package Bio::KBase::OntologyService::OntologyServiceImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

Ontology

=head1 DESCRIPTION

This module provides public interface/APIs for KBase gene ontology (GO) services in a species-independent manner. It encapsulates the basic functionality of extracting domain ontologies (e.g. biological process, molecular function, cellular process)  of interest for a given set of species specific genes. It only accepts KBase gene ids. External gene ids need to be converted to KBase ids. Additionally, it also allows gene ontology enrichment analysis ("hypergeometric") to be performed on a set of genes that identifies statistically overrepresented GO terms within given gene sets, say for example, GO enrichment of over-expressed genes in drought stress in plant roots. To support these key features, currently this modules provides five API-functions that are backed by custom defined data structures. Majority of these API-functions accept a list of input items (majority of them being text strings) such as list of gene-ids, list of go-ids, list of ontology-domains, and Test type ( "hypergeometric") and return the requested results as tabular dataset.

=cut

#BEGIN_HEADER
use DBI;
use POSIX;
use Text::NSP::Measures::2D::Fisher::twotailed;
use Config::Simple;
use JSON;
use Bio::KBase::OntologyService::OntologySupport;
use Bio::KBase::workspace::Client;
use Bio::KBase::ERDB_Service::Client;
use Bio::KBase::AuthToken;
use Data::Dumper;
#use IDServerAPIClient;
sub compute_tot_num_genes {
    my $self = shift;
    my($gnid) = @_;

    return if(defined $self->{total_genes}->{$gnid});

    # precompute total number of genes
    my $ec = Bio::KBase::ERDB_Service::Client->new($self->{_params}->{erdb_url});
    my $rr = $ec->runSQL("select count(*) from Feature where id like '$gnid.%' and feature_type = 'CDS'", []);
    $self->{total_genes}->{$gnid} = ${$$rr[0]}[0];
}

sub load_ont_anno4genome {
    my $self = shift;
    my($gnid) = @_;

    return if(defined $self->{_cache}->{$gnid});

    # TODO: It will be LRU based caching later or get_subobjects if it is really big
    my $at =Bio::KBase::AuthToken->new(user_id=>$self->{_params}->{ws_un}, password => $self->{_params}->{ws_pw});
    my $wsc = Bio::KBase::workspace::Client->new($self->{_params}->{ws_url}, token => $at->get());
    eval{
      my $rst = $wsc->get_object({workspace => $self->{_params}->{ws_id}, id  => $gnid});
      $self->{_cache}->{$gnid}= $rst->{data}->{ga};

      # precompute goid to gene count per species (ignore ec list for now) 
      my %term2cnt = ();
      my $gene2term = $rst->{data}->{ga};
      foreach my $gene (keys %{$gene2term}) {
          foreach my $term ( keys %{$gene2term->{$gene}}) {
            $term2cnt{$term} = 0 if ! defined $term2cnt{$term};
            $term2cnt{$term}++;
          }
      }
      
      $self->{term_genes}->{$gnid} = \%term2cnt;
     
      compute_tot_num_genes($self, $gnid);
    }
}

sub load_ont {
    my $self = shift;
    my($ctx) = @_;

    # TODO: Add refreshing logic later
    return if(defined $self->{_ont});

    my $at =Bio::KBase::AuthToken->new(user_id=>$self->{_params}->{ws_un}, password => $self->{_params}->{ws_pw});
    my $wsc = Bio::KBase::workspace::Client->new($self->{_params}->{ws_url}, token => $at->get());
    my $rst = $wsc->get_object({workspace => $self->{_params}->{ws_id}, id  => 'ontologies'});

    if(defined $rst->{data}) {
        $self->{_ont} = $rst->{data}->{ontology_acc_term_map};
        return;
    }

    my $kb_top = $ENV{'KB_TOP'};  
    $kb_top = '/kb/deployment' if ! defined $kb_top;
    my $package = $ctx->{module};
    open ONT, "$kb_top/services/$package/ontologies.json" or die "Couldn't open $kb_top/services/$package/ontologies.json";
    my @lines = <ONT>;
    my $file = join " ", @lines;
    $self->{_ont} = from_json($file);

}
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    my %params;
    my @list = qw(ws_url ws_un ws_id ws_type erdb_url ws_pw);
    if ((my $e = $ENV{KB_DEPLOYMENT_CONFIG}) && -e $ENV{KB_DEPLOYMENT_CONFIG}) {  
      my $service = $ENV{KB_SERVICE_NAME};
      if (defined($service)) {
        my %Config = ();
        tie %Config, "Config::Simple", "$e";
        for my $p (@list) {
          my $v = $Config{"$service.$p"};
          if ($v) {
            $params{$p} = $v;
          }
        }
      }
    }
 
    # set default values for testing
    $params{erdb_url} = 'http://kbase.us/services/erdb_service' if! defined $params{erdb_url};
    $params{ws_url} = 'https://kbase.us/services/ws' if! defined $params{ws_url};
    $params{ws_un} = 'kbasetest' if! defined $params{ws_un};
    #$params{ws_pw} = '' if! defined $params{ws_pw};
    $params{ws_id} = 'ont_upload' if! defined $params{ws_id};
    $params{ws_type} = 'KBaseOntology.GeneOntologyAnnotation-1.0' if! defined $params{ws_type};

    $self->{_params}=\%params;
    $self->{_cache}={};
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 get_goidlist

  $results = $obj->get_goidlist($geneIDList, $domainList, $ecList)

