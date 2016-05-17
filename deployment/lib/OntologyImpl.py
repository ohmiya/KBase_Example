#BEGIN_HEADER
#END_HEADER


class Ontology:
    '''
    Module Name:
    Ontology

    Module Description:
    This module provides public interface/APIs for KBase gene ontology (GO) services in a species-independent manner. It encapsulates the basic functionality of extracting domain ontologies (e.g. biological process, molecular function, cellular process)  of interest for a given set of species specific genes. It only accepts KBase gene ids. External gene ids need to be converted to KBase ids. Additionally, it also allows gene ontology enrichment analysis ("hypergeometric") to be performed on a set of genes that identifies statistically overrepresented GO terms within given gene sets, say for example, GO enrichment of over-expressed genes in drought stress in plant roots. To support these key features, currently this modules provides five API-functions that are backed by custom defined data structures. Majority of these API-functions accept a list of input items (majority of them being text strings) such as list of gene-ids, list of go-ids, list of ontology-domains, and Test type ( "hypergeometric") and return the requested results as tabular dataset.
    '''

    ######## WARNING FOR GEVENT USERS #######
    # Since asynchronous IO can lead to methods - even the same method -
    # interrupting each other, you must be *very* careful when using global
    # state. A method could easily clobber the state set by another while
    # the latter method is running.
    #########################################
    #BEGIN_CLASS_HEADER
    #END_CLASS_HEADER

    # config contains contents of config file in a hash or None if it couldn't
    # be found
    def __init__(self, config):
        #BEGIN_CONSTRUCTOR
        #END_CONSTRUCTOR
        pass

    def get_goidlist(self, ctx, geneIDList, domainList, ecList):
        # ctx is the context object
        # return variables are: results
        #BEGIN get_goidlist
        #END get_goidlist

        # At some point might do deeper type checking...
        if not isinstance(results, dict):
            raise ValueError('Method get_goidlist return value ' +
                             'results is not type dict as required.')
        # return the results
        return [results]

    def get_go_description(self, ctx, goIDList):
        # ctx is the context object
        # return variables are: results
        #BEGIN get_go_description
        #END get_go_description

        # At some point might do deeper type checking...
        if not isinstance(results, dict):
            raise ValueError('Method get_go_description return value ' +
                             'results is not type dict as required.')
        # return the results
        return [results]

    def get_go_enrichment(self, ctx, geneIDList, domainList, ecList, type, ontologytype):
        # ctx is the context object
        # return variables are: results
        #BEGIN get_go_enrichment
        #END get_go_enrichment

        # At some point might do deeper type checking...
        if not isinstance(results, list):
            raise ValueError('Method get_go_enrichment return value ' +
                             'results is not type list as required.')
        # return the results
        return [results]

    def get_go_annotation(self, ctx, geneIDList):
        # ctx is the context object
        # return variables are: results
        #BEGIN get_go_annotation
        #END get_go_annotation

        # At some point might do deeper type checking...
        if not isinstance(results, dict):
            raise ValueError('Method get_go_annotation return value ' +
                             'results is not type dict as required.')
        # return the results
        return [results]

    def association_test(self, ctx, gene_list, ws_name, in_obj_id, out_obj_id, type, correction_method, cut_off):
        # ctx is the context object
        # return variables are: results
        #BEGIN association_test
        #END association_test

        # At some point might do deeper type checking...
        if not isinstance(results, dict):
            raise ValueError('Method association_test return value ' +
                             'results is not type dict as required.')
        # return the results
        return [results]
