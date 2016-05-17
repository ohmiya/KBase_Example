#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

use Bio::KBase::KBaseTrees::Client;
use Bio::KBase::KBaseTrees::Util qw(getTreeURL);

my $DESCRIPTION =
"
NAME
      tree-create-group-file -- creates a group file for the tree-to-html command

SYNOPSIS
      tree-create-group-file [OPTIONS]

DESCRIPTION
      Given a list of leaf ids (one on each line) from standard in, prints to
      standard out a two column, tab delimited file with the IDs in the first
      column and the group name in the second column.  This group file places
      all nodes in the same group.  The group file can be used as input to
      tree-to-html.
      
      -g [GROUP_NAME], --group [GROUP_NAME]
                        specify the name of the group
      -h, --help
                        diplay this help message, ignore all arguments

EXAMPLES
      Display the current URL:
      > cat id.list | tree-create-group-file -g group1 > group.list
      
AUTHORS
      Michael Sneddon (mwsneddon\@lbl.gov)
      
";

# first parse options; only one here is help
my $help = '';
my $group = 'no_group_name_selected';
my $default = '';
my $opt = GetOptions (
        "help" => \$help,
        );
if($help) {
     print $DESCRIPTION;
     exit 0;
}

#retrieve or update the URL
my $n_args = $#ARGV+1;
if ($n_args == 0) {
    while (my $line = <STDIN>) {
	chomp $line;
        print $line."\t".$group."\n";
    }
    exit 0;
}

print "Invalid number of arguments.  Run with --help for usage.\n";
exit 1;

