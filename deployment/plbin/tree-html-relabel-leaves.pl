#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;

my $DESCRIPTION =
"
NAME
      tree-html-relabel-leaves -- replace leaf ids with other labels

SYNOPSIS
      tree-html-relabel-leaves [OPTIONS]

DESCRIPTION
      Modify html tree to replace leaf ids with any label. Html tree input is taken as 
      STDIN or as a command line arg. Modified tree is STDOUT.

      -l, --label-file
                        Required. Give the path to the leaf label file. Only one value 
                        per leaf is considered. Data file format is tab-delimited, one 
                        row per leaf with the leaf ID as the first column and the label
                         as the second column.

      -t, --tree-html-file
                        Optional. Give the path to the html tree file, or provide as 
                        STDIN.
			
      -h, --help
                        display this help message, ignore all arguments
                        
EXAMPLES
      Add the labels file 'leaf_labels.txt' to html tree file 'tree1.html'
      > cat tree1.html | tree-html-relabel-leaves -l leaf_labels.txt > tree1_with_labels.html
      
      Same action as above, but with tree-html-file argument
      > tree-html-relabel-leaves -l leaf_labels.txt -t tree1.html > tree1_with_labels.html
      
SEE ALSO
      tree-to-html
      tree-html-relabel-leaves

AUTHORS
      Dylan Chivian (dcchivian\@lbl.gov)
      
";

my $help = '';
my $label_file = '';
my $tree_html_file = '';
my $opt = GetOptions (
    "help" => \$help,
    "label-file=s" => \$label_file,
    "tree-html-file=s" => \$tree_html_file
    );

if ($help) {
    print $DESCRIPTION;
    exit 0;
}


# Read html tree
#
my @tree_html_buf = ();
if ($tree_html_file) {
    my $tree_html_file_handle;
    open ($tree_html_file_handle, '<', $tree_html_file);
    if (! $tree_html_file_handle) {
        print STDERR "FAILURE - cannot open '$tree_html_file'\n$!\n";
        exit 1;
    }
    push (@tree_html_buf, $_) while (<$tree_html_file_handle>);
    close ($tree_html_file_handle);
} else {
    push (@tree_html_buf, $_) while (<STDIN>);
}


# Read labels
#
my %leaf_name = ();
my @label_buf = ();
my $label_file_handle;
open ($label_file_handle, '<', $label_file);
if (! $label_file_handle) {
    print STDERR "FAILURE - cannot open '$label_file'\n$!\n";
    exit 1;
}
push (@label_buf, $_)  while (<$label_file_handle>);
close ($label_file_handle);
foreach my $line (@label_buf) {
    chomp $line;
    my ($id, $label) = split (/\t/, $line);
    $leaf_name{$id} = $label;
}


# Filter html tree to replace ids with labels
#
my $in_pre = undef;
foreach my $line (@tree_html_buf) {
    if (! $in_pre) {
	if ($line =~ /^\<pre\>/) {
	    $in_pre = 'true';
	}
    }
    else {
	if ($line =~ /^\<\/pre\>/) {
	    $in_pre = undef;
	}
	else {
	    if ($line !~ /^\s*\<a name="key"\>/i &&
		$line !~ /^\s*\<a name="header"\>/i
		) {

		my $line_copy = $line;
		my $new_line = '';
		my $tree_chunk = '';
		my $leader = '';
		my $id = undef;

		if ($line =~ /^(\S+\<font\s+\S+\<\/font\>)/) {
		    $tree_chunk = $1;
		}
		elsif ($line =~ /^(\S+)/) {
		    $tree_chunk = $1;
		}
		$line_copy =~ s/^$tree_chunk//;
		$new_line .= $tree_chunk;

		# get old boxes
		while ($line_copy =~ s/^(\s*\<font color=\#\w{6}\>\&\#9608\;\<\/font\>\s*)//) {
		    $new_line .= $1;
		}

		# determine leaf id
		if ($line_copy =~ s/^(\s*\<span[^\>]*\>)([^\<\s]+)//) {
		    $leader = $1;
		    $id = $2;
		} elsif ($line_copy =~ s/^(\s*)(\S+)//) {
		    $leader = $1;
		    $id = $2;
		}
		if (defined $leaf_name{$id}) {
		    $new_line .= $leader.'<!--$id-->'.$leaf_name{$id};
		} else {
		    print STDERR "missing label for ID: '$id'\n";
		    $new_line .= $leader.'<i>'.$id.'</i>';
		}
		$new_line .= $line_copy;  # add the remainder


		if (! $id) {
		    print STDERR "Bad tree line (missing ID): '$line'\n";
		}
		else {
		    $line = $new_line;
		}

		#$line =~ s/(<span[^\>]*\>\s*)([^\<]+?)(\s*\<\/span\>\s*\<span[^\>]*\>[^\<]*\<\/span\>\s*\<span[^\>]*\>[^\<]*\<\/span\>\s*)$/$1."<!--$2-->".$leaf_name{$2}.$3/e;
	    }
	}
    }
    print $line;
}

exit 0;
