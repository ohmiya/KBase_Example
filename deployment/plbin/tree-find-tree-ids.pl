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
      tree-find-tree-ids -- search KBase for the tree IDs that match the input options

SYNOPSIS
      tree-find-tree-ids [OPTIONS] [FEATURE_ID|PROTEIN_ID|SOURCE_ID_PATTERN]

DESCRIPTION
      This method retrieves a list of trees that match the provided options.  If a feature ID
      is provided, all trees that are built from protein sequences of the feature are returned.
      If a protein ID is provided, then all trees that are built from the exact sequence is
      returned.  If a source id pattern is provided, then all trees with a source ID that match
      the pattern is returned.  Note that source IDs are generally defined by the gene family
      model which was used to identifiy the sequences to be included in the tree.  Therefore,
      matching a source ID is a convenient way to find trees for a specific set of gene
      families.
      
      By default, if the type of argument is not specified with one of the options below, then
      this method assumes that the input is feature IDs.  If an ID is to be passed in as an
      argument, then only a single ID or pattern can be used.  If you wish to call this method
      on multiple feature/sequence IDs, then you must pass in the list through standard-in or
      a text file, with one ID per line.
                        
      -f, --feature
                        indicate that the IDs provided are feature IDs; matches of feature
                        IDs are exact
                        
      -p, --protein-sequence
                        indicate that the IDs provided are protein_sequence_ids (MD5s); matches
                        of protein sequence IDs are exact
                        
      -s, --source-id-pattern
                        Indicate that the input is a pattern used to match the source-id field
                        of the Tree entity.  The pattern is very simple and includes only two
                        special characters, wildcard character, '*', and a match-once character,
                        '.'  The wildcard character matches any number (including 0) of any
                        character, the '.' matches exactly one of any character.  These special
                        characters can be escaped with a backslash.  To match a blackslash
                        literally, you must also escape it.  When the source-id-pattern option
                        is provided, then this method returns a two column list, where the first
                        column is the tree ID, and the second column is the source-id that was
                        matched. Note that source IDs are generally defined by the gene family
                        model which was used to identifiy the sequences to be included in the
                        tree.  Therefore, matching a source ID is a convenient way to find trees
                        for a specific set of gene families.

      -i, --input
                        specify input file to read from;  each id or pattern must
                        be on a separate line in this file
     
      --url [URL]
                        set the KBaseTrees service url (optional)
                        
      -h, --help
                        diplay this help message, ignore all arguments
                        
EXAMPLES
      Retrieve tree ids based on a feature id
      > tree-find-tree-ids -f 'kb|g.0.peg.2173'
      
      Retrieve tree ids based on a set of protein_sequence_ids piped through standard in
      > echo cf9e9e74e06748fb161d07c8420e1097 | tree-find-tree-ids -p
      
      Retrieve tree ids based on a pattern used to match the source-id field
      > tree-find-tree-ids -s '*COG.11'
      
      Get the number of leaf nodes for trees with a source id field in the range COG10-COG11.
      First, we find tree ids, extract out only the tree IDs using 'cut', then pipe the results
      to 'tree-get-tree' to get meta information about each tree, and grep to extract the
      results we want.
      >  tree-find-tree-ids -s 'COG1.' | cut -f 1 | \
             tree-get-tree -m | grep 'tree_id\|source_id\|leaf_count'

AUTHORS
      Michael Sneddon (mwsneddon\@lbl.gov)
      Matt Henderson (mhenderson\@lbl.gov)
      
";



# declare variables that come from user input
my $help = '';
my $usingFeature = "";
my $usingSequence = "";
my $inputFile = "";
my $usingFamily = "";
my $showSourceId = "";
my $treeurl;

# first parse command line options
my $opt = GetOptions (
        "help" => \$help,
        "feature" => \$usingFeature,
        "protein-sequence" => \$usingSequence,
        "source-id-pattern" => \$usingFamily,
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
else {
     print "Invalid number of arguments.  Run with --help for usage.\n";
     exit 1;
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
     if($usingFamily) {
          foreach my $pattern (@$id_list) {
               my $tree_ids;
               eval {
                    $tree_ids = $treeClient->get_tree_ids_by_source_id_pattern($pattern);
               };
               $client_error = $@;
               if ($client_error) {
                    print Dumper($client_error);
                    print "FAILURE - error calling Tree service.\n";
                    exit 1;
               }
               foreach my $t (@$tree_ids) {
                    print $t->[0]."\t".$t->[1]."\n";
               }
          }
     }
     elsif($usingSequence) {
          my $tree_ids;
          eval {
               $tree_ids = $treeClient->get_tree_ids_by_protein_sequence($id_list);
          };
          $client_error = $@;
          if ($client_error) {
               print Dumper($client_error);
               print "FAILURE - error calling Tree service.\n";
               exit 1;
          }
          foreach my $t (@$tree_ids) {
               print $t."\n";
          }
     } else {
          my $tree_ids;
          eval {
               $tree_ids = $treeClient->get_tree_ids_by_feature($id_list);
          };
          $client_error = $@;
          if ($client_error) {
               print Dumper($client_error);
               print "FAILURE - error calling Tree service.\n";
               exit 1;
          }
          foreach my $t (@$tree_ids) {
               print $t."\n";
          }
     }
     exit 0;
} else {
     print "FAILURE - no ids provided.  Run with --help for usage.\n";
     exit 1;
}