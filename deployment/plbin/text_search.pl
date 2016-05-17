use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#

=head1 NAME

text_search

=head1 SYNOPSIS

text_search [arguments] < input > output

=head1 DESCRIPTION


text_search performs a search against a full-text index maintained 
for the CDMI. The parameter "input" is the text string to be searched for.
The parameter "entities" defines the entities to be searched. If the list
is empty, all indexed entities will be searched. The "start" and "count"
parameters limit the results to "count" hits starting at "start".


Example:

    text_search [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifer. If another column contains the identifier
use

    -c N

where N is the column (from 1) that contains the subsystem.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head1 COMMAND-LINE OPTIONS

Usage: text_search [arguments] < input > output


    --start string
    --count string
    --entity string

=head1 AUTHORS

L<The SEED Project|http://www.theseed.org>

=cut


our $usage = "usage: text_search [-start N] [-count N] [-entity name -entity name ..] search-string\n";

use Bio::KBase::CDMI::CDMIClient;
use Bio::KBase::Utilities::ScriptThing;

my $start = 0;
my $count = 100;
my @entities;
my $kbO = Bio::KBase::CDMI::CDMIClient->new_for_script('start=s' => \$start,
				     'count=s' => \$count,
				     'entity=s' => \@entities);

if (@ARGV == 0 || ! $kbO) { print STDERR $usage; exit }

my $string = join(" ", @ARGV);

my $res = $kbO->text_search($string, $start, $count, \@entities);
for my $entity (keys %$res)
{
    my @hdr;
    for my $hit (@{$res->{$entity}})
    {
	my($weight, $data) = @$hit;
	if (!@hdr)
	{
	    @hdr = sort keys %$data;
	    print join("\t", "#", @hdr), "\n";
	}
	print join("\t", $entity, @$data{@hdr}), "\n";

    }
}

__DATA__
