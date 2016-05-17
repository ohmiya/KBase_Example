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
      tree-find-alignment-ids -- returns the alignment IDs that align the specified sequence or feature

SYNOPSIS
      tree-find-alignment-ids [OPTIONS] [ID]

DESCRIPTION
      Given a KBase feature or sequence ID, retrieve the set of alignments that align the
      given feature/sequence.  By default, if the type of ID is not specified with one of the
      options below, then this method assumes that IDs are feature IDs.  If an ID is to be
      passed in as an argument, then only a single ID can be used.  If you wish to call this
      method on multiple feature/sequence IDs, then you must pass in the list through standard-in
      or a text file, with one ID per line.
                        
      -f, --feature
                        indicate that the IDs provided are feature IDs
      -p, --protein-sequence
                        indicate that the IDs provided are protein_sequence_ids (MD5s)                        
      -i, --input
                        specify input file to read from;  each feature/sequence id must
                        be on a separate line in this file
      --url [URL]
                        set the KBaseTrees service url (optional)
      -h, --help
                        diplay this help message, ignore all arguments
                        
EXAMPLES
      Retrieve alignment ids based on a feature id
      > tree-find-alignment-ids -f 'kb|g.0.peg.2173'
      
      Retrieve alignment ids based on a set of protein_sequence_ids piped through standard in
      > echo cf9e9e74e06748fb161d07c8420e1097 | tree-find-alignment-ids -p

AUTHORS
      Matt Henderson (mhenderson\@lbl.gov)
      Michael Sneddon (mwsneddon\@lbl.gov)
      
";



# declare variables that come from user input
my $help = '';
my $usingFeature = "";
my $usingSequence = "";
my $inputFile = "";
my $treeurl;

# first parse command line options
my $opt = GetOptions (
        "help" => \$help,
        "feature" => \$usingFeature,
        "protein-sequence" => \$usingSequence,
        "input=s" => \$inputFile,
        "url=s" => \$treeurl
        );
if ($help) {
     print $DESCRIPTION;
     exit 0;
}

my $n_args = $#ARGV + 1;

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
}

#create client
my $treeClient;
eval{ $treeClient = get_tree_client($treeurl); };
my $client_error = $@;
if ($client_error) {
     print Dumper($client_error);
     print "FAILURE - unable to create tree service client.  Is you tree URL correct? see tree-url.\n";
     exit 1;
}

# if we have some ids, we can continue;
if(scalar(@$id_list)>0) {
     if($usingSequence) {
          my $alignment_ids;
          eval {
               $alignment_ids = $treeClient->get_alignment_ids_by_protein_sequence($id_list);
          };
          $client_error = $@;
          if ($client_error) {
               print Dumper($client_error);
               print "FAILURE - error calling Tree service.\n";
               exit 1;
          }
          foreach my $t (@$alignment_ids) {
               print $t."\n";
          }
     } else {
          my $alignment_ids;
          eval {
               $alignment_ids = $treeClient->get_alignment_ids_by_feature($id_list);
          };
          $client_error = $@;
          if ($client_error) {
               print Dumper($client_error);
               print "FAILURE - error calling Tree service.\n";
               exit 1;
          }
          foreach my $t (@$alignment_ids) {
               print $t."\n";
          }
     }
     exit 0;
} else {
     print "FAILURE - no ids provided.  Run with --help for usage.\n";
     exit 1;
}