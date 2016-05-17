#BEGIN_HEADER
#END_HEADER


class IDServerAPI:
    '''
    Module Name:
    IDServerAPI

    Module Description:
    The KBase ID server provides access to the mappings between KBase identifiers and
external identifiers (the original identifiers for data that was migrated from
other databases into KBase).
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

    def kbase_ids_to_external_ids(self, ctx, ids):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN kbase_ids_to_external_ids
        #END kbase_ids_to_external_ids

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method kbase_ids_to_external_ids return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def external_ids_to_kbase_ids(self, ctx, external_db, ext_ids):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN external_ids_to_kbase_ids
        #END external_ids_to_kbase_ids

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method external_ids_to_kbase_ids return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def register_ids(self, ctx, prefix, db_name, ids):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN register_ids
        #END register_ids

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method register_ids return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def allocate_id_range(self, ctx, kbase_id_prefix, count):
        # ctx is the context object
        # return variables are: starting_value
        #BEGIN allocate_id_range
        #END allocate_id_range

        # At some point might do deeper type checking...
        if not isinstance(starting_value, int):
            raise ValueError('Method allocate_id_range return value ' +
                             'starting_value is not type int as required.')
        # return the results
        return [starting_value]

    def register_allocated_ids(self, ctx, prefix, db_name, assignments):
        # ctx is the context object
        #BEGIN register_allocated_ids
        #END register_allocated_ids

    def get_identifier_prefix(self, ctx):
        # ctx is the context object
        # return variables are: prefix
        #BEGIN get_identifier_prefix
        #END get_identifier_prefix

        # At some point might do deeper type checking...
        if not isinstance(prefix, basestring):
            raise ValueError('Method get_identifier_prefix return value ' +
                             'prefix is not type basestring as required.')
        # return the results
        return [prefix]
