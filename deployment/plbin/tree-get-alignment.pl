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
      tree-get-alignment -- retrieve alignment or alignment meta data from the CDS

SYNOPSIS
      tree-get-alignment  [OPTIONS] [TREE_ID]

DESCRIPTION
      Retrieve the specified alignment or meta information associated with the alignment.
      The alignment is returned in FASTA format by default with sequence labels in an
      arbitrary internal id that is unique only within the given alignment. To return the
      alignment with node labels replaced with KBase protein sequence IDs or cannonical
      feature IDs, use the options below.  To provide a list of IDs, pipe in the list
      through standard-in or specify an input file to read.  In either case, each alignment
      id should appear on a separate line.  In the case of a list, results are returned
      in the same order they were provided as input.
      
      -p, --protein-sequence
                        set this flag to return the alignment with sequence labels replaced with
                        protein sequence IDs
                        
      -f, --feature
                        set this flag to return the alignment with sequence labels replaced with KBase
                        feature IDs.  Note that some alignments may not have assigned cannonical
                        feature IDs for each node, in which case blank labels will be returned.
                        
      -m, --meta
                        set this flag to return meta data instead of the tree itself
                        
      -i, --input [FILENAME]
                        set this flag to specify the input file to read
     
      --url [URL]
                        set the KBaseTrees service url (optional)
                        
      -h, --help
                        diplay this help message, ignore all arguments
                        
                        

EXAMPLES
      Retrieve the raw alignment in FASTA
      > tree-get-alignment 'kb|aln.25'
      
      Retrieve meta data about an alignment
      > tree-get-alignment -m 'kb|aln.25'
      
SEE ALSO
      tree-find-alignment-ids
      
AUTHORS
      Michael Sneddon (mwsneddon\@lbl.gov)
      
";

my $help = '';
my $metaFlag = '';
my $replaceFeature='';
my $replaceSequence='';
my $inputFile='';
my $treeurl;
my $opt = GetOptions (
        "help" => \$help,
        "meta" => \$metaFlag,
        "feature" => \$replaceFeature,
        "protein-sequence" => \$replaceSequence,
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
          print "FAILURE - cannot open '$inputFile' \n$!\n";
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
     print "Invalid number of arguments.  Run with --help for usage.\n";
     exit 1;
}

my $treeClient;
eval{ $treeClient = get_tree_client($treeurl); };
if(!$treeClient) {
     print "FAILURE - unable to create tree service client.  Is you tree URL correct? see tree-url.\n";
     exit 1;
}
foreach my $alnId (@$id_list) {
    if($metaFlag) {
        #get meta data
        my $aln_data;
        # eval {   #add eval block so errors don't crash execution, should really handle exceptions here.
            ($aln_data) = $treeClient->get_alignment_data([$alnId]);
        # };
        if(exists $aln_data->{$alnId}) {
            my $metaData = $aln_data->{$alnId};

            print "[alignment_id]:\t".$alnId."\n";
            foreach my $label (keys %$metaData) {
               if($label eq 'tree_ids') {
                    print "[".$label."]:\t";
                    foreach my $t (@{$metaData->{$label}}) {
                         print $t."; ";
                    }
                    print "\n";
               } else {
                    print "[".$label."]:\t".$metaData->{$label}."\n";
               }
            }
        }
    } else {
        #get actual tree
        my $aln;
        # eval {   #add eval block so errors don't crash execution, should really handle exceptions here.
            my $options = {};
            if($replaceFeature && $replaceSequence) { print "FAILURE - cannot use -p option with -f; choose one or the other.\n"; exit 1; }
            if($replaceFeature) {$options->{sequence_label}='feature_id';}
            if($replaceSequence) {$options->{sequence_label}='protein_sequence_id';}
            ($aln) = $treeClient->get_alignment($alnId,$options);
        # };
        if($aln) { print $aln."\n"; }
    }
        
}

exit 0;

