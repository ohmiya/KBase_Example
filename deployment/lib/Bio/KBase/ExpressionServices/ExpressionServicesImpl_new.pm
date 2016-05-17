package ExpressionServicesImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

ExpressionServices

=head1 DESCRIPTION



=cut

#BEGIN_HEADER
use DBI;
use Storable qw(dclone);
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    #Copied from M. Sneddon's TreeImpl.pm from trees.git f63b672dc14f4600329424bc6b404b507e9c2503
    my($deploy) = @args;
    if (! $deploy) {
	# if not, then go to the config file defined by the deployment and import
	# the deployment settings
	my %params;
	if (my $e = $ENV{KB_DEPLOYMENT_CONFIG}) {
print "IN CONFIG IF\n";
	    my $EXPRESSION_SERVICE_NAME = $ENV{KB_SERVICE_NAME};
	    my $c = Config::Simple->new();
	    $c->read($e);
	    my @param_list = qw(dbName dbUser dbhost);
	    for my $p (@param_list)
	    {
		my $v = $c->param("$EXPRESSION_SERVICE_NAME.$p");
		if ($v)
		{
print "IN V IF\n";
		    $params{$p} = $v;
		    $self->{$p} = $v;
		}
	    }
	}
	else
	{ 
	    $self->{dbName} = 'CS_expression';
	    $self->{dbUser} = 'expressionSelect';
	    $self->{dbhost} = 'localhost'; 
	    print "IN CONFIG ELSE\n";
	} 
	#Create a connection to the EXPRESSION (and print a logging debug mssg)
	if( 0 < scalar keys(%params) ) {
	    warn "Connection to Expression Service established with the following non-default parameters:\n";
	    foreach my $key (sort keys %params) { warn "   $key => $params{$key} \n"; }
	} else { warn "Connection to Expression established with all default parameters.\n"; }
print "IN IF\n";
    }
    else
    {
	$self->{dbName} = 'CS_expression';
	$self->{dbUser} = 'expressionSelect';
	$self->{dbhost} = 'localhost';
print "IN ELSE\n";
    }
    print "\nDBNAME : ".  $self->{dbName};
    print "\nDBUSER : ".  $self->{dbUser};
    print "\nDBHOST : ".  $self->{dbhost} . "\n";
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 get_expression_samples_data

  $expressionDataSamplesMap = $obj->get_expression_samples_data($sampleIds)

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleIds is a SampleIDs
$expressionDataSamplesMap is an ExpressionDataSamplesMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$sampleIds is a SampleIDs
$expressionDataSamplesMap is an ExpressionDataSamplesMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text



=item Description

core function used by many others.  Given a list of SampleIds returns mapping of SampleId to SampleDataStructure

=back

=cut

