use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#

=head1 NAME

genomes_to_subsystems

=head1 SYNOPSIS

genomes_to_subsystems [arguments] < input > output

=head1 DESCRIPTION


A user can invoke genomes_to_subsystems to rerieve the names of the subsystems
relevant to each genome.  The input is a list of genomes.  The output is a mapping
from genome to a list of 2-tuples, where each 2-tuple give a variant code and a
subsystem name.  Variant codes of -1 (or *-1) amount to assertions that the
genome contains no active variant.  A variant code of 0 means "work in progress",
and presence or absence of the subsystem in the genome should be undetermined.


Example:

    genomes_to_subsystems [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifer. If another column contains the identifier
use

    -c N

where N is the column (from 1) that contains the subsystem.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head1 COMMAND-LINE OPTIONS

Usage: genomes_to_subsystems [arguments] < input > output


    -c num        Select the identifier from column num
    -i filename   Use filename rather than stdin for input

=head1 AUTHORS

L<The SEED Project|http://www.theseed.org>

=cut


our $usage = "usage: genomes_to_subsystems [-c column] < input > output";

use Bio::KBase::CDMI::CDMIClient;
use Bio::KBase::Utilities::ScriptThing;

my $column;

my $input_file;

my $kbO = Bio::KBase::CDMI::CDMIClient->new_for_script('c=i' => \$column,
				      'i=s' => \$input_file);
if (! $kbO) { print STDERR $usage; exit }

my $ih;
if ($input_file)
{
    open $ih, "<", $input_file or die "Cannot open input file $input_file: $!";
}
else
{
    $ih = \*STDIN;
}

while (my @tuples = Bio::KBase::Utilities::ScriptThing::GetBatch($ih, undef, $column)) {
    my @h = map { $_->[0] } @tuples;
    my $h = $kbO->genomes_to_subsystems(\@h);
    for my $tuple (@tuples) {
        #
        # Process output here and print.
        #
        my ($id, $line) = @$tuple;
        my $v = $h->{$id};

        if (! defined($v))
        {
            print STDERR $line,"\n";
        }
        elsif (ref($v) eq 'ARRAY')
        {
            foreach $_ (@$v)
            {
		 if (ref($_) eq 'ARRAY') {
                    $_ = join(",", @$_);
                }
                print "$line\t$_\n";
            }
        }
        else
        {
            print "$line\t$v\n";
        }
    }
}

__DATA__
