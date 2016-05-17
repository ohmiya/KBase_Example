use strict;
use Data::Dumper;
use File::Copy;
use Getopt::Long;
use XML::LibXML;
use String::CamelCase 'decamelize';

#
# This is a SAS Component
#

=head1 NAME

ermodel_to_text

=head1 SYNOPSIS

ermodel_to_text [--decamelize] > output

=head1 DESCRIPTION

Given the XML description of an Entity-Relationship model on stdin, dump the description
of the model as an easy-to-parse tab-delimited text file.

=head1 COMMAND-LINE OPTIONS

Usage: ermodel_to_text [--decamelize] > output

    --decamelize

        If set, convert all entity, relationship, and field names to a decamelized form.

=head1 OUTPUT FORMAT

The output is a tab-delimited file. It contains blocks of data delimited by
lines containing only the string "//".

Each block of data describes either an entity or a relationship. A single line
defines the entity or relationship name and the associated metadata. The
remaining lines in the block define the field data associated with the entity or relationship.

An entity line contains the following fields:

=over 4

=item The string "entity"

=item The entity name

=back

A relationship line contains the following fields:

=over 4

=item The string "relationship"

=item The relationship name

=item The name of the "from" entity.

=item The name of the "to" entity.

=item The arity of the relationship (1M or MM).

=item The name of the converse relationship.

=back

Each field description line contains the following fields:

=over 4

=item The name of the field

=item The field type

=item The name of a relation, if the field data is stored in a separate relation.

=back

=head1 AUTHORS

L<The SEED Project|http://www.theseed.org>

=cut

my $decamelize;

my $rc = GetOptions("decamelize" => \$decamelize);

$rc && @ARGV == 0 or die "Usage: $0 [--decamelize] < DBD-xml-file > tab-sep-output\n";

my $doc = XML::LibXML->new->parse_fh(\*STDIN);
$doc or die "Cannot parse XML data\n";

my %etypes;

for my $e ($doc->findnodes('//Entities/Entity'))
{
    my $name = $e->getAttribute("name");
    my $name_conv = convert_name($name);

    my $keytype = $e->getAttribute("keyType");
    $etypes{$name} = $keytype;

    print join("\t", "entity", $name_conv), "\n";
    print join("\t", 'id', $keytype, ''), "\n";
    for my $fn ($e->findnodes('Fields/Field'))
    {
	my $fname = $fn->getAttribute("name");
	my $fname_conv = convert_field_name($fname);
	my $ftype = $fn->getAttribute("type");
	my $rel = $fn->getAttribute("relation");
	print join("\t", $fname_conv, $ftype, $rel), "\n";
    }
    print "//\n";
}

for my $r ($doc->findnodes('//Relationships/Relationship'))
{
    my $name = $r->getAttribute("name");
    my $name_conv = convert_name($name);

    my $from = $r->getAttribute("from");
    my $from_conv = convert_name($from);
    my $from_type = $etypes{$from};

    my $to = $r->getAttribute("to");
    my $to_conv = convert_name($to);
    my $to_type = $etypes{$to};

    my $arity = $r->getAttribute("arity");
    my $converse = $r->getAttribute("converse");
    my $converse_conv = convert_name($converse);

    print join("\t", "relationship", $name_conv, $from_conv, $to_conv, $arity, $converse_conv), "\n";

    print join("\t", 'from_link', $from_type, ''), "\n";
    print join("\t", 'to_link', $to_type, ''), "\n";

    for my $fn ($r->findnodes('Fields/Field'))
    {
	my $fname = $fn->getAttribute("name");
	my $fname_conv = convert_field_name($fname);
	my $ftype = $fn->getAttribute("type");
	my $rel = $fn->getAttribute("relation");
	print join("\t", $fname_conv, $ftype, $rel), "\n";
    }
    print "//\n";
}

sub convert_name
{
    my($n) = @_;
    if ($decamelize)
    {
	return decamelize($n);
    }
    else
    {
	return $n;
    }
}

sub convert_field_name
{
    my($n) = @_;
    $n =~ s/-/_/g;
    return $n;
}

__DATA__
