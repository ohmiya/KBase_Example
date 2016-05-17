#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use Data::Dumper;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);

my $DESCRIPTION =
"
NAME
      tree-filter-abundance-profile-column -- filter metagenomic samples to abundance count tree mapping

SYNOPSIS
      tree-filter-abundance-profile [OPTIONS]

DESCRIPTION
      Filter the mapping of metagenomic sample reads to tree abundance counts.  

      The expected input is a two column tab delimited string with tree node labels in the first column
      and abundance counts in the second column.

      The -g, -t, -n options can all be supplied in a single call, or can be acheived using multiple script calls.
      If you supply multiple options (-g,-t,-n), the order they will be applied is minimum thresholding, 
      normalization, and then grouping.

      -g, --groups
                        specify a number of evenly spaced groups to divide the data into,
                        which will bin the data into groups of size (max - min + 1)/number_of_groups,
                        where data is in a group if (data >= group_min and data < next_group_min)
      -t, --threshold
                        specify a global minimum threshold to filter the input counts with,
                        which will remove all nodes with counts strictly less than the threshold
      -n, --normalize
                        normalize the data by a constant factor (i.e. divide by some factor)
      -i, --input                                                                                           
                        specify an input file to read from; if provided, any other arguments
                        and standard-in are ignored
      -h, --help
                        diplay this help message, ignore all arguments
                                                
EXAMPLES
      Based on the following input:
      > tree-compute-abundance-profile -t 'kb|tree.991753' -m '4447970.3' -f 'COG0840' -s 'COG' > abundance.out

      > cat abundance.out

      17606074_1_288_654	3
      19516952_1_320_727	1
      17606382_1_255_669	8
      17606439_1_391_753	1
      17607137_1_230_698	5
      19516485_1_166_586	1
      5651980_1_431_830	2
      17605787_1_300_519	1
      21808959_1_279_638	2
      574651_1_1_374	3
      21809103_1_178_646	1
      17605081_1_306_684	5
      20604468_1_1_174	1
      17605489_1_233_664	2
      17388525_1_288_664	2
      17605141_1_286_700	7
      17606343_1_253_679	2
      17606919_1_239_676	3
      18877351_1_281_660	4
      17605775_1_113_541	9
      574486_1_281_660	1
      17390038_1_141_554	1
      17606609_1_283_661	7
      574925_1_289_696	3

      Normalize values by a reducing factor of 5.0
      > tree-filter-abundance-profile-column -i abundance.out -n 5.0
      OR
      > tree-filter-abundance-profile-column -i abundance.out --normalize 5.0

      19516952_1_320_727	0.2
      17606074_1_288_654	0.6
      17606382_1_255_669	1.6
      17607137_1_230_698	1
      17606439_1_391_753	0.2
      19516485_1_166_586	0.2
      5651980_1_431_830	0.4
      17605787_1_300_519	0.2
      21808959_1_279_638	0.4
      574651_1_1_374	0.6
      17605081_1_306_684	1
      21809103_1_178_646	0.2
      20604468_1_1_174	0.2
      17605489_1_233_664	0.4
      17388525_1_288_664	0.4
      17605141_1_286_700	1.4
      17606343_1_253_679	0.4
      17606919_1_239_676	0.6
      18877351_1_281_660	0.8
      17390038_1_141_554	0.2
      574486_1_281_660	0.2
      17605775_1_113_541	1.8
      574925_1_289_696	0.6
      17606609_1_283_661	1.4


      Group the nodes into a set of 6 groups with evenly spaced range values      
      > tree-filter-abundance-profile-column -i abundance.out -g 6
      OR
      > tree-filter-abundance-profile-column -i abundance.out --groups 6

      19516952_1_320_727	0_range_1.00-2.50
      17606074_1_288_654	1_range_2.50-4.00
      17606382_1_255_669	4_range_7.00-8.50
      17607137_1_230_698	2_range_4.00-5.50
      17606439_1_391_753	0_range_1.00-2.50
      19516485_1_166_586	0_range_1.00-2.50
      5651980_1_431_830	0_range_1.00-2.50
      17605787_1_300_519	0_range_1.00-2.50
      21808959_1_279_638	0_range_1.00-2.50
      574651_1_1_374	1_range_2.50-4.00
      17605081_1_306_684	2_range_4.00-5.50
      21809103_1_178_646	0_range_1.00-2.50
      20604468_1_1_174	0_range_1.00-2.50
      17605489_1_233_664	0_range_1.00-2.50
      17388525_1_288_664	0_range_1.00-2.50
      17605141_1_286_700	4_range_7.00-8.50
      17606343_1_253_679	0_range_1.00-2.50
      17606919_1_239_676	1_range_2.50-4.00
      18877351_1_281_660	2_range_4.00-5.50
      17390038_1_141_554	0_range_1.00-2.50
      574486_1_281_660	0_range_1.00-2.50
      17605775_1_113_541	5_range_8.50-10.00
      574925_1_289_696	1_range_2.50-4.00
      17606609_1_283_661	4_range_7.00-8.50


      Apply a minimum threshold of 2.0 to the abundance counts, which will remove all counts less than 2.0
      > tree-filter-abundance-profile-column -i abundance.out -t 2.0 
      OR
      > tree-filter-abundance-profile-column -i abundance.out --threshold 2.0 

      17606074_1_288_654	3
      17606382_1_255_669	8
      17607137_1_230_698	5
      5651980_1_431_830	2
      21808959_1_279_638	2
      574651_1_1_374	3
      17605081_1_306_684	5
      17605489_1_233_664	2
      17388525_1_288_664	2
      17605141_1_286_700	7
      17606343_1_253_679	2
      17606919_1_239_676	3
      18877351_1_281_660	4
      17605775_1_113_541	9
      574925_1_289_696	3
      17606609_1_283_661	7

      
