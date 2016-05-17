package Bio::KBase::meme::Client;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::meme::Client

=head1 DESCRIPTION


Module MEME version 1.0
This module provides a set of methods for work with regulatory motifs. These methods integrate capabilities of three MEME Suite tools into KBase:
- MEME is a tool for finding ungapped motifs in unaligned DNA sequences
- TOMTOM is a tool for comparison of an input DNA motif to the elements of a database of known motifs
- MAST is a tool for searching biological sequence databases for occurrences of known motifs

Data types summary
MemeRunParameters data type keeps input parameters for MEME run.
TomtomRunParameters data type keeps input parameters for TOMTOM run.
MastRunParameters data type keeps input parameters for MAST run.
MemeSite data type represents a particular site from MEME motif description.
MemeMotif data type represents DNA sequence motif predicted by MEME.
MemeRunResult data type represents result of a single MEME run and contains parameters of the search and list of identified motifs.
MemePSPM data type represents a position-specific letter-probability matrix for use with TOMTOM and MAST.
MemePSPMCollection data type contains collection of matrices for use with TOMTOM and MAST.
TomtomHit represents a results of comparison of two matrices by TOMTOM.
TomtomRunResult represents result of a single TOMTOM run.
MastHit represents a particular MAST hit.
MastRunResult represents results of a single MAST run.

Methods summary
find_motifs_with_meme - runs MEME for a set of nucleotide sequences provided as SequenceSet object and returns MemeRunResult object
find_motifs_with_meme_from_ws - runs MEME for a set of nucleotide sequences provided as workspace ID of the SequenceSet and returns kbase ID of MemeRunResult object saved in workspace
find_motifs_with_meme_job_from_ws - runs MEME for a set of nucleotide sequences provided as workspace ID of the SequenceSet and returns job ID 
compare_motifs_with_tomtom - runs TOMTOM for MemePSPM as query vs. MemePSPMCollection as target and returns TomtomRunResult (list of motif pairs)
(removed)compare_motifs_with_tomtom_from_ws - runs TOMTOM for MemePSPM as query vs. MemePSPMCollection as target provided as workspace IDs and returns kbase ID of the TomtomRunResult saved in workspace
(removed)compare_motifs_with_tomtom_job_from_ws - runs TOMTOM for MemePSPM as query vs. MemePSPMCollection as target provided as workspace IDs and returns job ID
compare_motifs_with_tomtom_by_collection - runs TOMTOM for two collection of PSPMs and returns TomtomRunResult (list of motif pairs)
compare_motifs_with_tomtom_by_collection_from_ws - runs TOMTOM for two collection of PSPMs provided as workspace IDs and returns kbase ID of the TomtomRunResult saved in workspace
compare_motifs_with_tomtom_job_by_collection_from_ws - runs TOMTOM for two collection of PSPMs provided as workspace IDs and returns job ID
find_sites_with_mast - runs MAST for MemePSPM vs. SequenceSet and returns MastRunResult (list of MAST hits)
(removed)find_sites_with_mast_from_ws - runs MAST for MemePSPM stored in workspace vs. SequenceSet stored in workspace and returns kbase ID of MastRunResult (list of MAST hits) saved in workspace
(removed)find_sites_with_mast_job_from_ws - runs MAST for MemePSPM stored in workspace vs. SequenceSet stored in workspace and returns job ID
find_sites_with_mast_by_collection - runs MAST for MemePSPMCollection vs. SequenceSet and returns MastRunResult (list of MAST hits)
find_sites_with_mast_by_collection_from_ws - runs MAST for MemePSPMCollection stored in workspace vs. SequenceSet stored in workspace and returns kbase ID of MastRunResult (list of MAST hits) saved in workspace
find_sites_with_mast_job_by_collection_from_ws - runs MAST for MemePSPMCollection stored in workspace vs. SequenceSet stored in workspace and returns kbase ID of MastRunResult (list of MAST hits) saved in workspace
get_pspm_collection_from_meme_result - converts MemeRunResult into MemePSPMCollection
get_pspm_collection_from_meme_result_from_ws - converts MemeRunResult into MemePSPMCollection and writes the result to workspace
get_pspm_collection_from_meme_result_job_from_ws - returns ID of job object that contains ID of MemePSPMCollection converted from MemeRunResult


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => Bio::KBase::meme::Client::RpcClient->new,
	url => $url,
    };

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 find_motifs_with_meme

  $meme_run_result = $obj->find_motifs_with_meme($sequenceSet, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$sequenceSet is a KBaseSequences.SequenceSet
$params is a MEME.MemeRunParameters
$meme_run_result is a MEME.MemeRunResult
KBaseSequences.SequenceSet is a reference to a hash where the following keys are defined:
	sequence_set_id has a value which is a string
	description has a value which is a string
	sequences has a value which is a reference to a list where each element is a KBaseSequences.Sequence
KBaseSequences.Sequence is a reference to a hash where the following keys are defined:
	sequence_id has a value which is a string
	description has a value which is a string
	sequence has a value which is a string
MemeRunParameters is a reference to a hash where the following keys are defined:
	mod has a value which is a string
	nmotifs has a value which is an int
	minw has a value which is an int
	maxw has a value which is an int
	nsites has a value which is an int
	minsites has a value which is an int
	maxsites has a value which is an int
	pal has a value which is an int
	revcomp has a value which is an int
	source_ref has a value which is a MEME.sequence_set_ref
	source_id has a value which is a string
sequence_set_ref is a string
MemeRunResult is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_ref has a value which is a string
	source_id has a value which is a string
	timestamp has a value which is a string
	meme_version has a value which is a string
	input_file_name has a value which is a string
	alphabet has a value which is a string
	training_set has a value which is a reference to a list where each element is a string
	command_line has a value which is a string
	mod has a value which is a string
	nmotifs has a value which is an int
	evt has a value which is a string
	object_function has a value which is a string
	minw has a value which is an int
	maxw has a value which is an int
	minic has a value which is a float
	wg has a value which is an int
	ws has a value which is an int
	endgaps has a value which is a string
	minsites has a value which is an int
	maxsites has a value which is an int
	wnsites has a value which is a float
	prob has a value which is an int
	spmap has a value which is a string
	spfuzz has a value which is a string
	substring has a value which is a string
	branching has a value which is a string
	wbranch has a value which is a string
	prior has a value which is a string
	b has a value which is a float
	maxiter has a value which is an int
	distance has a value which is a float
	n has a value which is an int
	n_cap has a value which is an int
	strands has a value which is a string
	seed has a value which is an int
	seqfrac has a value which is an int
	letter_freq has a value which is a string
	bg_freq has a value which is a string
	motifs has a value which is a reference to a list where each element is a MEME.MemeMotif
	raw_output has a value which is a string
	params has a value which is a MEME.MemeRunParameters
MemeMotif is a reference to a hash where the following keys are defined:
	id has a value which is a string
	description has a value which is a string
	width has a value which is an int
	llr has a value which is a float
	evalue has a value which is a float
	raw_output has a value which is a string
	sites has a value which is a reference to a list where each element is a MEME.MemeSite
MemeSite is a reference to a hash where the following keys are defined:
	source_sequence_id has a value which is a string
	start has a value which is an int
	pvalue has a value which is a float
	left_flank has a value which is a string
	right_flank has a value which is a string
	sequence has a value which is a string

</pre>

=end html

=begin text

$sequenceSet is a KBaseSequences.SequenceSet
$params is a MEME.MemeRunParameters
$meme_run_result is a MEME.MemeRunResult
KBaseSequences.SequenceSet is a reference to a hash where the following keys are defined:
	sequence_set_id has a value which is a string
	description has a value which is a string
	sequences has a value which is a reference to a list where each element is a KBaseSequences.Sequence
KBaseSequences.Sequence is a reference to a hash where the following keys are defined:
	sequence_id has a value which is a string
	description has a value which is a string
	sequence has a value which is a string
MemeRunParameters is a reference to a hash where the following keys are defined:
	mod has a value which is a string
	nmotifs has a value which is an int
	minw has a value which is an int
	maxw has a value which is an int
	nsites has a value which is an int
	minsites has a value which is an int
	maxsites has a value which is an int
	pal has a value which is an int
	revcomp has a value which is an int
	source_ref has a value which is a MEME.sequence_set_ref
	source_id has a value which is a string
sequence_set_ref is a string
MemeRunResult is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_ref has a value which is a string
	source_id has a value which is a string
	timestamp has a value which is a string
	meme_version has a value which is a string
	input_file_name has a value which is a string
	alphabet has a value which is a string
	training_set has a value which is a reference to a list where each element is a string
	command_line has a value which is a string
	mod has a value which is a string
	nmotifs has a value which is an int
	evt has a value which is a string
	object_function has a value which is a string
	minw has a value which is an int
	maxw has a value which is an int
	minic has a value which is a float
	wg has a value which is an int
	ws has a value which is an int
	endgaps has a value which is a string
	minsites has a value which is an int
	maxsites has a value which is an int
	wnsites has a value which is a float
	prob has a value which is an int
	spmap has a value which is a string
	spfuzz has a value which is a string
	substring has a value which is a string
	branching has a value which is a string
	wbranch has a value which is a string
	prior has a value which is a string
	b has a value which is a float
	maxiter has a value which is an int
	distance has a value which is a float
	n has a value which is an int
	n_cap has a value which is an int
	strands has a value which is a string
	seed has a value which is an int
	seqfrac has a value which is an int
	letter_freq has a value which is a string
	bg_freq has a value which is a string
	motifs has a value which is a reference to a list where each element is a MEME.MemeMotif
	raw_output has a value which is a string
	params has a value which is a MEME.MemeRunParameters
MemeMotif is a reference to a hash where the following keys are defined:
	id has a value which is a string
	description has a value which is a string
	width has a value which is an int
	llr has a value which is a float
	evalue has a value which is a float
	raw_output has a value which is a string
	sites has a value which is a reference to a list where each element is a MEME.MemeSite
MemeSite is a reference to a hash where the following keys are defined:
	source_sequence_id has a value which is a string
	start has a value which is an int
	pvalue has a value which is a float
	left_flank has a value which is a string
	right_flank has a value which is a string
	sequence has a value which is a string


=end text

=item Description

Returns results of a single MEME run
MEME will be run with -dna -text parameters
SequenceSet sequenceSet - input set of sequences
MemeRunParameters params - parameters of MEME run

=back

=cut

sub find_motifs_with_meme
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function find_motifs_with_meme (received $n, expecting 2)");
    }
    {
	my($sequenceSet, $params) = @args;

	my @_bad_arguments;
        (ref($sequenceSet) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"sequenceSet\" (value was \"$sequenceSet\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to find_motifs_with_meme:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'find_motifs_with_meme');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.find_motifs_with_meme",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'find_motifs_with_meme',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method find_motifs_with_meme",
					    status_line => $self->{client}->status_line,
					    method_name => 'find_motifs_with_meme',
				       );
    }
}



