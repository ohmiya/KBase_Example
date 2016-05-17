#BEGIN_HEADER
#END_HEADER


class AbstractHandle:
    '''
    Module Name:
    AbstractHandle

    Module Description:
    The AbstractHandle module provides a programmatic
access to a remote file store.
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

    def new_handle(self, ctx):
        # ctx is the context object
        # return variables are: h
        #BEGIN new_handle
        #END new_handle

        # At some point might do deeper type checking...
        if not isinstance(h, dict):
            raise ValueError('Method new_handle return value ' +
                             'h is not type dict as required.')
        # return the results
        return [h]

    def localize_handle(self, ctx, h1, service_name):
        # ctx is the context object
        # return variables are: h2
        #BEGIN localize_handle
        #END localize_handle

        # At some point might do deeper type checking...
        if not isinstance(h2, dict):
            raise ValueError('Method localize_handle return value ' +
                             'h2 is not type dict as required.')
        # return the results
        return [h2]

    def initialize_handle(self, ctx, h1):
        # ctx is the context object
        # return variables are: h2
        #BEGIN initialize_handle
        #END initialize_handle

        # At some point might do deeper type checking...
        if not isinstance(h2, dict):
            raise ValueError('Method initialize_handle return value ' +
                             'h2 is not type dict as required.')
        # return the results
        return [h2]

    def persist_handle(self, ctx, h):
        # ctx is the context object
        # return variables are: hid
        #BEGIN persist_handle
        #END persist_handle

        # At some point might do deeper type checking...
        if not isinstance(hid, basestring):
            raise ValueError('Method persist_handle return value ' +
                             'hid is not type basestring as required.')
        # return the results
        return [hid]

    def upload(self, ctx, infile):
        # ctx is the context object
        # return variables are: h
        #BEGIN upload
        #END upload

        # At some point might do deeper type checking...
        if not isinstance(h, dict):
            raise ValueError('Method upload return value ' +
                             'h is not type dict as required.')
        # return the results
        return [h]

    def download(self, ctx, h, outfile):
        # ctx is the context object
        #BEGIN download
        #END download

    def upload_metadata(self, ctx, h, infile):
        # ctx is the context object
        #BEGIN upload_metadata
        #END upload_metadata

    def download_metadata(self, ctx, h, outfile):
        # ctx is the context object
        #BEGIN download_metadata
        #END download_metadata

    def ids_to_handles(self, ctx, ids):
        # ctx is the context object
        # return variables are: handles
        #BEGIN ids_to_handles
        #END ids_to_handles

        # At some point might do deeper type checking...
        if not isinstance(handles, list):
            raise ValueError('Method ids_to_handles return value ' +
                             'handles is not type list as required.')
        # return the results
        return [handles]

    def hids_to_handles(self, ctx, hids):
        # ctx is the context object
        # return variables are: handles
        #BEGIN hids_to_handles
        #END hids_to_handles

        # At some point might do deeper type checking...
        if not isinstance(handles, list):
            raise ValueError('Method hids_to_handles return value ' +
                             'handles is not type list as required.')
        # return the results
        return [handles]

    def are_readable(self, ctx, arg_1):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN are_readable
        #END are_readable

        # At some point might do deeper type checking...
        if not isinstance(returnVal, int):
            raise ValueError('Method are_readable return value ' +
                             'returnVal is not type int as required.')
        # return the results
        return [returnVal]

    def is_readable(self, ctx, id):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN is_readable
        #END is_readable

        # At some point might do deeper type checking...
        if not isinstance(returnVal, int):
            raise ValueError('Method is_readable return value ' +
                             'returnVal is not type int as required.')
        # return the results
        return [returnVal]

    def list_handles(self, ctx):
        # ctx is the context object
        # return variables are: l
        #BEGIN list_handles
        #END list_handles

        # At some point might do deeper type checking...
        if not isinstance(l, list):
            raise ValueError('Method list_handles return value ' +
                             'l is not type list as required.')
        # return the results
        return [l]

    def delete_handles(self, ctx, l):
        # ctx is the context object
        #BEGIN delete_handles
        #END delete_handles

    def give(self, ctx, user, perm, h):
        # ctx is the context object
        #BEGIN give
        #END give

    def ids_to_handles(self, ctx, ids):
        # ctx is the context object
        # return variables are: handles
        #BEGIN ids_to_handles
        #END ids_to_handles

        # At some point might do deeper type checking...
        if not isinstance(handles, list):
            raise ValueError('Method ids_to_handles return value ' +
                             'handles is not type list as required.')
        # return the results
        return [handles]
