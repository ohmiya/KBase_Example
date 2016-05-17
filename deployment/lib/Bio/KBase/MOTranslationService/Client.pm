package Bio::KBase::MOTranslationService::Client;

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

Bio::KBase::MOTranslationService::Client

=head1 DESCRIPTION


This module will translate KBase ids to MicrobesOnline ids and
vice-versa. For features, it will initially use MD5s to perform
the translation.

The MOTranslation module will ultimately be deprecated, once all
MicrobesOnline data types are natively stored in KBase. In general
the module and methods should not be publicized, and are mainly intended
to be used internally by other KBase services (specifically the protein
info service).


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => Bio::KBase::MOTranslationService::Client::RpcClient->new,
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




=head2 fids_to_moLocusIds

  $return = $obj->fids_to_moLocusIds($fids)

=over 4

=item Parameter and return types

=begin html

<pre>
$fids is a reference to a list where each element is a fid
$return is a reference to a hash where the key is a fid and the value is a reference to a list where each element is a moLocusId
fid is a string
moLocusId is an int

</pre>

=end html

=begin text

$fids is a reference to a list where each element is a fid
$return is a reference to a hash where the key is a fid and the value is a reference to a list where each element is a moLocusId
fid is a string
moLocusId is an int


=end text

=item Description

fids_to_moLocusIds translates a list of fids into MicrobesOnline
locusIds. It uses proteins_to_moLocusIds internally.

=back

=cut

sub fids_to_moLocusIds
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function fids_to_moLocusIds (received $n, expecting 1)");
    }
    {
	my($fids) = @args;

	my @_bad_arguments;
        (ref($fids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"fids\" (value was \"$fids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to fids_to_moLocusIds:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'fids_to_moLocusIds');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "MOTranslation.fids_to_moLocusIds",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'fids_to_moLocusIds',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method fids_to_moLocusIds",
					    status_line => $self->{client}->status_line,
					    method_name => 'fids_to_moLocusIds',
				       );
    }
}



=head2 proteins_to_moLocusIds

  $return = $obj->proteins_to_moLocusIds($proteins)

=over 4

=item Parameter and return types

=begin html

<pre>
$proteins is a reference to a list where each element is a protein
$return is a reference to a hash where the key is a protein and the value is a reference to a list where each element is a moLocusId
protein is a string
moLocusId is an int

</pre>

=end html

=begin text

$proteins is a reference to a list where each element is a protein
$return is a reference to a hash where the key is a protein and the value is a reference to a list where each element is a moLocusId
protein is a string
moLocusId is an int


=end text

=item Description

proteins_to_moLocusIds translates a list of proteins (MD5s) into
MicrobesOnline locusIds.

=back

=cut

sub proteins_to_moLocusIds
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function proteins_to_moLocusIds (received $n, expecting 1)");
    }
    {
	my($proteins) = @args;

	my @_bad_arguments;
        (ref($proteins) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"proteins\" (value was \"$proteins\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to proteins_to_moLocusIds:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'proteins_to_moLocusIds');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "MOTranslation.proteins_to_moLocusIds",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'proteins_to_moLocusIds',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method proteins_to_moLocusIds",
					    status_line => $self->{client}->status_line,
					    method_name => 'proteins_to_moLocusIds',
				       );
    }
}



=head2 moLocusIds_to_fids

  $return = $obj->moLocusIds_to_fids($moLocusIds)

=over 4

=item Parameter and return types

=begin html

<pre>
$moLocusIds is a reference to a list where each element is a moLocusId
$return is a reference to a hash where the key is a moLocusId and the value is a reference to a list where each element is a fid
moLocusId is an int
fid is a string

</pre>

=end html

=begin text

$moLocusIds is a reference to a list where each element is a moLocusId
$return is a reference to a hash where the key is a moLocusId and the value is a reference to a list where each element is a fid
moLocusId is an int
fid is a string


=end text

=item Description

