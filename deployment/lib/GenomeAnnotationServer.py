#!/usr/bin/env python
from wsgiref.simple_server import make_server
import sys
import json
import traceback
from multiprocessing import Process
from getopt import getopt, GetoptError
from jsonrpcbase import JSONRPCService, InvalidParamsError, KeywordError,\
    JSONRPCError, ServerError, InvalidRequestError
from os import environ
from ConfigParser import ConfigParser
from biokbase import log
import biokbase.nexus

DEPLOY = 'KB_DEPLOYMENT_CONFIG'
SERVICE = 'KB_SERVICE_NAME'

# Note that the error fields do not match the 2.0 JSONRPC spec


def get_config_file():
    return environ.get(DEPLOY, None)


def get_service_name():
    return environ.get(SERVICE, None)


def get_config():
    if not get_config_file() or not get_service_name():
        return None
    retconfig = {}
    config = ConfigParser()
    config.read(get_config_file())
    for nameval in config.items(get_service_name()):
        retconfig[nameval[0]] = nameval[1]
    return retconfig

config = get_config()

from GenomeAnnotationImpl import GenomeAnnotation
impl_GenomeAnnotation = GenomeAnnotation(config)


class JSONObjectEncoder(json.JSONEncoder):

    def default(self, obj):
        if isinstance(obj, set):
            return list(obj)
        if isinstance(obj, frozenset):
            return list(obj)
        if hasattr(obj, 'toJSONable'):
            return obj.toJSONable()
        return json.JSONEncoder.default(self, obj)


class JSONRPCServiceCustom(JSONRPCService):

    def call(self, ctx, jsondata):
        """
        Calls jsonrpc service's method and returns its return value in a JSON
        string or None if there is none.

        Arguments:
        jsondata -- remote method call in jsonrpc format
        """
        result = self.call_py(ctx, jsondata)
        if result is not None:
            return json.dumps(result, cls=JSONObjectEncoder)

        return None

    def _call_method(self, ctx, request):
        """Calls given method with given params and returns it value."""
        method = self.method_data[request['method']]['method']
        params = request['params']
        result = None
        try:
            if isinstance(params, list):
                # Does it have enough arguments?
                if len(params) < self._man_args(method) - 1:
                    raise InvalidParamsError('not enough arguments')
                # Does it have too many arguments?
                if(not self._vargs(method) and len(params) >
                        self._max_args(method) - 1):
                    raise InvalidParamsError('too many arguments')

                result = method(ctx, *params)
            elif isinstance(params, dict):
                # Do not accept keyword arguments if the jsonrpc version is
                # not >=1.1.
                if request['jsonrpc'] < 11:
                    raise KeywordError

                result = method(ctx, **params)
            else:  # No params
                result = method(ctx)
        except JSONRPCError:
            raise
        except Exception as e:
            # log.exception('method %s threw an exception' % request['method'])
            # Exception was raised inside the method.
            newerr = ServerError()
            newerr.trace = traceback.format_exc()
            newerr.data = e.message
            raise newerr
        return result

    def call_py(self, ctx, jsondata):
        """
        Calls jsonrpc service's method and returns its return value in python
        object format or None if there is none.

        This method is same as call() except the return value is a python
        object instead of JSON string. This method is mainly only useful for
        debugging purposes.
        """
        rdata = jsondata
        # we already deserialize the json string earlier in the server code, no
        # need to do it again
#        try:
#            rdata = json.loads(jsondata)
#        except ValueError:
#            raise ParseError

        # set some default values for error handling
        request = self._get_default_vals()

        if isinstance(rdata, dict) and rdata:
            # It's a single request.
            self._fill_request(request, rdata)
            respond = self._handle_request(ctx, request)

            # Don't respond to notifications
            if respond is None:
                return None

            return respond
        elif isinstance(rdata, list) and rdata:
            # It's a batch.
            requests = []
            responds = []

            for rdata_ in rdata:
                # set some default values for error handling
                request_ = self._get_default_vals()
                self._fill_request(request_, rdata_)
                requests.append(request_)

            for request_ in requests:
                respond = self._handle_request(ctx, request_)
                # Don't respond to notifications
                if respond is not None:
                    responds.append(respond)

            if responds:
                return responds

            # Nothing to respond.
            return None
        else:
            # empty dict, list or wrong type
            raise InvalidRequestError

    def _handle_request(self, ctx, request):
        """Handles given request and returns its response."""
        if self.method_data[request['method']].has_key('types'): # @IgnorePep8
            self._validate_params_types(request['method'], request['params'])

        result = self._call_method(ctx, request)

        # Do not respond to notifications.
        if request['id'] is None:
            return None

        respond = {}
        self._fill_ver(request['jsonrpc'], respond)
        respond['result'] = result
        respond['id'] = request['id']

        return respond


