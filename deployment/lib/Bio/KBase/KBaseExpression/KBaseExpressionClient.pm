package Bio::KBase::KBaseExpression::KBaseExpressionClient;

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

Bio::KBase::KBaseExpression::KBaseExpressionClient

=head1 DESCRIPTION


Service for all different sorts of Expression data (microarray, RNA_seq, proteomics, qPCR


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => Bio::KBase::KBaseExpression::KBaseExpressionClient::RpcClient->new,
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




=head2 get_expression_samples_data

  $expression_data_samples_map = $obj->get_expression_samples_data($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is a sample_ids
$expression_data_samples_map is an expression_data_samples_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$sample_ids is a sample_ids
$expression_data_samples_map is an expression_data_samples_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float


=end text

=item Description

core function used by many others.  Given a list of KBase SampleIds returns mapping of SampleId to expressionSampleDataStructure (essentially the core Expression Sample Object) : 
{sample_id -> expressionSampleDataStructure}

=back

=cut

sub get_expression_samples_data
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_data (received $n, expecting 1)");
    }
    {
	my($sample_ids) = @args;

	my @_bad_arguments;
        (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"sample_ids\" (value was \"$sample_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_data:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_data');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_data",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_data',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_data",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_data',
				       );
    }
}



=head2 get_expression_data_by_samples_and_features

  $label_data_mapping = $obj->get_expression_data_by_samples_and_features($sample_ids, $feature_ids, $numerical_interpretation)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is a sample_ids
$feature_ids is a feature_ids
$numerical_interpretation is a string
$label_data_mapping is a label_data_mapping
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
feature_ids is a reference to a list where each element is a feature_id
feature_id is a string
label_data_mapping is a reference to a hash where the key is a string and the value is a data_expression_levels_for_sample
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
measurement is a float

</pre>

=end html

=begin text

$sample_ids is a sample_ids
$feature_ids is a feature_ids
$numerical_interpretation is a string
$label_data_mapping is a label_data_mapping
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
feature_ids is a reference to a list where each element is a feature_id
feature_id is a string
label_data_mapping is a reference to a hash where the key is a string and the value is a data_expression_levels_for_sample
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
measurement is a float


=end text

=item Description

given a list of sample ids and feature ids and the string of what type of numerical interpretation it returns a LabelDataMapping {sampleID}->{featureId => value}}. 
If sample id list is an empty array [], all samples with that feature measurment values will be returned.
If feature list is an empty array [], all features with measurment values will be returned. 
Both sample id list and feature list can not be empty, one of them must have a value.
Numerical_interpretation options : 'FPKM', 'Log2 level intensities', 'Log2 level ratios' or 'Log2 level ratios genomic DNA control'

=back

=cut

sub get_expression_data_by_samples_and_features
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_data_by_samples_and_features (received $n, expecting 3)");
    }
    {
	my($sample_ids, $feature_ids, $numerical_interpretation) = @args;

	my @_bad_arguments;
        (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"sample_ids\" (value was \"$sample_ids\")");
        (ref($feature_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"feature_ids\" (value was \"$feature_ids\")");
        (!ref($numerical_interpretation)) or push(@_bad_arguments, "Invalid type for argument 3 \"numerical_interpretation\" (value was \"$numerical_interpretation\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_data_by_samples_and_features:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_data_by_samples_and_features');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_data_by_samples_and_features",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_data_by_samples_and_features',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_data_by_samples_and_features",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_data_by_samples_and_features',
				       );
    }
}



=head2 get_expression_samples_data_by_series_ids

  $series_expression_data_samples_mapping = $obj->get_expression_samples_data_by_series_ids($series_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$series_ids is a series_ids
$series_expression_data_samples_mapping is a series_expression_data_samples_mapping
series_ids is a reference to a list where each element is a series_id
series_id is a string
series_expression_data_samples_mapping is a reference to a hash where the key is a series_id and the value is an expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$series_ids is a series_ids
$series_expression_data_samples_mapping is a series_expression_data_samples_mapping
series_ids is a reference to a list where each element is a series_id
series_id is a string
series_expression_data_samples_mapping is a reference to a hash where the key is a series_id and the value is an expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float


=end text

=item Description

given a list of SeriesIDs returns mapping of SeriesID to expressionDataSamples : {series_id -> {sample_id -> expressionSampleDataStructure}}

=back

=cut

sub get_expression_samples_data_by_series_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_data_by_series_ids (received $n, expecting 1)");
    }
    {
	my($series_ids) = @args;

	my @_bad_arguments;
        (ref($series_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"series_ids\" (value was \"$series_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_data_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_data_by_series_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_data_by_series_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_data_by_series_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_data_by_series_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_data_by_series_ids',
				       );
    }
}



=head2 get_expression_sample_ids_by_series_ids

  $sample_ids = $obj->get_expression_sample_ids_by_series_ids($series_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$series_ids is a series_ids
$sample_ids is a sample_ids
series_ids is a reference to a list where each element is a series_id
series_id is a string
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string

</pre>

=end html

=begin text

$series_ids is a series_ids
$sample_ids is a sample_ids
series_ids is a reference to a list where each element is a series_id
series_id is a string
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string


=end text

=item Description

given a list of SeriesIDs returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_series_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_sample_ids_by_series_ids (received $n, expecting 1)");
    }
    {
	my($series_ids) = @args;

	my @_bad_arguments;
        (ref($series_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"series_ids\" (value was \"$series_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_sample_ids_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_sample_ids_by_series_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_sample_ids_by_series_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_sample_ids_by_series_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_sample_ids_by_series_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_sample_ids_by_series_ids',
				       );
    }
}



=head2 get_expression_samples_data_by_experimental_unit_ids

  $experimental_unit_expression_data_samples_mapping = $obj->get_expression_samples_data_by_experimental_unit_ids($experimental_unit_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$experimental_unit_ids is an experimental_unit_ids
$experimental_unit_expression_data_samples_mapping is an experimental_unit_expression_data_samples_mapping
experimental_unit_ids is a reference to a list where each element is an experimental_unit_id
experimental_unit_id is a string
experimental_unit_expression_data_samples_mapping is a reference to a hash where the key is an experimental_unit_id and the value is an expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$experimental_unit_ids is an experimental_unit_ids
$experimental_unit_expression_data_samples_mapping is an experimental_unit_expression_data_samples_mapping
experimental_unit_ids is a reference to a list where each element is an experimental_unit_id
experimental_unit_id is a string
experimental_unit_expression_data_samples_mapping is a reference to a hash where the key is an experimental_unit_id and the value is an expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float


=end text

=item Description

given a list of ExperimentalUnitIDs returns mapping of ExperimentalUnitID to expressionDataSamples : {experimental_unit_id -> {sample_id -> expressionSampleDataStructure}}

=back

=cut

sub get_expression_samples_data_by_experimental_unit_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_data_by_experimental_unit_ids (received $n, expecting 1)");
    }
    {
	my($experimental_unit_ids) = @args;

	my @_bad_arguments;
        (ref($experimental_unit_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"experimental_unit_ids\" (value was \"$experimental_unit_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_data_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_data_by_experimental_unit_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_data_by_experimental_unit_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_data_by_experimental_unit_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_data_by_experimental_unit_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_data_by_experimental_unit_ids',
				       );
    }
}



=head2 get_expression_sample_ids_by_experimental_unit_ids

  $sample_ids = $obj->get_expression_sample_ids_by_experimental_unit_ids($experimental_unit_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$experimental_unit_ids is an experimental_unit_ids
$sample_ids is a sample_ids
experimental_unit_ids is a reference to a list where each element is an experimental_unit_id
experimental_unit_id is a string
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string

</pre>

=end html

=begin text

$experimental_unit_ids is an experimental_unit_ids
$sample_ids is a sample_ids
experimental_unit_ids is a reference to a list where each element is an experimental_unit_id
experimental_unit_id is a string
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string


=end text

=item Description

given a list of ExperimentalUnitIDs returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_experimental_unit_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_sample_ids_by_experimental_unit_ids (received $n, expecting 1)");
    }
    {
	my($experimental_unit_ids) = @args;

	my @_bad_arguments;
        (ref($experimental_unit_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"experimental_unit_ids\" (value was \"$experimental_unit_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_sample_ids_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_sample_ids_by_experimental_unit_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_sample_ids_by_experimental_unit_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_sample_ids_by_experimental_unit_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_sample_ids_by_experimental_unit_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_sample_ids_by_experimental_unit_ids',
				       );
    }
}



=head2 get_expression_samples_data_by_experiment_meta_ids

  $experiment_meta_expression_data_samples_mapping = $obj->get_expression_samples_data_by_experiment_meta_ids($experiment_meta_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$experiment_meta_ids is an experiment_meta_ids
$experiment_meta_expression_data_samples_mapping is an experiment_meta_expression_data_samples_mapping
experiment_meta_ids is a reference to a list where each element is an experiment_meta_id
experiment_meta_id is a string
experiment_meta_expression_data_samples_mapping is a reference to a hash where the key is an experiment_meta_id and the value is an experimental_unit_expression_data_samples_mapping
experimental_unit_expression_data_samples_mapping is a reference to a hash where the key is an experimental_unit_id and the value is an expression_data_samples_map
experimental_unit_id is a string
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$experiment_meta_ids is an experiment_meta_ids
$experiment_meta_expression_data_samples_mapping is an experiment_meta_expression_data_samples_mapping
experiment_meta_ids is a reference to a list where each element is an experiment_meta_id
experiment_meta_id is a string
experiment_meta_expression_data_samples_mapping is a reference to a hash where the key is an experiment_meta_id and the value is an experimental_unit_expression_data_samples_mapping
experimental_unit_expression_data_samples_mapping is a reference to a hash where the key is an experimental_unit_id and the value is an expression_data_samples_map
experimental_unit_id is a string
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float


=end text

=item Description

given a list of ExperimentMetaIDs returns mapping of {experimentMetaID -> {experimentalUnitId -> {sample_id -> expressionSampleDataStructure}}}

=back

=cut

sub get_expression_samples_data_by_experiment_meta_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_data_by_experiment_meta_ids (received $n, expecting 1)");
    }
    {
	my($experiment_meta_ids) = @args;

	my @_bad_arguments;
        (ref($experiment_meta_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"experiment_meta_ids\" (value was \"$experiment_meta_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_data_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_data_by_experiment_meta_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_data_by_experiment_meta_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_data_by_experiment_meta_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_data_by_experiment_meta_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_data_by_experiment_meta_ids',
				       );
    }
}



=head2 get_expression_sample_ids_by_experiment_meta_ids

  $sample_ids = $obj->get_expression_sample_ids_by_experiment_meta_ids($experiment_meta_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$experiment_meta_ids is an experiment_meta_ids
$sample_ids is a sample_ids
experiment_meta_ids is a reference to a list where each element is an experiment_meta_id
experiment_meta_id is a string
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string

</pre>

=end html

=begin text

$experiment_meta_ids is an experiment_meta_ids
$sample_ids is a sample_ids
experiment_meta_ids is a reference to a list where each element is an experiment_meta_id
experiment_meta_id is a string
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string


=end text

=item Description

given a list of ExperimentMetaIDs returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_experiment_meta_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_sample_ids_by_experiment_meta_ids (received $n, expecting 1)");
    }
    {
	my($experiment_meta_ids) = @args;

	my @_bad_arguments;
        (ref($experiment_meta_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"experiment_meta_ids\" (value was \"$experiment_meta_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_sample_ids_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_sample_ids_by_experiment_meta_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_sample_ids_by_experiment_meta_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_sample_ids_by_experiment_meta_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_sample_ids_by_experiment_meta_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_sample_ids_by_experiment_meta_ids',
				       );
    }
}



=head2 get_expression_samples_data_by_strain_ids

  $strain_expression_data_samples_mapping = $obj->get_expression_samples_data_by_strain_ids($strain_ids, $sample_type)

=over 4

=item Parameter and return types

=begin html