=head2 find_motifs_with_meme_from_ws

  $output_id = $obj->find_motifs_with_meme_from_ws($ws_name, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$ws_name is a string
$params is a MEME.MemeRunParameters
$output_id is a string
MemeRunParameters is a reference to a hash where the following keys are defined:
	mod has a value which is a string
	nmotifs has a value which is an int
	minw has a value which is an int
	maxw has a value which is an int
	nsites has a value which is an int
	minsites has a value which is an int
	maxsites has a value which is an int
	pal has a value which is an int
	revcomp has a value which is an int
	source_ref has a value which is a MEME.sequence_set_ref
	source_id has a value which is a string
sequence_set_ref is a string

</pre>

=end html

=begin text

$ws_name is a string
$params is a MEME.MemeRunParameters
$output_id is a string
MemeRunParameters is a reference to a hash where the following keys are defined:
	mod has a value which is a string
	nmotifs has a value which is an int
	minw has a value which is an int
	maxw has a value which is an int
	nsites has a value which is an int
	minsites has a value which is an int
	maxsites has a value which is an int
	pal has a value which is an int
	revcomp has a value which is an int
	source_ref has a value which is a MEME.sequence_set_ref
	source_id has a value which is a string
sequence_set_ref is a string


=end text

=item Description

Returns kbase id of MemeRunResult object that contains results of a single MEME run
MEME will be run with -dna -text parameters
string ws_name - workspace id to save run result
MemeRunParameters params - parameters of MEME run

=back

=cut

sub find_motifs_with_meme_from_ws
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function find_motifs_with_meme_from_ws (received $n, expecting 2)");
    }
    {
	my($ws_name, $params) = @args;

	my @_bad_arguments;
        (!ref($ws_name)) or push(@_bad_arguments, "Invalid type for argument 1 \"ws_name\" (value was \"$ws_name\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to find_motifs_with_meme_from_ws:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'find_motifs_with_meme_from_ws');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.find_motifs_with_meme_from_ws",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'find_motifs_with_meme_from_ws',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method find_motifs_with_meme_from_ws",
					    status_line => $self->{client}->status_line,
					    method_name => 'find_motifs_with_meme_from_ws',
				       );
    }
}



=head2 find_motifs_with_meme_job_from_ws

  $job_id = $obj->find_motifs_with_meme_job_from_ws($ws_name, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$ws_name is a string
$params is a MEME.MemeRunParameters
$job_id is a string
MemeRunParameters is a reference to a hash where the following keys are defined:
	mod has a value which is a string
	nmotifs has a value which is an int
	minw has a value which is an int
	maxw has a value which is an int
	nsites has a value which is an int
	minsites has a value which is an int
	maxsites has a value which is an int
	pal has a value which is an int
	revcomp has a value which is an int
	source_ref has a value which is a MEME.sequence_set_ref
	source_id has a value which is a string
sequence_set_ref is a string

</pre>

=end html

=begin text

$ws_name is a string
$params is a MEME.MemeRunParameters
$job_id is a string
MemeRunParameters is a reference to a hash where the following keys are defined:
	mod has a value which is a string
	nmotifs has a value which is an int
	minw has a value which is an int
	maxw has a value which is an int
	nsites has a value which is an int
	minsites has a value which is an int
	maxsites has a value which is an int
	pal has a value which is an int
	revcomp has a value which is an int
	source_ref has a value which is a MEME.sequence_set_ref
	source_id has a value which is a string
sequence_set_ref is a string


=end text

=item Description

Returns id of job object that contains id of a single MEME run result
MEME will be run with -dna -text parameters
string ws_name - workspace id to save run result
MemeRunParameters params - parameters of MEME run

=back

=cut

sub find_motifs_with_meme_job_from_ws
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function find_motifs_with_meme_job_from_ws (received $n, expecting 2)");
    }
    {
	my($ws_name, $params) = @args;

	my @_bad_arguments;
        (!ref($ws_name)) or push(@_bad_arguments, "Invalid type for argument 1 \"ws_name\" (value was \"$ws_name\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to find_motifs_with_meme_job_from_ws:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'find_motifs_with_meme_job_from_ws');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.find_motifs_with_meme_job_from_ws",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'find_motifs_with_meme_job_from_ws',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method find_motifs_with_meme_job_from_ws",
					    status_line => $self->{client}->status_line,
					    method_name => 'find_motifs_with_meme_job_from_ws',
				       );
    }
}



