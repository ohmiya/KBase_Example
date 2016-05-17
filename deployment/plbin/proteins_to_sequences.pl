use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#

=head1 NAME

proteins_to_sequences

=head1 SYNOPSIS

proteins_to_sequences [arguments] < input > output

=head1 DESCRIPTION


proteins_to_sequences allows the user to look up the amino acid sequences
corresponding to each of a set of proteins (represented as MD5 hash values)
This command allows you to get back formatted fasta files.


Example:

    proteins_to_sequences [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifer. If another column contains the identifier
use

    -c N

where N is the column (from 1) that contains the subsystem.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Command-Line Options

=over 4

=item -c Column

This is used only if the column containing the subsystem is not the last column.

=item -i InputFile    [ use InputFile, rather than stdin ]

=item -fasta

This is used to request a fasta output file (dropping all of the other columns in the input lines).
It defaults to outputing just a fasta entry.

=item -fc Columns  [ construct comment for fasta from these columns ]

This is used to ask for "fasta comments" formed from one or more columns (comma-separated)

=back

=head2 Output Format

The standard output is jsut a fasta file with the sequence.  You can also get
a tab-delimited file by using -fasta=0.  The tab-delimited format consists of the input
file with an extra column of sequence  added.

Input lines that cannot be extended are written to stderr.

=cut


my $usage = "usage: proteins_to_sequences [-c column] < input > output";

use Bio::KBase::CDMI::CDMIClient;
use Bio::KBase::Utilities::ScriptThing;

my $column;

my $input_file;
my $fasta = 1;
my $fasta_comment;

my $kbO = Bio::KBase::CDMI::CDMIClient->new_for_script('c=i' => \$column,
				     'fasta=i' => \$fasta,
				     'fc=s'    => \$fasta_comment,
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

my %fasta_written;   # to remove any possible duplicates
while (my @tuples = Bio::KBase::Utilities::ScriptThing::GetBatch($ih, undef, $column)) {
    my @h = map { $_->[0] } @tuples;
    my $h = $kbO->get_entity_ProteinSequence(\@h,['sequence']);
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
        else
        {
	    my $seq = $v->{sequence};
	    if ($fasta)
	    {
		if (! $fasta_written{$id})
		{
		    $fasta_written{$id} = 1;
		    my $hdr = "";
		    if ($fasta_comment)
		    {
			my @fields = split(/\t/,$line);
			$hdr = join("; ",map { $fields[$_-1] } split(/,/,$fasta_comment));
		    }
		    print ">$id $hdr\n$seq\n";
		}
	    }
	    else
	    {
		print "$line\t$seq\n";
	    }
        }
    }
}
