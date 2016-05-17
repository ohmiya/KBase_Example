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
      tree-get-tree -- retrieve tree or tree meta data from the CDS

SYNOPSIS
      tree-get-tree [OPTIONS] [TREE_ID]

DESCRIPTION
      Retrieve the specified tree or meta information associated with the tree.  The
      raw tree is returned in newick format by default with leaf node labels in an
      arbitrary internal id that is unique only within the given tree.  By default, the
      raw tree stored in KBase is returned.  To return the tree with node labels replaced
      with KBase protein sequence IDs or cannonical feature IDs, use the options below.  To
      provide a list of tree IDs, pipe in the list through standard-in or specify an input
      file to read.  In either case, each tree id should appear on a separate line.  In the
      case of a list, results are returned in the same order they were provided as input.
      
      -p, --protein-sequence
                        set this flag to return the tree with node labels replaced with
                        protein sequence IDs
                        
      -f, --feature
                        set this flag to return the tree with node labels replaced with KBase
                        feature IDs.  Note that some trees may not have assigned cannonical
                        feature IDs for each node, in which case blank labels will be returned.
                        
      -e, --best-feature
                        set this flag to return the tree with node labels replaced with KBase
                        feature IDs, where one feature ID is selected for each leaf. Note that
                        in most cases, MANY feature IDs will map to one leaf, and this method
                        will just select one.  You should not assume that the same feature ID
                        will be selected over multiple runs as the metric for selecting the
                        best feature may change, or new features may be added to KBase!
                        
      -g, --best-genome
                        set this flag to return the tree with node labels replaced with KBase
                        genome IDs, where one genome ID is selected for each leaf. Note that
                        in most cases, MANY feature IDs (from many genomes) will map to one
                        leaf, and this method will just select one.  You should not assume
                        that the same genome ID will be selected over multiple runs as the
                        metric for selecting the best feature may change, or new features may
                        be added to KBase!
                        
      -b, --bootstrap-remove
                        set this flag to return the tree with bootstrap values removed
                        
      -d, --distance-remove
                        set this flag to return the tree without distance values removed
                        
      -m, --meta
                        set this flag to return meta data instead of the tree itself
                        
      -i, --input [FILENAME]
                        set this flag to specify the input file to read
     
      --url [URL]
                        set the KBaseTrees service url (optional)
                        
      -h, --help
                        diplay this help message, ignore all arguments
                        
                        

EXAMPLES
      Retrieve the raw tree newick string
      > tree-get-tree 'kb|tree.25'
      
      Retrieve meta data about a tree
      > tree-get-tree -m 'kb|tree.25'
      
      

SEE ALSO
      tree-find-tree-ids
      
AUTHORS
      Michael Sneddon (mwsneddon\@lbl.gov)
      
";

my $help = '';
my $metaFlag = '';
my $replaceFeature='';
my $replaceBestFeature='';
my $replaceBestGenome='';
my $replaceSequence='';
my $noBootstrap='';
my $noDist='';
my $inputFile='';
my $treeurl;
my $opt = GetOptions (
        "help|h" => \$help,
        "meta|m" => \$metaFlag,
        "feature|f" => \$replaceFeature,
        "best-feature|e" => \$replaceBestFeature,
        "best-genome|g" => \$replaceBestGenome,
        "protein-sequence|p" => \$replaceSequence,
        "bootstrap-remove|b" => \$noBootstrap,
        "distance-remove|d" => \$noDist,
        "input" => \$inputFile,
        "url=s" => \$treeurl
        );

if($help) {
     print $DESCRIPTION;
     exit 0;
}

my $n_args = $#ARGV+1;

my $id_list=[];
# if we have specified an input file, then read the file
if($inputFile) {
     my $inputFileHandle;
     open($inputFileHandle, "<", $inputFile);
     if(!$inputFileHandle) {
          print STDERR "FAILURE - cannot open '$inputFile' \n$!\n";
          exit 1;
     }
     eval {
          while (my $line = <$inputFileHandle>) {
               chomp($line);
               push @$id_list,$line;
          }
          close $inputFileHandle;
     };
}

# if we have a single argument, then accept it as the treeString
elsif($n_args==1) {
     my $id = $ARGV[0];
     chomp($id);
     push @$id_list,$id;
}

# if we have no arguments, then read the tree from standard-in
elsif($n_args == 0) {
     while(my $line = <STDIN>) {
          chomp($line);
          push @$id_list,$line;
     }
} else {
     print STDERR "Invalid number of arguments.  Run with --help for usage.\n";
     exit 1;
}

foreach my $treeId (@$id_list) {
    #create client
    my $treeClient;
    eval{ $treeClient = get_tree_client($treeurl); };
    if(!$treeClient) {
        print STDERR "FAILURE - unable to create tree service client.  Is you tree URL correct? see tree-url.\n";
        exit 1;
    }
    if($metaFlag) {
        #get meta data
        my $tree_data;
        # eval {   #add eval block so errors don't crash execution, should really handle exceptions here.
            ($tree_data) = $treeClient->get_tree_data([$treeId]);
        # };
        if(exists $tree_data->{$treeId}) {
            my $metaData = $tree_data->{$treeId};
            print "[tree_id]:\t".$treeId."\n";
            foreach my $label (keys %$metaData) {
                print "[".$label."]:\t".$metaData->{$label}."\n";
            }
        }
    } else {
        #get actual tree
        my $tree;
        # eval {   #add eval block so errors don't crash execution, should really handle exceptions here.
            my $options = {};
            
            my $replace_opt_count = 0;
            if($replaceFeature) {$options->{newick_label}='feature_id'; $replace_opt_count++;}
            if($replaceSequence) {$options->{newick_label}='protein_sequence_id';  $replace_opt_count++;}
            if($replaceBestFeature) {$options->{newick_label}='best_feature_id';  $replace_opt_count++;}
            if($replaceBestGenome) {$options->{newick_label}='best_genome_id';  $replace_opt_count++;}
            if( $replace_opt_count >= 2 ) { print STDERR "FAILURE - you can only select ONLY ONE of these options: [-p -f -e -g]\n"; exit 1; }
            
            if($noBootstrap) {$options->{newick_bootstrap}='none';}
            if($noDist) {$options->{newick_distance}='none';}
            
            ($tree) = $treeClient->get_tree($treeId,$options);
        # };
        if($tree) { print $tree."\n"; }
    }
        
}

exit 0;

