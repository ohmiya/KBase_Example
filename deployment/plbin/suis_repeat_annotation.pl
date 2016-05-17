
use strict;
use warnings;
use Carp;
use Bio::SeqIO;
use Bio::SeqI;
use Data::Dumper;
use File::Temp;
use File::Copy;
use File::Basename;

my $n = 0;
my %start;
my %end;
my %type;
my %score;
my %strand;
my $r = 0;
my %repeats;
my $max = 0;
my %BOX;
my $boxstart;
my $boxend;
my $boxnum = 0;
my $boxstrand;
my %boxstart;
my %boxstrand;
my %boxend;
my $A_start;
my $A_end;
my $A_score = 0;
my $A_hitstrand;
my $A_hitstart;
my $A_hitend;
my $B_start;
my $B_end;
my $B_score = 0;
my $B_hitstrand;
my $B_hitstart;
my $B_hitend;
my $in_box = 0;
my $start;
my $end;
my $hitscore = 0;
my $hitstart = 0;
my $hitend = 0;
my $hitstrand = 0;
my %brokencoords;
my %brokenscore;
my %brokendisrupt;

if (!exists($ENV{KB_TOP}))
{
    die "$0: KB_TOP not set in environment - required for this application";
}

my $HMM_DIR = "$ENV{KB_TOP}/libexec/strep_repeats/Repeat_HMMs";
-d $HMM_DIR || die "HMM dir $HMM_DIR not found";

my $HMMLS = "$ENV{KB_TOP}/libexec/strep_repeats/hmmls";
-x $HMMLS || die "hmmls not fount at $HMMLS";

my $tmpdir = File::Temp::tempdir(undef, CLEANUP => 1);

my @repeats = ("boxA","boxB","boxC","boxD","boxE","boxF");				# repeats being analysed
my %cutoffs = (									# cutoff scores for HMM analysis
		"boxA" => 60,
		"boxB" => 30,
		"boxC" => 30,
		"boxD" => 45,
		"boxE" => 80,
		"boxF" => 75,
);
my %hmms = (
		"boxA" => "$HMM_DIR/suis_boxA.hmm",			# paths of HMM for analysis
		"boxB" => "$HMM_DIR/suis_boxB.hmm",
		"boxC" => "$HMM_DIR/suis_boxC.hmm",
		"boxD" => "$HMM_DIR/suis_boxD.hmm",
		"boxE" => "$HMM_DIR/suis_boxE.hmm",
		"boxF" => "$HMM_DIR/suis_boxF.hmm",
);
my %input_files = (
		"boxA" => "boxA.rep",						# output files from HMM analysis
		"boxB" => "boxB.rep",
		"boxC" => "boxC.rep",
		"boxD" => "boxD.rep",
		"boxE" => "boxE.rep",
		"boxF" => "boxF.rep",
);

#
# Read from the one file if it is there, or STDIN otherwise.
#

my $input_file;

if (@ARGV == 0)
{
    $input_file = "$tmpdir/input_file";
    copy(\*STDIN, $input_file);
}
elsif (@ARGV == 1)
{
    $input_file = $ARGV[0];
}
else
{
    die "Usage: $0 [input-file] > output\n";
}

{
    my $seq = $input_file;
    my $sbase = basename($seq);
    foreach my $repeat (@repeats) {
	print STDERR "Searching sequence $seq for repeat $repeat...";
	run_system("$HMMLS -c -t $cutoffs{$repeat} $hmms{$repeat} $seq > $tmpdir/$sbase.$input_files{$repeat}");
	print STDERR "done\n";
    }
}

my %seen;

open(OUT, ">&STDOUT") or confess "Cannot reopen STDOUT: $!";

