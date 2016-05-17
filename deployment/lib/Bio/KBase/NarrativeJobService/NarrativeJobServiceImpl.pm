package Bio::KBase::NarrativeJobService::NarrativeJobServiceImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

NarrativeJobService

=head1 DESCRIPTION



=cut

#BEGIN_HEADER
use NarrativeJobService;
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
	$self->{'instance'} = new NarrativeJobService(@args);
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 run_app

  $return = $obj->run_app($app)

=over 4

=item Parameter and return types

=begin html

<pre>
$app is an app
$return is an app_state
app is a reference to a hash where the following keys are defined:
	name has a value which is a string
	steps has a value which is a reference to a list where each element is a step
step is a reference to a hash where the following keys are defined:
	step_id has a value which is a string
	type has a value which is a string
	service has a value which is a service_method
	script has a value which is a script_method
	parameters has a value which is a reference to a list where each element is a step_parameter
	is_long_running has a value which is a boolean
service_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	service_url has a value which is a string
script_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	has_files has a value which is a boolean
boolean is an int
step_parameter is a reference to a hash where the following keys are defined:
	label has a value which is a string
	value has a value which is a string
	type has a value which is a string
	step_source has a value which is a string
	is_workspace_id has a value which is a boolean
	ws_object has a value which is a workspace_object
workspace_object is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	object_type has a value which is a string
	is_input has a value which is a boolean
app_state is a reference to a hash where the following keys are defined:
	job_id has a value which is a string
	job_state has a value which is a string
	submit_time has a value which is a string
	start_time has a value which is a string
	complete_time has a value which is a string
	position has a value which is an int
	running_step_id has a value which is a string
	step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
	step_errors has a value which is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$app is an app
$return is an app_state
app is a reference to a hash where the following keys are defined:
	name has a value which is a string
	steps has a value which is a reference to a list where each element is a step
step is a reference to a hash where the following keys are defined:
	step_id has a value which is a string
	type has a value which is a string
	service has a value which is a service_method
	script has a value which is a script_method
	parameters has a value which is a reference to a list where each element is a step_parameter
	is_long_running has a value which is a boolean
service_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	service_url has a value which is a string
script_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	has_files has a value which is a boolean
boolean is an int
step_parameter is a reference to a hash where the following keys are defined:
	label has a value which is a string
	value has a value which is a string
	type has a value which is a string
	step_source has a value which is a string
	is_workspace_id has a value which is a boolean
	ws_object has a value which is a workspace_object
workspace_object is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	object_type has a value which is a string
	is_input has a value which is a boolean
app_state is a reference to a hash where the following keys are defined:
	job_id has a value which is a string
	job_state has a value which is a string
	submit_time has a value which is a string
	start_time has a value which is a string
	complete_time has a value which is a string
	position has a value which is an int
	running_step_id has a value which is a string
	step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
	step_errors has a value which is a reference to a hash where the key is a string and the value is a string


=end text



=item Description



=back

=cut

sub run_app
{
    my $self = shift;
    my($app) = @_;

    my @_bad_arguments;
    (ref($app) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"app\" (value was \"$app\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to run_app:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'run_app');
    }

    my $ctx = $Bio::KBase::NarrativeJobService::Service::CallContext;
    my($return);
    #BEGIN run_app
    $self->{'instance'}->token($ctx->{'token'});
    $return = $self->{'instance'}->run_app($app, $ctx->{'user_id'});
    #END run_app
    my @_bad_returns;
    (ref($return) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to run_app:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'run_app');
    }
    return($return);
}




=head2 compose_app

  $workflow = $obj->compose_app($app)

=over 4

=item Parameter and return types

=begin html

<pre>
$app is an app
$workflow is a string
app is a reference to a hash where the following keys are defined:
	name has a value which is a string
	steps has a value which is a reference to a list where each element is a step
step is a reference to a hash where the following keys are defined:
	step_id has a value which is a string
	type has a value which is a string
	service has a value which is a service_method
	script has a value which is a script_method
	parameters has a value which is a reference to a list where each element is a step_parameter
	is_long_running has a value which is a boolean
service_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	service_url has a value which is a string
script_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	has_files has a value which is a boolean
boolean is an int
step_parameter is a reference to a hash where the following keys are defined:
	label has a value which is a string
	value has a value which is a string
	type has a value which is a string
	step_source has a value which is a string
	is_workspace_id has a value which is a boolean
	ws_object has a value which is a workspace_object
workspace_object is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	object_type has a value which is a string
	is_input has a value which is a boolean

</pre>

=end html

=begin text

$app is an app
$workflow is a string
app is a reference to a hash where the following keys are defined:
	name has a value which is a string
	steps has a value which is a reference to a list where each element is a step