class MethodContext(dict):

    def __init__(self, logger):
        self['client_ip'] = None
        self['user_id'] = None
        self['authenticated'] = None
        self['token'] = None
        self['module'] = None
        self['method'] = None
        self['call_id'] = None
        self._debug_levels = set([7, 8, 9, 'DEBUG', 'DEBUG2', 'DEBUG3'])
        self._logger = logger

    def log_err(self, message):
        self._log(log.ERR, message)

    def log_info(self, message):
        self._log(log.INFO, message)

    def log_debug(self, message, level=1):
        if level in self._debug_levels:
            pass
        else:
            level = int(level)
            if level < 1 or level > 3:
                raise ValueError("Illegal log level: " + str(level))
            level = level + 6
        self._log(level, message)

    def set_log_level(self, level):
        self._logger.set_log_level(level)

    def get_log_level(self):
        return self._logger.get_log_level()

    def clear_log_level(self):
        self._logger.clear_user_log_level()

    def _log(self, level, message):
        self._logger.log_message(level, message, self['client_ip'],
                                 self['user_id'], self['module'],
                                 self['method'], self['call_id'])


def getIPAddress(environ):
    xFF = environ.get('HTTP_X_FORWARDED_FOR')
    realIP = environ.get('HTTP_X_REAL_IP')
    trustXHeaders = config is None or \
        config.get('dont_trust_x_ip_headers') != 'true'

    if (trustXHeaders):
        if (xFF):
            return xFF.split(',')[0].strip()
        if (realIP):
            return realIP.strip()
    return environ.get('REMOTE_ADDR')


