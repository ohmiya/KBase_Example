#BEGIN_HEADER
#END_HEADER


class HandleMngr:
    '''
    Module Name:
    HandleMngr

    Module Description:
    The HandleMngr module provides an interface for the workspace
service to make handles sharable. When the owner shares a
workspace object that contains Handles, the underlying shock
object is made readable to the person that the workspace object
is being shared with.
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

    def is_readable(self, ctx, token, nodeurl):
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

    def add_read_acl(self, ctx, hids, username):
        # ctx is the context object
        #BEGIN add_read_acl
        #END add_read_acl
