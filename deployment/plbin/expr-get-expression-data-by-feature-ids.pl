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
NAME:
    get_expression_data_by_feature_ids.pl
    DESCRIPTION
    given a list of feature ids it returns a featureSampleMeasurementMapping {featureID}->{sampleID => value}}. 
VERSION: 1.0

INPUT & OUTPUT:
    Input - an array of KBase feature ids, a sample type and flag for wildtype only strains
    Output - a hash of feature ids that points to a hash of sample_ids and the corrsponding value for the feature.
            {featureID}->{sampleID => value}}. 

PARAMETERS: 
    --featureID :    kbase feature ids (string).  Multiple feature ids do the following : " -featureID='kb|g.3899.CDS.39003' -featureID='kb|g.3899.CDS.39001'  "
                     If no featureIDs are entered, then all features with measurment values will be returned.

    --sampleType :   The type of sample type (string) to limit results to.  Acceptable values (case ignored): 'microarray', 'RNA-Seq', 'qPCR' or 'proteomics'.
                     Any other passed value will be evaluated to no filter on sample type, thus including all sample types.    

    --wildTypeOnly : The WildTypeOnly is a flag indicating true or false.  
                     If equal to '1','Y' or 'TRUE' then only strains that are wild type will be included in the 
                     results. 
                     If equal to '0', 'N', or 'FALSE' then results will include all strains. 

    --help,--man :   Display help message to standard out and exit with error code zero;                                                    
                     ignore all other command-line arguments.
    
    featureSampleMeasurementMapping = obj->get_expression_data_by_feature_ids(featureIDs, sampleType, wildTypeOnly)

    Details : 
        featureIDs is a FeatureIDs
        sampleType is a SampleType
        wildTypeOnly is a WildTypeOnly
        featureSampleMeasurementMapping is a FeatureSampleMeasurementMapping
        FeatureIDs is a reference to a list where each element is a FeatureID
        FeatureID is a string
        SampleType is a string
        WildTypeOnly is a string ('Y','TRUE','1','N','FALSE','0')
        FeatureSampleMeasurementMapping is a reference to a hash where the key is a FeatureID and the value is a SampleMeasurementMapping
        SampleMeasurementMapping is a reference to a hash where the key is a SampleID and the value is a Measurement
        SampleID is a string
        Measurement is a float

EXAMPLE:
    perl expr-get-expression-data-by-feature-ids.pl -featureID='kb|g.3899.CDS.39003' -featureID='kb|g.3899.CDS.39001' -sampleType='microarray' -wildTypeOnly='Y'

    This will give a hash of the two feature ids as the key and then their value will be a hash.  
    That hash has samples (that have that feature id and are from strains that are wildtype) are the keys and value is the 
        expression value for the that feature in that sample.
    

AUTHORS:
    Jason Baumohl (jkbaumohl\@lbl.gov)
^;


my @featureID;
my $sampleType = undef;
my $wildTypeOnly = undef;
my $help = undef;
my $h = undef;
my $man = undef;

# first parse command line options
my $opt = GetOptions (
    "help" => \$help,
    "h" => \$h,
    "man" => \$man,
    "featureID=s" => \@featureID,
    "sampleType=s" =>\$sampleType,
    "wildTypeOnly=s" => \$wildTypeOnly
    );
if (defined($h) || defined($help) || defined($man)) {
    print $DESCRIPTION;
    exit 0;
}
if (scalar(@featureID) < 1 )
{
    print "NOTE This requires FeatureIDs to passed in.\n    ".
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

print Dumper($client->get_expression_data_by_feature_ids(\@featureID,$sampleType,$wildTypeOnly));

exit 0; 