moLocusIds_to_fids translates a list of MicrobesOnline locusIds
into KBase fids. It uses moLocusIds_to_proteins internally.

=back

=cut

sub moLocusIds_to_fids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function moLocusIds_to_fids (received $n, expecting 1)");
    }
    {
	my($moLocusIds) = @args;

	my @_bad_arguments;
        (ref($moLocusIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"moLocusIds\" (value was \"$moLocusIds\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to moLocusIds_to_fids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'moLocusIds_to_fids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "MOTranslation.moLocusIds_to_fids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'moLocusIds_to_fids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method moLocusIds_to_fids",
					    status_line => $self->{client}->status_line,
					    method_name => 'moLocusIds_to_fids',
				       );
    }
}



=head2 moLocusIds_to_proteins

  $return = $obj->moLocusIds_to_proteins($moLocusIds)

=over 4

=item Parameter and return types

=begin html

<pre>
$moLocusIds is a reference to a list where each element is a moLocusId
$return is a reference to a hash where the key is a moLocusId and the value is a protein
moLocusId is an int
protein is a string

</pre>

=end html

=begin text

$moLocusIds is a reference to a list where each element is a moLocusId
$return is a reference to a hash where the key is a moLocusId and the value is a protein
moLocusId is an int
protein is a string


=end text

=item Description

moLocusIds_to_proteins translates a list of MicrobesOnline locusIds
into proteins (MD5s).

=back

=cut

sub moLocusIds_to_proteins
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function moLocusIds_to_proteins (received $n, expecting 1)");
    }
    {
	my($moLocusIds) = @args;

	my @_bad_arguments;
        (ref($moLocusIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"moLocusIds\" (value was \"$moLocusIds\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to moLocusIds_to_proteins:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'moLocusIds_to_proteins');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "MOTranslation.moLocusIds_to_proteins",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'moLocusIds_to_proteins',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method moLocusIds_to_proteins",
					    status_line => $self->{client}->status_line,
					    method_name => 'moLocusIds_to_proteins',
				       );
    }
}



=head2 map_to_fid

  $return_1, $log = $obj->map_to_fid($query_sequences, $genomeId)

=over 4

=item Parameter and return types

=begin html

<pre>
$query_sequences is a reference to a list where each element is a query_sequence
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a protein_id and the value is a result
$log is a status
query_sequence is a reference to a hash where the following keys are defined:
	id has a value which is a protein_id
	seq has a value which is a protein_sequence
	start has a value which is a position
	stop has a value which is a position
protein_id is a string
protein_sequence is a string
position is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string

</pre>

=end html

=begin text

$query_sequences is a reference to a list where each element is a query_sequence
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a protein_id and the value is a result
$log is a status
query_sequence is a reference to a hash where the following keys are defined:
	id has a value which is a protein_id
	seq has a value which is a protein_sequence
	start has a value which is a position
	stop has a value which is a position
protein_id is a string
protein_sequence is a string
position is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string


=end text

=item Description

A general method to lookup the best matching feature id in a specific genome for a given protein sequence.

NOTE: currently the intended use of this method is to map identical genomes with different gene calls, although it still
can work for fairly similar genomes.  But be warned!!  It may produce incorrect results for genomes that differ!

This method operates by first checking the MD5 and position of each sequence and determining if there is an exact match,
(or an exact MD5 match +- 30bp).  If none are found, then a simple blast search is performed.  Currently the blast search
is completely overkill as it is used simply to look for 50% overlap of genes. Blast was chosen, however, because it is
anticipated that this, or a very similar implementation of this method, will be used more generally for mapping features
on roughly similar genomes.  Keep very much in mind that this method is not designed to be a general homology search, which
should be done with more advanced methods.  Rather, this method is designed more for bookkeeping purposes when data based on
one genome with a set of gene calls needs to be applied to a genome with a second set of gene calls.

see also the cooresponds method of the CDMI.

=back

=cut

