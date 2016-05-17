use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#

=head1 NAME

subsystems_to_genomes

=head1 SYNOPSIS

subsystems_to_genomes [arguments] < input > output

=head1 DESCRIPTION

This command takes as input a table with a column containing subsystem names. 
An extra column is appended to the table containing genome IDs (for those genomes
included in the subsystem with an active variant code (not matching /\*?(o|-1)/).

Example:

    subsystems_to_genomes [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the subsystem name. If another column contains the subsystem name
use

    -c N

where N is the column (from 1) that contains the subsystem.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head1 COMMAND-LINE OPTIONS

Usage: subsystems_to_genomes [arguments] < input > output


    -c num        Select the identifier from column num
    -i filename   Use filename rather than stdin for input

=head1 AUTHORS

L<The SEED Project|http://www.theseed.org>

=cut


our $usage = "usage: subsystems_to_genomes [-c column] < input > output";

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
    my $h = $kbO->subsystems_to_genomes(\@h);
    for my $tuple (@tuples) {
        #
        # Process output here and print.
        #
  my ($subsys, $line) = @$tuple;
        my $v = $h->{$subsys};
        if ((! $v) || (@$v == 0))
        {
            print STDERR $line,"\n";
        }
        else
        {
            foreach $_ (@$v)
            {
                my($variant,$genome) = @$_;
		if ($variant !~ /^\*?(0|-1)/)
		{
		    print join("\t",($line,$variant,$genome)),"\n";
		}
            }
        }
    }
}


__DATA__