=head2 compare_motifs_with_tomtom

  $tomtom_run_result = $obj->compare_motifs_with_tomtom($query, $target, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$query is a MEME.MemePSPM
$target is a MEME.MemePSPMCollection
$params is a MEME.TomtomRunParameters
$tomtom_run_result is a MEME.TomtomRunResult
MemePSPM is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_id has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	width has a value which is an int
	nsites has a value which is an int
	evalue has a value which is a float
	matrix has a value which is a reference to a list where each element is a reference to a list where each element is a float
MemePSPMCollection is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_ref has a value which is a MEME.meme_run_result_ref
	timestamp has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	pspms has a value which is a reference to a list where each element is a MEME.MemePSPM
meme_run_result_ref is a string
TomtomRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.meme_pspm_collection_ref
	pspm_id has a value which is a string
	thresh has a value which is a float
	evalue has a value which is an int
	dist has a value which is a string
	internal has a value which is an int
	min_overlap has a value which is an int
meme_pspm_collection_ref is a string
TomtomRunResult is a reference to a hash where the following keys are defined:
	id has a value which is a string
	timestamp has a value which is a string
	params has a value which is a MEME.TomtomRunParameters
	hits has a value which is a reference to a list where each element is a MEME.TomtomHit
TomtomHit is a reference to a hash where the following keys are defined:
	query_pspm_id has a value which is a string
	target_pspm_id has a value which is a string
	optimal_offset has a value which is an int
	pvalue has a value which is a float
	evalue has a value which is a float
	qvalue has a value which is a float
	overlap has a value which is an int
	query_consensus has a value which is a string
	target_consensus has a value which is a string
	strand has a value which is a string

</pre>

=end html

=begin text

$query is a MEME.MemePSPM
$target is a MEME.MemePSPMCollection
$params is a MEME.TomtomRunParameters
$tomtom_run_result is a MEME.TomtomRunResult
MemePSPM is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_id has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	width has a value which is an int
	nsites has a value which is an int
	evalue has a value which is a float
	matrix has a value which is a reference to a list where each element is a reference to a list where each element is a float
MemePSPMCollection is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_ref has a value which is a MEME.meme_run_result_ref
	timestamp has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	pspms has a value which is a reference to a list where each element is a MEME.MemePSPM
meme_run_result_ref is a string
TomtomRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.meme_pspm_collection_ref
	pspm_id has a value which is a string
	thresh has a value which is a float
	evalue has a value which is an int
	dist has a value which is a string
	internal has a value which is an int
	min_overlap has a value which is an int
meme_pspm_collection_ref is a string
TomtomRunResult is a reference to a hash where the following keys are defined:
	id has a value which is a string
	timestamp has a value which is a string
	params has a value which is a MEME.TomtomRunParameters
	hits has a value which is a reference to a list where each element is a MEME.TomtomHit
TomtomHit is a reference to a hash where the following keys are defined:
	query_pspm_id has a value which is a string
	target_pspm_id has a value which is a string
	optimal_offset has a value which is an int
	pvalue has a value which is a float
	evalue has a value which is a float
	qvalue has a value which is a float
	overlap has a value which is an int
	query_consensus has a value which is a string
	target_consensus has a value which is a string
	strand has a value which is a string


=end text

=item Description

Returns TomtomRunResult with results of a single TOMTOM run
TOMTOM will be run with -text parameter
MemePSPM query - query motifs for TOMTOM run
MemePSPMCollection target - target motifs for TOMTOM run
TomtomRunParameters params - parameters of TOMTOM run

=back

=cut

sub compare_motifs_with_tomtom
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_motifs_with_tomtom (received $n, expecting 3)");
    }
    {
	my($query, $target, $params) = @args;

	my @_bad_arguments;
        (ref($query) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"query\" (value was \"$query\")");
        (ref($target) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"target\" (value was \"$target\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 3 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_motifs_with_tomtom:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_motifs_with_tomtom');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.compare_motifs_with_tomtom",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_motifs_with_tomtom',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_motifs_with_tomtom",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_motifs_with_tomtom',
				       );
    }
}



=head2 compare_motifs_with_tomtom_by_collection

  $tomtom_run_result = $obj->compare_motifs_with_tomtom_by_collection($query, $target, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$query is a MEME.MemePSPMCollection
$target is a MEME.MemePSPMCollection
$params is a MEME.TomtomRunParameters
$tomtom_run_result is a MEME.TomtomRunResult
MemePSPMCollection is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_ref has a value which is a MEME.meme_run_result_ref
	timestamp has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	pspms has a value which is a reference to a list where each element is a MEME.MemePSPM
meme_run_result_ref is a string
MemePSPM is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_id has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	width has a value which is an int
	nsites has a value which is an int
	evalue has a value which is a float
	matrix has a value which is a reference to a list where each element is a reference to a list where each element is a float
TomtomRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.meme_pspm_collection_ref
	pspm_id has a value which is a string
	thresh has a value which is a float
	evalue has a value which is an int
	dist has a value which is a string
	internal has a value which is an int
	min_overlap has a value which is an int
meme_pspm_collection_ref is a string
TomtomRunResult is a reference to a hash where the following keys are defined:
	id has a value which is a string
	timestamp has a value which is a string
	params has a value which is a MEME.TomtomRunParameters
	hits has a value which is a reference to a list where each element is a MEME.TomtomHit
TomtomHit is a reference to a hash where the following keys are defined:
	query_pspm_id has a value which is a string
	target_pspm_id has a value which is a string
	optimal_offset has a value which is an int
	pvalue has a value which is a float
	evalue has a value which is a float
	qvalue has a value which is a float
	overlap has a value which is an int
	query_consensus has a value which is a string
	target_consensus has a value which is a string
	strand has a value which is a string

</pre>

=end html

=begin text

$query is a MEME.MemePSPMCollection
$target is a MEME.MemePSPMCollection
$params is a MEME.TomtomRunParameters
$tomtom_run_result is a MEME.TomtomRunResult
MemePSPMCollection is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_ref has a value which is a MEME.meme_run_result_ref
	timestamp has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	pspms has a value which is a reference to a list where each element is a MEME.MemePSPM
meme_run_result_ref is a string
MemePSPM is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_id has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	width has a value which is an int
	nsites has a value which is an int
	evalue has a value which is a float
	matrix has a value which is a reference to a list where each element is a reference to a list where each element is a float
TomtomRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.meme_pspm_collection_ref
	pspm_id has a value which is a string
	thresh has a value which is a float
	evalue has a value which is an int
	dist has a value which is a string
	internal has a value which is an int
	min_overlap has a value which is an int
meme_pspm_collection_ref is a string
TomtomRunResult is a reference to a hash where the following keys are defined:
	id has a value which is a string
	timestamp has a value which is a string
	params has a value which is a MEME.TomtomRunParameters
	hits has a value which is a reference to a list where each element is a MEME.TomtomHit
TomtomHit is a reference to a hash where the following keys are defined:
	query_pspm_id has a value which is a string
	target_pspm_id has a value which is a string
	optimal_offset has a value which is an int
	pvalue has a value which is a float
	evalue has a value which is a float
	qvalue has a value which is a float
	overlap has a value which is an int
	query_consensus has a value which is a string
	target_consensus has a value which is a string
	strand has a value which is a string


=end text

=item Description

Returns TomtomRunResult with results of a single TOMTOM run
TOMTOM will be run with -text parameter
MemePSPMCollection query - query motifs for TOMTOM run
MemePSPMCollection target - target motifs for TOMTOM run
TomtomRunParameters params - parameters of TOMTOM run

=back

=cut

sub compare_motifs_with_tomtom_by_collection
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_motifs_with_tomtom_by_collection (received $n, expecting 3)");
    }
    {
	my($query, $target, $params) = @args;

	my @_bad_arguments;
        (ref($query) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"query\" (value was \"$query\")");
        (ref($target) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"target\" (value was \"$target\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 3 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_motifs_with_tomtom_by_collection:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_motifs_with_tomtom_by_collection');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.compare_motifs_with_tomtom_by_collection",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_motifs_with_tomtom_by_collection',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_motifs_with_tomtom_by_collection",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_motifs_with_tomtom_by_collection',
				       );
    }
}



=head2 compare_motifs_with_tomtom_by_collection_from_ws

  $output_id = $obj->compare_motifs_with_tomtom_by_collection_from_ws($ws_name, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$ws_name is a string
$params is a MEME.TomtomRunParameters
$output_id is a string
TomtomRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.meme_pspm_collection_ref
	pspm_id has a value which is a string
	thresh has a value which is a float
	evalue has a value which is an int
	dist has a value which is a string
	internal has a value which is an int
	min_overlap has a value which is an int
meme_pspm_collection_ref is a string

</pre>

=end html

=begin text

$ws_name is a string
$params is a MEME.TomtomRunParameters
$output_id is a string
TomtomRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.meme_pspm_collection_ref
	pspm_id has a value which is a string
	thresh has a value which is a float
	evalue has a value which is an int
	dist has a value which is a string
	internal has a value which is an int
	min_overlap has a value which is an int
meme_pspm_collection_ref is a string


=end text

=item Description

Returns kbase ID of TomtomRunResult with results of a single TOMTOM run
string ws_name - workspace id 
TOMTOM will be run with -text parameter
TomtomRunParameters params - parameters of TOMTOM run

=back

=cut

sub compare_motifs_with_tomtom_by_collection_from_ws
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_motifs_with_tomtom_by_collection_from_ws (received $n, expecting 2)");
    }
    {
	my($ws_name, $params) = @args;

	my @_bad_arguments;
        (!ref($ws_name)) or push(@_bad_arguments, "Invalid type for argument 1 \"ws_name\" (value was \"$ws_name\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_motifs_with_tomtom_by_collection_from_ws:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_motifs_with_tomtom_by_collection_from_ws');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.compare_motifs_with_tomtom_by_collection_from_ws",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_motifs_with_tomtom_by_collection_from_ws',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_motifs_with_tomtom_by_collection_from_ws",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_motifs_with_tomtom_by_collection_from_ws',
				       );
    }
}



