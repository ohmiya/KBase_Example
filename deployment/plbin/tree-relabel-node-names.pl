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
      tree-relabel-node-names -- allows you to relabel node names in a newick tree

SYNOPSIS
      tree-relabel-node-names [OPTIONS] [NEWICK_TREE]

DESCRIPTION
     Given a tree in newick format, relabel the specified nodes with replacement names found in
     a mappingfile.  If the tree is not provided as an argument and no input file is specified,
     the tree is read in from standard-in.
      
      -r, --replacement-file
                        specify the file name of the replacement mappings; this file should
                        be a two column file, with columns delimited by tabs, where the first
                        column indicates names to search for in the tree, and the second column
                        indicates the replacement string; the replacement string can be blank;
                        
      -i, --input
                        specify an input file to read the tree from
                        
      --url [URL]
                        set the KBaseTrees service url (optional)
                        
      -h, --help
                        diplay this help message, ignore all arguments
                        
                        
EXAMPLES
      Replace node names based on the file mapping.txt
      > cat mapping.txt
      l1	r1
      l2	mr_tree
      l3	
      > tree-relabel-node-names -r mapping.txt '(l1,l2,l3,l4)root;'
      (r1,mr_tree,,l4)root;

AUTHORS
      Michael Sneddon (mwsneddon\@lbl.gov)
      Matt Henderson (mhenderson\@lbl.gov)

";


my $help = '';
my $treeString='';
my $inputFile = '';
my $replacementFile = '';
my $treeurl;

# parse arguments and output file
my $stdinString = "";
my $opt = GetOptions("help" => \$help,
                     "input=s" => \$inputFile,
                     "replacement-file=s" => \$replacementFile,
                     "url=s" => \$treeurl
                     );
if($help) {
     print $DESCRIPTION;
     exit 0;
}
if(!$replacementFile) {
     print "FAILURE - no replacement mapping provided.  Run with -h for usage.\n";
     exit 1;
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
     
     my $replacementMapping = {};
     my $inputFileHandle;
     open($inputFileHandle, "<", $replacementFile);
     if(!$inputFileHandle) {
          print "FAILURE - cannot open replacement file '$replacementFile' \n$!\n";
          exit 1;
     }
     eval {
          my $line_number =0;
          while (my $line = <$inputFileHandle>) {
               $line_number++;
               chomp($line);
               if($line eq '') { next; }
               my @tokens = split("\t",$line);
               if(scalar (@tokens) > 2) {
                    print "FAILURE - malformed replacement file input on line $line_number.  Only two tab delimited columns permitted.\n";
                    exit 1;
               }
               if(scalar (@tokens) == 2) {
                    $replacementMapping->{$tokens[0]}=$tokens[1];
               } elsif(scalar (@tokens) == 1) {
                    $replacementMapping->{$tokens[0]}='';
               }
          }
          close $inputFileHandle;
     };
     my $new_tree;
     eval {
          $new_tree = $treeClient->replace_node_names($treeString, $replacementMapping);
     };

     $client_error = $@;
     if ($client_error) {
          print Dumper($client_error);
          print "FAILURE - error calling Tree service.\n";
          exit 1;
     }

     print $new_tree."\n";
     exit 0;
     
} else {
     print "FAILURE - no tree specified.  Run with --help for usage.\n";
     exit 1;
}

exit 0;


