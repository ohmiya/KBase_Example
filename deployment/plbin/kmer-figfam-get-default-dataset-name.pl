use strict;
use Bio::KBase::KmerAnnotationByFigfam::Client;
use Getopt::Long;
use JSON;

my $url;
my $port;

my $usage = "Usage: get_default_dataset_name [--port port] [--url url]\n";

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

my @output = $client->get_default_dataset_name(@ARGV);

print to_json(\@output) . "\n";
