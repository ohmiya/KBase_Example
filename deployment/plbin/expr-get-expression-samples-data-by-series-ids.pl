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
get_expression_samples_data_by_series_ids -- This command returns a SeriesExpressionDataSamplesMapping (a hash {seriesIDs -> ExpressionDataSamplesMap})

VERSION
1.0

SYNOPSIS
get_expression_samples_data_by_series_ids [--seriesID ID]

DESCRIPTION
INPUT:     The input for this command is one or more series IDs. 
OUTPUT:    The output file for this command is a SeriesExpressionDataSamplesMapping.

PARAMETERS:

--seriesID KBase series ids.  If have multiple series ids do the following : " -seriesID='kb|series.278' -sampleID='kb|series.279' "

--help     Display help message to standard out and exit with error code zero;                                                    
           ignore all other command-line arguments.  
    
EXAMPLES:
perl expr-get-expression-samples-data-by-series-ids.pl -seriesID='kb|series.278' -seriesID='kb|series.279'

AUTHOR: Jason Baumohl (jkbaumohl\@lbl.gov


Details of returned Data Structure: 
        seriesExpressionDataSamplesMapping is a SeriesExpressionDataSamplesMapping                                                         
        SeriesIDs is a reference to a list where each element is a SeriesID                                                                 
        SeriesID is a string                                                                                                                
        SeriesExpressionDataSamplesMapping is a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap            
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
PersonIDs is a reference to a list where each element is a PersonID                                                                 
PersonID is a string                                                                                                                
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID                                                     
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement                  
FeatureID is a string                                                                                                               
Measurement is a float
^;


my @seriesID;
my $help = undef;
my $h = undef;
my $man = undef;

# first parse command line options
my $opt = GetOptions (
        "help" => \$help,
        "h" => \$h,
        "man" => \$man,
        "seriesID=s" => \@seriesID,
    );
if (defined($h) || defined($help) || defined($man)) {
    print $DESCRIPTION;
    exit 0;
}
if (scalar(@seriesID) < 1)
{
    print "NOTE This requires SeriesIDs to passed in.\n    ".
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

print Dumper($client->get_expression_samples_data_by_series_ids(\@seriesID));

exit 0; 