sub map_to_fid
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function map_to_fid (received $n, expecting 2)");
    }
    {
	my($query_sequences, $genomeId) = @args;

	my @_bad_arguments;
        (ref($query_sequences) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"query_sequences\" (value was \"$query_sequences\")");
        (!ref($genomeId)) or push(@_bad_arguments, "Invalid type for argument 2 \"genomeId\" (value was \"$genomeId\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to map_to_fid:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'map_to_fid');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "MOTranslation.map_to_fid",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'map_to_fid',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method map_to_fid",
					    status_line => $self->{client}->status_line,
					    method_name => 'map_to_fid',
				       );
    }
}



=head2 map_to_fid_fast

  $return_1, $log = $obj->map_to_fid_fast($query_md5s, $genomeId)

=over 4

=item Parameter and return types

=begin html

<pre>
$query_md5s is a reference to a list where each element is a query_md5
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a protein_id and the value is a result
$log is a status
query_md5 is a reference to a hash where the following keys are defined:
	id has a value which is a protein_id
	md5 has a value which is a protein
	start has a value which is a position
	stop has a value which is a position
protein_id is a string
protein is a string
position is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string

</pre>

=end html

=begin text

$query_md5s is a reference to a list where each element is a query_md5
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a protein_id and the value is a result
$log is a status
query_md5 is a reference to a hash where the following keys are defined:
	id has a value which is a protein_id
	md5 has a value which is a protein
	start has a value which is a position
	stop has a value which is a position
protein_id is a string
protein is a string
position is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string


=end text

=item Description

Performs the same function as map_to_fid, except it does not require protein sequences to be defined. Instead, it assumes
genomes are identical and simply looks for genes on the same strand that overlap by at least 50%. Since no sequences are
compared, this method is fast.  But, since no sequences are compared, this method only makes sense for identical genomes

=back

=cut

sub map_to_fid_fast
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function map_to_fid_fast (received $n, expecting 2)");
    }
    {
	my($query_md5s, $genomeId) = @args;

	my @_bad_arguments;
        (ref($query_md5s) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"query_md5s\" (value was \"$query_md5s\")");
        (!ref($genomeId)) or push(@_bad_arguments, "Invalid type for argument 2 \"genomeId\" (value was \"$genomeId\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to map_to_fid_fast:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'map_to_fid_fast');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "MOTranslation.map_to_fid_fast",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'map_to_fid_fast',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method map_to_fid_fast",
					    status_line => $self->{client}->status_line,
					    method_name => 'map_to_fid_fast',
				       );
    }
}



=head2 moLocusIds_to_fid_in_genome

  $return_1, $log = $obj->moLocusIds_to_fid_in_genome($moLocusIds, $genomeId)

=over 4

=item Parameter and return types

=begin html

<pre>
$moLocusIds is a reference to a list where each element is a moLocusId
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a moLocusId and the value is a result
$log is a status
moLocusId is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string

</pre>

=end html

=begin text

$moLocusIds is a reference to a list where each element is a moLocusId
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a moLocusId and the value is a result
$log is a status
moLocusId is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string


=end text

=item Description

A method designed to map MicrobesOnline locus ids to the features of a specific target genome in kbase.  Under the hood, this
method simply fetches MicrobesOnline data and calls the 'map_to_fid' method defined in this service.  Therefore, all the caveats
and disclaimers of the 'map_to_fid' method apply to this function as well, so be sure to read the documenation for the 'map_to_fid'
method as well!

=back

=cut

sub moLocusIds_to_fid_in_genome
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function moLocusIds_to_fid_in_genome (received $n, expecting 2)");
    }
    {
	my($moLocusIds, $genomeId) = @args;

	my @_bad_arguments;
        (ref($moLocusIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"moLocusIds\" (value was \"$moLocusIds\")");
        (!ref($genomeId)) or push(@_bad_arguments, "Invalid type for argument 2 \"genomeId\" (value was \"$genomeId\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to moLocusIds_to_fid_in_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'moLocusIds_to_fid_in_genome');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "MOTranslation.moLocusIds_to_fid_in_genome",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'moLocusIds_to_fid_in_genome',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method moLocusIds_to_fid_in_genome",
					    status_line => $self->{client}->status_line,
					    method_name => 'moLocusIds_to_fid_in_genome',
				       );
    }
}



