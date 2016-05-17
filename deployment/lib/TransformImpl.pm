package TransformImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

Transform

=head1 DESCRIPTION

Transform Service

This KBase service supports translations and transformations of data types,
including converting external file formats to KBase objects, 
converting KBase objects to external file formats, and converting KBase objects
to other KBase objects, either objects of different types or objects of the same
type but different versions.

=cut

#BEGIN_HEADER
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 version

  $result = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$result is a string

</pre>

=end html

=begin text

$result is a string


=end text



=item Description

Returns the service version string.

=back

=cut

sub version
{
    my $self = shift;

    my $ctx = $TransformServer::CallContext;
    my($result);
    #BEGIN version
    #END version
    my @_bad_returns;
    (!ref($result)) or push(@_bad_returns, "Invalid type for return variable \"result\" (value was \"$result\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to version:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'version');
    }
    return($result);
}




=head2 methods

  $results = $obj->methods($query)

=over 4

=item Parameter and return types

=begin html

<pre>
$query is a string
$results is a reference to a list where each element is a string

</pre>

=end html

=begin text

$query is a string
$results is a reference to a list where each element is a string


=end text



=item Description

Returns all available service methods, and info about them.

=back

=cut

sub methods
{
    my $self = shift;
    my($query) = @_;

    my @_bad_arguments;
    (!ref($query)) or push(@_bad_arguments, "Invalid type for argument \"query\" (value was \"$query\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to methods:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'methods');
    }

    my $ctx = $TransformServer::CallContext;
    my($results);
    #BEGIN methods
    #END methods
    my @_bad_returns;
    (ref($results) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to methods:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'methods');
    }
    return($results);
}




=head2 upload

  $result = $obj->upload($args)

=over 4

=item Parameter and return types

=begin html

<pre>
$args is an UploadParameters
$result is a reference to a list where each element is a string
UploadParameters is a reference to a hash where the following keys are defined:
	external_type has a value which is a string
	kbase_type has a value which is a type_string
	url_mapping has a value which is a reference to a hash where the key is a string and the value is a string
	workspace_name has a value which is a string
	object_name has a value which is a string
	object_id has a value which is a string
	options has a value which is a string
type_string is a string

</pre>

=end html

=begin text

$args is an UploadParameters
$result is a reference to a list where each element is a string
UploadParameters is a reference to a hash where the following keys are defined:
	external_type has a value which is a string
	kbase_type has a value which is a type_string
	url_mapping has a value which is a reference to a hash where the key is a string and the value is a string
	workspace_name has a value which is a string
	object_name has a value which is a string
	object_id has a value which is a string
	options has a value which is a string
type_string is a string


=end text



=item Description



=back

=cut

sub upload
{
    my $self = shift;
    my($args) = @_;

    my @_bad_arguments;
    (ref($args) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"args\" (value was \"$args\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to upload:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'upload');
    }

    my $ctx = $TransformServer::CallContext;
    my($result);
    #BEGIN upload
    #END upload
    my @_bad_returns;
    (ref($result) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"result\" (value was \"$result\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to upload:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'upload');
    }
    return($result);
}




=head2 download

  $result = $obj->download($args)

=over 4

=item Parameter and return types

=begin html

<pre>
$args is a DownloadParameters
$result is a reference to a list where each element is a string
DownloadParameters is a reference to a hash where the following keys are defined:
	kbase_type has a value which is a type_string
	external_type has a value which is a string
	workspace_name has a value which is a string
	object_name has a value which is a string
	object_id has a value which is a string
	options has a value which is a string
type_string is a string

</pre>

=end html

=begin text

$args is a DownloadParameters
$result is a reference to a list where each element is a string
DownloadParameters is a reference to a hash where the following keys are defined:
	kbase_type has a value which is a type_string
	external_type has a value which is a string
	workspace_name has a value which is a string
	object_name has a value which is a string
	object_id has a value which is a string
	options has a value which is a string
type_string is a string


=end text



=item Description



=back

=cut

sub download
{
    my $self = shift;
    my($args) = @_;

    my @_bad_arguments;
    (ref($args) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"args\" (value was \"$args\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to download:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'download');
    }

    my $ctx = $TransformServer::CallContext;
    my($result);
    #BEGIN download
    #END download
    my @_bad_returns;
    (ref($result) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"result\" (value was \"$result\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to download:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'download');
    }
    return($result);
}




