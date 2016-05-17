package Bio::KBase::IdMap::Client;

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

Bio::KBase::IdMap::Client

=head1 DESCRIPTION


The IdMap service client provides various lookups. These
lookups are designed to provide mappings of external
identifiers to kbase identifiers. 

Not all lookups are easily represented as one-to-one
mappings.


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => Bio::KBase::IdMap::Client::RpcClient->new,
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




=head2 lookup_genome

  $id_pairs = $obj->lookup_genome($s, $type)

=over 4

=item Parameter and return types

=begin html

<pre>
$s is a string
$type is a string
$id_pairs is a reference to a list where each element is an IdPair
IdPair is a reference to a hash where the following keys are defined:
	source_db has a value which is a string
	alias has a value which is a string
	kbase_id has a value which is a string

</pre>

=end html

=begin text

$s is a string
$type is a string
$id_pairs is a reference to a list where each element is an IdPair
IdPair is a reference to a hash where the following keys are defined:
	source_db has a value which is a string
	alias has a value which is a string
	kbase_id has a value which is a string


=end text

=item Description

Makes an attempt to map external identifier of a genome to
the corresponding kbase identifier. Multiple candidates can
be found, thus a list of IdPairs is returned.

string s - a string that represents some sort of genome
identifier. The type of identifier is resolved with the
type parameter.

string type - this provides information about the tupe
of alias that is provided as the first parameter.

An example of the parameters is the first parameter could
be a string "Burkholderia" and the type could be
scientific_name.

A second example is the first parmater could be an integer
and the type could be ncbi_taxonid.

These are the two supported cases at this time. Valid types
are NAME and NCBI_TAXID

=back

=cut

sub lookup_genome
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function lookup_genome (received $n, expecting 2)");
    }
    {
	my($s, $type) = @args;

	my @_bad_arguments;
        (!ref($s)) or push(@_bad_arguments, "Invalid type for argument 1 \"s\" (value was \"$s\")");
        (!ref($type)) or push(@_bad_arguments, "Invalid type for argument 2 \"type\" (value was \"$type\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to lookup_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'lookup_genome');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "IdMap.lookup_genome",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'lookup_genome',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method lookup_genome",
					    status_line => $self->{client}->status_line,
					    method_name => 'lookup_genome',
				       );
    }
}



=head2 lookup_features

  $return = $obj->lookup_features($genome_id, $aliases, $feature_type, $source_db)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_id is a string
$aliases is a reference to a list where each element is a string
$feature_type is a string
$source_db is a string
$return is a reference to a hash where the key is a string and the value is a reference to a list where each element is an IdPair
IdPair is a reference to a hash where the following keys are defined:
	source_db has a value which is a string
	alias has a value which is a string
	kbase_id has a value which is a string

</pre>

=end html

=begin text

$genome_id is a string
$aliases is a reference to a list where each element is a string
$feature_type is a string
$source_db is a string
$return is a reference to a hash where the key is a string and the value is a reference to a list where each element is an IdPair
IdPair is a reference to a hash where the following keys are defined:
	source_db has a value which is a string
	alias has a value which is a string
	kbase_id has a value which is a string


=end text

=item Description

Given a genome id, a list of aliases, a feature type and a source db
return the set of feature ids associated with the aliases.

lookup_features attempts to find feature ids for the aliases provided.
The match is somewhat ambiguous  in that if an alias is provided
that is associated with a feature of type locus, then the
mrna and cds features encompassed in that locus will also be
returned. Therefor it is possible to have multiple feature ids
associated with one alias.

Parameters for the lookup_features function are:
string genome_id     - a kbase genome identifier
list<string> aliases - a list of aliases
string feature_type  - a kbase feature type
string source_db     - a kbase source identifier

To specify all feature types, provide an empty string as the
value of the feature_type parameter. To specify all source databases,
provide an empty string as the value of the source_db parameter.

  The lookup_features function returns a mapping between
  an alias and an IdPair.

=back

=cut

sub lookup_features
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 4)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function lookup_features (received $n, expecting 4)");
    }
    {
	my($genome_id, $aliases, $feature_type, $source_db) = @args;

	my @_bad_arguments;
        (!ref($genome_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"genome_id\" (value was \"$genome_id\")");
        (ref($aliases) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"aliases\" (value was \"$aliases\")");
        (!ref($feature_type)) or push(@_bad_arguments, "Invalid type for argument 3 \"feature_type\" (value was \"$feature_type\")");
        (!ref($source_db)) or push(@_bad_arguments, "Invalid type for argument 4 \"source_db\" (value was \"$source_db\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to lookup_features:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'lookup_features');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "IdMap.lookup_features",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'lookup_features',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method lookup_features",
					    status_line => $self->{client}->status_line,
					    method_name => 'lookup_features',
				       );
    }
}