{
    my $genome = $input_file;
    my $gbase = basename($genome);
    foreach my $repeat (sort keys %input_files) {
	open(IN, "<", "$tmpdir/$gbase.$input_files{$repeat}") or die print "Cannot open input file\n";
	foreach (<IN>) {
	    chomp;
	    if (my ($score) = /^(\d+\.\d+)/) {
		$score = $1;
		my ($start, $end) = /\sf\:\s*(\d+)\s+t\:\s*(\d+)/;
		if (($score > $cutoffs{$repeat}) && $start && $end) {
		    $start{$r} = $start;
		    $end{$r}   = $end;
		    $type{$r}  = $repeat;
		    $score{$r} = $score;
		    
		    if ($end{$r} > $start{$r}) {
			$strand{$r} = 1;
		    } else {
			$strand{$r} = -1;
		    }	
		}
		$r++;
	    }
	}
	$max = 0;
    }
    print STDERR "Identified repeat units in sequence $genome\n";
    foreach my $repeata (sort {$start{$a} <=> $start{$b}} keys %start) { # identify composite BOX elements from box modules
	unless (defined($seen{$repeata}) && $seen{$repeata} == 1) {
	    $boxstrand = $strand{$repeata};
	    $boxstart = $start{$repeata};
	    @{$BOX{$boxnum}} = "$repeata";
	    if ($boxstrand == 1) {
		$boxend = $end{$repeata}+5; # five base leeway for finding the adjacent boxB element
		foreach my $repeatb (sort {$start{$a} <=> $start{$b}} keys %start) {
		    if (($repeata != $repeatb) && ($start{$repeatb} <= $boxend && $start{$repeatb} >= $boxstart) && $strand{$repeatb} == $boxstrand) {
			$boxend = $end{$repeatb}+5; # need to stop BOX elements being added if already part of a BOX
			push(@{$BOX{$boxnum}},$repeatb);
		    }
		}
		if ($#{$BOX{$boxnum}} > 0) {
		    $boxstart{$boxnum} = $boxstart;
		    $boxend{$boxnum} = $boxend-5;
		    $boxstrand{$boxnum} = $boxstrand;
		    foreach my $num (@{$BOX{$boxnum}}) {
			$seen{$num} = 1;
		    }
		    $boxnum++;
		}
	    }
	}
    }
    foreach my $repeata (sort {$start{$b} <=> $start{$a}} keys %start) { # identify composite BOX elements from box modules
	unless (defined($seen{$repeata}) && $seen{$repeata} == 1) {
	    $boxstrand = $strand{$repeata};
	    $boxstart = $start{$repeata};
	    @{$BOX{$boxnum}} = "$repeata";
	    if ($boxstrand == -1) {
		$boxend = $end{$repeata}-5;
		foreach my $repeatb (sort {$start{$b} <=> $start{$a}} keys %start) {
		    if (($repeata != $repeatb) && ($start{$repeatb} >= $boxend && $start{$repeatb} <= $boxstart) && $strand{$repeatb} == $boxstrand) {
			$boxend = $end{$repeatb}-5; # greater leeway than with pneumo, HMMs not as well defined
			push(@{$BOX{$boxnum}},$repeatb);
		    }
		}
		if ($#{$BOX{$boxnum}} > 0) {
		    $boxstart{$boxnum} = $boxstart;
		    $boxend{$boxnum} = $boxend+5;
		    $boxstrand{$boxnum} = $boxstrand;
		    foreach my $num (@{$BOX{$boxnum}}) {
			$seen{$num} = 1;
		    }
		    $boxnum++;
		}
	    }
	}
    }	
    $in_box = 0;
    print STDERR "Identified composite BOX elements\n";
    delete($BOX{$boxnum});
    
    my %overlaps;
    
    foreach my $repeata (sort keys %start) { # identify overlapping repeat elements, except BOX modules
	foreach my $repeatb (sort keys %start) {
	    if (($start{$repeatb} <= $start{$repeata} && $end{$repeatb} >= $start{$repeata}) || ($start{$repeatb} <= $end{$repeata} && $end{$repeatb} >= $end{$repeata})) {
		unless (($type{$repeata} =~ /box/ && $type{$repeatb} =~ /box/) || ($repeata == $repeatb)) {
		    my @unsorted = ($repeata,$repeatb);
		    my @sorted = sort(@unsorted);
		    $overlaps{$sorted[0]} = $sorted[1];
		}		
	    }
	}
    }
    
    print STDERR "Printing output files\n";
    
    foreach my $repeat (sort keys %start) {
	if ($start{$repeat} eq "BROKEN") {
	    if ($strand{$repeat} == 1) {
		print OUT "FT   repeat_unit     order(${$brokencoords{$repeat}}[0]..${$brokencoords{$repeat}}[1],${$brokencoords{$repeat}}[2]..${$brokencoords{$repeat}}[3])\n";
	    } elsif ($strand{$repeat} == -1) {
		print OUT "FT   repeat_unit     complement(${$brokencoords{$repeat}}[0]..${$brokencoords{$repeat}}[1],${$brokencoords{$repeat}}[2]..${$brokencoords{$repeat}}[3])\n";
	    }
	    print OUT "FT                   /colour=2\n";
	    print OUT "FT                   /label=$type{$repeat}\n";
	    print OUT "FT                   /note=Detected using HMMER hmmls; appears to have been disrupted through $brokendisrupt{$repeat} insertion\n";
	    print OUT "FT                   /note=Initial match of score $score{$repeat} to model $type{$repeat}; realignment score of $brokenscore{$repeat}\n";
	} else {
	    if ($strand{$repeat} == 1) {
		print OUT "FT   repeat_unit     $start{$repeat}..$end{$repeat}\n";
	    } elsif ($strand{$repeat} == -1) {
		print OUT "FT   repeat_unit     complement($start{$repeat}..$end{$repeat})\n";
	    }
	    print OUT "FT                   /colour=2\n";
	    print OUT "FT                   /label=$type{$repeat}\n";
	    print OUT "FT                   /note=Detected using HMMER hmmls; match of score $score{$repeat} to model $type{$repeat}\n";
	}
    }
    foreach my $boxnum (sort keys %BOX) {
	if ($boxstrand{$boxnum} == 1) {
	    print OUT "FT   repeat_unit     $boxstart{$boxnum}..$boxend{$boxnum}\n";
	} else {
	    print OUT "FT   repeat_unit     complement($boxstart{$boxnum}..$boxend{$boxnum})\n";
	}
	print OUT "FT                   /colour=4\n";
	print OUT "FT                   /note=Composite BOX element\n";
	print OUT "FT                   /label=BOX\n";
    }
    
    undef(%start);
    undef(%end);
    undef(%type);
    undef(%score);
    undef(%strand);
    undef(%repeats);
    undef(%BOX);
    undef(%boxstart);
    undef(%boxstrand);
    undef(%boxend);
    undef(%brokencoords);
    undef(%brokenscore);
    undef(%brokendisrupt);	
    
}