=head2 compare_motifs_with_tomtom_job_by_collection_from_ws

  $job_id = $obj->compare_motifs_with_tomtom_job_by_collection_from_ws($ws_name, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$ws_name is a string
$params is a MEME.TomtomRunParameters
$job_id is a string
TomtomRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.meme_pspm_collection_ref
	pspm_id has a value which is a string
	thresh has a value which is a float
	evalue has a value which is an int
	dist has a value which is a string
	internal has a value which is an int
	min_overlap has a value which is an int
meme_pspm_collection_ref is a string

</pre>

=end html

=begin text

$ws_name is a string
$params is a MEME.TomtomRunParameters
$job_id is a string
TomtomRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.meme_pspm_collection_ref
	pspm_id has a value which is a string
	thresh has a value which is a float
	evalue has a value which is an int
	dist has a value which is a string
	internal has a value which is an int
	min_overlap has a value which is an int
meme_pspm_collection_ref is a string


=end text

=item Description

Returns ID of job object that contains ID of results of a single TOMTOM run
string ws_name - workspace id 
TOMTOM will be run with -text parameter
TomtomRunParameters params - parameters of TOMTOM run

=back

=cut

sub compare_motifs_with_tomtom_job_by_collection_from_ws
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_motifs_with_tomtom_job_by_collection_from_ws (received $n, expecting 2)");
    }
    {
	my($ws_name, $params) = @args;

	my @_bad_arguments;
        (!ref($ws_name)) or push(@_bad_arguments, "Invalid type for argument 1 \"ws_name\" (value was \"$ws_name\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_motifs_with_tomtom_job_by_collection_from_ws:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_motifs_with_tomtom_job_by_collection_from_ws');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.compare_motifs_with_tomtom_job_by_collection_from_ws",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_motifs_with_tomtom_job_by_collection_from_ws',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_motifs_with_tomtom_job_by_collection_from_ws",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_motifs_with_tomtom_job_by_collection_from_ws',
				       );
    }
}



=head2 find_sites_with_mast

  $mast_run_result = $obj->find_sites_with_mast($query, $target, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$query is a MEME.MemePSPM
$target is a KBaseSequences.SequenceSet
$params is a MEME.MastRunParameters
$mast_run_result is a MEME.MastRunResult
MemePSPM is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_id has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	width has a value which is an int
	nsites has a value which is an int
	evalue has a value which is a float
	matrix has a value which is a reference to a list where each element is a reference to a list where each element is a float
KBaseSequences.SequenceSet is a reference to a hash where the following keys are defined:
	sequence_set_id has a value which is a string
	description has a value which is a string
	sequences has a value which is a reference to a list where each element is a KBaseSequences.Sequence
KBaseSequences.Sequence is a reference to a hash where the following keys are defined:
	sequence_id has a value which is a string
	description has a value which is a string
	sequence has a value which is a string
MastRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.sequence_set_ref
	pspm_id has a value which is a string
	mt has a value which is a float
meme_pspm_collection_ref is a string
sequence_set_ref is a string
MastRunResult is a reference to a hash where the following keys are defined:
	id has a value which is a string
	timestamp has a value which is a string
	params has a value which is a MEME.MastRunParameters
	hits has a value which is a reference to a list where each element is a MEME.MastHit
MastHit is a reference to a hash where the following keys are defined:
	seq_id has a value which is a string
	pspm_id has a value which is a string
	strand has a value which is a string
	hit_start has a value which is an int
	hit_end has a value which is an int
	score has a value which is a float
	hit_pvalue has a value which is a float

</pre>

=end html

=begin text

$query is a MEME.MemePSPM
$target is a KBaseSequences.SequenceSet
$params is a MEME.MastRunParameters
$mast_run_result is a MEME.MastRunResult
MemePSPM is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_id has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	width has a value which is an int
	nsites has a value which is an int
	evalue has a value which is a float
	matrix has a value which is a reference to a list where each element is a reference to a list where each element is a float
KBaseSequences.SequenceSet is a reference to a hash where the following keys are defined:
	sequence_set_id has a value which is a string
	description has a value which is a string
	sequences has a value which is a reference to a list where each element is a KBaseSequences.Sequence
KBaseSequences.Sequence is a reference to a hash where the following keys are defined:
	sequence_id has a value which is a string
	description has a value which is a string
	sequence has a value which is a string
MastRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.sequence_set_ref
	pspm_id has a value which is a string
	mt has a value which is a float
meme_pspm_collection_ref is a string
sequence_set_ref is a string
MastRunResult is a reference to a hash where the following keys are defined:
	id has a value which is a string
	timestamp has a value which is a string
	params has a value which is a MEME.MastRunParameters
	hits has a value which is a reference to a list where each element is a MEME.MastHit
MastHit is a reference to a hash where the following keys are defined:
	seq_id has a value which is a string
	pspm_id has a value which is a string
	strand has a value which is a string
	hit_start has a value which is an int
	hit_end has a value which is an int
	score has a value which is a float
	hit_pvalue has a value which is a float


=end text

=item Description

Returns MastRunResult containing list of MAST hits
MAST will be run with -hit_list parameter
MemePSPM query - query PSPM for MAST run
SequenceSet target - target sequences for MAST run
MastRunParameters params - parameters of MAST run

=back

=cut

sub find_sites_with_mast
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function find_sites_with_mast (received $n, expecting 3)");
    }
    {
	my($query, $target, $params) = @args;

	my @_bad_arguments;
        (ref($query) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"query\" (value was \"$query\")");
        (ref($target) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"target\" (value was \"$target\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 3 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to find_sites_with_mast:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'find_sites_with_mast');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.find_sites_with_mast",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'find_sites_with_mast',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method find_sites_with_mast",
					    status_line => $self->{client}->status_line,
					    method_name => 'find_sites_with_mast',
				       );
    }
}