=head2 convert

  $result = $obj->convert($args)

=over 4

=item Parameter and return types

=begin html

<pre>
$args is a ConvertParameters
$result is a reference to a list where each element is a string
ConvertParameters is a reference to a hash where the following keys are defined:
	source_kbase_type has a value which is a type_string
	source_workspace_name has a value which is a string
	source_object_name has a value which is a string
	source_object_id has a value which is a string
	destination_kbase_type has a value which is a type_string
	destination_workspace_name has a value which is a string
	destination_object_name has a value which is a string
	destination_object_id has a value which is a string
	options has a value which is a string
type_string is a string

</pre>

=end html

=begin text

$args is a ConvertParameters
$result is a reference to a list where each element is a string
ConvertParameters is a reference to a hash where the following keys are defined:
	source_kbase_type has a value which is a type_string
	source_workspace_name has a value which is a string
	source_object_name has a value which is a string
	source_object_id has a value which is a string
	destination_kbase_type has a value which is a type_string
	destination_workspace_name has a value which is a string
	destination_object_name has a value which is a string
	destination_object_id has a value which is a string
	options has a value which is a string
type_string is a string


=end text



=item Description



=back

=cut

sub convert
{
    my $self = shift;
    my($args) = @_;

    my @_bad_arguments;
    (ref($args) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"args\" (value was \"$args\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to convert:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'convert');
    }

    my $ctx = $TransformServer::CallContext;
    my($result);
    #BEGIN convert
    #END convert
    my @_bad_returns;
    (ref($result) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"result\" (value was \"$result\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to convert:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'convert');
    }
    return($result);
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



=head2 type_string

=over 4



=item Description

A type string copied from WS spec.
Specifies the type and its version in a single string in the format
[module].[typename]-[major].[minor]:

module - a string. The module name of the typespec containing the type.
typename - a string. The name of the type as assigned by the typedef
        statement. For external type, it start with “e_”.
major - an integer. The major version of the type. A change in the
        major version implies the type has changed in a non-backwards
        compatible way.
minor - an integer. The minor version of the type. A change in the
        minor version implies that the type has changed in a way that is
        backwards compatible with previous type definitions.

In many cases, the major and minor versions are optional, and if not
provided the most recent version will be used.

Example: MyModule.MyType-3.1


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 UploadParameters

=over 4



=item Description

json string


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
external_type has a value which is a string
kbase_type has a value which is a type_string
url_mapping has a value which is a reference to a hash where the key is a string and the value is a string
workspace_name has a value which is a string
object_name has a value which is a string
object_id has a value which is a string
options has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
external_type has a value which is a string
kbase_type has a value which is a type_string
url_mapping has a value which is a reference to a hash where the key is a string and the value is a string
workspace_name has a value which is a string
object_name has a value which is a string
object_id has a value which is a string
options has a value which is a string


=end text

=back



=head2 DownloadParameters

=over 4



=item Description

json string


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
kbase_type has a value which is a type_string
external_type has a value which is a string
workspace_name has a value which is a string
object_name has a value which is a string
object_id has a value which is a string
options has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
kbase_type has a value which is a type_string
external_type has a value which is a string
workspace_name has a value which is a string
object_name has a value which is a string
object_id has a value which is a string
options has a value which is a string


=end text

=back



=head2 ConvertParameters

=over 4



=item Description

json string


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
source_kbase_type has a value which is a type_string
source_workspace_name has a value which is a string
source_object_name has a value which is a string
source_object_id has a value which is a string
destination_kbase_type has a value which is a type_string
destination_workspace_name has a value which is a string
destination_object_name has a value which is a string
destination_object_id has a value which is a string
options has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
source_kbase_type has a value which is a type_string
source_workspace_name has a value which is a string
source_object_name has a value which is a string
source_object_id has a value which is a string
destination_kbase_type has a value which is a type_string
destination_workspace_name has a value which is a string
destination_object_name has a value which is a string
destination_object_id has a value which is a string
options has a value which is a string


=end text

=back



=cut

1;