=head2 moLocusIds_to_fid_in_genome_fast

  $return_1, $log = $obj->moLocusIds_to_fid_in_genome_fast($moLocusIds, $genomeId)

=over 4

=item Parameter and return types

=begin html

<pre>
$moLocusIds is a reference to a list where each element is a moLocusId
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a moLocusId and the value is a result
$log is a status
moLocusId is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string

</pre>

=end html

=begin text

$moLocusIds is a reference to a list where each element is a moLocusId
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a moLocusId and the value is a result
$log is a status
moLocusId is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string


=end text

=item Description

Performs the same function as moLocusIds_to_fid_in_genome, but does not retrieve protein sequences for the locus Ids - it simply
uses md5 information and start/stop positions to identify matches.  It is therefore faster, but will not work if genomes are not
identical.

=back

=cut

sub moLocusIds_to_fid_in_genome_fast
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function moLocusIds_to_fid_in_genome_fast (received $n, expecting 2)");
    }
    {
	my($moLocusIds, $genomeId) = @args;

	my @_bad_arguments;
        (ref($moLocusIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"moLocusIds\" (value was \"$moLocusIds\")");
        (!ref($genomeId)) or push(@_bad_arguments, "Invalid type for argument 2 \"genomeId\" (value was \"$genomeId\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to moLocusIds_to_fid_in_genome_fast:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'moLocusIds_to_fid_in_genome_fast');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "MOTranslation.moLocusIds_to_fid_in_genome_fast",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'moLocusIds_to_fid_in_genome_fast',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method moLocusIds_to_fid_in_genome_fast",
					    status_line => $self->{client}->status_line,
					    method_name => 'moLocusIds_to_fid_in_genome_fast',
				       );
    }
}



=head2 moTaxonomyId_to_genomes

  $return = $obj->moTaxonomyId_to_genomes($moTaxonomyId)

=over 4

=item Parameter and return types

=begin html

<pre>
$moTaxonomyId is a moTaxonomyId
$return is a reference to a list where each element is a genomeId
moTaxonomyId is an int
genomeId is a kbaseId
kbaseId is a string

</pre>

=end html

=begin text

$moTaxonomyId is a moTaxonomyId
$return is a reference to a list where each element is a genomeId
moTaxonomyId is an int
genomeId is a kbaseId
kbaseId is a string


=end text

=item Description

A method to map a MicrobesOnline genome (identified by taxonomy Id) to the set of identical kbase genomes based on an MD5 checksum
of the contig sequences.  If you already know your MD5 value for your genome (computed in the KBase way), then you should avoid this
method and directly query the CDS using the CDMI API, which includes a method 'md5s_to_genomes'.

=back

=cut

