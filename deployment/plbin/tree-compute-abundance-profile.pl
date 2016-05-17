#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;

use Bio::KBase::KBaseTrees::Client;
use Bio::KBase::KBaseTrees::Util qw(get_tree_client);

my $DESCRIPTION =
"
NAME
      tree-compute-abundance-profile -- maps reads from a metagenomic sample to abundance counts on a tree

SYNOPSIS
      tree-compute-abundance-profile [OPTIONS]

DESCRIPTION
      This method retrieves the set of metagenomic reads from a metagenomic sample that have been assigned
      to the specified gene family.  Each read is mapped to a best hit protein sequence that corresponds to
      a leaf in the specified KBase tree using uclust.  The result is printed to standard out as a tab
      delimited file, and status messages on progress and results are printed to standard error.
      
      -t [ID], --tree-id [ID]
                        set this flag to specify the KBase ID of the tree to compute
                        abundances for; the tree is used to identify the set of sequences
                        that were aligned to build the tree; each leaf node of a tree built
                        from an alignment willbe mapped to a sequence; this script assumes
                        that trees are built from protein sequences
                        
      -m [ID1;ID2;ID3;...IDN;], --metagenomic-sample-id [ID1;ID2;ID3;...IDN;]
                        set this flag to specify the IDs of the metagenomic samples to lookup;
                        if there are multiple samples to lookup, pass a list of IDs without
                        spaces delimited by a semicolon; see the KBase communities service to
                        identifiy metagenomic sample ids, and the example below for 
                        
      -a [KEY], --auth [KEY]
                        set this flag to specify the authentication key that you generated with
                        MG Rast to access private datasets; public data sets do not require
                        this flag
                        
      -s [SOURCE], --source-family [SOURCE]
                        set this flag to specify the name of the source of the protein family;
                        currently supported protein families are: 'COG';
                        default value is set to 'COG'
                        
      -f [NAME], --family-name [NAME]
                        set this flag to specify the name of the protein family used to pull
                        a small set of reads from a metagenomic sample; currently only COG
                        families are supported
                        
      -p [VALUE], --percent-identity-threshold [VALUE]
                        set this flag to specify the minimum acceptable percent identity for
                        hits, provided as a percentage and not a fraction (i.e. set to 87.5
                        for 87.5%); default value is set to 50%
                        
      -l [VALUE], --length-threshold [VALUE]
                        set this flag to specify the minimum acceptable length of a match to
                        consider a hit; default value is set to 20
                        
      --url [URL]
                        set the KBaseTrees service url (optional)
                        
      -h, --help
                        display this help message, ignore all arguments
                        
                        

EXAMPLES
      Map reads to a tree and get an abundance profile for two metagenomic samples
      > tree-compute-abundance-profile -t 'kb|tree.991335' -f COG0556 -s COG -m '4502923.3;4502924.3'

SEE ALSO
     tree-normalize-abundance-profile
      
AUTHORS
      Michael Sneddon (mwsneddon\@lbl.gov)
      Keith Keller (kkeller\@lbl.gov)
      
";

my $help = '';
my $treeId = '';
my $mgIdList='';
my $protFamSrc='COG';
my $protFamName='';
my $pctIdt=50;
my $matchThreshold=20;
my $auth="";
my $treeurl;
my $opt = GetOptions (
        "help" => \$help,
        "tree-id=s" => \$treeId,
        "metagenomic-sample-id=s" => \$mgIdList,
        "source-family=s" => \$protFamSrc,
        "family-name=s" => \$protFamName,
        "percent-identity-threshold=f" => \$pctIdt,
        "length-threshold=i" => \$matchThreshold,
        "auth=s" => \$auth,
        "url=s" => \$treeurl
        );

if($help) {
     print $DESCRIPTION;
     exit 0;
}

my $n_args = $#ARGV+1;
if($n_args==0) {
    
    # make sure we have all we need
    if(!$treeId) {
        print STDERR "FAILURE - missing flag to specify a Tree ID.  Run with --help for usage.\n";
        exit 1;
    }
    if(!$mgIdList) {
        print STDERR "FAILURE - missing flag to specify a metagenomic sample ID.  Run with --help for usage.\n";
        exit 1;
    }
    if(!$protFamName) {
        print STDERR "FAILURE - missing flag to specify a protein family name.  Run with --help for usage.\n";
        exit 1;
    }
    
    #create client
    my $treeClient;
    eval{ $treeClient = get_tree_client($treeurl); };
    if(!$treeClient) {
        print STDERR "FAILURE - unable to create tree service client.  Is you tree URL correct? see tree-url.\n";
        exit 1;
    }
    
    # set up the output hash
    my $assembledResult = {}; # built as {mgID=>{leafId1=>count1,leafId2=>count2 ... }}
    my $allFoundLeafNodes = {}; # built as {leafHit=>1 ....}, if a leaf is not in here by the end, then it recieved 0 hits across all samples
    
    # split the metagenomic sample ids and iterate over each one
    my @mgIds = split(";",$mgIdList);
    foreach my $mgId (@mgIds) {
	    
	    my $result;
	    #eval {   #add eval block so errors don't crash execution, should really handle exceptions here.
	        my $params = {};
	        $params->{'protein_family_name'} = $protFamName;
	        $params->{'protein_family_source'} = $protFamSrc;
	        $params->{'metagenomic_sample_id'} = $mgId;
	        $params->{'tree_id'} = $treeId;
	        $params->{'percent_identity_threshold'} = $pctIdt;
	        $params->{'match_length_threshold'} = $matchThreshold;
	        $params->{'mg_auth_key'} = $auth;
	        
	    	# make the call
	        $result = $treeClient->compute_abundance_profile($params);
	    #};
	
	    if($result) {
	        my $abundance_profile = $result->{abundances};
	        $assembledResult->{$mgId} = $abundance_profile;
	        foreach my $leaf (keys %$abundance_profile) {
	        	$allFoundLeafNodes->{$leaf} = 1;
	        }
	        print STDERR "found $result->{n_hits} hits of $result->{n_reads} metagenomic reads for sample $mgId\n";
	    } else {
	        print STDERR "FAILURE - command did not execute successfully for metagenomic sample $mgId.\n";
	        exit 1;
	    }
    }
    
    
    # print the result (probably there is a more effecient way to aggregate the result, but who cares)
    print "#";
    foreach my $mgId (@mgIds) {
    	print "\t".$mgId;
    }
    print "\n";
    foreach my $leaf (sort keys %$allFoundLeafNodes) {
    	print $leaf;
    	foreach my $mgId (@mgIds) {
	    	if(exists $assembledResult->{$mgId}->{$leaf}) {
	    		print "\t".$assembledResult->{$mgId}->{$leaf};
	    	} else {
	    		print "\t0";
	    	}
    	}
    	print "\n";
    }
    
    exit 0;
}

print "Bad options / Invalid number of arguments.  Run with --help for usage.\n";
exit 1;

