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
get_expression_samples_data_by_genome_ids [--genomeID ID] [--sampleType] [--wildTypeOnly]

DESCRIPTION
INPUT:     This command takes a list of Genome IDs, a SampleType and the WildTypeOnly flag.


OUTPUT:    This output of this command is a GenomeExpressionDataSamplesMapping, 
                GenomeId -> StrainId -> ExpressionDataSample. StrainId -> 
           ExpressionSampleDataStructure {genome_id -> {strain_id -> {sample_id -> expressionSampleDataStructure}}}
PARAMETERS:

--genomeID               The KBase genome ID.  
                         Multiple sample IDs can be submitted, as: 
                            " -genomeID='kb|g.3907'  -genomeID='kb|g.3899' "

--sampleType             The type of sample type to limit results to.  
                         Acceptable values (case ignored): microarray, RNA-Seq, qPCR or proteomics. 
                         Any other passed value will be evaluated to no filter on sample type, thus including all.
 
--wildTypeOnly          The WildTypeOnly is a flag indicating true or false.  
                        If equal to '1','Y' or 'TRUE' then only strains that are wild type will be included in the 
                        results. 
                        If equal to '0', 'N', or 'FALSE' then results will include all strains. 
                         

--help                  Display help message to standard out and exit with error code zero;                                                    
                        ignore all other command-line arguments.


EXAMPLES
perl expr-get-expression-samples-data-by-genome-ids.pl -genomeID='kb|g.3907' -genomeID='kb|g.0' -sampleType='microarray' -wildTypeOnly='Y'

AUTHOR: Jason Baumohl (jkbaumohl\@lbl.gov)

Details of the returned data structure : 
        genomeIDs is a GenomeIDs
        sampleType is a SampleType
        wildTypeOnly is a WildTypeOnly
        genomeExpressionDataSamplesMapping is a GenomeExpressionDataSamplesMapping
        GenomeIDs is a reference to a list where each element is a GenomeID
        GenomeID is a string
        SampleType is a string
        WildTypeOnly is an string ('Y','TRUE','1','N','FALSE','0')      
        GenomeExpressionDataSamplesMapping is a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping
        StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
        StrainID is a string
        ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
        SampleID is a string
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


my @genomeID;
my $sampleType = '';
my $wildTypeOnly = undef;
my $help = undef;
my $h = undef;
my $man = undef;

# first parse command line options
my $opt = GetOptions (
        "help" => \$help,
        "h" => \$h,
        "man" => \$man,
        "genomeID=s" => \@genomeID,
        "sampleType=s" => \$sampleType,
        "wildTypeOnly=s" => \$wildTypeOnly,
    );
if (defined($h) || defined($help) || defined($man)) {
    print $DESCRIPTION;
    exit 0;
}
if (scalar(@genomeID) < 1 )
{
    print "NOTE This requires genomeIDs to passed in.\n    ".
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

print Dumper($client->get_expression_samples_data_by_genome_ids(\@genomeID,$sampleType,$wildTypeOnly));

exit 0; 


