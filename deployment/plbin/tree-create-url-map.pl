#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

my $DESCRIPTION =
"
NAME
      tree-create-url-map -- given a list of ids, return URLs to feature pages

SYNOPSIS
      tree-create-url-map [OPTIONS]

DESCRIPTION
      Given an input file that is a list of IDs, where each ID is on a separate
      line, output a two column tab-delimited list of IDs in the first
      column and URLs on the second column with each ID appended to the end for
      use with the tree-to-html script.  If a list of IDs file is not specified,
      this method accepts the list through standard-in.
      
      -i, --input        specify an input file to read the list of ids
      -u, --url          specify the base url
      -h, --help         diplay this help message, ignore all arguments

EXAMPLES
      Get a list of KBase URLs for a feature list
      > head -n5 features.list 
      kb|g.19905.peg.13323
      kb|g.3282.peg.1481
      kb|g.3159.peg.1680
      kb|g.1181.peg.2601
      kb|g.341.peg.1961
      > tree-create-url-map -i features.list -u 'http://140.221.92.12/feature_info/feature.html?id='
      kb|g.19905.peg.13323	http://140.221.92.12/feature_info/feature.html?id=kb|g.19905.peg.13323
      kb|g.3282.peg.1481	http://140.221.92.12/feature_info/feature.html?id=kb|g.3282.peg.1481
      kb|g.3159.peg.1680	http://140.221.92.12/feature_info/feature.html?id=kb|g.3159.peg.1680
      kb|g.1181.peg.2601	http://140.221.92.12/feature_info/feature.html?id=kb|g.1181.peg.2601
      kb|g.341.peg.1961	http://140.221.92.12/feature_info/feature.html?id=kb|g.341.peg.1961
      ...
      
AUTHORS
      Michael Sneddon (mwsneddon\@lbl.gov)
      
";

# first parse options; only one here is help
my $help = '';
my $input = '';
my $url = '';
my $opt = GetOptions (
        "help" => \$help,
        "input=s" => \$input,
        "url=s" => \$url,
        );
if($help) {
     print $DESCRIPTION;
     exit 0;
}


my $n_args = $#ARGV + 1;

my $id_list=[];
# if we have specified an input file, then read the file
if($input) {
     my $inputFileHandle;
     open($inputFileHandle, "<", $input);
     if(!$inputFileHandle) {
          print "FAILURE - cannot open '$input' \n$!\n";
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

if($url) {
     # if we have some ids, we can continue;
     if(scalar(@$id_list)>0) {
          foreach my $id (@$id_list) {
               print $id."\t".$url.$id."\n";
          }
     } else {
          print "ID list is empty.  Run with --help for usage.\n";
          exit 1;
     }
} else {
     print "No base URL specified.  Run with --help for usage.\n";
     exit 1;
}
exit 0;