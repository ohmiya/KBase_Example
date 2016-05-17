package Bio::KBase::KmerAnnotationByFigfam::KmerAnnotationByFigfamImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

KmerAnnotationByFigfam

=head1 DESCRIPTION



=cut

#BEGIN_HEADER

use Data::Dumper;
use KmerMgr;
use Bio::KBase::DeploymentConfig;
use SeedAware;

#
# transform the params struct into what the Kmers.pm code is looking for.
#
# Values in param map tuples are params struct key, Kmers.pm key, required-flag, default-value.
#
my @param_map = (['kmer_size', '-kmer', 1],
		 ['return_scores_for_all_proteins', '-all', 0, 0],
		 ['score_threshold', '-scoreThreshold', 0, 2],
		 ['hit_threshold', '-hitThreshold', 0, undef],
		 ['sequential_hit_threshold', '-seqHitThreshold', 0, 2],
		 ['detailed', '-detailed', 0, 0]);

sub process_params
{
    my($svc_params) = @_;

    my $params = {};

    my @required_missing = ();

    for my $ent (@param_map)
    {
	my($svc, $kmer, $required, $default) = @$ent;

	if (exists($svc_params->{$svc}))
	{
	    my $val = $svc_params->{$svc};
	    $params->{$kmer} = $val;
	}
	else
	{
	    if ($required)
	    {
		push(@required_missing, $svc);
	    }
	    elsif (defined($default))
	    {
		$params->{$kmer} = $default;
	    }
	}
    }

    return $params;
}

#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR

    my $cfg = Bio::KBase::DeploymentConfig->new('KmerAnnotationByFigfam',
						{ 'kmer-data' => '/tmp/' });

    my $kmer_data = $cfg->setting('kmer-data');
    if (! -d $kmer_data)
    {
	die "KmerAnnotationByFigfam: Kmer data directory '$kmer_data' does not exist";
    }

    my $mgr = KmerMgr->new(base_dir => $kmer_data);
    $self->{mgr} = $mgr;

    if (my $tmp = $cfg->setting("tempdir"))
    {
	if (-d $tmp)
	{
	    $ENV{TMPDIR} = $ENV{TEMPDIR} = $tmp;
	    print STDERR "Set tmpdir to $tmp\n";
	    print STDERR "SEED thinks tmp=" . SeedAware::location_of_tmp() . "\n";
	}
	else
	{
	    die "Configured tempdir $tmp does not exist";
	}
    }
    
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 get_dataset_names

  $dataset_names = $obj->get_dataset_names()

=over 4

=item Parameter and return types

=begin html

<pre>
$dataset_names is a reference to a list where each element is a string

</pre>

=end html

=begin text

$dataset_names is a reference to a list where each element is a string


=end text



=item Description



=back

=cut

sub get_dataset_names
{
    my $self = shift;

    my $ctx = $Bio::KBase::KmerAnnotationByFigfam::Service::CallContext;
    my($dataset_names);
    #BEGIN get_dataset_names

    $dataset_names = [$self->{mgr}->datasets];
    #END get_dataset_names
    my @_bad_returns;
    (ref($dataset_names) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"dataset_names\" (value was \"$dataset_names\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_dataset_names:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_dataset_names');
    }
    return($dataset_names);
}




=head2 get_default_dataset_name

  $default_dataset_name = $obj->get_default_dataset_name()

=over 4

=item Parameter and return types

=begin html

<pre>
$default_dataset_name is a string

</pre>

=end html

=begin text

$default_dataset_name is a string


=end text



=item Description



=back

=cut

sub get_default_dataset_name
{
    my $self = shift;

    my $ctx = $Bio::KBase::KmerAnnotationByFigfam::Service::CallContext;
    my($default_dataset_name);
    #BEGIN get_default_dataset_name

    $default_dataset_name = $self->{mgr}->default_dataset();
    
    #END get_default_dataset_name
    my @_bad_returns;
    (!ref($default_dataset_name)) or push(@_bad_returns, "Invalid type for return variable \"default_dataset_name\" (value was \"$default_dataset_name\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_default_dataset_name:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_default_dataset_name');
    }
    return($default_dataset_name);
}