<pre>
$strain_ids is a strain_ids
$sample_type is a sample_type
$strain_expression_data_samples_mapping is a strain_expression_data_samples_mapping
strain_ids is a reference to a list where each element is a strain_id
strain_id is a string
sample_type is a string
strain_expression_data_samples_mapping is a reference to a hash where the key is a strain_id and the value is an expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
genome_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$strain_ids is a strain_ids
$sample_type is a sample_type
$strain_expression_data_samples_mapping is a strain_expression_data_samples_mapping
strain_ids is a reference to a list where each element is a strain_id
strain_id is a string
sample_type is a string
strain_expression_data_samples_mapping is a reference to a hash where the key is a strain_id and the value is an expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
genome_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float


=end text

=item Description

given a list of Strains, and a SampleType (controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) , it returns a StrainExpressionDataSamplesMapping,  
StrainId -> ExpressionSampleDataStructure {strain_id -> {sample_id -> expressionSampleDataStructure}}

=back

=cut

sub get_expression_samples_data_by_strain_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_data_by_strain_ids (received $n, expecting 2)");
    }
    {
	my($strain_ids, $sample_type) = @args;

	my @_bad_arguments;
        (ref($strain_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"strain_ids\" (value was \"$strain_ids\")");
        (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument 2 \"sample_type\" (value was \"$sample_type\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_data_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_data_by_strain_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_data_by_strain_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_data_by_strain_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_data_by_strain_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_data_by_strain_ids',
				       );
    }
}



=head2 get_expression_sample_ids_by_strain_ids

  $sample_ids = $obj->get_expression_sample_ids_by_strain_ids($strain_ids, $sample_type)

=over 4

=item Parameter and return types

=begin html

<pre>
$strain_ids is a strain_ids
$sample_type is a sample_type
$sample_ids is a sample_ids
strain_ids is a reference to a list where each element is a strain_id
strain_id is a string
sample_type is a string
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string

</pre>

=end html

=begin text

$strain_ids is a strain_ids
$sample_type is a sample_type
$sample_ids is a sample_ids
strain_ids is a reference to a list where each element is a strain_id
strain_id is a string
sample_type is a string
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string


=end text

=item Description

given a list of Strains, and a SampleType, it returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_strain_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_sample_ids_by_strain_ids (received $n, expecting 2)");
    }
    {
	my($strain_ids, $sample_type) = @args;

	my @_bad_arguments;
        (ref($strain_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"strain_ids\" (value was \"$strain_ids\")");
        (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument 2 \"sample_type\" (value was \"$sample_type\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_sample_ids_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_sample_ids_by_strain_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_sample_ids_by_strain_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_sample_ids_by_strain_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_sample_ids_by_strain_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_sample_ids_by_strain_ids',
				       );
    }
}



=head2 get_expression_samples_data_by_genome_ids

  $genome_expression_data_samples_mapping = $obj->get_expression_samples_data_by_genome_ids($genome_ids, $sample_type, $wild_type_only)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_ids is a genome_ids
$sample_type is a sample_type
$wild_type_only is a wild_type_only
$genome_expression_data_samples_mapping is a genome_expression_data_samples_mapping
genome_ids is a reference to a list where each element is a genome_id
genome_id is a string
sample_type is a string
wild_type_only is an int
genome_expression_data_samples_mapping is a reference to a hash where the key is a genome_id and the value is a strain_expression_data_samples_mapping
strain_expression_data_samples_mapping is a reference to a hash where the key is a strain_id and the value is an expression_data_samples_map
strain_id is a string
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$genome_ids is a genome_ids
$sample_type is a sample_type
$wild_type_only is a wild_type_only
$genome_expression_data_samples_mapping is a genome_expression_data_samples_mapping
genome_ids is a reference to a list where each element is a genome_id
genome_id is a string
sample_type is a string
wild_type_only is an int
genome_expression_data_samples_mapping is a reference to a hash where the key is a genome_id and the value is a strain_expression_data_samples_mapping
strain_expression_data_samples_mapping is a reference to a hash where the key is a strain_id and the value is an expression_data_samples_map
strain_id is a string
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float


=end text

=item Description

given a list of Genomes, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
and a int indicating WildTypeOnly (1 = true, 0 = false) , it returns a GenomeExpressionDataSamplesMapping   ,  
GenomeId -> StrainId -> ExpressionDataSample.  StrainId -> ExpressionSampleDataStructure {genome_id -> {strain_id -> {sample_id -> expressionSampleDataStructure}}}

=back

=cut

sub get_expression_samples_data_by_genome_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_data_by_genome_ids (received $n, expecting 3)");
    }
    {
	my($genome_ids, $sample_type, $wild_type_only) = @args;

	my @_bad_arguments;
        (ref($genome_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_ids\" (value was \"$genome_ids\")");
        (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument 2 \"sample_type\" (value was \"$sample_type\")");
        (!ref($wild_type_only)) or push(@_bad_arguments, "Invalid type for argument 3 \"wild_type_only\" (value was \"$wild_type_only\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_data_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_data_by_genome_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_data_by_genome_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_data_by_genome_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_data_by_genome_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_data_by_genome_ids',
				       );
    }
}



=head2 get_expression_sample_ids_by_genome_ids

  $sample_ids = $obj->get_expression_sample_ids_by_genome_ids($genome_ids, $sample_type, $wild_type_only)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_ids is a genome_ids
$sample_type is a sample_type
$wild_type_only is a wild_type_only
$sample_ids is a sample_ids
genome_ids is a reference to a list where each element is a genome_id
genome_id is a string
sample_type is a string
wild_type_only is an int
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string

</pre>

=end html

=begin text

$genome_ids is a genome_ids
$sample_type is a sample_type
$wild_type_only is a wild_type_only
$sample_ids is a sample_ids
genome_ids is a reference to a list where each element is a genome_id
genome_id is a string
sample_type is a string
wild_type_only is an int
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string


=end text

=item Description

given a list of GenomeIDs, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
and a int indicating WildType Only (1 = true, 0 = false) , it returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_genome_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_sample_ids_by_genome_ids (received $n, expecting 3)");
    }
    {
	my($genome_ids, $sample_type, $wild_type_only) = @args;

	my @_bad_arguments;
        (ref($genome_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_ids\" (value was \"$genome_ids\")");
        (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument 2 \"sample_type\" (value was \"$sample_type\")");
        (!ref($wild_type_only)) or push(@_bad_arguments, "Invalid type for argument 3 \"wild_type_only\" (value was \"$wild_type_only\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_sample_ids_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_sample_ids_by_genome_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_sample_ids_by_genome_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_sample_ids_by_genome_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_sample_ids_by_genome_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_sample_ids_by_genome_ids',
				       );
    }
}



=head2 get_expression_samples_data_by_ontology_ids

  $ontology_expression_data_sample_mapping = $obj->get_expression_samples_data_by_ontology_ids($ontology_ids, $and_or, $genome_id, $sample_type, $wild_type_only)

=over 4

=item Parameter and return types

=begin html

<pre>
$ontology_ids is an ontology_ids
$and_or is a string
$genome_id is a genome_id
$sample_type is a sample_type
$wild_type_only is a wild_type_only
$ontology_expression_data_sample_mapping is an ontology_expression_data_sample_mapping
ontology_ids is a reference to a list where each element is an ontology_id
ontology_id is a string
genome_id is a string
sample_type is a string
wild_type_only is an int
ontology_expression_data_sample_mapping is a reference to a hash where the key is an ontology_id and the value is an expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
strain_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$ontology_ids is an ontology_ids
$and_or is a string
$genome_id is a genome_id
$sample_type is a sample_type
$wild_type_only is a wild_type_only
$ontology_expression_data_sample_mapping is an ontology_expression_data_sample_mapping
ontology_ids is a reference to a list where each element is an ontology_id
ontology_id is a string
genome_id is a string
sample_type is a string
wild_type_only is an int
ontology_expression_data_sample_mapping is a reference to a hash where the key is an ontology_id and the value is an expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is a sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is a sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is a strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is a genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an experimental_unit_id
	experiment_meta_id has a value which is an experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is a sample_annotations
	series_ids has a value which is a series_ids
	person_ids has a value which is a person_ids
	sample_ids_averaged_from has a value which is a sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample
strain_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is a sample_annotation_id
	ontology_id has a value which is an ontology_id
	ontology_name has a value which is an ontology_name
	ontology_definition has a value which is an ontology_definition
sample_annotation_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string
person_ids is a reference to a list where each element is a person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is a sample_id
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float


=end text

=item Description

given a list of ontologyIDs, AndOr operator (and requires sample to have all ontology IDs, or sample has to have any of the terms), GenomeId, 
SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics), wildTypeOnly returns OntologyID(concatenated if Anded) -> ExpressionDataSample

=back

=cut

sub get_expression_samples_data_by_ontology_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 5)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_data_by_ontology_ids (received $n, expecting 5)");
    }
    {
	my($ontology_ids, $and_or, $genome_id, $sample_type, $wild_type_only) = @args;

	my @_bad_arguments;
        (ref($ontology_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"ontology_ids\" (value was \"$ontology_ids\")");
        (!ref($and_or)) or push(@_bad_arguments, "Invalid type for argument 2 \"and_or\" (value was \"$and_or\")");
        (!ref($genome_id)) or push(@_bad_arguments, "Invalid type for argument 3 \"genome_id\" (value was \"$genome_id\")");
        (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument 4 \"sample_type\" (value was \"$sample_type\")");
        (!ref($wild_type_only)) or push(@_bad_arguments, "Invalid type for argument 5 \"wild_type_only\" (value was \"$wild_type_only\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_data_by_ontology_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_data_by_ontology_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_data_by_ontology_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_data_by_ontology_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_data_by_ontology_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_data_by_ontology_ids',
				       );
    }
}



=head2 get_expression_sample_ids_by_ontology_ids

  $sample_ids = $obj->get_expression_sample_ids_by_ontology_ids($ontology_ids, $and_or, $genome_id, $sample_type, $wild_type_only)

=over 4

=item Parameter and return types

=begin html

<pre>
$ontology_ids is an ontology_ids
$and_or is a string
$genome_id is a genome_id
$sample_type is a sample_type
$wild_type_only is a wild_type_only
$sample_ids is a sample_ids
ontology_ids is a reference to a list where each element is an ontology_id
ontology_id is a string
genome_id is a string
sample_type is a string
wild_type_only is an int
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string

</pre>

=end html

=begin text

$ontology_ids is an ontology_ids
$and_or is a string
$genome_id is a genome_id
$sample_type is a sample_type
$wild_type_only is a wild_type_only
$sample_ids is a sample_ids
ontology_ids is a reference to a list where each element is an ontology_id
ontology_id is a string
genome_id is a string
sample_type is a string
wild_type_only is an int
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string


=end text

=item Description

given a list of ontologyIDs, AndOr operator (and requires sample to have all ontology IDs, or sample has to have any of the terms), GenomeId, 
SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics), wildTypeOnly returns a list of SampleIDs

=back

=cut

sub get_expression_sample_ids_by_ontology_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 5)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_sample_ids_by_ontology_ids (received $n, expecting 5)");
    }
    {
	my($ontology_ids, $and_or, $genome_id, $sample_type, $wild_type_only) = @args;

	my @_bad_arguments;
        (ref($ontology_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"ontology_ids\" (value was \"$ontology_ids\")");
        (!ref($and_or)) or push(@_bad_arguments, "Invalid type for argument 2 \"and_or\" (value was \"$and_or\")");
        (!ref($genome_id)) or push(@_bad_arguments, "Invalid type for argument 3 \"genome_id\" (value was \"$genome_id\")");
        (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument 4 \"sample_type\" (value was \"$sample_type\")");
        (!ref($wild_type_only)) or push(@_bad_arguments, "Invalid type for argument 5 \"wild_type_only\" (value was \"$wild_type_only\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_sample_ids_by_ontology_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_sample_ids_by_ontology_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_sample_ids_by_ontology_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_sample_ids_by_ontology_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_sample_ids_by_ontology_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_sample_ids_by_ontology_ids',
				       );
    }
}



