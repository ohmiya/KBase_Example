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
get_expression_data_by_samples_and_features.pl -- This command returns an ExpressionDataSamplesMap.  

VERSION
1.0

SYNOPSIS
get_expression_data_by_samples_and_features [--sampleID ID] [--featureID ID]

DESCRIPTION
INPUT:     The input for this command is one or more sample IDs and/or feature IDs. 
OUTPUT:    The output file for this command is an ExpressionDataSamplesMap.

PARAMETERS:

--sampleID          The KBase sample IDs. Datatype = string. 
                    Multiple sample IDs can be submitted, as 
                    " -sampleID='kb|sample.2' -sampleID='kb|sample.3' "

--featureID         The KBase feature IDs. Datatype = string.                
                    Multiple feature IDs can be submitted, as
                    "  -featureID='kb|g.20848.CDS.1800' -featureID='kb|g.20848.CDS.1687' "
                    If no feature IDs are entered, then all features with measurement values will be      
                    returned.

--help             Display help message to standard out and exit with error code zero;                                                    
                   ignore all other command-line arguments.      


EXAMPLES
perl expr-get-expression-data-by-samples-and-features.pl -sampleID='kb|sample.5759' -sampleID='kb|sample.5079' -featureID='kb|g.3899.CDS.39001' -featureID='kb|g.3899.CDS.39003'
 
perl expr-get-expression-data-by-samples-and-features.pl -sampleID='kb|sample.5759' -sampleID='kb|sample.5079'  (if you want all features with measurments) 

AUTHORS
    Jason Baumohl (jkbaumohl\@lbl.gov)
^;


my @sampleID;
my @featureID;
my $help = undef;
my $h = undef;
my $man = undef;

# first parse command line options
my $opt = GetOptions (
        "help" => \$help,
        "h" => \$h,
        "man" => \$man,
        "sampleID=s" => \@sampleID,
        "featureID=s" => \@featureID,
    );
if (defined($h) || defined($help) || defined($man)) {
    print $DESCRIPTION;
    exit 0;
}
if (scalar(@sampleID) < 1 )
{
    print "NOTE This requires SampleIDs to passed in.\n    
           Ex: perl expr-get-expression-data-by-samples-and-features.pl -sampleID=''kb|sample.5759' -sampleID=''kb|sample.5079' -featureID=kb|g.3899.CDS.39001' -featureID='kb|g.3899.CDS.39003' \n".
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

print Dumper($client->get_expression_data_by_samples_and_features(\@sampleID,\@featureID));

exit 0; 


