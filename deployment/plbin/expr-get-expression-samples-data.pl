#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Carp;
use Config::Simple;
use Bio::KBase::KBaseExpression::KBaseExpressionClient; 


my $DESCRIPTION =
qq^
NAME
expr-get-expression-samples-data -- This command returns mapping of SampleID to expressionSampleDataStructure 
                                    given a list of KBase sample IDs.  ExpressionSampleDataStructure 
                                    is essentially the core Expression Sample Object) : {sample_id -> 
                                    expressionSampleDataStructure}.

VERSION 
1.0

SYNOPSIS
expr-get-expression-samples-data [--help] [--sampleID ID] 

DESCRIPTION
INPUT:     The input for this command is a list of KBase sample IDs. 

OUTPUT:    This command returns an ExpressionDataSamplesMap. 

            expressionDataSamplesMap = obj->get_expression_samples_data(sampleIDs)

PARAMETERS:
--help                 Display help message to standard out and exit with error code zero;                                                    
                       ignore all other command-line arguments.
--sampleID             The KBase sample IDs. Datatype = string.
                       Multiple sample IDs can be submitted, as:
                       " -sampleID='kb|sample.3746' -sampleID='kb|sample.3747' "   

EXAMPLES
perl expr-get-expression-samples-data.pl -sampleID='kb|sample.3746' -sampleID='kb|sample.3747' 
  
AUTHOR: Jason Baumohl (jkbaumohl\@lbl.gov) 

Details For returned Datastructure: 
    SampleIDs is a reference to a list where each element is a SampleID
    SampleID is a string
    ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
    ExpressionDataSample is a reference to a hash where the following keys are defined:
    sampleID has a value which is a SampleID
    sourceID has a value which is a string
    sampleTitle has a value which is a string
    sampleDescription has a value which is a string
    molecule has a value which is a string
    sampleType has a value which is a SampleType
    dataSource has a value which is a string
    externalSourceID has a value which is a string
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
    platformID has a value which is a string
    platformTitle has a value which is a string
    platformTechnology has a value which is a string
    experimentalUnitID has a value which is an ExperimentalUnitID
    experimentMetaID has a value which is an ExperimentMetaID
    experimentTitle has a value which is a string
    experimentDescription has a value which is a string
    environmentID has a value which is a string
    environmentDescription has a value which is a string
    protocolID has a value which is a string
    protocolDescription has a value which is a string
    protocolName has a value which is a string
    sampleAnnotations has a value which is a SampleAnnotations
    seriesIDs has a value which is a SeriesIDs
    personIDs has a value which is a PersonIDs
    sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
    dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
    SampleType is a string
    StrainID is a string
    GenomeID is a string
    ExperimentalUnitID is a string
    ExperimentMetaID is a string
    SampleAnnotations is a reference to a list where each element is a SampleAnnotation
    SampleAnnotation is a reference to a hash where the following keys are defined:
    sampleAnnotationID has a value which is a SampleAnnotationID
    ontologyID has a value which is an OntologyID
    ontologyName has a value which is an OntologyName
    ontologyDefinition has a value which is an OntologyDefinition
    SampleAnnotationID is a string
    OntologyID is a string
    OntologyName is a string
    OntologyDefinition is a string
    SeriesIDs is a reference to a list where each element is a SeriesID
    SeriesID is a string
    PersonIDs is a reference to a list where each element is a PersonID
    PersonID is a string
    SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
    DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
    FeatureID is a string
    Measurement is a float
^;


my @sampleID;
my $help = undef;
my $h = undef;
my $man = undef;

# first parse command line options
my $opt = GetOptions (
        "help" => \$help,
        "h" => \$h,
        "man" => \$man,
        "sampleID=s" => \@sampleID,
    );
if (defined($h) || defined($help) || defined($man)) {
    print $DESCRIPTION;
    exit 0;
}
if (scalar(@sampleID) < 1)
{
    print "NOTE This requires SampleIDs to passed in.\n   ".
	$DESCRIPTION;
    exit 1;
}


our $cfg = {};
if (defined $ENV{KB_DEPLOYMENT_CONFIG} && -e $ENV{KB_DEPLOYMENT_CONFIG}) 
{
    $cfg = new Config::Simple($ENV{KB_DEPLOYMENT_CONFIG}) or
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => Config::Simple->error(),
							       method_name => 'new');
}
else {
    $cfg = new Config::Simple(syntax=>'ini') or
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => Config::Simple->error(),
							       method_name => 'new'); 
    $cfg->param('KBaseExpression.dbName', 'kbase_sapling_v3'); 
    $cfg->param('KBaseExpression.dbUser', 'kbase_sapselect'); 
#    $cfg->param('KBaseExpression.userData', 'kbase_sapselect/');                                                                                                                         
    $cfg->param('KBaseExpression.dbhost', 'db3.chicago.kbase.us'); 
    $cfg->param('KBaseExpression.dbPwd', 'oiwn22&dmwWEe'); 
    $cfg->param('KBaseExpression.dbms', 'mysql'); 
}
my $service_url = "http://localhost:7075";
my $client = Bio::KBase::KBaseExpression::KBaseExpressionClient->new($service_url); 

print Dumper($client->get_expression_samples_data(\@sampleID));

exit 0; 