=head2 get_expression_data_by_feature_ids

  $feature_sample_measurement_mapping = $obj->get_expression_data_by_feature_ids($feature_ids, $sample_type, $wild_type_only)

=over 4

=item Parameter and return types

=begin html

<pre>
$feature_ids is a feature_ids
$sample_type is a sample_type
$wild_type_only is a wild_type_only
$feature_sample_measurement_mapping is a feature_sample_measurement_mapping
feature_ids is a reference to a list where each element is a feature_id
feature_id is a string
sample_type is a string
wild_type_only is an int
feature_sample_measurement_mapping is a reference to a hash where the key is a feature_id and the value is a sample_measurement_mapping
sample_measurement_mapping is a reference to a hash where the key is a sample_id and the value is a measurement
sample_id is a string
measurement is a float

</pre>

=end html

=begin text

$feature_ids is a feature_ids
$sample_type is a sample_type
$wild_type_only is a wild_type_only
$feature_sample_measurement_mapping is a feature_sample_measurement_mapping
feature_ids is a reference to a list where each element is a feature_id
feature_id is a string
sample_type is a string
wild_type_only is an int
feature_sample_measurement_mapping is a reference to a hash where the key is a feature_id and the value is a sample_measurement_mapping
sample_measurement_mapping is a reference to a hash where the key is a sample_id and the value is a measurement
sample_id is a string
measurement is a float


=end text

=item Description

given a list of FeatureIDs, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
and an int indicating WildType Only (1 = true, 0 = false) returns a FeatureSampleMeasurementMapping: {featureID->{sample_id->measurement}}

=back

=cut

sub get_expression_data_by_feature_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_data_by_feature_ids (received $n, expecting 3)");
    }
    {
	my($feature_ids, $sample_type, $wild_type_only) = @args;

	my @_bad_arguments;
        (ref($feature_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"feature_ids\" (value was \"$feature_ids\")");
        (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument 2 \"sample_type\" (value was \"$sample_type\")");
        (!ref($wild_type_only)) or push(@_bad_arguments, "Invalid type for argument 3 \"wild_type_only\" (value was \"$wild_type_only\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_data_by_feature_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_data_by_feature_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_data_by_feature_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_data_by_feature_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_data_by_feature_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_data_by_feature_ids',
				       );
    }
}



=head2 compare_samples

  $sample_comparison_mapping = $obj->compare_samples($numerators_data_mapping, $denominators_data_mapping)

=over 4

=item Parameter and return types

=begin html

<pre>
$numerators_data_mapping is a label_data_mapping
$denominators_data_mapping is a label_data_mapping
$sample_comparison_mapping is a sample_comparison_mapping
label_data_mapping is a reference to a hash where the key is a string and the value is a data_expression_levels_for_sample
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float
sample_comparison_mapping is a reference to a hash where the key is a sample_id and the value is a denominator_sample_comparison
sample_id is a string
denominator_sample_comparison is a reference to a hash where the key is a comparison_denominator_label and the value is a data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is a feature_id and the value is a log2_ratio
log2_ratio is a float

</pre>

=end html

=begin text

$numerators_data_mapping is a label_data_mapping
$denominators_data_mapping is a label_data_mapping
$sample_comparison_mapping is a sample_comparison_mapping
label_data_mapping is a reference to a hash where the key is a string and the value is a data_expression_levels_for_sample
data_expression_levels_for_sample is a reference to a hash where the key is a feature_id and the value is a measurement
feature_id is a string
measurement is a float
sample_comparison_mapping is a reference to a hash where the key is a sample_id and the value is a denominator_sample_comparison
sample_id is a string
denominator_sample_comparison is a reference to a hash where the key is a comparison_denominator_label and the value is a data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is a feature_id and the value is a log2_ratio
log2_ratio is a float


=end text

=item Description

Compare samples takes two data structures labelDataMapping  {sampleID or label}->{featureId or label => value}}, 
the first labelDataMapping is the numerator, the 2nd is the denominator in the comparison. returns a 
SampleComparisonMapping {numerator_sample_id(or label)->{denominator_sample_id(or label)->{feature_id(or label) -> log2Ratio}}}

=back

=cut

sub compare_samples
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_samples (received $n, expecting 2)");
    }
    {
	my($numerators_data_mapping, $denominators_data_mapping) = @args;

	my @_bad_arguments;
        (ref($numerators_data_mapping) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"numerators_data_mapping\" (value was \"$numerators_data_mapping\")");
        (ref($denominators_data_mapping) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"denominators_data_mapping\" (value was \"$denominators_data_mapping\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_samples:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_samples');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.compare_samples",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_samples',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_samples",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_samples',
				       );
    }
}



=head2 compare_samples_vs_default_controls

  $sample_comparison_mapping = $obj->compare_samples_vs_default_controls($numerator_sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$numerator_sample_ids is a sample_ids
$sample_comparison_mapping is a sample_comparison_mapping
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
sample_comparison_mapping is a reference to a hash where the key is a sample_id and the value is a denominator_sample_comparison
denominator_sample_comparison is a reference to a hash where the key is a comparison_denominator_label and the value is a data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is a feature_id and the value is a log2_ratio
feature_id is a string
log2_ratio is a float

</pre>

=end html

=begin text

$numerator_sample_ids is a sample_ids
$sample_comparison_mapping is a sample_comparison_mapping
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
sample_comparison_mapping is a reference to a hash where the key is a sample_id and the value is a denominator_sample_comparison
denominator_sample_comparison is a reference to a hash where the key is a comparison_denominator_label and the value is a data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is a feature_id and the value is a log2_ratio
feature_id is a string
log2_ratio is a float


=end text

=item Description

Compares each sample vs its defined default control.  If the Default control is not specified for a sample, then nothing is returned for that sample .
Takes a list of sampleIDs returns SampleComparisonMapping {sample_id ->{denominator_default_control sample_id ->{feature_id -> log2Ratio}}}

=back

=cut

sub compare_samples_vs_default_controls
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_samples_vs_default_controls (received $n, expecting 1)");
    }
    {
	my($numerator_sample_ids) = @args;

	my @_bad_arguments;
        (ref($numerator_sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"numerator_sample_ids\" (value was \"$numerator_sample_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_samples_vs_default_controls:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_samples_vs_default_controls');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.compare_samples_vs_default_controls",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_samples_vs_default_controls',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_samples_vs_default_controls",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_samples_vs_default_controls',
				       );
    }
}



=head2 compare_samples_vs_the_average

  $sample_comparison_mapping = $obj->compare_samples_vs_the_average($numerator_sample_ids, $denominator_sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$numerator_sample_ids is a sample_ids
$denominator_sample_ids is a sample_ids
$sample_comparison_mapping is a sample_comparison_mapping
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
sample_comparison_mapping is a reference to a hash where the key is a sample_id and the value is a denominator_sample_comparison
denominator_sample_comparison is a reference to a hash where the key is a comparison_denominator_label and the value is a data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is a feature_id and the value is a log2_ratio
feature_id is a string
log2_ratio is a float

</pre>

=end html

=begin text

$numerator_sample_ids is a sample_ids
$denominator_sample_ids is a sample_ids
$sample_comparison_mapping is a sample_comparison_mapping
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
sample_comparison_mapping is a reference to a hash where the key is a sample_id and the value is a denominator_sample_comparison
denominator_sample_comparison is a reference to a hash where the key is a comparison_denominator_label and the value is a data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is a feature_id and the value is a log2_ratio
feature_id is a string
log2_ratio is a float


=end text

=item Description

Compares each numerator sample vs the average of all the denominator sampleIds.  Take a list of numerator sample IDs and a list of samples Ids to average for the denominator.
returns SampleComparisonMapping {numerator_sample_id->{denominator_sample_id ->{feature_id -> log2Ratio}}}

=back

=cut

sub compare_samples_vs_the_average
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_samples_vs_the_average (received $n, expecting 2)");
    }
    {
	my($numerator_sample_ids, $denominator_sample_ids) = @args;

	my @_bad_arguments;
        (ref($numerator_sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"numerator_sample_ids\" (value was \"$numerator_sample_ids\")");
        (ref($denominator_sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"denominator_sample_ids\" (value was \"$denominator_sample_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_samples_vs_the_average:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_samples_vs_the_average');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.compare_samples_vs_the_average",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_samples_vs_the_average',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_samples_vs_the_average",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_samples_vs_the_average',
				       );
    }
}



=head2 get_on_off_calls

  $on_off_mappings = $obj->get_on_off_calls($sample_comparison_mapping, $off_threshold, $on_threshold)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_comparison_mapping is a sample_comparison_mapping
$off_threshold is a float
$on_threshold is a float
$on_off_mappings is a sample_comparison_mapping
sample_comparison_mapping is a reference to a hash where the key is a sample_id and the value is a denominator_sample_comparison
sample_id is a string
denominator_sample_comparison is a reference to a hash where the key is a comparison_denominator_label and the value is a data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is a feature_id and the value is a log2_ratio
feature_id is a string
log2_ratio is a float

</pre>

=end html

=begin text

$sample_comparison_mapping is a sample_comparison_mapping
$off_threshold is a float
$on_threshold is a float
$on_off_mappings is a sample_comparison_mapping
sample_comparison_mapping is a reference to a hash where the key is a sample_id and the value is a denominator_sample_comparison
sample_id is a string
denominator_sample_comparison is a reference to a hash where the key is a comparison_denominator_label and the value is a data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is a feature_id and the value is a log2_ratio
feature_id is a string
log2_ratio is a float


=end text

=item Description

Takes in comparison results.  If the value is >= on_threshold it is deemed on (1), if <= off_threshold it is off(-1), meets none then 0.  Thresholds normally set to zero.
returns SampleComparisonMapping {numerator_sample_id(or label)->{denominator_sample_id(or label)->{feature_id(or label) -> on_off_call (possible values 0,-1,1)}}}

=back

=cut

sub get_on_off_calls
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_on_off_calls (received $n, expecting 3)");
    }
    {
	my($sample_comparison_mapping, $off_threshold, $on_threshold) = @args;

	my @_bad_arguments;
        (ref($sample_comparison_mapping) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"sample_comparison_mapping\" (value was \"$sample_comparison_mapping\")");
        (!ref($off_threshold)) or push(@_bad_arguments, "Invalid type for argument 2 \"off_threshold\" (value was \"$off_threshold\")");
        (!ref($on_threshold)) or push(@_bad_arguments, "Invalid type for argument 3 \"on_threshold\" (value was \"$on_threshold\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_on_off_calls:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_on_off_calls');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_on_off_calls",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_on_off_calls',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_on_off_calls",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_on_off_calls',
				       );
    }
}



=head2 get_top_changers

  $top_changers_mappings = $obj->get_top_changers($sample_comparison_mapping, $direction, $count)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_comparison_mapping is a sample_comparison_mapping
$direction is a string
$count is an int
$top_changers_mappings is a sample_comparison_mapping
sample_comparison_mapping is a reference to a hash where the key is a sample_id and the value is a denominator_sample_comparison
sample_id is a string
denominator_sample_comparison is a reference to a hash where the key is a comparison_denominator_label and the value is a data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is a feature_id and the value is a log2_ratio
feature_id is a string
log2_ratio is a float

</pre>

=end html

=begin text

$sample_comparison_mapping is a sample_comparison_mapping
$direction is a string
$count is an int
$top_changers_mappings is a sample_comparison_mapping
sample_comparison_mapping is a reference to a hash where the key is a sample_id and the value is a denominator_sample_comparison
sample_id is a string
denominator_sample_comparison is a reference to a hash where the key is a comparison_denominator_label and the value is a data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is a feature_id and the value is a log2_ratio
feature_id is a string
log2_ratio is a float


=end text

=item Description

Takes in comparison results. Direction must equal 'up', 'down', or 'both'.  Count is the number of changers returned in each direction.
returns SampleComparisonMapping {numerator_sample_id(or label)->{denominator_sample_id(or label)->{feature_id(or label) -> log2Ratio (note that the features listed will be limited to the top changers)}}}