=over 4

=item Parameter and return types

=begin html

<pre>
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$results is a GeneIDMap2GoInfo
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
GeneIDMap2GoInfo is a reference to a hash where the key is a GeneID and the value is a GoIDMap2GoTermInfo
GoIDMap2GoTermInfo is a reference to a hash where the key is a GoID and the value is a GoTermInfoList
GoID is a string
GoTermInfoList is a reference to a list where each element is a GoTermInfo
GoTermInfo is a reference to a hash where the following keys are defined:
	domain has a value which is a Domain
	ec has a value which is an EvidenceCode
	desc has a value which is a GoDesc
GoDesc is a string

</pre>

=end html

=begin text

$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$results is a GeneIDMap2GoInfo
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
GeneIDMap2GoInfo is a reference to a hash where the key is a GeneID and the value is a GoIDMap2GoTermInfo
GoIDMap2GoTermInfo is a reference to a hash where the key is a GoID and the value is a GoTermInfoList
GoID is a string
GoTermInfoList is a reference to a list where each element is a GoTermInfo
GoTermInfo is a reference to a hash where the following keys are defined:
	domain has a value which is a Domain
	ec has a value which is an EvidenceCode
	desc has a value which is a GoDesc
GoDesc is a string


=end text



=item Description

This function call accepts three parameters: a list of kbase gene-identifiers, a list of ontology domains, and a list of evidence codes. The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of the last two lists is not empty then the gene-id and go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Finally, this function returns a mapping of kbase gene id to go-ids along with go-description, ontology domain, and evidence code; note that in the returned table of results, each gene-id is associated with a list of one of more go-ids. Also, if no species is provided as input then by default, Arabidopsis thaliana is used as the input species.

=back

=cut

sub get_goidlist
{
    my $self = shift;
    my($geneIDList, $domainList, $ecList) = @_;

    my @_bad_arguments;
    (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"geneIDList\" (value was \"$geneIDList\")");
    (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"domainList\" (value was \"$domainList\")");
    (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ecList\" (value was \"$ecList\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_goidlist:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_goidlist');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN get_goidlist

    my %domainMap = map {$_ => 1} @{$domainList};
    my %ecMap = map {$_ => 1} @{$ecList};

    my %g2idlist = (); # gene to id list
    $results = \%g2idlist;

    my $gncache = $self->{_cache};
    my $n_dl = @$domainList;
    my $n_ec = @$ecList;
    foreach my $geneID (@{$geneIDList}) {
      if($geneID =~ m/^(kb\|g\.\d+)/) {
        my $gnid = $1;
        load_ont_anno4genome($self, $gnid) if ! defined $self->{_cache}->{$gnid};
        next if ! defined $self->{_cache}->{$gnid};

        my $oid2terms = $gncache->{$gnid}->{$geneID};
        foreach my $oid (keys %$oid2terms) {
          my $domain = $oid2terms->{$oid}->{ontology_type};
          next if ($n_dl > 0) && (! defined $domainMap{$domain});
          my $desc = $oid2terms->{$oid}->{ontology_description};
          foreach my $ec (@{$oid2terms->{$oid}->{evidence_codes}}) {
            next if $n_ec > 0 && (! defined $ecMap{$ec});
            $g2idlist{$geneID} = {} if(! defined $g2idlist{$geneID}) ;
            $g2idlist{$geneID}->{$oid} = [] if(! defined $g2idlist{$geneID}->{$oid});
            push $g2idlist{$geneID}->{$oid}, {'domain' => $domain, 'ec' => $ec, 'desc' => $desc};
          }
        }
      }
    } 

    #END get_goidlist
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_goidlist:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_goidlist');
    }
    return($results);
}