=head2 annotate_proteins

  $hits = $obj->annotate_proteins($proteins, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$proteins is a reference to a list where each element is a reference to a list containing 2 items:
	0: (id) a string
	1: (protein) a string
$params is a kmer_annotation_figfam_parameters
$hits is a reference to a list where each element is a hit
kmer_annotation_figfam_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
hit is a reference to a list containing 7 items:
	0: (id) a string
	1: (prot_function) a string
	2: (otu) a string
	3: (score) an int
	4: (nonoverlapping_hits) an int
	5: (overlapping_hits) an int
	6: (details) a reference to a list where each element is a hit_detail
hit_detail is a reference to a list containing 4 items:
	0: (offset) an int
	1: (oligo) a string
	2: (prot_function) a string
	3: (otu) a string

</pre>

=end html

=begin text

$proteins is a reference to a list where each element is a reference to a list containing 2 items:
	0: (id) a string
	1: (protein) a string
$params is a kmer_annotation_figfam_parameters
$hits is a reference to a list where each element is a hit
kmer_annotation_figfam_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
hit is a reference to a list containing 7 items:
	0: (id) a string
	1: (prot_function) a string
	2: (otu) a string
	3: (score) an int
	4: (nonoverlapping_hits) an int
	5: (overlapping_hits) an int
	6: (details) a reference to a list where each element is a hit_detail
hit_detail is a reference to a list containing 4 items:
	0: (offset) an int
	1: (oligo) a string
	2: (prot_function) a string
	3: (otu) a string


=end text



=item Description



=back

=cut

sub annotate_proteins
{
    my $self = shift;
    my($proteins, $params) = @_;

    my @_bad_arguments;
    (ref($proteins) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"proteins\" (value was \"$proteins\")");
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to annotate_proteins:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'annotate_proteins');
    }

    my $ctx = $Bio::KBase::KmerAnnotationByFigfam::Service::CallContext;
    my($hits);
    #BEGIN annotate_proteins

    my $dataset_name = $params->{dataset_name} || $self->{mgr}->default_dataset();
    my $kmers = $self->{mgr}->get_kmer_object($dataset_name);

    ref($kmers) or die "Could not retrieve kmer dataset for name '$dataset_name'";

    my $kmer_fasta = $self->{mgr}->get_extra_fasta_path($dataset_name);

    my $kmer_params = process_params($params);

    #
    # Need to massaage data for the Kmers.pm call.
    #

    $kmer_params->{-seqs} = [map { [$_->[0], undef, $_->[1] ] } @$proteins];

    # print Dumper($params, $proteins, $kmer_params);
    my @hits = $kmers->assign_functions_to_prot_set($kmer_params);
    $hits = \@hits;

    #END annotate_proteins
    my @_bad_returns;
    (ref($hits) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"hits\" (value was \"$hits\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to annotate_proteins:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'annotate_proteins');
    }
    return($hits);
}




