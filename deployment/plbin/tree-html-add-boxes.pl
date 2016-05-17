#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;

my $DESCRIPTION =
"
NAME
      tree-html-add-boxes -- add data values to tree leaves

SYNOPSIS
      tree-html-add-boxes [OPTIONS]

DESCRIPTION
      Modify html tree to include data values for each leaf as a heatmap.  Labels are 
      justified if not already aligned.  Html tree input is taken as STDIN or as a 
      command line arg. Modified tree is STDOUT.

      -d, --data-file
                        Required. Give the path to the data associated with each leaf.  
                        Data file format is tab-delimited, one row per leaf with the 
                        leaf ID as the first column and the data value(s) as the 
                        remaining columns.  Header first line is permitted, but must
                        have '#' in first column, and if present, will be used as 
                        as a key in the legend.  May rerun method with new
                        data file and additional column(s) will be appended.

      -t, --tree-html-file
                        Optional. Give the path to the html tree file, or provide 
                        as STDIN.

      -c, --color-scheme
                        Optional. Configure the color scheme for the heatmap. May 
                        be 'YB' for blue-black-yellow spectrum or 'RYB' for 
                        blue-yellow-red spectrum.
                        
      -h, --help
                        display this help message, ignore all arguments
                        
EXAMPLES
      Add the data from data file 'leaf_data_set1.txt' to html tree file 'tree1.html' using default RYB color scheme
      > cat tree1.html | tree-html-add-boxes -d leaf_data_set1.txt > tree1_with_data1.html
      
      Add the data from data file 'leaf_data_set2.txt' to previous output with color scheme 'YB'
      > tree-html-add_boxes -d leaf_data_set2.txt -t tree1_with_with_data1.html -c YB > tree1_with_data1+2.html
      
SEE ALSO
      tree-to-html
      tree-html-relabel-leaves

AUTHORS
      Dylan Chivian (dcchivian\@lbl.gov)
      
";

my $help = '';
my $data_file = '';
my $tree_html_file = '';
my $color_scheme = '';
my @out = ();
my $opt = GetOptions (
    "help" => \$help,
    "data-file=s" => \$data_file,
    "tree-html-file=s" => \$tree_html_file,
    "color-scheme=s" => \$color_scheme
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
	print STDERR "FAILURE - cannot open '$tree_html_file'\n";
	exit 1;
    }
    while (<$tree_html_file_handle>) {
	chomp;
	push (@tree_html_buf, $_);
    }
    close ($tree_html_file_handle);
} else {
    while (<STDIN>) {
	chomp;
	push (@tree_html_buf, $_) 
    }
}


# Read abundance info
#
my $data_set_name = $data_file;
$data_set_name =~ s!^.*/!!;
$data_set_name =~ s!\.[^\.]*$!!;
my %leaf_data = ();
my @header = ();
my $header_seen = undef;
my @vals = ();
my @min_val = ();
my @max_val = ();
my @range = ();
my $global_min_val = undef;
my @data_buf = ();
my $data_file_handle;
open ($data_file_handle, '<', $data_file);
if (! $data_file_handle) {
    print STDERR "FAILURE - cannot open '$data_file'\n";
    exit 1;
}
while (my $line = <$data_file_handle>) {
    push (@data_buf, $line);
}
close ($data_file_handle);
foreach my $line (@data_buf) {
    chomp $line;
    next if ($line =~ /^\s*$/);
    my ($id, @vals) = split (/\t/, $line);
    if (! $header_seen) {
        if($line =~ /^#/) {
            $header_seen = 'true';
	    push (@header, @vals);
        }
        # original method doesn't work if headers are numeric
	#foreach my $val (@vals) {
	#   if ($val !~ /^[\-\d\.\e]+$/) {   
        #   if($val =~ /^#/) {
	#	$header_seen = 'true';
	#	push (@header, @vals);
	#	last;
	#   }
	#}
	next  if ($header_seen);
    }
    $leaf_data{$id} = +[@vals];
    for (my $i=0; $i <= $#vals; ++$i) {
        if($vals[$i] ne '') { # we need to be able to handle null values
            $global_min_val = $vals[$i]  if (! defined $global_min_val || $global_min_val > $vals[$i]);
            $min_val[$i] = $vals[$i]  if (! defined $min_val[$i] || $min_val[$i] > $vals[$i]);
            $max_val[$i] = $vals[$i]  if (! defined $max_val[$i] || $max_val[$i] < $vals[$i]);
        }
    }
}
for (my $i=0; $i <= $#max_val; ++$i) {
    $range[$i] = $max_val[$i] - $min_val[$i];
}

