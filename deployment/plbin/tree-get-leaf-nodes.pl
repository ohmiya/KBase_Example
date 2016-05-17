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
      tree-get-leaf-nodes -- get a list of the names of leaf nodes

SYNOPSIS
      tree-get-leaf-nodes [OPTIONS] [NEWICK_TREE]

DESCRIPTION
      Given a tree in newick format, produce a list of the names of the leaf nodes.  If no
      no tree is provided as an argument on the commandline, then standard-in is parsed to
      read the tree.

      -i, --input
                        specify an input file to read from; if provided, any other arguments
                        and standard-in are ignored
      --url [URL]
                        set the KBaseTrees service url (optional)
      -h, --help
                        diplay this help message, ignore all other arguments
                        
                        
EXAMPLES
      Retrieve all the leaf nodes of a given newick tree
      > tree-get-leaf-nodes '(l1,((l2,l3)n2,(l4,l5)n3)n1)root;'
      l1
      l2
      l3
      l4
      l5

AUTHORS
      Matt Henderson (mhenderson\@lbl.gov)
      Michael Sneddon (mwsneddon\@lbl.gov)

      
";


my $help = '';
my $treeString='';
my $inputFile = '';
my $treeurl;

# parse arguments and output file
my $stdinString = "";
my $opt = GetOptions("help" => \$help,
                     "input=s" => \$inputFile,
                     "url=s" => \$treeurl);
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
     my $leaf_names;
     eval {
          $leaf_names = $treeClient->extract_leaf_node_names($treeString);
     };
     $client_error = $@;
     if ($client_error) {
          print Dumper($client_error);
          print "FAILURE - error calling Tree service.\n";
          exit 1;
     }
     
     foreach my $l (@$leaf_names) {
          print $l."\n";
     }
     exit 0;
     
} else {
     print "FAILURE - no tree specified.  Run with --help for usage.\n";
     exit 1;
}

exit 0;