=head2 annotate_proteins_fasta

  $hits = $obj->annotate_proteins_fasta($protein_fasta, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$protein_fasta is a string
$params is a kmer_annotation_figfam_parameters
$hits is a reference to a list where each element is a hit
kmer_annotation_figfam_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
hit is a reference to a list containing 7 items:
	0: (id) a string
	1: (prot_function) a string
	2: (otu) a string
	3: (score) an int
	4: (nonoverlapping_hits) an int
	5: (overlapping_hits) an int
	6: (details) a reference to a list where each element is a hit_detail
hit_detail is a reference to a list containing 4 items:
	0: (offset) an int
	1: (oligo) a string
	2: (prot_function) a string
	3: (otu) a string

</pre>

=end html

=begin text

$protein_fasta is a string
$params is a kmer_annotation_figfam_parameters
$hits is a reference to a list where each element is a hit
kmer_annotation_figfam_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
hit is a reference to a list containing 7 items:
	0: (id) a string
	1: (prot_function) a string
	2: (otu) a string
	3: (score) an int
	4: (nonoverlapping_hits) an int
	5: (overlapping_hits) an int
	6: (details) a reference to a list where each element is a hit_detail
hit_detail is a reference to a list containing 4 items:
	0: (offset) an int
	1: (oligo) a string
	2: (prot_function) a string
	3: (otu) a string


=end text



=item Description



=back

=cut

sub annotate_proteins_fasta
{
    my $self = shift;
    my($protein_fasta, $params) = @_;

    my @_bad_arguments;
    (!ref($protein_fasta)) or push(@_bad_arguments, "Invalid type for argument \"protein_fasta\" (value was \"$protein_fasta\")");
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to annotate_proteins_fasta:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'annotate_proteins_fasta');
    }

    my $ctx = $Bio::KBase::KmerAnnotationByFigfam::Service::CallContext;
    my($hits);
    #BEGIN annotate_proteins_fasta
    #END annotate_proteins_fasta
    my @_bad_returns;
    (ref($hits) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"hits\" (value was \"$hits\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to annotate_proteins_fasta:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'annotate_proteins_fasta');
    }
    return($hits);
}




=head2 call_genes_in_dna

  $hits = $obj->call_genes_in_dna($dna, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$dna is a reference to a list where each element is a reference to a list containing 2 items:
	0: (id) a string
	1: (dna) a string
$params is a kmer_annotation_figfam_parameters
$hits is a reference to a list where each element is a dna_hit
kmer_annotation_figfam_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
dna_hit is a reference to a list containing 6 items:
	0: (nhits) an int
	1: (id) a string
	2: (beg) an int
	3: (end) an int
	4: (protein_function) a string
	5: (otu) a string

</pre>

=end html

=begin text

$dna is a reference to a list where each element is a reference to a list containing 2 items:
	0: (id) a string
	1: (dna) a string
$params is a kmer_annotation_figfam_parameters
$hits is a reference to a list where each element is a dna_hit
kmer_annotation_figfam_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
dna_hit is a reference to a list containing 6 items:
	0: (nhits) an int
	1: (id) a string
	2: (beg) an int
	3: (end) an int
	4: (protein_function) a string
	5: (otu) a string


=end text



=item Description



=back

=cut

sub call_genes_in_dna
{
    my $self = shift;
    my($dna, $params) = @_;

    my @_bad_arguments;
    (ref($dna) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"dna\" (value was \"$dna\")");
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to call_genes_in_dna:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'call_genes_in_dna');
    }

    my $ctx = $Bio::KBase::KmerAnnotationByFigfam::Service::CallContext;
    my($hits);
    #BEGIN call_genes_in_dna

    my $dataset_name = $params->{dataset_name} || $self->{mgr}->default_dataset();
    my $kmers = $self->{mgr}->get_kmer_object($dataset_name);

    $params->{min_hits} //= 2;
    $params->{max_gap} //= 600;

    ref($kmers) or die "Could not retrieve kmer dataset for name '$dataset_name'";

    my $kmer_fasta = $self->{mgr}->get_extra_fasta_path($dataset_name);

    # print Dumper($params, $proteins, $kmer_params);
    
    $hits = [];
    for my $ent (@$dna)
    {
	my $ent_hits = $kmers->assign_functions_to_PEGs_in_DNA($params->{kmer_size}, $ent->[1], 
							   $params->{min_hits}, $params->{max_gap}, 0, 0);
	for my $hit (@$ent_hits)
	{
	    my($n, $beg, $end, $func, $otu) = @$hit;
	    next unless abs($beg - $end) >= $params->{min_size};
	    push(@$hits, [$n, $ent->[0], $beg, $end, $func, $otu]);
	}
    }

    #END call_genes_in_dna
    my @_bad_returns;
    (ref($hits) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"hits\" (value was \"$hits\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to call_genes_in_dna:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'call_genes_in_dna');
    }
    return($hits);
}




