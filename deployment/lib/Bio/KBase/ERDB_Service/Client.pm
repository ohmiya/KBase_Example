package Bio::KBase::ERDB_Service::Client;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};


# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::ERDB_Service::Client

=head1 DESCRIPTION


ERDB Service API specification

This service wraps the ERDB software and allows querying the CDS via the ERDB
using typecompiler generated clients rather than direct Perl imports of the ERDB
code.

The exposed functions behave, generally, identically to the ERDB functions documented
L<here|http://pubseed.theseed.org/sapling/server.cgi?pod=ERDB#Query_Methods>.
It is expected that users of this service already understand how to query the CDS via
the ERDB.


=cut

sub new
{
    my($class, $url, @args) = @_;
    
    if (!defined($url))
    {
	$url = 'http://kbase.us/services/erdb_service';
    }

    my $self = {
	client => Bio::KBase::ERDB_Service::Client::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }


    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 GetAll

  $return = $obj->GetAll($objectNames, $filterClause, $parameters, $fields, $count)

=over 4

=item Parameter and return types

=begin html

<pre>
$objectNames is an objectNames
$filterClause is a filterClause
$parameters is a parameters
$fields is a fields
$count is a count
$return is a rowlist
objectNames is a string
filterClause is a string
parameters is a reference to a list where each element is a parameter
parameter is a string
fields is a string
count is an int
rowlist is a reference to a list where each element is a fieldValues
fieldValues is a reference to a list where each element is a fieldValue
fieldValue is a string

</pre>

=end html

=begin text

$objectNames is an objectNames
$filterClause is a filterClause
$parameters is a parameters
$fields is a fields
$count is a count
$return is a rowlist
objectNames is a string
filterClause is a string
parameters is a reference to a list where each element is a parameter
parameter is a string
fields is a string
count is an int
rowlist is a reference to a list where each element is a fieldValues
fieldValues is a reference to a list where each element is a fieldValue
fieldValue is a string


=end text

=item Description

Wrapper for the GetAll function documented L<here|http://pubseed.theseed.org/sapling/server.cgi?pod=ERDB#GetAll>.
Note that the objectNames and fields arguments must be strings; array references are not allowed.

=back

=cut

sub GetAll
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 5)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function GetAll (received $n, expecting 5)");
    }
    {
	my($objectNames, $filterClause, $parameters, $fields, $count) = @args;

	my @_bad_arguments;
        (!ref($objectNames)) or push(@_bad_arguments, "Invalid type for argument 1 \"objectNames\" (value was \"$objectNames\")");
        (!ref($filterClause)) or push(@_bad_arguments, "Invalid type for argument 2 \"filterClause\" (value was \"$filterClause\")");
        (ref($parameters) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 3 \"parameters\" (value was \"$parameters\")");
        (!ref($fields)) or push(@_bad_arguments, "Invalid type for argument 4 \"fields\" (value was \"$fields\")");
        (!ref($count)) or push(@_bad_arguments, "Invalid type for argument 5 \"count\" (value was \"$count\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to GetAll:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'GetAll');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ERDB_Service.GetAll",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'GetAll',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method GetAll",
					    status_line => $self->{client}->status_line,
					    method_name => 'GetAll',
				       );
    }
}



=head2 runSQL

  $return = $obj->runSQL($SQLstring, $parameters)

=over 4

=item Parameter and return types

=begin html

<pre>
$SQLstring is an SQLstring
$parameters is a parameters
$return is a rowlist
SQLstring is a string
parameters is a reference to a list where each element is a parameter
parameter is a string
rowlist is a reference to a list where each element is a fieldValues
fieldValues is a reference to a list where each element is a fieldValue
fieldValue is a string

</pre>

=end html

=begin text

$SQLstring is an SQLstring
$parameters is a parameters
$return is a rowlist
SQLstring is a string
parameters is a reference to a list where each element is a parameter
parameter is a string
rowlist is a reference to a list where each element is a fieldValues
fieldValues is a reference to a list where each element is a fieldValue
fieldValue is a string


=end text

=item Description

WARNING: this is a function of last resort. Try to do what you need to do with the CDMI client or the
GetAll function first.
Runs a standard SQL query via the ERDB DB hook. Be sure not to code inputs into the SQL string - put them
in the parameter list and use ? placeholders in the SQL. Otherwise you risk SQL injection. If you don't
understand this paragraph, do not use this function.
Note that most likely, the account for this server only has select privileges and cannot modify the
database.

=back

=cut

sub runSQL
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function runSQL (received $n, expecting 2)");
    }
    {
	my($SQLstring, $parameters) = @args;

	my @_bad_arguments;
        (!ref($SQLstring)) or push(@_bad_arguments, "Invalid type for argument 1 \"SQLstring\" (value was \"$SQLstring\")");
        (ref($parameters) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"parameters\" (value was \"$parameters\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to runSQL:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'runSQL');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ERDB_Service.runSQL",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'runSQL',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method runSQL",
					    status_line => $self->{client}->status_line,
					    method_name => 'runSQL',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "ERDB_Service.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'runSQL',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method runSQL",
            status_line => $self->{client}->status_line,
            method_name => 'runSQL',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::KBase::ERDB_Service::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::ERDB_Service::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 objectNames

=over 4



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



=head2 filterClause

=over 4



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



=head2 parameter

=over 4



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



=head2 parameters

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a parameter
</pre>

=end html

=begin text

a reference to a list where each element is a parameter

=end text

=back



=head2 fields

=over 4



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



=head2 count

=over 4



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



=head2 fieldValue

=over 4



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



=head2 fieldValues

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a fieldValue
</pre>

=end html

=begin text

a reference to a list where each element is a fieldValue

=end text

=back



=head2 rowlist

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a fieldValues
</pre>

=end html

=begin text

a reference to a list where each element is a fieldValues

=end text

=back



=head2 SQLstring

=over 4



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



=cut

package Bio::KBase::ERDB_Service::Client::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