=head2 find_sites_with_mast_by_collection

  $mast_run_result = $obj->find_sites_with_mast_by_collection($query, $target, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$query is a MEME.MemePSPMCollection
$target is a KBaseSequences.SequenceSet
$params is a MEME.MastRunParameters
$mast_run_result is a MEME.MastRunResult
MemePSPMCollection is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_ref has a value which is a MEME.meme_run_result_ref
	timestamp has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	pspms has a value which is a reference to a list where each element is a MEME.MemePSPM
meme_run_result_ref is a string
MemePSPM is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_id has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	width has a value which is an int
	nsites has a value which is an int
	evalue has a value which is a float
	matrix has a value which is a reference to a list where each element is a reference to a list where each element is a float
KBaseSequences.SequenceSet is a reference to a hash where the following keys are defined:
	sequence_set_id has a value which is a string
	description has a value which is a string
	sequences has a value which is a reference to a list where each element is a KBaseSequences.Sequence
KBaseSequences.Sequence is a reference to a hash where the following keys are defined:
	sequence_id has a value which is a string
	description has a value which is a string
	sequence has a value which is a string
MastRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.sequence_set_ref
	pspm_id has a value which is a string
	mt has a value which is a float
meme_pspm_collection_ref is a string
sequence_set_ref is a string
MastRunResult is a reference to a hash where the following keys are defined:
	id has a value which is a string
	timestamp has a value which is a string
	params has a value which is a MEME.MastRunParameters
	hits has a value which is a reference to a list where each element is a MEME.MastHit
MastHit is a reference to a hash where the following keys are defined:
	seq_id has a value which is a string
	pspm_id has a value which is a string
	strand has a value which is a string
	hit_start has a value which is an int
	hit_end has a value which is an int
	score has a value which is a float
	hit_pvalue has a value which is a float

</pre>

=end html

=begin text

$query is a MEME.MemePSPMCollection
$target is a KBaseSequences.SequenceSet
$params is a MEME.MastRunParameters
$mast_run_result is a MEME.MastRunResult
MemePSPMCollection is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_ref has a value which is a MEME.meme_run_result_ref
	timestamp has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	pspms has a value which is a reference to a list where each element is a MEME.MemePSPM
meme_run_result_ref is a string
MemePSPM is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_id has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	width has a value which is an int
	nsites has a value which is an int
	evalue has a value which is a float
	matrix has a value which is a reference to a list where each element is a reference to a list where each element is a float
KBaseSequences.SequenceSet is a reference to a hash where the following keys are defined:
	sequence_set_id has a value which is a string
	description has a value which is a string
	sequences has a value which is a reference to a list where each element is a KBaseSequences.Sequence
KBaseSequences.Sequence is a reference to a hash where the following keys are defined:
	sequence_id has a value which is a string
	description has a value which is a string
	sequence has a value which is a string
MastRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.sequence_set_ref
	pspm_id has a value which is a string
	mt has a value which is a float
meme_pspm_collection_ref is a string
sequence_set_ref is a string
MastRunResult is a reference to a hash where the following keys are defined:
	id has a value which is a string
	timestamp has a value which is a string
	params has a value which is a MEME.MastRunParameters
	hits has a value which is a reference to a list where each element is a MEME.MastHit
MastHit is a reference to a hash where the following keys are defined:
	seq_id has a value which is a string
	pspm_id has a value which is a string
	strand has a value which is a string
	hit_start has a value which is an int
	hit_end has a value which is an int
	score has a value which is a float
	hit_pvalue has a value which is a float


=end text

=item Description

Returns MastRunResult containing list of MAST hits
MAST will be run with -hit_list parameter
MemePSPMCollection query - query motifs for MAST run
SequenceSet target - target sequences for MAST run
MastRunParameters params - parameters of MAST run

=back

=cut

sub find_sites_with_mast_by_collection
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function find_sites_with_mast_by_collection (received $n, expecting 3)");
    }
    {
	my($query, $target, $params) = @args;

	my @_bad_arguments;
        (ref($query) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"query\" (value was \"$query\")");
        (ref($target) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"target\" (value was \"$target\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 3 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to find_sites_with_mast_by_collection:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'find_sites_with_mast_by_collection');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.find_sites_with_mast_by_collection",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'find_sites_with_mast_by_collection',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method find_sites_with_mast_by_collection",
					    status_line => $self->{client}->status_line,
					    method_name => 'find_sites_with_mast_by_collection',
				       );
    }
}



=head2 find_sites_with_mast_by_collection_from_ws

  $output_id = $obj->find_sites_with_mast_by_collection_from_ws($ws_name, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$ws_name is a string
$params is a MEME.MastRunParameters
$output_id is a string
MastRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.sequence_set_ref
	pspm_id has a value which is a string
	mt has a value which is a float
meme_pspm_collection_ref is a string
sequence_set_ref is a string

</pre>

=end html

=begin text

$ws_name is a string
$params is a MEME.MastRunParameters
$output_id is a string
MastRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.sequence_set_ref
	pspm_id has a value which is a string
	mt has a value which is a float
meme_pspm_collection_ref is a string
sequence_set_ref is a string


=end text

=item Description

Returns kbase ID of MastRunResult containing list of MAST hits
MAST will be run with -hit_list parameter
string ws_name - workspace id 
MastRunParameters params - parameters of MAST run

=back

=cut

sub find_sites_with_mast_by_collection_from_ws
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function find_sites_with_mast_by_collection_from_ws (received $n, expecting 2)");
    }
    {
	my($ws_name, $params) = @args;

	my @_bad_arguments;
        (!ref($ws_name)) or push(@_bad_arguments, "Invalid type for argument 1 \"ws_name\" (value was \"$ws_name\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to find_sites_with_mast_by_collection_from_ws:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'find_sites_with_mast_by_collection_from_ws');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.find_sites_with_mast_by_collection_from_ws",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'find_sites_with_mast_by_collection_from_ws',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method find_sites_with_mast_by_collection_from_ws",
					    status_line => $self->{client}->status_line,
					    method_name => 'find_sites_with_mast_by_collection_from_ws',
				       );
    }
}



=head2 find_sites_with_mast_job_by_collection_from_ws

  $job_id = $obj->find_sites_with_mast_job_by_collection_from_ws($ws_name, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$ws_name is a string
$params is a MEME.MastRunParameters
$job_id is a string
MastRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.sequence_set_ref
	pspm_id has a value which is a string
	mt has a value which is a float
meme_pspm_collection_ref is a string
sequence_set_ref is a string

</pre>

=end html

=begin text

$ws_name is a string
$params is a MEME.MastRunParameters
$job_id is a string
MastRunParameters is a reference to a hash where the following keys are defined:
	query_ref has a value which is a MEME.meme_pspm_collection_ref
	target_ref has a value which is a MEME.sequence_set_ref
	pspm_id has a value which is a string
	mt has a value which is a float
meme_pspm_collection_ref is a string
sequence_set_ref is a string


=end text

=item Description

Returns ID of job object that contains ID of MastRunResult
MAST will be run with -hit_list parameter
string ws_name - workspace id 
MastRunParameters params - parameters of MAST run

=back

=cut

sub find_sites_with_mast_job_by_collection_from_ws
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function find_sites_with_mast_job_by_collection_from_ws (received $n, expecting 2)");
    }
    {
	my($ws_name, $params) = @args;

	my @_bad_arguments;
        (!ref($ws_name)) or push(@_bad_arguments, "Invalid type for argument 1 \"ws_name\" (value was \"$ws_name\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to find_sites_with_mast_job_by_collection_from_ws:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'find_sites_with_mast_job_by_collection_from_ws');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.find_sites_with_mast_job_by_collection_from_ws",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'find_sites_with_mast_job_by_collection_from_ws',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method find_sites_with_mast_job_by_collection_from_ws",
					    status_line => $self->{client}->status_line,
					    method_name => 'find_sites_with_mast_job_by_collection_from_ws',
				       );
    }
}



=head2 get_pspm_collection_from_meme_result

  $meme_pspm_collection = $obj->get_pspm_collection_from_meme_result($meme_run_result)

=over 4

=item Parameter and return types

=begin html

<pre>
$meme_run_result is a MEME.MemeRunResult
$meme_pspm_collection is a MEME.MemePSPMCollection
MemeRunResult is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_ref has a value which is a string
	source_id has a value which is a string
	timestamp has a value which is a string
	meme_version has a value which is a string
	input_file_name has a value which is a string
	alphabet has a value which is a string
	training_set has a value which is a reference to a list where each element is a string
	command_line has a value which is a string
	mod has a value which is a string
	nmotifs has a value which is an int
	evt has a value which is a string
	object_function has a value which is a string
	minw has a value which is an int
	maxw has a value which is an int
	minic has a value which is a float
	wg has a value which is an int
	ws has a value which is an int
	endgaps has a value which is a string
	minsites has a value which is an int
	maxsites has a value which is an int
	wnsites has a value which is a float
	prob has a value which is an int
	spmap has a value which is a string
	spfuzz has a value which is a string
	substring has a value which is a string
	branching has a value which is a string
	wbranch has a value which is a string
	prior has a value which is a string
	b has a value which is a float
	maxiter has a value which is an int
	distance has a value which is a float
	n has a value which is an int
	n_cap has a value which is an int
	strands has a value which is a string
	seed has a value which is an int
	seqfrac has a value which is an int
	letter_freq has a value which is a string
	bg_freq has a value which is a string
	motifs has a value which is a reference to a list where each element is a MEME.MemeMotif
	raw_output has a value which is a string
	params has a value which is a MEME.MemeRunParameters
MemeMotif is a reference to a hash where the following keys are defined:
	id has a value which is a string
	description has a value which is a string
	width has a value which is an int
	llr has a value which is a float
	evalue has a value which is a float
	raw_output has a value which is a string
	sites has a value which is a reference to a list where each element is a MEME.MemeSite