class Application(object):
    # Wrap the wsgi handler in a class definition so that we can
    # do some initialization and avoid regenerating stuff over
    # and over

    def logcallback(self):
        self.serverlog.set_log_file(self.userlog.get_log_file())

    def log(self, level, context, message):
        self.serverlog.log_message(level, message, context['client_ip'],
                                   context['user_id'], context['module'],
                                   context['method'], context['call_id'])

    def __init__(self):
        submod = get_service_name() or 'GenomeAnnotation'
        self.userlog = log.log(
            submod, ip_address=True, authuser=True, module=True, method=True,
            call_id=True, changecallback=self.logcallback,
            config=get_config_file())
        self.serverlog = log.log(
            submod, ip_address=True, authuser=True, module=True, method=True,
            call_id=True, logfile=self.userlog.get_log_file())
        self.serverlog.set_log_level(6)
        self.rpc_service = JSONRPCServiceCustom()
        self.method_authentication = dict()
        self.rpc_service.add(impl_GenomeAnnotation.genome_ids_to_genomes,
                             name='GenomeAnnotation.genome_ids_to_genomes',
                             types=[list])
        self.method_authentication['GenomeAnnotation.genome_ids_to_genomes'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.create_genome,
                             name='GenomeAnnotation.create_genome',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.create_genome'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.create_genome_from_SEED,
                             name='GenomeAnnotation.create_genome_from_SEED',
                             types=[basestring])
        self.method_authentication['GenomeAnnotation.create_genome_from_SEED'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.create_genome_from_RAST,
                             name='GenomeAnnotation.create_genome_from_RAST',
                             types=[basestring])
        self.method_authentication['GenomeAnnotation.create_genome_from_RAST'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.set_metadata,
                             name='GenomeAnnotation.set_metadata',
                             types=[dict, dict])
        self.method_authentication['GenomeAnnotation.set_metadata'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.add_contigs,
                             name='GenomeAnnotation.add_contigs',
                             types=[dict, list])
        self.method_authentication['GenomeAnnotation.add_contigs'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.add_contigs_from_handle,
                             name='GenomeAnnotation.add_contigs_from_handle',
                             types=[dict, list])
        self.method_authentication['GenomeAnnotation.add_contigs_from_handle'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.add_features,
                             name='GenomeAnnotation.add_features',
                             types=[dict, list])
        self.method_authentication['GenomeAnnotation.add_features'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.genomeTO_to_reconstructionTO,
                             name='GenomeAnnotation.genomeTO_to_reconstructionTO',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.genomeTO_to_reconstructionTO'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.genomeTO_to_feature_data,
                             name='GenomeAnnotation.genomeTO_to_feature_data',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.genomeTO_to_feature_data'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.reconstructionTO_to_roles,
                             name='GenomeAnnotation.reconstructionTO_to_roles',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.reconstructionTO_to_roles'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.reconstructionTO_to_subsystems,
                             name='GenomeAnnotation.reconstructionTO_to_subsystems',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.reconstructionTO_to_subsystems'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.assign_functions_to_CDSs,
                             name='GenomeAnnotation.assign_functions_to_CDSs',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.assign_functions_to_CDSs'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.annotate_genome,
                             name='GenomeAnnotation.annotate_genome',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.annotate_genome'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_selenoproteins,
                             name='GenomeAnnotation.call_selenoproteins',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_selenoproteins'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_pyrrolysoproteins,
                             name='GenomeAnnotation.call_pyrrolysoproteins',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_pyrrolysoproteins'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_selenoprotein,
                             name='GenomeAnnotation.call_features_selenoprotein',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_features_selenoprotein'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_pyrrolysoprotein,
                             name='GenomeAnnotation.call_features_pyrrolysoprotein',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_features_pyrrolysoprotein'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_insertion_sequences,
                             name='GenomeAnnotation.call_features_insertion_sequences',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_features_insertion_sequences'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_rRNA_SEED,
                             name='GenomeAnnotation.call_features_rRNA_SEED',
                             types=[dict, list])
        self.method_authentication['GenomeAnnotation.call_features_rRNA_SEED'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_tRNA_trnascan,
                             name='GenomeAnnotation.call_features_tRNA_trnascan',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_features_tRNA_trnascan'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_RNAs,
                             name='GenomeAnnotation.call_RNAs',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_RNAs'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_CDS_glimmer3,
                             name='GenomeAnnotation.call_features_CDS_glimmer3',
                             types=[dict, dict])
        self.method_authentication['GenomeAnnotation.call_features_CDS_glimmer3'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_CDS_prodigal,
                             name='GenomeAnnotation.call_features_CDS_prodigal',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_features_CDS_prodigal'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_CDS_genemark,
                             name='GenomeAnnotation.call_features_CDS_genemark',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_features_CDS_genemark'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_CDS_SEED_projection,
                             name='GenomeAnnotation.call_features_CDS_SEED_projection',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_features_CDS_SEED_projection'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_CDS_FragGeneScan,
                             name='GenomeAnnotation.call_features_CDS_FragGeneScan',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_features_CDS_FragGeneScan'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_repeat_region_SEED,
                             name='GenomeAnnotation.call_features_repeat_region_SEED',
                             types=[dict, dict])
        self.method_authentication['GenomeAnnotation.call_features_repeat_region_SEED'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_prophage_phispy,
                             name='GenomeAnnotation.call_features_prophage_phispy',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_features_prophage_phispy'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_scan_for_matches,
                             name='GenomeAnnotation.call_features_scan_for_matches',
                             types=[dict, basestring, basestring])
        self.method_authentication['GenomeAnnotation.call_features_scan_for_matches'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.annotate_proteins_similarity,
                             name='GenomeAnnotation.annotate_proteins_similarity',
                             types=[dict, dict])
        self.method_authentication['GenomeAnnotation.annotate_proteins_similarity'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.annotate_proteins_kmer_v1,
                             name='GenomeAnnotation.annotate_proteins_kmer_v1',
                             types=[dict, dict])
        self.method_authentication['GenomeAnnotation.annotate_proteins_kmer_v1'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.annotate_proteins_kmer_v2,
                             name='GenomeAnnotation.annotate_proteins_kmer_v2',
                             types=[dict, dict])
        self.method_authentication['GenomeAnnotation.annotate_proteins_kmer_v2'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.resolve_overlapping_features,
                             name='GenomeAnnotation.resolve_overlapping_features',
                             types=[dict, dict])
        self.method_authentication['GenomeAnnotation.resolve_overlapping_features'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_ProtoCDS_kmer_v1,
                             name='GenomeAnnotation.call_features_ProtoCDS_kmer_v1',
                             types=[dict, dict])
        self.method_authentication['GenomeAnnotation.call_features_ProtoCDS_kmer_v1'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_ProtoCDS_kmer_v2,
                             name='GenomeAnnotation.call_features_ProtoCDS_kmer_v2',
                             types=[dict, dict])
        self.method_authentication['GenomeAnnotation.call_features_ProtoCDS_kmer_v2'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.enumerate_special_protein_databases,
                             name='GenomeAnnotation.enumerate_special_protein_databases',
                             types=[])
        self.method_authentication['GenomeAnnotation.enumerate_special_protein_databases'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.compute_special_proteins,
                             name='GenomeAnnotation.compute_special_proteins',
                             types=[dict, list])
        self.method_authentication['GenomeAnnotation.compute_special_proteins'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.annotate_special_proteins,
                             name='GenomeAnnotation.annotate_special_proteins',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.annotate_special_proteins'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.annotate_families_figfam_v1,
                             name='GenomeAnnotation.annotate_families_figfam_v1',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.annotate_families_figfam_v1'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.annotate_null_to_hypothetical,
                             name='GenomeAnnotation.annotate_null_to_hypothetical',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.annotate_null_to_hypothetical'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.compute_cdd,
                             name='GenomeAnnotation.compute_cdd',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.compute_cdd'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.annotate_proteins,
                             name='GenomeAnnotation.annotate_proteins',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.annotate_proteins'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.estimate_crude_phylogenetic_position_kmer,
                             name='GenomeAnnotation.estimate_crude_phylogenetic_position_kmer',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.estimate_crude_phylogenetic_position_kmer'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.find_close_neighbors,
                             name='GenomeAnnotation.find_close_neighbors',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.find_close_neighbors'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_strep_suis_repeat,
                             name='GenomeAnnotation.call_features_strep_suis_repeat',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_features_strep_suis_repeat'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_strep_pneumo_repeat,
                             name='GenomeAnnotation.call_features_strep_pneumo_repeat',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_features_strep_pneumo_repeat'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.call_features_crispr,
                             name='GenomeAnnotation.call_features_crispr',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.call_features_crispr'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.update_functions,
                             name='GenomeAnnotation.update_functions',
                             types=[dict, list, dict])
        self.method_authentication['GenomeAnnotation.update_functions'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.renumber_features,
                             name='GenomeAnnotation.renumber_features',
                             types=[dict])
        self.method_authentication['GenomeAnnotation.renumber_features'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.export_genome,
                             name='GenomeAnnotation.export_genome',
                             types=[dict, basestring, list])
        self.method_authentication['GenomeAnnotation.export_genome'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.enumerate_classifiers,
                             name='GenomeAnnotation.enumerate_classifiers',
                             types=[])
        self.method_authentication['GenomeAnnotation.enumerate_classifiers'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.query_classifier_groups,
                             name='GenomeAnnotation.query_classifier_groups',
                             types=[basestring])
        self.method_authentication['GenomeAnnotation.query_classifier_groups'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.query_classifier_taxonomies,
                             name='GenomeAnnotation.query_classifier_taxonomies',
                             types=[basestring])
        self.method_authentication['GenomeAnnotation.query_classifier_taxonomies'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.classify_into_bins,
                             name='GenomeAnnotation.classify_into_bins',
                             types=[basestring, list])
        self.method_authentication['GenomeAnnotation.classify_into_bins'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.classify_full,
                             name='GenomeAnnotation.classify_full',
                             types=[basestring, list])
        self.method_authentication['GenomeAnnotation.classify_full'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.default_workflow,
                             name='GenomeAnnotation.default_workflow',
                             types=[])
        self.method_authentication['GenomeAnnotation.default_workflow'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.complete_workflow_template,
                             name='GenomeAnnotation.complete_workflow_template',
                             types=[])
        self.method_authentication['GenomeAnnotation.complete_workflow_template'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.run_pipeline,
                             name='GenomeAnnotation.run_pipeline',
                             types=[dict, dict])
        self.method_authentication['GenomeAnnotation.run_pipeline'] = 'none'
        self.rpc_service.add(impl_GenomeAnnotation.pipeline_batch_start,
                             name='GenomeAnnotation.pipeline_batch_start',
                             types=[list, dict])
        self.method_authentication['GenomeAnnotation.pipeline_batch_start'] = 'required'
        self.rpc_service.add(impl_GenomeAnnotation.pipeline_batch_status,
                             name='GenomeAnnotation.pipeline_batch_status',
                             types=[basestring])
        self.method_authentication['GenomeAnnotation.pipeline_batch_status'] = 'required'
        self.rpc_service.add(impl_GenomeAnnotation.pipeline_batch_enumerate_batches,
                             name='GenomeAnnotation.pipeline_batch_enumerate_batches',
                             types=[])
        self.method_authentication['GenomeAnnotation.pipeline_batch_enumerate_batches'] = 'required'
        self.auth_client = biokbase.nexus.Client(
            config={'server': 'nexus.api.globusonline.org',
                    'verify_ssl': True,
                    'client': None,
                    'client_secret': None})

    def __call__(self, environ, start_response):
        # Context object, equivalent to the perl impl CallContext
        ctx = MethodContext(self.userlog)
        ctx['client_ip'] = getIPAddress(environ)
        status = '500 Internal Server Error'

        try:
            body_size = int(environ.get('CONTENT_LENGTH', 0))
        except (ValueError):
            body_size = 0
        if environ['REQUEST_METHOD'] == 'OPTIONS':
            # we basically do nothing and just return headers
            status = '200 OK'
            rpc_result = ""
        else:
            request_body = environ['wsgi.input'].read(body_size)
            try:
                req = json.loads(request_body)
            except ValueError as ve:
                err = {'error': {'code': -32700,
                                 'name': "Parse error",
                                 'message': str(ve),
                                 }
                       }
                rpc_result = self.process_error(err, ctx, {'version': '1.1'})
            else:
                ctx['module'], ctx['method'] = req['method'].split('.')
                ctx['call_id'] = req['id']
                try:
                    token = environ.get('HTTP_AUTHORIZATION')
                    # parse out the method being requested and check if it
                    # has an authentication requirement
                    auth_req = self.method_authentication.get(req['method'],
                                                              "none")
                    if auth_req != "none":
                        if token is None and auth_req == 'required':
                            err = ServerError()
                            err.data = "Authentication required for " + \
                                "GenomeAnnotation but no authentication header was passed"
                            raise err
                        elif token is None and auth_req == 'optional':
                            pass
                        else:
                            try:
                                user, _, _ = \
                                    self.auth_client.validate_token(token)
                                ctx['user_id'] = user
                                ctx['authenticated'] = 1
                                ctx['token'] = token
                            except Exception, e:
                                if auth_req == 'required':
                                    err = ServerError()
                                    err.data = \
                                        "Token validation failed: %s" % e
                                    raise err
                    if (environ.get('HTTP_X_FORWARDED_FOR')):
                        self.log(log.INFO, ctx, 'X-Forwarded-For: ' +
                                 environ.get('HTTP_X_FORWARDED_FOR'))
                    self.log(log.INFO, ctx, 'start method')
                    rpc_result = self.rpc_service.call(ctx, req)
                    self.log(log.INFO, ctx, 'end method')
                except JSONRPCError as jre:
                    err = {'error': {'code': jre.code,
                                     'name': jre.message,
                                     'message': jre.data
                                     }
                           }
                    trace = jre.trace if hasattr(jre, 'trace') else None
                    rpc_result = self.process_error(err, ctx, req, trace)
                except Exception, e:
                    err = {'error': {'code': 0,
                                     'name': 'Unexpected Server Error',
                                     'message': 'An unexpected server error ' +
                                                'occurred',
                                     }
                           }
                    rpc_result = self.process_error(err, ctx, req,
                                                    traceback.format_exc())
                else:
                    status = '200 OK'

        # print 'The request method was %s\n' % environ['REQUEST_METHOD']
        # print 'The environment dictionary is:\n%s\n' % pprint.pformat(environ) @IgnorePep8
        # print 'The request body was: %s' % request_body
        # print 'The result from the method call is:\n%s\n' % \
        #    pprint.pformat(rpc_result)

        if rpc_result:
            response_body = rpc_result
        else:
            response_body = ''

        response_headers = [
            ('Access-Control-Allow-Origin', '*'),
            ('Access-Control-Allow-Headers', environ.get(
                'HTTP_ACCESS_CONTROL_REQUEST_HEADERS', 'authorization')),
            ('content-type', 'application/json'),
            ('content-length', str(len(response_body)))]
        start_response(status, response_headers)
        return [response_body]

    def process_error(self, error, context, request, trace=None):
        if trace:
            self.log(log.ERR, context, trace.split('\n')[0:-1])
        if 'id' in request:
            error['id'] = request['id']
        if 'version' in request:
            error['version'] = request['version']
            error['error']['error'] = trace
        elif 'jsonrpc' in request:
            error['jsonrpc'] = request['jsonrpc']
            error['error']['data'] = trace
        else:
            error['version'] = '1.0'
            error['error']['error'] = trace
        return json.dumps(error)

