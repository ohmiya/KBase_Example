use strict;
use Data::Dumper;
use Carp;
use Getopt::Long;
use DBI;


=head1 NAME

get_go_annotation - find out which GO terms are associated with a list of kbase gene ids. 

=head1 SYNOPSIS

get_go_annotation [--url=http://kbase.us/services/ontology_service] [--domain_list=biological_process] [--evidence_code_list=IEA] < geneIDs

=head1 DESCRIPTION

Use this function to get GO ids, GO description, GO domain information (biological process, molecular function, cellular component) and list of evidence codes for a given list of kbase gene ids. 

=head2 Documentation for underlying call

This function call accepts three parameters: a list of kbase gene-identifiers, a list of ontology domains, and a list of evidence codes. The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of the last two lists is not empty then the gene-id and go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Finally, this function returns a mapping of kbase gene-id to go-ids along with go-description, ontology domain, and evidence code; note that in the returned table of results, each gene-id is associated with a list of one of more go-ids. Also, if no species is provided as input then by default, Arabidopsis thaliana is used as the input species.

=head1 OPTIONS

=over 6

=item B<-u> I<[http://kbase.us/services/ontology_service]> B<--url>=I<[http://kbase.us/services/ontology_service]>
url of the server


=item B<--help>
prints help information

=item B<--version>
print version information

=item B<--domain_list> comma separated list of ontology domains e.g. --domain_list=[biological_process,cellular_component]

=item B<--evidence_code_list> comma separated list of ontology evidence codes e.g. --evidence_code_list=[IEA,IEP]

=back

=head1 EXAMPLE

 echo "kb|g.3899.CDS.35386" | get_go_annotation 
 echo "kb|g.3899.CDS.35386" | get_go_annotation --evidence_code=IEA
 get_go_annotation --help
 get_go_annotation --version

=head1 VERSION

0.1

=cut

use Bio::KBase::OntologyService::Client;

my $usage = "Usage: $0 [--url=http://kbase.us/services/ontology_service] < geneIDs\n";

my $url        = "http://kbase.us/services/ontology_service";


my $help       = 0;
my $version    = 0;

GetOptions("help"       => \$help,
           "version"    => \$version,
           "url=s"     => \$url
           ) or die $usage;

if($help)
{
        print <<MAN;
        DESCRIPTION
	 This function call accepts  a list of kbase gene-identifiers. The list of gene identifiers cannot be empty. This function returns a precomputed gene ontology enrichment annotations. 
MAN

	print "$usage\n";
	print "\n";
	print "General options\n";
    print "\t--url=[http://kbase.us/services/ontology_service]\t\turl of the server\n";
	print "\t--help\t\tprint help information\n";
	print "\t--version\t\tprint version information\n";
	print "\n";
	print "Examples: \n";
	print "echo 'kb|g.3899.CDS.35386,kb|g.3899.CDS.62006' | get_go_annotation ";
	print "\n";
	print "\n";
	print "$0 --help\tprint out help\n";
	print "\n";
	print "$0 --version\tprint out version information\n";
	print "\n";
	print "Report bugs to Shinjae Yoo at sjyoo\@bnl.gov\n";
	exit(0);
}

if($version)
{
	print "$0 version 0.1\n";
	print "Copyright (C) 2014 Shinjae Yoo\n";
	print "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n";
	print "This is free software: you are free to change and redistribute it.\n";
	print "There is NO WARRANTY, to the extent permitted by law.\n";
	print "\n";
	print "Written by Shinjae Yoo and Sunita Kumari\n";
	exit(0);
}

die $usage unless @ARGV == 0;

my $oc = Bio::KBase::OntologyService::Client->new($url);
my @input = <STDIN>;
my $istr = join(" ", @input);
$istr =~ s/[,]/ /g;
@input = split /\s+/, $istr;

my $results = $oc->get_go_annotation(\@input);
foreach my $geneID (keys %{$results->{'gene_enrichment_annotations'}}) {
  foreach my $record (@{$results->{'gene_enrichment_annotations'}->{$geneID}}) {
    print "$geneID\t$record->{'ontology_id'}\t$record->{'p_value'}\t$record->{'ontology_description'}\n";
  }
}