MemeSite is a reference to a hash where the following keys are defined:
	source_sequence_id has a value which is a string
	start has a value which is an int
	pvalue has a value which is a float
	left_flank has a value which is a string
	right_flank has a value which is a string
	sequence has a value which is a string
MemeRunParameters is a reference to a hash where the following keys are defined:
	mod has a value which is a string
	nmotifs has a value which is an int
	minw has a value which is an int
	maxw has a value which is an int
	nsites has a value which is an int
	minsites has a value which is an int
	maxsites has a value which is an int
	pal has a value which is an int
	revcomp has a value which is an int
	source_ref has a value which is a MEME.sequence_set_ref
	source_id has a value which is a string
sequence_set_ref is a string
MemePSPMCollection is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_ref has a value which is a MEME.meme_run_result_ref
	timestamp has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	pspms has a value which is a reference to a list where each element is a MEME.MemePSPM
meme_run_result_ref is a string
MemePSPM is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_id has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	width has a value which is an int
	nsites has a value which is an int
	evalue has a value which is a float
	matrix has a value which is a reference to a list where each element is a reference to a list where each element is a float

</pre>

=end html

=begin text

$meme_run_result is a MEME.MemeRunResult
$meme_pspm_collection is a MEME.MemePSPMCollection
MemeRunResult is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_ref has a value which is a string
	source_id has a value which is a string
	timestamp has a value which is a string
	meme_version has a value which is a string
	input_file_name has a value which is a string
	alphabet has a value which is a string
	training_set has a value which is a reference to a list where each element is a string
	command_line has a value which is a string
	mod has a value which is a string
	nmotifs has a value which is an int
	evt has a value which is a string
	object_function has a value which is a string
	minw has a value which is an int
	maxw has a value which is an int
	minic has a value which is a float
	wg has a value which is an int
	ws has a value which is an int
	endgaps has a value which is a string
	minsites has a value which is an int
	maxsites has a value which is an int
	wnsites has a value which is a float
	prob has a value which is an int
	spmap has a value which is a string
	spfuzz has a value which is a string
	substring has a value which is a string
	branching has a value which is a string
	wbranch has a value which is a string
	prior has a value which is a string
	b has a value which is a float
	maxiter has a value which is an int
	distance has a value which is a float
	n has a value which is an int
	n_cap has a value which is an int
	strands has a value which is a string
	seed has a value which is an int
	seqfrac has a value which is an int
	letter_freq has a value which is a string
	bg_freq has a value which is a string
	motifs has a value which is a reference to a list where each element is a MEME.MemeMotif
	raw_output has a value which is a string
	params has a value which is a MEME.MemeRunParameters
MemeMotif is a reference to a hash where the following keys are defined:
	id has a value which is a string
	description has a value which is a string
	width has a value which is an int
	llr has a value which is a float
	evalue has a value which is a float
	raw_output has a value which is a string
	sites has a value which is a reference to a list where each element is a MEME.MemeSite
MemeSite is a reference to a hash where the following keys are defined:
	source_sequence_id has a value which is a string
	start has a value which is an int
	pvalue has a value which is a float
	left_flank has a value which is a string
	right_flank has a value which is a string
	sequence has a value which is a string
MemeRunParameters is a reference to a hash where the following keys are defined:
	mod has a value which is a string
	nmotifs has a value which is an int
	minw has a value which is an int
	maxw has a value which is an int
	nsites has a value which is an int
	minsites has a value which is an int
	maxsites has a value which is an int
	pal has a value which is an int
	revcomp has a value which is an int
	source_ref has a value which is a MEME.sequence_set_ref
	source_id has a value which is a string
sequence_set_ref is a string
MemePSPMCollection is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_ref has a value which is a MEME.meme_run_result_ref
	timestamp has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	pspms has a value which is a reference to a list where each element is a MEME.MemePSPM
meme_run_result_ref is a string
MemePSPM is a reference to a hash where the following keys are defined:
	id has a value which is a string
	source_id has a value which is a string
	description has a value which is a string
	alphabet has a value which is a string
	width has a value which is an int
	nsites has a value which is an int
	evalue has a value which is a float
	matrix has a value which is a reference to a list where each element is a reference to a list where each element is a float


=end text

=item Description

Converts MemeRunResult into MemePSPMCollection 
MemeRunResult meme_run_result - source MemeRunResult

=back

=cut

sub get_pspm_collection_from_meme_result
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_pspm_collection_from_meme_result (received $n, expecting 1)");
    }
    {
	my($meme_run_result) = @args;

	my @_bad_arguments;
        (ref($meme_run_result) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"meme_run_result\" (value was \"$meme_run_result\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_pspm_collection_from_meme_result:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_pspm_collection_from_meme_result');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.get_pspm_collection_from_meme_result",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_pspm_collection_from_meme_result',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_pspm_collection_from_meme_result",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_pspm_collection_from_meme_result',
				       );
    }
}



=head2 get_pspm_collection_from_meme_result_from_ws

  $output_id = $obj->get_pspm_collection_from_meme_result_from_ws($ws_name, $input_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$ws_name is a string
$input_id is a string
$output_id is a string

</pre>

=end html

=begin text

$ws_name is a string
$input_id is a string
$output_id is a string


=end text

=item Description

Converts MemeRunResult into MemePSPMCollection and writes the result to workspace
string ws_name - workspace id
string input_id - KBase ID of source MemeRunResult

=back

=cut

sub get_pspm_collection_from_meme_result_from_ws
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_pspm_collection_from_meme_result_from_ws (received $n, expecting 2)");
    }
    {
	my($ws_name, $input_id) = @args;

	my @_bad_arguments;
        (!ref($ws_name)) or push(@_bad_arguments, "Invalid type for argument 1 \"ws_name\" (value was \"$ws_name\")");
        (!ref($input_id)) or push(@_bad_arguments, "Invalid type for argument 2 \"input_id\" (value was \"$input_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_pspm_collection_from_meme_result_from_ws:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_pspm_collection_from_meme_result_from_ws');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.get_pspm_collection_from_meme_result_from_ws",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_pspm_collection_from_meme_result_from_ws',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_pspm_collection_from_meme_result_from_ws",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_pspm_collection_from_meme_result_from_ws',
				       );
    }
}