application = Application()

# This is the uwsgi application dictionary. On startup uwsgi will look
# for this dict and pull its configuration from here.
# This simply lists where to "mount" the application in the URL path
#
# This uwsgi module "magically" appears when running the app within
# uwsgi and is not available otherwise, so wrap an exception handler
# around it
#
# To run this server in uwsgi with 4 workers listening on port 9999 use:
# uwsgi -M -p 4 --http :9999 --wsgi-file _this_file_
# To run a using the single threaded python BaseHTTP service
# listening on port 9999 by default execute this file
#
try:
    import uwsgi
# Before we do anything with the application, see if the
# configs specify patching all std routines to be asynch
# *ONLY* use this if you are going to wrap the service in
# a wsgi container that has enabled gevent, such as
# uwsgi with the --gevent option
    if config is not None and config.get('gevent_monkeypatch_all', False):
        print "Monkeypatching std libraries for async"
        from gevent import monkey
        monkey.patch_all()
    uwsgi.applications = {
        '': application
        }
except ImportError:
    # Not available outside of wsgi, ignore
    pass

_proc = None


def start_server(host='localhost', port=0, newprocess=False):
    '''
    By default, will start the server on localhost on a system assigned port
    in the main thread. Excecution of the main thread will stay in the server
    main loop until interrupted. To run the server in a separate process, and
    thus allow the stop_server method to be called, set newprocess = True. This
    will also allow returning of the port number.'''

    global _proc
    if _proc:
        raise RuntimeError('server is already running')
    httpd = make_server(host, port, application)
    port = httpd.server_address[1]
    print "Listening on port %s" % port
    if newprocess:
        _proc = Process(target=httpd.serve_forever)
        _proc.daemon = True
        _proc.start()
    else:
        httpd.serve_forever()
    return port


def stop_server():
    global _proc
    _proc.terminate()
    _proc = None

if __name__ == "__main__":
    try:
        opts, args = getopt(sys.argv[1:], "", ["port=", "host="])
    except GetoptError as err:
        # print help information and exit:
        print str(err)  # will print something like "option -a not recognized"
        sys.exit(2)
    port = 9999
    host = 'localhost'
    for o, a in opts:
        if o == '--port':
            port = int(a)
        elif o == '--host':
            host = a
            print "Host set to %s" % host
        else:
            assert False, "unhandled option"

    start_server(host=host, port=port)
#    print "Listening on port %s" % port
#    httpd = make_server( host, port, application)
#
#    httpd.serve_forever()