=head2 lookup_feature_synonyms

  $return = $obj->lookup_feature_synonyms($genome_id, $feature_type)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_id is a string
$feature_type is a string
$return is a reference to a list where each element is an IdPair
IdPair is a reference to a hash where the following keys are defined:
	source_db has a value which is a string
	alias has a value which is a string
	kbase_id has a value which is a string

</pre>

=end html

=begin text

$genome_id is a string
$feature_type is a string
$return is a reference to a list where each element is an IdPair
IdPair is a reference to a hash where the following keys are defined:
	source_db has a value which is a string
	alias has a value which is a string
	kbase_id has a value which is a string


=end text

=item Description

Returns a list of mappings of all possible types of feature
synonyms and external ids to feature kbase ids for a
particular kbase genome, and a given type of a feature.

string genome_id - kbase id of a target genome
string feature_type - type of a kbase feature, e.g. CDS,
pep, etc (see https://trac.kbase.us/projects/kbase/wiki/IDRegistry).
If not provided, all mappings should be returned.

=back

=cut

sub lookup_feature_synonyms
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function lookup_feature_synonyms (received $n, expecting 2)");
    }
    {
	my($genome_id, $feature_type) = @args;

	my @_bad_arguments;
        (!ref($genome_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"genome_id\" (value was \"$genome_id\")");
        (!ref($feature_type)) or push(@_bad_arguments, "Invalid type for argument 2 \"feature_type\" (value was \"$feature_type\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to lookup_feature_synonyms:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'lookup_feature_synonyms');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "IdMap.lookup_feature_synonyms",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'lookup_feature_synonyms',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method lookup_feature_synonyms",
					    status_line => $self->{client}->status_line,
					    method_name => 'lookup_feature_synonyms',
				       );
    }
}



=head2 longest_cds_from_locus

  $return = $obj->longest_cds_from_locus($arg_1)

=over 4

=item Parameter and return types

=begin html

<pre>
$arg_1 is a reference to a list where each element is a string
$return is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$arg_1 is a reference to a list where each element is a string
$return is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

Returns a mapping of locus feature id to cds feature id.

=back

=cut

sub longest_cds_from_locus
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function longest_cds_from_locus (received $n, expecting 1)");
    }
    {
	my($arg_1) = @args;

	my @_bad_arguments;
        (ref($arg_1) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"arg_1\" (value was \"$arg_1\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to longest_cds_from_locus:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'longest_cds_from_locus');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "IdMap.longest_cds_from_locus",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'longest_cds_from_locus',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method longest_cds_from_locus",
					    status_line => $self->{client}->status_line,
					    method_name => 'longest_cds_from_locus',
				       );
    }
}



=head2 longest_cds_from_mrna

  $return = $obj->longest_cds_from_mrna($arg_1)

=over 4

=item Parameter and return types

=begin html

<pre>
$arg_1 is a reference to a list where each element is a string
$return is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$arg_1 is a reference to a list where each element is a string
$return is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

Returns a mapping a mrna feature id to a cds feature id.

=back

=cut

sub longest_cds_from_mrna
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function longest_cds_from_mrna (received $n, expecting 1)");
    }
    {
	my($arg_1) = @args;

	my @_bad_arguments;
        (ref($arg_1) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"arg_1\" (value was \"$arg_1\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to longest_cds_from_mrna:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'longest_cds_from_mrna');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "IdMap.longest_cds_from_mrna",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'longest_cds_from_mrna',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method longest_cds_from_mrna",
					    status_line => $self->{client}->status_line,
					    method_name => 'longest_cds_from_mrna',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "IdMap.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'longest_cds_from_mrna',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method longest_cds_from_mrna",
            status_line => $self->{client}->status_line,
            method_name => 'longest_cds_from_mrna',
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
        warn "New client version available for Bio::KBase::IdMap::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::IdMap::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 IdPair

=over 4



=item Description

A mapping of aliases to the corresponding kbase identifier.

string source_db  - the kbase id of the source
string alias      - the identifier to be mapped to a feature id
string kbase_id - the kbase id of the feature


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
source_db has a value which is a string
alias has a value which is a string
kbase_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
source_db has a value which is a string
alias has a value which is a string
kbase_id has a value which is a string


=end text

=back



=cut

package Bio::KBase::IdMap::Client::RpcClient;
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
