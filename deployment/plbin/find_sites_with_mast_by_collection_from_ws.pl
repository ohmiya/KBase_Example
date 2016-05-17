use strict;
use Data::Dumper;
use Carp;

=head1 NAME

find_sites_with_mast_by_collection_from_ws - search a sequence database for occurences of known motifs by MAST

=head1 SYNOPSIS

find_sites_with_mast_by_collection_from_ws [--url=http://140.221.85.173:7077/ --ws=<workspace name> --query=<MemePSPMCollection reference> --target=<sequence set reference> --matrix=<PSPM ID> --mt=<mt>]

=head1 DESCRIPTION

Search a set of nucleotide sequences for occurences of known motifs. This program assumes 
exactly one occurrence of each motif per sequence, and each sequence in the database is assigned 
a p-value, based on the product of the p-values of the individual motif occurrences in that sequence. 

=head2 Documentation for underlying call

Returns name of a list of MAST hits.

=head1 OPTIONS

=over 6

=item B<--url>=I<[http://140.221.85.173:7077/]>
the service url

=item B<-h> B<--help>
print help information

=item B<--version>
print version information

=item B<--ws>
    workspace name

=item B<--query>
Workspace reference of the query PSPM collection

=item B<--target>
Workspace reference of the target sequence set

=item B<--matrix>
KBase ID of a MemePSPM from the query collection that will be used. If omitted, all motifs in the query collection will be used

=item B<--mt>
show motif matches with p-value < <mt>

=back

=head1 EXAMPLE

find_sites_with_mast_by_collection_from_ws --url=http://140.221.85.173:7077/ --ws=AKtest --query="AKtest/kb|memepspmcollection.1" --target=\"AKtest/kb|sequenceset.8\" --mt=0.001 
find_sites_with_mast_by_collection_from_ws --help
find_sites_with_mast_by_collection_from_ws --version

=head1 VERSION

1.0

=cut

use Getopt::Long;
use Bio::KBase::meme::Client;
use Config::Simple;
use Bio::KBase::Auth;
use Bio::KBase::AuthToken;
use Bio::KBase::AuthUser;


my $usage = "Usage: find_sites_with_mast_by_collection_from_ws [--url=http://140.221.85.173:7077/ --ws=<workspace name> --query=<MemePSPMCollection reference> --target=<sequence set reference> --matrix=<PSPM ID> --mt=<mt>]\n";

my $url       = "http://140.221.85.173:7077/";
my $ws   	  = "";
my $query     = "";
my $target    = "";
my $pspm_id   = "";
my $mt        = 0;
my $help      = 0;
my $version   = 0;

GetOptions("help"       	=> \$help,
           "version"    	=> \$version,
           "ws=s"           => \$ws,
           "query=s"        => \$query,
           "target=s"       => \$target,
           "matrix:s"       => \$pspm_id,
           "mt=f"    		=> \$mt,
           "url=s"     		=> \$url) or 
               exit(1);
           
if($help){
print "NAME\n";
print "find_sites_with_mast_by_collection_from_ws - search a sequence database for occurences of known motifs by MAST.\n";
print "\n";
print "\n";
print "VERSION\n";
print "1.0\n";
print "\n";
print "SYNOPSIS\n";
print "find_sites_with_mast_by_collection_from_ws [--url=http://140.221.85.173:7077/ --ws=<workspace ID> --query=<MemePSPMCollection ID> --target=<sequence set ID> --matrix=<PSPM ID> --mt=<mt>]\n";
print "\n";
print "DESCRIPTION\n";
print "INPUT:            This command requires the URL of the service, ID of query PSPM collection, ID of target sequence set, p-value threshold .\n";
print "\n";
print "OUTPUT:           The output of this command is KBase ID of a list of MAST hits.\n";
print "\n";
print "PARAMETERS:\n";
print "--url             The URL of the service, --url=http://140.221.85.173:7077/, required.\n";
print "\n";
print "--ws              Workspace name, required.\n";
print "\n";
print "--query           Workspace reference of the query PSPM collection, required.\n";
print "\n";
print "--target          Workspace reference of the target sequence set, required.\n";
print "\n";
print "--matrix          KBase ID of a MemePSPM from the query collection that will be used. If omitted, all motifs in the query collection will be used.\n";
print "\n";
print "--mt              Show motif matches with p-value < <mt>, required.\n";
print "\n";
print "--help            Display help message to standard out and exit with error code zero; \n";
print "                  ignore all other command-line arguments.  \n";
print "--version         Print version information. \n";
print "\n";
print " \n";
print "EXAMPLES \n";
print "find_sites_with_mast_by_collection_from_ws --url=http://140.221.85.173:7077/ --ws=AKtest --query=\"AKtest/kb|memepspmcollection.1\" --target=\"AKtest/kb|sequenceset.8\" --mt=0.001\n";
print "\n";
print "This command will return name of a list of occurences of motifs from the collection in the set of sequences with p-value below 0.001.\n";
print "\n";
print " \n";
print "Report bugs to aekazakov\@lbl.gov\n";
exit(0);
}

if($version)
{
    print "find_sites_with_mast_by_collection_from_ws\n";
    print "Copyright (C) 2013 DOE Systems Biology Knowledgebase\n";
    print "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n";
    print "This is free software: you are free to change and redistribute it.\n";
    print "There is NO WARRANTY, to the extent permitted by law.\n";
    print "\n";
    print "Written by Alexey Kazakov\n";
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

my $meme_run_parameters = {
	"mt"=>$mt,
    "query_ref"=>$query,
    "target_ref"=>$target
};

if ($pspm_id != ""){
$meme_run_parameters->{"pspm_id"} = $pspm_id;
}

my $obj = {
	method => "MEME.find_sites_with_mast_by_collection_from_ws",
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

