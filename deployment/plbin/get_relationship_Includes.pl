use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#

=head1 NAME

get_relationship_Includes

=head1 SYNOPSIS

get_relationship_Includes [-c N] [-a] [--fields field-list] < ids > table.with.fields.added

=head1 DESCRIPTION

A subsystem is defined by its roles. The subsystem's variants
contain slightly different sets of roles, but all of the roles in a
variant must be connected to the parent subsystem by this
relationship. A subsystem always has at least one role, and a role
always belongs to at least one subsystem.

Example:

    get_relationship_Includes -a < ids > table.with.fields.added

would read in a file of ids and add a column for each field in the relationship.

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the id. If some other column contains the id,
use

    -c N

where N is the column (from 1) that contains the id.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head1 COMMAND-LINE OPTIONS

Usage: get_relationship_Includes [arguments] < ids > table.with.fields.added

=over 4

=item -c num

Select the identifier from column num

=item -from field-list

Choose a set of fields from the Subsystem
entity to return. Field-list is a comma-separated list of strings. The
following fields are available:

=over 4

=item id

=item version

=item curator

=item notes

=item description

=item usable

=item private

=item cluster_based

=item experimental

=back    

=item -rel field-list

Choose a set of fields from the relationship to return. Field-list is a comma-separated list of 
strings. The following fields are available:

=over 4

=item from_link

=item to_link

=item sequence

=item abbreviation

=item auxiliary

=back    

=item -to field-list

Choose a set of fields from the Role entity to return. Field-list is a comma-separated list of 
strings. The following fields are available:

=over 4

=item id

=item hypothetical

=back    

=back

=head1 AUTHORS

L<The SEED Project|http://www.theseed.org>

=cut

use Bio::KBase::Utilities::ScriptThing;
use Bio::KBase::CDMI::CDMIClient;
use Getopt::Long;

#Default fields
 
my @all_from_fields = ( 'id', 'version', 'curator', 'notes', 'description', 'usable', 'private', 'cluster_based', 'experimental' );
my @all_rel_fields = ( 'from_link', 'to_link', 'sequence', 'abbreviation', 'auxiliary' );
my @all_to_fields = ( 'id', 'hypothetical' );

my %all_from_fields = map { $_ => 1 } @all_from_fields;
my %all_rel_fields = map { $_ => 1 } @all_rel_fields;
my %all_to_fields = map { $_ => 1 } @all_to_fields;

my @default_fields = ('from-link', 'to-link');

my @from_fields;
my @rel_fields;
my @to_fields;

our $usage = <<'END';
Usage: get_relationship_Includes [arguments] < ids > table.with.fields.added

--show-fields
    List the available fields.

-c num        
    Select the identifier from column num

--from field-list
    Choose a set of fields from the Subsystem
    entity to return. Field-list is a comma-separated list of strings. The
    following fields are available:
        id
        version
        curator
        notes
        description
        usable
        private
        cluster_based
        experimental

--rel field-list
    Choose a set of fields from the relationship to return. Field-list is a comma-separated list of 
    strings. The following fields are available:
        from_link
        to_link
        sequence
        abbreviation
        auxiliary

--to field-list
    Choose a set of fields from the Role entity to 
    return. Field-list is a comma-separated list of strings. The following fields are available:
        id
        hypothetical

END

my $column;
my $input_file;
my $a;
my $f;
my $r;
my $t;
my $help;
my $show_fields;
my $i = "-";

my $geO = Bio::KBase::CDMI::CDMIClient->new_get_entity_for_script("c=i"		=> \$column,
								  "h"	   	=> \$help,
								  "show-fields"	=> \$show_fields,
								  "a"	   	=> \$a,
								  "from=s" 	=> \$f,
								  "rel=s" 	=> \$r,
								  "to=s" 	=> \$t,
								  'i=s'	   	=> \$i);

if ($help) {
    print $usage;
    exit 0;
}

if ($show_fields)
{
    print "from fields:\n";
    print "    $_\n" foreach @all_from_fields;
    print "relation fields:\n";
    print "    $_\n" foreach @all_rel_fields;
    print "to fields:\n";
    print "    $_\n" foreach @all_to_fields;
    exit 0;
}

if ($a  && ($f || $r || $t)) {die $usage};

if ($a) {
	@from_fields = @all_from_fields;
	@rel_fields = @all_rel_fields;
	@to_fields = @all_to_fields;
} elsif ($f || $t || $r) {
	my $err = 0;
	if ($f) {
		@from_fields = split(",", $f);
		$err += check_fields(\@from_fields, %all_from_fields);
	}
	if ($r) {
		@rel_fields = split(",", $r);
		$err += check_fields(\@rel_fields, %all_rel_fields);
	}
	if ($t) {
		@to_fields = split(",", $t);
		$err += check_fields(\@to_fields, %all_to_fields);
	}
	if ($err) {exit 1;}	
} else {
	@rel_fields =  @default_fields;
}
 
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
    my $h = $geO->get_relationship_Includes(\@h, \@from_fields, \@rel_fields, \@to_fields);
    my %results;
    for my $result (@$h) {
        my @from;
        my @rel;
        my @to;
        my $from_id;
        my $res = $result->[0];
	for my $key (@from_fields) {
		push (@from,$res->{$key});
	}
        $res = $result->[1];
	$from_id = $res->{'from_link'};
	for my $key (@rel_fields) {
		push (@rel,$res->{$key});
	}
	$res = $result->[2];
	for my $key (@to_fields) {
		push (@to,$res->{$key});
	}
        if ($from_id) {
	    push @{$results{$from_id}}, [@from, @rel, @to];
        }
    }
    for my $tuple (@tuples)
    {
	my($id, $line) = @$tuple;
	my $resultsForId = $results{$id};
	if ($resultsForId) {
	    for my $result (@$resultsForId) {
		print join("\t", $line, @$result) . "\n";
	    }
	}
    }
}

sub check_fields {
	my ($fields, %all_fields) = @_;
	my @err;
	for my $field (@$fields) {
		if (!$all_fields{$field})
		{
		    push(@err, $field);
		}
        }
	if (@err) {
		my @f = keys %all_fields;
		print STDERR "get_relationship_Includes: unknown fields @err. Valid fields are @f\n";
		return 1;
	}
	return 0;
}

