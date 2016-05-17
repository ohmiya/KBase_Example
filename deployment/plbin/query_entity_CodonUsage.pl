use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#


=head1 NAME

query_entity_CodonUsage

=head1 SYNOPSIS

query_entity_CodonUsage [--is field,value] [--like field,value] [--op operator,field,value]

=head1 DESCRIPTION

Query the entity CodonUsage. Results are limited using one or more of the query flags:

=over 4

=item the C<--is> flag to match for exact values; 

=item the C<--like> flag for SQL LIKE searches, or 

=item the C<--op> flag for making other comparisons. 

=back

This entity contains information about the codon usage
frequency in a particular genome with respect to a particular
type of analysis (e.g. high-expression genes, modal, mean,
etc.).

Example:

    query_entity_CodonUsage -is id,exact-match-value -a > records

=head2 Related entities

The CodonUsage entity has the following relationship links:

=over 4
    
=item AreCodonsFor Genome


=back

=head1 COMMAND-LINE OPTIONS

query_entity_CodonUsage [arguments] > records

=over 4

=item --is field,value

Limit the results to entities where the given field has the given value.

=item --like field,value

Limit the results to entities where the given field is LIKE (in the sql sense) the given value.

=item --op operator,field,value

Limit the results to entities where the given field is related to the given value based on the given operator.

The operators supported are as follows. We provide text based alternatives to the comparison
operators so that extra quoting is not required to keep the command-line shell from 
confusing them with shell I/O redirection operators.

=over 4

=item < or lt

=item > or gt

=item <=  or le

=item >= or ge

=item =

=item LIKE

=back

=item --a

Return all fields.

=item --show-fields

Display a list of the fields available for use.

=item --fields field-list

Choose a set of fields to return. Field-list is a comma-separated list of 
strings. The following fields are available:

=over 4

=item frequencies

=item genetic_code

=item type

=item subtype

=back    
   
=back

=head1 AUTHORS

L<The SEED Project|http://www.theseed.org>

=cut

use Bio::KBase::CDMI::CDMIClient;
use Getopt::Long;

#Default fields

my @all_fields = ( 'frequencies', 'genetic_code', 'type', 'subtype' );
my %all_fields = map { $_ => 1 } @all_fields, 'id';

our $usage = <<'END';
query_entity_CodonUsage [arguments] > records

--is field,value
    Limit the results to entities where the given field has the given value.

--like field,value
    Limit the results to entities where the given field is LIKE (in the sql sense) the given value.

--op operator,field,value
    Limit the results to entities where the given field is related to
    the given value based on the given operator.

    The operators supported are as follows. We provide text based
    alternatives to the comparison operators so that extra quoting is
    not required to keep the command-line shell from confusing them
    with shell I/O redirection operators.

        < or lt
        > or gt
        <=  or le
        >= or ge
        =
        LIKE

-a
    Return all fields.

--show-fields
    Display a list of the fields available for use.

--fields field-list
    Choose a set of fields to return. Field-list is a comma-separated list of 
    strings. The following fields are available:

        frequencies
        genetic_code
        type
        subtype
END

my $a;
my $f;
my @fields;
my $help;
my $show_fields;
my @query_is;
my @query_like;
my @query_op;

my %op_map = ('>', '>',
	      'gt', '>',
	      '<', '<',
	      'lt', '<',
	      '>=', '>=',
	      'ge', '>=',
	      '<=', '<=',
	      'le', '<=',
	      'like', 'LIKE',
	      );

my $geO = Bio::KBase::CDMI::CDMIClient->new_get_entity_for_script("all-fields|a" => \$a,
								  "show-fields"	 => \$show_fields,
								  "help|h"	 => \$help,
								  "is=s"	 => \@query_is,
								  "like=s"	 => \@query_like,
								  "op=s"	 => \@query_op,
								  "fields=s"	 => \$f);

if ($help)
{
    print $usage;
    exit 0;
}
elsif ($show_fields)
{
    print STDERR "Available fields:\n";
    print STDERR "\t$_\n" foreach @all_fields;
    exit 0;
}

if (@ARGV != 0 || ($a && $f))
{
    print STDERR $usage, "\n";
    exit 1;
}

if ($a)
{
    @fields = @all_fields;
}
elsif ($f) {
    my @err;
    for my $field (split(",", $f))
    {
	if (!$all_fields{$field})
	{
	    push(@err, $field);
	}
	else
	{
	    push(@fields, $field);
	}
    }
    if (@err)
    {
	print STDERR "all_entities_CodonUsage: unknown fields @err. Valid fields are: @all_fields\n";
	exit 1;
    }
}

my @qry;

for my $ent (@query_is)
{
    my($field,$value) = split(/,/, $ent, 2);
    if (!$all_fields{$field})
    {
	die "$field is not a valid field\n";
    }
    
    push(@qry, [$field, '=', $value]);
}

for my $ent (@query_like)
{
    my($field,$value) = split(/,/, $ent, 2);
    if (!$all_fields{$field})
    {
	die "$field is not a valid field\n";
    }
    
    push(@qry, [$field, 'LIKE', $value]);
}

for my $ent (@query_op)
{
    my($op,$field,$value) = split(/,/, $ent, 3);

    if (!$all_fields{$field})
    {
	die "$field is not a valid field\n";
    }
    my $mapped_op = $op_map{lc($op)};
    if (!$mapped_op)
    {
	die "$op is not a valid operator\n";
    }
    
    push(@qry, [$field, $mapped_op, $value]);
}

my $h = $geO->query_entity_CodonUsage(\@qry, \@fields );

while (my($k, $v) = each %$h)
{
    print join("\t", $k, map { ref($_) eq 'ARRAY' ? join(",", @$_) : $_ } @$v{@fields}), "\n";
}

