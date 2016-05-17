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
      tree-get-leaf-id-mapping -- get a mapping from the leaf ids to protein/feature ids

SYNOPSIS
      tree-find-tree-ids [OPTIONS] [TREE_ID]

DESCRIPTION
      Given a tree, this script returns a two column mapping file of internal leaf ids to
      protein sequence or KBase feature IDs.  If the leaf was based on a concatenated sequence,
      this method currently only returns the first sequence ID.  If no canonical feature id
      exists, then none is returned. If a tree ID is not passed in as an argument, then it
      will be read from standard in or an input file.  This method currently only handles one
      tree at a time.  If a list is provided, only the first tree id in the list will be used
                        
      -f, --feature
                        indicate that the IDs should be mapped to feature IDs
                        
      -p, --protein-sequence
                        indicate that the IDs should be mapped to protein sequence IDs

      -i, --input
                        specify input file to read from;  each tree id must
                        be on a separate line in this file
                        
      --url [URL]
                        set the KBaseTrees service url (optional)
                        
      -h, --help
                        diplay this help message, ignore all arguments
                        
EXAMPLES
      Retrieve a mapping from raw leaf node ids to feature ids
      > tree-get-leaf-id-mapping -f 'kb|tree.1000000' 
      

AUTHORS
      Michael Sneddon (mwsneddon\@lbl.gov)
      Matt Henderson (mhenderson\@lbl.gov)
      
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

my $id_list;
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
     if($usingFeature) {
          foreach my $id (@$id_list) {
               my $fids;
               eval {
                    $fids = $treeClient->get_leaf_to_feature_map($id);
               };
               $client_error = $@;
               if ($client_error) {
                    print Dumper($client_error);
                    print "FAILURE - error calling Tree service.\n";
                    exit 1;
               }
               foreach my $f (sort keys %$fids) {
                    print $f."\t".$fids->{$f}."\n";
               }
               # ONLY HANDLE THE FIRST TREE ID
               exit 0;
          }
     }
     elsif($usingSequence) {
          foreach my $id (@$id_list) {
               my $pids;
               eval {
                    $pids = $treeClient->get_leaf_to_protein_map($id);
               };
               $client_error = $@;
               if ($client_error) {
                    print Dumper($client_error);
                    print "FAILURE - error calling Tree service.\n";
                    exit 1;
               }
               foreach my $p (sort keys %$pids) {
                    print $p."\t".$pids->{$p}."\n";
               }
               # ONLY HANDLE THE FIRST TREE ID
               exit 0;
          }
          # ONLY HANDLE THE FIRST TREE ID
          exit 0;
     } else {
          print "FAILURE - did not specify if mapping should be features or sequences.  Run with --help for usage.\n";
     }
     exit 0;
} else {
     print "FAILURE - no ids provided.  Run with --help for usage.\n";
     exit 1;
}