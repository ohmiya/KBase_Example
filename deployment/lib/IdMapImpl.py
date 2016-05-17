#BEGIN_HEADER
#END_HEADER


class IdMap:
    '''
    Module Name:
    IdMap

    Module Description:
    The IdMap service client provides various lookups. These
lookups are designed to provide mappings of external
identifiers to kbase identifiers. 

Not all lookups are easily represented as one-to-one
mappings.
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

    def lookup_genome(self, ctx, s, type):
        # ctx is the context object
        # return variables are: id_pairs
        #BEGIN lookup_genome
        #END lookup_genome

        # At some point might do deeper type checking...
        if not isinstance(id_pairs, list):
            raise ValueError('Method lookup_genome return value ' +
                             'id_pairs is not type list as required.')
        # return the results
        return [id_pairs]

    def lookup_features(self, ctx, genome_id, aliases, feature_type, source_db):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN lookup_features
        #END lookup_features

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method lookup_features return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def lookup_feature_synonyms(self, ctx, genome_id, feature_type):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN lookup_feature_synonyms
        #END lookup_feature_synonyms

        # At some point might do deeper type checking...
        if not isinstance(returnVal, list):
            raise ValueError('Method lookup_feature_synonyms return value ' +
                             'returnVal is not type list as required.')
        # return the results
        return [returnVal]

    def longest_cds_from_locus(self, ctx, arg_1):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN longest_cds_from_locus
        #END longest_cds_from_locus

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method longest_cds_from_locus return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def longest_cds_from_mrna(self, ctx, arg_1):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN longest_cds_from_mrna
        #END longest_cds_from_mrna

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method longest_cds_from_mrna return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]