=back

=cut

sub get_top_changers
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_top_changers (received $n, expecting 3)");
    }
    {
	my($sample_comparison_mapping, $direction, $count) = @args;

	my @_bad_arguments;
        (ref($sample_comparison_mapping) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"sample_comparison_mapping\" (value was \"$sample_comparison_mapping\")");
        (!ref($direction)) or push(@_bad_arguments, "Invalid type for argument 2 \"direction\" (value was \"$direction\")");
        (!ref($count)) or push(@_bad_arguments, "Invalid type for argument 3 \"count\" (value was \"$count\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_top_changers:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_top_changers');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_top_changers",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_top_changers',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_top_changers",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_top_changers',
				       );
    }
}



=head2 get_expression_samples_titles

  $samples_titles_map = $obj->get_expression_samples_titles($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is a sample_ids
$samples_titles_map is a samples_string_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is a sample_id and the value is a string

</pre>

=end html

=begin text

$sample_ids is a sample_ids
$samples_titles_map is a samples_string_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is a sample_id and the value is a string


=end text

=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: Title of Sample)

=back

=cut

sub get_expression_samples_titles
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_titles (received $n, expecting 1)");
    }
    {
	my($sample_ids) = @args;

	my @_bad_arguments;
        (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"sample_ids\" (value was \"$sample_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_titles:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_titles');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_titles",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_titles',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_titles",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_titles',
				       );
    }
}



=head2 get_expression_samples_descriptions

  $samples_descriptions_map = $obj->get_expression_samples_descriptions($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is a sample_ids
$samples_descriptions_map is a samples_string_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is a sample_id and the value is a string

</pre>

=end html

=begin text

$sample_ids is a sample_ids
$samples_descriptions_map is a samples_string_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is a sample_id and the value is a string


=end text

=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: Description of Sample)

=back

=cut

sub get_expression_samples_descriptions
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_descriptions (received $n, expecting 1)");
    }
    {
	my($sample_ids) = @args;

	my @_bad_arguments;
        (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"sample_ids\" (value was \"$sample_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_descriptions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_descriptions');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_descriptions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_descriptions',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_descriptions",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_descriptions',
				       );
    }
}



=head2 get_expression_samples_molecules

  $samples_molecules_map = $obj->get_expression_samples_molecules($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is a sample_ids
$samples_molecules_map is a samples_string_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is a sample_id and the value is a string

</pre>

=end html

=begin text

$sample_ids is a sample_ids
$samples_molecules_map is a samples_string_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is a sample_id and the value is a string


=end text

=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: Molecule of Sample)

=back

=cut

sub get_expression_samples_molecules
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_molecules (received $n, expecting 1)");
    }
    {
	my($sample_ids) = @args;

	my @_bad_arguments;
        (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"sample_ids\" (value was \"$sample_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_molecules:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_molecules');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_molecules",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_molecules',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_molecules",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_molecules',
				       );
    }
}



=head2 get_expression_samples_types

  $samples_types_map = $obj->get_expression_samples_types($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is a sample_ids
$samples_types_map is a samples_string_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is a sample_id and the value is a string

</pre>

=end html

=begin text

$sample_ids is a sample_ids
$samples_types_map is a samples_string_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is a sample_id and the value is a string


=end text

=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: Type of Sample)

=back

=cut

sub get_expression_samples_types
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_types (received $n, expecting 1)");
    }
    {
	my($sample_ids) = @args;

	my @_bad_arguments;
        (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"sample_ids\" (value was \"$sample_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_types:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_types');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_types",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_types',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_types",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_types',
				       );
    }
}



=head2 get_expression_samples_external_source_ids

  $samples_external_source_id_map = $obj->get_expression_samples_external_source_ids($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is a sample_ids
$samples_external_source_id_map is a samples_string_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is a sample_id and the value is a string

</pre>

=end html

=begin text

$sample_ids is a sample_ids
$samples_external_source_id_map is a samples_string_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is a sample_id and the value is a string


=end text

=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: External_Source_ID of Sample (typically GSM))

=back

=cut

sub get_expression_samples_external_source_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_external_source_ids (received $n, expecting 1)");
    }
    {
	my($sample_ids) = @args;

	my @_bad_arguments;
        (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"sample_ids\" (value was \"$sample_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_external_source_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_external_source_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_external_source_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_external_source_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_external_source_ids',
				       );
    }
}



=head2 get_expression_samples_original_log2_medians

  $samples_float_map = $obj->get_expression_samples_original_log2_medians($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is a sample_ids
$samples_float_map is a samples_float_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
samples_float_map is a reference to a hash where the key is a sample_id and the value is a float

</pre>

=end html

=begin text

$sample_ids is a sample_ids
$samples_float_map is a samples_float_map
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
samples_float_map is a reference to a hash where the key is a sample_id and the value is a float


=end text

=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: OriginalLog2Median of Sample)

=back

=cut

sub get_expression_samples_original_log2_medians
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_samples_original_log2_medians (received $n, expecting 1)");
    }
    {
	my($sample_ids) = @args;

	my @_bad_arguments;
        (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"sample_ids\" (value was \"$sample_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_original_log2_medians:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_original_log2_medians');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_samples_original_log2_medians",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_samples_original_log2_medians',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_samples_original_log2_medians",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_samples_original_log2_medians',
				       );
    }
}



=head2 get_expression_series_titles

  $series_string_map = $obj->get_expression_series_titles($series_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$series_ids is a series_ids
$series_string_map is a series_string_map
series_ids is a reference to a list where each element is a series_id
series_id is a string
series_string_map is a reference to a hash where the key is a series_id and the value is a string

</pre>

=end html

=begin text

$series_ids is a series_ids
$series_string_map is a series_string_map
series_ids is a reference to a list where each element is a series_id
series_id is a string
series_string_map is a reference to a hash where the key is a series_id and the value is a string


=end text

=item Description

given a List of SeriesIDs, returns a Hash (key : SeriesID, value: Title of Series)

=back

=cut

sub get_expression_series_titles
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_series_titles (received $n, expecting 1)");
    }
    {
	my($series_ids) = @args;

	my @_bad_arguments;
        (ref($series_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"series_ids\" (value was \"$series_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_series_titles:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_series_titles');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_series_titles",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_series_titles',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_series_titles",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_series_titles',
				       );
    }
}



=head2 get_expression_series_summaries

  $series_string_map = $obj->get_expression_series_summaries($series_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$series_ids is a series_ids
$series_string_map is a series_string_map
series_ids is a reference to a list where each element is a series_id
series_id is a string
series_string_map is a reference to a hash where the key is a series_id and the value is a string

</pre>

=end html

=begin text

$series_ids is a series_ids
$series_string_map is a series_string_map
series_ids is a reference to a list where each element is a series_id
series_id is a string
series_string_map is a reference to a hash where the key is a series_id and the value is a string


=end text

=item Description

given a List of SeriesIDs, returns a Hash (key : SeriesID, value: Summary of Series)

=back

=cut

sub get_expression_series_summaries
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_series_summaries (received $n, expecting 1)");
    }
    {
	my($series_ids) = @args;

	my @_bad_arguments;
        (ref($series_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"series_ids\" (value was \"$series_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_series_summaries:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_series_summaries');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_series_summaries",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_series_summaries',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_series_summaries",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_series_summaries',
				       );
    }
}



=head2 get_expression_series_designs

  $series_string_map = $obj->get_expression_series_designs($series_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$series_ids is a series_ids
$series_string_map is a series_string_map
series_ids is a reference to a list where each element is a series_id
series_id is a string
series_string_map is a reference to a hash where the key is a series_id and the value is a string

</pre>

=end html

=begin text

$series_ids is a series_ids
$series_string_map is a series_string_map
series_ids is a reference to a list where each element is a series_id
series_id is a string
series_string_map is a reference to a hash where the key is a series_id and the value is a string


=end text

=item Description

given a List of SeriesIDs, returns a Hash (key : SeriesID, value: Design of Series)

=back

=cut

sub get_expression_series_designs
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_series_designs (received $n, expecting 1)");
    }
    {
	my($series_ids) = @args;

	my @_bad_arguments;
        (ref($series_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"series_ids\" (value was \"$series_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_series_designs:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_series_designs');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_series_designs",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_series_designs',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_series_designs",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_series_designs',
				       );
    }
}



=head2 get_expression_series_external_source_ids

  $series_string_map = $obj->get_expression_series_external_source_ids($series_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$series_ids is a series_ids
$series_string_map is a series_string_map
series_ids is a reference to a list where each element is a series_id
series_id is a string
series_string_map is a reference to a hash where the key is a series_id and the value is a string

</pre>

=end html

=begin text

$series_ids is a series_ids
$series_string_map is a series_string_map
series_ids is a reference to a list where each element is a series_id
series_id is a string
series_string_map is a reference to a hash where the key is a series_id and the value is a string


=end text

=item Description

given a List of SeriesIDs, returns a Hash (key : SeriesID, value: External_Source_ID of Series (typically GSE))

=back

=cut

sub get_expression_series_external_source_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_series_external_source_ids (received $n, expecting 1)");
    }
    {
	my($series_ids) = @args;

	my @_bad_arguments;
        (ref($series_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"series_ids\" (value was \"$series_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_series_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_series_external_source_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_series_external_source_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_series_external_source_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_series_external_source_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_series_external_source_ids',
				       );
    }
}



=head2 get_expression_sample_ids_by_sample_external_source_ids

  $sample_ids = $obj->get_expression_sample_ids_by_sample_external_source_ids($external_source_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$external_source_ids is an external_source_ids
$sample_ids is a sample_ids
external_source_ids is a reference to a list where each element is an external_source_id
external_source_id is a string
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string

</pre>

=end html

=begin text

$external_source_ids is an external_source_ids
$sample_ids is a sample_ids
external_source_ids is a reference to a list where each element is an external_source_id
external_source_id is a string
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string


=end text

=item Description

get sample ids by the sample's external source id : Takes a list of sample external source ids, and returns a list of sample ids

=back

=cut

sub get_expression_sample_ids_by_sample_external_source_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_sample_ids_by_sample_external_source_ids (received $n, expecting 1)");
    }
    {
	my($external_source_ids) = @args;

	my @_bad_arguments;
        (ref($external_source_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"external_source_ids\" (value was \"$external_source_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_sample_ids_by_sample_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_sample_ids_by_sample_external_source_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_sample_ids_by_sample_external_source_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_sample_ids_by_sample_external_source_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_sample_ids_by_sample_external_source_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_sample_ids_by_sample_external_source_ids',
				       );
    }
}



=head2 get_expression_sample_ids_by_platform_external_source_ids

  $sample_ids = $obj->get_expression_sample_ids_by_platform_external_source_ids($external_source_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$external_source_ids is an external_source_ids
$sample_ids is a sample_ids
external_source_ids is a reference to a list where each element is an external_source_id
external_source_id is a string
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string

</pre>

=end html

=begin text

$external_source_ids is an external_source_ids
$sample_ids is a sample_ids
external_source_ids is a reference to a list where each element is an external_source_id
external_source_id is a string
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string


=end text

=item Description

get sample ids by the platform's external source id : Takes a list of platform external source ids, and returns a list of sample ids

=back

=cut

sub get_expression_sample_ids_by_platform_external_source_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_sample_ids_by_platform_external_source_ids (received $n, expecting 1)");
    }
    {
	my($external_source_ids) = @args;

	my @_bad_arguments;
        (ref($external_source_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"external_source_ids\" (value was \"$external_source_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_sample_ids_by_platform_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_sample_ids_by_platform_external_source_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_sample_ids_by_platform_external_source_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_sample_ids_by_platform_external_source_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_sample_ids_by_platform_external_source_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_sample_ids_by_platform_external_source_ids',
				       );
    }
}



