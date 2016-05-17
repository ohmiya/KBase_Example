package ExpressionServicesImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

ExpressionServices

=head1 DESCRIPTION

Service for all different sorts of Expression data (microarray, RNA_seq, proteomics, qPCR

=cut

#BEGIN_HEADER
use DBI;
use Storable qw(dclone);
use Config::Simple;
use Data::Dumper; 
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
use IO::File; 
use LWP::Simple; 
use Bio::DB::Taxonomy;
use Bio::KBase;
use Bio::KBase::CDMI::CDMIClient; 
use Bio::KBase::ExpressionServices::FunctionsForGEO;

sub trim($)
{
    #removes beginning and trailing white space
    my $string = shift;
    if (defined($string))
    {
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
    }
    return $string;
}
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
#foreach my $key (keys %ENV) { 
#print "$key = $ENV{$key}\n"; 
#} 
    #Copied from M. Sneddon's TreeImpl.pm from trees.git f63b672dc14f4600329424bc6b404b507e9c2503   
    my($deploy) = @args; 
#print "\nARGS : ".join("___",@args). "\n";
    if (! $deploy) { 
#print "\nIN DEPLOY IF \n";
        # if not, then go to the config file defined by the deployment and import                                                      
        # the deployment settings   
	my %params; 
#print "DEPLOYMENT_CONFIG ". $ENV{KB_DEPLOYMENT_CONFIG} . "\n";
        if (my $e = $ENV{KB_DEPLOYMENT_CONFIG}) { 
#print "IN CONFIG IF\n"; 
#print "CONFIG FILE $e \n\n";
            my $EXPRESSION_SERVICE_NAME = $ENV{KB_SERVICE_NAME}; 
            my $c = Config::Simple->new(); 
            $c->read($e); 
#print "CONFIG FILE C: $c \n\n";
	    my %temp_hash = $c->vars();
#foreach my $c_key (keys(%temp_hash))
#{
#print "CKEY: $c_key : Val $temp_hash{$c_key} \n";
#}
            my @param_list = qw(dbName dbUser dbhost); 
#print "PAram list : ".join(":",@param_list)."\n";
            for my $p (@param_list) 
            { 
#print "$EXPRESSION_SERVICE_NAME.$p \n\n";
                my $v = $c->param("$EXPRESSION_SERVICE_NAME.$p"); 
#print "IN LOOP P: $p v $v \n";
                if ($v) 
                { 
#print "IN V IF\n"; 
                    $params{$p} = $v; 
                    $self->{$p} = $v; 
                } 
            } 
        } 
        else 
        { 
            $self->{dbName} = 'expression'; 
            $self->{dbUser} = 'expressionselect'; 
            $self->{dbhost} = 'db1.chicago.kbase.us'; 
#print "IN CONFIG ELSE\n"; 
        } 
        #Create a connection to the EXPRESSION (and print a logging debug mssg)              
	if( 0 < scalar keys(%params) ) { 
            warn "Connection to Expression Service established with the following non-default parameters:\n"; 
            foreach my $key (sort keys %params) { warn "   $key => $params{$key} \n"; } 
        } else { warn "Connection to Expression established with all default parameters.\n"; } 
#print "IN IF\n"; 
    } 
    else 
    { 
#        $self->{dbName} = 'CS_expression'; 
#        $self->{dbUser} = 'expressionSelect'; 
#        $self->{dbhost} = 'localhost'; 
         $self->{dbName} = 'expression'; 
         $self->{dbUser} = 'expressionselect';
         $self->{dbhost} = 'db1.chicago.kbase.us'; 
#print "IN ELSE\n"; 
    } 
#print "\nDBNAME : ".  $self->{dbName}; 
#print "\nDBUSER : ".  $self->{dbUser}; 
#print "\nDBHOST : ".  $self->{dbhost} . "\n"; 
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 get_expression_samples_data

  $expression_data_samples_map = $obj->get_expression_samples_data($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is an ExpressionServices.sample_ids
$expression_data_samples_map is an ExpressionServices.expression_data_samples_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$sample_ids is an ExpressionServices.sample_ids
$expression_data_samples_map is an ExpressionServices.expression_data_samples_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float


=end text



=item Description

core function used by many others.  Given a list of KBase SampleIds returns mapping of SampleId to expressionSampleDataStructure (essentially the core Expression Sample Object) : 
{sample_id -> expressionSampleDataStructure}

=back

=cut

sub get_expression_samples_data
{
    my $self = shift;
    my($sample_ids) = @_;

    my @_bad_arguments;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($expression_data_samples_map);
    #BEGIN get_expression_samples_data
    $expression_data_samples_map = {};
    if (0 == @{$sample_ids}) 
    { 
        my $msg = "get_expression_samples_data requires a list of valid sample ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_samples_data'); 
    } 
#    if (0 == @{$sampleIDs})
#    {
#	return $expressionDataSamplesMap;
#    }

#    my $dbh = DBI->connect('DBI:mysql:CS_expression:localhost', 'expressionSelect', '', 
#                           { RaiseError => 1, ShowErrorStatement => 1 } 
#        ); 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
			   { RaiseError => 1, ShowErrorStatement => 1 } 
    ); 
    my $get_sample_meta_data_q = qq^select sam.id, sam.source_id, sam.title as sample_title, sam.description as sample_description,  
                                    sam.molecule, sam.type, sam.dataSource, sam.externalSourceId, 
                                    FROM_UNIXTIME(sam.kbaseSubmissionDate), FROM_UNIXTIME(sam.externalSourceDate),  
                                    sam.custom, sam.originalLog2Median, 
                                    str.id, str.referenceStrain, str.wildtype, str.description,  
                                    gen.id, gen.scientific_name, 
                                    plt.id, plt.title as platform_title, plt.technology, eu.id,  
                                    em.id, em.title as experiment_title, em.description as experiment_description, 
                                    env.id, env.description as env_description, 
                                    pro.id, pro.description, pro.name 
                                    from Sample sam  
                                    inner join StrainWithSample sws on sam.id = sws.to_link 
                                    inner join Strain str on sws.from_link = str.id 
                                    inner join GenomeParentOf gpo on str.id = gpo.to_link 
                                    inner join kbase_sapling_v1.Genome gen on gpo.from_link = gen.id 
                                    left outer join PlatformWithSamples pws on sam.id = pws.to_link 
                                    left outer join Platform plt on pws.from_link = plt.id 
                                    left outer join HasExpressionSample hes on sam.id = hes.to_link 
                                    left outer join ExperimentalUnit eu on hes.from_link = eu.id 
                                    left outer join HasExperimentalUnit heu on eu.id = heu.to_link 
                                    left outer join ExperimentMeta em on heu.from_link = em.id 
                                    left outer join IsContextOf ico on eu.id = ico.to_link 
                                    left outer join Environment env on ico.from_link = env.id 
                                    left outer join ProtocolForSample pfs on sam.id = pfs.to_link 
                                    left outer join Protocol pro on pfs.from_link = pro.id 
                                    where sam.id in ( ^. 
				 join(",", ("?") x @{$sample_ids}) . ") "; 
    my $get_sample_meta_data_qh = $dbh->prepare($get_sample_meta_data_q) or die "Unable to prepare : get_sample_meta_data_q : ".
	                          $get_sample_meta_data_q . " : " .$dbh->errstr();
    $get_sample_meta_data_qh->execute(@{$sample_ids}) or die "Unable to execute : get_sample_meta_data_q : ".$get_sample_meta_data_qh->errstr();
    while(my ($sample_id, $sample_source_id, $sample_title, $sample_description, $sample_molecule, $sample_type, 
              $sample_dataSource, $sample_externalSourceId, $sample_kbaseSubmissionDate, $sample_externalSourceDate,
              $sample_custom, $sample_originalLog2Median, $strain_id, $referenceStrain, $wildtype, $strain_description, 
	      $genome_id, $scientific_name, $platform_id, $platform_title, $platform_technology, $experimental_unit_id, 
              $experiment_meta_id, $experiment_meta_title, $experiment_meta_description, $environment_id, $environment_description,
              $protocol_id, $protocol_description, $protocol_name) = $get_sample_meta_data_qh->fetchrow_array())
    {
	$expression_data_samples_map->{$sample_id}={"sampleID" => $sample_id,
						 "sourceID" => $sample_source_id,
						 "sampleTitle" => $sample_title,
						 "sampleDescription" => $sample_description,
						 "molecule" => $sample_molecule,
						 "sampleType" => $sample_type,
						 "dataSource" => $sample_dataSource,
						 "externalSourceID" => $sample_externalSourceId,
						 "externalSourceDate" => $sample_externalSourceDate,
						 "kbaseSubmissionDate" => $sample_kbaseSubmissionDate,
						 "custom" => $sample_custom,
						 "originalLog2Median" => $sample_originalLog2Median,
						 "strainID" => $strain_id,
						 "referenceStrain" => $referenceStrain,
						 "wildtype" => $wildtype,
						 "strainDescription" => $strain_description,
						 "genomeID" => $genome_id,
						 "genomeScientificName" => $scientific_name,
						 "platformID" => $platform_id,
						 "platformTitle" => $platform_title,
						 "platformTechnology" => $platform_technology,
						 "experimentalUnitID" => $experimental_unit_id,
						 "experimentMetaID" => $experiment_meta_id,
						 "experimentTitle" => $experiment_meta_title,
						 "experimentDescription" => $experiment_meta_description,
						 "environmentID" => $environment_id,
						 "environmentDescription" => $environment_description,
						 "protocolID" => $protocol_id,
						 "protocolDescription" => $protocol_description,
						 "protocolName" => $protocol_name,
						 "sampleAnnotationIDs" => [],
						 "seriesIDs" => [],
						 "sampleIDsAveragedFrom" => [],
						 "personIDs" => [],
						 "dataExpressionLevelsForSample" => {}};
    }

    #Sample Annotations
    my $get_sample_annotations_q = qq^select sam.id, san.id, ont.id, ont.name, ont.definition  
                                      from Sample sam  
                                      inner join SampleHasAnnotations sha on sam.id = sha.from_link 
                                      inner join SampleAnnotation san on sha.to_link = san.id 
                                      inner join OntologyForSample ofs on ofs.to_link = san.id 
                                      inner join Ontology ont on ont.id = ofs.from_link 
                                      where sam.id in (^.
                                  join(",", ("?") x @{$sample_ids}) . ") "; 
    my $get_sample_annotations_qh = $dbh->prepare($get_sample_annotations_q) or die "Unable to prepare get_sample_annotations_q : ".
	$get_sample_annotations_q . " : " . $dbh->errstr();
    $get_sample_annotations_qh->execute(@{$sample_ids}) or die "Unable to execute get_sample_annotations_q : ".$get_sample_annotations_q.
                                    " : " .$get_sample_annotations_qh->errstr();
    while (my ($sample_id,$sample_annotation_id, $ontology_id, $ontology_name, $ontology_definition) 
	   = $get_sample_annotations_qh->fetchrow_array()) 
    { 
	my %temp_hash;
	$temp_hash{"sampleAnnotationID"} = $sample_annotation_id;
	$temp_hash{"ontologyID"} = $ontology_id;
	$temp_hash{"ontologyName"} = $ontology_name;
	if (($ontology_definition eq '' )||(defined($ontology_definition)))
	{
	    $temp_hash{"ontologyDefinition"} = $ontology_definition;
	}
        push(@{$expression_data_samples_map->{$sample_id}->{"sampleAnnotationIDs"}},\%temp_hash);
    }        

    #SeriesIds
    my $get_sample_series_ids_q = qq^select sam.id, ser.id
                                     from Sample sam
                                     inner join SampleInSeries sis on sam.id = sis.from_link
                                     inner join Series ser on sis.to_link = ser.id
                                     where sam.id in (^.
                                  join(",", ("?") x @{$sample_ids}) . ") "; 
    my $get_sample_series_ids_qh = $dbh->prepare($get_sample_series_ids_q) or die "Unable to prepare : get_sample_series_ids_q : ".
	$get_sample_series_ids_q . " : " .$dbh->errstr();
    $get_sample_series_ids_qh->execute(@{$sample_ids}) or die "Unable to execute : get_sample_series_ids_q : ".$get_sample_series_ids_qh->errstr();
    while (my ($sample_id,$series_id) = $get_sample_series_ids_qh->fetchrow_array())
    {
          push(@{$expression_data_samples_map->{$sample_id}->{"seriesIDs"}},$series_id);
    }

    #SampleIDsAveragedFrom
    my $get_sample_ids_averaged_from_q = qq^select saf.from_link, saf.to_link
                                            from SampleAveragedFrom saf
                                            where saf.to_link in (^. 
                                         join(",", ("?") x @{$sample_ids}) . ") "; 
    my $get_sample_ids_averaged_from_qh = $dbh->prepare($get_sample_ids_averaged_from_q) or die "Unable to prepare : get_sample_ids_averaged_from_q : ". 
        $get_sample_ids_averaged_from_q . " : " .$dbh->errstr(); 
    $get_sample_ids_averaged_from_qh->execute(@{$sample_ids}) or die "Unable to execute : get_sample_ids_averaged_from_q : ".$get_sample_ids_averaged_from_qh->errstr(); 
    while (my ($averaged_from_sample_id, $averaged_to_sample_id) = $get_sample_ids_averaged_from_qh->fetchrow_array()) 
    { 
          push(@{$expression_data_samples_map->{$averaged_to_sample_id}->{"sampleIDsAveragedFrom"}},$averaged_from_sample_id); 
    } 
    
    #PersonIds     
    my $get_sample_person_ids_q = qq^select sam.id, per.id 
                                     from Sample sam 
                                     inner join SampleContactPerson scp on sam.id = scp.from_link 
                                     inner join Person per on scp.to_link = per.id 
                                     where sam.id in (^.
                                  join(",", ("?") x @{$sample_ids}) . ") ";
    my $get_sample_person_ids_qh = $dbh->prepare($get_sample_person_ids_q) or die "Unable to prepare : get_sample_person_ids_q : ".           
                                   $get_sample_person_ids_q . " : " .$dbh->errstr();        
    $get_sample_person_ids_qh->execute(@{$sample_ids}) or die "Unable to execute : get_sample_person_ids_q : ".$get_sample_person_ids_qh->errstr();  
    while (my ($sample_id,$person_id) = $get_sample_person_ids_qh->fetchrow_array())
    {
        push(@{$expression_data_samples_map->{$sample_id}->{"personIDs"}},$person_id);
    }

    #log2Levels
    my $get_log2levels_q = qq^select sam.id, fea.id, mea.value
                              from Sample sam
                              inner join SampleMeasurements sme on sam.id = sme.from_link
                              inner join Measurement mea on sme.to_link = mea.id
                              inner join FeatureMeasuredBy fmb on mea.id = fmb.to_link
                              inner join kbase_sapling_v1.Feature fea on fmb.from_link = fea.id
                              where sam.id in (^. 
                           join(",", ("?") x @{$sample_ids}) . ") ";  
    my $get_log2levels_qh = $dbh->prepare($get_log2levels_q) or die "Unable to prepare get_log2levels_q : ".
                            $get_log2levels_q . " : " . $dbh->errstr();
    $get_log2levels_qh->execute(@{$sample_ids}) or die "Unable to execute get_log2levels_q : " . $get_log2levels_q . " : ".
                            $get_log2levels_qh->errstr();
    while(my ($sample_id, $feature_id, $log2level) = $get_log2levels_qh->fetchrow_array())
    {
        $expression_data_samples_map->{$sample_id}->{"dataExpressionLevelsForSample"}->{$feature_id} = $log2level;
    }
    #END get_expression_samples_data
    my @_bad_returns;
    (ref($expression_data_samples_map) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"expression_data_samples_map\" (value was \"$expression_data_samples_map\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data');
    }
    return($expression_data_samples_map);
}




=head2 get_expression_data_by_samples_and_features

  $label_data_mapping = $obj->get_expression_data_by_samples_and_features($sample_ids, $feature_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is an ExpressionServices.sample_ids
$feature_ids is an ExpressionServices.feature_ids
$label_data_mapping is an ExpressionServices.label_data_mapping
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
feature_ids is a reference to a list where each element is an ExpressionServices.feature_id
feature_id is a string
label_data_mapping is a reference to a hash where the key is a string and the value is an ExpressionServices.data_expression_levels_for_sample
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
measurement is a float

</pre>

=end html

=begin text

$sample_ids is an ExpressionServices.sample_ids
$feature_ids is an ExpressionServices.feature_ids
$label_data_mapping is an ExpressionServices.label_data_mapping
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
feature_ids is a reference to a list where each element is an ExpressionServices.feature_id
feature_id is a string
label_data_mapping is a reference to a hash where the key is a string and the value is an ExpressionServices.data_expression_levels_for_sample
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
measurement is a float


=end text



=item Description

given a list of sample ids and feature ids it returns a LabelDataMapping {sampleID}->{featureId => value}}.  
If feature list is an empty array [], all features with measurment values will be returned.

=back

=cut

sub get_expression_data_by_samples_and_features
{
    my $self = shift;
    my($sample_ids, $feature_ids) = @_;

    my @_bad_arguments;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sample_ids\" (value was \"$sample_ids\")");
    (ref($feature_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"feature_ids\" (value was \"$feature_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_data_by_samples_and_features:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_data_by_samples_and_features');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($label_data_mapping);
    #BEGIN get_expression_data_by_samples_and_features
    $label_data_mapping = {};
    if (0 == @{$sample_ids}) 
    { 
	my $msg = "get_expression_data_by_samples_and_features requires a list of valid sample ids.  Note that feature ids can be empty.  ".
	    "If features are empty all features for the sample will be returned";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
							       method_name => 'get_expression_data_by_samples_and_features'); 
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
	); 

    my $get_feature_log2level_q = qq^select sam.id, fea.id, mea.value   
                                     from Sample sam           
                                     inner join SampleMeasurements sms on sam.id = sms.from_link      
                                     inner join Measurement mea on sms.to_link = mea.id       
                                     inner join FeatureMeasuredBy fmb on mea.id = fmb.to_link      
                                     inner join kbase_sapling_v1.Feature fea on fmb.from_link = fea.id       
                                     where sam.id in (^.
				     join(",", ("?") x @{$sample_ids}). ") ";
    if (scalar(@{$feature_ids}) > 0)
    {
	$get_feature_log2level_q .= qq^ and fea.id in (^. join(",", ("?") x @{$feature_ids}). ") ";
    }

    my $get_feature_log2level_qh = $dbh->prepare($get_feature_log2level_q) or die "Unable to prepare get_feature_log2level_q : ".
        $get_feature_log2level_q . " : " .$dbh->errstr();
    $get_feature_log2level_qh->execute(@{$sample_ids},@{$feature_ids})  or die "Unable to execute get_feature_log2level_q : ".
        $get_feature_log2level_q . " : " .$get_feature_log2level_qh->errstr();
    while(my ($sample_id,$feature_id,$log2level) = $get_feature_log2level_qh->fetchrow_array())
    { 
        $label_data_mapping->{$sample_id}->{$feature_id}=$log2level;
    } 

    #END get_expression_data_by_samples_and_features
    my @_bad_returns;
    (ref($label_data_mapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"label_data_mapping\" (value was \"$label_data_mapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_data_by_samples_and_features:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_data_by_samples_and_features');
    }
    return($label_data_mapping);
}




=head2 get_expression_samples_data_by_series_ids

  $series_expression_data_samples_mapping = $obj->get_expression_samples_data_by_series_ids($series_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$series_ids is an ExpressionServices.series_ids
$series_expression_data_samples_mapping is an ExpressionServices.series_expression_data_samples_mapping
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
series_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.series_id and the value is an ExpressionServices.expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$series_ids is an ExpressionServices.series_ids
$series_expression_data_samples_mapping is an ExpressionServices.series_expression_data_samples_mapping
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
series_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.series_id and the value is an ExpressionServices.expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float


=end text



=item Description

given a list of SeriesIDs returns mapping of SeriesID to expressionDataSamples : {series_id -> {sample_id -> expressionSampleDataStructure}}

=back

=cut

sub get_expression_samples_data_by_series_ids
{
    my $self = shift;
    my($series_ids) = @_;

    my @_bad_arguments;
    (ref($series_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"series_ids\" (value was \"$series_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_series_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($series_expression_data_samples_mapping);
    #BEGIN get_expression_samples_data_by_series_ids
    $series_expression_data_samples_mapping = {};
    if (0 == @{$series_ids})
    { 
        my $msg = "get_expression_samples_data_by_series_ids requires a list of valid series ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_samples_data_by_series_ids');
    } 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
	);


    my $get_sample_ids_by_series_ids_q = 
        qq^select ser.id, sam.id
           from Sample sam 
           inner join SampleInSeries sis on sam.id = sis.from_link
           inner join Series ser on sis.to_link = ser.id
           where ser.id in (^.
	join(",", ("?") x @{$series_ids}) . ") "; 
    my $get_sample_ids_by_series_ids_qh = $dbh->prepare($get_sample_ids_by_series_ids_q) or die
                                                "Unable to prepare get_sample_ids_by_series_ids_q : ". 
                                                $get_sample_ids_by_series_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_series_ids_qh->execute(@{$series_ids}) or die "Unable to execute get_sample_ids_by_series_ids_q : ".
			    $get_sample_ids_by_series_ids_q . " : " . $get_sample_ids_by_series_ids_qh->errstr() . "\n\n";
    my %series_id_sample_id_hash; # {seriesID}->{sample_id}=1		
    my %sample_ids_hash; #hash to get unique sample_id_hash
    while (my ($series_id, $sample_id) = $get_sample_ids_by_series_ids_qh->fetchrow_array())			   
    { 
	$sample_ids_hash{$sample_id} = 1; 
	$series_id_sample_id_hash{$series_id}->{$sample_id}=1;
    }
    # Get the ExpressionDataSamples  			    
    my @distinct_sample_ids = keys(%sample_ids_hash); 

    my $sample_ids_data_hash_ref = $self->get_expression_samples_data(\@distinct_sample_ids);

    my %sample_ids_data_hash = %{$sample_ids_data_hash_ref};    
    my %series_id_sample_data_hash; # {series}->{sample_id}->data_hash               
    foreach my $series_id (keys(%series_id_sample_id_hash))
    { 
        foreach my $sample_id (keys(%{$series_id_sample_id_hash{$series_id}}))
	{ 
	    $series_id_sample_data_hash{$series_id}->{$sample_id} = $sample_ids_data_hash{$sample_id};
	} 
    } 
    $series_expression_data_samples_mapping = \%series_id_sample_data_hash;
    #END get_expression_samples_data_by_series_ids
    my @_bad_returns;
    (ref($series_expression_data_samples_mapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"series_expression_data_samples_mapping\" (value was \"$series_expression_data_samples_mapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_series_ids');
    }
    return($series_expression_data_samples_mapping);
}




=head2 get_expression_sample_ids_by_series_ids

  $sample_ids = $obj->get_expression_sample_ids_by_series_ids($series_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$series_ids is an ExpressionServices.series_ids
$sample_ids is an ExpressionServices.sample_ids
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string

</pre>

=end html

=begin text

$series_ids is an ExpressionServices.series_ids
$sample_ids is an ExpressionServices.sample_ids
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string


=end text



=item Description

given a list of SeriesIDs returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_series_ids
{
    my $self = shift;
    my($series_ids) = @_;

    my @_bad_arguments;
    (ref($series_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"series_ids\" (value was \"$series_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_series_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($sample_ids);
    #BEGIN get_expression_sample_ids_by_series_ids
    if (0 == @{$series_ids}) 
    { 
        my $msg = "get_expression_sample_ids_by_series_ids requires a list of valid series ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
							     method_name => 'get_expression_sample_ids_by_series_ids'); 
    } 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
 
    my $get_sample_ids_by_series_ids_q = 
        qq^select sam.id 
           from Sample sam  
           inner join SampleInSeries sis on sam.id = sis.from_link  
           inner join Series ser on sis.to_link = ser.id  
           where ser.id in (^. 
	   join(",", ("?") x @{$series_ids}) . ") "; 
    my $get_sample_ids_by_series_ids_qh = $dbh->prepare($get_sample_ids_by_series_ids_q) or die 
                                                "Unable to prepare get_sample_ids_by_series_ids_q : ". 
                                                $get_sample_ids_by_series_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_series_ids_qh->execute(@{$series_ids}) or die "Unable to execute get_sample_ids_by_series_ids_q : ". 
	$get_sample_ids_by_series_ids_q . " : " . $get_sample_ids_by_series_ids_qh->errstr() . "\n\n"; 
    my %sample_ids_hash; #hash to get unique sample_id_hash 
    while (my ($sample_id) = $get_sample_ids_by_series_ids_qh->fetchrow_array()) 
    { 
	$sample_ids_hash{$sample_id} = 1;
    } 
    my @temp_arr = keys(%sample_ids_hash);
    $sample_ids = \@temp_arr;
    #END get_expression_sample_ids_by_series_ids
    my @_bad_returns;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_series_ids');
    }
    return($sample_ids);
}




=head2 get_expression_samples_data_by_experimental_unit_ids

  $experimental_unit_expression_data_samples_mapping = $obj->get_expression_samples_data_by_experimental_unit_ids($experimental_unit_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$experimental_unit_ids is an ExpressionServices.experimental_unit_ids
$experimental_unit_expression_data_samples_mapping is an ExpressionServices.experimental_unit_expression_data_samples_mapping
experimental_unit_ids is a reference to a list where each element is an ExpressionServices.experimental_unit_id
experimental_unit_id is a string
experimental_unit_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.experimental_unit_id and the value is an ExpressionServices.expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$experimental_unit_ids is an ExpressionServices.experimental_unit_ids
$experimental_unit_expression_data_samples_mapping is an ExpressionServices.experimental_unit_expression_data_samples_mapping
experimental_unit_ids is a reference to a list where each element is an ExpressionServices.experimental_unit_id
experimental_unit_id is a string
experimental_unit_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.experimental_unit_id and the value is an ExpressionServices.expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float


=end text



=item Description

given a list of ExperimentalUnitIDs returns mapping of ExperimentalUnitID to expressionDataSamples : {experimental_unit_id -> {sample_id -> expressionSampleDataStructure}}

=back

=cut

sub get_expression_samples_data_by_experimental_unit_ids
{
    my $self = shift;
    my($experimental_unit_ids) = @_;

    my @_bad_arguments;
    (ref($experimental_unit_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"experimental_unit_ids\" (value was \"$experimental_unit_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_experimental_unit_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($experimental_unit_expression_data_samples_mapping);
    #BEGIN get_expression_samples_data_by_experimental_unit_ids
    $experimental_unit_expression_data_samples_mapping = {};
    if (0 == @{$experimental_unit_ids}) 
    { 
        my $msg = "get_expression_samples_data_by_experimental_unit_ids requires a list of valid experimental unit ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_samples_data_by_experimental_unit_ids'); 
    } 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
	); 
    my $get_sample_ids_by_experimental_unit_ids_q = 
        qq^select eu.id, sam.id           
           from  Sample sam
           inner join HasExpressionSample hes on sam.id = hes.to_link
           inner join ExperimentalUnit eu on hes.from_link = eu.id
           where eu.id in (^.
	   join(",", ("?") x @{$experimental_unit_ids}) . ") "; 
    my $get_sample_ids_by_experimental_unit_ids_qh = $dbh->prepare($get_sample_ids_by_experimental_unit_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_experimental_unit_ids_q : ". 
                                                              $get_sample_ids_by_experimental_unit_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_experimental_unit_ids_qh->execute(@{$experimental_unit_ids}) or die "Unable to execute get_sample_ids_by_experimental_unit_ids_q : ". 
        $get_sample_ids_by_experimental_unit_ids_q . " : " . $get_sample_ids_by_experimental_unit_ids_qh->errstr() . "\n\n"; 
    my %experimental_unit_sample_list_hash; # {experimentalUnitID}->[Sample_IDS]                                                                                                                                                                                                               
    my %sample_ids_hash; #hash to get unique sample_id_hash                                                                                                                                                                                                                                    
    while (my ($experimental_unit_id, $sample_id) = $get_sample_ids_by_experimental_unit_ids_qh->fetchrow_array()) 
    { 
        $sample_ids_hash{$sample_id} = 1; 
        if (exists($experimental_unit_sample_list_hash{$experimental_unit_id})) 
        { 
            push(@{$experimental_unit_sample_list_hash{$experimental_unit_id}},$sample_id); 
        } 
        else 
        { 
            $experimental_unit_sample_list_hash{$experimental_unit_id} = [$sample_id]; 
        } 
    } 
    # Get the ExpressionDataSamples                                                                                                                                                                                                                                                            
    my @distinct_sample_ids = keys(%sample_ids_hash); 
    my %sample_ids_data_hash = %{$self->get_expression_samples_data(\@distinct_sample_ids)}; 
    my %exp_unit_sample_data_hash; # {exp_unit_id}->{sample_id}->data_hash                                                                                                                                                                                                                     
    foreach my $experimental_unit_id (keys(%experimental_unit_sample_list_hash)) 
    { 
        foreach my $sample_id (@{$experimental_unit_sample_list_hash{$experimental_unit_id}}) 
        { 
            $exp_unit_sample_data_hash{$experimental_unit_id}->{$sample_id} = $sample_ids_data_hash{$sample_id}; 
        } 
    } 
    $experimental_unit_expression_data_samples_mapping = \%exp_unit_sample_data_hash; 
    #END get_expression_samples_data_by_experimental_unit_ids
    my @_bad_returns;
    (ref($experimental_unit_expression_data_samples_mapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"experimental_unit_expression_data_samples_mapping\" (value was \"$experimental_unit_expression_data_samples_mapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_experimental_unit_ids');
    }
    return($experimental_unit_expression_data_samples_mapping);
}




=head2 get_expression_sample_ids_by_experimental_unit_ids

  $sample_ids = $obj->get_expression_sample_ids_by_experimental_unit_ids($experimental_unit_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$experimental_unit_ids is an ExpressionServices.experimental_unit_ids
$sample_ids is an ExpressionServices.sample_ids
experimental_unit_ids is a reference to a list where each element is an ExpressionServices.experimental_unit_id
experimental_unit_id is a string
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string

</pre>

=end html

=begin text

$experimental_unit_ids is an ExpressionServices.experimental_unit_ids
$sample_ids is an ExpressionServices.sample_ids
experimental_unit_ids is a reference to a list where each element is an ExpressionServices.experimental_unit_id
experimental_unit_id is a string
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string


=end text



=item Description

given a list of ExperimentalUnitIDs returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_experimental_unit_ids
{
    my $self = shift;
    my($experimental_unit_ids) = @_;

    my @_bad_arguments;
    (ref($experimental_unit_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"experimental_unit_ids\" (value was \"$experimental_unit_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_experimental_unit_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($sample_ids);
    #BEGIN get_expression_sample_ids_by_experimental_unit_ids
    $sample_ids = [];
    if (0 == @{$experimental_unit_ids}) 
    { 
        my $msg = "get_expression_sample_ids_by_experimental_unit_ids requires a list of valid experimental unit ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_sample_ids_by_experimental_unit_ids'); 
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
    my $get_sample_ids_by_experimental_unit_ids_q = 
        qq^select distinct sam.id   
           from  Sample sam  
           inner join HasExpressionSample hes on sam.id = hes.to_link  
           inner join ExperimentalUnit eu on hes.from_link = eu.id
           where eu.id in (^. 
           join(",", ("?") x @{$experimental_unit_ids}) . ") "; 
    my $get_sample_ids_by_experimental_unit_ids_qh = $dbh->prepare($get_sample_ids_by_experimental_unit_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_experimental_unit_ids_q : ". 
                                                              $get_sample_ids_by_experimental_unit_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_experimental_unit_ids_qh->execute(@{$experimental_unit_ids}) or die "Unable to execute get_sample_ids_by_experimental_unit_ids_q : ". 
        $get_sample_ids_by_experimental_unit_ids_q . " : " . $get_sample_ids_by_experimental_unit_ids_qh->errstr() . "\n\n"; 
    while (my ($sample_id) = $get_sample_ids_by_experimental_unit_ids_qh->fetchrow_array()) 
    { 
	push(@$sample_ids,$sample_id);
    } 
    #END get_expression_sample_ids_by_experimental_unit_ids
    my @_bad_returns;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_experimental_unit_ids');
    }
    return($sample_ids);
}




=head2 get_expression_samples_data_by_experiment_meta_ids

  $experiment_meta_expression_data_samples_mapping = $obj->get_expression_samples_data_by_experiment_meta_ids($experiment_meta_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$experiment_meta_ids is an ExpressionServices.experiment_meta_ids
$experiment_meta_expression_data_samples_mapping is an ExpressionServices.experiment_meta_expression_data_samples_mapping
experiment_meta_ids is a reference to a list where each element is an ExpressionServices.experiment_meta_id
experiment_meta_id is a string
experiment_meta_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.experiment_meta_id and the value is an ExpressionServices.experimental_unit_expression_data_samples_mapping
experimental_unit_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.experimental_unit_id and the value is an ExpressionServices.expression_data_samples_map
experimental_unit_id is a string
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$experiment_meta_ids is an ExpressionServices.experiment_meta_ids
$experiment_meta_expression_data_samples_mapping is an ExpressionServices.experiment_meta_expression_data_samples_mapping
experiment_meta_ids is a reference to a list where each element is an ExpressionServices.experiment_meta_id
experiment_meta_id is a string
experiment_meta_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.experiment_meta_id and the value is an ExpressionServices.experimental_unit_expression_data_samples_mapping
experimental_unit_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.experimental_unit_id and the value is an ExpressionServices.expression_data_samples_map
experimental_unit_id is a string
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
sample_type is a string
strain_id is a string
genome_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float


=end text



=item Description

given a list of ExperimentMetaIDs returns mapping of {experimentMetaID -> {experimentalUnitId -> {sample_id -> expressionSampleDataStructure}}}

=back

=cut

sub get_expression_samples_data_by_experiment_meta_ids
{
    my $self = shift;
    my($experiment_meta_ids) = @_;

    my @_bad_arguments;
    (ref($experiment_meta_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"experiment_meta_ids\" (value was \"$experiment_meta_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_experiment_meta_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($experiment_meta_expression_data_samples_mapping);
    #BEGIN get_expression_samples_data_by_experiment_meta_ids
    $experiment_meta_expression_data_samples_mapping = {}; 
    if (0 == @{$experiment_meta_ids}) 
    { 
        my $msg = "get_expression_samples_data_by_experimental_meta_ids requires a list of valid experimental unit ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_samples_data_by_experiment_meta_ids'); 
    } 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
 
    my %experimentMetaExpressionDataSamplesMapping_hash; 
    my %experimental_unit_ids_hash; 
    my $get_experimental_unit_ids_by_experiment_meta_ids_q = 
        qq^select em.id, eu.id   
           from Sample sam  
           inner join HasExpressionSample hes on sam.id = hes.to_link     
           inner join ExperimentalUnit eu on hes.from_link = eu.id        
           inner join HasExperimentalUnit heu on eu.id = heu.to_link   
           inner join ExperimentMeta em on heu.from_link = em.id   
           where em.id in (^. 
	join(",", ("?") x @{$experiment_meta_ids}) . ") "; 
    my $get_experimental_unit_ids_by_experiment_meta_ids_qh = $dbh->prepare($get_experimental_unit_ids_by_experiment_meta_ids_q) or die 
                                                              "Unable to prepare get_experimental_unit_ids_by_experiment_meta_ids_q : ". 
    $get_experimental_unit_ids_by_experiment_meta_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_experimental_unit_ids_by_experiment_meta_ids_qh->execute(@{$experiment_meta_ids}) or 
			       die "Unable to execute get_experimental_unit_ids_by_experiment_meta_ids_q : ". 
    $get_experimental_unit_ids_by_experiment_meta_ids_q . " : " . $get_experimental_unit_ids_by_experiment_meta_ids_qh->errstr() . "\n\n"; 
    while (my ($experiment_meta_id, $experimental_unit_id) = $get_experimental_unit_ids_by_experiment_meta_ids_qh->fetchrow_array()) 
    { 
	$experimentMetaExpressionDataSamplesMapping_hash{$experiment_meta_id}->{$experimental_unit_id}=1; 
	$experimental_unit_ids_hash{$experimental_unit_id}=1; 
    } 
    my @distinct_experimental_unit_ids = keys(%experimental_unit_ids_hash); 
    my %experimental_unit_expression_data_samples_mapping = %{$self->get_expression_samples_data_by_experimental_unit_ids(\@distinct_experimental_unit_ids)}; 
    my %return_expmeta_data_hash; 
    foreach my $experiment_meta_id (keys(%experimentMetaExpressionDataSamplesMapping_hash)) 
    { 
	my %exp_unit_hash = %{$experimentMetaExpressionDataSamplesMapping_hash{$experiment_meta_id}}; 
        foreach my $experimental_unit_id (keys(%exp_unit_hash)) 
        { 
            $return_expmeta_data_hash{$experiment_meta_id}->{$experimental_unit_id}=$experimental_unit_expression_data_samples_mapping{$experimental_unit_id}; 
        } 
    } 
    $experiment_meta_expression_data_samples_mapping = \%return_expmeta_data_hash; 
    #END get_expression_samples_data_by_experiment_meta_ids
    my @_bad_returns;
    (ref($experiment_meta_expression_data_samples_mapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"experiment_meta_expression_data_samples_mapping\" (value was \"$experiment_meta_expression_data_samples_mapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_experiment_meta_ids');
    }
    return($experiment_meta_expression_data_samples_mapping);
}




=head2 get_expression_sample_ids_by_experiment_meta_ids

  $sample_ids = $obj->get_expression_sample_ids_by_experiment_meta_ids($experiment_meta_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$experiment_meta_ids is an ExpressionServices.experiment_meta_ids
$sample_ids is an ExpressionServices.sample_ids
experiment_meta_ids is a reference to a list where each element is an ExpressionServices.experiment_meta_id
experiment_meta_id is a string
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string

</pre>

=end html

=begin text

$experiment_meta_ids is an ExpressionServices.experiment_meta_ids
$sample_ids is an ExpressionServices.sample_ids
experiment_meta_ids is a reference to a list where each element is an ExpressionServices.experiment_meta_id
experiment_meta_id is a string
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string


=end text



=item Description

given a list of ExperimentMetaIDs returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_experiment_meta_ids
{
    my $self = shift;
    my($experiment_meta_ids) = @_;

    my @_bad_arguments;
    (ref($experiment_meta_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"experiment_meta_ids\" (value was \"$experiment_meta_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_experiment_meta_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($sample_ids);
    #BEGIN get_expression_sample_ids_by_experiment_meta_ids
    $sample_ids = [];
    if (0 == @{$experiment_meta_ids}) 
    { 
        my $msg = "get_expression_sample_ids_by_experimental_meta_ids requires a list of valid experimental unit ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_sample_ids_by_experiment_meta_ids'); 
    } 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
     my $get_experimental_unit_ids_by_experiment_meta_ids_q = 
        qq^select distinct sam.id
           from Sample sam   
           inner join HasExpressionSample hes on sam.id = hes.to_link 
           inner join ExperimentalUnit eu on hes.from_link = eu.id   
           inner join HasExperimentalUnit heu on eu.id = heu.to_link  
           inner join ExperimentMeta em on heu.from_link = em.id  
           where em.id in (^. 
	   join(",", ("?") x @{$experiment_meta_ids}) . ") "; 
    my $get_experimental_unit_ids_by_experiment_meta_ids_qh = $dbh->prepare($get_experimental_unit_ids_by_experiment_meta_ids_q) or die 
                                                              "Unable to prepare get_experimental_unit_ids_by_experiment_meta_ids_q : ". 
							      $get_experimental_unit_ids_by_experiment_meta_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_experimental_unit_ids_by_experiment_meta_ids_qh->execute(@{$experiment_meta_ids}) or 
                               die "Unable to execute get_experimental_unit_ids_by_experiment_meta_ids_q : ". 
			       $get_experimental_unit_ids_by_experiment_meta_ids_q . " : " . $get_experimental_unit_ids_by_experiment_meta_ids_qh->errstr() . "\n\n"; 
    while (my ($sample_id) = $get_experimental_unit_ids_by_experiment_meta_ids_qh->fetchrow_array()) 
    { 
	push(@$sample_ids,$sample_id);
    } 
    #END get_expression_sample_ids_by_experiment_meta_ids
    my @_bad_returns;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_experiment_meta_ids');
    }
    return($sample_ids);
}




=head2 get_expression_samples_data_by_strain_ids

  $strain_expression_data_samples_mapping = $obj->get_expression_samples_data_by_strain_ids($strain_ids, $sample_type)

=over 4

=item Parameter and return types

=begin html

<pre>
$strain_ids is an ExpressionServices.strain_ids
$sample_type is an ExpressionServices.sample_type
$strain_expression_data_samples_mapping is an ExpressionServices.strain_expression_data_samples_mapping
strain_ids is a reference to a list where each element is an ExpressionServices.strain_id
strain_id is a string
sample_type is a string
strain_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.strain_id and the value is an ExpressionServices.expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
genome_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$strain_ids is an ExpressionServices.strain_ids
$sample_type is an ExpressionServices.sample_type
$strain_expression_data_samples_mapping is an ExpressionServices.strain_expression_data_samples_mapping
strain_ids is a reference to a list where each element is an ExpressionServices.strain_id
strain_id is a string
sample_type is a string
strain_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.strain_id and the value is an ExpressionServices.expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
genome_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float


=end text



=item Description

given a list of Strains, and a SampleType (controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) , it returns a StrainExpressionDataSamplesMapping,  
StrainId -> ExpressionSampleDataStructure {strain_id -> {sample_id -> expressionSampleDataStructure}}

=back

=cut

sub get_expression_samples_data_by_strain_ids
{
    my $self = shift;
    my($strain_ids, $sample_type) = @_;

    my @_bad_arguments;
    (ref($strain_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"strain_ids\" (value was \"$strain_ids\")");
    (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument \"sample_type\" (value was \"$sample_type\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_strain_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($strain_expression_data_samples_mapping);
    #BEGIN get_expression_samples_data_by_strain_ids
    $strain_expression_data_samples_mapping = {};
    if (0 == scalar(@{$strain_ids})) 
    { 
        my $msg = "get_expression_samples_data_by_strain_ids requires a list of valid strain ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_samples_data_by_strain_ids'); 
    } 
    my $sample_type_part = ""; 
    if ((uc($sample_type) eq "RNA-SEQ") || (uc($sample_type) eq "RNA_SEQ") || (uc($sample_type) eq "RNASEQ") || (uc($sample_type) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sample_type) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sample_type) eq "MICROARRAY") 
    { 
        $sample_type_part = " and sam.type = 'microarray' "; 
    } 
    elsif(uc($sample_type) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.                                                                                                                                                           
    } 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
	);

    my $get_sample_ids_by_strain_ids_q = 
        qq^select str.id, sam.id
           from Sample sam 
           inner join StrainWithSample sws on sam.id = sws.to_link
           inner join Strain str on sws.from_link = str.id 
           where str.id in (^. 
	join(",", ("?") x @{$strain_ids}) . ") ".
	$sample_type_part;
    my $get_sample_ids_by_strain_ids_qh = $dbh->prepare($get_sample_ids_by_strain_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_strain_ids_q : ". 
                                                              $get_sample_ids_by_strain_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_strain_ids_qh->execute(@{$strain_ids}) or die "Unable to execute get_sample_ids_by_strain_ids_q : ". 
        $get_sample_ids_by_strain_ids_q . " : " . $get_sample_ids_by_strain_ids_qh->errstr() . "\n\n"; 
    my %strain_id_sample_id_hash; # {strainID}->{sample_id}=1     
    my %sample_ids_hash; #hash to get unique sample_id_hash      
    while (my ($strain_id, $sample_id) = $get_sample_ids_by_strain_ids_qh->fetchrow_array()) 
    { 
        $sample_ids_hash{$sample_id} = 1; 
	$strain_id_sample_id_hash{$strain_id}->{$sample_id}=1;
    } 
    # Get the ExpressionDataSamples                                                                                                                                                                                            
    my @distinct_sample_ids = keys(%sample_ids_hash); 
    my %sample_ids_data_hash = %{$self->get_expression_samples_data(\@distinct_sample_ids)}; 
    my %strain_id_sample_data_hash; # {strain}->{sample_id}->data_hash                  
    foreach my $strain_id (keys(%strain_id_sample_id_hash)) 
    { 
        foreach my $sample_id (keys(%{$strain_id_sample_id_hash{$strain_id}})) 
        { 
            $strain_id_sample_data_hash{$strain_id}->{$sample_id} = $sample_ids_data_hash{$sample_id}; 
        } 
    } 
    $strain_expression_data_samples_mapping = \%strain_id_sample_data_hash; 
    #END get_expression_samples_data_by_strain_ids
    my @_bad_returns;
    (ref($strain_expression_data_samples_mapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"strain_expression_data_samples_mapping\" (value was \"$strain_expression_data_samples_mapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_strain_ids');
    }
    return($strain_expression_data_samples_mapping);
}




=head2 get_expression_sample_ids_by_strain_ids

  $sample_ids = $obj->get_expression_sample_ids_by_strain_ids($strain_ids, $sample_type)

=over 4

=item Parameter and return types

=begin html

<pre>
$strain_ids is an ExpressionServices.strain_ids
$sample_type is an ExpressionServices.sample_type
$sample_ids is an ExpressionServices.sample_ids
strain_ids is a reference to a list where each element is an ExpressionServices.strain_id
strain_id is a string
sample_type is a string
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string

</pre>

=end html

=begin text

$strain_ids is an ExpressionServices.strain_ids
$sample_type is an ExpressionServices.sample_type
$sample_ids is an ExpressionServices.sample_ids
strain_ids is a reference to a list where each element is an ExpressionServices.strain_id
strain_id is a string
sample_type is a string
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string


=end text



=item Description

given a list of Strains, and a SampleType, it returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_strain_ids
{
    my $self = shift;
    my($strain_ids, $sample_type) = @_;

    my @_bad_arguments;
    (ref($strain_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"strain_ids\" (value was \"$strain_ids\")");
    (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument \"sample_type\" (value was \"$sample_type\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_strain_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($sample_ids);
    #BEGIN get_expression_sample_ids_by_strain_ids
    $sample_ids = [];
    if (0 == @{$strain_ids}) 
    { 
        my $msg = "get_expression_sample_ids_by_strain_ids requires a list of valid strain ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_sample_ids_by_strain_ids'); 
    } 
    my $sample_type_part = ""; 
    if ((uc($sample_type) eq "RNA-SEQ") || (uc($sample_type) eq "RNA_SEQ") || (uc($sample_type) eq "RNASEQ") || (uc($sample_type) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sample_type) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sample_type) eq "MICROARRAY") 
    { 
        $sample_type_part = " and sam.type = 'microarray' "; 
    } 
    elsif(uc($sample_type) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty. 
    } 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
 
    my $get_sample_ids_by_strain_ids_q = 
        qq^select distinct sam.id 
           from Sample sam 
           inner join StrainWithSample sws on sam.id = sws.to_link 
           inner join Strain str on sws.from_link = str.id   
           where str.id in (^. 
	   join(",", ("?") x @{$strain_ids}) . ") ". 
	   $sample_type_part; 
    my $get_sample_ids_by_strain_ids_qh = $dbh->prepare($get_sample_ids_by_strain_ids_q) or die
                                                              "Unable to prepare get_sample_ids_by_strain_ids_q : ".
							      $get_sample_ids_by_strain_ids_q . " : " . dbh->errstr() . "\n\n";
    $get_sample_ids_by_strain_ids_qh->execute(@{$strain_ids}) or die "Unable to execute get_sample_ids_by_strain_ids_q : ".
	$get_sample_ids_by_strain_ids_q . " : " . $get_sample_ids_by_strain_ids_qh->errstr() . "\n\n";
    while (my ($sample_id) = $get_sample_ids_by_strain_ids_qh->fetchrow_array()) 
    { 
	push(@$sample_ids,$sample_id);
    } 
    #END get_expression_sample_ids_by_strain_ids
    my @_bad_returns;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_strain_ids');
    }
    return($sample_ids);
}




=head2 get_expression_samples_data_by_genome_ids

  $genome_expression_data_samples_mapping = $obj->get_expression_samples_data_by_genome_ids($genome_ids, $sample_type, $wild_type_only)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_ids is an ExpressionServices.genome_ids
$sample_type is an ExpressionServices.sample_type
$wild_type_only is an ExpressionServices.wild_type_only
$genome_expression_data_samples_mapping is an ExpressionServices.genome_expression_data_samples_mapping
genome_ids is a reference to a list where each element is an ExpressionServices.genome_id
genome_id is a string
sample_type is a string
wild_type_only is an int
genome_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.genome_id and the value is an ExpressionServices.strain_expression_data_samples_mapping
strain_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.strain_id and the value is an ExpressionServices.expression_data_samples_map
strain_id is a string
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$genome_ids is an ExpressionServices.genome_ids
$sample_type is an ExpressionServices.sample_type
$wild_type_only is an ExpressionServices.wild_type_only
$genome_expression_data_samples_mapping is an ExpressionServices.genome_expression_data_samples_mapping
genome_ids is a reference to a list where each element is an ExpressionServices.genome_id
genome_id is a string
sample_type is a string
wild_type_only is an int
genome_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.genome_id and the value is an ExpressionServices.strain_expression_data_samples_mapping
strain_expression_data_samples_mapping is a reference to a hash where the key is an ExpressionServices.strain_id and the value is an ExpressionServices.expression_data_samples_map
strain_id is a string
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float


=end text



=item Description

given a list of Genomes, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
and a int indicating WildTypeOnly (1 = true, 0 = false) , it returns a GenomeExpressionDataSamplesMapping   ,  
GenomeId -> StrainId -> ExpressionDataSample.  StrainId -> ExpressionSampleDataStructure {genome_id -> {strain_id -> {sample_id -> expressionSampleDataStructure}}}

=back

=cut

sub get_expression_samples_data_by_genome_ids
{
    my $self = shift;
    my($genome_ids, $sample_type, $wild_type_only) = @_;

    my @_bad_arguments;
    (ref($genome_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"genome_ids\" (value was \"$genome_ids\")");
    (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument \"sample_type\" (value was \"$sample_type\")");
    (!ref($wild_type_only)) or push(@_bad_arguments, "Invalid type for argument \"wild_type_only\" (value was \"$wild_type_only\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_genome_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($genome_expression_data_samples_mapping);
    #BEGIN get_expression_samples_data_by_genome_ids
    $genome_expression_data_samples_mapping = {};
    if (0 == @{$genome_ids}) 
    { 
        my $msg = "get_expression_samples_data_by_genome_ids  requires a list of valid genome ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_samples_data_by_genome_ids'); 
    } 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
	);

    my $wild_type_part = "";
    if (($wild_type_only eq "1") || (uc($wild_type_only) eq "Y") || (uc($wild_type_only) eq "TRUE"))
    {
	$wild_type_part = " and str.wildType = 'Y' ";
    }
    my $sample_type_part = "";
    if ((uc($sample_type) eq "RNA-SEQ") || (uc($sample_type) eq "RNA_SEQ") || (uc($sample_type) eq "RNASEQ") || (uc($sample_type) eq "RNA SEQ"))
    {
	$sample_type_part = " and sam.type = 'RNA-Seq' ";
    }
    elsif(uc($sample_type) eq "QPCR")
    {
	$sample_type_part = " and sam.type = 'qPCR' ";
    }
    elsif(uc($sample_type) eq "MICROARRAY")
    {
	$sample_type_part = " and sam.type = 'microarray' ";
    }
    elsif(uc($sample_type) eq "PROTEOMICS")
    {
        $sample_type_part = " and sam.type = 'proteomics' ";
    }
    else 
    {
	#ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.
    }
    my %strain_ids_hash; 
    my %genome_strain_id_hash;
    my $get_strain_ids_by_genome_ids_q = 
        qq^select gen.id, str.id
           from Sample sam 
           inner join StrainWithSample sws on sam.id = sws.to_link
           inner join Strain str on sws.from_link = str.id
           inner join GenomeParentOf gpo on str.id = gpo.to_link
           inner join kbase_sapling_v1.Genome gen on gpo.from_link = gen.id
           where gen.id in (^.
	   join(",", ("?") x @{$genome_ids}). ") ". 
	   $wild_type_part . 
	   $sample_type_part;
    my $get_strain_ids_by_genome_ids_qh = $dbh->prepare($get_strain_ids_by_genome_ids_q) or die 
                                                              "Unable to prepare get_strain_ids_by_genome_ids_q : ". 
                                                              $get_strain_ids_by_genome_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_strain_ids_by_genome_ids_qh->execute(@{$genome_ids}) or die "Unable to execute get_strain_ids_by_genome_ids_q : ". 
        $get_strain_ids_by_genome_ids_q . " : " . $get_strain_ids_by_genome_ids_qh->errstr() . "\n\n"; 
    while (my ($genome_id, $strain_id) = $get_strain_ids_by_genome_ids_qh->fetchrow_array()) 
    { 
        $genome_strain_id_hash{$genome_id}->{$strain_id}=1; 
        $strain_ids_hash{$strain_id}=1; 
    } 
    my @distinct_strain_ids = keys(%strain_ids_hash); 
    my %strainExpressionDataSamplesMapping = %{$self->get_expression_samples_data_by_strain_ids(\@distinct_strain_ids, $sample_type)}; 
 
    my %return_genome_data_hash; 
    foreach my $genome_id (keys(%genome_strain_id_hash)) 
    { 
	my %strain_hash = %{$genome_strain_id_hash{$genome_id}};
	foreach my $strain_id (keys(%strain_hash))
	{
	    $return_genome_data_hash{$genome_id}->{$strain_id} = $strainExpressionDataSamplesMapping{$strain_id};
	}
    } 
    $genome_expression_data_samples_mapping = \%return_genome_data_hash;              
    #END get_expression_samples_data_by_genome_ids
    my @_bad_returns;
    (ref($genome_expression_data_samples_mapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"genome_expression_data_samples_mapping\" (value was \"$genome_expression_data_samples_mapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_genome_ids');
    }
    return($genome_expression_data_samples_mapping);
}




=head2 get_expression_sample_ids_by_genome_ids

  $sample_ids = $obj->get_expression_sample_ids_by_genome_ids($genome_ids, $sample_type, $wild_type_only)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_ids is an ExpressionServices.genome_ids
$sample_type is an ExpressionServices.sample_type
$wild_type_only is an ExpressionServices.wild_type_only
$sample_ids is an ExpressionServices.sample_ids
genome_ids is a reference to a list where each element is an ExpressionServices.genome_id
genome_id is a string
sample_type is a string
wild_type_only is an int
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string

</pre>

=end html

=begin text

$genome_ids is an ExpressionServices.genome_ids
$sample_type is an ExpressionServices.sample_type
$wild_type_only is an ExpressionServices.wild_type_only
$sample_ids is an ExpressionServices.sample_ids
genome_ids is a reference to a list where each element is an ExpressionServices.genome_id
genome_id is a string
sample_type is a string
wild_type_only is an int
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string


=end text



=item Description

given a list of GenomeIDs, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
and a int indicating WildType Only (1 = true, 0 = false) , it returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_genome_ids
{
    my $self = shift;
    my($genome_ids, $sample_type, $wild_type_only) = @_;

    my @_bad_arguments;
    (ref($genome_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"genome_ids\" (value was \"$genome_ids\")");
    (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument \"sample_type\" (value was \"$sample_type\")");
    (!ref($wild_type_only)) or push(@_bad_arguments, "Invalid type for argument \"wild_type_only\" (value was \"$wild_type_only\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_genome_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($sample_ids);
    #BEGIN get_expression_sample_ids_by_genome_ids
    $sample_ids = [];
    if (0 == @{$genome_ids}) 
    { 
        my $msg = "get_expression_sample_ids_by_genome_ids requires a list of valid genome ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_sample_ids_by_genome_ids'); 
    } 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
 
    my $wild_type_part = ""; 
    if (($wild_type_only eq "1") || (uc($wild_type_only) eq "Y") || (uc($wild_type_only) eq "TRUE")) 
    { 
        $wild_type_part = " and str.wildType = 'Y' "; 
    } 
    my $sample_type_part = ""; 
    if ((uc($sample_type) eq "RNA-SEQ") || (uc($sample_type) eq "RNA_SEQ") || (uc($sample_type) eq "RNASEQ") || (uc($sample_type) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sample_type) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sample_type) eq "MICROARRAY") 
    { 
        $sample_type_part = " and sam.type = 'microarray' "; 
    } 
    elsif(uc($sample_type) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.   
    } 
    my $get_strain_ids_by_genome_ids_q = 
        qq^select distinct sam.id  
           from Sample sam 
           inner join StrainWithSample sws on sam.id = sws.to_link 
           inner join Strain str on sws.from_link = str.id 
           inner join GenomeParentOf gpo on str.id = gpo.to_link 
           inner join kbase_sapling_v1.Genome gen on gpo.from_link = gen.id     
           where gen.id in (^. 
	   join(",", ("?") x @{$genome_ids}). ") ". 
           $wild_type_part . 
	   $sample_type_part; 
    my $get_strain_ids_by_genome_ids_qh = $dbh->prepare($get_strain_ids_by_genome_ids_q) or die
	"Unable to prepare get_strain_ids_by_genome_ids_q : ".
	$get_strain_ids_by_genome_ids_q . " : " . dbh->errstr() . "\n\n";
    $get_strain_ids_by_genome_ids_qh->execute(@{$genome_ids}) or die "Unable to execute get_strain_ids_by_genome_ids_q : ".
	$get_strain_ids_by_genome_ids_q . " : " . $get_strain_ids_by_genome_ids_qh->errstr() . "\n\n";
    while (my ($sample_id) = $get_strain_ids_by_genome_ids_qh->fetchrow_array())
    {
	push(@$sample_ids,$sample_id);
    }
    #END get_expression_sample_ids_by_genome_ids
    my @_bad_returns;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_genome_ids');
    }
    return($sample_ids);
}




=head2 get_expression_samples_data_by_ontology_ids

  $ontology_expression_data_sample_mapping = $obj->get_expression_samples_data_by_ontology_ids($ontology_ids, $and_or, $genome_id, $sample_type, $wild_type_only)

=over 4

=item Parameter and return types

=begin html

<pre>
$ontology_ids is an ExpressionServices.ontology_ids
$and_or is a string
$genome_id is an ExpressionServices.genome_id
$sample_type is an ExpressionServices.sample_type
$wild_type_only is an ExpressionServices.wild_type_only
$ontology_expression_data_sample_mapping is an ExpressionServices.ontology_expression_data_sample_mapping
ontology_ids is a reference to a list where each element is an ExpressionServices.ontology_id
ontology_id is a string
genome_id is a string
sample_type is a string
wild_type_only is an int
ontology_expression_data_sample_mapping is a reference to a hash where the key is an ExpressionServices.ontology_id and the value is an ExpressionServices.expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
strain_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float

</pre>

=end html

=begin text

$ontology_ids is an ExpressionServices.ontology_ids
$and_or is a string
$genome_id is an ExpressionServices.genome_id
$sample_type is an ExpressionServices.sample_type
$wild_type_only is an ExpressionServices.wild_type_only
$ontology_expression_data_sample_mapping is an ExpressionServices.ontology_expression_data_sample_mapping
ontology_ids is a reference to a list where each element is an ExpressionServices.ontology_id
ontology_id is a string
genome_id is a string
sample_type is a string
wild_type_only is an int
ontology_expression_data_sample_mapping is a reference to a hash where the key is an ExpressionServices.ontology_id and the value is an ExpressionServices.expression_data_samples_map
expression_data_samples_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
sample_id is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sample_id has a value which is an ExpressionServices.sample_id
	source_id has a value which is a string
	sample_title has a value which is a string
	sample_description has a value which is a string
	molecule has a value which is a string
	sample_type has a value which is an ExpressionServices.sample_type
	data_source has a value which is a string
	external_source_id has a value which is a string
	external_source_date has a value which is a string
	kbase_submission_date has a value which is a string
	custom has a value which is a string
	original_log2_median has a value which is a float
	strain_id has a value which is an ExpressionServices.strain_id
	reference_strain has a value which is a string
	wildtype has a value which is a string
	strain_description has a value which is a string
	genome_id has a value which is an ExpressionServices.genome_id
	genome_scientific_name has a value which is a string
	platform_id has a value which is a string
	platform_title has a value which is a string
	platform_technology has a value which is a string
	experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
	experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
	experiment_title has a value which is a string
	experiment_description has a value which is a string
	environment_id has a value which is a string
	environment_description has a value which is a string
	protocol_id has a value which is a string
	protocol_description has a value which is a string
	protocol_name has a value which is a string
	sample_annotations has a value which is an ExpressionServices.sample_annotations
	series_ids has a value which is an ExpressionServices.series_ids
	person_ids has a value which is an ExpressionServices.person_ids
	sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
	data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample
strain_id is a string
experimental_unit_id is a string
experiment_meta_id is a string
sample_annotations is a reference to a list where each element is an ExpressionServices.SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
	ontology_id has a value which is an ExpressionServices.ontology_id
	ontology_name has a value which is an ExpressionServices.ontology_name
	ontology_definition has a value which is an ExpressionServices.ontology_definition
sample_annotation_id is a string
ontology_name is a string
ontology_definition is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
person_ids is a reference to a list where each element is an ExpressionServices.person_id
person_id is a string
sample_ids_averaged_from is a reference to a list where each element is an ExpressionServices.sample_id
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float


=end text



=item Description

given a list of ontologyIDs, AndOr operator (and requires sample to have all ontology IDs, or sample has to have any of the terms), GenomeId, 
SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics), wildTypeOnly returns OntologyID(concatenated if Anded) -> ExpressionDataSample

=back

=cut

sub get_expression_samples_data_by_ontology_ids
{
    my $self = shift;
    my($ontology_ids, $and_or, $genome_id, $sample_type, $wild_type_only) = @_;

    my @_bad_arguments;
    (ref($ontology_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ontology_ids\" (value was \"$ontology_ids\")");
    (!ref($and_or)) or push(@_bad_arguments, "Invalid type for argument \"and_or\" (value was \"$and_or\")");
    (!ref($genome_id)) or push(@_bad_arguments, "Invalid type for argument \"genome_id\" (value was \"$genome_id\")");
    (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument \"sample_type\" (value was \"$sample_type\")");
    (!ref($wild_type_only)) or push(@_bad_arguments, "Invalid type for argument \"wild_type_only\" (value was \"$wild_type_only\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_ontology_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_ontology_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($ontology_expression_data_sample_mapping);
    #BEGIN get_expression_samples_data_by_ontology_ids
    $ontology_expression_data_sample_mapping = {}; 
    if (0 == @{$ontology_ids}) 
    { 
        my $msg = "get_expression_samples_data_by_ontology_ids requires a list of valid ontology ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
							       method_name => 'get_expression_samples_data_by_ontology_ids'); 
    } 
    if (uc($and_or) eq 'AND')
    {
	$and_or = 'and';
    }
    elsif (uc($and_or) eq 'OR')
    {
	$and_or = 'or';
    }
    else  #DEFAULTS TO OR : Really should have a warning or error message, but this is undefined KBase wide.  Meantime will default.
    {
	$and_or = 'or';
    }
    my $wild_type_part = ""; 
    if (($wild_type_only eq "1") || (uc($wild_type_only) eq "Y") || (uc($wild_type_only) eq "TRUE")) 
    { 
        $wild_type_part = " and str.wildType = 'Y' "; 
    } 
    my $sample_type_part = ""; 
    if ((uc($sample_type) eq "RNA-SEQ") || (uc($sample_type) eq "RNA_SEQ") || (uc($sample_type) eq "RNASEQ") || (uc($sample_type) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sample_type) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sample_type) eq "MICROARRAY") 
    { 
        $sample_type_part = " and sam.type = 'microarray' "; 
    } 
    elsif(uc($sample_type) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.          
    } 
    my %distinct_ontologies;
    foreach my $ont_id (@{$ontology_ids})
    {
	$distinct_ontologies{$ont_id} = 1;
    }
    my $distinct_ontology_count = scalar(keys(%distinct_ontologies));

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
	); 
    my $get_sample_ids_by_ontology_ids_q = 
	    qq^select distinct sam.id as samid, ont.id as ontid
               from Sample sam  
               inner join StrainWithSample sws on sam.id = sws.to_link 
               inner join Strain str on sws.from_link = str.id 
               inner join GenomeParentOf gpo on str.id = gpo.to_link 
               inner join kbase_sapling_v1.Genome gen on gpo.from_link = gen.id 
               inner join SampleHasAnnotations sha on sha.from_link = sam.id
               inner join OntologyForSample ofs on ofs.to_link = sha.to_link
               inner join Ontology ont on ofs.from_link = ont.id
               where gen.id = ? ^.
	       $sample_type_part .
	       $wild_type_part .
	    qq^ and ont.id in ( ^.
            join(",", ("?") x $distinct_ontology_count). ") "; 

    if (($and_or eq 'or') || ($distinct_ontology_count == 1)) 
    { 
	my $get_sample_ids_by_ontology_ids_qh = $dbh->prepare($get_sample_ids_by_ontology_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_ontolgy_ids_q : ". 
                                                              $get_sample_ids_by_ontology_ids_q . " : " . dbh->errstr() . "\n\n"; 
	$get_sample_ids_by_ontology_ids_qh->execute($genome_id, keys(%distinct_ontologies)) 
	    or die "Unable to execute get_sample_ids_by_ontology_ids_q : ". 
	    $get_sample_ids_by_ontology_ids_q . " : " . $get_sample_ids_by_ontology_ids_qh->errstr() . "\n\n"; 
	my %ontology_id_sample_id_hash; # {ontologyID}->{sample_id}=1   
	my %sample_ids_hash; #hash to get unique sample_id_hash    
	while (my ($sample_id, $ontology_id) = $get_sample_ids_by_ontology_ids_qh->fetchrow_array()) 
	{ 
	    $sample_ids_hash{$sample_id} = 1; 
	    $ontology_id_sample_id_hash{$ontology_id}->{$sample_id}=1; 
	} 
	# Get the ExpressionDataSamples     
	my @distinct_sample_ids = keys(%sample_ids_hash);
	my %sample_ids_data_hash = %{$self->get_expression_samples_data(\@distinct_sample_ids)};
	my %ontology_id_sample_data_hash; # {ontology_id}->{sample_id}->data_hash                                                                            
	foreach my $ontology_id (keys(%ontology_id_sample_id_hash))
	{
	    foreach my $sample_id (keys(%{$ontology_id_sample_id_hash{$ontology_id}}))
	    { 
		$ontology_id_sample_data_hash{$ontology_id}->{$sample_id} = $sample_ids_data_hash{$sample_id}; 
	    } 
	} 
	$ontology_expression_data_sample_mapping = \%ontology_id_sample_data_hash; 
    }
    elsif ($and_or eq 'and')
    {
	$get_sample_ids_by_ontology_ids_q =  
	    qq^select results.samid from ( ^.
	    $get_sample_ids_by_ontology_ids_q .
	    qq^) results
               group by results.samid
               having count(results.ontid) = ^ . $distinct_ontology_count;
	#print "QUERY : " . $get_sample_ids_by_ontology_ids_q . "\n";
    
        my $get_sample_ids_by_ontology_ids_qh = $dbh->prepare($get_sample_ids_by_ontology_ids_q) or die
                                                              "Unable to prepare get_sample_ids_by_ontolgy_ids_q : ".
                                                              $get_sample_ids_by_ontology_ids_q . " : " . dbh->errstr() . "\n\n";
        $get_sample_ids_by_ontology_ids_qh->execute($genome_id, keys(%distinct_ontologies)) 
	    or die "Unable to execute get_sample_ids_by_ontology_ids_q : ".
            $get_sample_ids_by_ontology_ids_q . " : " . $get_sample_ids_by_ontology_ids_qh->errstr() . "\n\n";
        my %ontology_id_sample_data_hash; # {ontologyID}->{sample_id}=1 
        my @sample_ids_arr; #unique sample_ids   
        while (my ($sample_id) = $get_sample_ids_by_ontology_ids_qh->fetchrow_array())
        {
	    push(@sample_ids_arr,$sample_id);
	}
	if (scalar(@sample_ids_arr) > 0)
	{
	    my %sample_ids_data_hash = %{$self->get_expression_samples_data(\@sample_ids_arr)}; 
	    my $ontology_and_key = join(",",sort(keys(%distinct_ontologies)));
	    $ontology_id_sample_data_hash{$ontology_and_key}= \%sample_ids_data_hash; 
	}
	$ontology_expression_data_sample_mapping = \%ontology_id_sample_data_hash; 
    }
    #END get_expression_samples_data_by_ontology_ids
    my @_bad_returns;
    (ref($ontology_expression_data_sample_mapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"ontology_expression_data_sample_mapping\" (value was \"$ontology_expression_data_sample_mapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_ontology_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_ontology_ids');
    }
    return($ontology_expression_data_sample_mapping);
}




=head2 get_expression_sample_ids_by_ontology_ids

  $sample_ids = $obj->get_expression_sample_ids_by_ontology_ids($ontology_ids, $and_or, $genome_id, $sample_type, $wild_type_only)

=over 4

=item Parameter and return types

=begin html

<pre>
$ontology_ids is an ExpressionServices.ontology_ids
$and_or is a string
$genome_id is an ExpressionServices.genome_id
$sample_type is an ExpressionServices.sample_type
$wild_type_only is an ExpressionServices.wild_type_only
$sample_ids is an ExpressionServices.sample_ids
ontology_ids is a reference to a list where each element is an ExpressionServices.ontology_id
ontology_id is a string
genome_id is a string
sample_type is a string
wild_type_only is an int
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string

</pre>

=end html

=begin text

$ontology_ids is an ExpressionServices.ontology_ids
$and_or is a string
$genome_id is an ExpressionServices.genome_id
$sample_type is an ExpressionServices.sample_type
$wild_type_only is an ExpressionServices.wild_type_only
$sample_ids is an ExpressionServices.sample_ids
ontology_ids is a reference to a list where each element is an ExpressionServices.ontology_id
ontology_id is a string
genome_id is a string
sample_type is a string
wild_type_only is an int
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string


=end text



=item Description

given a list of ontologyIDs, AndOr operator (and requires sample to have all ontology IDs, or sample has to have any of the terms), GenomeId, 
SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics), wildTypeOnly returns a list of SampleIDs

=back

=cut

sub get_expression_sample_ids_by_ontology_ids
{
    my $self = shift;
    my($ontology_ids, $and_or, $genome_id, $sample_type, $wild_type_only) = @_;

    my @_bad_arguments;
    (ref($ontology_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ontology_ids\" (value was \"$ontology_ids\")");
    (!ref($and_or)) or push(@_bad_arguments, "Invalid type for argument \"and_or\" (value was \"$and_or\")");
    (!ref($genome_id)) or push(@_bad_arguments, "Invalid type for argument \"genome_id\" (value was \"$genome_id\")");
    (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument \"sample_type\" (value was \"$sample_type\")");
    (!ref($wild_type_only)) or push(@_bad_arguments, "Invalid type for argument \"wild_type_only\" (value was \"$wild_type_only\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_ontology_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_ontology_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($sample_ids);
    #BEGIN get_expression_sample_ids_by_ontology_ids
    $sample_ids = [];
    if (0 == @{$ontology_ids})
    { 
        my $msg = "get_expression_sample_ids_by_ontology_ids requires a list of valid ontology ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							     method_name => 'get_expression_sample_ids_by_ontology_ids');
    } 
    if (uc($and_or) eq 'AND')
    { 
        $and_or = 'and'; 
    } 
    elsif (uc($and_or) eq 'OR') 
    { 
        $and_or = 'or'; 
    } 
    else  #DEFAULTS TO OR : Really should have a warning or error message, but this is undefined KBase wide.  Meantime will default.  
    { 
        $and_or = 'or'; 
    } 
    my $wild_type_part = ""; 
    if (($wild_type_only eq "1") || (uc($wild_type_only) eq "Y") || (uc($wild_type_only) eq "TRUE")) 
    { 
        $wild_type_part = " and str.wildType = 'Y' "; 
    } 
    my $sample_type_part = ""; 
    if ((uc($sample_type) eq "RNA-SEQ") || (uc($sample_type) eq "RNA_SEQ") || (uc($sample_type) eq "RNASEQ") || (uc($sample_type) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sample_type) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sample_type) eq "MICROARRAY")
    {
        $sample_type_part = " and sam.type = 'microarray' ";
    } 
    elsif(uc($sample_type) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.         
    } 
    my %distinct_ontologies; 
    foreach my $ont_id (@{$ontology_ids}) 
    { 
        $distinct_ontologies{$ont_id} = 1; 
    } 
    my $distinct_ontology_count = scalar(keys(%distinct_ontologies)); 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_sample_ids_by_ontology_ids_q_p1 = qq^select distinct sam.id as samid ^;
    my $get_sample_ids_by_ontology_ids_q_sub = ", ont.id as ontid "; 
    my $get_sample_ids_by_ontology_ids_q_p2 =
            qq^from Sample sam
               inner join StrainWithSample sws on sam.id = sws.to_link  
               inner join Strain str on sws.from_link = str.id               
               inner join GenomeParentOf gpo on str.id = gpo.to_link    
               inner join kbase_sapling_v1.Genome gen on gpo.from_link = gen.id   
               inner join SampleHasAnnotations sha on sha.from_link = sam.id  
               inner join OntologyForSample ofs on ofs.to_link = sha.to_link  
               inner join Ontology ont on ofs.from_link = ont.id  
               where gen.id = ? ^.
               $sample_type_part . 
               $wild_type_part . 
            qq^ and ont.id in ( ^. 
            join(",", ("?") x $distinct_ontology_count). ") ";
    if (($and_or eq 'or') || ($distinct_ontology_count == 1)) 
    { 
	my $get_sample_ids_by_ontology_ids_q = $get_sample_ids_by_ontology_ids_q_p1 . $get_sample_ids_by_ontology_ids_q_p2;
        my $get_sample_ids_by_ontology_ids_qh = $dbh->prepare($get_sample_ids_by_ontology_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_ontolgy_ids_q : ".
                                                              $get_sample_ids_by_ontology_ids_q . " : " . dbh->errstr() . "\n\n";
        $get_sample_ids_by_ontology_ids_qh->execute($genome_id, keys(%distinct_ontologies))
            or die "Unable to execute get_sample_ids_by_ontology_ids_q : ". 
            $get_sample_ids_by_ontology_ids_q . " : " . $get_sample_ids_by_ontology_ids_qh->errstr() . "\n\n";
        while (my ($sample_id) = $get_sample_ids_by_ontology_ids_qh->fetchrow_array())
        {
            push(@$sample_ids,$sample_id);
        } 
    }
    elsif ($and_or eq 'and') 
    { 
        my $get_sample_ids_by_ontology_ids_q = 
            qq^select results.samid from ( ^. 
	    $get_sample_ids_by_ontology_ids_q_p1 .
	    $get_sample_ids_by_ontology_ids_q_sub . 
	    $get_sample_ids_by_ontology_ids_q_p2.
            qq^) results  
               group by results.samid  
               having count(results.ontid) = ^ . $distinct_ontology_count; 
        #print "QUERY : " . $get_sample_ids_by_ontology_ids_q . "\n";  
	my $get_sample_ids_by_ontology_ids_qh = $dbh->prepare($get_sample_ids_by_ontology_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_ontolgy_ids_q : ". 
                                                              $get_sample_ids_by_ontology_ids_q . " : " . dbh->errstr() . "\n\n"; 
        $get_sample_ids_by_ontology_ids_qh->execute($genome_id, keys(%distinct_ontologies)) 
            or die "Unable to execute get_sample_ids_by_ontology_ids_q : ". 
            $get_sample_ids_by_ontology_ids_q . " : " . $get_sample_ids_by_ontology_ids_qh->errstr() . "\n\n"; 
        while (my ($sample_id) = $get_sample_ids_by_ontology_ids_qh->fetchrow_array()) 
        { 
            push(@$sample_ids,$sample_id); 
        } 
    }
    #END get_expression_sample_ids_by_ontology_ids
    my @_bad_returns;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_ontology_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_ontology_ids');
    }
    return($sample_ids);
}




=head2 get_expression_data_by_feature_ids

  $feature_sample_measurement_mapping = $obj->get_expression_data_by_feature_ids($feature_ids, $sample_type, $wild_type_only)

=over 4

=item Parameter and return types

=begin html

<pre>
$feature_ids is an ExpressionServices.feature_ids
$sample_type is an ExpressionServices.sample_type
$wild_type_only is an ExpressionServices.wild_type_only
$feature_sample_measurement_mapping is an ExpressionServices.feature_sample_measurement_mapping
feature_ids is a reference to a list where each element is an ExpressionServices.feature_id
feature_id is a string
sample_type is a string
wild_type_only is an int
feature_sample_measurement_mapping is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.sample_measurement_mapping
sample_measurement_mapping is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.measurement
sample_id is a string
measurement is a float

</pre>

=end html

=begin text

$feature_ids is an ExpressionServices.feature_ids
$sample_type is an ExpressionServices.sample_type
$wild_type_only is an ExpressionServices.wild_type_only
$feature_sample_measurement_mapping is an ExpressionServices.feature_sample_measurement_mapping
feature_ids is a reference to a list where each element is an ExpressionServices.feature_id
feature_id is a string
sample_type is a string
wild_type_only is an int
feature_sample_measurement_mapping is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.sample_measurement_mapping
sample_measurement_mapping is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.measurement
sample_id is a string
measurement is a float


=end text



=item Description

given a list of FeatureIDs, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
and an int indicating WildType Only (1 = true, 0 = false) returns a FeatureSampleMeasurementMapping: {featureID->{sample_id->measurement}}

=back

=cut

sub get_expression_data_by_feature_ids
{
    my $self = shift;
    my($feature_ids, $sample_type, $wild_type_only) = @_;

    my @_bad_arguments;
    (ref($feature_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"feature_ids\" (value was \"$feature_ids\")");
    (!ref($sample_type)) or push(@_bad_arguments, "Invalid type for argument \"sample_type\" (value was \"$sample_type\")");
    (!ref($wild_type_only)) or push(@_bad_arguments, "Invalid type for argument \"wild_type_only\" (value was \"$wild_type_only\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_data_by_feature_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_data_by_feature_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($feature_sample_measurement_mapping);
    #BEGIN get_expression_data_by_feature_ids
    $feature_sample_measurement_mapping = {};
    if (0 == @{$feature_ids}) 
    { 
        my $msg = "get_expression_data_by_feature_ids requires a list of valid feature ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_data_by_feature_ids'); 
    } 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
	);

    my $wild_type_part = ""; 
    if (($wild_type_only eq "1") || (uc($wild_type_only) eq "Y") || (uc($wild_type_only) eq "TRUE")) 
    { 
        $wild_type_part = " and str.wildType = 'Y' "; 
    } 
    my $sample_type_part = ""; 
    if ((uc($sample_type) eq "RNA-SEQ") || (uc($sample_type) eq "RNA_SEQ") || (uc($sample_type) eq "RNASEQ") || (uc($sample_type) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sample_type) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sample_type) eq "MICROARRAY") 
    { 
        $sample_type_part = " and sam.type = 'microarray' "; 
    } 
    elsif(uc($sample_type) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.   
    } 
    my $get_feature_log2level_q = qq^select sam.id, fea.id, mea.value  
                                     from Sample sam  
                                     inner join SampleMeasurements sms on sam.id = sms.from_link     
                                     inner join Measurement mea on sms.to_link = mea.id 
                                     inner join FeatureMeasuredBy fmb on mea.id = fmb.to_link 
                                     inner join kbase_sapling_v1.Feature fea on fmb.from_link = fea.id 
                                     inner join StrainWithSample sws on sam.id = sws.to_link 
                                     inner join Strain str on sws.from_link = str.id  
                                     where fea.id in (^.
                                 join(",", ("?") x @{$feature_ids}). ") ". 
                                 $wild_type_part . 
                                 $sample_type_part; 
    my $get_feature_log2level_qh = $dbh->prepare($get_feature_log2level_q) or die "Unable to prepare get_feature_log2level_q : ".
	$get_feature_log2level_q . " : " .$dbh->errstr();
    $get_feature_log2level_qh->execute(@{$feature_ids})  or die "Unable to execute get_feature_log2level_q : ".
        $get_feature_log2level_q . " : " .$get_feature_log2level_qh->errstr(); 
    while(my ($sample_id,$feature_id,$log2level) = $get_feature_log2level_qh->fetchrow_array())
    {
	$feature_sample_measurement_mapping->{$feature_id}->{$sample_id}=$log2level;
    }
    #END get_expression_data_by_feature_ids
    my @_bad_returns;
    (ref($feature_sample_measurement_mapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"feature_sample_measurement_mapping\" (value was \"$feature_sample_measurement_mapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_data_by_feature_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_data_by_feature_ids');
    }
    return($feature_sample_measurement_mapping);
}




=head2 compare_samples

  $sample_comparison_mapping = $obj->compare_samples($numerators_data_mapping, $denominators_data_mapping)

=over 4

=item Parameter and return types

=begin html

<pre>
$numerators_data_mapping is an ExpressionServices.label_data_mapping
$denominators_data_mapping is an ExpressionServices.label_data_mapping
$sample_comparison_mapping is an ExpressionServices.sample_comparison_mapping
label_data_mapping is a reference to a hash where the key is a string and the value is an ExpressionServices.data_expression_levels_for_sample
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float
sample_comparison_mapping is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.denominator_sample_comparison
sample_id is a string
denominator_sample_comparison is a reference to a hash where the key is an ExpressionServices.comparison_denominator_label and the value is an ExpressionServices.data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.log2_ratio
log2_ratio is a float

</pre>

=end html

=begin text

$numerators_data_mapping is an ExpressionServices.label_data_mapping
$denominators_data_mapping is an ExpressionServices.label_data_mapping
$sample_comparison_mapping is an ExpressionServices.sample_comparison_mapping
label_data_mapping is a reference to a hash where the key is a string and the value is an ExpressionServices.data_expression_levels_for_sample
data_expression_levels_for_sample is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
feature_id is a string
measurement is a float
sample_comparison_mapping is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.denominator_sample_comparison
sample_id is a string
denominator_sample_comparison is a reference to a hash where the key is an ExpressionServices.comparison_denominator_label and the value is an ExpressionServices.data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.log2_ratio
log2_ratio is a float


=end text



=item Description

Compare samples takes two data structures labelDataMapping  {sampleID or label}->{featureId or label => value}}, 
the first labelDataMapping is the numerator, the 2nd is the denominator in the comparison. returns a 
SampleComparisonMapping {numerator_sample_id(or label)->{denominator_sample_id(or label)->{feature_id(or label) -> log2Ratio}}}

=back

=cut

sub compare_samples
{
    my $self = shift;
    my($numerators_data_mapping, $denominators_data_mapping) = @_;

    my @_bad_arguments;
    (ref($numerators_data_mapping) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"numerators_data_mapping\" (value was \"$numerators_data_mapping\")");
    (ref($denominators_data_mapping) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"denominators_data_mapping\" (value was \"$denominators_data_mapping\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to compare_samples:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($sample_comparison_mapping);
    #BEGIN compare_samples
    $sample_comparison_mapping = {};
    my @numerator_keys = keys(%{$numerators_data_mapping});
    my @denominator_keys = keys(%{$denominators_data_mapping});
    if ((0 == scalar(@numerator_keys)) || (0 == scalar(@denominator_keys)))
    { 
	my $msg = "The numerator and/or denominator keys passed to compare_samples are empty \n";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples'); 
    } 
    my %empty_numerator_keys;
    my %empty_denominator_keys;
    foreach my $numerator_key (@numerator_keys)
    {
	if(scalar(keys(%{$numerators_data_mapping->{$numerator_key}})) == 0)
	{
	    $empty_numerator_keys{$numerator_key} = 1;
	}
    }
    foreach my $denominator_key (@denominator_keys)
    {
        if(scalar(keys(%{$denominators_data_mapping->{$denominator_key}})) == 0)
        {
            $empty_denominator_keys{$denominator_key} = 1;
        }
    }
    if ((scalar(keys(%empty_numerator_keys)) > 0) ||
	(scalar(keys(%empty_denominator_keys)) > 0))
    {
	my $msg = "The numerator and/or denominator keys passed had the following empty subhashes:\n";
	if (scalar(keys(%empty_numerator_keys)) > 0)
	{
	    $msg .= "NUMERATOR SUBHASHES : \n";
	    foreach my $numerator_key (keys(%empty_numerator_keys))
	    {
		$msg .= $numerator_key . "\n";
	    }
	}
        if (scalar(keys(%empty_denominator_keys)) > 0)
        {
            $msg .= "DENOMINATOR SUBHASHES : \n";
            foreach my $denominator_key (keys(%empty_denominator_keys))
            {
                $msg .= $denominator_key . "\n";
            } 
        }
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples');
    }

    #Create average of denominator_values
    my %denominator_average_hash;  #feature_id -> {running_total->val, count->val}

    foreach my $denominator_key (@denominator_keys)
    {
	foreach my $feature_id (keys(%{$denominators_data_mapping->{$denominator_key}}))
	{
	    if(exists($denominator_average_hash{$feature_id})) #add to values
	    {
		$denominator_average_hash{$feature_id}{'running_total'} = $denominator_average_hash{$feature_id}{'running_total'} + 
		    $denominators_data_mapping->{$denominator_key}->{$feature_id} ;
		$denominator_average_hash{$feature_id}{'count'} = $denominator_average_hash{$feature_id}{'count'} + 1;
	    }
	    else #initialize values
	    {
		$denominator_average_hash{$feature_id}{'running_total'} = $denominators_data_mapping->{$denominator_key}->{$feature_id} ;
		$denominator_average_hash{$feature_id}{'count'} = 1;
	    }
	}
    }
    foreach my $feature_id (keys(%denominator_average_hash)) 
    { 
        $denominator_average_hash{$feature_id}{'average'} = $denominator_average_hash{$feature_id}{'running_total'} / 
            $denominator_average_hash{$feature_id}{'count'}; 
    } 
    my $final_denominator_key; 
    if (scalar(@denominator_keys) == 1) 
    { 
        $final_denominator_key = $denominator_keys[0];
    } 
    else 
    { 
        $final_denominator_key = "Average of samples : ". join (", ",sort(@denominator_keys));
    } 
    #Generate comparisons vs the average.
    foreach my $numerator_key (@numerator_keys)
    {
	foreach my $feature_id (keys(%{$numerators_data_mapping->{$numerator_key}}))
	{
	    if (exists($denominator_average_hash{$feature_id}->{'average'}))
	    {
		$sample_comparison_mapping->{$numerator_key}->{$final_denominator_key}->{$feature_id} = 
		    $numerators_data_mapping->{$numerator_key}->{$feature_id} - 
		    $denominator_average_hash{$feature_id}->{'average'};
	    }
	}
    }
    #END compare_samples
    my @_bad_returns;
    (ref($sample_comparison_mapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"sample_comparison_mapping\" (value was \"$sample_comparison_mapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to compare_samples:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples');
    }
    return($sample_comparison_mapping);
}




=head2 compare_samples_vs_default_controls

  $sample_comparison_mapping = $obj->compare_samples_vs_default_controls($numerator_sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$numerator_sample_ids is an ExpressionServices.sample_ids
$sample_comparison_mapping is an ExpressionServices.sample_comparison_mapping
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
sample_comparison_mapping is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.denominator_sample_comparison
denominator_sample_comparison is a reference to a hash where the key is an ExpressionServices.comparison_denominator_label and the value is an ExpressionServices.data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.log2_ratio
feature_id is a string
log2_ratio is a float

</pre>

=end html

=begin text

$numerator_sample_ids is an ExpressionServices.sample_ids
$sample_comparison_mapping is an ExpressionServices.sample_comparison_mapping
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
sample_comparison_mapping is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.denominator_sample_comparison
denominator_sample_comparison is a reference to a hash where the key is an ExpressionServices.comparison_denominator_label and the value is an ExpressionServices.data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.log2_ratio
feature_id is a string
log2_ratio is a float


=end text



=item Description

Compares each sample vs its defined default control.  If the Default control is not specified for a sample, then nothing is returned for that sample .
Takes a list of sampleIDs returns SampleComparisonMapping {sample_id ->{denominator_default_control sample_id ->{feature_id -> log2Ratio}}}

=back

=cut

sub compare_samples_vs_default_controls
{
    my $self = shift;
    my($numerator_sample_ids) = @_;

    my @_bad_arguments;
    (ref($numerator_sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"numerator_sample_ids\" (value was \"$numerator_sample_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to compare_samples_vs_default_controls:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples_vs_default_controls');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($sample_comparison_mapping);
    #BEGIN compare_samples_vs_default_controls
    $sample_comparison_mapping = {};
    if (scalar(@{$numerator_sample_ids} == 0)) 
    { 
        my $msg = "compare_samples_vs_default_controls requires a list of valid sample ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'compare_samples_vs_default_controls'); 
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 

    my $get_default_sample_ids_q = qq^select to_link as num_sample_id, from_link as control_sample_id 
                                      from DefaultControlSample
                                      where to_link in (^.
                                   join(",", ("?") x @{$numerator_sample_ids}). ") "; 
    my $get_default_sample_ids_qh = $dbh->prepare($get_default_sample_ids_q) or die "Unable to prepare get_default_sample_ids_q : ".
	$get_default_sample_ids_q , " : " . $dbh->errstr();
    $get_default_sample_ids_qh->execute(@{$numerator_sample_ids})  or die "Unable to execute get_default_sample_ids_q : ".
        $get_default_sample_ids_q , " : " . $get_default_sample_ids_qh->errstr();
    my %distinct_sample_ids_hash;
    my %numerator_control_mappings;
    while (my ($numerator_sample_id,$control_sample_id) = $get_default_sample_ids_qh->fetchrow_array())
    {
	$distinct_sample_ids_hash{$numerator_sample_id} = 1;
	$distinct_sample_ids_hash{$control_sample_id} = 1;
	$numerator_control_mappings{$numerator_sample_id} = $control_sample_id;
    }
    if (scalar(keys(%distinct_sample_ids_hash)) == 0)
    {
	return $sample_comparison_mapping;
    }
    #log2Levels
    my $get_log2levels_q = qq^select sam.id, fea.id, mea.value
                              from Sample sam 
                              inner join SampleMeasurements sme on sam.id = sme.from_link 
                              inner join Measurement mea on sme.to_link = mea.id  
                              inner join FeatureMeasuredBy fmb on mea.id = fmb.to_link 
                              inner join kbase_sapling_v1.Feature fea on fmb.from_link = fea.id  
                              where sam.id in (^. 
			      join(",", ("?") x scalar(keys(%distinct_sample_ids_hash))) . ") "; 
    my $get_log2levels_qh = $dbh->prepare($get_log2levels_q) or die "Unable to prepare get_log2levels_q : ".
	$get_log2levels_q . " : " . $dbh->errstr(); 
    $get_log2levels_qh->execute(keys(%distinct_sample_ids_hash)) or die "Unable to execute get_log2levels_q : " . $get_log2levels_q . " : ".
	$get_log2levels_qh->errstr(); 
    my %sample_data_hash; # key $sample_id -> {$feature_id => value}
    while(my ($sample_id, $feature_id, $log2level) = $get_log2levels_qh->fetchrow_array())
    { 
        $sample_data_hash{$sample_id}{$feature_id} = $log2level;
    }
    
    foreach my $numerator_sample_id (keys(%numerator_control_mappings))
    {
	my $temp_num_hash->{$numerator_sample_id}=$sample_data_hash{$numerator_sample_id};
	my $temp_control_hash->{$numerator_control_mappings{$numerator_sample_id}} = 
	    $sample_data_hash{$numerator_control_mappings{$numerator_sample_id}};
	my $temp_comparison_hash_ref = $self->compare_samples($temp_num_hash,$temp_control_hash);	
	$sample_comparison_mapping->{$numerator_sample_id}->{$numerator_control_mappings{$numerator_sample_id}} = 
	    $temp_comparison_hash_ref->{$numerator_sample_id}->{$numerator_control_mappings{$numerator_sample_id}};
    }
    #END compare_samples_vs_default_controls
    my @_bad_returns;
    (ref($sample_comparison_mapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"sample_comparison_mapping\" (value was \"$sample_comparison_mapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to compare_samples_vs_default_controls:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples_vs_default_controls');
    }
    return($sample_comparison_mapping);
}




=head2 compare_samples_vs_the_average

  $sample_comparison_mapping = $obj->compare_samples_vs_the_average($numerator_sample_ids, $denominator_sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$numerator_sample_ids is an ExpressionServices.sample_ids
$denominator_sample_ids is an ExpressionServices.sample_ids
$sample_comparison_mapping is an ExpressionServices.sample_comparison_mapping
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
sample_comparison_mapping is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.denominator_sample_comparison
denominator_sample_comparison is a reference to a hash where the key is an ExpressionServices.comparison_denominator_label and the value is an ExpressionServices.data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.log2_ratio
feature_id is a string
log2_ratio is a float

</pre>

=end html

=begin text

$numerator_sample_ids is an ExpressionServices.sample_ids
$denominator_sample_ids is an ExpressionServices.sample_ids
$sample_comparison_mapping is an ExpressionServices.sample_comparison_mapping
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
sample_comparison_mapping is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.denominator_sample_comparison
denominator_sample_comparison is a reference to a hash where the key is an ExpressionServices.comparison_denominator_label and the value is an ExpressionServices.data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.log2_ratio
feature_id is a string
log2_ratio is a float


=end text



=item Description

Compares each numerator sample vs the average of all the denominator sampleIds.  Take a list of numerator sample IDs and a list of samples Ids to average for the denominator.
returns SampleComparisonMapping {numerator_sample_id->{denominator_sample_id ->{feature_id -> log2Ratio}}}

=back

=cut

sub compare_samples_vs_the_average
{
    my $self = shift;
    my($numerator_sample_ids, $denominator_sample_ids) = @_;

    my @_bad_arguments;
    (ref($numerator_sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"numerator_sample_ids\" (value was \"$numerator_sample_ids\")");
    (ref($denominator_sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"denominator_sample_ids\" (value was \"$denominator_sample_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to compare_samples_vs_the_average:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples_vs_the_average');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($sample_comparison_mapping);
    #BEGIN compare_samples_vs_the_average
    if((scalar(@{$numerator_sample_ids}) == 0) || (scalar(@{$denominator_sample_ids}) == 0))
    { 
	my $msg = "A list of valid sample ids must be present for both the numerator and denominator\n";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
							 method_name => 'compare_samples_vs_average');
    } 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
    my %distinct_sample_ids_hash; 
    my %numerator_sample_ids_hash; 
    my %denominator_sample_ids_hash; 
    foreach my $numerator_sample_id (@{$numerator_sample_ids})
    {
	$numerator_sample_ids_hash{$numerator_sample_id} = 1;
	$distinct_sample_ids_hash{$numerator_sample_id} = 1;
    }
    foreach my $denominator_sample_id (@{$denominator_sample_ids})
    {
        $denominator_sample_ids_hash{$denominator_sample_id} = 1;
        $distinct_sample_ids_hash{$denominator_sample_id} = 1;
    } 
    #log2Levels                                                                     
    my $get_log2levels_q = qq^select sam.id, fea.id, mea.value              
                              from Sample sam                                  
                              inner join SampleMeasurements sme on sam.id = sme.from_link       
                              inner join Measurement mea on sme.to_link = mea.id                         
                              inner join FeatureMeasuredBy fmb on mea.id = fmb.to_link              
                              inner join kbase_sapling_v1.Feature fea on fmb.from_link = fea.id                    
                              where sam.id in (^. 
                              join(",", ("?") x scalar(keys(%distinct_sample_ids_hash))) . ") "; 
    my $get_log2levels_qh = $dbh->prepare($get_log2levels_q) or die "Unable to prepare get_log2levels_q : ". 
        $get_log2levels_q . " : " . $dbh->errstr(); 
    $get_log2levels_qh->execute(keys(%distinct_sample_ids_hash)) or 
	die "Unable to execute get_log2levels_q : " . $get_log2levels_q . " : ". 
	$get_log2levels_qh->errstr(); 
    my %sample_data_hash; # key $sample_id -> {$feature_id => value}               
    while(my ($sample_id, $feature_id, $log2level) = $get_log2levels_qh->fetchrow_array()) 
    { 
        $sample_data_hash{$sample_id}{$feature_id} = $log2level; 
    } 
    my %numerator_parameter_hash;
    my %denominator_parameter_hash;
    foreach my $sample_id (keys(%sample_data_hash))
    {
	if (exists($numerator_sample_ids_hash{$sample_id}))
	{
	    $numerator_parameter_hash{$sample_id}=$sample_data_hash{$sample_id};
	}
        if (exists($denominator_sample_ids_hash{$sample_id}))
        {
            $denominator_parameter_hash{$sample_id}=$sample_data_hash{$sample_id};
        } 
    }
    $sample_comparison_mapping = $self->compare_samples(\%numerator_parameter_hash,\%denominator_parameter_hash); 
    #END compare_samples_vs_the_average
    my @_bad_returns;
    (ref($sample_comparison_mapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"sample_comparison_mapping\" (value was \"$sample_comparison_mapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to compare_samples_vs_the_average:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples_vs_the_average');
    }
    return($sample_comparison_mapping);
}




=head2 get_on_off_calls

  $on_off_mappings = $obj->get_on_off_calls($sample_comparison_mapping, $off_threshold, $on_threshold)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_comparison_mapping is an ExpressionServices.sample_comparison_mapping
$off_threshold is a float
$on_threshold is a float
$on_off_mappings is an ExpressionServices.sample_comparison_mapping
sample_comparison_mapping is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.denominator_sample_comparison
sample_id is a string
denominator_sample_comparison is a reference to a hash where the key is an ExpressionServices.comparison_denominator_label and the value is an ExpressionServices.data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.log2_ratio
feature_id is a string
log2_ratio is a float

</pre>

=end html

=begin text

$sample_comparison_mapping is an ExpressionServices.sample_comparison_mapping
$off_threshold is a float
$on_threshold is a float
$on_off_mappings is an ExpressionServices.sample_comparison_mapping
sample_comparison_mapping is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.denominator_sample_comparison
sample_id is a string
denominator_sample_comparison is a reference to a hash where the key is an ExpressionServices.comparison_denominator_label and the value is an ExpressionServices.data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.log2_ratio
feature_id is a string
log2_ratio is a float


=end text



=item Description

Takes in comparison results.  If the value is >= on_threshold it is deemed on (1), if <= off_threshold it is off(-1), meets none then 0.  Thresholds normally set to zero.
returns SampleComparisonMapping {numerator_sample_id(or label)->{denominator_sample_id(or label)->{feature_id(or label) -> on_off_call (possible values 0,-1,1)}}}

=back

=cut

sub get_on_off_calls
{
    my $self = shift;
    my($sample_comparison_mapping, $off_threshold, $on_threshold) = @_;

    my @_bad_arguments;
    (ref($sample_comparison_mapping) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"sample_comparison_mapping\" (value was \"$sample_comparison_mapping\")");
    (!ref($off_threshold)) or push(@_bad_arguments, "Invalid type for argument \"off_threshold\" (value was \"$off_threshold\")");
    (!ref($on_threshold)) or push(@_bad_arguments, "Invalid type for argument \"on_threshold\" (value was \"$on_threshold\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_on_off_calls:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_on_off_calls');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($on_off_mappings);
    #BEGIN get_on_off_calls
    if (scalar(keys(%{$sample_comparison_mapping})) == 0)
    {
        my $msg = "The sampleComparisonMapping (1st argument, the hash was empty)";	 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
							     method_name => 'get_on_off_calls'); 
    }
    #Check that thresholds are numbers or empty 
    if ($on_threshold ne '')
    {
	if(!($on_threshold =~ m/^[-+]?[0-9]*\.?[0-9]+$/))
	{ 
	    my $msg = "The on threshold must be a valid number";
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
								   method_name => 'get_on_off_calls');
	} 
    }
    else
    {
	$on_threshold = 0;
    }
    if ($off_threshold ne '')
    {
	if(!($off_threshold =~ m/^[-+]?[0-9]*\.?[0-9]+$/))
	{
	    my $msg = "The off threshold must be a valid number";
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
								   method_name => 'get_on_off_calls'); 
	} 
    }
    else
    {
	$off_threshold = 0;
    }
    if ($on_threshold < $off_threshold)
    {
        my $msg = "The on_threshold must >= the off_threshold"; 
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_on_off_calls'); 	
    }
    foreach my $numerator_key (keys(%{$sample_comparison_mapping}))
    {
	foreach my $denominator_key (keys(%{$sample_comparison_mapping->{$numerator_key}}))
	{
	    foreach my $feature_id (keys(%{$sample_comparison_mapping->{$numerator_key}->{$denominator_key}}))
	    {
		my $tested_value = $sample_comparison_mapping->{$numerator_key}->{$denominator_key}->{$feature_id};
		my $call = 0;
		if ($tested_value >= $on_threshold)
		{
		    $call = 1;
		}
		elsif ($tested_value < $off_threshold)
		{
		    $call = -1;
		}
		$on_off_mappings->{$numerator_key}->{$denominator_key}->{$feature_id} = $call;
	    }
	}
    }
    #END get_on_off_calls
    my @_bad_returns;
    (ref($on_off_mappings) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"on_off_mappings\" (value was \"$on_off_mappings\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_on_off_calls:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_on_off_calls');
    }
    return($on_off_mappings);
}




=head2 get_top_changers

  $top_changers_mappings = $obj->get_top_changers($sample_comparison_mapping, $direction, $count)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_comparison_mapping is an ExpressionServices.sample_comparison_mapping
$direction is a string
$count is an int
$top_changers_mappings is an ExpressionServices.sample_comparison_mapping
sample_comparison_mapping is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.denominator_sample_comparison
sample_id is a string
denominator_sample_comparison is a reference to a hash where the key is an ExpressionServices.comparison_denominator_label and the value is an ExpressionServices.data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.log2_ratio
feature_id is a string
log2_ratio is a float

</pre>

=end html

=begin text

$sample_comparison_mapping is an ExpressionServices.sample_comparison_mapping
$direction is a string
$count is an int
$top_changers_mappings is an ExpressionServices.sample_comparison_mapping
sample_comparison_mapping is a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.denominator_sample_comparison
sample_id is a string
denominator_sample_comparison is a reference to a hash where the key is an ExpressionServices.comparison_denominator_label and the value is an ExpressionServices.data_sample_comparison
comparison_denominator_label is a string
data_sample_comparison is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.log2_ratio
feature_id is a string
log2_ratio is a float


=end text



=item Description

Takes in comparison results. Direction must equal 'up', 'down', or 'both'.  Count is the number of changers returned in each direction.
returns SampleComparisonMapping {numerator_sample_id(or label)->{denominator_sample_id(or label)->{feature_id(or label) -> log2Ratio (note that the features listed will be limited to the top changers)}}}

=back

=cut

sub get_top_changers
{
    my $self = shift;
    my($sample_comparison_mapping, $direction, $count) = @_;

    my @_bad_arguments;
    (ref($sample_comparison_mapping) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"sample_comparison_mapping\" (value was \"$sample_comparison_mapping\")");
    (!ref($direction)) or push(@_bad_arguments, "Invalid type for argument \"direction\" (value was \"$direction\")");
    (!ref($count)) or push(@_bad_arguments, "Invalid type for argument \"count\" (value was \"$count\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_top_changers:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_top_changers');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($top_changers_mappings);
    #BEGIN get_top_changers
    if (scalar(keys(%{$sample_comparison_mapping})) == 0) 
    { 
        my $msg = "The sample_comparison_mapping (1st argument, the hash was empty)"; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_top_changers'); 
    } 
    if (!((uc($direction) eq 'UP') || 
	  (uc($direction) eq 'DOWN') || 
	  (uc($direction) eq 'BOTH')))
    { 
        my $msg = "The Direction (2nd argument) must be equal to 'UP','DOWN', or 'BOTH'"; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_top_changers'); 
    } 
    if(!($count =~ m/^\d+$/))
    {
        my $msg = "The count of top changers returned has to be a positive integer";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_top_changers'); 
    }
    foreach my $numerator_key (keys(%{$sample_comparison_mapping}))
    { 
        foreach my $denominator_key (keys(%{$sample_comparison_mapping->{$numerator_key}}))
        { 
	    my %data_hash = %{$sample_comparison_mapping->{$numerator_key}->{$denominator_key}};
	    if ((uc($direction) eq 'UP') || (uc($direction) eq 'BOTH'))
	    {
		#get top up changers
		my $counter = 0;
		foreach my $feature_id(sort {$data_hash{$b} <=> $data_hash{$a}} (keys %data_hash))
		{
		    if ($counter < $count)
		    {
			$top_changers_mappings->{$numerator_key}->{$denominator_key}->{$feature_id} = 
			    $data_hash{$feature_id};
		    }
		    else {last;}
		    $counter++;
		}
	    }
            if ((uc($direction) eq 'DOWN') || (uc($direction) eq 'BOTH')) 
            {
                #get top down changers                                         
                my $counter = 0;
                foreach my $feature_id(sort {$data_hash{$a} <=> $data_hash{$b}} (keys %data_hash))
                { 
                    if ($counter < $count)
                    {
                        $top_changers_mappings->{$numerator_key}->{$denominator_key}->{$feature_id} = 
                            $data_hash{$feature_id};
                    } 
                    else {last;}
		    $counter++;
                } 
            } 
        } 
    }     
    #END get_top_changers
    my @_bad_returns;
    (ref($top_changers_mappings) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"top_changers_mappings\" (value was \"$top_changers_mappings\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_top_changers:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_top_changers');
    }
    return($top_changers_mappings);
}




=head2 get_expression_samples_titles

  $samples_titles_map = $obj->get_expression_samples_titles($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is an ExpressionServices.sample_ids
$samples_titles_map is an ExpressionServices.samples_string_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is a string

</pre>

=end html

=begin text

$sample_ids is an ExpressionServices.sample_ids
$samples_titles_map is an ExpressionServices.samples_string_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is a string


=end text



=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: Title of Sample)

=back

=cut

sub get_expression_samples_titles
{
    my $self = shift;
    my($sample_ids) = @_;

    my @_bad_arguments;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_titles:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_titles');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($samples_titles_map);
    #BEGIN get_expression_samples_titles
    $samples_titles_map = {}; 
    if (0 == @{$sample_ids}) 
    { 
        my $msg = "get_expression_samples_titles requires a list of valid sample ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_samples_titles'); 
    } 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
	); 
    my $get_samples_titles_q = qq^select id, title from Sample where id in (^.
				    join(",", ("?") x @{$sample_ids}) . ") "; 
    my $get_samples_titles_qh = $dbh->prepare($get_samples_titles_q) or die "Unable to prepare : get_samples_titles_q : ". 
	$get_samples_titles_q . " : " .$dbh->errstr(); 
    $get_samples_titles_qh->execute(@{$sample_ids}) or die "Unable to execute : get_samples_titles_q : ".$get_samples_titles_qh->errstr(); 
    while (my ($sample_id, $title) = $get_samples_titles_qh->fetchrow_array())
    {
	$samples_titles_map->{$sample_id} = $title;
    }
    #END get_expression_samples_titles
    my @_bad_returns;
    (ref($samples_titles_map) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"samples_titles_map\" (value was \"$samples_titles_map\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_titles:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_titles');
    }
    return($samples_titles_map);
}




=head2 get_expression_samples_descriptions

  $samples_descriptions_map = $obj->get_expression_samples_descriptions($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is an ExpressionServices.sample_ids
$samples_descriptions_map is an ExpressionServices.samples_string_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is a string

</pre>

=end html

=begin text

$sample_ids is an ExpressionServices.sample_ids
$samples_descriptions_map is an ExpressionServices.samples_string_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is a string


=end text



=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: Description of Sample)

=back

=cut

sub get_expression_samples_descriptions
{
    my $self = shift;
    my($sample_ids) = @_;

    my @_bad_arguments;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_descriptions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_descriptions');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($samples_descriptions_map);
    #BEGIN get_expression_samples_descriptions
    $samples_descriptions_map = {}; 
    if (0 == @{$sample_ids})
    { 
        my $msg = "get_expression_samples_descriptions requires a list of valid sample ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_samples_descriptions');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_samples_descriptions_q = qq^select id, description from Sample where id in (^.
	join(",", ("?") x @{$sample_ids}) . ") "; 
    my $get_samples_descriptions_qh = $dbh->prepare($get_samples_descriptions_q) or die "Unable to prepare : get_samples_descriptions_q : ".
        $get_samples_descriptions_q . " : " .$dbh->errstr(); 
    $get_samples_descriptions_qh->execute(@{$sample_ids}) or die "Unable to execute : get_samples_descriptions_q : ".$get_samples_descriptions_qh->errstr();
    while (my ($sample_id, $description) = $get_samples_descriptions_qh->fetchrow_array())
    { 
        $samples_descriptions_map->{$sample_id} = $description;
    } 
    #END get_expression_samples_descriptions
    my @_bad_returns;
    (ref($samples_descriptions_map) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"samples_descriptions_map\" (value was \"$samples_descriptions_map\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_descriptions:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_descriptions');
    }
    return($samples_descriptions_map);
}




=head2 get_expression_samples_molecules

  $samples_molecules_map = $obj->get_expression_samples_molecules($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is an ExpressionServices.sample_ids
$samples_molecules_map is an ExpressionServices.samples_string_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is a string

</pre>

=end html

=begin text

$sample_ids is an ExpressionServices.sample_ids
$samples_molecules_map is an ExpressionServices.samples_string_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is a string


=end text



=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: Molecule of Sample)

=back

=cut

sub get_expression_samples_molecules
{
    my $self = shift;
    my($sample_ids) = @_;

    my @_bad_arguments;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_molecules:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_molecules');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($samples_molecules_map);
    #BEGIN get_expression_samples_molecules
    $samples_molecules_map = {}; 
    if (0 == @{$sample_ids})
    { 
        my $msg = "get_expression_samples_molecules requires a list of valid sample ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_samples_molecules');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_samples_molecules_q = qq^select id, molecule from Sample where id in (^.
	join(",", ("?") x @{$sample_ids}) . ") "; 
    my $get_samples_molecules_qh = $dbh->prepare($get_samples_molecules_q) or die "Unable to prepare : get_samples_molecules_q : ".
        $get_samples_molecules_q . " : " .$dbh->errstr(); 
    $get_samples_molecules_qh->execute(@{$sample_ids}) or die "Unable to execute : get_samples_molecules_q : ".$get_samples_molecules_qh->errstr();
    while (my ($sample_id, $molecule) = $get_samples_molecules_qh->fetchrow_array())
    { 
        $samples_molecules_map->{$sample_id} = $molecule;
    } 
    #END get_expression_samples_molecules
    my @_bad_returns;
    (ref($samples_molecules_map) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"samples_molecules_map\" (value was \"$samples_molecules_map\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_molecules:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_molecules');
    }
    return($samples_molecules_map);
}




=head2 get_expression_samples_types

  $samples_types_map = $obj->get_expression_samples_types($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is an ExpressionServices.sample_ids
$samples_types_map is an ExpressionServices.samples_string_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is a string

</pre>

=end html

=begin text

$sample_ids is an ExpressionServices.sample_ids
$samples_types_map is an ExpressionServices.samples_string_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is a string


=end text



=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: Type of Sample)

=back

=cut

sub get_expression_samples_types
{
    my $self = shift;
    my($sample_ids) = @_;

    my @_bad_arguments;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_types:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_types');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($samples_types_map);
    #BEGIN get_expression_samples_types
    $samples_types_map = {}; 
    if (0 == @{$sample_ids})
    { 
        my $msg = "get_expression_samples_types requires a list of valid sample ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_samples_types');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_samples_types_q = qq^select id, type from Sample where id in (^.
	join(",", ("?") x @{$sample_ids}) . ") "; 
    my $get_samples_types_qh = $dbh->prepare($get_samples_types_q) or die "Unable to prepare : get_samples_types_q : ".
        $get_samples_types_q . " : " .$dbh->errstr(); 
    $get_samples_types_qh->execute(@{$sample_ids}) or die "Unable to execute : get_samples_types_q : ".$get_samples_types_qh->errstr();
    while (my ($sample_id, $type) = $get_samples_types_qh->fetchrow_array())
    { 
        $samples_types_map->{$sample_id} = $type;
    } 
    #END get_expression_samples_types
    my @_bad_returns;
    (ref($samples_types_map) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"samples_types_map\" (value was \"$samples_types_map\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_types:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_types');
    }
    return($samples_types_map);
}




=head2 get_expression_samples_external_source_ids

  $samples_external_source_id_map = $obj->get_expression_samples_external_source_ids($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is an ExpressionServices.sample_ids
$samples_external_source_id_map is an ExpressionServices.samples_string_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is a string

</pre>

=end html

=begin text

$sample_ids is an ExpressionServices.sample_ids
$samples_external_source_id_map is an ExpressionServices.samples_string_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
samples_string_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is a string


=end text



=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: External_Source_ID of Sample (typically GSM))

=back

=cut

sub get_expression_samples_external_source_ids
{
    my $self = shift;
    my($sample_ids) = @_;

    my @_bad_arguments;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_external_source_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($samples_external_source_id_map);
    #BEGIN get_expression_samples_external_source_ids
    $samples_external_source_id_map = {}; 
    if (0 == @{$sample_ids})
    { 
        my $msg = "get_expression_samples_external_source_ids requires a list of valid sample ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_samples_external_source_ids');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_samples_ex_id_q = qq^select id, externalSourceId from Sample where id in (^.
	join(",", ("?") x @{$sample_ids}) . ") "; 
    my $get_samples_ex_id_qh = $dbh->prepare($get_samples_ex_id_q) or die "Unable to prepare : get_samples_ex_id_q : ".
        $get_samples_ex_id_q . " : " .$dbh->errstr(); 
    $get_samples_ex_id_qh->execute(@{$sample_ids}) or die "Unable to execute : get_samples_ex_id_q : ".$get_samples_ex_id_qh->errstr();
    while (my ($sample_id, $ex_id) = $get_samples_ex_id_qh->fetchrow_array())
    { 
        $samples_external_source_id_map->{$sample_id} = $ex_id;
    } 
    #END get_expression_samples_external_source_ids
    my @_bad_returns;
    (ref($samples_external_source_id_map) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"samples_external_source_id_map\" (value was \"$samples_external_source_id_map\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_external_source_ids');
    }
    return($samples_external_source_id_map);
}




=head2 get_expression_samples_original_log2_medians

  $samples_float_map = $obj->get_expression_samples_original_log2_medians($sample_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$sample_ids is an ExpressionServices.sample_ids
$samples_float_map is an ExpressionServices.samples_float_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
samples_float_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is a float

</pre>

=end html

=begin text

$sample_ids is an ExpressionServices.sample_ids
$samples_float_map is an ExpressionServices.samples_float_map
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string
samples_float_map is a reference to a hash where the key is an ExpressionServices.sample_id and the value is a float


=end text



=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: OriginalLog2Median of Sample)

=back

=cut

sub get_expression_samples_original_log2_medians
{
    my $self = shift;
    my($sample_ids) = @_;

    my @_bad_arguments;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_original_log2_medians:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_original_log2_medians');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($samples_float_map);
    #BEGIN get_expression_samples_original_log2_medians
    $samples_float_map = {}; 
    if (0 == @{$sample_ids})
    { 
        my $msg = "get_expression_samples_original_log2_medians requires a list of valid sample ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_samples_original_log2_medians');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_samples_olog2_q = qq^select id, originalLog2Median from Sample where id in (^.
	join(",", ("?") x @{$sample_ids}) . ") ";
    my $get_samples_olog2_qh = $dbh->prepare($get_samples_olog2_q) or die "Unable to prepare : get_samples_olog2_q : ".
        $get_samples_olog2_q . " : " .$dbh->errstr();
    $get_samples_olog2_qh->execute(@{$sample_ids}) or die "Unable to execute : get_samples_olog2_q : ".$get_samples_olog2_qh->errstr();
    while (my ($sample_id, $olog2) = $get_samples_olog2_qh->fetchrow_array()) 
    { 
        $samples_float_map->{$sample_id} = $olog2; 
    } 

    #END get_expression_samples_original_log2_medians
    my @_bad_returns;
    (ref($samples_float_map) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"samples_float_map\" (value was \"$samples_float_map\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_original_log2_medians:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_original_log2_medians');
    }
    return($samples_float_map);
}




=head2 get_expression_series_titles

  $series_string_map = $obj->get_expression_series_titles($series_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$series_ids is an ExpressionServices.series_ids
$series_string_map is an ExpressionServices.series_string_map
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
series_string_map is a reference to a hash where the key is an ExpressionServices.series_id and the value is a string

</pre>

=end html

=begin text

$series_ids is an ExpressionServices.series_ids
$series_string_map is an ExpressionServices.series_string_map
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
series_string_map is a reference to a hash where the key is an ExpressionServices.series_id and the value is a string


=end text



=item Description

given a List of SeriesIDs, returns a Hash (key : SeriesID, value: Title of Series)

=back

=cut

sub get_expression_series_titles
{
    my $self = shift;
    my($series_ids) = @_;

    my @_bad_arguments;
    (ref($series_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"series_ids\" (value was \"$series_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_series_titles:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_titles');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($series_string_map);
    #BEGIN get_expression_series_titles
    $series_string_map = {}; 
    if (0 == @{$series_ids})
    { 
        my $msg = "get_expression_series_titles requires a list of valid series ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_series_titles');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_series_info_q = qq^select id, title from Series where id in (^.
        join(",", ("?") x @{$series_ids}) . ") ";
    my $get_series_info_qh = $dbh->prepare($get_series_info_q) or die "Unable to prepare : get_series_info_q : ".
        $get_series_info_q . " : " .$dbh->errstr();
    $get_series_info_qh->execute(@{$series_ids}) or die "Unable to execute : get_series_info_q : ".$get_series_info_qh->errstr();
    while (my ($series_id, $info) = $get_series_info_qh->fetchrow_array()) 
    { 
        $series_string_map->{$series_id} = $info; 
    } 
    #END get_expression_series_titles
    my @_bad_returns;
    (ref($series_string_map) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"series_string_map\" (value was \"$series_string_map\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_series_titles:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_titles');
    }
    return($series_string_map);
}




=head2 get_expression_series_summaries

  $series_string_map = $obj->get_expression_series_summaries($series_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$series_ids is an ExpressionServices.series_ids
$series_string_map is an ExpressionServices.series_string_map
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
series_string_map is a reference to a hash where the key is an ExpressionServices.series_id and the value is a string

</pre>

=end html

=begin text

$series_ids is an ExpressionServices.series_ids
$series_string_map is an ExpressionServices.series_string_map
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
series_string_map is a reference to a hash where the key is an ExpressionServices.series_id and the value is a string


=end text



=item Description

given a List of SeriesIDs, returns a Hash (key : SeriesID, value: Summary of Series)

=back

=cut

sub get_expression_series_summaries
{
    my $self = shift;
    my($series_ids) = @_;

    my @_bad_arguments;
    (ref($series_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"series_ids\" (value was \"$series_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_series_summaries:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_summaries');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($series_string_map);
    #BEGIN get_expression_series_summaries
    $series_string_map = {}; 
    if (0 == @{$series_ids})
    { 
        my $msg = "get_expression_series_summaries requires a list of valid series ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_summaries');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_series_info_q = qq^select id, summary from Series where id in (^.
        join(",", ("?") x @{$series_ids}) . ") ";
    my $get_series_info_qh = $dbh->prepare($get_series_info_q) or die "Unable to prepare : get_series_info_q : ".
        $get_series_info_q . " : " .$dbh->errstr();
    $get_series_info_qh->execute(@{$series_ids}) or die "Unable to execute : get_series_info_q : ".$get_series_info_qh->errstr();
    while (my ($series_id, $info) = $get_series_info_qh->fetchrow_array()) 
    { 
        $series_string_map->{$series_id} = $info; 
    } 
    #END get_expression_series_summaries
    my @_bad_returns;
    (ref($series_string_map) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"series_string_map\" (value was \"$series_string_map\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_series_summaries:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_summaries');
    }
    return($series_string_map);
}




=head2 get_expression_series_designs

  $series_string_map = $obj->get_expression_series_designs($series_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$series_ids is an ExpressionServices.series_ids
$series_string_map is an ExpressionServices.series_string_map
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
series_string_map is a reference to a hash where the key is an ExpressionServices.series_id and the value is a string

</pre>

=end html

=begin text

$series_ids is an ExpressionServices.series_ids
$series_string_map is an ExpressionServices.series_string_map
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
series_string_map is a reference to a hash where the key is an ExpressionServices.series_id and the value is a string


=end text



=item Description

given a List of SeriesIDs, returns a Hash (key : SeriesID, value: Design of Series)

=back

=cut

sub get_expression_series_designs
{
    my $self = shift;
    my($series_ids) = @_;

    my @_bad_arguments;
    (ref($series_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"series_ids\" (value was \"$series_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_series_designs:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_designs');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($series_string_map);
    #BEGIN get_expression_series_designs
    $series_string_map = {}; 
    if (0 == @{$series_ids})
    { 
        my $msg = "get_expression_series_designs requires a list of valid series ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_designs');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_series_info_q = qq^select id, design from Series where id in (^.
        join(",", ("?") x @{$series_ids}) . ") ";
    my $get_series_info_qh = $dbh->prepare($get_series_info_q) or die "Unable to prepare : get_series_info_q : ".
        $get_series_info_q . " : " .$dbh->errstr();
    $get_series_info_qh->execute(@{$series_ids}) or die "Unable to execute : get_series_info_q : ".$get_series_info_qh->errstr();
    while (my ($series_id, $info) = $get_series_info_qh->fetchrow_array()) 
    { 
        $series_string_map->{$series_id} = $info; 
    } 
    #END get_expression_series_designs
    my @_bad_returns;
    (ref($series_string_map) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"series_string_map\" (value was \"$series_string_map\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_series_designs:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_designs');
    }
    return($series_string_map);
}




=head2 get_expression_series_external_source_ids

  $series_string_map = $obj->get_expression_series_external_source_ids($series_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$series_ids is an ExpressionServices.series_ids
$series_string_map is an ExpressionServices.series_string_map
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
series_string_map is a reference to a hash where the key is an ExpressionServices.series_id and the value is a string

</pre>

=end html

=begin text

$series_ids is an ExpressionServices.series_ids
$series_string_map is an ExpressionServices.series_string_map
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string
series_string_map is a reference to a hash where the key is an ExpressionServices.series_id and the value is a string


=end text



=item Description

given a List of SeriesIDs, returns a Hash (key : SeriesID, value: External_Source_ID of Series (typically GSE))

=back

=cut

sub get_expression_series_external_source_ids
{
    my $self = shift;
    my($series_ids) = @_;

    my @_bad_arguments;
    (ref($series_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"series_ids\" (value was \"$series_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_series_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_external_source_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($series_string_map);
    #BEGIN get_expression_series_external_source_ids
    $series_string_map = {}; 
    if (0 == @{$series_ids})
    { 
        my $msg = "get_expression_series_external_source_ids requires a list of valid series ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_external_source_ids');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_series_info_q = qq^select id, externalSourceId from Series where id in (^.
        join(",", ("?") x @{$series_ids}) . ") ";
    my $get_series_info_qh = $dbh->prepare($get_series_info_q) or die "Unable to prepare : get_series_info_q : ".
        $get_series_info_q . " : " .$dbh->errstr();
    $get_series_info_qh->execute(@{$series_ids}) or die "Unable to execute : get_series_info_q : ".$get_series_info_qh->errstr();
    while (my ($series_id, $info) = $get_series_info_qh->fetchrow_array()) 
    { 
        $series_string_map->{$series_id} = $info; 
    } 
    #END get_expression_series_external_source_ids
    my @_bad_returns;
    (ref($series_string_map) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"series_string_map\" (value was \"$series_string_map\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_series_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_external_source_ids');
    }
    return($series_string_map);
}




=head2 get_expression_sample_ids_by_sample_external_source_ids

  $sample_ids = $obj->get_expression_sample_ids_by_sample_external_source_ids($external_source_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$external_source_ids is an ExpressionServices.external_source_ids
$sample_ids is an ExpressionServices.sample_ids
external_source_ids is a reference to a list where each element is an ExpressionServices.external_source_id
external_source_id is a string
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string

</pre>

=end html

=begin text

$external_source_ids is an ExpressionServices.external_source_ids
$sample_ids is an ExpressionServices.sample_ids
external_source_ids is a reference to a list where each element is an ExpressionServices.external_source_id
external_source_id is a string
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string


=end text



=item Description

get sample ids by the sample's external source id : Takes a list of sample external source ids, and returns a list of sample ids

=back

=cut

sub get_expression_sample_ids_by_sample_external_source_ids
{
    my $self = shift;
    my($external_source_ids) = @_;

    my @_bad_arguments;
    (ref($external_source_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"external_source_ids\" (value was \"$external_source_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_sample_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_sample_external_source_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($sample_ids);
    #BEGIN get_expression_sample_ids_by_sample_external_source_ids
    $sample_ids = []; 
    if (0 == @{$external_source_ids}) 
    { 
        my $msg = "get_expression_sample_ids_by_sample_external_source_ids requires a list of valid external source ids for the sample.  ".
	    "These are typically GSM numbers. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							     method_name => 'get_expression_sample_ids_by_sample_external_source_ids');
    }
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_samples_q = qq^select id from Sample where externalSourceId in (^.
        join(",", ("?") x @{$external_source_ids}) . ") ";
    my $get_samples_qh = $dbh->prepare($get_samples_q) or die "Unable to prepare : get_samples_q : ". 
        $get_samples_q . " : " .$dbh->errstr(); 
    $get_samples_qh->execute(@{$external_source_ids}) or die "Unable to execute : get_samples_q : ".$get_samples_qh->errstr(); 
    while (my ($sample_id) = $get_samples_qh->fetchrow_array())
    {
	push(@{$sample_ids},$sample_id);
    } 
    #END get_expression_sample_ids_by_sample_external_source_ids
    my @_bad_returns;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_sample_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_sample_external_source_ids');
    }
    return($sample_ids);
}




=head2 get_expression_sample_ids_by_platform_external_source_ids

  $sample_ids = $obj->get_expression_sample_ids_by_platform_external_source_ids($external_source_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$external_source_ids is an ExpressionServices.external_source_ids
$sample_ids is an ExpressionServices.sample_ids
external_source_ids is a reference to a list where each element is an ExpressionServices.external_source_id
external_source_id is a string
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string

</pre>

=end html

=begin text

$external_source_ids is an ExpressionServices.external_source_ids
$sample_ids is an ExpressionServices.sample_ids
external_source_ids is a reference to a list where each element is an ExpressionServices.external_source_id
external_source_id is a string
sample_ids is a reference to a list where each element is an ExpressionServices.sample_id
sample_id is a string


=end text



=item Description

get sample ids by the platform's external source id : Takes a list of platform external source ids, and returns a list of sample ids

=back

=cut

sub get_expression_sample_ids_by_platform_external_source_ids
{
    my $self = shift;
    my($external_source_ids) = @_;

    my @_bad_arguments;
    (ref($external_source_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"external_source_ids\" (value was \"$external_source_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_platform_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_platform_external_source_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($sample_ids);
    #BEGIN get_expression_sample_ids_by_platform_external_source_ids
    $sample_ids = []; 
    if (0 == @{$external_source_ids}) 
    { 
        my $msg = "get_expression_sample_ids_by_platform_external_source_ids requires a list of valid external source ids for the platform.  ". 
            "These are typically GPL numbers. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_sample_ids_by_platform_external_source_ids'); 
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
    my $get_samples_q = qq^select s.id from Sample s inner join PlatformWithSamples ps on s.id = ps.to_link ^.
	                qq^inner join Platform p on p.id = ps.from_link where p.externalSourceId in (^. 
        join(",", ("?") x @{$external_source_ids}) . ") "; 
    my $get_samples_qh = $dbh->prepare($get_samples_q) or die "Unable to prepare : get_samples_q : ". 
        $get_samples_q . " : " .$dbh->errstr(); 
    $get_samples_qh->execute(@{$external_source_ids}) or die "Unable to execute : get_samples_q : ".$get_samples_qh->errstr(); 
    while (my ($sample_id) = $get_samples_qh->fetchrow_array()) 
    { 
        push(@{$sample_ids},$sample_id); 
    } 
    #END get_expression_sample_ids_by_platform_external_source_ids
    my @_bad_returns;
    (ref($sample_ids) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sample_ids\" (value was \"$sample_ids\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_platform_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_platform_external_source_ids');
    }
    return($sample_ids);
}




=head2 get_expression_series_ids_by_series_external_source_ids

  $series_ids = $obj->get_expression_series_ids_by_series_external_source_ids($external_source_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$external_source_ids is an ExpressionServices.external_source_ids
$series_ids is an ExpressionServices.series_ids
external_source_ids is a reference to a list where each element is an ExpressionServices.external_source_id
external_source_id is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string

</pre>

=end html

=begin text

$external_source_ids is an ExpressionServices.external_source_ids
$series_ids is an ExpressionServices.series_ids
external_source_ids is a reference to a list where each element is an ExpressionServices.external_source_id
external_source_id is a string
series_ids is a reference to a list where each element is an ExpressionServices.series_id
series_id is a string


=end text



=item Description

get series ids by the series's external source id : Takes a list of series external source ids, and returns a list of series ids

=back

=cut

sub get_expression_series_ids_by_series_external_source_ids
{
    my $self = shift;
    my($external_source_ids) = @_;

    my @_bad_arguments;
    (ref($external_source_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"external_source_ids\" (value was \"$external_source_ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_series_ids_by_series_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_ids_by_series_external_source_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($series_ids);
    #BEGIN get_expression_series_ids_by_series_external_source_ids
    $series_ids = []; 
    if (0 == @{$external_source_ids}) 
    { 
        my $msg = "get_expression_series_ids_by_series_external_source_ids requires a list of valid external source ids for the series.  ".
            "These are typically GSE numbers. ";
      Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_series_ids_by_series_external_source_ids');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
    my $get_series_q = qq^select s.id from Series s where s.externalSourceId in (^.
			join(",", ("?") x @{$external_source_ids}) . ") ";
    my $get_series_qh = $dbh->prepare($get_series_q) or die "Unable to prepare : get_series_q : ".
        $get_series_q . " : " .$dbh->errstr(); 
    $get_series_qh->execute(@{$external_source_ids}) or die "Unable to execute : get_series_q : ".$get_series_qh->errstr(); 
    while (my ($series_id) = $get_series_qh->fetchrow_array()) 
    { 
        push(@{$series_ids},$series_id); 
    } 
    #END get_expression_series_ids_by_series_external_source_ids
    my @_bad_returns;
    (ref($series_ids) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"series_ids\" (value was \"$series_ids\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_series_ids_by_series_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_ids_by_series_external_source_ids');
    }
    return($series_ids);
}




=head2 get_GEO_GSE

  $gseObject = $obj->get_GEO_GSE($gse_input_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$gse_input_id is a string
$gseObject is an ExpressionServices.GseObject
GseObject is a reference to a hash where the following keys are defined:
	gse_id has a value which is a string
	gse_title has a value which is a string
	gse_summary has a value which is a string
	gse_design has a value which is a string
	gse_submission_date has a value which is a string
	pub_med_id has a value which is a string
	gse_samples has a value which is an ExpressionServices.gse_samples
	gse_warnings has a value which is an ExpressionServices.gse_warnings
	gse_errors has a value which is an ExpressionServices.gse_errors
gse_samples is a reference to a hash where the key is a string and the value is an ExpressionServices.GsmObject
GsmObject is a reference to a hash where the following keys are defined:
	gsm_id has a value which is a string
	gsm_title has a value which is a string
	gsm_description has a value which is a string
	gsm_molecule has a value which is a string
	gsm_submission_date has a value which is a string
	gsm_tax_id has a value which is a string
	gsm_sample_organism has a value which is a string
	gsm_sample_characteristics has a value which is an ExpressionServices.gsm_sample_characteristics
	gsm_protocol has a value which is a string
	gsm_value_type has a value which is a string
	gsm_platform has a value which is an ExpressionServices.GPL
	gsm_contact_people has a value which is an ExpressionServices.contact_people
	gsm_data has a value which is an ExpressionServices.gsm_data
	gsm_feature_mapping_approach has a value which is a string
	ontology_ids has a value which is an ExpressionServices.ontology_ids
	gsm_warning has a value which is an ExpressionServices.gsm_warnings
	gsm_errors has a value which is an ExpressionServices.gsm_errors
gsm_sample_characteristics is a reference to a list where each element is a string
GPL is a reference to a hash where the following keys are defined:
	gpl_id has a value which is a string
	gpl_title has a value which is a string
	gpl_technology has a value which is a string
	gpl_tax_id has a value which is a string
	gpl_organism has a value which is a string
contact_people is a reference to a hash where the key is an ExpressionServices.contact_email and the value is an ExpressionServices.ContactPerson
contact_email is a string
ContactPerson is a reference to a hash where the following keys are defined:
	contact_first_name has a value which is an ExpressionServices.contact_first_name
	contact_last_name has a value which is an ExpressionServices.contact_last_name
	contact_institution has a value which is an ExpressionServices.contact_institution
contact_first_name is a string
contact_last_name is a string
contact_institution is a string
gsm_data is a reference to a hash where the key is an ExpressionServices.genome_id and the value is an ExpressionServices.GenomeDataGSM
genome_id is a string
GenomeDataGSM is a reference to a hash where the following keys are defined:
	warnings has a value which is an ExpressionServices.gsm_data_warnings
	errors has a value which is an ExpressionServices.gsm_data_errors
	features has a value which is an ExpressionServices.gsm_data_set
	originalLog2Median has a value which is a float
gsm_data_warnings is a reference to a list where each element is a string
gsm_data_errors is a reference to a list where each element is a string
gsm_data_set is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.FullMeasurement
feature_id is a string
FullMeasurement is a reference to a hash where the following keys are defined:
	value has a value which is a float
	n has a value which is a float
	stddev has a value which is a float
	z_score has a value which is a float
	p_value has a value which is a float
	median has a value which is a float
	mean has a value which is a float
ontology_ids is a reference to a list where each element is an ExpressionServices.ontology_id
ontology_id is a string
gsm_warnings is a reference to a list where each element is a string
gsm_errors is a reference to a list where each element is a string
gse_warnings is a reference to a list where each element is a string
gse_errors is a reference to a list where each element is a string

</pre>

=end html

=begin text

$gse_input_id is a string
$gseObject is an ExpressionServices.GseObject
GseObject is a reference to a hash where the following keys are defined:
	gse_id has a value which is a string
	gse_title has a value which is a string
	gse_summary has a value which is a string
	gse_design has a value which is a string
	gse_submission_date has a value which is a string
	pub_med_id has a value which is a string
	gse_samples has a value which is an ExpressionServices.gse_samples
	gse_warnings has a value which is an ExpressionServices.gse_warnings
	gse_errors has a value which is an ExpressionServices.gse_errors
gse_samples is a reference to a hash where the key is a string and the value is an ExpressionServices.GsmObject
GsmObject is a reference to a hash where the following keys are defined:
	gsm_id has a value which is a string
	gsm_title has a value which is a string
	gsm_description has a value which is a string
	gsm_molecule has a value which is a string
	gsm_submission_date has a value which is a string
	gsm_tax_id has a value which is a string
	gsm_sample_organism has a value which is a string
	gsm_sample_characteristics has a value which is an ExpressionServices.gsm_sample_characteristics
	gsm_protocol has a value which is a string
	gsm_value_type has a value which is a string
	gsm_platform has a value which is an ExpressionServices.GPL
	gsm_contact_people has a value which is an ExpressionServices.contact_people
	gsm_data has a value which is an ExpressionServices.gsm_data
	gsm_feature_mapping_approach has a value which is a string
	ontology_ids has a value which is an ExpressionServices.ontology_ids
	gsm_warning has a value which is an ExpressionServices.gsm_warnings
	gsm_errors has a value which is an ExpressionServices.gsm_errors
gsm_sample_characteristics is a reference to a list where each element is a string
GPL is a reference to a hash where the following keys are defined:
	gpl_id has a value which is a string
	gpl_title has a value which is a string
	gpl_technology has a value which is a string
	gpl_tax_id has a value which is a string
	gpl_organism has a value which is a string
contact_people is a reference to a hash where the key is an ExpressionServices.contact_email and the value is an ExpressionServices.ContactPerson
contact_email is a string
ContactPerson is a reference to a hash where the following keys are defined:
	contact_first_name has a value which is an ExpressionServices.contact_first_name
	contact_last_name has a value which is an ExpressionServices.contact_last_name
	contact_institution has a value which is an ExpressionServices.contact_institution
contact_first_name is a string
contact_last_name is a string
contact_institution is a string
gsm_data is a reference to a hash where the key is an ExpressionServices.genome_id and the value is an ExpressionServices.GenomeDataGSM
genome_id is a string
GenomeDataGSM is a reference to a hash where the following keys are defined:
	warnings has a value which is an ExpressionServices.gsm_data_warnings
	errors has a value which is an ExpressionServices.gsm_data_errors
	features has a value which is an ExpressionServices.gsm_data_set
	originalLog2Median has a value which is a float
gsm_data_warnings is a reference to a list where each element is a string
gsm_data_errors is a reference to a list where each element is a string
gsm_data_set is a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.FullMeasurement
feature_id is a string
FullMeasurement is a reference to a hash where the following keys are defined:
	value has a value which is a float
	n has a value which is a float
	stddev has a value which is a float
	z_score has a value which is a float
	p_value has a value which is a float
	median has a value which is a float
	mean has a value which is a float
ontology_ids is a reference to a list where each element is an ExpressionServices.ontology_id
ontology_id is a string
gsm_warnings is a reference to a list where each element is a string
gsm_errors is a reference to a list where each element is a string
gse_warnings is a reference to a list where each element is a string
gse_errors is a reference to a list where each element is a string


=end text



=item Description

given a GEO GSE ID, it will return a complex data structure to be put int the upload tab files

=back

=cut

sub get_GEO_GSE
{
    my $self = shift;
    my($gse_input_id) = @_;

    my @_bad_arguments;
    (!ref($gse_input_id)) or push(@_bad_arguments, "Invalid type for argument \"gse_input_id\" (value was \"$gse_input_id\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_GEO_GSE:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_GEO_GSE');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($gseObject);
    #BEGIN get_GEO_GSE
    $gseObject ={};

    # create new functionsForGEO
    my $functionsForGEO = Bio::KBase::ExpressionServices::FunctionsForGEO->new();
    $gseObject = $functionsForGEO->get_GEO_GSE_data($gse_input_id,1);
    #END get_GEO_GSE
    my @_bad_returns;
    (ref($gseObject) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"gseObject\" (value was \"$gseObject\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_GEO_GSE:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_GEO_GSE');
    }
    return($gseObject);
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



=head2 feature_id

=over 4



=item Description

KBase Feature ID for a feature, typically CDS/PEG
id ws KB.Feature 

"ws" may change to "to" in the future


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



=head2 feature_ids

=over 4



=item Description

KBase list of Feature IDs , typically CDS/PEG


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.feature_id
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.feature_id

=end text

=back



=head2 measurement

=over 4



=item Description

Measurement Value (Zero median normalized within a sample) for a given feature


=item Definition

=begin html

<pre>
a float
</pre>

=end html

=begin text

a float

=end text

=back



=head2 sample_id

=over 4



=item Description

KBase Sample ID for the sample


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



=head2 sample_ids

=over 4



=item Description

List of KBase Sample IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.sample_id
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.sample_id

=end text

=back



=head2 sample_ids_averaged_from

=over 4



=item Description

List of KBase Sample IDs that this sample was averaged from


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.sample_id
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.sample_id

=end text

=back



=head2 sample_type

=over 4



=item Description

Sample type controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics


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



=head2 series_id

=over 4



=item Description

Kbase Series ID


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



=head2 series_ids

=over 4



=item Description

list of KBase Series IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.series_id
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.series_id

=end text

=back



=head2 experiment_meta_id

=over 4



=item Description

Kbase ExperimentMeta ID


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



=head2 experiment_meta_ids

=over 4



=item Description

list of KBase ExperimentMeta IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.experiment_meta_id
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.experiment_meta_id

=end text

=back



=head2 experimental_unit_id

=over 4



=item Description

Kbase ExperimentalUnit ID


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



=head2 experimental_unit_ids

=over 4



=item Description

list of KBase ExperimentalUnit IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.experimental_unit_id
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.experimental_unit_id

=end text

=back



=head2 samples_string_map

=over 4



=item Description

Mapping between sample id and corresponding value.   Used as return for get_expression_samples_(titles,descriptions,molecules,types,external_source_ids)


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.sample_id and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.sample_id and the value is a string

=end text

=back



=head2 samples_float_map

=over 4



=item Description

Mapping between sample id and corresponding value.   Used as return for get_expression_samples_original_log2_median


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.sample_id and the value is a float
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.sample_id and the value is a float

=end text

=back



=head2 series_string_map

=over 4



=item Description

Mapping between sample id and corresponding value.   Used as return for get_series_(titles,summaries,designs,external_source_ids)


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.series_id and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.series_id and the value is a string

=end text

=back



=head2 data_expression_levels_for_sample

=over 4



=item Description

mapping kbase feature id as the key and measurement as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.measurement

=end text

=back



=head2 label_data_mapping

=over 4



=item Description

Mapping from Label (often a sample id, but free text to identify} to DataExpressionLevelsForSample


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is an ExpressionServices.data_expression_levels_for_sample
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is an ExpressionServices.data_expression_levels_for_sample

=end text

=back



=head2 comparison_denominator_label

=over 4



=item Description

denominator label is the label for the denominator in a comparison.  
This label can be a single sampleId (default or defined) or a comma separated list of sampleIds that were averaged.


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



=head2 log2_ratio

=over 4



=item Description

Log2Ratio Log2Level of sample over log2Level of another sample for a given feature.  
Note if the Ratio is consumed by On Off Call function it will have 1(on), 0(unknown), -1(off) for its values


=item Definition

=begin html

<pre>
a float
</pre>

=end html

=begin text

a float

=end text

=back



=head2 data_sample_comparison

=over 4



=item Description

mapping kbase feature id as the key and log2Ratio as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.log2_ratio
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.log2_ratio

=end text

=back



=head2 denominator_sample_comparison

=over 4



=item Description

mapping ComparisonDenominatorLabel to DataSampleComparison mapping


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.comparison_denominator_label and the value is an ExpressionServices.data_sample_comparison
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.comparison_denominator_label and the value is an ExpressionServices.data_sample_comparison

=end text

=back



=head2 sample_comparison_mapping

=over 4



=item Description

mapping Sample Id for the numerator to a DenominatorSampleComparison.  This is the comparison data structure {NumeratorSampleId->{denominatorLabel -> {feature -> log2ratio}}}


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.denominator_sample_comparison
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.denominator_sample_comparison

=end text

=back



=head2 sample_annotation_id

=over 4



=item Description

Kbase SampleAnnotation ID


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

Kbase OntologyID


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



=head2 ontology_ids

=over 4



=item Description

list of Kbase Ontology IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.ontology_id
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.ontology_id

=end text

=back



=head2 ontology_name

=over 4



=item Description

Kbase OntologyName


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



=head2 ontology_definition

=over 4



=item Description

Kbase OntologyDefinition


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



=head2 SampleAnnotation

=over 4



=item Description

Data structure for top level information for sample annotation and ontology


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
ontology_id has a value which is an ExpressionServices.ontology_id
ontology_name has a value which is an ExpressionServices.ontology_name
ontology_definition has a value which is an ExpressionServices.ontology_definition

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
sample_annotation_id has a value which is an ExpressionServices.sample_annotation_id
ontology_id has a value which is an ExpressionServices.ontology_id
ontology_name has a value which is an ExpressionServices.ontology_name
ontology_definition has a value which is an ExpressionServices.ontology_definition


=end text

=back



=head2 sample_annotations

=over 4



=item Description

list of Sample Annotations associated with the Sample


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.SampleAnnotation
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.SampleAnnotation

=end text

=back



=head2 external_source_id

=over 4



=item Description

externalSourceId (could be for Platform, Sample or Series)(typically maps to a GPL, GSM or GSE from GEO)


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



=head2 external_source_ids

=over 4



=item Description

list of externalSourceIDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.external_source_id
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.external_source_id

=end text

=back



=head2 Person

=over 4



=item Description

Data structure for Person  (TEMPORARY WORKSPACE TYPED OBJECT SHOULD BE HANDLED IN THE FUTURE IN WORKSPACE COMMON)

##        @searchable ws_subset email last_name institution


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
email has a value which is a string
first_name has a value which is a string
last_name has a value which is a string
institution has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
email has a value which is a string
first_name has a value which is a string
last_name has a value which is a string
institution has a value which is a string


=end text

=back



=head2 person_id

=over 4



=item Description

Kbase Person ID


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



=head2 person_ids

=over 4



=item Description

list of KBase PersonsIDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.person_id
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.person_id

=end text

=back



=head2 strain_id

=over 4



=item Description

KBase StrainID


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



=head2 strain_ids

=over 4



=item Description

list of KBase StrainIDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.strain_id
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.strain_id

=end text

=back



=head2 genome_id

=over 4



=item Description

KBase GenomeID 
id ws KB.Genome

"ws" may change to "to" in the future


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



=head2 genome_ids

=over 4



=item Description

list of KBase GenomeIDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.genome_id
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.genome_id

=end text

=back



=head2 wild_type_only

=over 4



=item Description

Single integer 1= WildTypeonly, 0 means all strains ok


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 ExpressionDataSample

=over 4



=item Description

Data structure for all the top level metadata and value data for an expression sample.  Essentially a expression Sample object.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
sample_id has a value which is an ExpressionServices.sample_id
source_id has a value which is a string
sample_title has a value which is a string
sample_description has a value which is a string
molecule has a value which is a string
sample_type has a value which is an ExpressionServices.sample_type
data_source has a value which is a string
external_source_id has a value which is a string
external_source_date has a value which is a string
kbase_submission_date has a value which is a string
custom has a value which is a string
original_log2_median has a value which is a float
strain_id has a value which is an ExpressionServices.strain_id
reference_strain has a value which is a string
wildtype has a value which is a string
strain_description has a value which is a string
genome_id has a value which is an ExpressionServices.genome_id
genome_scientific_name has a value which is a string
platform_id has a value which is a string
platform_title has a value which is a string
platform_technology has a value which is a string
experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
experiment_title has a value which is a string
experiment_description has a value which is a string
environment_id has a value which is a string
environment_description has a value which is a string
protocol_id has a value which is a string
protocol_description has a value which is a string
protocol_name has a value which is a string
sample_annotations has a value which is an ExpressionServices.sample_annotations
series_ids has a value which is an ExpressionServices.series_ids
person_ids has a value which is an ExpressionServices.person_ids
sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
sample_id has a value which is an ExpressionServices.sample_id
source_id has a value which is a string
sample_title has a value which is a string
sample_description has a value which is a string
molecule has a value which is a string
sample_type has a value which is an ExpressionServices.sample_type
data_source has a value which is a string
external_source_id has a value which is a string
external_source_date has a value which is a string
kbase_submission_date has a value which is a string
custom has a value which is a string
original_log2_median has a value which is a float
strain_id has a value which is an ExpressionServices.strain_id
reference_strain has a value which is a string
wildtype has a value which is a string
strain_description has a value which is a string
genome_id has a value which is an ExpressionServices.genome_id
genome_scientific_name has a value which is a string
platform_id has a value which is a string
platform_title has a value which is a string
platform_technology has a value which is a string
experimental_unit_id has a value which is an ExpressionServices.experimental_unit_id
experiment_meta_id has a value which is an ExpressionServices.experiment_meta_id
experiment_title has a value which is a string
experiment_description has a value which is a string
environment_id has a value which is a string
environment_description has a value which is a string
protocol_id has a value which is a string
protocol_description has a value which is a string
protocol_name has a value which is a string
sample_annotations has a value which is an ExpressionServices.sample_annotations
series_ids has a value which is an ExpressionServices.series_ids
person_ids has a value which is an ExpressionServices.person_ids
sample_ids_averaged_from has a value which is an ExpressionServices.sample_ids_averaged_from
data_expression_levels_for_sample has a value which is an ExpressionServices.data_expression_levels_for_sample


=end text

=back



=head2 expression_data_samples_map

=over 4



=item Description

Mapping between sampleID and ExpressionDataSample


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.ExpressionDataSample

=end text

=back



=head2 series_expression_data_samples_mapping

=over 4



=item Description

mapping between seriesIDs and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.series_id and the value is an ExpressionServices.expression_data_samples_map
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.series_id and the value is an ExpressionServices.expression_data_samples_map

=end text

=back



=head2 experimental_unit_expression_data_samples_mapping

=over 4



=item Description

mapping between experimentalUnitIDs and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.experimental_unit_id and the value is an ExpressionServices.expression_data_samples_map
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.experimental_unit_id and the value is an ExpressionServices.expression_data_samples_map

=end text

=back



=head2 experiment_meta_expression_data_samples_mapping

=over 4



=item Description

mapping between experimentMetaIDs and ExperimentalUnitExpressionDataSamplesMapping it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.experiment_meta_id and the value is an ExpressionServices.experimental_unit_expression_data_samples_mapping
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.experiment_meta_id and the value is an ExpressionServices.experimental_unit_expression_data_samples_mapping

=end text

=back



=head2 strain_expression_data_samples_mapping

=over 4



=item Description

mapping between strainIDs and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.strain_id and the value is an ExpressionServices.expression_data_samples_map
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.strain_id and the value is an ExpressionServices.expression_data_samples_map

=end text

=back



=head2 genome_expression_data_samples_mapping

=over 4



=item Description

mapping between genomeIDs and all StrainExpressionDataSamplesMapping it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.genome_id and the value is an ExpressionServices.strain_expression_data_samples_mapping
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.genome_id and the value is an ExpressionServices.strain_expression_data_samples_mapping

=end text

=back



=head2 ontology_expression_data_sample_mapping

=over 4



=item Description

mapping between ontologyIDs (concatenated if searched for with the and operator) and all the Samples that match that term(s)


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.ontology_id and the value is an ExpressionServices.expression_data_samples_map
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.ontology_id and the value is an ExpressionServices.expression_data_samples_map

=end text

=back



=head2 sample_measurement_mapping

=over 4



=item Description

mapping kbase sample id as the key and a single measurement (for a specified feature id, one mapping higher) as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.measurement
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.sample_id and the value is an ExpressionServices.measurement

=end text

=back



=head2 feature_sample_measurement_mapping

=over 4



=item Description

mapping between FeatureIds and the mappings between samples and log2level mapping


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.sample_measurement_mapping
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.sample_measurement_mapping

=end text

=back



=head2 GPL

=over 4



=item Description

Data structure for a GEO Platform


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
gpl_id has a value which is a string
gpl_title has a value which is a string
gpl_technology has a value which is a string
gpl_tax_id has a value which is a string
gpl_organism has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
gpl_id has a value which is a string
gpl_title has a value which is a string
gpl_technology has a value which is a string
gpl_tax_id has a value which is a string
gpl_organism has a value which is a string


=end text

=back



=head2 contact_email

=over 4



=item Description

Email for the GSM contact person


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



=head2 contact_first_name

=over 4



=item Description

First Name of GSM contact person


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



=head2 contact_last_name

=over 4



=item Description

Last Name of GSM contact person


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



=head2 contact_institution

=over 4



=item Description

Institution of GSM contact person


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



=head2 ContactPerson

=over 4



=item Description

Data structure for GSM ContactPerson


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
contact_first_name has a value which is an ExpressionServices.contact_first_name
contact_last_name has a value which is an ExpressionServices.contact_last_name
contact_institution has a value which is an ExpressionServices.contact_institution

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
contact_first_name has a value which is an ExpressionServices.contact_first_name
contact_last_name has a value which is an ExpressionServices.contact_last_name
contact_institution has a value which is an ExpressionServices.contact_institution


=end text

=back



=head2 contact_people

=over 4



=item Description

Mapping between key : ContactEmail and value : ContactPerson Data Structure


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.contact_email and the value is an ExpressionServices.ContactPerson
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.contact_email and the value is an ExpressionServices.ContactPerson

=end text

=back



=head2 FullMeasurement

=over 4



=item Description

Measurement data structure


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
value has a value which is a float
n has a value which is a float
stddev has a value which is a float
z_score has a value which is a float
p_value has a value which is a float
median has a value which is a float
mean has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
value has a value which is a float
n has a value which is a float
stddev has a value which is a float
z_score has a value which is a float
p_value has a value which is a float
median has a value which is a float
mean has a value which is a float


=end text

=back



=head2 gsm_data_set

=over 4



=item Description

mapping kbase feature id as the key and FullMeasurement Structure as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.FullMeasurement
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.feature_id and the value is an ExpressionServices.FullMeasurement

=end text

=back



=head2 gsm_data_warnings

=over 4



=item Description

List of GSM Data level warnings


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



=head2 gsm_warnings

=over 4



=item Description

List of GSM level warnings


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



=head2 gse_warnings

=over 4



=item Description

List of GSE level warnings


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



=head2 gsm_data_errors

=over 4



=item Description

List of GSM Data level errors


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



=head2 gsm_errors

=over 4



=item Description

List of GSM level errors


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



=head2 gse_errors

=over 4



=item Description

List of GSE level errors


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



=head2 gsm_sample_characteristics

=over 4



=item Description

List of GSM Sample Characteristics from ch1


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



=head2 GenomeDataGSM

=over 4



=item Description

Data structure that has the GSM data, warnings, errors and originalLog2Median for that GSM and Genome ID combination


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
warnings has a value which is an ExpressionServices.gsm_data_warnings
errors has a value which is an ExpressionServices.gsm_data_errors
features has a value which is an ExpressionServices.gsm_data_set
originalLog2Median has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
warnings has a value which is an ExpressionServices.gsm_data_warnings
errors has a value which is an ExpressionServices.gsm_data_errors
features has a value which is an ExpressionServices.gsm_data_set
originalLog2Median has a value which is a float


=end text

=back



=head2 gsm_data

=over 4



=item Description

mapping kbase feature id as the key and FullMeasurement Structure as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.genome_id and the value is an ExpressionServices.GenomeDataGSM
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.genome_id and the value is an ExpressionServices.GenomeDataGSM

=end text

=back



=head2 GsmObject

=over 4



=item Description

GSM OBJECT


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
gsm_id has a value which is a string
gsm_title has a value which is a string
gsm_description has a value which is a string
gsm_molecule has a value which is a string
gsm_submission_date has a value which is a string
gsm_tax_id has a value which is a string
gsm_sample_organism has a value which is a string
gsm_sample_characteristics has a value which is an ExpressionServices.gsm_sample_characteristics
gsm_protocol has a value which is a string
gsm_value_type has a value which is a string
gsm_platform has a value which is an ExpressionServices.GPL
gsm_contact_people has a value which is an ExpressionServices.contact_people
gsm_data has a value which is an ExpressionServices.gsm_data
gsm_feature_mapping_approach has a value which is a string
ontology_ids has a value which is an ExpressionServices.ontology_ids
gsm_warning has a value which is an ExpressionServices.gsm_warnings
gsm_errors has a value which is an ExpressionServices.gsm_errors

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
gsm_id has a value which is a string
gsm_title has a value which is a string
gsm_description has a value which is a string
gsm_molecule has a value which is a string
gsm_submission_date has a value which is a string
gsm_tax_id has a value which is a string
gsm_sample_organism has a value which is a string
gsm_sample_characteristics has a value which is an ExpressionServices.gsm_sample_characteristics
gsm_protocol has a value which is a string
gsm_value_type has a value which is a string
gsm_platform has a value which is an ExpressionServices.GPL
gsm_contact_people has a value which is an ExpressionServices.contact_people
gsm_data has a value which is an ExpressionServices.gsm_data
gsm_feature_mapping_approach has a value which is a string
ontology_ids has a value which is an ExpressionServices.ontology_ids
gsm_warning has a value which is an ExpressionServices.gsm_warnings
gsm_errors has a value which is an ExpressionServices.gsm_errors


=end text

=back



=head2 gse_samples

=over 4



=item Description

Mapping of Key GSMID to GSM Object


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is an ExpressionServices.GsmObject
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is an ExpressionServices.GsmObject

=end text

=back



=head2 GseObject

=over 4



=item Description

GSE OBJECT


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
gse_id has a value which is a string
gse_title has a value which is a string
gse_summary has a value which is a string
gse_design has a value which is a string
gse_submission_date has a value which is a string
pub_med_id has a value which is a string
gse_samples has a value which is an ExpressionServices.gse_samples
gse_warnings has a value which is an ExpressionServices.gse_warnings
gse_errors has a value which is an ExpressionServices.gse_errors

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
gse_id has a value which is a string
gse_title has a value which is a string
gse_summary has a value which is a string
gse_design has a value which is a string
gse_submission_date has a value which is a string
pub_med_id has a value which is a string
gse_samples has a value which is an ExpressionServices.gse_samples
gse_warnings has a value which is an ExpressionServices.gse_warnings
gse_errors has a value which is an ExpressionServices.gse_errors


=end text

=back



=head2 meta_data_only

=over 4



=item Description

Single integer 1= metaDataOnly, 0 means returns data


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 ExpressionOntologyTerm

=over 4



=item Description

Temporary workspace typed object for ontology.  Should be replaced by a ontology workspace typed object.
Currently supports EO, PO and ENVO ontology terms.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
expression_ontology_term_id has a value which is a string
expression_ontology_term_name has a value which is a string
expression_ontology_term_definition has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
expression_ontology_term_id has a value which is a string
expression_ontology_term_name has a value which is a string
expression_ontology_term_definition has a value which is a string


=end text

=back



=head2 expression_ontology_terms

=over 4



=item Description

list of ExpressionsOntologies


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.ExpressionOntologyTerm
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.ExpressionOntologyTerm

=end text

=back



=head2 Strain

=over 4



=item Description

Data structure for Strain  (TEMPORARY WORKSPACE TYPED OBJECT SHOULD BE HANDLED IN THE FUTURE IN WORKSPACE COMMON)


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_id has a value which is an ExpressionServices.genome_id
reference_strain has a value which is a string
wild_type has a value which is a string
description has a value which is a string
name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_id has a value which is an ExpressionServices.genome_id
reference_strain has a value which is a string
wild_type has a value which is a string
description has a value which is a string
name has a value which is a string


=end text

=back



=head2 ExpressionPlatform

=over 4



=item Description

Data structure for the workspace expression platform.  The ExpressionPlatform typed object.
source_id defaults to id if not set, but typically referes to a GPL if the data is from GEO.

@optional strain

@searchable ws_subset source_id id genome_id title technology
@searchable ws_subset strain.genome_id  strain.reference_strain strain.wild_type


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
genome_id has a value which is an ExpressionServices.genome_id
strain has a value which is an ExpressionServices.Strain
technology has a value which is a string
title has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
genome_id has a value which is an ExpressionServices.genome_id
strain has a value which is an ExpressionServices.Strain
technology has a value which is a string
title has a value which is a string


=end text

=back



=head2 expression_platform_id

=over 4



=item Description

id for the expression platform

@id ws ExpressionServices.ExpressionPlatform

"ws" may go to "to" in the future


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



=head2 Protocol

=over 4



=item Description

Data structure for Protocol  (TEMPORARY WORKSPACE TYPED OBJECT SHOULD BE HANDLED IN THE FUTURE IN WORKSPACE COMMON)


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
description has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
description has a value which is a string


=end text

=back



=head2 expression_sample_id

=over 4



=item Description

id for the expression sample

@id ws ExpressionServices.ExpressionSample

"ws" may go to "to" in the future


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



=head2 expression_sample_ids

=over 4



=item Description

list of expression sample ids


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.expression_sample_id
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.expression_sample_id

=end text

=back



=head2 genome_expression_sample_ids_map

=over 4



=item Description

map between genome ids and a list of samples from that genome in this sample


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExpressionServices.genome_id and the value is an ExpressionServices.expression_sample_ids
</pre>

=end html

=begin text

a reference to a hash where the key is an ExpressionServices.genome_id and the value is an ExpressionServices.expression_sample_ids

=end text

=back



=head2 persons

=over 4



=item Description

list of Persons


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExpressionServices.Person
</pre>

=end html

=begin text

a reference to a list where each element is an ExpressionServices.Person

=end text

=back



=head2 ExpressionSample

=over 4



=item Description

Data structure for the workspace expression sample.  The Expression Sample typed object.

protocol, persons and strain should need to eventually have common ws objects.  I will make expression ones for now.

we may need a link to experimentMetaID later.

@optional description title data_quality_level original_median expression_ontology_terms platform_id default_control_sample 
@optional averaged_from_samples protocol strain persons molecule data_source

@searchable ws_subset id source_id type data_quality_level genome_id platform_id description title data_source keys_of(expression_levels) 
@searchable ws_subset persons.[*].email persons.[*].last_name persons.[*].institution  
@searchable ws_subset strain.genome_id strain.reference_strain strain.wild_type          
@searchable ws_subset protocol.name protocol.description 
@searchable ws_subset expression_ontology_terms.[*].expression_ontology_term_id expression_ontology_terms.[*].expression_ontology_term_name


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
type has a value which is an ExpressionServices.sample_type
numerical_interpretation has a value which is a string
description has a value which is a string
title has a value which is a string
data_quality_level has a value which is an int
original_median has a value which is a float
external_source_date has a value which is a string
expression_levels has a value which is an ExpressionServices.data_expression_levels_for_sample
genome_id has a value which is an ExpressionServices.genome_id
expression_ontology_terms has a value which is an ExpressionServices.expression_ontology_terms
platform_id has a value which is an ExpressionServices.expression_platform_id
default_control_sample has a value which is an ExpressionServices.expression_sample_id
averaged_from_samples has a value which is an ExpressionServices.expression_sample_ids
protocol has a value which is an ExpressionServices.Protocol
strain has a value which is an ExpressionServices.Strain
persons has a value which is an ExpressionServices.persons
molecule has a value which is a string
data_source has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
type has a value which is an ExpressionServices.sample_type
numerical_interpretation has a value which is a string
description has a value which is a string
title has a value which is a string
data_quality_level has a value which is an int
original_median has a value which is a float
external_source_date has a value which is a string
expression_levels has a value which is an ExpressionServices.data_expression_levels_for_sample
genome_id has a value which is an ExpressionServices.genome_id
expression_ontology_terms has a value which is an ExpressionServices.expression_ontology_terms
platform_id has a value which is an ExpressionServices.expression_platform_id
default_control_sample has a value which is an ExpressionServices.expression_sample_id
averaged_from_samples has a value which is an ExpressionServices.expression_sample_ids
protocol has a value which is an ExpressionServices.Protocol
strain has a value which is an ExpressionServices.Strain
persons has a value which is an ExpressionServices.persons
molecule has a value which is a string
data_source has a value which is a string


=end text

=back



=head2 ExpressionSeries

=over 4



=item Description

Data structure for the workspace expression series.  The ExpressionSeries typed object.
publication should need to eventually have ws objects, will not include it for now.

@optional title summary design publication_id 

@searchable ws_subset id source_id publication_id title summary design genome_expression_sample_ids_map


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
genome_expression_sample_ids_map has a value which is an ExpressionServices.genome_expression_sample_ids_map
title has a value which is a string
summary has a value which is a string
design has a value which is a string
publication_id has a value which is a string
external_source_date has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
source_id has a value which is a string
genome_expression_sample_ids_map has a value which is an ExpressionServices.genome_expression_sample_ids_map
title has a value which is a string
summary has a value which is a string
design has a value which is a string
publication_id has a value which is a string
external_source_date has a value which is a string


=end text

=back



=head2 ExpressionReplicateGroup

=over 4



=item Description

Simple Grouping of Samples that belong to the same replicate group.  ExpressionReplicateGroup yuped object.

@searchable ws_subset id expression_sample_ids


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
expression_sample_ids has a value which is an ExpressionServices.expression_sample_ids

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
expression_sample_ids has a value which is an ExpressionServices.expression_sample_ids


=end text

=back



=cut

1;
