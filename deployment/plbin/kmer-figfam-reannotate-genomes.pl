use strict;
use Bio::KBase::KmerAnnotationByFigfam::Client;
use Bio::KBase::CDMI::Client;
use Getopt::Long;
use JSON;
use Data::Dumper;
use Proc::ParallelLoop;

my $url;
my $port;
my $parallel = 1;
my $output_dir;

my $usage = "Usage: kmer-figfams-reannotate-genomes [--output-dir dir] [--parallel N] [--port port] [--url url] < list-of-genome-ids \n";

my $rc = GetOptions("port=s" => \$port,
		    "url=s"  => \$url,
		    "parallel=s" => \$parallel,
		    "output-dir=s" => \$output_dir,
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

my @work = <>;
chomp @work;

pareach \@work, sub {
    my $gid = shift;

    my $client = Bio::KBase::KmerAnnotationByFigfam::Client->new($url);
    my $cdm = Bio::KBase::CDMI::Client->new();

    process_genome($gid, $client, $cdm);

}, { Max_Workers => $parallel };


sub process_genome
{
    my($gid, $kmer_client, $cdm) = @_;

    my $fids = $cdm->genomes_to_fids([$gid], ['peg', 'CDS']);
    $fids = $fids->{$gid};
    my $prots = $cdm->fids_to_protein_sequences($fids);

    my $max_size = 10_000_000;
    my $size = 0;
    my @input;

    my $params = {
	kmer_size => 8,
	detailed => 0,
    };

    my $fh;

    if ($output_dir)
    {
	open($fh, ">", "$output_dir/$gid") or die "Cannot open $output_dir/$gid: $!";
    }
    else
    {
	$fh = \*STDOUT;
    }

    for my $fid (@$fids)
    {
	push(@input, [$fid, $prots->{$fid}]);
	$size += length($prots->{$fid});
	if ($size > $max_size)
	{
	    process_proteins($kmer_client, $params,\@input, $fh);
	    @input = ();
	    $size = 0;
	}
    }
    if (@input)
    {
	process_proteins($kmer_client, $params, \@input, $fh);
    }
}

sub process_proteins
{
    my($client, $params, $input, $output_fh) = @_;
    my $res = $client->annotate_proteins($input, $params);

    for my $ent (@$res)
    {
	my $details = $ent->[6];
	print $output_fh join("\t", @$ent[0..5]), "\n";
	if (ref($details))
	{
	    print $output_fh join("\t", '', @$_), "\n" foreach @$details;
	}
    }
}