=head2 get_pspm_collection_from_meme_result_job_from_ws

  $job_id = $obj->get_pspm_collection_from_meme_result_job_from_ws($ws_name, $input_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$ws_name is a string
$input_id is a MEME.meme_run_result_ref
$job_id is a string
meme_run_result_ref is a string

</pre>

=end html

=begin text

$ws_name is a string
$input_id is a MEME.meme_run_result_ref
$job_id is a string
meme_run_result_ref is a string


=end text

=item Description

Returns ID of job object that contains ID of MemePSPMCollection converted from MemeRunResult
string ws_name - workspace id
string meme_run_result_id - KBase ID of source MemeRunResult

=back

=cut

sub get_pspm_collection_from_meme_result_job_from_ws
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_pspm_collection_from_meme_result_job_from_ws (received $n, expecting 2)");
    }
    {
	my($ws_name, $input_id) = @args;

	my @_bad_arguments;
        (!ref($ws_name)) or push(@_bad_arguments, "Invalid type for argument 1 \"ws_name\" (value was \"$ws_name\")");
        (!ref($input_id)) or push(@_bad_arguments, "Invalid type for argument 2 \"input_id\" (value was \"$input_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_pspm_collection_from_meme_result_job_from_ws:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_pspm_collection_from_meme_result_job_from_ws');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MEME.get_pspm_collection_from_meme_result_job_from_ws",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_pspm_collection_from_meme_result_job_from_ws',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_pspm_collection_from_meme_result_job_from_ws",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_pspm_collection_from_meme_result_job_from_ws',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "MEME.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'get_pspm_collection_from_meme_result_job_from_ws',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method get_pspm_collection_from_meme_result_job_from_ws",
            status_line => $self->{client}->status_line,
            method_name => 'get_pspm_collection_from_meme_result_job_from_ws',
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
        warn "New client version available for Bio::KBase::meme::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::meme::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 sequence_set_ref

=over 4



=item Description

Represents WS KBaseSequences.SequenceSet identifier
@id ws KBaseSequences.SequenceSet


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



=head2 meme_run_result_ref

=over 4



=item Description

Represents WS MemeRunResult identifier
@id ws MEME.MemeRunResult


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



=head2 meme_pspm_collection_ref

=over 4



=item Description

Represents WS MemePSPMCollection identifier
@id ws MEME.MemePSPMCollection


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



=head2 MemeSite

=over 4



=item Description

Represents a particular site from MEME motif description 
string source_sequence_id - ID of sequence where the site was found
int start - position of site start 
float pvalue - site P-value
string left_flank - sequence of left flank
string sequence - sequence of site
string right_flank - sequence of right flank

@optional start pvalue left_flank right_flank


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
source_sequence_id has a value which is a string
start has a value which is an int
pvalue has a value which is a float
left_flank has a value which is a string
right_flank has a value which is a string
sequence has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
source_sequence_id has a value which is a string
start has a value which is an int
pvalue has a value which is a float
left_flank has a value which is a string
right_flank has a value which is a string
sequence has a value which is a string


=end text

=back



=head2 MemeMotif

=over 4



=item Description

Represents a particular motif found by MEME
string id - KBase ID of MemeMotif
string description - name of motif or number of motif in collection or anything else
int width - width of motif
int sites - number of sites
float llr - log likelihood ratio of motif
float evalue - E-value of motif
string raw_output - part of MEME output file with data about this motif
list<MemeSite> sites - list of sites

@optional description width llr evalue raw_output


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
description has a value which is a string
width has a value which is an int
llr has a value which is a float
evalue has a value which is a float
raw_output has a value which is a string
sites has a value which is a reference to a list where each element is a MEME.MemeSite

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
description has a value which is a string
width has a value which is an int
llr has a value which is a float
evalue has a value which is a float
raw_output has a value which is a string
sites has a value which is a reference to a list where each element is a MEME.MemeSite


=end text

=back



=head2 MemeRunParameters

=over 4



=item Description

Contains parameters of a MEME run
string mod - distribution of motifs, acceptable values are "oops", "zoops", "anr"
int nmotifs - maximum number of motifs to find
int minw - minumum motif width
int maxw - maximum motif width
int nsites - number of sites for each motif
int minsites - minimum number of sites for each motif
int maxsites - maximum number of sites for each motif
int pal - force palindromes, acceptable values are 0 and 1
int revcomp - allow sites on + or - DNA strands, acceptable values are 0 and 1
sequence_set_ref source_ref - WS reference to source SequenceSet object
string source_id - id of source SequenceSet object

@optional nmotifs minw maxw nsites minsites maxsites pal revcomp source_ref source_id


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
mod has a value which is a string
nmotifs has a value which is an int
minw has a value which is an int
maxw has a value which is an int
nsites has a value which is an int
minsites has a value which is an int
maxsites has a value which is an int
pal has a value which is an int
revcomp has a value which is an int
source_ref has a value which is a MEME.sequence_set_ref
source_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
mod has a value which is a string
nmotifs has a value which is an int
minw has a value which is an int
maxw has a value which is an int
nsites has a value which is an int
minsites has a value which is an int
maxsites has a value which is an int
pal has a value which is an int
revcomp has a value which is an int
source_ref has a value which is a MEME.sequence_set_ref
source_id has a value which is a string


=end text

=back



=head2 MemeRunResult

=over 4



=item Description

Represents results of a single MEME run
string id - KBase ID of MemeRunResult
string source_ref - WS reference to source SequenceSet object
string source_id - id of source SequenceSet object
string timestamp - timestamp for creation time of collection
string version - version of MEME like "MEME version 4.9.0 (Release date: Wed Oct  3 11:07:26 EST 2012)"
string input_file_name - name of input file, DATAFILE field of MEME output
string alphabet - ALPHABET field of MEME output (like "ACGT")
string training_set - strings from TRAINING SET section, except DATAFILE and ALPHABET fields
string command_line - command line of MEME run 
string mod - value of mod parameter of MEME run
int nmotifs - value of nmotifs parameter of MEME run
string evt - value of evt parameter of MEME run
string object_function - value of object function parameter of MEME run
int minw - value of minw parameter of MEME run
int maxw - value of maxw parameter of MEME run
float minic - value of minic parameter of MEME run
int wg - value of wg parameter of MEME run
int ws - value of wc parameter of MEME run
string endgaps - value of endgaps parameter of MEME run
int minsites - value of minsites parameter of MEME run
int maxsites - value of maxsites parameter of MEME run
float wnsites - value of wnsites parameter of MEME run
int prob - value of prob parameter of MEME run
string spmap - value of spmsp parameter of MEME run
float spfuzz - value of spfuzz parameter of MEME run
string substring - value of substring parameter of MEME run
string branching - value of branching parameter of MEME run
string wbranch - value of wbranch parameter of MEME run
string prior - value of prior parameter of MEME run
float b - value of b parameter of MEME run
int maxiter - value of maxiter parameter of MEME run
float distance - value of distance parameter of MEME run
int n - value of n parameter of MEME run
int n_cap - value of N parameter of MEME run
string strands - value of strands parameter of MEME run
int seed - value of seed parameter of MEME run
int seqfrac - value of seqfrac parameter of MEME run
string letter_freq - letter frequencies in dataset
string bg_freq - background letter frequencies
list<MemeMotif> motifs - A list of all motifs in a collection
string raw_output - section of MEME output text file (all before motif data)
MemeRunParameters params

@optional source_ref source_id timestamp meme_version input_file_name alphabet training_set command_line mod nmotifs evt object_function minw maxw minic wg ws endgaps minsites maxsites wnsites prob spmap spfuzz substring branching wbranch prior b maxiter distance n n_cap strands seed seqfrac letter_freq bg_freq motifs raw_output


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
source_ref has a value which is a string
source_id has a value which is a string
timestamp has a value which is a string
meme_version has a value which is a string
input_file_name has a value which is a string
alphabet has a value which is a string
training_set has a value which is a reference to a list where each element is a string
command_line has a value which is a string
mod has a value which is a string
nmotifs has a value which is an int
evt has a value which is a string
object_function has a value which is a string
minw has a value which is an int
maxw has a value which is an int
minic has a value which is a float
wg has a value which is an int
ws has a value which is an int
endgaps has a value which is a string
minsites has a value which is an int
maxsites has a value which is an int
wnsites has a value which is a float
prob has a value which is an int
spmap has a value which is a string
spfuzz has a value which is a string
substring has a value which is a string
branching has a value which is a string
wbranch has a value which is a string
prior has a value which is a string
b has a value which is a float
maxiter has a value which is an int
distance has a value which is a float
n has a value which is an int
n_cap has a value which is an int
strands has a value which is a string
seed has a value which is an int
seqfrac has a value which is an int
letter_freq has a value which is a string
bg_freq has a value which is a string
motifs has a value which is a reference to a list where each element is a MEME.MemeMotif
raw_output has a value which is a string
params has a value which is a MEME.MemeRunParameters

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
source_ref has a value which is a string
source_id has a value which is a string
timestamp has a value which is a string
meme_version has a value which is a string
input_file_name has a value which is a string
alphabet has a value which is a string
training_set has a value which is a reference to a list where each element is a string
command_line has a value which is a string
mod has a value which is a string
nmotifs has a value which is an int
evt has a value which is a string
object_function has a value which is a string
minw has a value which is an int
maxw has a value which is an int
minic has a value which is a float
wg has a value which is an int
ws has a value which is an int
endgaps has a value which is a string
minsites has a value which is an int
maxsites has a value which is an int
wnsites has a value which is a float
prob has a value which is an int
spmap has a value which is a string
spfuzz has a value which is a string
substring has a value which is a string
branching has a value which is a string
wbranch has a value which is a string
prior has a value which is a string
b has a value which is a float
maxiter has a value which is an int
distance has a value which is a float
n has a value which is an int
n_cap has a value which is an int
strands has a value which is a string
seed has a value which is an int
seqfrac has a value which is an int
letter_freq has a value which is a string
bg_freq has a value which is a string
motifs has a value which is a reference to a list where each element is a MEME.MemeMotif
raw_output has a value which is a string
params has a value which is a MEME.MemeRunParameters


=end text

=back



=head2 MemePSPM

=over 4



=item Description

Represents a position-specific probability matrix fot MEME motif
string id - KBase ID of the matrix object
string source_id - KBase ID of source object
string description - description of motif
string alphabet - ALPHABET field of MEME output ("ACGT" for nucleotide motifs)
int width - width of motif
int nsites - number of sites
float evalue - E-value of motif
list<list<float>> matrix - The letter probability matrix is a table of probabilities where the rows are positions in the motif and the columns are letters in the alphabet. The columns are ordered alphabetically so for DNA the first column is A, the second is C, the third is G and the last is T.

@optional source_id description width nsites evalue


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
description has a value which is a string
alphabet has a value which is a string
width has a value which is an int
nsites has a value which is an int
evalue has a value which is a float
matrix has a value which is a reference to a list where each element is a reference to a list where each element is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
description has a value which is a string
alphabet has a value which is a string
width has a value which is an int
nsites has a value which is an int
evalue has a value which is a float
matrix has a value which is a reference to a list where each element is a reference to a list where each element is a float


=end text

=back



=head2 MemePSPMCollection

=over 4



=item Description

Represents collection of MemePSPMs
string id - KBase ID of MotifPSPMMeme
meme_run_result_ref source_ref - WS reference of source object
string timestamp - timestamp for creation time of collection
string description - user's description of the collection
string alphabet - ALPHABET field of MEME output ("ACGT" for nucleotide motifs)
list<MemeMotif> pspms - A list of all MemePSPMs in a collection

@optional source_ref timestamp description


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
source_ref has a value which is a MEME.meme_run_result_ref
timestamp has a value which is a string
description has a value which is a string
alphabet has a value which is a string
pspms has a value which is a reference to a list where each element is a MEME.MemePSPM

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
source_ref has a value which is a MEME.meme_run_result_ref
timestamp has a value which is a string
description has a value which is a string
alphabet has a value which is a string
pspms has a value which is a reference to a list where each element is a MEME.MemePSPM


=end text

=back



=head2 TomtomRunParameters

=over 4



=item Description

Contains parameters of a TOMTOM run
meme_pspm_collection_ref query_ref - query motifs for TOMTOM run
meme_pspm_collection_ref target_ref - target motifs for TOMTOM run
string pspm_id - KBase ID of a MemePSPM from the query collection that will be used. When empty string provided, all motifs in the query collection will be used
float thresh - thresh parameter of TOMTOM run, must be smaller than or equal to 1.0 unless evalueTomtom == 1
int evalue - evalue parameter of TOMTOM run (accepable values are "0" and "1")
string dist - value of dist parameter of TOMTOM run (accepable values are "allr", "ed", "kullback", "pearson", "sandelin")
int internal - internal parameter of TOMTOM run (accepable values are "0" and "1")
int min_overlap - value of min-overlap parameter of TOMTOM run. In case a query motif is smaller than minOverlapTomtom specified, then the motif's width is used as the minimum overlap for that query.

@optional query_ref target_ref pspm_id thresh evalue dist internal min_overlap


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
query_ref has a value which is a MEME.meme_pspm_collection_ref
target_ref has a value which is a MEME.meme_pspm_collection_ref
pspm_id has a value which is a string
thresh has a value which is a float
evalue has a value which is an int
dist has a value which is a string
internal has a value which is an int
min_overlap has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
query_ref has a value which is a MEME.meme_pspm_collection_ref
target_ref has a value which is a MEME.meme_pspm_collection_ref
pspm_id has a value which is a string
thresh has a value which is a float
evalue has a value which is an int
dist has a value which is a string
internal has a value which is an int
min_overlap has a value which is an int


=end text

=back



=head2 TomtomHit

=over 4



=item Description

Represents a particluar TOMTOM hit
string query_pspm_id - id of query MemePSPM
string target_pspm_id - id of target MemePSPM
int optimal_offset - Optimal offset: the offset between the query and the target motif
float pvalue - p-value
float evalue - E-value
float qvalue - q-value
int overlap - Overlap: the number of positions of overlap between the two motifs.
string query_consensus - Query consensus sequence.
string target_consensus - Target consensus sequence.
string strand - Orientation: Orientation of target motif with respect to query motif.

@optional optimal_offset pvalue evalue qvalue overlap query_consensus target_consensus strand


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
query_pspm_id has a value which is a string
target_pspm_id has a value which is a string
optimal_offset has a value which is an int
pvalue has a value which is a float
evalue has a value which is a float
qvalue has a value which is a float
overlap has a value which is an int
query_consensus has a value which is a string
target_consensus has a value which is a string
strand has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
query_pspm_id has a value which is a string
target_pspm_id has a value which is a string
optimal_offset has a value which is an int
pvalue has a value which is a float
evalue has a value which is a float
qvalue has a value which is a float
overlap has a value which is an int
query_consensus has a value which is a string
target_consensus has a value which is a string
strand has a value which is a string


=end text

=back



=head2 TomtomRunResult

=over 4



=item Description

Represents result of a single TOMTOM run
string id - KBase ID of TomtomRunResult
string timestamp - timestamp for creation time of TomtomRunResult
TomtomRunParameters params - run parameters
list<TomtomHit> hits - A list of all hits found by TOMTOM

@optional timestamp hits


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
timestamp has a value which is a string
params has a value which is a MEME.TomtomRunParameters
hits has a value which is a reference to a list where each element is a MEME.TomtomHit

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
timestamp has a value which is a string
params has a value which is a MEME.TomtomRunParameters
hits has a value which is a reference to a list where each element is a MEME.TomtomHit


=end text

=back



=head2 MastRunParameters

=over 4



=item Description

Contains parameters of a MAST run
meme_pspm_collection_ref query_ref - query motifs for MAST run
sequence_set_ref target_ref - target sequences for MAST run
string pspm_id - KBase ID of a MemePSPM from the query collection that will be used. When empty string provided, all motifs in the query collection will be used
float mt - value of mt parameter for MAST run

@optional query_ref target_ref pspm_id mt


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
query_ref has a value which is a MEME.meme_pspm_collection_ref
target_ref has a value which is a MEME.sequence_set_ref
pspm_id has a value which is a string
mt has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
query_ref has a value which is a MEME.meme_pspm_collection_ref
target_ref has a value which is a MEME.sequence_set_ref
pspm_id has a value which is a string
mt has a value which is a float


=end text

=back



=head2 MastHit

=over 4



=item Description

Represents a particluar MAST hit
string seq_id - name of sequence
string strand - strand ("+" or "-")
string pspm_id - id of MemePSPM
int hit_start - start position of hit
int hit_end - end position of hit
float score - hit score
float hitPvalue - hit p-value

@optional strand hit_start hit_end score hit_pvalue


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
seq_id has a value which is a string
pspm_id has a value which is a string
strand has a value which is a string
hit_start has a value which is an int
hit_end has a value which is an int
score has a value which is a float
hit_pvalue has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
seq_id has a value which is a string
pspm_id has a value which is a string
strand has a value which is a string
hit_start has a value which is an int
hit_end has a value which is an int
score has a value which is a float
hit_pvalue has a value which is a float


=end text

=back



=head2 MastRunResult

=over 4



=item Description

Represents result of a single MAST run
string id - KBase ID of MastRunResult
string timestamp - timestamp for creation time of MastRunResult
MastRunParameters params - run parameters
list<MastHit> hits - A list of all hits found by MAST

@optional timestamp hits


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
timestamp has a value which is a string
params has a value which is a MEME.MastRunParameters
hits has a value which is a reference to a list where each element is a MEME.MastHit

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
timestamp has a value which is a string
params has a value which is a MEME.MastRunParameters
hits has a value which is a reference to a list where each element is a MEME.MastHit


=end text

=back



=cut

package Bio::KBase::meme::Client::RpcClient;
use base 'JSON::RPC::Client';

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $obj) = @_;
    my $result;

    if ($uri =~ /\?/) {
       $result = $self->_get($uri);
    }
    else {
        Carp::croak "not hashref." unless (ref $obj eq 'HASH');
        $result = $self->_post($uri, $obj);
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
    my ($self, $uri, $obj) = @_;
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
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