=head2 get_expression_series_ids_by_series_external_source_ids

  $series_ids = $obj->get_expression_series_ids_by_series_external_source_ids($external_source_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$external_source_ids is an external_source_ids
$series_ids is a series_ids
external_source_ids is a reference to a list where each element is an external_source_id
external_source_id is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string

</pre>

=end html

=begin text

$external_source_ids is an external_source_ids
$series_ids is a series_ids
external_source_ids is a reference to a list where each element is an external_source_id
external_source_id is a string
series_ids is a reference to a list where each element is a series_id
series_id is a string


=end text

=item Description

get series ids by the series's external source id : Takes a list of series external source ids, and returns a list of series ids

=back

=cut

sub get_expression_series_ids_by_series_external_source_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_series_ids_by_series_external_source_ids (received $n, expecting 1)");
    }
    {
	my($external_source_ids) = @args;

	my @_bad_arguments;
        (ref($external_source_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"external_source_ids\" (value was \"$external_source_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_series_ids_by_series_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_series_ids_by_series_external_source_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_series_ids_by_series_external_source_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_series_ids_by_series_external_source_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_series_ids_by_series_external_source_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_series_ids_by_series_external_source_ids',
				       );
    }
}



=head2 get_GEO_GSE

  $gseObject = $obj->get_GEO_GSE($gse_input_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$gse_input_id is a string
$gseObject is a GseObject
GseObject is a reference to a hash where the following keys are defined:
	gse_id has a value which is a string
	gse_title has a value which is a string
	gse_summary has a value which is a string
	gse_design has a value which is a string
	gse_submission_date has a value which is a string
	pub_med_id has a value which is a string
	gse_samples has a value which is a gse_samples
	gse_warnings has a value which is a gse_warnings
	gse_errors has a value which is a gse_errors
gse_samples is a reference to a hash where the key is a string and the value is a GsmObject
GsmObject is a reference to a hash where the following keys are defined:
	gsm_id has a value which is a string
	gsm_title has a value which is a string
	gsm_description has a value which is a string
	gsm_molecule has a value which is a string
	gsm_submission_date has a value which is a string
	gsm_tax_id has a value which is a string
	gsm_sample_organism has a value which is a string
	gsm_sample_characteristics has a value which is a gsm_sample_characteristics
	gsm_protocol has a value which is a string
	gsm_value_type has a value which is a string
	gsm_platform has a value which is a GPL
	gsm_contact_people has a value which is a contact_people
	gsm_data has a value which is a gsm_data
	gsm_feature_mapping_approach has a value which is a string
	ontology_ids has a value which is an ontology_ids
	gsm_warning has a value which is a gsm_warnings
	gsm_errors has a value which is a gsm_errors
gsm_sample_characteristics is a reference to a list where each element is a string
GPL is a reference to a hash where the following keys are defined:
	gpl_id has a value which is a string
	gpl_title has a value which is a string
	gpl_technology has a value which is a string
	gpl_tax_id has a value which is a string
	gpl_organism has a value which is a string
contact_people is a reference to a hash where the key is a contact_email and the value is a ContactPerson
contact_email is a string
ContactPerson is a reference to a hash where the following keys are defined:
	contact_first_name has a value which is a contact_first_name
	contact_last_name has a value which is a contact_last_name
	contact_institution has a value which is a contact_institution
contact_first_name is a string
contact_last_name is a string
contact_institution is a string
gsm_data is a reference to a hash where the key is a genome_id and the value is a GenomeDataGSM
genome_id is a string
GenomeDataGSM is a reference to a hash where the following keys are defined:
	warnings has a value which is a gsm_data_warnings
	errors has a value which is a gsm_data_errors
	features has a value which is a gsm_data_set
	originalLog2Median has a value which is a float
gsm_data_warnings is a reference to a list where each element is a string
gsm_data_errors is a reference to a list where each element is a string
gsm_data_set is a reference to a hash where the key is a feature_id and the value is a FullMeasurement
feature_id is a string
FullMeasurement is a reference to a hash where the following keys are defined:
	value has a value which is a float
	n has a value which is a float
	stddev has a value which is a float
	z_score has a value which is a float
	p_value has a value which is a float
	median has a value which is a float
	mean has a value which is a float
ontology_ids is a reference to a list where each element is an ontology_id
ontology_id is a string
gsm_warnings is a reference to a list where each element is a string
gsm_errors is a reference to a list where each element is a string
gse_warnings is a reference to a list where each element is a string
gse_errors is a reference to a list where each element is a string

</pre>

=end html

=begin text

$gse_input_id is a string
$gseObject is a GseObject
GseObject is a reference to a hash where the following keys are defined:
	gse_id has a value which is a string
	gse_title has a value which is a string
	gse_summary has a value which is a string
	gse_design has a value which is a string
	gse_submission_date has a value which is a string
	pub_med_id has a value which is a string
	gse_samples has a value which is a gse_samples
	gse_warnings has a value which is a gse_warnings
	gse_errors has a value which is a gse_errors
gse_samples is a reference to a hash where the key is a string and the value is a GsmObject
GsmObject is a reference to a hash where the following keys are defined:
	gsm_id has a value which is a string
	gsm_title has a value which is a string
	gsm_description has a value which is a string
	gsm_molecule has a value which is a string
	gsm_submission_date has a value which is a string
	gsm_tax_id has a value which is a string
	gsm_sample_organism has a value which is a string
	gsm_sample_characteristics has a value which is a gsm_sample_characteristics
	gsm_protocol has a value which is a string
	gsm_value_type has a value which is a string
	gsm_platform has a value which is a GPL
	gsm_contact_people has a value which is a contact_people
	gsm_data has a value which is a gsm_data
	gsm_feature_mapping_approach has a value which is a string
	ontology_ids has a value which is an ontology_ids
	gsm_warning has a value which is a gsm_warnings
	gsm_errors has a value which is a gsm_errors
gsm_sample_characteristics is a reference to a list where each element is a string
GPL is a reference to a hash where the following keys are defined:
	gpl_id has a value which is a string
	gpl_title has a value which is a string
	gpl_technology has a value which is a string
	gpl_tax_id has a value which is a string
	gpl_organism has a value which is a string
contact_people is a reference to a hash where the key is a contact_email and the value is a ContactPerson
contact_email is a string
ContactPerson is a reference to a hash where the following keys are defined:
	contact_first_name has a value which is a contact_first_name
	contact_last_name has a value which is a contact_last_name
	contact_institution has a value which is a contact_institution
contact_first_name is a string
contact_last_name is a string
contact_institution is a string
gsm_data is a reference to a hash where the key is a genome_id and the value is a GenomeDataGSM
genome_id is a string
GenomeDataGSM is a reference to a hash where the following keys are defined:
	warnings has a value which is a gsm_data_warnings
	errors has a value which is a gsm_data_errors
	features has a value which is a gsm_data_set
	originalLog2Median has a value which is a float
gsm_data_warnings is a reference to a list where each element is a string
gsm_data_errors is a reference to a list where each element is a string
gsm_data_set is a reference to a hash where the key is a feature_id and the value is a FullMeasurement
feature_id is a string
FullMeasurement is a reference to a hash where the following keys are defined:
	value has a value which is a float
	n has a value which is a float
	stddev has a value which is a float
	z_score has a value which is a float
	p_value has a value which is a float
	median has a value which is a float
	mean has a value which is a float
ontology_ids is a reference to a list where each element is an ontology_id
ontology_id is a string
gsm_warnings is a reference to a list where each element is a string
gsm_errors is a reference to a list where each element is a string
gse_warnings is a reference to a list where each element is a string
gse_errors is a reference to a list where each element is a string


=end text

=item Description

given a GEO GSE ID, it will return a complex data structure to be put int the upload tab files

=back

=cut

sub get_GEO_GSE
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_GEO_GSE (received $n, expecting 1)");
    }
    {
	my($gse_input_id) = @args;

	my @_bad_arguments;
        (!ref($gse_input_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"gse_input_id\" (value was \"$gse_input_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_GEO_GSE:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_GEO_GSE');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_GEO_GSE",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_GEO_GSE',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_GEO_GSE",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_GEO_GSE',
				       );
    }
}



=head2 get_expression_float_data_table_by_samples_and_features

  $float_data_table = $obj->get_expression_float_data_table_by_samples_and_features($sample_ids, $feature_ids, $numerical_interpretation)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is a sample_ids
$feature_ids is a feature_ids
$numerical_interpretation is a string
$float_data_table is a FloatDataTable
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
feature_ids is a reference to a list where each element is a feature_id
feature_id is a string
FloatDataTable is a reference to a hash where the following keys are defined:
	id has a value which is a string
	name has a value which is a string
	row_ids has a value which is a reference to a list where each element is a string
	row_labels has a value which is a reference to a list where each element is a string
	row_groups has a value which is a reference to a list where each element is a string
	row_groups_ids has a value which is a reference to a list where each element is a string
	column_ids has a value which is a reference to a list where each element is a string
	column_labels has a value which is a reference to a list where each element is a string
	column_groups has a value which is a reference to a list where each element is a string
	column_groups_ids has a value which is a reference to a list where each element is a string
	data has a value which is a reference to a list where each element is a reference to a list where each element is a float

</pre>

=end html

=begin text

$sample_ids is a sample_ids
$feature_ids is a feature_ids
$numerical_interpretation is a string
$float_data_table is a FloatDataTable
sample_ids is a reference to a list where each element is a sample_id
sample_id is a string
feature_ids is a reference to a list where each element is a feature_id
feature_id is a string
FloatDataTable is a reference to a hash where the following keys are defined:
	id has a value which is a string
	name has a value which is a string
	row_ids has a value which is a reference to a list where each element is a string
	row_labels has a value which is a reference to a list where each element is a string
	row_groups has a value which is a reference to a list where each element is a string
	row_groups_ids has a value which is a reference to a list where each element is a string
	column_ids has a value which is a reference to a list where each element is a string
	column_labels has a value which is a reference to a list where each element is a string
	column_groups has a value which is a reference to a list where each element is a string
	column_groups_ids has a value which is a reference to a list where each element is a string
	data has a value which is a reference to a list where each element is a reference to a list where each element is a float


=end text

=item Description

given a list of sample ids and feature ids and the string of what type of numerical interpretation 
it returns a FloatDataTable. 
If sample id list is an empty array [], all samples with that feature measurment values will be returned. 
If feature list is an empty array [], all features with measurment values will be returned. 
Both sample id list and feature list can not be empty, one of them must have a value. 
Numerical_interpretation options : 'FPKM', 'Log2 level intensities', 'Log2 level ratios' or 'Log2 level ratios genomic DNA control'

=back

=cut

sub get_expression_float_data_table_by_samples_and_features
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_float_data_table_by_samples_and_features (received $n, expecting 3)");
    }
    {
	my($sample_ids, $feature_ids, $numerical_interpretation) = @args;

	my @_bad_arguments;
        (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"sample_ids\" (value was \"$sample_ids\")");
        (ref($feature_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"feature_ids\" (value was \"$feature_ids\")");
        (!ref($numerical_interpretation)) or push(@_bad_arguments, "Invalid type for argument 3 \"numerical_interpretation\" (value was \"$numerical_interpretation\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_float_data_table_by_samples_and_features:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_float_data_table_by_samples_and_features');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_float_data_table_by_samples_and_features",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_float_data_table_by_samples_and_features',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_float_data_table_by_samples_and_features",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_float_data_table_by_samples_and_features',
				       );
    }
}



=head2 get_expression_float_data_table_by_genome

  $float_data_table = $obj->get_expression_float_data_table_by_genome($genome_id, $numerical_interpretation)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_id is a string
$numerical_interpretation is a string
$float_data_table is a FloatDataTable
FloatDataTable is a reference to a hash where the following keys are defined:
	id has a value which is a string
	name has a value which is a string
	row_ids has a value which is a reference to a list where each element is a string
	row_labels has a value which is a reference to a list where each element is a string
	row_groups has a value which is a reference to a list where each element is a string
	row_groups_ids has a value which is a reference to a list where each element is a string
	column_ids has a value which is a reference to a list where each element is a string
	column_labels has a value which is a reference to a list where each element is a string
	column_groups has a value which is a reference to a list where each element is a string
	column_groups_ids has a value which is a reference to a list where each element is a string
	data has a value which is a reference to a list where each element is a reference to a list where each element is a float

