use strict;
use Data::Dumper;
use Carp;

=head1 NAME

get_pspm_collection_from_meme_result_job_from_ws - converts MEME run result into collection of position-specific probability matrices

=head1 SYNOPSIS

get_pspm_collection_from_meme_result_job_from_ws [--url=http://140.221.85.173:7077/ --ws=<workspace ID> --input=<MemeRunResult ID> --user=<username> --pw=<password>]

=head1 DESCRIPTION

A command for conversion of MEME run result into a collection of PSPMs (position-specific probability matrices)

=head2 Documentation for underlying call

Returns Job object ID that keeps KBase ID of MemePSPMCollection.

=head1 OPTIONS

=over 6

=item B<--url>=I<[http://140.221.85.173:7077/]>
the service url

=item B<-h> B<--help>
print help information

=item B<--version>
print version information

=item B<--ws>
workspace name where result will be stored

=item B<--input>
workspace reference of the MemeRunResult

=item B<--user>
User name for access to workspace

=item B<--pw>
Password for access to workspace

=back

=head1 EXAMPLE

get_pspm_collection_from_meme_result_job_from_ws --url=http://140.221.85.173:7077/ --ws=AKtest --input=\"AKtest/kb|memerunresult.15\" 
get_pspm_collection_from_meme_result_job_from_ws --help
get_pspm_collection_from_meme_result_job_from_ws --version

=head1 VERSION

1.0

=cut

use Getopt::Long;
use Bio::KBase::meme::Client;
use Config::Simple;
use Bio::KBase::Auth;
use Bio::KBase::AuthToken;
use Bio::KBase::AuthUser;


my $usage = "Usage: get_pspm_collection_from_meme_result_job_from_ws [--url=http://140.221.85.173:7077/ --ws=<workspace name> --input=<MemeRunResult reference> --user=<username> --pw=<password>]\n";

my $url       = "http://140.221.85.173:7077/";
my $ws   	  = "";
my $input     = "";
my $user       = "";
my $pw         = "";
my $help      = 0;
my $version   = 0;

GetOptions("help"       	=> \$help,
           "version"    	=> \$version,
           "ws=s"           => \$ws,
           "input=s"        => \$input,
           "user=s"         => \$user,
           "pw=s"           => \$pw,
           "url=s"     		=> \$url) or 
               exit(1);
           
if($help){
print "NAME\n";
print "get_pspm_collection_from_meme_result_job_from_ws - converts MEME run result into collection of position-specific probability matrices\n";
print "\n";
print "\n";
print "VERSION\n";
print "1.0\n";
print "\n";
print "SYNOPSIS\n";
print "get_pspm_collection_from_meme_result_job_from_ws [--url=http://140.221.85.173:7077/ --ws=<workspace ID> --input=<MemeRunResult ID> --user=<username> --pw=<password>]\n";
print "\n";
print "DESCRIPTION\n";
print "INPUT:            This command requires the URL of the service, workspace name, workspace reference of MemeRunresult, .\n";
print "\n";
print "OUTPUT:           The output of this command is Job object ID.\n";
print "\n";
print "PARAMETERS:\n";
print "--url             The URL of the service, --url=http://140.221.85.173:7077/, required.\n";
print "\n";
print "--ws              Workspace name, required.\n";
print "\n";
print "--input           Workspace reference of the MemeRunResult , required.\n";
print "\n";
print "--user            User name for access to workspace.\n";
print "\n";
print "--pw              Password for access to workspace.\n";
print "\n";
print "--help            Display help message to standard out and exit with error code zero; \n";
print "                  ignore all other command-line arguments.  \n";
print "--version         Print version information. \n";
print "\n";
print " \n";
print "EXAMPLES \n";
print "get_pspm_collection_from_meme_result_job_from_ws --url=http://140.221.85.173:7077/ --ws=AKtest --input=\"AKtest/kb|memerunresult.15\" --user=<username> --pw=<password>\n";
print "\n";
print "This command will return Job object ID.\n";
print " \n";
print "Report bugs to aekazakov\@lbl.gov\n";
exit(0);
}

if($version)
{
    print "get_pspm_collection_from_meme_result_job_from_ws\n";
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

my $obj = {
	method => "MEME.get_pspm_collection_from_meme_result_job_from_ws",
	params => [$ws, $input],
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