=head2 get_go_description

  $results = $obj->get_go_description($goIDList)

=over 4

=item Parameter and return types

=begin html

<pre>
$goIDList is a GoIDList
$results is a reference to a hash where the key is a GoID and the value is a StringArray
GoIDList is a reference to a list where each element is a GoID
GoID is a string
StringArray is a reference to a list where each element is a string

</pre>

=end html

=begin text

$goIDList is a GoIDList
$results is a reference to a hash where the key is a GoID and the value is a StringArray
GoIDList is a reference to a list where each element is a GoID
GoID is a string
StringArray is a reference to a list where each element is a string


=end text



=item Description

Extract GO term description for a given list of GO identifiers. This function expects an input list of GO-ids (white space or comman separated) and returns a table of three columns, first column being the GO ids,  the second column is the GO description and third column is GO domain (biological process, molecular function, cellular component

=back

=cut

sub get_go_description
{
    my $self = shift;
    my($goIDList) = @_;

    my @_bad_arguments;
    (ref($goIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"goIDList\" (value was \"$goIDList\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_go_description:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_go_description');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN get_go_description
    load_ont($self, $ctx);
    my %go2desc = (); # gene to id list
    $results = \%go2desc;
    my $oid2term = $self->{_ont};
    foreach my $goID (@{$goIDList}) {
      $go2desc{$goID} = [$oid2term->{$goID}->{name}, $oid2term->{$goID}->{type}] if defined $oid2term->{$goID};
    } 
    #END get_go_description
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_go_description:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_go_description');
    }
    return($results);
}




=head2 get_go_enrichment

  $results = $obj->get_go_enrichment($geneIDList, $domainList, $ecList, $type, $ontologytype)

=over 4

=item Parameter and return types

=begin html

<pre>
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$type is a TestType
$ontologytype is an ontology_type
$results is an EnrichmentList
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
TestType is a string
ontology_type is a string
EnrichmentList is a reference to a list where each element is an Enrichment
Enrichment is a reference to a hash where the following keys are defined:
	goID has a value which is a GoID
	goDesc has a value which is a GoDesc
	pvalue has a value which is a float
GoID is a string
GoDesc is a string

</pre>

=end html

=begin text

$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$type is a TestType
$ontologytype is an ontology_type
$results is an EnrichmentList
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
TestType is a string
ontology_type is a string
EnrichmentList is a reference to a list where each element is an Enrichment
Enrichment is a reference to a hash where the following keys are defined:
	goID has a value which is a GoID
	goDesc has a value which is a GoDesc
	pvalue has a value which is a float
GoID is a string
GoDesc is a string


=end text



=item Description

For a given list of kbase gene ids from a particular genome (for example "Athaliana" ) find out the significantly enriched GO terms in your gene set. This function accepts four parameters: A list of kbase gene-identifiers, a list of ontology domains (e.g."biological process", "molecular function", "cellular component"), a list of evidence codes (e.g."IEA","IDA","IEP" etc.), and test type (e.g. "hypergeometric"). The list of kbase gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Final filtered list of the kbase gene-id to go-ids mapping is used to calculate GO enrichment using hypergeometric test and provides pvalues.The default pvalue cutoff is used as 0.05.  
The current released version ignores test type and by default, it uses hypergeometric test. So even if you do not provide TestType, it will do hypergeometric test.

=back

=cut

sub get_go_enrichment
{
    my $self = shift;
    my($geneIDList, $domainList, $ecList, $type, $ontologytype) = @_;

    my @_bad_arguments;
    (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"geneIDList\" (value was \"$geneIDList\")");
    (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"domainList\" (value was \"$domainList\")");
    (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ecList\" (value was \"$ecList\")");
    (!ref($type)) or push(@_bad_arguments, "Invalid type for argument \"type\" (value was \"$type\")");
    (!ref($ontologytype)) or push(@_bad_arguments, "Invalid type for argument \"ontologytype\" (value was \"$ontologytype\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_go_enrichment:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_go_enrichment');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN get_go_enrichment
    my $frst = get_goidlist($self, $geneIDList, $domainList, $ecList);
    my %ukey = ();
    my @tem_goID=();
	foreach my $geneID (keys %{$frst}) {
		foreach my $goID (keys %{$frst->{$geneID}}) {
       		if(defined $ukey{$goID}) {
          		$ukey{$goID} = $ukey{$goID} + 1;
       		} else {
          		$ukey{$goID} = 1;
        	}
      		}
    }

    $results = [];

    my $geneSize = $#$geneIDList + 1;
    my @goIDList = keys %ukey;
    my $sname;
    $$geneIDList[0] =~ m/^(kb\|g\.\d+)\./;
    $sname = $1;

    #load_ont_anno4genome($self, $sname); # will be called by get_goidlist

    my $rh_goDescList = get_go_description($self, \@goIDList);
    #my $rh_goID2Count = getGoSize( $sname, \@goIDList, $domainList, $ecList, $ontologytype);
    my $rh_goID2Count = $self->{term_genes}->{$sname};
    compute_tot_num_genes($self, $sname) if ! defined $self->{total_genes}->{$sname}; # should not happen
    if( defined $self->{total_genes}->{$sname} && defined $self->{term_genes}->{$sname}) {
      my $wholeGeneSize = $self->{total_genes}->{$sname};
     
      for(my $i = 0; $i <= $#goIDList; $i= $i+1) {
        my $goDesc = $rh_goDescList->{$goIDList[$i]};
        my $goSize = $rh_goID2Count->{$goIDList[$i]};
     
        # calc p-value using any h.g. test
        my %rst = ();
        $rst{"pvalue"} = calculateStatistic(n11 => $ukey{$goIDList[$i]}, n1p => $geneSize, np1 => $goSize, npp => $wholeGeneSize);
        $rst{"goDesc"} = $goDesc;
        $rst{"goID"} = $goIDList[$i];
        push @$results, \%rst;
      }
    }
    
    #END get_go_enrichment
    my @_bad_returns;
    (ref($results) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_go_enrichment:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_go_enrichment');
    }
    return($results);
}




=head2 get_go_annotation

  $results = $obj->get_go_annotation($geneIDList)

=over 4

=item Parameter and return types

=begin html

<pre>
$geneIDList is a GeneIDList
$results is a GeneAnnotations
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
GeneAnnotations is a reference to a hash where the following keys are defined:
	gene_enrichment_annotations has a value which is a reference to a hash where the key is a gene_id and the value is an ontology_annotation_list
gene_id is a string
ontology_annotation_list is a reference to a list where each element is an OntologyAnnotation
OntologyAnnotation is a reference to a hash where the following keys are defined:
	ontology_id has a value which is a string
	ontology_type has a value which is a string
	ontology_description has a value which is a string
	p_value has a value which is a string

</pre>

=end html

=begin text

$geneIDList is a GeneIDList
$results is a GeneAnnotations
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
GeneAnnotations is a reference to a hash where the following keys are defined:
	gene_enrichment_annotations has a value which is a reference to a hash where the key is a gene_id and the value is an ontology_annotation_list
gene_id is a string
ontology_annotation_list is a reference to a list where each element is an OntologyAnnotation
OntologyAnnotation is a reference to a hash where the following keys are defined:
	ontology_id has a value which is a string
	ontology_type has a value which is a string
	ontology_description has a value which is a string
	p_value has a value which is a string


=end text



=item Description

Returns the precomputed annotation with validation GO terms

=back

=cut

sub get_go_annotation
{
    my $self = shift;
    my($geneIDList) = @_;

    my @_bad_arguments;
    (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"geneIDList\" (value was \"$geneIDList\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_go_annotation:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_go_annotation');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN get_go_annotation
    my $dbh = $self->{_dbh};

    my %gene2anno = (); # gene to id list
    $results = { 'gene_enrichment_annotations' => \%gene2anno};
    if(1 == 0) {
        my $pstmt_exc = $dbh->prepare("select ontology_id, ontology_description, p_value, 'net_neighbor_enrichment' ontology_type from ontology_enrichment_annotation where kbfid = ?");
        my $pstmt;
        foreach my $geneID (@{$geneIDList}) {
 
          $pstmt_exc->bind_param(1, $geneID);
          $pstmt_exc->execute();
          $pstmt = $pstmt_exc;
          while( my $hr = $pstmt->fetchrow_hashref()) {
            $gene2anno{$geneID} = [] if(! defined $gene2anno{$geneID}) ;
            push @{$gene2anno{$geneID}}, $hr;
          } 
        } 
        $pstmt_exc = $dbh->prepare("select ontology_id, ontology_description, 'GO' ontology_type from ontology_enr_anno_val where kbfid = ?");
        foreach my $geneID (@{$geneIDList}) {
 
          $pstmt_exc->bind_param(1, $geneID);
          $pstmt_exc->execute();
          $pstmt = $pstmt_exc;
          while( my $hr = $pstmt->fetchrow_hashref()) {
            $gene2anno{$geneID} = [] if(! defined $gene2anno{$geneID}) ;
            push @{$gene2anno{$geneID}}, $hr;
          } 
        } 
    }
    #END get_go_annotation
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_go_annotation:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_go_annotation');
    }
    return($results);
}




=head2 association_test

  $results = $obj->association_test($gene_list, $ws_name, $in_obj_id, $out_obj_id, $type, $correction_method, $cut_off)

=over 4

=item Parameter and return types

=begin html

<pre>
$gene_list is a GeneIDList
$ws_name is a string
$in_obj_id is a string
$out_obj_id is a string
$type is a TestType
$correction_method is a string
$cut_off is a float
$results is a reference to a hash where the key is a string and the value is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
TestType is a string

</pre>

=end html

=begin text

$gene_list is a GeneIDList
$ws_name is a string
$in_obj_id is a string
$out_obj_id is a string
$type is a TestType
$correction_method is a string
$cut_off is a float
$results is a reference to a hash where the key is a string and the value is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
TestType is a string


=end text



=item Description

Association Test
gene_list is tested against each cluster in a network typed object with test method (TestType) and p-value correction method (correction_method).
The current correction_method is either "none" or "bonferroni" and the default is "none" if it is not specified.
The current test type, by default, uses hypergeometric test. Even if you do not provide TestType, it will do hypergeometric test.

=back

=cut

sub association_test
{
    my $self = shift;
    my($gene_list, $ws_name, $in_obj_id, $out_obj_id, $type, $correction_method, $cut_off) = @_;

    my @_bad_arguments;
    (ref($gene_list) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"gene_list\" (value was \"$gene_list\")");
    (!ref($ws_name)) or push(@_bad_arguments, "Invalid type for argument \"ws_name\" (value was \"$ws_name\")");
    (!ref($in_obj_id)) or push(@_bad_arguments, "Invalid type for argument \"in_obj_id\" (value was \"$in_obj_id\")");
    (!ref($out_obj_id)) or push(@_bad_arguments, "Invalid type for argument \"out_obj_id\" (value was \"$out_obj_id\")");
    (!ref($type)) or push(@_bad_arguments, "Invalid type for argument \"type\" (value was \"$type\")");
    (!ref($correction_method)) or push(@_bad_arguments, "Invalid type for argument \"correction_method\" (value was \"$correction_method\")");
    (!ref($cut_off)) or push(@_bad_arguments, "Invalid type for argument \"cut_off\" (value was \"$cut_off\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to association_test:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'association_test');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN association_test
    $results = {};

    $cut_off = 1.0 if ! defined $cut_off;
    my $geneSize = @$gene_list;
    $$gene_list[0] =~ m/^(kb\|g\.\d+)/;
    my $gnid = $1;
    compute_tot_num_genes($self, $gnid);
    my $tot_genes = $self->{total_genes}->{$gnid};


    my $wsc = Bio::KBase::workspace::Client->new($self->{_params}->{ws_url}, token => $ctx->{'token'});
    #$@ = undef;
    my %nid2eid = ();
    my %cid2genes = ();
    my %cid2pv =();
    my %ecid2pv = ();
    #eval{
      my $obj = $wsc->get_object({workspace => $ws_name, id  => $in_obj_id});
      my $net = $obj->{data};
      
      foreach my $node (@{$net->{nodes}}) {
        $nid2eid{$node->{id}} = $node->{entity_id};
        $cid2genes{$node->{id}} = {} if($node->{entity_id} =~ m/cluster/ || $node->{entity_id} =~ m/clst/ || $node->{entity_id} =~ m/[|.]ps\.\d+\./);
      }
      foreach my $edge (@{$net->{edges}}) {
        if(defined $cid2genes{$edge->{node_id1}} && ! defined $cid2genes{$edge->{node_id2}}) {
          $cid2genes{$edge->{node_id1}}->{$nid2eid{$edge->{node_id2}}} = 1;
        } elsif(! defined $cid2genes{$edge->{node_id1}} && defined $cid2genes{$edge->{node_id2}}) {
          $cid2genes{$edge->{node_id2}}->{$nid2eid{$edge->{node_id1}}} = 1;
        }
      }
      my %cid2cnt=();
      foreach my $cid (keys %cid2genes) {
        my $cnt  = 0;
        foreach my $gid (@$gene_list) {
          $cnt++ if defined $cid2genes{$cid}->{$gid};
        }
        #next if $cnt == 0;
        $cid2pv{$cid} = calculateStatistic(n11 => $cnt, n1p => $geneSize, np1 => scalar keys %{$cid2genes{$cid}}, npp => $tot_genes);
        #print STDERR "$cid2pv{$cid} = calculateStatistic(n11 => $cnt, n1p => $geneSize, np1 => ".(scalar keys %{$cid2genes{$cid}}).", npp => $tot_genes)\n";
      }
      my $pvm = keys %cid2pv;
      foreach my $node (@{$net->{nodes}}) {
        if(defined $cid2pv{$node->{id}}) {
          if($correction_method eq "bonferroni") {
            $node->{user_annotations}->{"cae.p_value"} = "".$cid2pv{$node->{id}} * $pvm if $cid2pv{$node->{id}} * $pvm <= $cut_off;

            $ecid2pv{$node->{entity_id}} = $cid2pv{$node->{id}} * $pvm if $cid2pv{$node->{id}} * $pvm <= $cut_off;
          } else { # none
            $node->{user_annotations}->{"cae.p_value"} = "".$cid2pv{$node->{id}} if $cid2pv{$node->{id}} <= $cut_off;
            $ecid2pv{$node->{entity_id}} = $cid2pv{$node->{id}} if $cid2pv{$node->{id}} <= $cut_off;
          }
        }
      }
      my $gls = join(',', @{$gene_list});
      $wsc->save_objects({workspace => $ws_name, objects => [{type=>'KBaseNetworks.Network-1.0', name=>$out_obj_id, data=>$net, meta=>{source=>"$ws_name:$in_obj_id:$type:$correction_method:$gls:OntologyService.association_test"}}]}) if $out_obj_id ne "";
      $results = \%ecid2pv;
    #};
    
    
    #END association_test
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to association_test:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'association_test');
    }
    return($results);
}




=head2 version 

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}

=head1 TYPES



=head2 Species

=over 4



=item Description

Plant Species names.
    
     The current list of plant species includes: 
     Alyrata: Arabidopsis lyrata
     Athaliana: Arabidopsis thaliana
     Bdistachyon: Brachypodium distachyon
     Creinhardtii: Chlamydomonas reinhardtii
     Gmax: Glycine max
     Oglaberrima: Oryza glaberrima
     Oindica: Oryza sativa indica
     Osativa: Oryza sativa japonica
     Ptrichocarpa: Populus trichocarpa 
     Sbicolor: Sorghum bicolor 
     Smoellendorffii:  Selaginella moellendorffii
     Vvinifera: Vitis vinefera 
     Zmays: Zea mays


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GoID

=over 4



=item Description

GoID : Unique GO term id (Source: external Gene Ontology database - http://www.geneontology.org/)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ontology_id

=over 4



=item Description

GoID : Unique GO term id (Source: external Gene Ontology database - http://www.geneontology.org/)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GoDesc

=over 4



=item Description

GoDesc : Human readable text description of the corresponding GO term


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ontology_description

=over 4



=item Description

GoDesc : Human readable text description of the corresponding GO term


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GeneID

=over 4



=item Description

Unique identifier of a species specific Gene (aka Feature entity in KBase parlence). This ID is an external identifier that exists in the public databases such as Gramene, Ensembl, NCBI etc.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 gene_id

=over 4



=item Description

Unique identifier of a species specific Gene (aka Feature entity in KBase parlence). This ID is an external identifier that exists in the public databases such as Gramene, Ensembl, NCBI etc.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 EvidenceCode

=over 4



=item Description

Evidence code indicates how the annotation to a particular term is supported. 
The list of evidence codes includes Experimental, Computational Analysis, Author statement, Curator statement, Automatically assigned and Obsolete evidence codes. This list will be useful in selecting the correct evidence code for an annotation. The details are given below: 

+  Experimental Evidence Codes
EXP: Inferred from Experiment
IDA: Inferred from Direct Assay
IPI: Inferred from Physical Interaction
IMP: Inferred from Mutant Phenotype
IGI: Inferred from Genetic Interaction
IEP: Inferred from Expression Pattern
    
+ Computational Analysis Evidence Codes
ISS: Inferred from Sequence or Structural Similarity
ISO: Inferred from Sequence Orthology
ISA: Inferred from Sequence Alignment
ISM: Inferred from Sequence Model
IGC: Inferred from Genomic Context
IBA: Inferred from Biological aspect of Ancestor
IBD: Inferred from Biological aspect of Descendant
IKR: Inferred from Key Residues
IRD: Inferred from Rapid Divergence
RCA: inferred from Reviewed Computational Analysis
    
+ Author Statement Evidence Codes
TAS: Traceable Author Statement
NAS: Non-traceable Author Statement
    
+ Curator Statement Evidence Codes
IC: Inferred by Curator
ND: No biological Data available
    
+ Automatically-assigned Evidence Codes
IEA: Inferred from Electronic Annotation
    
+ Obsolete Evidence Codes
NR: Not Recorded


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 evidence_code

=over 4



=item Description

Evidence code indicates how the annotation to a particular term is supported. 
The list of evidence codes includes Experimental, Computational Analysis, Author statement, Curator statement, Automatically assigned and Obsolete evidence codes. This list will be useful in selecting the correct evidence code for an annotation. The details are given below: 

+  Experimental Evidence Codes
EXP: Inferred from Experiment
IDA: Inferred from Direct Assay
IPI: Inferred from Physical Interaction
IMP: Inferred from Mutant Phenotype
IGI: Inferred from Genetic Interaction
IEP: Inferred from Expression Pattern
    
+ Computational Analysis Evidence Codes
ISS: Inferred from Sequence or Structural Similarity
ISO: Inferred from Sequence Orthology
ISA: Inferred from Sequence Alignment
ISM: Inferred from Sequence Model
IGC: Inferred from Genomic Context
IBA: Inferred from Biological aspect of Ancestor
IBD: Inferred from Biological aspect of Descendant
IKR: Inferred from Key Residues
IRD: Inferred from Rapid Divergence
RCA: inferred from Reviewed Computational Analysis
    
+ Author Statement Evidence Codes
TAS: Traceable Author Statement
NAS: Non-traceable Author Statement
    
+ Curator Statement Evidence Codes
IC: Inferred by Curator
ND: No biological Data available
    
+ Automatically-assigned Evidence Codes
IEA: Inferred from Electronic Annotation
    
+ Obsolete Evidence Codes
NR: Not Recorded


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Domain

=over 4



=item Description

Captures which branch of knowledge the GO terms refers to e.g. "biological_process", "molecular_function", "cellular_component" etc.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 domain

=over 4



=item Description

Captures which branch of knowledge the GO terms refers to e.g. "biological_process", "molecular_function", "cellular_component" etc.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 TestType

=over 4



=item Description

Test type, whether it's "hypergeometric" and "chisq"


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 test_type

=over 4



=item Description

Test type, whether it's "hypergeometric" and "chisq"


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GoIDList

=over 4



=item Description

A list of ontology identifiers


=item Definition

=begin html

<pre>
a reference to a list where each element is a GoID
</pre>

=end html

=begin text

a reference to a list where each element is a GoID

=end text

=back



=head2 ontology_id_list

=over 4



=item Description

A list of ontology identifiers


=item Definition

=begin html

<pre>
a reference to a list where each element is an ontology_id
</pre>

=end html

=begin text

a reference to a list where each element is an ontology_id

=end text

=back



=head2 GoDescList

=over 4



=item Description

a list of GO terms description


=item Definition

=begin html

<pre>
a reference to a list where each element is a GoDesc
</pre>

=end html

=begin text

a reference to a list where each element is a GoDesc

=end text

=back



=head2 ontology_description_list

=over 4



=item Description

a list of GO terms description


=item Definition

=begin html

<pre>
a reference to a list where each element is an ontology_description
</pre>

=end html

=begin text

a reference to a list where each element is an ontology_description

=end text

=back



=head2 GeneIDList

=over 4



=item Description

A list of gene identifiers from same species


=item Definition

=begin html

<pre>
a reference to a list where each element is a GeneID
</pre>

=end html

=begin text

a reference to a list where each element is a GeneID

=end text

=back



=head2 gene_id_list

=over 4



=item Description

A list of gene identifiers from same species


=item Definition

=begin html

<pre>
a reference to a list where each element is a gene_id
</pre>

=end html

=begin text

a reference to a list where each element is a gene_id

=end text

=back



=head2 DomainList

=over 4



=item Description

A list of ontology domains


=item Definition

=begin html

<pre>
a reference to a list where each element is a Domain
</pre>

=end html

=begin text

a reference to a list where each element is a Domain

=end text

=back



=head2 domain_list

=over 4



=item Description

A list of ontology domains


=item Definition

=begin html

<pre>
a reference to a list where each element is a domain
</pre>

=end html

=begin text

a reference to a list where each element is a domain

=end text

=back



=head2 StringArray

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 string_list

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 EvidenceCodeList

=over 4



=item Description

A list of ontology term evidence codes. One ontology term can have one or more evidence codes.


=item Definition

=begin html

<pre>
a reference to a list where each element is an EvidenceCode
</pre>

=end html

=begin text

a reference to a list where each element is an EvidenceCode

=end text

=back



=head2 ontology_type

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GoTermInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
domain has a value which is a Domain
ec has a value which is an EvidenceCode
desc has a value which is a GoDesc

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
domain has a value which is a Domain
ec has a value which is an EvidenceCode
desc has a value which is a GoDesc


=end text

=back



=head2 GoTermInfoList

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a GoTermInfo
</pre>

=end html

=begin text

a reference to a list where each element is a GoTermInfo

=end text

=back



=head2 GoIDMap2GoTermInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is a GoID and the value is a GoTermInfoList
</pre>

=end html

=begin text

a reference to a hash where the key is a GoID and the value is a GoTermInfoList

=end text

=back



=head2 GeneIDMap2GoInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is a GeneID and the value is a GoIDMap2GoTermInfo
</pre>

=end html

=begin text

a reference to a hash where the key is a GeneID and the value is a GoIDMap2GoTermInfo

=end text

=back



=head2 Enrichment

=over 4



=item Description

A composite data structure to capture ontology enrichment type object


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
goID has a value which is a GoID
goDesc has a value which is a GoDesc
pvalue has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
goID has a value which is a GoID
goDesc has a value which is a GoDesc
pvalue has a value which is a float


=end text

=back



=head2 EnrichmentList

=over 4



=item Description

A list of ontology enrichment objects


=item Definition

=begin html

<pre>
a reference to a list where each element is an Enrichment
</pre>

=end html

=begin text

a reference to a list where each element is an Enrichment

=end text

=back



=head2 OntologyAnnotation

=over 4



=item Description

Structure for OntologyAnnotation object 
@optional p_value


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ontology_id has a value which is a string
ontology_type has a value which is a string
ontology_description has a value which is a string
p_value has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ontology_id has a value which is a string
ontology_type has a value which is a string
ontology_description has a value which is a string
p_value has a value which is a string


=end text

=back



=head2 ontology_annotation_list

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is an OntologyAnnotation
</pre>

=end html

=begin text

a reference to a list where each element is an OntologyAnnotation

=end text

=back



=head2 GeneAnnotations

=over 4



=item Description

Structure for GeneAnnotations


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
gene_enrichment_annotations has a value which is a reference to a hash where the key is a gene_id and the value is an ontology_annotation_list

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
gene_enrichment_annotations has a value which is a reference to a hash where the key is a gene_id and the value is an ontology_annotation_list


=end text

=back



=cut

1;