</pre>

=end html

=begin text

$genome_id is a string
$numerical_interpretation is a string
$float_data_table is a FloatDataTable
FloatDataTable is a reference to a hash where the following keys are defined:
	id has a value which is a string
	name has a value which is a string
	row_ids has a value which is a reference to a list where each element is a string
	row_labels has a value which is a reference to a list where each element is a string
	row_groups has a value which is a reference to a list where each element is a string
	row_groups_ids has a value which is a reference to a list where each element is a string
	column_ids has a value which is a reference to a list where each element is a string
	column_labels has a value which is a reference to a list where each element is a string
	column_groups has a value which is a reference to a list where each element is a string
	column_groups_ids has a value which is a reference to a list where each element is a string
	data has a value which is a reference to a list where each element is a reference to a list where each element is a float


=end text

=item Description

given a list of genome_id and the string of what type of numerical interpretation 
it returns a FloatDataTable. 
Gives all samples and features for expression data that match the numerical interpretation
Numerical_interpretation options : 'FPKM', 'Log2 level intensities', 'Log2 level ratios' or 'Log2 level ratios genomic DNA control'

=back

=cut

sub get_expression_float_data_table_by_genome
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_float_data_table_by_genome (received $n, expecting 2)");
    }
    {
	my($genome_id, $numerical_interpretation) = @args;

	my @_bad_arguments;
        (!ref($genome_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"genome_id\" (value was \"$genome_id\")");
        (!ref($numerical_interpretation)) or push(@_bad_arguments, "Invalid type for argument 2 \"numerical_interpretation\" (value was \"$numerical_interpretation\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_float_data_table_by_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_float_data_table_by_genome');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseExpression.get_expression_float_data_table_by_genome",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expression_float_data_table_by_genome',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_float_data_table_by_genome",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_float_data_table_by_genome',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "KBaseExpression.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'get_expression_float_data_table_by_genome',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method get_expression_float_data_table_by_genome",
            status_line => $self->{client}->status_line,
            method_name => 'get_expression_float_data_table_by_genome',
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
        warn "New client version available for Bio::KBase::KBaseExpression::KBaseExpressionClient\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::KBaseExpression::KBaseExpressionClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 feature_id

=over 4



=item Description

KBase Feature ID for a feature, typically CDS/PEG
id ws KB.Feature 

"ws" may change to "to" in the future


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



=head2 feature_ids

=over 4



=item Description

KBase list of Feature IDs , typically CDS/PEG


=item Definition

=begin html

<pre>
a reference to a list where each element is a feature_id
</pre>

=end html

=begin text

a reference to a list where each element is a feature_id

=end text

=back



=head2 measurement

=over 4



=item Description

Measurement Value (Zero median normalized within a sample) for a given feature


=item Definition

=begin html

<pre>
a float
</pre>

=end html

=begin text

a float

=end text

=back



=head2 sample_id

=over 4



=item Description

KBase Sample ID for the sample


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



=head2 sample_ids

=over 4



=item Description

List of KBase Sample IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is a sample_id
</pre>

=end html

=begin text

a reference to a list where each element is a sample_id

=end text

=back



=head2 sample_ids_averaged_from

=over 4



=item Description

List of KBase Sample IDs that this sample was averaged from


=item Definition

=begin html

<pre>
a reference to a list where each element is a sample_id
</pre>

=end html

=begin text

a reference to a list where each element is a sample_id

=end text

=back



=head2 sample_type

=over 4



=item Description

Sample type controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics


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



=head2 series_id

=over 4



=item Description

Kbase Series ID


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



=head2 series_ids

=over 4



=item Description

list of KBase Series IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is a series_id
</pre>

=end html

=begin text

a reference to a list where each element is a series_id

=end text

=back



=head2 experiment_meta_id

=over 4



=item Description

Kbase ExperimentMeta ID


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



=head2 experiment_meta_ids

=over 4



=item Description

list of KBase ExperimentMeta IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an experiment_meta_id
</pre>

=end html

=begin text

a reference to a list where each element is an experiment_meta_id

=end text

=back



=head2 experimental_unit_id

=over 4



=item Description

Kbase ExperimentalUnit ID


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



=head2 experimental_unit_ids

=over 4



=item Description

list of KBase ExperimentalUnit IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an experimental_unit_id
</pre>

=end html

=begin text

a reference to a list where each element is an experimental_unit_id

=end text

=back



=head2 samples_string_map

=over 4



=item Description

Mapping between sample id and corresponding value.   Used as return for get_expression_samples_(titles,descriptions,molecules,types,external_source_ids)


=item Definition

=begin html

<pre>
a reference to a hash where the key is a sample_id and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a sample_id and the value is a string

=end text

=back



=head2 samples_float_map

=over 4



=item Description

Mapping between sample id and corresponding value.   Used as return for get_expression_samples_original_log2_median


=item Definition

=begin html

<pre>
a reference to a hash where the key is a sample_id and the value is a float
</pre>

=end html

=begin text

a reference to a hash where the key is a sample_id and the value is a float

=end text

=back



=head2 series_string_map

=over 4



=item Description

Mapping between sample id and corresponding value.   Used as return for get_series_(titles,summaries,designs,external_source_ids)


=item Definition

=begin html

<pre>
a reference to a hash where the key is a series_id and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a series_id and the value is a string

=end text

=back



=head2 data_expression_levels_for_sample

=over 4



=item Description

mapping kbase feature id as the key and measurement as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a feature_id and the value is a measurement
</pre>

=end html

=begin text

a reference to a hash where the key is a feature_id and the value is a measurement

=end text

=back



=head2 label_data_mapping

=over 4



=item Description

Mapping from Label (often a sample id, but free text to identify} to DataExpressionLevelsForSample


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a data_expression_levels_for_sample
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a data_expression_levels_for_sample

=end text

=back



=head2 comparison_denominator_label

=over 4



=item Description

denominator label is the label for the denominator in a comparison.  
This label can be a single sampleId (default or defined) or a comma separated list of sampleIds that were averaged.


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



=head2 log2_ratio

=over 4



=item Description

Log2Ratio Log2Level of sample over log2Level of another sample for a given feature.  
Note if the Ratio is consumed by On Off Call function it will have 1(on), 0(unknown), -1(off) for its values


=item Definition

=begin html

<pre>
a float
</pre>

=end html

=begin text

a float

=end text

=back



=head2 data_sample_comparison

=over 4



=item Description

mapping kbase feature id as the key and log2Ratio as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a feature_id and the value is a log2_ratio
</pre>

=end html

=begin text

a reference to a hash where the key is a feature_id and the value is a log2_ratio

=end text

=back



=head2 denominator_sample_comparison

=over 4



=item Description

mapping ComparisonDenominatorLabel to DataSampleComparison mapping


=item Definition

=begin html

<pre>
a reference to a hash where the key is a comparison_denominator_label and the value is a data_sample_comparison
</pre>

=end html

=begin text

a reference to a hash where the key is a comparison_denominator_label and the value is a data_sample_comparison

=end text

=back



=head2 sample_comparison_mapping

=over 4



=item Description

mapping Sample Id for the numerator to a DenominatorSampleComparison.  This is the comparison data structure {NumeratorSampleId->{denominatorLabel -> {feature -> log2ratio}}}


=item Definition

=begin html

<pre>
a reference to a hash where the key is a sample_id and the value is a denominator_sample_comparison
</pre>

=end html

=begin text

a reference to a hash where the key is a sample_id and the value is a denominator_sample_comparison

=end text

=back



=head2 sample_annotation_id

=over 4



=item Description

Kbase SampleAnnotation ID


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



=head2 ontology_id

=over 4



=item Description

Kbase OntologyID


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



=head2 ontology_ids

=over 4



=item Description

list of Kbase Ontology IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an ontology_id
</pre>

=end html

=begin text

a reference to a list where each element is an ontology_id

=end text

=back



=head2 ontology_name

=over 4



=item Description

Kbase OntologyName


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



=head2 ontology_definition

=over 4



=item Description

Kbase OntologyDefinition


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



=head2 SampleAnnotation

=over 4



=item Description

Data structure for top level information for sample annotation and ontology


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
sample_annotation_id has a value which is a sample_annotation_id
ontology_id has a value which is an ontology_id
ontology_name has a value which is an ontology_name
ontology_definition has a value which is an ontology_definition

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
sample_annotation_id has a value which is a sample_annotation_id
ontology_id has a value which is an ontology_id
ontology_name has a value which is an ontology_name
ontology_definition has a value which is an ontology_definition


=end text

=back



=head2 sample_annotations

=over 4



=item Description

list of Sample Annotations associated with the Sample


=item Definition

=begin html

<pre>
a reference to a list where each element is a SampleAnnotation
</pre>

=end html

=begin text

a reference to a list where each element is a SampleAnnotation

=end text

=back



=head2 external_source_id

=over 4



=item Description

externalSourceId (could be for Platform, Sample or Series)(typically maps to a GPL, GSM or GSE from GEO)


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



=head2 external_source_ids

=over 4



=item Description

list of externalSourceIDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an external_source_id
</pre>

=end html

=begin text

a reference to a list where each element is an external_source_id

=end text

=back



=head2 Person

=over 4



=item Description

Data structure for Person  (TEMPORARY WORKSPACE TYPED OBJECT SHOULD BE HANDLED IN THE FUTURE IN WORKSPACE COMMON)

##        @searchable ws_subset email last_name institution


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
email has a value which is a string
first_name has a value which is a string
last_name has a value which is a string
institution has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
email has a value which is a string
first_name has a value which is a string
last_name has a value which is a string
institution has a value which is a string


=end text

=back



=head2 person_id

=over 4



=item Description

Kbase Person ID


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



=head2 person_ids

=over 4



=item Description

list of KBase PersonsIDs


=item Definition

=begin html

<pre>
a reference to a list where each element is a person_id
</pre>

=end html

=begin text

a reference to a list where each element is a person_id

=end text

=back



=head2 strain_id

=over 4



=item Description

KBase StrainID


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



=head2 strain_ids

=over 4



=item Description

list of KBase StrainIDs


=item Definition

=begin html

<pre>
a reference to a list where each element is a strain_id
</pre>

=end html

=begin text

a reference to a list where each element is a strain_id

=end text

=back



=head2 genome_id

=over 4



=item Description

KBase GenomeID 
id ws KB.Genome

"ws" may change to "to" in the future


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



=head2 genome_ids

=over 4



=item Description

list of KBase GenomeIDs


=item Definition

=begin html

<pre>
a reference to a list where each element is a genome_id
</pre>

=end html

=begin text

a reference to a list where each element is a genome_id

=end text

=back



=head2 wild_type_only

=over 4



=item Description

Single integer 1= WildTypeonly, 0 means all strains ok


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



=head2 ExpressionDataSample

=over 4



=item Description

Data structure for all the top level metadata and value data for an expression sample.  Essentially a expression Sample object.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
sample_id has a value which is a sample_id
source_id has a value which is a string
sample_title has a value which is a string
sample_description has a value which is a string
molecule has a value which is a string
sample_type has a value which is a sample_type
data_source has a value which is a string
external_source_id has a value which is a string
external_source_date has a value which is a string
kbase_submission_date has a value which is a string
custom has a value which is a string
original_log2_median has a value which is a float
strain_id has a value which is a strain_id
reference_strain has a value which is a string
wildtype has a value which is a string
strain_description has a value which is a string
genome_id has a value which is a genome_id
genome_scientific_name has a value which is a string
platform_id has a value which is a string
platform_title has a value which is a string
platform_technology has a value which is a string
experimental_unit_id has a value which is an experimental_unit_id
experiment_meta_id has a value which is an experiment_meta_id
experiment_title has a value which is a string
experiment_description has a value which is a string
environment_id has a value which is a string
environment_description has a value which is a string
protocol_id has a value which is a string
protocol_description has a value which is a string
protocol_name has a value which is a string
sample_annotations has a value which is a sample_annotations
series_ids has a value which is a series_ids
person_ids has a value which is a person_ids
sample_ids_averaged_from has a value which is a sample_ids_averaged_from
data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
sample_id has a value which is a sample_id
source_id has a value which is a string
sample_title has a value which is a string
sample_description has a value which is a string
molecule has a value which is a string
sample_type has a value which is a sample_type
data_source has a value which is a string
external_source_id has a value which is a string
external_source_date has a value which is a string
kbase_submission_date has a value which is a string
custom has a value which is a string
original_log2_median has a value which is a float
strain_id has a value which is a strain_id
reference_strain has a value which is a string
wildtype has a value which is a string
strain_description has a value which is a string
genome_id has a value which is a genome_id
genome_scientific_name has a value which is a string
platform_id has a value which is a string
platform_title has a value which is a string
platform_technology has a value which is a string
experimental_unit_id has a value which is an experimental_unit_id
experiment_meta_id has a value which is an experiment_meta_id
experiment_title has a value which is a string
experiment_description has a value which is a string
environment_id has a value which is a string
environment_description has a value which is a string
protocol_id has a value which is a string
protocol_description has a value which is a string
protocol_name has a value which is a string
sample_annotations has a value which is a sample_annotations
series_ids has a value which is a series_ids
person_ids has a value which is a person_ids
sample_ids_averaged_from has a value which is a sample_ids_averaged_from
data_expression_levels_for_sample has a value which is a data_expression_levels_for_sample


=end text

=back



=head2 expression_data_samples_map

=over 4



=item Description

Mapping between sampleID and ExpressionDataSample


=item Definition

=begin html

<pre>
a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample
</pre>

=end html

=begin text

a reference to a hash where the key is a sample_id and the value is an ExpressionDataSample

=end text

=back



=head2 series_expression_data_samples_mapping

=over 4



=item Description

mapping between seriesIDs and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is a series_id and the value is an expression_data_samples_map
</pre>

=end html

=begin text

a reference to a hash where the key is a series_id and the value is an expression_data_samples_map

=end text

=back



=head2 experimental_unit_expression_data_samples_mapping

=over 4



=item Description

mapping between experimentalUnitIDs and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an experimental_unit_id and the value is an expression_data_samples_map
</pre>

=end html

=begin text

a reference to a hash where the key is an experimental_unit_id and the value is an expression_data_samples_map

=end text

=back



=head2 experiment_meta_expression_data_samples_mapping

=over 4



=item Description

mapping between experimentMetaIDs and ExperimentalUnitExpressionDataSamplesMapping it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an experiment_meta_id and the value is an experimental_unit_expression_data_samples_mapping
</pre>

=end html

=begin text

a reference to a hash where the key is an experiment_meta_id and the value is an experimental_unit_expression_data_samples_mapping

=end text

=back



=head2 strain_expression_data_samples_mapping

=over 4



=item Description

mapping between strainIDs and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is a strain_id and the value is an expression_data_samples_map
</pre>

=end html

=begin text

a reference to a hash where the key is a strain_id and the value is an expression_data_samples_map

=end text

=back



=head2 genome_expression_data_samples_mapping

=over 4



=item Description

mapping between genomeIDs and all StrainExpressionDataSamplesMapping it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is a genome_id and the value is a strain_expression_data_samples_mapping
</pre>

=end html

=begin text

a reference to a hash where the key is a genome_id and the value is a strain_expression_data_samples_mapping

=end text

=back



=head2 ontology_expression_data_sample_mapping

=over 4



=item Description

mapping between ontologyIDs (concatenated if searched for with the and operator) and all the Samples that match that term(s)


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ontology_id and the value is an expression_data_samples_map
</pre>

=end html

=begin text

a reference to a hash where the key is an ontology_id and the value is an expression_data_samples_map

=end text

=back



=head2 sample_measurement_mapping

=over 4



=item Description

mapping kbase sample id as the key and a single measurement (for a specified feature id, one mapping higher) as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a sample_id and the value is a measurement
</pre>

=end html

=begin text

a reference to a hash where the key is a sample_id and the value is a measurement

=end text

=back



=head2 feature_sample_measurement_mapping

=over 4



=item Description

mapping between FeatureIds and the mappings between samples and log2level mapping


=item Definition

=begin html

<pre>
a reference to a hash where the key is a feature_id and the value is a sample_measurement_mapping
</pre>

=end html

=begin text

a reference to a hash where the key is a feature_id and the value is a sample_measurement_mapping

=end text

=back



=head2 GPL

=over 4



=item Description

Data structure for a GEO Platform


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
gpl_id has a value which is a string
gpl_title has a value which is a string
gpl_technology has a value which is a string
gpl_tax_id has a value which is a string
gpl_organism has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
gpl_id has a value which is a string
gpl_title has a value which is a string
gpl_technology has a value which is a string
gpl_tax_id has a value which is a string
gpl_organism has a value which is a string


=end text

=back



=head2 contact_email

=over 4



=item Description

Email for the GSM contact person


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



=head2 contact_first_name

=over 4



=item Description

First Name of GSM contact person


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



=head2 contact_last_name

=over 4



=item Description

Last Name of GSM contact person


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



=head2 contact_institution

=over 4



=item Description

Institution of GSM contact person


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



=head2 ContactPerson

=over 4



=item Description

Data structure for GSM ContactPerson


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
contact_first_name has a value which is a contact_first_name
contact_last_name has a value which is a contact_last_name
contact_institution has a value which is a contact_institution

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
contact_first_name has a value which is a contact_first_name
contact_last_name has a value which is a contact_last_name
contact_institution has a value which is a contact_institution


=end text

=back



=head2 contact_people

=over 4



=item Description

Mapping between key : ContactEmail and value : ContactPerson Data Structure


=item Definition

=begin html

<pre>
a reference to a hash where the key is a contact_email and the value is a ContactPerson
</pre>

=end html

=begin text

a reference to a hash where the key is a contact_email and the value is a ContactPerson

=end text

=back



=head2 FullMeasurement

=over 4



=item Description

Measurement data structure


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
value has a value which is a float
n has a value which is a float
stddev has a value which is a float
z_score has a value which is a float
p_value has a value which is a float
median has a value which is a float
mean has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
value has a value which is a float
n has a value which is a float
stddev has a value which is a float
z_score has a value which is a float
p_value has a value which is a float
median has a value which is a float
mean has a value which is a float


=end text

=back



=head2 gsm_data_set

=over 4



=item Description

mapping kbase feature id as the key and FullMeasurement Structure as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a feature_id and the value is a FullMeasurement
</pre>

=end html

=begin text

a reference to a hash where the key is a feature_id and the value is a FullMeasurement

=end text

=back



=head2 gsm_data_warnings

=over 4



=item Description

List of GSM Data level warnings


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 gsm_warnings

=over 4



=item Description

List of GSM level warnings


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 gse_warnings

=over 4



=item Description

List of GSE level warnings


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 gsm_data_errors

=over 4



=item Description

List of GSM Data level errors


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 gsm_errors

=over 4



=item Description

List of GSM level errors


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 gse_errors

=over 4



=item Description

List of GSE level errors


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 gsm_sample_characteristics

=over 4



=item Description

List of GSM Sample Characteristics from ch1


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 GenomeDataGSM

=over 4



=item Description

Data structure that has the GSM data, warnings, errors and originalLog2Median for that GSM and Genome ID combination


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
warnings has a value which is a gsm_data_warnings
errors has a value which is a gsm_data_errors
features has a value which is a gsm_data_set
originalLog2Median has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
warnings has a value which is a gsm_data_warnings
errors has a value which is a gsm_data_errors
features has a value which is a gsm_data_set
originalLog2Median has a value which is a float


=end text

=back



=head2 gsm_data

=over 4



=item Description

mapping kbase feature id as the key and FullMeasurement Structure as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a genome_id and the value is a GenomeDataGSM
</pre>

=end html

=begin text

a reference to a hash where the key is a genome_id and the value is a GenomeDataGSM

=end text

=back



=head2 GsmObject

=over 4



=item Description

GSM OBJECT


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
gsm_id has a value which is a string
gsm_title has a value which is a string
gsm_description has a value which is a string
gsm_molecule has a value which is a string
gsm_submission_date has a value which is a string
gsm_tax_id has a value which is a string
gsm_sample_organism has a value which is a string
gsm_sample_characteristics has a value which is a gsm_sample_characteristics
gsm_protocol has a value which is a string
gsm_value_type has a value which is a string
gsm_platform has a value which is a GPL
gsm_contact_people has a value which is a contact_people
gsm_data has a value which is a gsm_data
gsm_feature_mapping_approach has a value which is a string
ontology_ids has a value which is an ontology_ids
gsm_warning has a value which is a gsm_warnings
gsm_errors has a value which is a gsm_errors

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
gsm_id has a value which is a string
gsm_title has a value which is a string
gsm_description has a value which is a string
gsm_molecule has a value which is a string
gsm_submission_date has a value which is a string
gsm_tax_id has a value which is a string
gsm_sample_organism has a value which is a string
gsm_sample_characteristics has a value which is a gsm_sample_characteristics
gsm_protocol has a value which is a string
gsm_value_type has a value which is a string
gsm_platform has a value which is a GPL
gsm_contact_people has a value which is a contact_people
gsm_data has a value which is a gsm_data
gsm_feature_mapping_approach has a value which is a string
ontology_ids has a value which is an ontology_ids
gsm_warning has a value which is a gsm_warnings
gsm_errors has a value which is a gsm_errors


=end text

=back



=head2 gse_samples

=over 4



=item Description

Mapping of Key GSMID to GSM Object


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a GsmObject
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a GsmObject

=end text

=back



=head2 GseObject

=over 4



=item Description

GSE OBJECT


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
gse_id has a value which is a string
gse_title has a value which is a string
gse_summary has a value which is a string
gse_design has a value which is a string
gse_submission_date has a value which is a string
pub_med_id has a value which is a string
gse_samples has a value which is a gse_samples
gse_warnings has a value which is a gse_warnings
gse_errors has a value which is a gse_errors

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
gse_id has a value which is a string
gse_title has a value which is a string
gse_summary has a value which is a string
gse_design has a value which is a string
gse_submission_date has a value which is a string
pub_med_id has a value which is a string
gse_samples has a value which is a gse_samples
gse_warnings has a value which is a gse_warnings
gse_errors has a value which is a gse_errors


=end text

=back



=head2 meta_data_only

=over 4



=item Description

Single integer 1= metaDataOnly, 0 means returns data


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



=head2 ExpressionOntologyTerm

=over 4



=item Description

Temporary workspace typed object for ontology.  Should be replaced by a ontology workspace typed object.
Currently supports EO, PO and ENVO ontology terms.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
expression_ontology_term_id has a value which is a string
expression_ontology_term_name has a value which is a string
expression_ontology_term_definition has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
expression_ontology_term_id has a value which is a string
expression_ontology_term_name has a value which is a string
expression_ontology_term_definition has a value which is a string


=end text

=back



=head2 expression_ontology_terms

=over 4



=item Description

list of ExpressionsOntologies


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionOntologyTerm
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionOntologyTerm

=end text

=back



=head2 kbase_genome_id

=over 4



=item Description

id for the genome

@id ws KBaseGenomes.Genome


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



=head2 Strain

=over 4



=item Description

Data structure for Strain  (TEMPORARY WORKSPACE TYPED OBJECT SHOULD BE HANDLED IN THE FUTURE IN WORKSPACE COMMON)


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_id has a value which is a kbase_genome_id
reference_strain has a value which is a string
wild_type has a value which is a string
description has a value which is a string
name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_id has a value which is a kbase_genome_id
reference_strain has a value which is a string
wild_type has a value which is a string
description has a value which is a string
name has a value which is a string


=end text

=back



=head2 FloatDataTable

=over 4



=item Description

Represents data for a single data table, convention is biological features on y-axis and samples etc. on x
string id - identifier for data table
string name - name or title to display in a plot etc.
list<string> row_ids - kb ids for the objects
list<string> row_labels - label text to display
list<string> row_groups - group labels for row
list<string> row_groups_ids - kb ids for group objects
list<string> column_ids - kb ids for the objects
list<string> column_labels - label text to display
list<string> column_groups - group labels for columns
list<string> column_groups_ids - kb ids for group objects
list<list<float>> data - a list of rows of floats, non-numeric values represented as 'null'
@optional id
@optional name
@optional row_ids
@optional row_groups
@optional row_groups_ids
@optional column_ids
@optional column_groups
@optional column_groups_ids


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
name has a value which is a string
row_ids has a value which is a reference to a list where each element is a string
row_labels has a value which is a reference to a list where each element is a string
row_groups has a value which is a reference to a list where each element is a string
row_groups_ids has a value which is a reference to a list where each element is a string
column_ids has a value which is a reference to a list where each element is a string
column_labels has a value which is a reference to a list where each element is a string
column_groups has a value which is a reference to a list where each element is a string
column_groups_ids has a value which is a reference to a list where each element is a string
data has a value which is a reference to a list where each element is a reference to a list where each element is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
name has a value which is a string
row_ids has a value which is a reference to a list where each element is a string
row_labels has a value which is a reference to a list where each element is a string
row_groups has a value which is a reference to a list where each element is a string
row_groups_ids has a value which is a reference to a list where each element is a string
column_ids has a value which is a reference to a list where each element is a string
column_labels has a value which is a reference to a list where each element is a string
column_groups has a value which is a reference to a list where each element is a string
column_groups_ids has a value which is a reference to a list where each element is a string
data has a value which is a reference to a list where each element is a reference to a list where each element is a float


=end text

=back



=head2 ExpressionPlatform

=over 4



=item Description

Data structure for the workspace expression platform.  The ExpressionPlatform typed object.
source_id defaults to id if not set, but typically referes to a GPL if the data is from GEO.

@optional strain

@searchable ws_subset source_id id genome_id title technology
@searchable ws_subset strain.genome_id  strain.reference_strain strain.wild_type


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
genome_id has a value which is a kbase_genome_id
strain has a value which is a Strain
technology has a value which is a string
title has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
genome_id has a value which is a kbase_genome_id
strain has a value which is a Strain
technology has a value which is a string
title has a value which is a string


=end text

=back



=head2 expression_platform_id

=over 4



=item Description

id for the expression platform

@id ws KBaseExpression.ExpressionPlatform


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



=head2 Protocol

=over 4



=item Description

Data structure for Protocol  (TEMPORARY WORKSPACE TYPED OBJECT SHOULD BE HANDLED IN THE FUTURE IN WORKSPACE COMMON)


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
description has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
description has a value which is a string


=end text

=back



=head2 expression_sample_id

=over 4



=item Description

id for the expression sample

@id ws KBaseExpression.ExpressionSample


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



=head2 expression_sample_ids

=over 4



=item Description

list of expression sample ids


=item Definition

=begin html

<pre>
a reference to a list where each element is an expression_sample_id
</pre>

=end html

=begin text

a reference to a list where each element is an expression_sample_id

=end text

=back



=head2 expression_series_ids

=over 4



=item Description

list of expression series ids that the sample belongs to : note this can not be a ws_reference because ws does not support bidirectional references


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 genome_expression_sample_ids_map

=over 4



=item Description

map between genome ids and a list of samples from that genome in this series


=item Definition

=begin html

<pre>
a reference to a hash where the key is a kbase_genome_id and the value is an expression_sample_ids
</pre>

=end html

=begin text

a reference to a hash where the key is a kbase_genome_id and the value is an expression_sample_ids

=end text

=back



=head2 persons

=over 4



=item Description

list of Persons


=item Definition

=begin html

<pre>
a reference to a list where each element is a Person
</pre>

=end html

=begin text

a reference to a list where each element is a Person

=end text

=back



=head2 ExpressionSample

=over 4



=item Description

Data structure for the workspace expression sample.  The Expression Sample typed object.

protocol, persons and strain should need to eventually have common ws objects.  I will make expression ones for now.
RMA_normalized (1 = true, non 1 = false)

we may need a link to experimentMetaID later.

@optional description title data_quality_level original_median expression_ontology_terms platform_id default_control_sample characteristics
@optional averaged_from_samples protocol strain persons molecule data_source shock_url processing_comments expression_series_ids RMA_normalized

@searchable ws_subset id source_id type data_quality_level genome_id platform_id description title data_source characteristics keys_of(expression_levels) 
@searchable ws_subset persons.[*].email persons.[*].last_name persons.[*].institution  
@searchable ws_subset strain.genome_id strain.reference_strain strain.wild_type          
@searchable ws_subset protocol.name protocol.description 
@searchable ws_subset expression_ontology_terms.[*].expression_ontology_term_id expression_ontology_terms.[*].expression_ontology_term_name


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
type has a value which is a sample_type
numerical_interpretation has a value which is a string
description has a value which is a string
title has a value which is a string
data_quality_level has a value which is an int
original_median has a value which is a float
external_source_date has a value which is a string
expression_levels has a value which is a data_expression_levels_for_sample
genome_id has a value which is a kbase_genome_id
expression_ontology_terms has a value which is an expression_ontology_terms
platform_id has a value which is an expression_platform_id
default_control_sample has a value which is an expression_sample_id
averaged_from_samples has a value which is an expression_sample_ids
protocol has a value which is a Protocol
strain has a value which is a Strain
persons has a value which is a persons
molecule has a value which is a string
data_source has a value which is a string
shock_url has a value which is a string
processing_comments has a value which is a string
expression_series_ids has a value which is an expression_series_ids
characteristics has a value which is a string
RMA_normalized has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
type has a value which is a sample_type
numerical_interpretation has a value which is a string
description has a value which is a string
title has a value which is a string
data_quality_level has a value which is an int
original_median has a value which is a float
external_source_date has a value which is a string
expression_levels has a value which is a data_expression_levels_for_sample
genome_id has a value which is a kbase_genome_id
expression_ontology_terms has a value which is an expression_ontology_terms
platform_id has a value which is an expression_platform_id
default_control_sample has a value which is an expression_sample_id
averaged_from_samples has a value which is an expression_sample_ids
protocol has a value which is a Protocol
strain has a value which is a Strain
persons has a value which is a persons
molecule has a value which is a string
data_source has a value which is a string
shock_url has a value which is a string
processing_comments has a value which is a string
expression_series_ids has a value which is an expression_series_ids
characteristics has a value which is a string
RMA_normalized has a value which is an int


=end text

=back



=head2 ExpressionSeries

=over 4



=item Description

Data structure for the workspace expression series.  The ExpressionSeries typed object.
publication should need to eventually have ws objects, will not include it for now.

@optional title summary design publication_id 

@searchable ws_subset id source_id publication_id title summary design genome_expression_sample_ids_map


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
genome_expression_sample_ids_map has a value which is a genome_expression_sample_ids_map
title has a value which is a string
summary has a value which is a string
design has a value which is a string
publication_id has a value which is a string
external_source_date has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
genome_expression_sample_ids_map has a value which is a genome_expression_sample_ids_map
title has a value which is a string
summary has a value which is a string
design has a value which is a string
publication_id has a value which is a string
external_source_date has a value which is a string


=end text

=back



=head2 ExpressionReplicateGroup

=over 4



=item Description

Simple Grouping of Samples that belong to the same replicate group.  ExpressionReplicateGroup typed object.
@searchable ws_subset id expression_sample_ids


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
expression_sample_ids has a value which is an expression_sample_ids

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
expression_sample_ids has a value which is an expression_sample_ids


=end text

=back



=head2 genome_id

=over 4



=item Description

reference genome id for mapping the RNA-Seq fastq file


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



=head2 RNASeqSampleMetaData

=over 4



=item Description

Object for the RNASeq Metadata
@optional platform source tissue condition po_id eo_id


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
paired has a value which is a string
platform has a value which is a string
sample_id has a value which is a string
title has a value which is a string
source has a value which is a string
source_id has a value which is a string
ext_source_date has a value which is a string
domain has a value which is a string
ref_genome has a value which is a genome_id
tissue has a value which is a reference to a list where each element is a string
condition has a value which is a reference to a list where each element is a string
po_id has a value which is a reference to a list where each element is a string
eo_id has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
paired has a value which is a string
platform has a value which is a string
sample_id has a value which is a string
title has a value which is a string
source has a value which is a string
source_id has a value which is a string
ext_source_date has a value which is a string
domain has a value which is a string
ref_genome has a value which is a genome_id
tissue has a value which is a reference to a list where each element is a string
condition has a value which is a reference to a list where each element is a string
po_id has a value which is a reference to a list where each element is a string
eo_id has a value which is a reference to a list where each element is a string


=end text

=back



=head2 RNASeqSamplesMetaData

=over 4



=item Description

Complete List of RNASeq MetaData


=item Definition

=begin html

<pre>
a reference to a list where each element is an RNASeqSampleMetaData
</pre>

=end html

=begin text

a reference to a list where each element is an RNASeqSampleMetaData

=end text

=back



=head2 shock_url

=over 4



=item Description

A reference to RNASeq fastq  object on shock


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



=head2 shock_id

=over 4



=item Description

A reference to RNASeq fastq  object on shock


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



=head2 shock_ref

=over 4



=item Description

A reference to RNASeq fastq  object


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
shock_id has a value which is a shock_id
shock_url has a value which is a shock_url

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
shock_id has a value which is a shock_id
shock_url has a value which is a shock_url


=end text

=back



=head2 RNASeqSample

=over 4



=item Description

RNASeq fastq  object


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
type has a value which is a string
created has a value which is a string
shock_ref has a value which is a shock_ref
metadata has a value which is an RNASeqSampleMetaData

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
type has a value which is a string
created has a value which is a string
shock_ref has a value which is a shock_ref
metadata has a value which is an RNASeqSampleMetaData


=end text

=back



=head2 RNASeqSamplesSet

=over 4



=item Description

list of RNASeqSamples


=item Definition

=begin html

<pre>
a reference to a list where each element is an RNASeqSample
</pre>

=end html

=begin text

a reference to a list where each element is an RNASeqSample

=end text

=back



=head2 RNASeqSampleAlignment

=over 4



=item Description

Object for the RNASeq Alignment bam file


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
paired has a value which is a string
created has a value which is a string
shock_ref has a value which is a shock_ref
metadata has a value which is an RNASeqSampleMetaData

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
paired has a value which is a string
created has a value which is a string
shock_ref has a value which is a shock_ref
metadata has a value which is an RNASeqSampleMetaData


=end text

=back



=head2 RNASeqSampleAlignmentSet

=over 4



=item Description

list of RNASeqSampleAlignment


=item Definition

=begin html

<pre>
a reference to a list where each element is an RNASeqSampleAlignment
</pre>

=end html

=begin text

a reference to a list where each element is an RNASeqSampleAlignment

=end text

=back



=head2 RNASeqDifferentialExpressionFile

=over 4



=item Description

RNASeqDifferentialExpression file structure


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
shock_ref has a value which is a shock_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
shock_ref has a value which is a shock_ref


=end text

=back



=head2 RNASeqDifferentialExpressionSet

=over 4



=item Description

list of RNASeqDifferentialExpression files


=item Definition

=begin html

<pre>
a reference to a list where each element is an RNASeqDifferentialExpressionFile
</pre>

=end html

=begin text

a reference to a list where each element is an RNASeqDifferentialExpressionFile

=end text

=back



=head2 RNASeqDifferentialExpression

=over 4



=item Description

Object for the RNASeq Differential Expression


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
title has a value which is a string
created has a value which is a string
diff_expression has a value which is an RNASeqDifferentialExpressionSet

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
title has a value which is a string
created has a value which is a string
diff_expression has a value which is an RNASeqDifferentialExpressionSet


=end text

=back



=cut

package Bio::KBase::KBaseExpression::KBaseExpressionClient::RpcClient;
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