=head2 estimate_closest_genomes

  $output = $obj->estimate_closest_genomes($proteins, $dataset_name)

=over 4

=item Parameter and return types

=begin html

<pre>
$proteins is a reference to a list where each element is a reference to a list containing 3 items:
	0: (id) a string
	1: (function) a string
	2: (translation) a string
$dataset_name is a string
$output is a reference to a list where each element is a reference to a list containing 3 items:
	0: (genome_id) a string
	1: (score) an int
	2: (genome_name) a string

</pre>

=end html

=begin text

$proteins is a reference to a list where each element is a reference to a list containing 3 items:
	0: (id) a string
	1: (function) a string
	2: (translation) a string
$dataset_name is a string
$output is a reference to a list where each element is a reference to a list containing 3 items:
	0: (genome_id) a string
	1: (score) an int
	2: (genome_name) a string


=end text



=item Description



=back

=cut

sub estimate_closest_genomes
{
    my $self = shift;
    my($proteins, $dataset_name) = @_;

    my @_bad_arguments;
    (ref($proteins) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"proteins\" (value was \"$proteins\")");
    (!ref($dataset_name)) or push(@_bad_arguments, "Invalid type for argument \"dataset_name\" (value was \"$dataset_name\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to estimate_closest_genomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'estimate_closest_genomes');
    }

    my $ctx = $Bio::KBase::KmerAnnotationByFigfam::Service::CallContext;
    my($output);
    #BEGIN estimate_closest_genomes

    if (!$dataset_name)
    {
	$dataset_name = $self->{mgr}->default_dataset();
    }

    my $kmers = $self->{mgr}->get_kmer_object($dataset_name);

    $kmers or die "Could not find kmers for dataset $dataset_name";

    my $output = $kmers->compute_approximate_neighbors($proteins);
  
    #END estimate_closest_genomes
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to estimate_closest_genomes:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'estimate_closest_genomes');
    }
    return($output);
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



=head2 kmer_annotation_figfam_parameters

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
kmer_size has a value which is an int
dataset_name has a value which is a string
return_scores_for_all_proteins has a value which is an int
score_threshold has a value which is an int
hit_threshold has a value which is an int
sequential_hit_threshold has a value which is an int
detailed has a value which is an int
min_hits has a value which is an int
min_size has a value which is an int
max_gap has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
kmer_size has a value which is an int
dataset_name has a value which is a string
return_scores_for_all_proteins has a value which is an int
score_threshold has a value which is an int
hit_threshold has a value which is an int
sequential_hit_threshold has a value which is an int
detailed has a value which is an int
min_hits has a value which is an int
min_size has a value which is an int
max_gap has a value which is an int


=end text

=back



=head2 hit_detail

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 4 items:
0: (offset) an int
1: (oligo) a string
2: (prot_function) a string
3: (otu) a string

</pre>

=end html

=begin text

a reference to a list containing 4 items:
0: (offset) an int
1: (oligo) a string
2: (prot_function) a string
3: (otu) a string


=end text

=back



=head2 hit

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 7 items:
0: (id) a string
1: (prot_function) a string
2: (otu) a string
3: (score) an int
4: (nonoverlapping_hits) an int
5: (overlapping_hits) an int
6: (details) a reference to a list where each element is a hit_detail

</pre>

=end html

=begin text

a reference to a list containing 7 items:
0: (id) a string
1: (prot_function) a string
2: (otu) a string
3: (score) an int
4: (nonoverlapping_hits) an int
5: (overlapping_hits) an int
6: (details) a reference to a list where each element is a hit_detail


=end text

=back



=head2 dna_hit

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 6 items:
0: (nhits) an int
1: (id) a string
2: (beg) an int
3: (end) an int
4: (protein_function) a string
5: (otu) a string

</pre>

=end html

=begin text

a reference to a list containing 6 items:
0: (nhits) an int
1: (id) a string
2: (beg) an int
3: (end) an int
4: (protein_function) a string
5: (otu) a string


=end text

=back



=cut

1;