AUTHORS
      Matt Henderson (mhenderson\@lbl.gov)
      
";

my $help = '';
my $inputFile;
my $inputString = '';
my $numGroups = 0;
my $minThreshold = 0;
my $normalizeFactor = 0.0;
my $leaves;

my $defaultGroups = 5;
my $defaultNormal = 1.0;

my $opt = GetOptions (
              "groups:i" => \$numGroups,
              "help" => \$help,
              "input:s" => \$inputFile,
              "normalize:f" => \$normalizeFactor,
              "threshold:f" => \$minThreshold
          );

if ($help) {
    print $DESCRIPTION;
    exit 0;
}


my $n_args = $#ARGV + 1;

# if we have specified an input file, then read the file                                                                                
if ($inputFile) {
    open my $inputFileHandle, '<', $inputFile or die "FAILURE - Unable to open $inputFile: $!";
    $inputString = do { local $/; <$inputFileHandle>; };
}
# if we have a single argument, then accept it as the input  
elsif ($n_args == 1) {
    $inputString = $ARGV[0];
}
# if we have no arguments, then read from standard-in                                                                           
elsif ($n_args == 0) {
    while (my $line = <STDIN>) {
	$inputString = $inputString.$line;
    }
}
# otherwise we have some bad number of commandline args 
else {
    print "Bad options / Invalid number of arguments.  Run with --help for usage.\n";
    exit 1;
}


if ($inputString ne '') {
    my $leaves;

    eval {
        my $line_number = 0;
        my @lines = split('\n',$inputString);

        foreach my $x (@lines) {
            ++$line_number;

            if ($x eq '') {
                next;
	    }

            my @tokens = split('\t', $x);

            if(scalar (@tokens) != 2) {
                    print "FAILURE - malformed replacement string input on line $line_number.  Exactly two tab delimited columns permitted.\n\n";
                    exit 1;
            }
            else {
                $leaves->{$tokens[0]} = $tokens[1];
            }
	}
    };

    if (($numGroups == 0) && ($minThreshold == 0) && ($normalizeFactor - 1E-6 < 0.0001)) {
        printStatistics($leaves);
        exit 0;
    }


    if ($minThreshold > 0) {
        $leaves = &cullLeaves($leaves, $minThreshold);
    }

    if ($normalizeFactor - 1E-6 > 0.001) {
        $leaves = &normalizeLeaves($leaves, $normalizeFactor);
    }

    if ($numGroups > 0) {
        $leaves = &groupLeaves($leaves, $numGroups);
    }

    &printLeaves($leaves);
    exit 0;
} else {
    print "FAILURE - no abundance profile specified.  Run with --help for usage.\n";
    exit 1;
}

exit 0;


sub printLeaves {
    my ($leaves_local) = @_;

    for my $leaf_key (keys %{$leaves_local}) {
        print $leaf_key . "\t" . $leaves_local->{$leaf_key} . "\n";
    }    
}

sub printStatistics {
    my ($leaves_local) = @_;

    #my $stat = Statistics::Descriptive::Full->new();
    #$stat->add_data(values %{$leaves});

    my $count = scalar(keys %{$leaves_local});
    my $min = min values %{$leaves_local};
    my $max = max values %{$leaves_local};
    my $avg = (sum values %{$leaves_local})/(1.0*$count);

    print "\n\n";
    print "Count" . "\t" . $count . "\n";
    print "Min" . "\t" . $min . "\n";
    print "Max" . "\t" . $max . "\n";
    print "Mean" . "\t" . $avg . "\n";
}


sub normalizeLeaves {
    my ($leaves_local, $normalizeFactor) = @_;

    for my $leaf_key (keys %{$leaves_local}) {
        $leaves_local->{$leaf_key} /= $normalizeFactor; 
    }    

    return $leaves_local;
}


sub groupLeaves {
    my ($leaves_local, $numGroups) = @_;

    my @bins = ();

    my $count = scalar(keys %{$leaves_local});
    my $leafMin = min values %{$leaves_local};
    my $leafMax = max values %{$leaves_local};
    my $binSize = (1.0*$leafMax - 1.0*$leafMin + 1.0)/(1.0*$numGroups);

    for (my $n = 0; $n < $numGroups; $n++) {
        push(@bins, $leafMin + $n*$binSize);
    }
    push(@bins, $leafMin + $numGroups*$binSize);

    for my $leaf_key (keys %{$leaves_local}) {        
        for (my $i = 1; $i < $numGroups + 1; $i++) {
            if (($leaves_local->{$leaf_key} >= $bins[$i-1]) && ($leaves_local->{$leaf_key} < $bins[$i])) {
                $leaves_local->{$leaf_key} = ($i-1) . "_range_" . sprintf("%.2f", $bins[$i-1]) . "-" . sprintf("%.2f", $bins[$i]);
                last;
            }            
	}
    }

    return $leaves_local;
}


sub cullLeaves {
    my ($leaves_local, $minThreshold) = @_;

    for my $leaf_key (keys %{$leaves_local}) {
        if ($leaves_local->{$leaf_key} < $minThreshold) {
            delete $leaves_local->{$leaf_key};
	}
    }

    return $leaves_local;
}

#End of file

