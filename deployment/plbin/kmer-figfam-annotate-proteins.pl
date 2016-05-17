use strict;
use Bio::KBase::KmerAnnotationByFigfam::Client;
use Getopt::Long;
use JSON;
use Data::Dumper;

my $url;
my $port;

my $usage = "Usage: kmer-figfams-annotate-proteins [--port port] [--url url] < fasta \n";

my $rc = GetOptions("port=s" => \$port,
		    "url=s"  => \$url,
		    );
if (!$rc || @ARGV != 0)
{
    die $usage;
}

if (!$url)
{
    if ($port)
    {
	$url = "http://localhost:$port/";
    }
}
my $client = Bio::KBase::KmerAnnotationByFigfam::Client->new($url);

my $max_size = 1_000_000;
my $size = 0;
my @input;

my $params = {
    kmer_size => 8,
    detailed => 0,
};

while (my($id, $seqp, $comment) = read_fasta_record(\*STDIN))
{
    push(@input, [$id, $$seqp]);
    $size += length($$seqp);
    if ($size > $max_size)
    {
	process(\@input);
	@input = ();
	$size = 0;
    }
}
if (@input)
{
    process(\@input);
}

sub process
{
    my($input) = @_;
    my $res = $client->annotate_proteins($input, $params);

    for my $ent (@$res)
    {
	my $details = $ent->[6];
	print join("\t", @$ent[0..5]), "\n";
	if (ref($details))
	{
	    print join("\t", '', @$_), "\n" foreach @$details;
	}
    }
}

sub read_fasta_record {
    my ($file_handle) = @_;
    my ($old_end_of_record, $fasta_record, @lines, $head, $sequence, $seq_id, $comment, @parsed_fasta_record);

    if (not defined($file_handle))  { $file_handle = \*STDIN; }

    local $/ = "\n>";

    if (defined($fasta_record = <$file_handle>)) {
        chomp $fasta_record;
        @lines  =  split( /\n/, $fasta_record );
        $head   =  shift @lines;
        $head   =~ s/^>?//;
        $head   =~ m/^(\S+)/;
        $seq_id = $1;
        if ($head  =~ m/^\S+\s+(.*)$/)  { $comment = $1; } else { $comment = ""; }
        $sequence  =  join( "", @lines );
        @parsed_fasta_record = ( $seq_id, \$sequence, $comment );
    } else {
        @parsed_fasta_record = ();
    }

    return @parsed_fasta_record;
}
