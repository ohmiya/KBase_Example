#!/usr/bin/perl
use strict;
use Data::Dumper;
use Carp;
use Getopt::Long;
use DBI;
=head1 NAME

get_go_enrichment - find out enriched GO terms in a set of genes.

=head1 SYNOPSIS

get_go_enrichment [--url=http://kbase.us/services/ontology_service] [--domain_list=biological_process,molecular_function,cellular_component] [--evidence_code_list=IEA]  [--test_type=hypergeometric] < geneIDsList

=head1 DESCRIPTION

Use this function to perform GO enrichment analysis on a set of kbase gene ids..

=head2 Documentation for underlying call

    For a given list of kbase gene ids from a particular genome (for example "Athaliana" ) find out the significantly enriched GO terms in your gene set. This function accepts four parameters: A list of kbase gene-identifiers, a list of ontology domains (e.g."biological process", "molecular function", "cellular component"), a list of evidence codes (e.g."IEA","IDA","IEP" etc.), and test type (e.g. "hypergeometric"). The list of kbase gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Final filtered list of the kbase gene-id to go-ids mapping is used to calculate GO enrichment using hypergeometric test and provides pvalues.The default pvalue cutoff is used as 0.05. Also, if input species is not provided then by default Arabidopsis thaliana is considered the input species.


=head1 OPTIONS

=over 6

=item B<-u> I<[http://kbase.us/services/ontology_service]> B<--url>=I<[http://kbase.us/services/ontology_service]>
url of the server

=item B<-h> B<--help>
prints help information

=item B<--version>
print version information

=item B<--domain_list> comman separated list of ontology domains e.g. [biological_process,molecular_function,cellular_component]

=item B<--evidence_code_list> commma separated list of ontology term evidence code e.g [IEA,IEP]

=item B<--test_type> statistical test to use for enrichment analysis [hypergeometric|chisq]

=back

=head1 EXAMPLE

 echo "kb|g.3899.CDS.35386" | get_go_enrichment
 echo "kb|g.3899.CDS.35386" | get_go_enrichment --evidence_code=[IEA,IEP]
 get_go_enrichment --help
 get_go_enrichment --version

=head1 VERSION

0.1

=cut

use Bio::KBase::OntologyService::Client;

my $usage = "Usage: $0 [--url=http://kbase.us/services/ontology_service] [--domain_list=biological_process] [--evidence_code_list=IEA]  [--test_type=hypergeometric] [--p_value=XXX]< geneIDs  \n";

my $url        = "http://kbase.us/services/ontology_service";
my $type       = "hypergeometric";
my $help       = 0;
my $version    = 0;
my $domainList="biological_process,molecular_function,cellular_component";
my $ecList     = "IEA,IDA,IPI,IMP,IGI,IEP,ISS,ISS,ISO,ISA,ISM,IGC,IBA,IBD,IKR,IRD,RCA,TAS,NAS,IC,ND,NR";
my $pvalue_cutoff="0.05";
my $ontologytype="GO";

GetOptions("help"       => \$help,
           "version"    => \$version,
           "url=s"      => \$url, 
           "domain_list=s" => \$domainList, 
           "evidence_code_list=s" => \$ecList,
           "test_type=s" => \$type,
	"p_value=s"=>\$pvalue_cutoff,
"ontology_type=s"=>\$ontologytype
) or die $usage;

if($help)
{
    print <<MAN;
    DESCRIPTION
         For a given list of kbase gene ids from a particular genome (for example "Athaliana" ) find out the significantly enriched GO terms in your gene set. This function accepts four parameters: A list of kbase gene-identifiers, a list of ontology domains (e.g."biological process", "molecular function", "cellular component"), a list of evidence codes (e.g."IEA","IDA","IEP" etc.), and test type (e.g. "hypergeometric"). The list of kbase gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Final filtered list of the kbase gene-id to go-ids mapping is used to calculate GO enrichment using hypergeometric test and provides pvalues.The default pvalue cutoff is used as 0.05. Also, if input species is not provided then by default Arabidopsis thaliana is considered the input species.
MAN

	print "$usage\n";
	print "\n";
	print "General options\n";
    print "\t--url=[http://kbase.us/services/ontology_service]\t\turl of the server\n";
	print "\t--domain_list=[biological_process,molecular_function,cellular_component]\t\tdomain list (comma separated)\n";
	print "\t--evidence_code_list=[XXX,YYY,ZZZ,...]\t\tGO evidence code list (comma separated)\n";
	print "\t--test_type=[hypergeometric|chisq]\t\tthe types of test\n";
	print "\t--help\t\tprint help information\n";
	print "\t--version\t\tprint version information\n";
	print "\n";
	print "Examples: \n";
	print "echo 'kb|g.3899.CDS.35386' | $0\n";
	print "\n\n";
	print " echo  'kb|g.3899.CDS.35386,kb|g.3899.CDS.62006,kb|g.3899.CDS.62602,kb|g.3899.CDS.56001'| get_go_enrichment\n";
	print "\n\n";
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
my @dl = split/,/, $domainList;
my @el = split/,/, $ecList;
my @input = <STDIN>;
my $istr = join(" ", @input);
$istr =~ s/[,]/ /g;
@input = split /\s+/, $istr;

my $results = $oc->get_go_enrichment( \@input, \@dl, \@el, $type, $ontologytype);

#print "@input\n===\n";

foreach my $hr (@$results) {

	next if $hr->{"goID"} !~/$ontologytype/;
	
	next if  $hr->{"pvalue"} >=  $pvalue_cutoff;
	print $hr->{"goID"}."\t".$hr->{"pvalue"}."\t".${$hr->{"goDesc"}}[0]."\t".${$hr->{"goDesc"}}[1]."\t";

my $go_id=$hr->{"goID"};

	my %tem_gene_hash;
#get the gene associated with this GO term
	undef (%tem_gene_hash);

	foreach my $ggene(@input){
	my @tem_gene_array;
	$tem_gene_array[0]=$ggene;
	my $my_goid_list=$oc->get_goidlist(\@tem_gene_array,\@dl,\@el);
	my %my_hash=%$my_goid_list;
	$tem_gene_hash{$ggene}=1 if grep /$go_id/, keys %{$my_hash{$ggene}};
	}


	my @tem_in;
	undef @tem_in;
	foreach my $in(keys %tem_gene_hash){
		push @tem_in,$in;
	}
	my $new_line=join",",@tem_in;
	
	print "$new_line\n";

}




