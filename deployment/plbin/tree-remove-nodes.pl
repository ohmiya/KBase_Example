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
      tree-remove-nodes -- remove nodes by label in a tree and simplify the tree

SYNOPSIS
      tree-remove-nodes [OPTIONS] [NEWICK_TREE]

DESCRIPTION
     Given a tree in newick format, remove the nodes with the given names indicated
     in the list, and simplify the tree.  Simplifying a tree involves removing unnamed
     internal nodes that have only one child, and removing unnamed leaf nodes.  During
     the removal process, edge lengths (if they exist) are conserved so that the summed
     end to end distance between any two nodes left in the tree will remain the same.
     If the tree is not provided as an argument and no input file is specified,
     the tree is read in from standard-in.
      
      -r [FILE_NAME], --removal-list [FILE_NAME]
                        specify the file name of the list of nodes to remove; this file should
                        be a one column file where each line contains the name of the node to
                        remove; if multiple nodes have a identical labels, they are all
                        removed; instead of a file, you can also provide a string listing the
                        nodes to be removed, in which case they should be delimited by a ';'
                        
      -s [FILE_NAME], --save-list [FILE_NAME]
                        instead of specifying the set set of nodes to remove, this flag indicates
                        that the list includes the list of nodes to save; if a node label is
                        on this list it is saved, otherwise it is removed; instead of a file,
                        you can also provide a string listing the nodes to be removed, in which
                        case they should be delimited by a ';'
                        
      -z, --merge-zero-distance-leaves
                        after other removal operations have been performed, setting this flags
                        specifies that all leaves with distance zero are merged into a single
                        leaf, and an arbitrary leaf is kept.
                        
      -i [FILE_NAME], --input [FILE_NAME]
                        specify an input file to read the tree from
     
      --url [URL]
                        set the KBaseTrees service url (optional)
     
      -h, --help
                        diplay this help message, ignore all arguments
                        
                        
EXAMPLES
      Replace node names based on the file mapping.txt
      > cat removal_list.txt
      mr_tree
      > tree-remove-nodes -r removal_list.txt '(l1,mr_tree,l3,l4)root;'
      (l1,l3,l4)root;

AUTHORS
      Michael Sneddon (mwsneddon\@lbl.gov)
      Matt Henderson (mhenderson\@lbl.gov)

";


my $help = '';
my $treeString='';
my $inputFile = '';
my $removalFile = '';
my $saveFile = '';
my $mergeZeroDistLeaves='';
my $treeurl;

# parse arguments and output file
my $stdinString = "";
my $opt = GetOptions("help" => \$help,
                     "input=s" => \$inputFile,
                     "removal-list=s" => \$removalFile,
                     "save-list=s" => \$saveFile,
                     "merge-zero-distance-leaves|z" => \$mergeZeroDistLeaves,
                     "url=s" => \$treeurl
                     );
if($help) {
     print $DESCRIPTION;
     exit 0;
}

my $n_args = $#ARGV + 1;
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
               $treeString = $treeString.$line;
          }
          close $inputFileHandle;
     };
}

# if we have a single argument, then accept it as the treeString
elsif($n_args==1) {
     $treeString = $ARGV[0];
     chomp($treeString);
}

# if we have no arguments, then read the tree from standard-in
elsif($n_args == 0) {
     while(my $line = <STDIN>) {
          chomp($line);
          $treeString = $treeString.$line;
     }
}

# otherwise we have some bad number of commandline args
else {
    print "Bad options / Invalid number of arguments.  Run with --help for usage.\n";
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

# make sure we got something out of all of that
if ($treeString ne '') {
     
     my $removalList = [];
     my $removalHash = {};
     if($removalFile) {
          
          if (-e $removalFile) {
               my $inputFileHandle;
               open($inputFileHandle, "<", $removalFile);
               if(!$inputFileHandle) {
                    print STDERR "FAILURE - cannot open removal list file '$removalFile' \n$!\n";
                    exit 1;
               }
               #eval {
                    my $line_number =0;
                    while (my $line = <$inputFileHandle>) {
                         $line_number++;
                         chomp($line);
                         if($line eq '') { next; }
                         push @$removalList, $line;
                         $removalHash->{$line} = '1';
                    }
                    close $inputFileHandle;
               #};
          } else {
               my @lines = split(/;/,$removalFile);
               foreach my $line (@lines) {
                    chomp($line);
                    if($line eq '') { next; }
                    push @$removalList, $line;
                    $removalHash->{$line} = '1';
               }
          }
     }
     
     if($saveFile) {
          my $save_hashed_list = {};
          my $inputFileHandle;
          
          if (-e $saveFile) {
               open($inputFileHandle, "<", $saveFile);
               if(!$inputFileHandle) {
                    print STDERR "FAILURE - cannot open save list file '$saveFile' \n$!\n";
                    exit 1;
               }
               #eval {
                    my $line_number =0;
                    while (my $line = <$inputFileHandle>) {
                         $line_number++;
                         chomp($line);
                         if($line eq '') { next; }
                         $save_hashed_list->{$line} = '1';
                    }
                    close $inputFileHandle;
               #};
          } else {
                my @lines = split(/;/,$saveFile);
               foreach my $line (@lines) {
                    chomp($line);
                    if($line eq '') { next; }
                    $save_hashed_list->{$line} = '1';
               }
          }
               
          #print Dumper($save_hashed_list)."\n";
          my $all_node_names = $treeClient->extract_leaf_node_names($treeString);
          foreach my $name (@$all_node_names) {
               if(!exists $save_hashed_list->{$name}) {
                    push @$removalList, $name;
               } else {
                    if(exists $removalHash->{$name}) {
                         print STDERR "FAILURE - node '$name' is in both the removal list and the save list!\n";
                         exit 1;
                    }
               }
          }
     }
     
     #print Dumper($removalList)."\n";
     my $new_tree;
     eval {
          $new_tree = $treeClient->remove_node_names_and_simplify($treeString, $removalList);
          if($mergeZeroDistLeaves) {
               $new_tree = $treeClient->merge_zero_distance_leaves($new_tree);
          }
     };

     $client_error = $@;
     if ($client_error) {
          print Dumper($client_error);
          print STDERR "FAILURE - error calling Tree service.\n";
          exit 1;
     }
     

     print $new_tree."\n";
     exit 0;
     
} else {
     print STDERR "FAILURE - no tree specified.  Run with --help for usage.\n";
     exit 1;
}

exit 0;


