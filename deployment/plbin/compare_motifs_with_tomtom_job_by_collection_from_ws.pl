use strict;
use Data::Dumper;
use Carp;

=head1 NAME

compare_motifs_with_tomtom_job_by_collection_from_ws - find motifs that are similar to a given DNA motif by searching a database of known motifs.

=head1 SYNOPSIS

compare_motifs_with_tomtom_job_by_collection_from_ws [--url=http://140.221.85.173:7077/ --ws=<workspace ID> --query=<MemePSPMCollection reference> --target=<MemePSPMCollection reference> --matrix=<PSPM ID> --thresh=<threshold> --evalue --dist=<allr|ed|kullback|pearson|sandelin> --internal --min_overlap=<value>] 

=head1 DESCRIPTION

Find motifs that are similar to a given DNA motif by searching a database of known motifs.

=head2 Documentation for underlying call

Returns Job object ID that keeps ID of TOMTOM run result.

=head1 OPTIONS

=over 6

=item B<--url>=I<[http://140.221.85.173:7077/]>
the service url

=item B<-h> B<--help>
print help information

=item B<--version>
print version information

=item B<--ws>
Name of workspace where run result will be stored

=item B<--query>
Workspace reference of the query PSPM collection

=item B<--target>
Workspace reference of the target PSPM collection

=item B<--matrix>
KBase ID of a MemePSPM from the query collection that will be used. If omitted, all motifs in the query collection will be used

=item B<--thresh>
Only report matches with significance values ≤ thresh parameter value. 

=item B<--evalue>
Use the E-value of the match as the significance threshold.

=item B<--dist>
Motif distance calculation algorithm (accepable values are "allr", "ed", "kullback", "pearson", "sandelin").

=item B<--internal>
This parameter forces the shorter motif to be completely contained in the longer motif.

=item B<--min_overlap>
Only report motif matches that overlap by min overlap positions or more.

=back

=head1 EXAMPLE

 compare_motifs_with_tomtom_job_by_collection_from_ws --url=http://140.221.85.173:7077/ --ws=AKtest --query="AKtest/kb|memepspmcollection.1" --target="AKtest/kb|memepspmcollection.1" --thresh=0.0000001 --evalue --dist=pearson --internal --min_overlap=12
 compare_motifs_with_tomtom_job_by_collection_from_ws --help
 compare_motifs_with_tomtom_job_by_collection_from_ws --version

=head1 VERSION

1.0

=cut

use Getopt::Long;
use Bio::KBase::meme::Client;
use Config::Simple;
use Bio::KBase::Auth;
use Bio::KBase::AuthToken;
use Bio::KBase::AuthUser;

my $usage = "Usage: compare_motifs_with_tomtom_job_by_collection_from_ws [--url=http://140.221.85.173:7077/ --ws=<workspace ID> --query=<MemePSPMCollection reference> --target=<MemePSPMCollection reference> --matrix=<PSPM ID> --thresh=<threshold> --evalue --dist=<allr|ed|kullback|pearson|sandelin> --internal --min_overlap=<value>]\n";

my $url        = "http://140.221.85.173:7077/";
my $ws		   = "";
my $query      = "";
my $target     = "";
my $pspm_id    = "";
my $thresh     = 0;
my $evalue     =  0;
my $dist       = "";
my $internal   = 0;
my $min_overlap= 0;
my $help       = 0;
my $version    = 0;

GetOptions("help"           => \$help,
           "version"        => \$version,
           "ws=s"           => \$ws,
           "query=s"        => \$query,
           "target=s"       => \$target,
           "matrix:s"       => \$pspm_id,
           "thresh=f"       => \$thresh,
           "evalue"         => \$evalue,
           "dist=s"         => \$dist,
           "internal"       => \$internal,
           "min_overlap:i"  => \$min_overlap,
           "url=s"          => \$url) or 
           		exit(1);
           
if($help){
print "NAME\n";
print "compare_motifs_with_tomtom_job_by_collection_from_ws - compare two collections of sequence motifs by TOMTOM.\n";
print "\n";
print "\n";
print "VERSION\n";
print "1.0\n";
print "\n";
print "SYNOPSIS\n";
print "compare_motifs_with_tomtom_job_by_collection_from_ws [--url=http://140.221.85.173:7077/ --ws=<workspace ID> --query=<MemePSPMCollection reference> --target=<MemePSPMCollection reference> --matrix=<PSPM ID> --thresh=<threshold> --evalue --dist=<allr|ed|kullback|pearson|sandelin> --internal --min_overlap=<value>] \n";
print "\n";
print "DESCRIPTION\n";
print "INPUT:            This command requires the URL of the service, references of two PSPM collections and parameters.\n";
print "\n";
print "OUTPUT:           The output of this command is a Job object ID.\n";
print "\n";
print "PARAMETERS:\n";
print "--url             The URL of the service, --url=http://140.221.85.173:7077/, required.\n";
print "\n";
print "--ws              Name of workspace where run result will be stored, required.\n";
print "\n";
print "--query           Workspace reference of the query PSPM collection, required.\n";
print "\n";
print "--target           Workspace reference of the target PSPM collection, required.\n";
print "\n";
print "--matrix           KBase ID of a MemePSPM from the query collection that will be used. If omitted, all motifs in the query collection will be used.\n";
print "\n";
print "--thresh          Only report matches with significance values ≤ thresh parameter value. \n";
print "\n";
print "--evalue          Use the E-value of the match as the significance threshold.\n";
print "\n";
print "--dist            Motif distance calculation algorithm (accepable values are \"allr\", \"ed\", \"kullback\", \"pearson\", \"sandelin\").\n";
print "\n";
print "--internal        This parameter forces the shorter motif to be completely contained in the longer motif.\n";
print "\n";
print "--min_overlap     Only report motif matches that overlap by min overlap positions or more.\n";
print "\n";
print "--help            Display help message to standard out and exit with error code zero; \n";
print "                  ignore all other command-line arguments.  \n";
print "--version         Print version information. \n";
print "\n";
print " \n";
print "EXAMPLES \n";
print "compare_motifs_with_tomtom_job_by_collection_from_ws --url=http://140.221.85.173:7077/ --ws=AKtest --query=\"AKtest/kb|memepspmcollection.2\" --target=\"AKtest/kb|memepspmcollection.2\" --thresh=0.0000001 --evalue --dist=pearson --internal --min_overlap=12\n";
print "\n";
print "This command will return a Job object ID.\n";
print "\n";
print " \n";
print "Report bugs to aekazakov\@lbl.gov\n";
exit(0);
}

if($version)
{
    print "compare_motifs_with_tomtom_job_by_collection_from_ws\n";
    print "Copyright (C) 2013 DOE Systems Biology Knowledgebase\n";
    print "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n";
    print "This is free software: you are free to change and redistribute it.\n";
    print "There is NO WARRANTY, to the extent permitted by law.\n";
    print "\n";
	print "Report bugs to aekazakov\@lbl.gov\n";
    exit(0);
}

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

my $tomtom_run_parameters = {
	"thresh"=>$thresh,
    "evalue"=>$evalue,
    "dist"=>$dist,
    "internal"=>$internal,
    "min_overlap"=>$min_overlap,
    "query_ref"=>$query,
    "target_ref"=>$target,
    "pspm_id"=>$pspm_id
};

my $obj = {
	method => "MEME.compare_motifs_with_tomtom_job_by_collection_from_ws",
	params => [$ws, $tomtom_run_parameters],
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