close OUT;

print STDERR "Done\n";

sub boundaries { # subroutine for identifying repeat boundaries, esp BOX elements
    my $rep = shift;
    if ($type{$rep} =~ /box/) {
	foreach $boxnum (sort keys %BOX) {
	    foreach my $module (@{$BOX{$boxnum}}) {
		if ($module == $rep) {
		    my @unsorted = ("$boxstart{$boxnum}","$boxend{$boxnum}");
		    my @sorted = sort(@unsorted);
		    $start = $sorted[0];
		    $end = $sorted[1];
		    $in_box = 1;
		}
	    }
	}
    }
    if ($in_box == 0) {
	my @unsorted = ("$start{$rep}","$end{$rep}");
	my @sorted = sort(@unsorted);
	$start = $sorted[0];
	$end = $sorted[1];
    }
    $in_box = 0;
    return($start,$end);
}

sub print_fasta { # subroutine for printing sequence in a suitable format for hmmls
    my $filename = shift;
    my $dna_string = shift;
    my $fh;
    open($fh, ">", $filename) or confess "Cannot write $filename: $!";
    print $fh ">$filename\n";
    my $offset = 0;
    while ($offset < 440) {
	my $line = substr($dna_string,$offset,60);
	print $fh "$line\n";
	$offset+=60;
    }
    my $line = substr($dna_string,$offset,(500-$offset));
    print $fh "$line\n";
    close $fh;
}

sub hmm_results { # subroutine for picking the top hit from the hmmls results
    my $filename = shift;
    open(HMM, "<", $filename) or confess "Cannot open HMM file $filename: $!";
    $hitscore = 0;
    foreach (<HMM>) {
	my @data = split(/\s+/,$_);
	if (substr($_,0,2) =~ /\d\d/) {
	    if ($data[0] > $hitscore) {
		if ($data[3] < $data[5] && $data[3] <= 250 && $data[5] >= 250) {
		    $hitstrand = 1;
		    $hitscore = $data[0];
		    $hitstart = $data[3];
		    $hitend = $data[5];
		} elsif ($data[5] < $data[3] && $data[3] >= 250 && $data[5] <= 250) {
		    $hitstrand = -1;
		    $hitscore = $data[0];
		    $hitstart = $data[3];
		    $hitend = $data[5];
				}
			}
		}
	}
	close HMM;
	return($hitstart,$hitend,$hitscore,$hitstrand);
}

sub run_system
{
    my(@cmd) = @_;

    my $rc = system(@cmd);
    if ($rc != 0)
    {
	confess "Command failed with rc=$rc: @cmd";
    }
}
