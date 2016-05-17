package Bio::KBase::OntologyService::Client;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::OntologyService::Client

=head1 DESCRIPTION


This module provides public interface/APIs for KBase gene ontology (GO) services in a species-independent manner. It encapsulates the basic functionality of extracting domain ontologies (e.g. biological process, molecular function, cellular process)  of interest for a given set of species specific genes. It only accepts KBase gene ids. External gene ids need to be converted to KBase ids. Additionally, it also allows gene ontology enrichment analysis ("hypergeometric") to be performed on a set of genes that identifies statistically overrepresented GO terms within given gene sets, say for example, GO enrichment of over-expressed genes in drought stress in plant roots. To support these key features, currently this modules provides five API-functions that are backed by custom defined data structures. Majority of these API-functions accept a list of input items (majority of them being text strings) such as list of gene-ids, list of go-ids, list of ontology-domains, and Test type ( "hypergeometric") and return the requested results as tabular dataset.


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => Bio::KBase::OntologyService::Client::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




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
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_goidlist (received $n, expecting 3)");
    }
    {
	my($geneIDList, $domainList, $ecList) = @args;

	my @_bad_arguments;
        (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"geneIDList\" (value was \"$geneIDList\")");
        (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"domainList\" (value was \"$domainList\")");
        (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 3 \"ecList\" (value was \"$ecList\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_goidlist:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_goidlist');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "Ontology.get_goidlist",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_goidlist',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_goidlist",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_goidlist',
				       );
    }
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
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_go_description (received $n, expecting 1)");
    }
    {
	my($goIDList) = @args;

	my @_bad_arguments;
        (ref($goIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"goIDList\" (value was \"$goIDList\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_go_description:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_go_description');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "Ontology.get_go_description",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_go_description',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_go_description",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_go_description',
				       );
    }
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
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 5)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_go_enrichment (received $n, expecting 5)");
    }
    {
	my($geneIDList, $domainList, $ecList, $type, $ontologytype) = @args;

	my @_bad_arguments;
        (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"geneIDList\" (value was \"$geneIDList\")");
        (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"domainList\" (value was \"$domainList\")");
        (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 3 \"ecList\" (value was \"$ecList\")");
        (!ref($type)) or push(@_bad_arguments, "Invalid type for argument 4 \"type\" (value was \"$type\")");
        (!ref($ontologytype)) or push(@_bad_arguments, "Invalid type for argument 5 \"ontologytype\" (value was \"$ontologytype\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_go_enrichment:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_go_enrichment');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "Ontology.get_go_enrichment",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_go_enrichment',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_go_enrichment",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_go_enrichment',
				       );
    }
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
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_go_annotation (received $n, expecting 1)");
    }
    {
	my($geneIDList) = @args;

	my @_bad_arguments;
        (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"geneIDList\" (value was \"$geneIDList\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_go_annotation:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_go_annotation');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "Ontology.get_go_annotation",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_go_annotation',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_go_annotation",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_go_annotation',
				       );
    }
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
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 7)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function association_test (received $n, expecting 7)");
    }
    {
	my($gene_list, $ws_name, $in_obj_id, $out_obj_id, $type, $correction_method, $cut_off) = @args;

	my @_bad_arguments;
        (ref($gene_list) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"gene_list\" (value was \"$gene_list\")");
        (!ref($ws_name)) or push(@_bad_arguments, "Invalid type for argument 2 \"ws_name\" (value was \"$ws_name\")");
        (!ref($in_obj_id)) or push(@_bad_arguments, "Invalid type for argument 3 \"in_obj_id\" (value was \"$in_obj_id\")");
        (!ref($out_obj_id)) or push(@_bad_arguments, "Invalid type for argument 4 \"out_obj_id\" (value was \"$out_obj_id\")");
        (!ref($type)) or push(@_bad_arguments, "Invalid type for argument 5 \"type\" (value was \"$type\")");
        (!ref($correction_method)) or push(@_bad_arguments, "Invalid type for argument 6 \"correction_method\" (value was \"$correction_method\")");
        (!ref($cut_off)) or push(@_bad_arguments, "Invalid type for argument 7 \"cut_off\" (value was \"$cut_off\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to association_test:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'association_test');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "Ontology.association_test",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'association_test',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method association_test",
					    status_line => $self->{client}->status_line,
					    method_name => 'association_test',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "Ontology.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'association_test',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method association_test",
            status_line => $self->{client}->status_line,
            method_name => 'association_test',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::KBase::OntologyService::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::OntologyService::Client version is $svr_version. API subject to change.\n";
    }
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

package Bio::KBase::OntologyService::Client::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