step is a reference to a hash where the following keys are defined:
	step_id has a value which is a string
	type has a value which is a string
	service has a value which is a service_method
	script has a value which is a script_method
	parameters has a value which is a reference to a list where each element is a step_parameter
	is_long_running has a value which is a boolean
service_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	service_url has a value which is a string
script_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	has_files has a value which is a boolean
boolean is an int
step_parameter is a reference to a hash where the following keys are defined:
	label has a value which is a string
	value has a value which is a string
	type has a value which is a string
	step_source has a value which is a string
	is_workspace_id has a value which is a boolean
	ws_object has a value which is a workspace_object
workspace_object is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	object_type has a value which is a string
	is_input has a value which is a boolean


=end text



=item Description



=back

=cut

sub compose_app
{
    my $self = shift;
    my($app) = @_;

    my @_bad_arguments;
    (ref($app) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"app\" (value was \"$app\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to compose_app:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compose_app');
    }

    my $ctx = $Bio::KBase::NarrativeJobService::Service::CallContext;
    my($workflow);
    #BEGIN compose_app
    $self->{'instance'}->token($ctx->{'token'});
    $workflow = $self->{'instance'}->compose_app($app, $ctx->{'user_id'});
    #END compose_app
    my @_bad_returns;
    (!ref($workflow)) or push(@_bad_returns, "Invalid type for return variable \"workflow\" (value was \"$workflow\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to compose_app:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compose_app');
    }
    return($workflow);
}




=head2 check_app_state

  $return = $obj->check_app_state($job_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$job_id is a string
$return is an app_state
app_state is a reference to a hash where the following keys are defined:
	job_id has a value which is a string
	job_state has a value which is a string
	submit_time has a value which is a string
	start_time has a value which is a string
	complete_time has a value which is a string
	position has a value which is an int
	running_step_id has a value which is a string
	step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
	step_errors has a value which is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$job_id is a string
$return is an app_state
app_state is a reference to a hash where the following keys are defined:
	job_id has a value which is a string
	job_state has a value which is a string
	submit_time has a value which is a string
	start_time has a value which is a string
	complete_time has a value which is a string
	position has a value which is an int
	running_step_id has a value which is a string
	step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
	step_errors has a value which is a reference to a hash where the key is a string and the value is a string


=end text



=item Description



=back

=cut

sub check_app_state
{
    my $self = shift;
    my($job_id) = @_;

    my @_bad_arguments;
    (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument \"job_id\" (value was \"$job_id\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to check_app_state:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'check_app_state');
    }

    my $ctx = $Bio::KBase::NarrativeJobService::Service::CallContext;
    my($return);
    #BEGIN check_app_state
    $self->{'instance'}->token($ctx->{'token'});
    $return = $self->{'instance'}->check_app_state($job_id);
    #END check_app_state
    my @_bad_returns;
    (ref($return) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to check_app_state:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'check_app_state');
    }
    return($return);
}




