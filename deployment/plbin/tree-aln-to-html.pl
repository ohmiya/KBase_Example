use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#

=head1 aln_to_html

=head2 Introduction

    aln_to_html [options] < alignment.in.fasta.format > alignment.as.html

Convert a FASTA alignment to HTML

This script takes a FASTA version of an alignment and produces the HTML needed
to support visualization of the alignment.

=head2 Command-Line Options

=over 4

=item -c=conservation|conservation2|residue|none

If I<conservation> is specified, coloring is used to reveal levels of conservation (within a column).
If I<conservation2> is specified, an alternative color scheme is used to reveal levels of conservation (within a column).
If I<residue> is specified, coloring is used to reveal classes of residues.
If I<none> simply turns off coloring

The default value is I<conservation>.

=item -d

If this option is specified, pop-up sequence definitions (comments) will be omitted

=item -j

If this option is specified, pop-up menus will be omitted (only valid with -t)

=item -l

If this option is specified, the legend will be omitted


=item -n          

Treat residues as nucleotides (if neither -n nor -p is set, the program looks at the sequence and guesses)

=item -p          

Treat residues as amino acids (if neither -n nor -p is set, the program looks at the sequence and guesses)

=item -s=seqfile  

Add unaligned residues to the ends of the alignment

=item -t          

Write html table (default is to write a self-contained page)

=back

=head3 Output Format

The generated HTML document is written to STDOUT.

=cut

use Bio::KBase::CDMI::CDMIClient;
use Bio::KBase::Utilities::ScriptThing;

my $usage = <<"End_of_Usage";

NAME
      tree-aln-to-html -- render a sequence alignment as in a static HTML file

SYNOPSIS
      tree-aln-to-html [OPTIONS] [FASTA_ALIGNMENT]

DESCRIPTION
     Given an alignment in FASTA, render the alignment as a static HTML file with
     the options defined below.  The alignment must be passed in through standard-in,
     and the HTML output is returned through standard out.
      
	-c          #  specify color scheme [conservation|conservation2|residue|none]
	-d          #  Omit pop-up sequence definitions
	-j          #  Omit JavaScript (only valid with -t)
	-l          #  Omit legend
	-n          #  Treat residues as nucleotides 
	-p          #  Treat residues as amino acids 
	-s seqfile  #  Add unaligned residues to the ends of the alignment
	-t          #  Write html table (Default is write a self-contained page)

EXAMPLES
      Render a tree with species name labels and links to KBase labs feature pages:
      > tree-get-tree 'kb|tree.1000000' -f > my.tree
      > tree-get-leaf-nodes -i my.tree > feature.list
      > cat feature.data | cut -f 1,13 > species.name.map
      > cat features.list | tree-create-url-map -u 'http://140.221.92.12/feature_info/feature.html?id=' > feature.links
      > cat my.tree | tree-to-html -a species.name.map -l feature.links > out.html

AUTHORS
      Fangfang Xia, ANL (fangfang.xia\@gmail.com)
      Michael Sneddon (mwsneddon\@lbl.gov)

End_of_Usage

use gjoalign2html;
use gjoseqlib;

my $colored     = "conservation";
my $popup       = 0;
my $javascript  = 0;
my $show_legend = 0;
my $is_protein  = undef;
my $is_nuc      = 0;
my $seqF        = undef;
my $as_table    = 0;
my $by_residue  = 0;
my $pallet      = undef;
use Getopt::Long;

my $kbO = Bio::KBase::CDMI::CDMIClient->new_for_script("c=s" => \$colored,
                                                       "d"   => \$popup,
                                                       "j"   => \$javascript,
                                                       "l"   => \$show_legend,
                                                       "n"   => \$is_nuc,
                                                       "p"   => \$is_protein,
                                                       "s=s" => \$seqF,
                                                       "t"   => \$as_table);
	
if (! $kbO) { print STDERR $usage; exit }

if     ($colored eq "none")              { $colored = 0 }
elsif  ($colored eq "residue")           { $by_residue = 1 }
elsif  ($colored eq "conservation")      { $colored = 1 }
elsif  ($colored eq "conservation2")     { $colored = 1; $pallet = { mismatch => '#d55e00' } }
else                                     { print STDERR "Invalid -c option\n\n$usage\n"; exit }

$popup       = $popup ? 0 : 1;
$javascript  = $javascript ? 0 : 1;
$show_legend = $show_legend ? 0 : 1;

if    ($is_nuc)                             { $is_protein = 0 }

my @ali = read_fasta();
@ali or print STDERR "Failed to read alignment\n$usage"
     and exit;

my $ali2;
if ( $seqF )
{
    my @seq = read_fasta( $seqF );
    @seq or print STDERR "Failed to read sequence file '$seqF'\n$usage"
         and exit;
    $ali2 = gjoalign2html::add_alignment_context( \@ali, \@seq );
}
else
{
    $ali2 = \@ali;
}

my ( $ali3, $legend );
if ( ! $colored )
{
    $ali3   = gjoalign2html::repad_alignment( $ali2 );
    foreach $_ (@$ali3)
    {
	$_->[2] =~ s/ /\&nbsp;/g;
    }
    $legend = '';
}
elsif ( $by_residue )
{
    ( $ali3, $legend ) = gjoalign2html::color_alignment_by_residue( 
                           { align  => $ali2,
                             ( defined( $is_protein ) ? ( protein => $is_protein ) : () ),
                           } );
}
else
{
    ( $ali3, $legend ) = gjoalign2html::color_alignment_by_consensus( { align => $ali2, colors => $pallet } );
}

my @legend_opt = ( $show_legend && $legend ) ? ( legend => $legend ) : ();

if ( $as_table )
{
    my @javascript_opt = $javascript ? () : ( nojavascript => 1 );

    print scalar gjoalign2html::alignment_2_html_table( { align   => $ali3,
                                                          @javascript_opt,
                                                          @legend_opt,
                                                          tooltip => $popup,
                                                        } );
}
else
{
    my $title = $by_residue ? 'Alignment colored by residue'
                            : 'Alignment colored by consensus';

    print gjoalign2html::alignment_2_html_page( { align   => $ali3, 
                                                  @legend_opt,
                                                  title   => $title,
                                                  tooltip => $popup,
                                                } );
}
exit 0;
