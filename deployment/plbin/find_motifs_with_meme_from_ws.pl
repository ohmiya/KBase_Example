use strict;
use Data::Dumper;
use Carp;

=head1 NAME

    find_motifs_with_meme_from_ws - search motifs in a set of sequences stored in workspace using MEME

=head1 SYNOPSIS

    find_motifs_with_meme_from_ws [--url=http://140.221.85.173:7077/ --ws=<workspace name> --input=<sequence set reference> --mod=<oops|zoops|anr> --nmotifs=<nmotifs> --minw=<minw> --maxw=<maxw> --nsites=<nsites> --minsites=<minsites> --maxsites=<maxsites> --pal --revcomp]

=head1 DESCRIPTION

    Find conserved motifs in a set of nucleotide sequences stored in workspace

=head2 Documentation for underlying call

    Returns name of MemeRunResult object stored in workspace.

=head1 OPTIONS

=over 6

=item B<--url>=I<http://140.221.85.173:7077/>
    the service url

=item B<-h> B<--help>
    print help information

=item B<--version>
    print version information

=item B<--ws>
    workspace name where run result will be stored    

=item B<--input>
    Workspace reference of the input sequence set

=item B<--mod>
    distribution of motifs (oops =  One Occurrence Per Sequence, zoops = Zero or One Occurrence Per Sequence, anr = Any Number of Repetitions)

=item B<--nmotifs>
    maximum number of motifs to find

=item B<--minw>
    minumum motif width

=item B<--maxw>
    maximum motif width

=item B<--nsites>
    number of sites for each motif

=item B<--minsites>
    minimum number of sites for each motif

=item B<--maxsites>
    maximum number of sites for each motif

=item B<--pal>
    force palindromes

=item B<--revcomp>
    allow sites on + or - DNA strands. Default: look for DNA motifs only on the strand given in the training set.

=back

=head1 EXAMPLE

    find_motifs_with_meme_from_ws --url=http://140.221.85.173:7077/ --ws=AKtest --input=\"AKtest/kb|sequenceset.8\" --mod=oops --nmotifs=2 --minw=14 --maxw=28
    find_motifs_with_meme_from_ws --help
    find_motifs_with_meme_from_ws --version

=head1 VERSION

    1.0

=cut

use Getopt::Long;
use Bio::KBase::meme::Client;
use Config::Simple;
use Bio::KBase::Auth;
use Bio::KBase::AuthToken;
use Bio::KBase::AuthUser;

my $usage = "Usage: find_motifs_with_meme_from_ws [--url=http://140.221.85.173:7077/ --ws=<workspace name> --input=<sequence set reference> --mod=<oops|zoops|anr> --nmotifs=<nmotifs> --minw=<minw> --maxw=<maxw> --nsites=<nsites> --minsites=<minsites> --maxsites=<maxsites> --pal --revcomp]\n";

my $url        = "http://140.221.85.173:7077/";
my $input      = "";
my $ws		   = "";
my $mod        = "oops";
my $nmotifs    = 2;
my $minw       = 14;
my $maxw       = 28;
my $nsites     = 0;
my $minsites   = 0;
my $maxsites   = 0;
my $pal        = 0;
my $revcomp    = 0;
my $help       = 0;
my $version    = 0;

GetOptions("help"       => \$help,
           "version"    => \$version,
           "ws=s"    => \$ws,
           "input=s"    => \$input,
           "mod=s"    => \$mod,
           "nmotifs=i"    => \$nmotifs,
           "minw=i"    => \$minw,
           "maxw=i"    => \$maxw,
           "nsites:i"    => \$nsites,
           "minsites:i"    => \$minsites,
           "maxsites:i"    => \$maxsites,
           "pal:i"    => \$pal,
           "revcomp:i"    => \$revcomp,
           "url=s"     => \$url) 
           or exit(1);

if($help){
print "NAME\n";
print "find_motifs_with_meme_from_ws - This command reconstructs motifs with MEME in a set of sequences stored in workspace.\n";
print "\n";
print "\n";
print "VERSION\n";
print "1.0\n";
print "\n";
print "SYNOPSIS\n";
print "find_motifs_with_meme_from_ws [--url=http://140.221.85.173:7077/ --ws=<workspace name> --input=<sequence set reference> --mod=<oops|zoops|anr> --nmotifs=<nmotifs> --minw=<minw> --maxw=<maxw> --nsites=<nsites> --minsites=<minsites> --maxsites=<maxsites> --pal --revcomp --user=<username> --pw=<password>]\n";
print "\n";
print "DESCRIPTION\n";
print "INPUT:            This command requires the URL of the service, reference of a sequence set and parameters.\n";
print "\n";
print "OUTPUT:           This command returns name of MEME run result.\n";
print "\n";
print "PARAMETERS:\n";
print "--url             The URL of the service, --url=http://140.221.85.173:7077/, required.\n";
print "\n";
print "--ws              Workspace name, required.\n";
print "\n";
print "--input           Workspace reference of the input sequence set, required.\n";
print "\n";
print "--mod             Distribution of motifs (oops =  One Occurrence Per Sequence, zoops = Zero or One Occurrence Per Sequence, anr = Any Number of Repetitions), required.\n";
print "\n";
print "--nmotifs         Maximum number of motifs to find, required.\n";
print "\n";
print "--minw            Minumum motif width, required.\n";
print "\n";
print "--maxw            Maximum motif width, required.\n";
print "\n";
print "--nsites          Number of sites for each motif.\n";
print "\n";
print "--minsites        Minimum number of sites for each motif.\n";
print "\n";
print "--maxsites        Maximum number of sites for each motif.\n";
print "\n";
print "--pal             Force palindromes.\n";
print "\n";
print "--revcomp         Allow sites on + or - DNA strands. Default: look for DNA motifs only on the strand given in the training set.\n";
print "\n";
print "--help            Display help message to standard out and exit with error code zero; \n";
print "                  ignore all other command-line arguments.  \n";
print "--version         Print version information. \n";
print "\n";
print " \n";
print "EXAMPLES \n";
print "find_motifs_with_meme_from_ws --url=http://140.221.85.173:7077/ --ws=AKtest --input=\"AKtest/kb|sequenceset.8\" --mod=oops --nmotifs=2 --minw=14 --maxw=28 --user=<username> --pw=<password>\n";
print "\n";
print "This command will return a collection of two motifs with length between 14 and 28 bp.\n";
print "\n";
print "\n";
print "Report bugs to aekazakov\@lbl.gov\n";
exit(0);
};

if($version)
{
    print "find_motifs_with_meme_from_ws 1.0\n";
    print "Copyright (C) 2013 DOE Systems Biology Knowledgebase\n";
    print "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n";
    print "This is free software: you are free to change and redistribute it.\n";
    print "There is NO WARRANTY, to the extent permitted by law.\n";
    print "\n";
    print "Report bugs to aekazakov\@lbl.gov\n";
    exit(0);
};

unless (@ARGV == 0){
    print $usage;
    exit(1);
};

my $token='';
my $user="";
my $pw="";
my $auth_user = Bio::KBase::AuthUser->new();
my $kbConfPath = $Bio::KBase::Auth::ConfPath;

if (defined($ENV{KB_RUNNING_IN_IRIS})) {
        $token = $ENV{KB_AUTH_TOKEN};
} elsif ( -e $kbConfPath ) {
        my $cfg = new Config::Simple($kbConfPath);
        $user = $cfg->param("authentication.user_id");
        $pw = $cfg->param("authentication.password");
        $cfg->close();
        $token = Bio::KBase::AuthToken->new( user_id => $user, password => $pw);
        $auth_user->get( token => $token->token );
}

if ($token->error_message){
	print $token->error_message."\n\n";
	exit(1);
};

my $meme_run_parameters = {
	"mod"=>$mod,
    "nmotifs"=>$nmotifs,
    "minw"=>$minw,
    "maxw"=>$maxw,
    "nsites"=>$nsites,
    "minsites"=>$minsites,
    "maxsites"=>$maxsites,
    "pal"=>$pal,
    "revcomp"=>$revcomp,
    "source_ref"=>$input
};

my $obj = {
	method => "MEME.find_motifs_with_meme_from_ws",
	params => [$ws, $meme_run_parameters],
};

my $client = Bio::KBase::meme::Client::RpcClient->new;
$client->{token} = $token->token;

my $result = $client->call($url, $obj);

my @keys = keys % { $result };

if (${$result}{is_success} == 1){
	my $result_id = ${$result}{jsontext};
	$result_id =~ s/\"\]\}$//;
	$result_id =~ s/^.*\"\,\"result\"\:\[\"//;
	print $result_id."\n\n";
	exit(0);
}
else {
	print ${$result}{jsontext}."\n";
	exit(1);
}
exit(1);