=head2 suspend_app

  $status = $obj->suspend_app($job_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$job_id is a string
$status is a string

</pre>

=end html

=begin text

$job_id is a string
$status is a string


=end text



=item Description

status - 'success' or 'failure' of action

=back

=cut

sub suspend_app
{
    my $self = shift;
    my($job_id) = @_;

    my @_bad_arguments;
    (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument \"job_id\" (value was \"$job_id\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to suspend_app:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'suspend_app');
    }

    my $ctx = $Bio::KBase::NarrativeJobService::Service::CallContext;
    my($status);
    #BEGIN suspend_app
    $self->{'instance'}->token($ctx->{'token'});
    $status= $self->{'instance'}->suspend_app($job_id);
    #END suspend_app
    my @_bad_returns;
    (!ref($status)) or push(@_bad_returns, "Invalid type for return variable \"status\" (value was \"$status\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to suspend_app:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'suspend_app');
    }
    return($status);
}




=head2 resume_app

  $status = $obj->resume_app($job_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$job_id is a string
$status is a string

</pre>

=end html

=begin text

$job_id is a string
$status is a string


=end text



=item Description



=back

=cut

sub resume_app
{
    my $self = shift;
    my($job_id) = @_;

    my @_bad_arguments;
    (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument \"job_id\" (value was \"$job_id\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to resume_app:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'resume_app');
    }

    my $ctx = $Bio::KBase::NarrativeJobService::Service::CallContext;
    my($status);
    #BEGIN resume_app
    $self->{'instance'}->token($ctx->{'token'});
    $status = $self->{'instance'}->resume_app($job_id);
    #END resume_app
    my @_bad_returns;
    (!ref($status)) or push(@_bad_returns, "Invalid type for return variable \"status\" (value was \"$status\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to resume_app:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'resume_app');
    }
    return($status);
}




=head2 delete_app

  $status = $obj->delete_app($job_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$job_id is a string
$status is a string

</pre>

=end html

=begin text

$job_id is a string
$status is a string


=end text



=item Description



=back

=cut

sub delete_app
{
    my $self = shift;
    my($job_id) = @_;

    my @_bad_arguments;
    (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument \"job_id\" (value was \"$job_id\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to delete_app:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'delete_app');
    }

    my $ctx = $Bio::KBase::NarrativeJobService::Service::CallContext;
    my($status);
    #BEGIN delete_app
    $self->{'instance'}->token($ctx->{'token'});
    $status = $self->{'instance'}->delete_app($job_id);
    #END delete_app
    my @_bad_returns;
    (!ref($status)) or push(@_bad_returns, "Invalid type for return variable \"status\" (value was \"$status\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to delete_app:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'delete_app');
    }
    return($status);
}




=head2 list_config

  $return = $obj->list_config()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$return is a reference to a hash where the key is a string and the value is a string


=end text



=item Description



=back

=cut

sub list_config
{
    my $self = shift;

    my $ctx = $Bio::KBase::NarrativeJobService::Service::CallContext;
    my($return);
    #BEGIN list_config
    $return = $self->{'instance'}->list_config();
    #END list_config
    my @_bad_returns;
    (ref($return) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to list_config:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_config');
    }
    return($return);
}




=head2 version 

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}

=head1 TYPES



=head2 boolean

=over 4



=item Description

@range [0,1]


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 service_method

=over 4



=item Description

service_name - deployable KBase module
method_name - name of service command or script to invoke


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
service_name has a value which is a string
method_name has a value which is a string
service_url has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
service_name has a value which is a string
method_name has a value which is a string
service_url has a value which is a string


=end text

=back



=head2 script_method

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
service_name has a value which is a string
method_name has a value which is a string
has_files has a value which is a boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
service_name has a value which is a string
method_name has a value which is a string
has_files has a value which is a boolean


=end text

=back



=head2 workspace_object

=over 4



=item Description

label - label of parameter, can be empty string for positional parameters
value - value of parameter
type - type of parameter: 'string', 'int', 'float', or 'array'
       will be cast to given type when submitted
step_source - step_id that parameter derives from
is_workspace_id - parameter is a workspace id (value is object name)
# the below are only used if is_workspace_id is true
    is_input - parameter is an input (true) or output (false)
    workspace_name - name of workspace
    object_type - name of object type


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a string
object_type has a value which is a string
is_input has a value which is a boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a string
object_type has a value which is a string
is_input has a value which is a boolean


=end text

=back



=head2 step_parameter

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
label has a value which is a string
value has a value which is a string
type has a value which is a string
step_source has a value which is a string
is_workspace_id has a value which is a boolean
ws_object has a value which is a workspace_object

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
label has a value which is a string
value has a value which is a string
type has a value which is a string
step_source has a value which is a string
is_workspace_id has a value which is a boolean
ws_object has a value which is a workspace_object


=end text

=back



=head2 step

=over 4



=item Description

type - 'service' or 'script'


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
step_id has a value which is a string
type has a value which is a string
service has a value which is a service_method
script has a value which is a script_method
parameters has a value which is a reference to a list where each element is a step_parameter
is_long_running has a value which is a boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
step_id has a value which is a string
type has a value which is a string
service has a value which is a service_method
script has a value which is a script_method
parameters has a value which is a reference to a list where each element is a step_parameter
is_long_running has a value which is a boolean


=end text

=back



=head2 app

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
steps has a value which is a reference to a list where each element is a step

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
steps has a value which is a reference to a list where each element is a step


=end text

=back



=head2 app_state

=over 4



=item Description

job_id - id of job running app
job_state - 'queued', 'in-progress', 'completed', or 'suspend'
position - position of job in the queue, '0' indicates not enqueued: init, suspend, completed
submit_time - ISO8601 datetime formatted string of submission to queue
start_time - ISO8601 datetime formatted string of start of job step, may be empty string id not started
complete_time - SO8601 datetime formatted string of completion of job, may be empty string if not completed
running_step_id - id of step currently running
step_outputs - mapping step_id to stdout text produced by step, only for completed or errored steps
step_outputs - mapping step_id to stderr text produced by step, only for completed or errored steps


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
job_id has a value which is a string
job_state has a value which is a string
submit_time has a value which is a string
start_time has a value which is a string
complete_time has a value which is a string
position has a value which is an int
running_step_id has a value which is a string
step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
step_errors has a value which is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
job_id has a value which is a string
job_state has a value which is a string
submit_time has a value which is a string
start_time has a value which is a string
complete_time has a value which is a string
position has a value which is an int
running_step_id has a value which is a string
step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
step_errors has a value which is a reference to a hash where the key is a string and the value is a string


=end text

=back



=cut

1;
