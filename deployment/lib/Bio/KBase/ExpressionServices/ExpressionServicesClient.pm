package ExpressionServicesClient;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

ExpressionServicesClient

=head1 DESCRIPTION





=cut

sub new
{
    my($class, $url, @args) = @_;

    my $self = {
	client => ExpressionServicesClient::RpcClient->new,
	url => $url,
    };


    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 get_expression_samples_data

  $expressionDataSamplesMap = $obj->get_expression_samples_data($sampleIds)

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleIds is a SampleIDs
$expressionDataSamplesMap is an ExpressionDataSamplesMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$sampleIds is a SampleIDs
$expressionDataSamplesMap is an ExpressionDataSamplesMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text

=item Description

core function used by many others.  Given a list of SampleIds returns mapping of SampleId to SampleDataStructure

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
	my($sampleIds) = @args;

	my @_bad_arguments;
        (ref($sampleIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"sampleIds\" (value was \"$sampleIds\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_data:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_data');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "ExpressionServices.get_expression_samples_data",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_expression_samples_data',
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



=head2 get_expression_samples_data_by_series_ids

  $seriesExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_series_ids($seriesIds)

=over 4

=item Parameter and return types

=begin html

<pre>
$seriesIds is a SeriesIDs
$seriesExpressionDataSamplesMapping is a SeriesExpressionDataSamplesMapping
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesExpressionDataSamplesMapping is a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$seriesIds is a SeriesIDs
$seriesExpressionDataSamplesMapping is a SeriesExpressionDataSamplesMapping
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesExpressionDataSamplesMapping is a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text

=item Description

given a list of SeriesIds returns mapping of SeriesId to expressionDataSamples

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
	my($seriesIds) = @args;

	my @_bad_arguments;
        (ref($seriesIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"seriesIds\" (value was \"$seriesIds\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_data_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_data_by_series_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "ExpressionServices.get_expression_samples_data_by_series_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_expression_samples_data_by_series_ids',
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



=head2 get_expression_samples_data_by_experimental_unit_ids

  $experimentalUnitExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_experimental_unit_ids($experimentalUnitIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$experimentalUnitIDs is an ExperimentalUnitIDs
$experimentalUnitExpressionDataSamplesMapping is an ExperimentalUnitExpressionDataSamplesMapping
ExperimentalUnitIDs is a reference to a list where each element is an ExperimentalUnitID
ExperimentalUnitID is a string
ExperimentalUnitExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$experimentalUnitIDs is an ExperimentalUnitIDs
$experimentalUnitExpressionDataSamplesMapping is an ExperimentalUnitExpressionDataSamplesMapping
ExperimentalUnitIDs is a reference to a list where each element is an ExperimentalUnitID
ExperimentalUnitID is a string
ExperimentalUnitExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text

=item Description

given a list of ExperimentalUnitIds returns mapping of ExperimentalUnitId to expressionDataSamples

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
	my($experimentalUnitIDs) = @args;

	my @_bad_arguments;
        (ref($experimentalUnitIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"experimentalUnitIDs\" (value was \"$experimentalUnitIDs\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_data_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_data_by_experimental_unit_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "ExpressionServices.get_expression_samples_data_by_experimental_unit_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_expression_samples_data_by_experimental_unit_ids',
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



=head2 get_expression_experimental_unit_samples_data_by_experiment_meta_ids

  $experimentMetaExpressionDataSamplesMapping = $obj->get_expression_experimental_unit_samples_data_by_experiment_meta_ids($experimentMetaIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$experimentMetaIDs is an ExperimentMetaIDs
$experimentMetaExpressionDataSamplesMapping is an ExperimentMetaExpressionDataSamplesMapping
ExperimentMetaIDs is a reference to a list where each element is an ExperimentMetaID
ExperimentMetaID is a string
ExperimentMetaExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentMetaID and the value is an ExperimentalUnitExpressionDataSamplesMapping
ExperimentalUnitExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
ExperimentalUnitID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$experimentMetaIDs is an ExperimentMetaIDs
$experimentMetaExpressionDataSamplesMapping is an ExperimentMetaExpressionDataSamplesMapping
ExperimentMetaIDs is a reference to a list where each element is an ExperimentMetaID
ExperimentMetaID is a string
ExperimentMetaExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentMetaID and the value is an ExperimentalUnitExpressionDataSamplesMapping
ExperimentalUnitExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
ExperimentalUnitID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text

=item Description

given a list of ExperimentMetaIds returns mapping of ExperimentId to experimentalUnitExpressionDataSamplesMapping

=back

=cut

sub get_expression_experimental_unit_samples_data_by_experiment_meta_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expression_experimental_unit_samples_data_by_experiment_meta_ids (received $n, expecting 1)");
    }
    {
	my($experimentMetaIDs) = @args;

	my @_bad_arguments;
        (ref($experimentMetaIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"experimentMetaIDs\" (value was \"$experimentMetaIDs\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_experimental_unit_samples_data_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_experimental_unit_samples_data_by_experiment_meta_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "ExpressionServices.get_expression_experimental_unit_samples_data_by_experiment_meta_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_expression_experimental_unit_samples_data_by_experiment_meta_ids',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expression_experimental_unit_samples_data_by_experiment_meta_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expression_experimental_unit_samples_data_by_experiment_meta_ids',
				       );
    }
}



=head2 get_expression_samples_data_by_strain_ids

  $strainExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_strain_ids($strainIDs, $sampleType)

=over 4

=item Parameter and return types

=begin html

<pre>
$strainIDs is a StrainIDs
$sampleType is a SampleType
$strainExpressionDataSamplesMapping is a StrainExpressionDataSamplesMapping
StrainIDs is a reference to a list where each element is a StrainID
StrainID is a string
SampleType is a string
StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$strainIDs is a StrainIDs
$sampleType is a SampleType
$strainExpressionDataSamplesMapping is a StrainExpressionDataSamplesMapping
StrainIDs is a reference to a list where each element is a StrainID
StrainID is a string
SampleType is a string
StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text

=item Description

given a list of Strains, and a SampleType, it returns a StrainExpressionDataSamplesMapping,  StrainId -> ExpressionDataSample

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
	my($strainIDs, $sampleType) = @args;

	my @_bad_arguments;
        (ref($strainIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"strainIDs\" (value was \"$strainIDs\")");
        (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument 2 \"sampleType\" (value was \"$sampleType\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_data_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_data_by_strain_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "ExpressionServices.get_expression_samples_data_by_strain_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_expression_samples_data_by_strain_ids',
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



=head2 get_expression_samples_data_by_genome_ids

  $genomeExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_genome_ids($genomeIDs, $sampleType, $wildTypeOnly)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeIDs is a GenomeIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$genomeExpressionDataSamplesMapping is a GenomeExpressionDataSamplesMapping
GenomeIDs is a reference to a list where each element is a GenomeID
GenomeID is a string
SampleType is a string
WildTypeOnly is an int
GenomeExpressionDataSamplesMapping is a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping
StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
StrainID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$genomeIDs is a GenomeIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$genomeExpressionDataSamplesMapping is a GenomeExpressionDataSamplesMapping
GenomeIDs is a reference to a list where each element is a GenomeID
GenomeID is a string
SampleType is a string
WildTypeOnly is an int
GenomeExpressionDataSamplesMapping is a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping
StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
StrainID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text

=item Description

given a list of Genomes, a SampleType and a int indicating WildType Only (1 = true, 0 = false) , it returns a GenomeExpressionDataSamplesMapping   ,  Genome -> StrainId -> ExpressionDataSample

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
	my($genomeIDs, $sampleType, $wildTypeOnly) = @args;

	my @_bad_arguments;
        (ref($genomeIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeIDs\" (value was \"$genomeIDs\")");
        (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument 2 \"sampleType\" (value was \"$sampleType\")");
        (!ref($wildTypeOnly)) or push(@_bad_arguments, "Invalid type for argument 3 \"wildTypeOnly\" (value was \"$wildTypeOnly\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_samples_data_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_samples_data_by_genome_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "ExpressionServices.get_expression_samples_data_by_genome_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_expression_samples_data_by_genome_ids',
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



=head2 get_expression_data_by_feature_ids

  $featureSampleLog2LevelMapping = $obj->get_expression_data_by_feature_ids($featureIds, $sampleType, $wildTypeOnly)

=over 4

=item Parameter and return types

=begin html

<pre>
$featureIds is a FeatureIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$featureSampleLog2LevelMapping is a FeatureSampleLog2LevelMapping
FeatureIDs is a reference to a list where each element is a FeatureID
FeatureID is a string
SampleType is a string
WildTypeOnly is an int
FeatureSampleLog2LevelMapping is a reference to a hash where the key is a FeatureID and the value is a SampleLog2LevelMapping
SampleLog2LevelMapping is a reference to a hash where the key is a SampleID and the value is a Log2Level
SampleID is a string
Log2Level is a float

</pre>

=end html

=begin text

$featureIds is a FeatureIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$featureSampleLog2LevelMapping is a FeatureSampleLog2LevelMapping
FeatureIDs is a reference to a list where each element is a FeatureID
FeatureID is a string
SampleType is a string
WildTypeOnly is an int
FeatureSampleLog2LevelMapping is a reference to a hash where the key is a FeatureID and the value is a SampleLog2LevelMapping
SampleLog2LevelMapping is a reference to a hash where the key is a SampleID and the value is a Log2Level
SampleID is a string
Log2Level is a float


=end text

=item Description

given a list of FeatureIds, a SampleType and a int indicating WildType Only (1 = true, 0 = false) returns a FeatureSampleLog2LevelMapping : featureId->{sample_id->log2Level}

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
	my($featureIds, $sampleType, $wildTypeOnly) = @args;

	my @_bad_arguments;
        (ref($featureIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"featureIds\" (value was \"$featureIds\")");
        (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument 2 \"sampleType\" (value was \"$sampleType\")");
        (!ref($wildTypeOnly)) or push(@_bad_arguments, "Invalid type for argument 3 \"wildTypeOnly\" (value was \"$wildTypeOnly\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expression_data_by_feature_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expression_data_by_feature_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "ExpressionServices.get_expression_data_by_feature_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_expression_data_by_feature_ids',
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



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "ExpressionServices.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'get_expression_data_by_feature_ids',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method get_expression_data_by_feature_ids",
            status_line => $self->{client}->status_line,
            method_name => 'get_expression_data_by_feature_ids',
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
        warn "New client version available for ExpressionServicesClient\n";
    }
    if ($sMajor == 0) {
        warn "ExpressionServicesClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 FeatureID

=over 4



=item Description

KBase Feature ID for a feature, typically CDS/PEG


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



=head2 FeatureIDs

=over 4



=item Description

KBase list of Feature IDs , typically CDS/PEG


=item Definition

=begin html

<pre>
a reference to a list where each element is a FeatureID
</pre>

=end html

=begin text

a reference to a list where each element is a FeatureID

=end text

=back



=head2 Log2Level

=over 4



=item Description

Log2Level (Zero median normalized within a sample) for a given feature


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



=head2 SampleID

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



=head2 SampleIDs

=over 4



=item Description

List of KBase Sample IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is a SampleID
</pre>

=end html

=begin text

a reference to a list where each element is a SampleID

=end text

=back



=head2 SampleType

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



=head2 SeriesID

=over 4



=item Description

Kbase Series Id


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



=head2 SeriesIDs

=over 4



=item Description

list of KBase Series Ids


=item Definition

=begin html

<pre>
a reference to a list where each element is a SeriesID
</pre>

=end html

=begin text

a reference to a list where each element is a SeriesID

=end text

=back



=head2 ExperimentMetaID

=over 4



=item Description

Kbase ExperimentMeta Id


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



=head2 ExperimentMetaIDs

=over 4



=item Description

list of KBase ExperimentMeta Ids


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExperimentMetaID
</pre>

=end html

=begin text

a reference to a list where each element is an ExperimentMetaID

=end text

=back



=head2 ExperimentalUnitID

=over 4



=item Description

Kbase ExperimentalUnitId


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



=head2 ExperimentalUnitIDs

=over 4



=item Description

list of KBase ExperimentUnitIds


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExperimentalUnitID
</pre>

=end html

=begin text

a reference to a list where each element is an ExperimentalUnitID

=end text

=back



=head2 DataExpressionLevelsForSample

=over 4



=item Description

mapping kbase feature id as the key and log2level as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a FeatureID and the value is a Log2Level
</pre>

=end html

=begin text

a reference to a hash where the key is a FeatureID and the value is a Log2Level

=end text

=back



=head2 SampleAnnotationID

=over 4



=item Description

Kbase SampleAnnotation Id


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



=head2 SampleAnnotationIDs

=over 4



=item Description

list of KBase SampleAnnotation Ids


=item Definition

=begin html

<pre>
a reference to a list where each element is a SampleAnnotationID
</pre>

=end html

=begin text

a reference to a list where each element is a SampleAnnotationID

=end text

=back



=head2 PersonID

=over 4



=item Description

Kbase Person Id


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



=head2 PersonIDs

=over 4



=item Description

list of KBase PersonsIds


=item Definition

=begin html

<pre>
a reference to a list where each element is a PersonID
</pre>

=end html

=begin text

a reference to a list where each element is a PersonID

=end text

=back



=head2 StrainID

=over 4



=item Description

KBase StrainId


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



=head2 StrainIDs

=over 4



=item Description

list of KBase StrainIds


=item Definition

=begin html

<pre>
a reference to a list where each element is a StrainID
</pre>

=end html

=begin text

a reference to a list where each element is a StrainID

=end text

=back



=head2 GenomeID

=over 4



=item Description

KBase GenomeId


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



=head2 GenomeIDs

=over 4



=item Description

list of KBase GenomeIds


=item Definition

=begin html

<pre>
a reference to a list where each element is a GenomeID
</pre>

=end html

=begin text

a reference to a list where each element is a GenomeID

=end text

=back



=head2 WildTypeOnly

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

Data structure for all the top level metadata and value data for an expression sample


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
sampleId has a value which is a SampleID
sourceId has a value which is a string
sampleTitle has a value which is a string
sampleDescription has a value which is a string
molecule has a value which is a string
sampleType has a value which is a SampleType
dataSource has a value which is a string
externalSourceId has a value which is a string
externalSourceDate has a value which is a string
kbaseSubmissionDate has a value which is a string
custom has a value which is a string
originalLog2Median has a value which is a float
strainID has a value which is a StrainID
referenceStrain has a value which is a string
wildtype has a value which is a string
strainDescription has a value which is a string
genomeID has a value which is a GenomeID
genomeScientificName has a value which is a string
platformId has a value which is a string
platformTitle has a value which is a string
platformTechnology has a value which is a string
experimentalUnitID has a value which is an ExperimentalUnitID
experimentMetaID has a value which is an ExperimentMetaID
experimentTitle has a value which is a string
experimentDescription has a value which is a string
environmentId has a value which is a string
environmentDescription has a value which is a string
protocolId has a value which is a string
protocolDescription has a value which is a string
protocolName has a value which is a string
sampleAnnotationIDs has a value which is a SampleAnnotationIDs
seriesIds has a value which is a SeriesIDs
personIds has a value which is a PersonIDs
dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
sampleId has a value which is a SampleID
sourceId has a value which is a string
sampleTitle has a value which is a string
sampleDescription has a value which is a string
molecule has a value which is a string
sampleType has a value which is a SampleType
dataSource has a value which is a string
externalSourceId has a value which is a string
externalSourceDate has a value which is a string
kbaseSubmissionDate has a value which is a string
custom has a value which is a string
originalLog2Median has a value which is a float
strainID has a value which is a StrainID
referenceStrain has a value which is a string
wildtype has a value which is a string
strainDescription has a value which is a string
genomeID has a value which is a GenomeID
genomeScientificName has a value which is a string
platformId has a value which is a string
platformTitle has a value which is a string
platformTechnology has a value which is a string
experimentalUnitID has a value which is an ExperimentalUnitID
experimentMetaID has a value which is an ExperimentMetaID
experimentTitle has a value which is a string
experimentDescription has a value which is a string
environmentId has a value which is a string
environmentDescription has a value which is a string
protocolId has a value which is a string
protocolDescription has a value which is a string
protocolName has a value which is a string
sampleAnnotationIDs has a value which is a SampleAnnotationIDs
seriesIds has a value which is a SeriesIDs
personIds has a value which is a PersonIDs
dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample


=end text

=back



=head2 ExpressionDataSamplesMap

=over 4



=item Description

Mapping between sampleId and ExpressionDataSample


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
</pre>

=end html

=begin text

a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample

=end text

=back



=head2 SeriesExpressionDataSamplesMapping

=over 4



=item Description

mapping between seriesIds and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap
</pre>

=end html

=begin text

a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap

=end text

=back



=head2 ExperimentalUnitExpressionDataSamplesMapping

=over 4



=item Description

mapping between experimentalUnitIds and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
</pre>

=end html

=begin text

a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap

=end text

=back



=head2 ExperimentMetaExpressionDataSamplesMapping

=over 4



=item Description

mapping between experimentMetaIds and ExperimentalUnitExpressionDataSamplesMapping it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExperimentMetaID and the value is an ExperimentalUnitExpressionDataSamplesMapping
</pre>

=end html

=begin text

a reference to a hash where the key is an ExperimentMetaID and the value is an ExperimentalUnitExpressionDataSamplesMapping

=end text

=back



=head2 StrainExpressionDataSamplesMapping

=over 4



=item Description

mapping between strainIds and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
</pre>

=end html

=begin text

a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap

=end text

=back



=head2 GenomeExpressionDataSamplesMapping

=over 4



=item Description

mapping between genomeIds and all StrainExpressionDataSamplesMapping it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping
</pre>

=end html

=begin text

a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping

=end text

=back



=head2 SampleLog2LevelMapping

=over 4



=item Description

mapping kbase sample id as the key and a single log2level (for a scpecified feature id, one mapping higher) as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SampleID and the value is a Log2Level
</pre>

=end html

=begin text

a reference to a hash where the key is a SampleID and the value is a Log2Level

=end text

=back



=head2 FeatureSampleLog2LevelMapping

=over 4



=item Description

mapping between FeatureIds and the mappings between samples and log2level mapping


=item Definition

=begin html

<pre>
a reference to a hash where the key is a FeatureID and the value is a SampleLog2LevelMapping
</pre>

=end html

=begin text

a reference to a hash where the key is a FeatureID and the value is a SampleLog2LevelMapping

=end text

=back



=cut

package ExpressionServicesClient::RpcClient;
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