sub moTaxonomyId_to_genomes
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function moTaxonomyId_to_genomes (received $n, expecting 1)");
    }
    {
	my($moTaxonomyId) = @args;

	my @_bad_arguments;
        (!ref($moTaxonomyId)) or push(@_bad_arguments, "Invalid type for argument 1 \"moTaxonomyId\" (value was \"$moTaxonomyId\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to moTaxonomyId_to_genomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'moTaxonomyId_to_genomes');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "MOTranslation.moTaxonomyId_to_genomes",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'moTaxonomyId_to_genomes',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method moTaxonomyId_to_genomes",
					    status_line => $self->{client}->status_line,
					    method_name => 'moTaxonomyId_to_genomes',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "MOTranslation.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'moTaxonomyId_to_genomes',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method moTaxonomyId_to_genomes",
            status_line => $self->{client}->status_line,
            method_name => 'moTaxonomyId_to_genomes',
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
        warn "New client version available for Bio::KBase::MOTranslationService::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::MOTranslationService::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 protein

=over 4



=item Description

protein is an MD5 in KBase. It is the primary lookup between
KBase fids and MicrobesOnline locusIds.


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



=head2 kbaseId

=over 4



=item Description

kbaseId can represent any object with a KBase identifier. 
In the future this may be used to translate between other data
types, such as contig or genome.


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



=head2 genomeId

=over 4



=item Description

genomeId is a kbase id of a genome


=item Definition

=begin html

<pre>
a kbaseId
</pre>

=end html

=begin text

a kbaseId

=end text

=back



=head2 fid

=over 4



=item Description

fid is a feature id in KBase.


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



=head2 moLocusId

=over 4



=item Description

moLocusId is a locusId in MicrobesOnline. It is analogous to a fid
in KBase.


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



=head2 moScaffoldId

=over 4



=item Description

moScaffoldId is a scaffoldId in MicrobesOnline.  It is analogous to
a contig kbId in KBase.


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



=head2 moTaxonomyId

=over 4



=item Description

moTaxonomyId is a taxonomyId in MicrobesOnline.  It is somewhat analogous
to a genome kbId in KBase.  It generally stores the NCBI taxonomy ID,
though sometimes can store an internal identifier instead.


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



=head2 protein_sequence

=over 4



=item Description

AA sequence of a protein


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



=head2 protein_id

=over 4



=item Description

internally consistant and unique id of a protein (could just be integers 0..n), necessary
for returning results


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



=head2 position

=over 4



=item Description

Used to indicate a single nucleotide/residue location in a sequence


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



=head2 status

=over 4



=item Description

A short note used to convey the status or explanaton of a result, or in some cases a log of the
method that was run


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



=head2 query_sequence

=over 4



=item Description

A structure for specifying the input sequence queries for the map_to_fid method.  This structure, for
now, assumes you will be making queries with identical genomes, so it requires the start and stop.  In the
future, if this assumption is relaxed, then start and stop will be optional parameters.  We should probably
also add an MD5 string which can optionally be provided so that we don't have to compute it on the fly.

        protein_id id         - arbitrary ID that must be unique within the set of query sequences
        protein_sequence seq  - the one letter code AA sequence of the protein
        position start        - the start position of the start codon in the genome contig (may be a larger
                                number than stop if the gene is on the reverse strand)
        position stop         - the last position of he stop codon in the genome contig


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a protein_id
seq has a value which is a protein_sequence
start has a value which is a position
stop has a value which is a position

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a protein_id
seq has a value which is a protein_sequence
start has a value which is a position
stop has a value which is a position


=end text

=back



=head2 query_md5

=over 4



=item Description

A structure for specifying the input md5 queries for the map_to_fid_fast method.  This structure assumes
you will be making queries with identical genomes, so it requires the start and stop.

        protein_id id         - arbitrary ID that must be unique within the set of query sequences
        protein md5           - the computed md5 of the protein sequence
        position start        - the start position of the start codon in the genome contig (may be a larger
                                number than stop if the gene is on the reverse strand)
        position stop         - the last position of he stop codon in the genome contig


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a protein_id
md5 has a value which is a protein
start has a value which is a position
stop has a value which is a position

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a protein_id
md5 has a value which is a protein
start has a value which is a position
stop has a value which is a position


=end text

=back



=head2 result

=over 4



=item Description

A simple structure which returns the best matching FID to a given query (see query_sequence) and attaches
a short status string indicating how the match was made, or which consoles you after a match could not
be made.

        fid best_match - the feature ID of a KBase feature that offers the best mapping to your query
        status status  - a short note explaining how the match was made


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
best_match has a value which is a fid
status has a value which is a status

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
best_match has a value which is a fid
status has a value which is a status


=end text

=back



=cut

package Bio::KBase::MOTranslationService::Client::RpcClient;
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