# prepare key
#
my @spectrum_boxes = ();
for (my $i=0; $i <= 16; $i += 2) {
#for (my $i=0; $i <= 16; $i += 1) {
    my $box_color = &getHexColor ($i, 16, $global_min_val, $color_scheme);
    push (@spectrum_boxes, '<font color=#'.$box_color.'>&#9608;</font>');
}
my $spectrum = join ('&nbsp;', @spectrum_boxes);
my @alpha = qw (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 ~ ! @ $ % ^ & * + = { } | [ ] \ : ; " ' < > ?);


# Determine longest tree branch
#
my $big_tree_chunk = 0;
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
	    next;
	}

	next if ($line =~ /^\s*$/);
	next if ($line =~ /^\s*\<a name="key"\>/);
	next if ($line =~ /^\s*\<\/?table[^\>]*\>/);
	next if ($line =~ /^\s*\<tr\>/);

	my ($tree_chunk) = split (/\s+/, $line);
	next if ($tree_chunk =~ /\<font$/);                 # already justified
	my $len_tree_chunk = $#{[split(/\&/, $tree_chunk)]};
	$big_tree_chunk = $len_tree_chunk  if ($len_tree_chunk > $big_tree_chunk);
    }
}


# Filter html tree to remove color, add boxes, and justify labels
#
$in_pre = undef;
my ($col_i, $col_a, $data_name, $line_copy, $new_key_html, $odd_even_adjust) = ();
my ($seen_key, $remove_header) = (undef, undef);
my $col_header_line = '';
my ($id, $box_color, $new_box, $tree_chunk, $one_more_space, $num_extra_spaces, $extra_spaces, $label_html, $len_tree_chunk) = ();
my @old_boxes = ();
foreach my $line (@tree_html_buf) {
    if (! $in_pre) {
	if ($line =~ /^\<pre\>/) {
	    $in_pre = 'true';
	}
	push (@out, $line);
    }
    else {
	if ($line =~ /^\<\/pre\>/) {
	    $in_pre = undef;
	    push (@out, $line);
	    next;
	}

	# add key
	if (! $seen_key) {

	    if ($line =~ /^\s*\<a name="key"\>/) {
		# add to existing color key
		$col_i = 0;
		$line_copy = $line;
		++$col_i  while ($line_copy =~ s/\<tr\>//);
		$new_key_html = '';
		for (my $i=0; $i <= $#max_val; ++$i) {
		    if (defined $header[$i]) {
			$data_name = $header[$i];
		    } else {
			$data_name = $data_set_name;
			if ($#max_val > 0) {
			    $data_name .= ".$i";
			}
		    }
		    $col_a = $alpha[$col_i+$i];
		    $new_key_html .= qq{<tr><td>$col_a</td><td>$data_name</td><td>$min_val[$i]</td><td>$spectrum</td><td>$max_val[$i]</td></tr>};
		}
		$line =~ s/\<\/table>\s*$/$new_key_html\<\/table\>/;
		push (@out, $line);

		$seen_key = 'true';
		$remove_header = 'true';
		next;
	    }
	    else {
		# make new color key
		$new_key_html = '';
		for (my $i=0; $i <= $#max_val; ++$i) {
		    if (defined $header[$i]) {
			$data_name = $header[$i];
		    } else {
			$data_name = $data_set_name;
			if ($#max_val > 0) {
			    $data_name .= ".$i";
			}
		    }
		    $col_a = $alpha[$i];
		    $new_key_html .= qq{<tr><td>$col_a</td><td>$data_name</td><td>$min_val[$i]</td><td>$spectrum</td><td>$max_val[$i]</td></tr>};
		}
		push (@out, qq{<a name="key"><table border=0 cellspacing=5 cellpadding=0>$new_key_html</table>});

		# make new col header line
		$odd_even_adjust = ((($big_tree_chunk+1) % 2) == 0) ? 1 : 0;
		$col_header_line = '&nbsp;'x($big_tree_chunk+$odd_even_adjust).' ';
		for (my $i=0; $i <= $#max_val; ++$i) {
		    $col_header_line .= ' '.$alpha[$i];
		}
		push (@out, qq{<a name="header">$col_header_line</a>});

		$seen_key = 'true';
		$remove_header = undef;
	    }
	}

	if ($remove_header) {                       # we'll replace header line
	    my $line_copy = $line;
	    $line_copy =~ s/^\<a name\=\"header\"\>//i;
	    1 while ($line_copy =~ s/^\&nbsp\;//);
	    $line_copy =~ s/^\s+|\s+$//g;
	    my @old_col_header = split (/\s+/, $line_copy);

	    $col_header_line = '&nbsp;'x$big_tree_chunk.' ';
	    for (my $label_i=0; $label_i <= $#old_col_header; ++$label_i) {
		$col_header_line .= ' '.$alpha[$label_i];
	    }
	    for (my $i=0; $i <= $#max_val; ++$i) {
		$col_header_line .= ' '.$alpha[$#old_col_header+$i+1];
	    }
	    push (@out, qq{<a name="header">$col_header_line});
	    $remove_header = undef;
	    next;
	}


	next if ($line =~ /^\s*$/);
	next if ($line =~ /^\s*\<\/?table[^\>]*\>/);
	next if ($line =~ /^\s*\<tr\>/);

	# get tree chunk
	@old_boxes = ();
	$id = '';
	$line_copy = $line;

	if ($line =~ /^(\S+\<font\s+\S+\<\/font\>)/) {
	    $tree_chunk = $1;
	}
	elsif ($line =~ /^(\S+)/) {
	    $tree_chunk = $1;
	}
	$line_copy =~ s/^$tree_chunk//;

	# get old boxes
	while ($line_copy =~ /^\s*(\<font color=\#\w{6}\>\&\#9608\;\<\/font\>)\s*/) {
	    push (@old_boxes, $1);
	    $line_copy =~ s/^\s*\<font color=\#\w{6}\>\&\#9608\;\<\/font\>\s*//;
	}
	
	# determine leaf id
	if ($line_copy =~ /^\s*\<span[^\>]*\>([^\<\s]+)/) {
	    $id = $1;
	} elsif ($line_copy =~ /^\s*(\S+)/) {
	    $id = $1;
	}
	if (! $id) {
	    print STDERR "Bad tree line (missing ID): '$line'\n";
	}

	# remove label color
	$label_html = $line_copy;
	$label_html =~ s/^\s+//g;
	$label_html =~ s/^\<span class=\"c\d+\"\>/\<span\>/;

	# make new boxes
	my @new_boxes = ();
	for (my $i=0; $i <= $#max_val; ++$i) {
	    if (! defined $leaf_data{$id}->[$i] || $leaf_data{$id}->[$i] eq '') {
		$box_color = 'cccccc';
	    } else {
		$box_color = &getHexColor (($leaf_data{$id}->[$i] - $min_val[$i]), $range[$i], $min_val[$i], $color_scheme);
	    }
	    push (@new_boxes, '<font color=#'.$box_color.'>&#9608;</font>');
	}

	# justify labels by adding dashes to tree
	if ($tree_chunk !~ /\<\/font>$/) { 
	    $len_tree_chunk = $#{[split(/\&/, $tree_chunk)]};
	    $one_more_space = ((($len_tree_chunk+1) % 2) == 0) ? '&nbsp;' : '';
	    $odd_even_adjust = ((($big_tree_chunk+1) % 2) == 0) ? 1 : 0;
	    $num_extra_spaces = int (($big_tree_chunk-$len_tree_chunk+$odd_even_adjust)/2);
	    $extra_spaces = ($num_extra_spaces > 0) 
		? '<font color=#cccccc>'.('&nbsp;&#9472;' x $num_extra_spaces).'</font>'
		: '';

	    $tree_chunk .= $one_more_space.$extra_spaces;
	    #$line =~ s/^($tree_chunk)/$tree_chunk$one_more_space$extra_spaces/;
	}

	# add box and restore label
	my $old_boxes_html = (@old_boxes) ? ' '.join(" ", @old_boxes) : '';
	my $new_boxes_html = join(" ", @new_boxes);
	my $new_line = join (" ", $tree_chunk, $old_boxes_html, $new_boxes_html, $label_html);

	# output
	push (@out, $new_line);
    }
}

print join ("\n", @out)."\n"  if (@out);


exit 0;

###############################################################################

sub getHexColor {
    my ($val, $range, $min_val, $color_scheme) = @_;
    $color_scheme = 'RYB'  if (! $color_scheme);
    my $hexColor = undef;
    my ($color_i, $r_color_i, $g_color_i, $b_color_i) = ();
    my $slope = 15/0.5;
    my @hexMap = qw (0 1 2 3 4 5 6 7 8 9 a b c d e f);

    my $mid_val = $range/2;
    my $one_third_val = $range/3;

    if ($color_scheme =~ /^Y/i) {
	if ($min_val < 0) {                # range from blue to black to yellow
	    if ($val == $mid_val) {
		$hexColor = '000000';
	    }
	    elsif ($val < $mid_val) {
		$color_i = int (-$slope * $val/$range + 15 + 0.5);
		$hexColor = '00'.'00'.$hexMap[$color_i].$hexMap[$color_i];
	    }
	    else {
		$color_i = int ($slope * $val/$range - 15 + 0.5);
		$hexColor = $hexMap[$color_i].$hexMap[$color_i].$hexMap[$color_i].$hexMap[$color_i].'00';
	    }
	} else {                           # range from black to blue to cyan to yellow
	    if ($val < $one_third_val) {
		my $b_slope = 3 * 15;
		$b_color_i = int ($b_slope * $val/$range + 0 + 0.5);
		$hexColor = '00'.'00'.$hexMap[$b_color_i].$hexMap[$b_color_i];
	    }
	    elsif ($val < $mid_val) {
		my $g_slope = 6 * 15;
		$g_color_i = int ($g_slope * $val/$range - 30 + 0.5);
		$hexColor = '00'.$hexMap[$g_color_i].$hexMap[$g_color_i].'ff';
	    }
	    else {
		my $r_slope = 2 * 15;
		my $b_slope = 2 * 15;
		$r_color_i = int ($r_slope  * $val/$range - 15 + 0.5);
		$b_color_i = int (-$b_slope * $val/$range + 30 + 0.5);
		$hexColor = $hexMap[$r_color_i].$hexMap[$r_color_i].'ff'.$hexMap[$b_color_i].$hexMap[$b_color_i];
	    }
	}
    }
    elsif ($color_scheme =~ /^R/i) {
	if ($val == $mid_val) {
	    $hexColor = 'ffff00';
	}
	elsif ($val < $mid_val) {
	    $r_color_i = int ( $slope * $val/$range +  0 + 0.5);
	    $g_color_i = int ( $slope * $val/$range +  0 + 0.5);
	    $b_color_i = int (-$slope * $val/$range + 15 + 0.5);
	    $hexColor = $hexMap[$r_color_i].$hexMap[$r_color_i].
		        $hexMap[$g_color_i].$hexMap[$g_color_i].
		        $hexMap[$b_color_i].$hexMap[$b_color_i];
	}
	else {
	    $r_color_i = 15;
	    $g_color_i = int (-$slope * $val/$range + 30 + 0.5);
	    $b_color_i = 0;
	    $hexColor = $hexMap[$r_color_i].$hexMap[$r_color_i].
		        $hexMap[$g_color_i].$hexMap[$g_color_i].
			$hexMap[$b_color_i].$hexMap[$b_color_i];
	}
    }

    else {
	print STDERR "unknown color scheme: '$color_scheme'\n";
	exit -1;
    }

    return $hexColor;
}