sub get_expression_samples_data
{
    my $self = shift;
    my($sampleIds) = @_;

    my @_bad_arguments;
    (ref($sampleIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sampleIds\" (value was \"$sampleIds\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($expressionDataSamplesMap);
    #BEGIN get_expression_samples_data
    $expressionDataSamplesMap = {};
    if (0 == @{$sampleIds})
    {
	return $expressionDataSamplesMap;
    }

    $self->{dbName} = 'CS_expression';
    $self->{dbUser} = 'expressionSelect';
    $self->{dbhost} = 'localhost';


    my $dbh = DBI->connect('DBI:mysql:'.$self->{db_name}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }  
        );    

#    my $dbh = DBI->connect('DBI:mysql:CS_expression:localhost', 'expressionSelect', '', 
#                           { RaiseError => 1, ShowErrorStatement => 1 } 
#        ); 
    my $get_sample_meta_data_q = qq^select sam.id, sam.source_id, sam.title as sample_title, sam.description as sample_description,  
                                    sam.molecule, sam.type,  
                                    sam.dataSource, sam.externalSourceId, sam.kbaseSubmissionDate, sam.externalSourceDate,  
                                    sam.custom, sam.originalLog2Median, 
                                    str.id, str.referenceStrain, str.wildtype, str.description,  
                                    gen.id, gen.scientific_name, 
                                    plt.id, plt.title as platform_title, plt.technology, eu.id,  
                                    em.id, em.title as experiment_title, em.description as experiment_description, 
                                    env.id, env.description as env_description, 
                                    pro.id, pro.description, pro.name 
                                    from Sample sam  
                                    inner join SampleForStrain sfs on sam.id = sfs.to_link 
                                    inner join Strain str on sfs.from_link = str.id 
                                    inner join GenomeParentOf gpo on str.id = gpo.to_link 
                                    inner join Genome gen on gpo.from_link = gen.id 
                                    left outer join SampleRunOnPlatform srp on sam.id = srp.to_link 
                                    left outer join Platform plt on srp.from_link = plt.id 
                                    left outer join HasExpressionSample hes on sam.id = hes.to_link 
                                    left outer join ExperimentalUnit eu on hes.from_link = eu.id 
                                    left outer join HasExperimentalUnit heu on eu.id = heu.to_link 
                                    left outer join ExperimentMeta em on heu.from_link = em.id 
                                    left outer join IsContextOf ico on eu.id = ico.to_link 
                                    left outer join Environment env on ico.from_link = env.id 
                                    left outer join SampleUsesProtocol sup on sam.id = sup.to_link 
                                    left outer join Protocol pro on sup.from_link = pro.id 
                                    where sam.id in ( ^. 
				 join(",", ("?") x @{$sampleIds}) . ") "; 
    my $get_sample_meta_data_qh = $dbh->prepare($get_sample_meta_data_q) or die "Unable to prepare : get_sample_meta_data_q : ".
	                          $get_sample_meta_data_q . " : " .$dbh->errstr();
    $get_sample_meta_data_qh->execute(@{$sampleIds}) or die "Unable to execute : get_sample_meta_data_q : ".$get_sample_meta_data_qh->errstr();
    while(my ($sample_id, $sample_source_id, $sample_title, $sample_description, $sample_molecule, $sample_type, 
              $sample_dataSource, $sample_externalSourceId, $sample_kbaseSubmissionDate, $sample_externalSourceDate,
              $sample_custom, $sample_originalLog2Median, $strain_id, $referenceStrain, $wildtype, $strain_description, 
	      $genome_id, $scientific_name, $platform_id, $platform_title, $platform_technology, $experimental_unit_id, 
              $experiment_meta_id, $experiment_meta_title, $experiment_meta_description, $environment_id, $environment_description,
              $protocol_id, $protocol_description, $protocol_name) = $get_sample_meta_data_qh->fetchrow_array())
    {
	$expressionDataSamplesMap->{$sample_id}={"sampleId" => $sample_id,
						 "sourceId" => $sample_source_id,
						 "sampleTitle" => $sample_title,
						 "sampleDescription" => $sample_description,
						 "molecule" => $sample_molecule,
						 "sampleType" => $sample_type,
						 "dataSource" => $sample_dataSource,
						 "externalSourceId" => $sample_externalSourceId,
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
						 "platformId" => $platform_id,
						 "platformTitle" => $platform_title,
						 "platformTechnology" => $platform_technology,
						 "experimentalUnitID" => $experimental_unit_id,
						 "experimentMetaID" => $experiment_meta_id,
						 "experimentTitle" => $experiment_meta_title,
						 "experimentDescription" => $experiment_meta_description,
						 "environmentId" => $environment_id,
						 "environmentDescription" => $environment_description,
						 "protocolId" => $protocol_id,
						 "protocolDescription" => $protocol_description,
						 "protocolName" => $protocol_name,
						 "sampleAnnotationIDs" => [],
						 "seriesIds" => [],
						 "personIds" => [],
						 "dataExpressionLevelsForSample" => {}};
    }

    #Sample Annotations
    my $get_sample_annotations_q = qq^select sam.id, san.id 
                                      from Sample sam 
                                      inner join SampleHasAnnotations sha on sam.id = sha.from_link 
                                      inner join SampleAnnotation san on sha.to_link = san.id 
                                      where sam.id in (^.
                                  join(",", ("?") x @{$sampleIds}) . ") "; 
    my $get_sample_annotations_qh = $dbh->prepare($get_sample_annotations_q) or die "Unable to prepare get_sample_annotations_q : ".
	$get_sample_annotations_q . " : " . $dbh->errstr();
    $get_sample_annotations_qh->execute(@{$sampleIds}) or die "Unable to execute get_sample_annotations_q : ".$get_sample_annotations_q.
                                    " : " .$get_sample_annotations_qh->errstr();
    while (my ($sample_id,$sample_annotation_id) = $get_sample_annotations_qh->fetchrow_array()) 
    { 
          push(@{$expressionDataSamplesMap->{$sample_id}->{"sampleAnnotationIDs"}},$sample_annotation_id);
    }        

    #SeriesIds
    my $get_sample_series_ids_q = qq^select sam.id, ser.id
                                     from Sample sam
                                     inner join SampleInSeries sis on sam.id = sis.from_link
                                     inner join Series ser on sis.to_link = ser.id
                                     where sam.id in (^.
                                  join(",", ("?") x @{$sampleIds}) . ") "; 
    my $get_sample_series_ids_qh = $dbh->prepare($get_sample_series_ids_q) or die "Unable to prepare : get_sample_series_ids_q : ".
	$get_sample_series_ids_q . " : " .$dbh->errstr();
    $get_sample_series_ids_qh->execute(@{$sampleIds}) or die "Unable to execute : get_sample_series_ids_q : ".$get_sample_series_ids_qh->errstr();
    while (my ($sample_id,$series_id) = $get_sample_series_ids_qh->fetchrow_array())
    {
          push(@{$expressionDataSamplesMap->{$sample_id}->{"seriesIds"}},$series_id);
    }
    
    #PersonIds     
    my $get_sample_person_ids_q = qq^select sam.id, per.id 
                                     from Sample sam 
                                     inner join SampleContactPerson scp on sam.id = scp.to_link 
                                     inner join Person per on scp.from_link = per.id 
                                     where sam.id in (^.
                                  join(",", ("?") x @{$sampleIds}) . ") ";
    my $get_sample_person_ids_qh = $dbh->prepare($get_sample_person_ids_q) or die "Unable to prepare : get_sample_person_ids_q : ".           
                                   $get_sample_person_ids_q . " : " .$dbh->errstr();        
    $get_sample_person_ids_qh->execute(@{$sampleIds}) or die "Unable to execute : get_sample_person_ids_q : ".$get_sample_person_ids_qh->errstr();  
    while (my ($sample_id,$person_id) = $get_sample_person_ids_qh->fetchrow_array())
    {
        push(@{$expressionDataSamplesMap->{$sample_id}->{"personIds"}},$person_id);
    }

    #log2Levels
    my $get_log2levels_q = qq^select sam.id, fea.id, l2l.log2Level
                              from Sample sam
                              inner join LevelInSample lis on sam.id = lis.from_link
                              inner join Log2Level l2l on lis.to_link = l2l.id
                              inner join LevelForFeature lfl on l2l.id = lfl.to_link
                              inner join Feature fea on lfl.from_link = fea.id
                              where sam.id in (^. 
                           join(",", ("?") x @{$sampleIds}) . ") ";  
    my $get_log2levels_qh = $dbh->prepare($get_log2levels_q) or die "Unable to prepare get_log2levels_q : ".
                            $get_log2levels_q . " : " . $dbh->errstr();
    $get_log2levels_qh->execute(@{$sampleIds}) or die "Unable to execute get_log2levels_q : " . $get_log2levels_q . " : ".
                            $get_log2levels_qh->errstr();
    while(my ($sample_id, $feature_id, $log2level) = $get_log2levels_qh->fetchrow_array())
    {
        $expressionDataSamplesMap->{$sample_id}->{"dataExpressionLevelsForSample"}->{$feature_id} = $log2level;
    }
    #END get_expression_samples_data
    my @_bad_returns;
    (ref($expressionDataSamplesMap) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"expressionDataSamplesMap\" (value was \"$expressionDataSamplesMap\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data');
    }
    return($expressionDataSamplesMap);
}




=head2 get_expression_samples_data_by_series_ids

  $seriesExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_series_ids($seriesIds)

=over 4

=item Parameter and return types

=begin html

<pre>
$seriesIds is a SeriesIDs
$seriesExpressionDataSamplesMapping is a SeriesExpressionDataSamplesMapping
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesExpressionDataSamplesMapping is a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$seriesIds is a SeriesIDs
$seriesExpressionDataSamplesMapping is a SeriesExpressionDataSamplesMapping
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesExpressionDataSamplesMapping is a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text



=item Description

given a list of SeriesIds returns mapping of SeriesId to expressionDataSamples

=back

=cut

sub get_expression_samples_data_by_series_ids
{
    my $self = shift;
    my($seriesIds) = @_;

    my @_bad_arguments;
    (ref($seriesIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"seriesIds\" (value was \"$seriesIds\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_series_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($seriesExpressionDataSamplesMapping);
    #BEGIN get_expression_samples_data_by_series_ids
    $seriesExpressionDataSamplesMapping = {};
    if (0 == @{$seriesIds}) 
    { 
        return $seriesExpressionDataSamplesMapping;
    } 
#    my $dbh = DBI->connect('DBI:mysql:CS_expression:localhost', 'expressionSelect', '', 
#                           { RaiseError => 1, ShowErrorStatement => 1 } 
#        ); 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{db_name}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 

    my $get_sample_ids_by_series_ids_q = 
        qq^select ser.id, sam.id
           from Sample sam 
           inner join SampleInSeries sis on sam.id = sis.from_link
           inner join Series ser on sis.to_link = ser.id
           where ser.id in (^.
	join(",", ("?") x @{$seriesIds}) . ") "; 
    my $get_sample_ids_by_series_ids_qh = $dbh->prepare($get_sample_ids_by_series_ids_q) or die
                                                "Unable to prepare get_sample_ids_by_series_ids_q : ". 
                                                $get_sample_ids_by_series_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_series_ids_qh->execute(@{$seriesIds}) or die "Unable to execute get_sample_ids_by_series_ids_q : ".
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
    $seriesExpressionDataSamplesMapping = \%series_id_sample_data_hash;
    #END get_expression_samples_data_by_series_ids
    my @_bad_returns;
    (ref($seriesExpressionDataSamplesMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"seriesExpressionDataSamplesMapping\" (value was \"$seriesExpressionDataSamplesMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_series_ids');
    }
    return($seriesExpressionDataSamplesMapping);
}




=head2 get_expression_samples_data_by_experimental_unit_ids

  $experimentalUnitExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_experimental_unit_ids($experimentalUnitIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$experimentalUnitIDs is an ExperimentalUnitIDs
$experimentalUnitExpressionDataSamplesMapping is an ExperimentalUnitExpressionDataSamplesMapping
ExperimentalUnitIDs is a reference to a list where each element is an ExperimentalUnitID
ExperimentalUnitID is a string
ExperimentalUnitExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$experimentalUnitIDs is an ExperimentalUnitIDs
$experimentalUnitExpressionDataSamplesMapping is an ExperimentalUnitExpressionDataSamplesMapping
ExperimentalUnitIDs is a reference to a list where each element is an ExperimentalUnitID
ExperimentalUnitID is a string
ExperimentalUnitExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text



=item Description

given a list of ExperimentalUnitIds returns mapping of ExperimentalUnitId to expressionDataSamples

=back

=cut

sub get_expression_samples_data_by_experimental_unit_ids
{
    my $self = shift;
    my($experimentalUnitIDs) = @_;

    my @_bad_arguments;
    (ref($experimentalUnitIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"experimentalUnitIDs\" (value was \"$experimentalUnitIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_experimental_unit_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($experimentalUnitExpressionDataSamplesMapping);
    #BEGIN get_expression_samples_data_by_experimental_unit_ids
    $experimentalUnitExpressionDataSamplesMapping = {};
    if (0 == @{$experimentalUnitIDs})
    { 
        return $experimentalUnitExpressionDataSamplesMapping; 
    }
#    my $dbh = DBI->connect('DBI:mysql:CS_expression:localhost', 'expressionSelect', '', 
#                           { RaiseError => 1, ShowErrorStatement => 1 } 
#        ); 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{db_name}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 

    my $get_sample_ids_by_experimental_unit_ids_q = 
        qq^select eu.id, sam.id           
           from  Sample sam
           inner join HasExpressionSample hes on sam.id = hes.to_link
           inner join ExperimentalUnit eu on hes.from_link = eu.id
           where eu.id in (^.
	   join(",", ("?") x @{$experimentalUnitIDs}) . ") "; 
    my $get_sample_ids_by_experimental_unit_ids_qh = $dbh->prepare($get_sample_ids_by_experimental_unit_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_experimental_unit_ids_q : ". 
                                                              $get_sample_ids_by_experimental_unit_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_experimental_unit_ids_qh->execute(@{$experimentalUnitIDs}) or die "Unable to execute get_sample_ids_by_experimental_unit_ids_q : ". 
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
    $experimentalUnitExpressionDataSamplesMapping = \%exp_unit_sample_data_hash; 
    #END get_expression_samples_data_by_experimental_unit_ids
    my @_bad_returns;
    (ref($experimentalUnitExpressionDataSamplesMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"experimentalUnitExpressionDataSamplesMapping\" (value was \"$experimentalUnitExpressionDataSamplesMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_experimental_unit_ids');
    }
    return($experimentalUnitExpressionDataSamplesMapping);
}




=head2 get_expression_experimental_unit_samples_data_by_experiment_meta_ids

  $experimentMetaExpressionDataSamplesMapping = $obj->get_expression_experimental_unit_samples_data_by_experiment_meta_ids($experimentMetaIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$experimentMetaIDs is an ExperimentMetaIDs
$experimentMetaExpressionDataSamplesMapping is an ExperimentMetaExpressionDataSamplesMapping
ExperimentMetaIDs is a reference to a list where each element is an ExperimentMetaID
ExperimentMetaID is a string
ExperimentMetaExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentMetaID and the value is an ExperimentalUnitExpressionDataSamplesMapping
ExperimentalUnitExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
ExperimentalUnitID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$experimentMetaIDs is an ExperimentMetaIDs
$experimentMetaExpressionDataSamplesMapping is an ExperimentMetaExpressionDataSamplesMapping
ExperimentMetaIDs is a reference to a list where each element is an ExperimentMetaID
ExperimentMetaID is a string
ExperimentMetaExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentMetaID and the value is an ExperimentalUnitExpressionDataSamplesMapping
ExperimentalUnitExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
ExperimentalUnitID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text



=item Description

given a list of ExperimentMetaIds returns mapping of ExperimentId to experimentalUnitExpressionDataSamplesMapping

=back

=cut

sub get_expression_experimental_unit_samples_data_by_experiment_meta_ids
{
    my $self = shift;
    my($experimentMetaIDs) = @_;

    my @_bad_arguments;
    (ref($experimentMetaIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"experimentMetaIDs\" (value was \"$experimentMetaIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_experimental_unit_samples_data_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_experimental_unit_samples_data_by_experiment_meta_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($experimentMetaExpressionDataSamplesMapping);
    #BEGIN get_expression_experimental_unit_samples_data_by_experiment_meta_ids
    $experimentMetaExpressionDataSamplesMapping = {}; 
    if (0 == @{$experimentMetaIDs}) 
    { 
        return $experimentMetaExpressionDataSamplesMapping; 
    } 
#    my $dbh = DBI->connect('DBI:mysql:CS_expression:localhost', 'expressionSelect', '', 
#			   { RaiseError => 1, ShowErrorStatement => 1 } 
#	); 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{db_name}.':'.$self->{dbhost}, $self->{dbUser}, '',
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
           join(",", ("?") x @{$experimentMetaIDs}) . ") "; 
    my $get_experimental_unit_ids_by_experiment_meta_ids_qh = $dbh->prepare($get_experimental_unit_ids_by_experiment_meta_ids_q) or die
                                                              "Unable to prepare get_experimental_unit_ids_by_experiment_meta_ids_q : ".
                                                              $get_experimental_unit_ids_by_experiment_meta_ids_q . " : " . dbh->errstr() . "\n\n";
    $get_experimental_unit_ids_by_experiment_meta_ids_qh->execute(@{$experimentMetaIDs}) or die "Unable to execute get_experimental_unit_ids_by_experiment_meta_ids_q : ".
        $get_experimental_unit_ids_by_experiment_meta_ids_q . " : " . $get_experimental_unit_ids_by_experiment_meta_ids_qh->errstr() . "\n\n";
    while (my ($experiment_meta_id, $experimental_unit_id) = $get_experimental_unit_ids_by_experiment_meta_ids_qh->fetchrow_array())
    { 
        $experimentMetaExpressionDataSamplesMapping_hash{$experiment_meta_id}->{$experimental_unit_id}=1;
        $experimental_unit_ids_hash{$experimental_unit_id}=1; 
    } 
    my @distinct_experimental_unit_ids = keys(%experimental_unit_ids_hash); 
    my %experimentalUnitExpressionDataSamplesMapping = %{$self->get_expression_samples_data_by_experimental_unit_ids(\@distinct_experimental_unit_ids)};
    my %return_expmeta_data_hash; 
    foreach my $experiment_meta_id (keys(%experimentMetaExpressionDataSamplesMapping_hash))
    { 
        my %exp_unit_hash = %{$experimentMetaExpressionDataSamplesMapping_hash{$experiment_meta_id}};
        foreach my $experimental_unit_id (keys(%exp_unit_hash))
        {
            $return_expmeta_data_hash{$experiment_meta_id}->{$experimental_unit_id}=$experimentalUnitExpressionDataSamplesMapping{$experimental_unit_id};
        }
    }
    $experimentMetaExpressionDataSamplesMapping = \%return_expmeta_data_hash;       
    #END get_expression_experimental_unit_samples_data_by_experiment_meta_ids
    my @_bad_returns;
    (ref($experimentMetaExpressionDataSamplesMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"experimentMetaExpressionDataSamplesMapping\" (value was \"$experimentMetaExpressionDataSamplesMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_experimental_unit_samples_data_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_experimental_unit_samples_data_by_experiment_meta_ids');
    }
    return($experimentMetaExpressionDataSamplesMapping);
}




=head2 get_expression_samples_data_by_strain_ids

  $strainExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_strain_ids($strainIDs, $sampleType)

=over 4

=item Parameter and return types

=begin html

<pre>
$strainIDs is a StrainIDs
$sampleType is a SampleType
$strainExpressionDataSamplesMapping is a StrainExpressionDataSamplesMapping
StrainIDs is a reference to a list where each element is a StrainID
StrainID is a string
SampleType is a string
StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$strainIDs is a StrainIDs
$sampleType is a SampleType
$strainExpressionDataSamplesMapping is a StrainExpressionDataSamplesMapping
StrainIDs is a reference to a list where each element is a StrainID
StrainID is a string
SampleType is a string
StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text



=item Description

given a list of Strains, and a SampleType, it returns a StrainExpressionDataSamplesMapping,  StrainId -> ExpressionDataSample

=back

=cut

sub get_expression_samples_data_by_strain_ids
{
    my $self = shift;
    my($strainIDs, $sampleType) = @_;

    my @_bad_arguments;
    (ref($strainIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"strainIDs\" (value was \"$strainIDs\")");
    (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument \"sampleType\" (value was \"$sampleType\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_strain_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($strainExpressionDataSamplesMapping);
    #BEGIN get_expression_samples_data_by_strain_ids
    $strainExpressionDataSamplesMapping = {};
    if(0 == @{$strainIDs})
    {
	return $strainExpressionDataSamplesMapping;
    }
    my $sample_type_part = ""; 
    if ((uc($sampleType) eq "RNA-SEQ") || (uc($sampleType) eq "RNA_SEQ") || (uc($sampleType) eq "RNASEQ") || (uc($sampleType) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sampleType) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sampleType) eq "MICROARRAY") 
    { 
        $sample_type_part = " and sam.type = 'microarray' "; 
    } 
    elsif(uc($sampleType) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.                                                                                                                                                           
    } 
#    my $dbh = DBI->connect('DBI:mysql:CS_expression:localhost', 'expressionSelect', '', 
#                           { RaiseError => 1, ShowErrorStatement => 1 } 
#        ); 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{db_name}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 

    my $get_sample_ids_by_strain_ids_q = 
        qq^select str.id, sam.id
           from Sample sam 
           inner join SampleForStrain sfs on sam.id = sfs.to_link
           inner join Strain str on sfs.from_link = str.id 
           where str.id in (^. 
	join(",", ("?") x @{$strainIDs}) . ") ".
	$sample_type_part;
    my $get_sample_ids_by_strain_ids_qh = $dbh->prepare($get_sample_ids_by_strain_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_strain_ids_q : ". 
                                                              $get_sample_ids_by_strain_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_strain_ids_qh->execute(@{$strainIDs}) or die "Unable to execute get_sample_ids_by_strain_ids_q : ". 
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
    $strainExpressionDataSamplesMapping = \%strain_id_sample_data_hash; 
    #END get_expression_samples_data_by_strain_ids
    my @_bad_returns;
    (ref($strainExpressionDataSamplesMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"strainExpressionDataSamplesMapping\" (value was \"$strainExpressionDataSamplesMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_strain_ids');
    }
    return($strainExpressionDataSamplesMapping);
}




=head2 get_expression_samples_data_by_genome_ids

  $genomeExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_genome_ids($genomeIDs, $sampleType, $wildTypeOnly)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeIDs is a GenomeIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$genomeExpressionDataSamplesMapping is a GenomeExpressionDataSamplesMapping
GenomeIDs is a reference to a list where each element is a GenomeID
GenomeID is a string
SampleType is a string
WildTypeOnly is an int
GenomeExpressionDataSamplesMapping is a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping
StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
StrainID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$genomeIDs is a GenomeIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$genomeExpressionDataSamplesMapping is a GenomeExpressionDataSamplesMapping
GenomeIDs is a reference to a list where each element is a GenomeID
GenomeID is a string
SampleType is a string
WildTypeOnly is an int
GenomeExpressionDataSamplesMapping is a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping
StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
StrainID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
	externalSourceDate has a value which is a string
	kbaseSubmissionDate has a value which is a string
	custom has a value which is a string
	originalLog2Median has a value which is a float
	strainID has a value which is a StrainID
	referenceStrain has a value which is a string
	wildtype has a value which is a string
	strainDescription has a value which is a string
	genomeID has a value which is a GenomeID
	genomeScientificName has a value which is a string
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text



=item Description

given a list of Genomes, a SampleType and a int indicating WildType Only (1 = true, 0 = false) , it returns a GenomeExpressionDataSamplesMapping   ,  Genome -> StrainId -> ExpressionDataSample

=back

=cut

sub get_expression_samples_data_by_genome_ids
{
    my $self = shift;
    my($genomeIDs, $sampleType, $wildTypeOnly) = @_;

    my @_bad_arguments;
    (ref($genomeIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"genomeIDs\" (value was \"$genomeIDs\")");
    (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument \"sampleType\" (value was \"$sampleType\")");
    (!ref($wildTypeOnly)) or push(@_bad_arguments, "Invalid type for argument \"wildTypeOnly\" (value was \"$wildTypeOnly\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_genome_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($genomeExpressionDataSamplesMapping);
    #BEGIN get_expression_samples_data_by_genome_ids
    $genomeExpressionDataSamplesMapping = {};
    if (0 == @{$genomeIDs})
    {
	return $genomeExpressionDataSamplesMapping;
    }

print "\nDBNAME : ".  $self->{dbName};
print "\nDBUSER : ".  $self->{dbUser}; 
print "\nDBHOST : ".  $self->{dbhost} . "\n"; 

my $connect1 = 'DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost};
my $connect2 = $self->{dbUser};

print "CONNECT 1 &".$connect1."&\n";
print "CONNECT 2 &".$connect2."&\n";

#    my $dbh = DBI->connect($connect1, $connect2, '', 
#                           { RaiseError => 1, ShowErrorStatement => 1 } 
#        ); 


#    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
#                           { RaiseError => 1, ShowErrorStatement => 1 } 
#        ); 
    my $dbh = DBI->connect('DBI:mysql:CS_expression:localhost', 'expressionSelect', '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
    my $wild_type_part = "";
    if (($wildTypeOnly eq "1") || (uc($wildTypeOnly) eq "Y") || (uc($wildTypeOnly) eq "TRUE"))
    {
	$wild_type_part = " and str.wildType = 'Y' ";
    }
    my $sample_type_part = "";
    if ((uc($sampleType) eq "RNA-SEQ") || (uc($sampleType) eq "RNA_SEQ") || (uc($sampleType) eq "RNASEQ") || (uc($sampleType) eq "RNA SEQ"))
    {
	$sample_type_part = " and sam.type = 'RNA-Seq' ";
    }
    elsif(uc($sampleType) eq "QPCR")
    {
	$sample_type_part = " and sam.type = 'qPCR' ";
    }
    elsif(uc($sampleType) eq "MICROARRAY")
    {
	$sample_type_part = " and sam.type = 'microarray' ";
    }
    elsif(uc($sampleType) eq "PROTEOMICS")
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
           inner join SampleForStrain sfs on sam.id = sfs.to_link
           inner join Strain str on sfs.from_link = str.id
           inner join GenomeParentOf gpo on str.id = gpo.to_link
           inner join Genome gen on gpo.from_link = gen.id
           where gen.id in (^.
	   join(",", ("?") x @{$genomeIDs}). ") ". 
	   $wild_type_part . 
	   $sample_type_part;
    my $get_strain_ids_by_genome_ids_qh = $dbh->prepare($get_strain_ids_by_genome_ids_q) or die 
                                                              "Unable to prepare get_strain_ids_by_genome_ids_q : ". 
                                                              $get_strain_ids_by_genome_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_strain_ids_by_genome_ids_qh->execute(@{$genomeIDs}) or die "Unable to execute get_strain_ids_by_genome_ids_q : ". 
        $get_strain_ids_by_genome_ids_q . " : " . $get_strain_ids_by_genome_ids_qh->errstr() . "\n\n"; 
    while (my ($genome_id, $strain_id) = $get_strain_ids_by_genome_ids_qh->fetchrow_array()) 
    { 
        $genome_strain_id_hash{$genome_id}->{$strain_id}=1; 
        $strain_ids_hash{$strain_id}=1; 
    } 
    my @distinct_strain_ids = keys(%strain_ids_hash); 
    my %strainExpressionDataSamplesMapping = %{$self->get_expression_samples_data_by_strain_ids(\@distinct_strain_ids, $sampleType)}; 
 
    my %return_genome_data_hash; 
    foreach my $genome_id (keys(%genome_strain_id_hash)) 
    { 
	my %strain_hash = %{$genome_strain_id_hash{$genome_id}};
	foreach my $strain_id (keys(%strain_hash))
	{
	    $return_genome_data_hash{$genome_id}->{$strain_id} = $strainExpressionDataSamplesMapping{$strain_id};
	}
    } 
    $genomeExpressionDataSamplesMapping = \%return_genome_data_hash;              
    #END get_expression_samples_data_by_genome_ids
    my @_bad_returns;
    (ref($genomeExpressionDataSamplesMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"genomeExpressionDataSamplesMapping\" (value was \"$genomeExpressionDataSamplesMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_genome_ids');
    }
    return($genomeExpressionDataSamplesMapping);
}




=head2 get_expression_data_by_feature_ids

  $featureSampleLog2LevelMapping = $obj->get_expression_data_by_feature_ids($featureIds, $sampleType, $wildTypeOnly)

=over 4

=item Parameter and return types

=begin html

<pre>
$featureIds is a FeatureIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$featureSampleLog2LevelMapping is a FeatureSampleLog2LevelMapping
FeatureIDs is a reference to a list where each element is a FeatureID
FeatureID is a string
SampleType is a string
WildTypeOnly is an int
FeatureSampleLog2LevelMapping is a reference to a hash where the key is a FeatureID and the value is a SampleLog2LevelMapping
SampleLog2LevelMapping is a reference to a hash where the key is a SampleID and the value is a Log2Level
SampleID is a string
Log2Level is a float

</pre>

=end html

=begin text

$featureIds is a FeatureIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$featureSampleLog2LevelMapping is a FeatureSampleLog2LevelMapping
FeatureIDs is a reference to a list where each element is a FeatureID
FeatureID is a string
SampleType is a string
WildTypeOnly is an int
FeatureSampleLog2LevelMapping is a reference to a hash where the key is a FeatureID and the value is a SampleLog2LevelMapping
SampleLog2LevelMapping is a reference to a hash where the key is a SampleID and the value is a Log2Level
SampleID is a string
Log2Level is a float


=end text



=item Description

given a list of FeatureIds, a SampleType and a int indicating WildType Only (1 = true, 0 = false) returns a FeatureSampleLog2LevelMapping : featureId->{sample_id->log2Level}

=back

=cut

sub get_expression_data_by_feature_ids
{
    my $self = shift;
    my($featureIds, $sampleType, $wildTypeOnly) = @_;

    my @_bad_arguments;
    (ref($featureIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"featureIds\" (value was \"$featureIds\")");
    (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument \"sampleType\" (value was \"$sampleType\")");
    (!ref($wildTypeOnly)) or push(@_bad_arguments, "Invalid type for argument \"wildTypeOnly\" (value was \"$wildTypeOnly\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_data_by_feature_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_data_by_feature_ids');
    }

    my $ctx = $ExpressionServicesServer::CallContext;
    my($featureSampleLog2LevelMapping);
    #BEGIN get_expression_data_by_feature_ids
    $featureSampleLog2LevelMapping = {};
    if (0 == @{$featureIds})
    {
	return $featureSampleLog2LevelMapping; 
    }

    print "\nDBNAME : ".  $self->{dbName};
    print "\nDBUSER : ".  $self->{dbUser}; 
    print "\nDBHOST : ".  $self->{dbhost} . "\n"; 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{db_name}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 

#    my $dbh = DBI->connect('DBI:mysql:CS_expression:localhost', 'expressionSelect', '', 
#                           { RaiseError => 1, ShowErrorStatement => 1 } 
#        ); 
    my $wild_type_part = ""; 
    if (($wildTypeOnly eq "1") || (uc($wildTypeOnly) eq "Y") || (uc($wildTypeOnly) eq "TRUE")) 
    { 
        $wild_type_part = " and str.wildType = 'Y' "; 
    } 
    my $sample_type_part = ""; 
    if ((uc($sampleType) eq "RNA-SEQ") || (uc($sampleType) eq "RNA_SEQ") || (uc($sampleType) eq "RNASEQ") || (uc($sampleType) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sampleType) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sampleType) eq "MICROARRAY") 
    { 
        $sample_type_part = " and sam.type = 'microarray' "; 
    } 
    elsif(uc($sampleType) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.   
    } 
    my $get_feature_log2level_q = qq^select sam.id, fea.id, l2l.log2Level
                                     from Sample sam
                                     inner join LevelInSample lis on sam.id = lis.from_link
                                     inner join Log2Level l2l on lis.to_link = l2l.id
                                     inner join LevelForFeature lfl on l2l.id = lfl.to_link
                                     inner join Feature fea on lfl.from_link = fea.id
                                     inner join SampleForStrain sfs on sam.id = sfs.to_link
                                     inner join Strain str on sfs.from_link = str.id
                                     where fea.id in (^.
                                 join(",", ("?") x @{$featureIds}). ") ". 
                                 $wild_type_part . 
                                 $sample_type_part; 
    my $get_feature_log2level_qh = $dbh->prepare($get_feature_log2level_q) or die "Unable to prepare get_feature_log2level_q : ".
	$get_feature_log2level_q . " : " .$dbh->errstr();
    $get_feature_log2level_qh->execute(@{$featureIds})  or die "Unable to execute get_feature_log2level_q : ".
        $get_feature_log2level_q . " : " .$get_feature_log2level_qh->errstr(); 
    while(my ($sample_id,$feature_id,$log2level) = $get_feature_log2level_qh->fetchrow_array())
    {
	$featureSampleLog2LevelMapping->{$feature_id}->{$sample_id}=$log2level;
    }
    #END get_expression_data_by_feature_ids
    my @_bad_returns;
    (ref($featureSampleLog2LevelMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"featureSampleLog2LevelMapping\" (value was \"$featureSampleLog2LevelMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_data_by_feature_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_data_by_feature_ids');
    }
    return($featureSampleLog2LevelMapping);
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



=head2 FeatureID

=over 4



=item Description

KBase Feature ID for a feature, typically CDS/PEG


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



=head2 FeatureIDs

=over 4



=item Description

KBase list of Feature IDs , typically CDS/PEG


=item Definition

=begin html

<pre>
a reference to a list where each element is a FeatureID
</pre>

=end html

=begin text

a reference to a list where each element is a FeatureID

=end text

=back



=head2 Log2Level

=over 4



=item Description

Log2Level (Zero median normalized within a sample) for a given feature


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



=head2 SampleID

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



=head2 SampleIDs

=over 4



=item Description

List of KBase Sample IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is a SampleID
</pre>

=end html

=begin text

a reference to a list where each element is a SampleID

=end text

=back



=head2 SampleType

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



=head2 SeriesID

=over 4



=item Description

Kbase Series Id


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



=head2 SeriesIDs

=over 4



=item Description

list of KBase Series Ids


=item Definition

=begin html

<pre>
a reference to a list where each element is a SeriesID
</pre>

=end html

=begin text

a reference to a list where each element is a SeriesID

=end text

=back



=head2 ExperimentMetaID

=over 4



=item Description

Kbase ExperimentMeta Id


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



=head2 ExperimentMetaIDs

=over 4



=item Description

list of KBase ExperimentMeta Ids


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExperimentMetaID
</pre>

=end html

=begin text

a reference to a list where each element is an ExperimentMetaID

=end text

=back



=head2 ExperimentalUnitID

=over 4



=item Description

Kbase ExperimentalUnitId


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



=head2 ExperimentalUnitIDs

=over 4



=item Description

list of KBase ExperimentUnitIds


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExperimentalUnitID
</pre>

=end html

=begin text

a reference to a list where each element is an ExperimentalUnitID

=end text

=back



=head2 DataExpressionLevelsForSample

=over 4



=item Description

mapping kbase feature id as the key and log2level as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a FeatureID and the value is a Log2Level
</pre>

=end html

=begin text

a reference to a hash where the key is a FeatureID and the value is a Log2Level

=end text

=back



=head2 SampleAnnotationID

=over 4



=item Description

Kbase SampleAnnotation Id


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



=head2 SampleAnnotationIDs

=over 4



=item Description

list of KBase SampleAnnotation Ids


=item Definition

=begin html

<pre>
a reference to a list where each element is a SampleAnnotationID
</pre>

=end html

=begin text

a reference to a list where each element is a SampleAnnotationID

=end text

=back



=head2 PersonID

=over 4



=item Description

Kbase Person Id


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



=head2 PersonIDs

=over 4



=item Description

list of KBase PersonsIds


=item Definition

=begin html

<pre>
a reference to a list where each element is a PersonID
</pre>

=end html

=begin text

a reference to a list where each element is a PersonID

=end text

=back



=head2 StrainID

=over 4



=item Description

KBase StrainId


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



=head2 StrainIDs

=over 4



=item Description

list of KBase StrainIds


=item Definition

=begin html

<pre>
a reference to a list where each element is a StrainID
</pre>

=end html

=begin text

a reference to a list where each element is a StrainID

=end text

=back



=head2 GenomeID

=over 4



=item Description

KBase GenomeId


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



=head2 GenomeIDs

=over 4



=item Description

list of KBase GenomeIds


=item Definition

=begin html

<pre>
a reference to a list where each element is a GenomeID
</pre>

=end html

=begin text

a reference to a list where each element is a GenomeID

=end text

=back



=head2 WildTypeOnly

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

Data structure for all the top level metadata and value data for an expression sample


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
sampleId has a value which is a SampleID
sourceId has a value which is a string
sampleTitle has a value which is a string
sampleDescription has a value which is a string
molecule has a value which is a string
sampleType has a value which is a SampleType
dataSource has a value which is a string
externalSourceId has a value which is a string
externalSourceDate has a value which is a string
kbaseSubmissionDate has a value which is a string
custom has a value which is a string
originalLog2Median has a value which is a float
strainID has a value which is a StrainID
referenceStrain has a value which is a string
wildtype has a value which is a string
strainDescription has a value which is a string
genomeID has a value which is a GenomeID
genomeScientificName has a value which is a string
platformId has a value which is a string
platformTitle has a value which is a string
platformTechnology has a value which is a string
experimentalUnitID has a value which is an ExperimentalUnitID
experimentMetaID has a value which is an ExperimentMetaID
experimentTitle has a value which is a string
experimentDescription has a value which is a string
environmentId has a value which is a string
environmentDescription has a value which is a string
protocolId has a value which is a string
protocolDescription has a value which is a string
protocolName has a value which is a string
sampleAnnotationIDs has a value which is a SampleAnnotationIDs
seriesIds has a value which is a SeriesIDs
personIds has a value which is a PersonIDs
dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
sampleId has a value which is a SampleID
sourceId has a value which is a string
sampleTitle has a value which is a string
sampleDescription has a value which is a string
molecule has a value which is a string
sampleType has a value which is a SampleType
dataSource has a value which is a string
externalSourceId has a value which is a string
externalSourceDate has a value which is a string
kbaseSubmissionDate has a value which is a string
custom has a value which is a string
originalLog2Median has a value which is a float
strainID has a value which is a StrainID
referenceStrain has a value which is a string
wildtype has a value which is a string
strainDescription has a value which is a string
genomeID has a value which is a GenomeID
genomeScientificName has a value which is a string
platformId has a value which is a string
platformTitle has a value which is a string
platformTechnology has a value which is a string
experimentalUnitID has a value which is an ExperimentalUnitID
experimentMetaID has a value which is an ExperimentMetaID
experimentTitle has a value which is a string
experimentDescription has a value which is a string
environmentId has a value which is a string
environmentDescription has a value which is a string
protocolId has a value which is a string
protocolDescription has a value which is a string
protocolName has a value which is a string
sampleAnnotationIDs has a value which is a SampleAnnotationIDs
seriesIds has a value which is a SeriesIDs
personIds has a value which is a PersonIDs
dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample


=end text

=back



=head2 ExpressionDataSamplesMap

=over 4



=item Description

Mapping between sampleId and ExpressionDataSample


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
</pre>

=end html

=begin text

a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample

=end text

=back



=head2 SeriesExpressionDataSamplesMapping

=over 4



=item Description

mapping between seriesIds and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap
</pre>

=end html

=begin text

a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap

=end text

=back



=head2 ExperimentalUnitExpressionDataSamplesMapping

=over 4



=item Description

mapping between experimentalUnitIds and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
</pre>

=end html

=begin text

a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap

=end text

=back



=head2 ExperimentMetaExpressionDataSamplesMapping

=over 4



=item Description

mapping between experimentMetaIds and ExperimentalUnitExpressionDataSamplesMapping it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExperimentMetaID and the value is an ExperimentalUnitExpressionDataSamplesMapping
</pre>

=end html

=begin text

a reference to a hash where the key is an ExperimentMetaID and the value is an ExperimentalUnitExpressionDataSamplesMapping

=end text

=back



=head2 StrainExpressionDataSamplesMapping

=over 4



=item Description

mapping between strainIds and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
</pre>

=end html

=begin text

a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap

=end text

=back



=head2 GenomeExpressionDataSamplesMapping

=over 4



=item Description

mapping between genomeIds and all StrainExpressionDataSamplesMapping it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping
</pre>

=end html

=begin text

a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping

=end text

=back



=head2 SampleLog2LevelMapping

=over 4



=item Description

mapping kbase sample id as the key and a single log2level (for a scpecified feature id, one mapping higher) as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SampleID and the value is a Log2Level
</pre>

=end html

=begin text

a reference to a hash where the key is a SampleID and the value is a Log2Level

=end text

=back



=head2 FeatureSampleLog2LevelMapping

=over 4



=item Description

mapping between FeatureIds and the mappings between samples and log2level mapping


=item Definition

=begin html

<pre>
a reference to a hash where the key is a FeatureID and the value is a SampleLog2LevelMapping
</pre>

=end html

=begin text

a reference to a hash where the key is a FeatureID and the value is a SampleLog2LevelMapping

=end text

=back



=cut

1;
