package Bio::KBase::ExpressionServices::GEO2TypedObjects;
use strict;
use Statistics::Descriptive;
#use Bio::KBase::Exceptions;
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
use Config::Simple;
use Data::Dumper; 
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
use IO::File; 
use Bio::DB::Taxonomy;
use Bio::KBase;
use Bio::KBase::CDMI::CDMIClient; 
use JSON::RPC::Client; 
use JSON;
use Bio::KBase::IDServer::Client;

#require Exporter;

our (@ISA,@EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(new geo2TypedObjects);


#SUBROUTINES
#new
#trim      -removes beginning and trailing white space
 
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
            my $EXPRESSION_SERVICE_NAME = $ENV{KB_SERVICE_NAME}; 
            my $c = Config::Simple->new(); 
            $c->read($e); 
	    my %temp_hash = $c->vars();
            my @param_list = qw(dbName dbUser dbhost); 
            for my $p (@param_list) 
            { 
                my $v = $c->param("$EXPRESSION_SERVICE_NAME.$p"); 
                if ($v) 
                { 
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
        } 
        #Create a connection to the EXPRESSION (and print a logging debug mssg)              
	if( 0 < scalar keys(%params) ) { 
            warn "Connection to Expression Service established with the following non-default parameters:\n"; 
            foreach my $key (sort keys %params) { warn "   $key => $params{$key} \n"; } 
        } else { warn "Connection to Expression established with all default parameters.\n"; } 
    } 
    else 
    { 
         $self->{dbName} = 'expression'; 
         $self->{dbUser} = 'expressionselect';
         $self->{dbhost} = 'db1.chicago.kbase.us'; 
    } 
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}


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

sub geo2TypedObjects
{
    #Takes in 2 arguements :
    # 1) a file path and name to a GSE Object in JSON format 
    # 2) data source
    # 3) directory of geo_results (running list of files storing ids and results of geo objects)
    # 4) directory where to write the workspace typed objects in json format
    #returns a "1"  if successful or a "0 - error_string" if failed
    
    #This does checking for existing Platform, Samples and Series being created by looking in the contents
    #of the platforms, samples and series files located in $geo_results_directory (arg3)

    #The typed objects will be stored in json format in $typed_objects_directory (arg4)

    my $self = shift;
    my $gse_object_file = shift;
    my $data_source = shift;
    my $geo_results_directory = shift;
    my $typed_objects_directory = shift;

    open (JSON_FILE,$gse_object_file) or die "0 - Unable to open $gse_object_file , it was supposed to exist"; 
    my ($json_result,@temp_array)= (<JSON_FILE>); 
    close(JSON_FILE);
    my $gse_object_ref = from_json($json_result);

    my $gse_results_file = $geo_results_directory."/gse_results";
    my $gpl_results_file = $geo_results_directory."/gpl_results";
    my $gsm_results_file = $geo_results_directory."/gsm_results";

    my $id_server = Bio::KBase::IDServer::Client->new("http://kbase.us/services/idserver"); 

    my %processed_gse_hash = get_processed_gse_hash($gse_results_file); #returns a hash key gse_id => {"id" => kb|series.#,
                                                                        #                              "result" => result}
    my %processed_gpl_hash = get_processed_gpl_hash($gpl_results_file); #returns a hash key gpl_id => value kb|platform.#
    my %processed_gsm_hash = get_processed_gsm_hash($gsm_results_file); 
                      #returns a hash key gsm_id => {genome => {data_quality_level => value kb|sample.#

    my $current_gse_id = $gse_object_ref->{'gseID'};
    my %sample_ids_already_in_series;

    if(exists($processed_gse_hash{$current_gse_id}{"sample_ids"}))
    {
	my @sample_ids_array = split("\s*,\s*",$processed_gse_hash{$current_gse_id}{"sample_ids"});
	foreach my $sample_id (@sample_ids_array)
	{
	    $sample_ids_already_in_series{$sample_id} = 1;
	}
    }
    else
    {
	delete($processed_gse_hash{$current_gse_id});
    }

    #check if GSE has errors
    my @gse_errors = @{$gse_object_ref->{'gseErrors'}};
    if (scalar(@gse_errors) > 0)
    {
	if ((exists($processed_gse_hash{$current_gse_id})))
	{
	    return "1";
	}
	else
	{
	    delete($processed_gse_hash{$current_gse_id});
	}
        #write out gse record result
        open (GSE_RESULTS_FILE, ">>".$gse_results_file) or return "0 - Unable to make/append to $gse_results_file \n"; 
        #the first column is the GSE_ID      
        #the second column is the KBase Series ID (if it exists) 
        #the third column is the upload result (3 possible values "Full Success","Partial Success"(some of GSMs passed, but not all),"Failure"  
        #the fourth column is the warning and error messages (separated by "___", 3 underscores)                                             
	#the fifth column is comma separated list of ids for the samples that the series contains.

        #GRAB ERRORS REMOVE "\n", concatenate with 3 underscores
        my $gse_error_message = join("___",@gse_errors);
        $gse_error_message =~ s/\n/ /g;       
        print GSE_RESULTS_FILE $current_gse_id . "\t\tFailure\t" . $gse_error_message . "\t\n";  
        close(GSE_RESULTS_FAIL);

        #loop through each GSM and write out gsm record result
        open (GSM_RESULTS_FILE, ">>".$gsm_results_file) or return "0 - Unable to make/append to $gsm_results_file \n"; 
        my @gsm_ids = keys(%{$gse_object_ref->{'gseSamples'}});
        foreach my $gsm_id (@gsm_ids)
        {
            #the first column is the GSM_ID 
            #the second column is the Genome (kbase genome id)
            #the third column is the DataQualityLevel (currently 3 possible int values - 
            #        "1" for kbase pipeline processed data, "2" for seq blat mapped geo data,  "3" for synonym mapped geo data 
            #the fourth column is the KBase Sample ID (if it exists) 
            #the fifth column is the warning and error messages (separated by "___", 3 underscores)
            my @genome_list;
            if (scalar(keys(%{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmPlatform'}->{'genomesMappingMethod'}})) == 0)
            {            
                @genome_list = ('');
            }
            else
            {  
                @genome_list = keys(%{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmPlatform'}->{'genomesMappingMethod'}});
	    }
            my $gsm_error_message = join("___",@{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'errors'}});
            $gsm_error_message =~ s/\n/ /g;       
            foreach my $genome_id (@genome_list)
	    {
		print GSM_RESULTS_FILE $gsm_id . "\t".$genome_id."\t\t\t".$gsm_error_message."\n";
	    }
        }
        close(GSM_RESULTS_FILE);
	return "1";
    }
    else
    {
        #PROCESS PLATFORMS
        #the GSE passed and at least 1 gsm passed
        my %gpl_object_hash;  #key = gpl_id, value = platform typedef structure { id => val,
                              #                                                   source_id => val,
                              #                                                   genome_id => val,
                              #                                                   technology => val,
                              #                                                   title => val,
                              #                                                   strain => {genome_id=>val, 
                              #                                                              reference_strain => val (Y or N), 
                              #                                                              wild_type => val (Y or N),
                              #                                                              description => val, 
                              #                                                              name => val}} 

        my @gsm_ids = keys(%{$gse_object_ref->{'gseSamples'}});
 
        my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                               { RaiseError => 1, ShowErrorStatement => 1 }
            );

	my $passing_gsm_count = 0;
	my $failing_gsm_count = 0;

        #check each passing GSM and grab the platform build up unique platform objects (see if they already exist)
        foreach my $gsm_id (@gsm_ids) 
        { 
            if (scalar(@{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'errors'}}) == 0)
            {
                my %gpl_hash = %{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmPlatform'}};
                my $gpl_id = $gpl_hash{'gplID'};
		#check if it has been processed in previous runs 
                unless(exists($processed_gpl_hash{$gpl_id}))
		{
		    #check if gpl has been encountered in file before
		    unless(exists($gpl_object_hash{$gpl_id}))   
		    {
                        #Build up the platform object
                        #Grab genomes based on scientific_name and tax_id (which one to select?)
			my $ncbi_db = Bio::DB::Taxonomy->new(-source=>"entrez");
			my $ncbi_taxon = $ncbi_db->get_taxon(-taxonid=>$gpl_hash{'gplTaxID'});
			my @ncbi_scientific_names = @{$ncbi_taxon->{'_names_hash'}->{'scientific'}};
                        my $get_genome_ids_q = "select id from kbase_sapling_v1.Genome where scientific_name in (".
                            join(",", ("?") x @ncbi_scientific_names) . ") "; 
                        my $get_genome_ids_qh = $dbh->prepare($get_genome_ids_q) or return "0 - Unable to prepare get_genome_ids_q : $get_genome_ids_q ".
                            $dbh->errstr(); 
                        $get_genome_ids_qh->execute(@ncbi_scientific_names) or return "0 - Unable to execute get_genome_ids_q : $get_genome_ids_q " . 
                        $get_genome_ids_qh->errstr(); 
                        my $genome_id_selected = '';
                        my %genome_ids_hash;
			while (my ($genome_id) = $get_genome_ids_qh->fetchrow_array()) 
                        { 
                            $genome_ids_hash{$genome_id} = 1; 
			}
                        my %genomes_map_results = %{$gpl_hash{'genomesMappingMethod'}};
                        foreach my $genome_id (sort(keys(%genomes_map_results)))
                        {
                            #will preferentially choose a mapped genome assuming the genome maps to the Platform tax ID.
                            if ($genome_id_selected eq '')
                            {
				if (($genomes_map_results{$genome_id} ne "UNABLE TO MAP PROBES BY SEQUENCE OR EXTERNAL IDS") && 
				    ($genome_ids_hash{$genome_id} == 1))
				{
				    $genome_id_selected = $genome_id;
				}
                            }
                        }
			if ($genome_id_selected eq '')
			{
                            #if mapped genome does not match GPL genome ids,  Will select first (sorted) GPL genome id.
			    my @genome_keys = sort(keys(%genome_ids_hash));
			    $genome_id_selected = $genome_keys[0];
			}
                        #grab kbase_platform_id for it                        
			my $platform_prefix = "kb|platform_test";  #if want to test it do it for sample and series as well. Then comment out next line.
			my $kb_gpl_id = $platform_prefix .".".$id_server->allocate_id_range( $platform_prefix, 1 );
#			my $platform_prefix = "kb|platform";
#			my $temp_id_hash_ref = $id_server->register_ids($platform_prefix,"GEO",[$gpl_id]); 
#			my $kb_gpl_id = $temp_id_hash_ref->{$gpl_id};
                        $gpl_object_hash{$gpl_id}={"id" =>$kb_gpl_id,
						   "source_id" => $gpl_id,
						   "genome_id" => $genome_id_selected,
                                                   "technology" => $gpl_hash{"gplTechnology"},
                                                   "title" => $gpl_hash{"gplTitle"},
                                                   "strain" => {"genome_id" => $genome_id_selected,
								"reference_strain" => "Y",
								"wild_type" => "Y",
                                                                "description" => "$genome_id_selected wild_type reference strain",
                                                                "name" => "$genome_id_selected wild_type reference strain"}};       
		    }    
		}
	    }
        }
        #print "\n\nGPL OBJECT HASH : ".Dumper(\%gpl_object_hash)."\n\n";
        if (scalar(keys(%gpl_object_hash)) > 0)
        {
	    open (GPL_RESULTS_FILE, ">>".$gpl_results_file) or return "0 - Unable to make/append to $gpl_results_file \n";             
	    foreach my $gpl_id (keys(%gpl_object_hash))
	    {
		#add it to the %processed_gpl_hash (used later for looking up kb_platform_ids for building the GSM)
		$processed_gpl_hash{$gpl_id} = $gpl_object_hash{$gpl_id}{"id"};
		#write the GPL info in the file
		print GPL_RESULTS_FILE $gpl_id . "\t".$gpl_object_hash{$gpl_id}{"id"}."\n";

		#CREATE JSON OBJECT FILE
		my $temp_platform_file_name = $gpl_object_hash{$gpl_id}{"id"};
		$temp_platform_file_name =~ s/kb\|//; 
		my $platform_file_name = $typed_objects_directory."/".$temp_platform_file_name;
		open(PLATFORM_FILE, ">".$platform_file_name) or return "0 - Unable to make to $platform_file_name \n";             
		print PLATFORM_FILE to_json($gpl_object_hash{$gpl_id});
		close(PLATFORM_FILE);
	    }
	    close (GPL_RESULTS_FILE);
	}

        #PROCESS SAMPLES
        #get sample kbase IDS for later use in the series Objects
        my @gsm_id_array; #array of Sample Kbase IDs associated with the Series (could be both new and old GSMs)      
	my @new_gsm_id_array; #Array of new id of new GSMs to be added. : new gsm = distinct (GSM - Genome - DataQualityLevel combination).
	                         #If at least one new one and the GSE already exist, need to save a new verion of the GSE 
                                 #(extra entries in the sample list)

	open (GSM_RESULTS_FILE, ">>".$gsm_results_file) or return "0 - Unable to make/append to $gsm_results_file \n"; 
	#the first column is the GSM_ID  
	#the second column is the Genome (kbase genome id)  
	#the third column is the DataQualityLevel (currently 3 possible int values -   
	#        "1" for kbase pipeline processed data, "2" for seq blat mapped geo data,  "3" for synonym mapped geo data  
	#the fourth column is the KBase Sample ID (if it exists)                               
	#the fifth column is the warning and error messages (separated by "___", 3 underscores) 

        #loop through all passing GSMs and build up sample objects (see if they already exist)
        my @gsm_ids = keys(%{$gse_object_ref->{'gseSamples'}});
        foreach my $gsm_id (@gsm_ids) 
        { 
            if (scalar(@{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'errors'}}) == 0)
            {
		#grab shared sample object data
                my $gsm_type = "microarray";
		my $gsm_numerical_interpretation = "Log2 level intensities";
		my $gsm_description = "";
		if(exists($gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmDescription'}) &&
		   ($gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmDescription'} ne ""))
		{
		    $gsm_description = $gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmDescription'};
		}
		my $gsm_title = $gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmTitle'};
		my $gsm_external_source_date = $gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmSubmissionDate'};

		my $gsm_molecule = "";
		if (exists($gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmMolecule'}) &&
		    ($gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmMolecule'} ne ""))
		{
		    $gsm_molecule = $gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmMolecule'};
		}
                my $gsm_data_source = $data_source;

		my $gsm_platform_id = $processed_gpl_hash{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmPlatform'}->{'gplID'}};

		#Protocol
                my $gsm_protocol = "";
		if ((exists($gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmProtocol'})) && 
		    ($gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmProtocol'} ne ""))
		{
		    my $gsm_protocol_name = $gsm_id . " protocol";
		    $gsm_protocol = {"name"=>$gsm_protocol_name,
				    "description"=>$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmProtocol'}};
		}
                #Persons
                my @persons;
                foreach my $person_email (keys(%{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'contactPeople'}}))
		{
		    push(@persons,{"email" => $person_email,
				   "first_name" => $gse_object_ref->{'gseSamples'}->{$gsm_id}->{'contactPeople'}->{$person_email}->{'contactFirstName'},
				   "last_name" => $gse_object_ref->{'gseSamples'}->{$gsm_id}->{'contactPeople'}->{$person_email}->{'contactLastName'},
				   "institution" => $gse_object_ref->{'gseSamples'}->{$gsm_id}->{'contactPeople'}->{$person_email}->{'contactInstitution'}});
		}

                #NEED TO GRAB OTHER ONTOLOGY TERM INFO FROM THE DATABASE.
		my @expression_ontology_terms;
	        my @ontology_term_ids = $gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmOntologies'};
		my $get_ontology_info_q = "select id, name, definition from expression.Ontology where id in (".
		    join(",", ("?") x @ontology_term_ids) . ") ";
		my $get_ontology_info_qh = $dbh->prepare($get_ontology_info_q) or return "0 - Unable to prepare get_ontology_info_q : $get_ontology_info_q ". 
		    $dbh->errstr(); 
                $get_ontology_info_qh->execute(@ontology_term_ids) or return "0 - Unable to execute get_ontology_info_q : $get_ontology_info_q ".
		    $get_ontology_info_qh->errstr();
                while(my ($temp_term_id, $temp_term_name, $temp_term_definition) = $get_ontology_info_qh->fetchrow_array())
                {
		    push(@expression_ontology_terms,{'expression_ontology_term_id'=>$temp_term_id,
						     'expression_ontology_term_name'=>$temp_term_name,
						     'expression_ontology_term_definition'=>$temp_term_definition});  
                }				   
                #genome specific data : id, genome_id, expression_levels, original_median, data_quality_level, strain (all of strain)
		#loop through each passing GENOME        
                my @genome_ids = keys(%{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmData'}});
		foreach my $temp_genome_id (@genome_ids)
		{
		    my $dataQualityLevel = $gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmData'}->{$temp_genome_id}->{'dataQualityLevel'};
		    my $temp_kbase_id = "";
		    if(exists($processed_gsm_hash{$gsm_id}{$temp_genome_id}{$dataQualityLevel}))
		    {
			$temp_kbase_id = $processed_gsm_hash{$gsm_id}{$temp_genome_id}{$dataQualityLevel};
                    }
		    if($temp_kbase_id ne "")
		    {
			#means the sample already exists just need to add the sample kbase_id to the list of samples for the 
			push(@gsm_id_array,$temp_kbase_id);
			unless (exists($sample_ids_already_in_series{$temp_kbase_id}))
			{
			    push(@new_gsm_id_array,$temp_kbase_id); 
			}
			$passing_gsm_count++;
		    }
		    else
		    {
			#we have a new GSM-Genome-DQL combination ( will be made into a new sample object)
			my %expression_levels_hash;
                        my %temp_levels_hash = %{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmData'}->{$temp_genome_id}->{'features'}}; 
                        foreach my $temp_feature_id (keys(%temp_levels_hash))
			{
			    $expression_levels_hash{$temp_feature_id} = $temp_levels_hash{$temp_feature_id}->{'mean'};
			}
			my $original_log2_median;

			unless(exists($gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmData'}->{$temp_genome_id}->{'originalLog2Median'}))
			{
			    my @temp_level_keys = sort { $expression_levels_hash{$a} <=> $expression_levels_hash{$b} } keys(%expression_levels_hash);
			    my $num_measurements = scalar(@temp_level_keys);
			    if (($num_measurements%2) == 0)
			    {
				$original_log2_median = ($expression_levels_hash{$temp_level_keys[(($num_measurements/2)-1)]} + 
							 $expression_levels_hash{$temp_level_keys[($num_measurements/2)]})/2;
			    }
			    else
			    {
				$original_log2_median = $expression_levels_hash{$temp_level_keys[(floor($num_measurements/2))]}; 
			    }
			    foreach my $feature_id (@temp_level_keys)
			    {
				$expression_levels_hash{$feature_id} = $expression_levels_hash{$feature_id} - $original_log2_median;
			    }			    
			}
                        else
			{
			    $original_log2_median = $gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmData'}->{$temp_genome_id}->{'originalLog2Median'};
			}
			#within sample loop			
                        #grab kbase_sample_id for it
			my $sample_prefix = "kb|sample_test";  
			my $gsm_id = $sample_prefix .".".$id_server->allocate_id_range( $sample_prefix, 1 );
#			my $sample_prefix = "kb|sample";
#			my $sample_id_key = "GEO::".$gsm_id."::".$temp_genome_id."::".$dataQualityLevel;
#                       my $temp_id_hash_ref = $id_server->register_ids($sample_prefix,"GEO",[$sample_id_key]);
#                       my $gsm_id = $temp_id_hash_ref->{$sample_id_key};
			#add gsm_id to gse_list
			push(@gsm_id_array,$gsm_id);
			#new sample - push id onto new_gsm_id_array;
			push(@new_gsm_id_array,$gsm_id); 
			$passing_gsm_count++;
			#write out the samples in the processed_gsm_file   
			my $gsm_warning_message = "";
			if (exists($gse_object_ref->{'gseSamples'}->{$gsm_id}->{'warnings'}))
			{
			    $gsm_warning_message = join("___",@{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'warnings'}}); 
			    $gsm_warning_message =~ s/\n/ /g;
			}
			print GSM_RESULTS_FILE $gsm_id . "\t".$temp_genome_id."\t".$dataQualityLevel."\t".$gsm_id."\t".$gsm_warning_message."\n"; 

                        #BUILD UP FULL SAMPLE OBJECT
			#note "default_control_sample"
                        # and "averaged_from_samples" are not set by this (those are custom fields that require users to set that data)
			$dataQualityLevel = $dataQualityLevel + 0;#To coerce back to an integer
			my $sample_object_ref = {"id" =>$gsm_id,
						 "source_id" => $gsm_id,
						 "type"=>$gsm_type,
						 "numerical_interpretation"=>$gsm_numerical_interpretation,
						 "title"=>$gsm_title,
						 "data_quality_level"=>$dataQualityLevel,
						 "original_median"=>$original_log2_median,
						 "external_source_date"=>$gsm_external_source_date,
						 "expression_levels"=>\%expression_levels_hash,
						 "genome_id" => $temp_genome_id, 
						 "platform_id"=>$gsm_platform_id,
						 "strain"=>{"genome_id" => $temp_genome_id,
							    "reference_strain" => "Y", 
							    "wild_type" => "Y",
							    "description" => "$temp_genome_id wild_type reference strain",
							    "name" => "$temp_genome_id wild_type reference strain"},
						 "data_source"=>$gsm_data_source,
			};

			if (scalar(@expression_ontology_terms) > 0)
			{
			    $sample_object_ref->{"expression_ontology_terms"}=\@expression_ontology_terms;
			}			
			if ($gsm_protocol)
			{
			    $sample_object_ref->{"protocol"}=$gsm_protocol;
			}
			if ($gsm_description)
			{
			    $sample_object_ref->{"description"}=$gsm_description;
			}
			if ($gsm_molecule)
			{
			    $sample_object_ref->{"molecule"}=$gsm_molecule;
			}
			if (scalar(@persons) > 0)
			{
			    $sample_object_ref->{"persons"}=\@persons;
			}
			#Write out object
			#CREATE JSON OBJECT FILE          
			my $temp_sample_file_name = $gsm_id; 
			$temp_sample_file_name =~ s/kb\|//; 
			my $sample_file_name = $typed_objects_directory."/".$temp_sample_file_name; 
			open(SAMPLE_FILE, ">".$sample_file_name) or return "0 - Unable to make to $sample_file_name \n";
			print SAMPLE_FILE to_json($sample_object_ref); 
			close(SAMPLE_FILE); 
		    }
		}
	    }
	    else
	    {
		#GSM HAS A ERROR ADD TO FILE
		my @genome_list; 
		if (scalar(keys(%{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmPlatform'}->{'genomesMappingMethod'}})) == 0) 
		{ 
		    @genome_list = (''); 
		} 
		else 
		{ 
		    @genome_list = keys(%{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'gsmPlatform'}->{'genomesMappingMethod'}}); 
		} 
		my $gsm_error_message = join("___",@{$gse_object_ref->{'gseSamples'}->{$gsm_id}->{'errors'}}); 
		$gsm_error_message =~ s/\n/ /g;
		$failing_gsm_count++; 
		foreach my $genome_id (@genome_list) 
		{ 
		    print GSM_RESULTS_FILE $gsm_id . "\t".$genome_id."\t\t\t".$gsm_error_message."\n"; 
		}  
	    }
	}
	close(GSM_RESULTS_FILE); 

	my %sample_genome_hash = create_sample_genome_hash($gsm_results_file);

        #PROCESS SERIES (IF new SERIES, or existing SERIES but need to add new samples to the list (NEED TO STORE sample_id_list)).
        #NOTE IF SERIES EXISTS ALREADY NEED TO SLURP UP ENTIRE GSE_RESULTS_FILE AND CHANGE THAT GSE ENTRY 
        #(TO INCLUDE THE NEW SAMPLE_IDS)(CAN GET SAMPLE_IDS_THEN)
        #grab series data, write it to file, build up return typed object

	#check to see if it exists all ready.  If it does, get the id for it and the list of SampleIDs associated with it.
	#if it does not get new id.
    
	my $series_id;
	my %sample_ids_in_series;#key kb_sample_id => genome_id
	foreach my $temp_kb_sample_id (@gsm_id_array)
	{
	    $sample_ids_in_series{$temp_kb_sample_id}=$sample_genome_hash{$temp_kb_sample_id};
	}

	if (exists($processed_gse_hash{$current_gse_id}{"id"}))
	{
	    #means the GSE exists but new sample_ids need to be added to it.
	    #need to make the full SERIES typed object again using existing id
	    #merged set between @gsm_id_array and %sample_ids_already_in_series
	    $series_id = $processed_gse_hash{$current_gse_id}{"id"};
	    #print "\nIN IF : Existing series\n";
	    foreach my $temp_kb_sample_id (keys(%sample_ids_already_in_series))
	    {
		$sample_ids_in_series{$temp_kb_sample_id}=$sample_genome_hash{$temp_kb_sample_id};
	    }	    
	    #need to change geo results file and overwrite the previous entry (new list of sample_ids)
	    if ($passing_gsm_count == 0)
	    {
                return "0 - $current_gse_id had no passing GSMs, but should not have reached this error \n";             
	    }
	    my $result = $processed_gse_hash{$current_gse_id}{"result"};
	    if (($result eq "Full Success")  && ($failing_gsm_count > 0))
	    {
		$result = "Partial Success";
	    }
	    my @gse_warnings = @{$gse_object_ref->{'gseWarnings'}};
	    my $warning_messages = join("___",@gse_warnings);

            my @gse_results_lines; 
	    if (-e $gse_results_file) 
	    { 
		open (GSE_RESULTS,$gse_results_file) or return "0 - Unable to open $gse_results_file , it was supposed to exist"; 
		@gse_results_lines = (<GSE_RESULTS>); 
		close (GSE_RESULTS);
	    }
	    open (GSE_RESULTS_FILE, ">".$gse_results_file) or return "0 - Unable to make to $gse_results_file \n";
	    my $old_messages = "";
	    foreach my $gse_result_line (@gse_results_lines) 
	    { 
		my ($gse_id,$kbase_id,$result,$messages,$sample_ids) = split('\t',trim($gse_result_line));
		if ($current_gse_id ne $gse_id)
		{
		    print GSE_RESULTS_FILE $gse_result_line;
		}
		else
		{
		    $old_messages = $messages;
		}
	    }
	    #add new version of series to the results file.
	    if ($old_messages)
	    {
		if ($warning_messages)
		{
		    $warning_messages .= "___" . $old_messages;
		}
		else
		{
		    $warning_messages = $old_messages;
		}
	    }
	    print GSE_RESULTS_FILE $current_gse_id . "\t" . $series_id . "\t".$result."\t".$warning_messages."\t".
		join(",",sort(keys(%sample_ids_in_series)))."\n";  
	    close (GSE_RESULTS_FILE);
	}
	else
	{
	    #means brand new series and can append to series geo results file.
            #GRAB NEW SERIES KB ID
            #print "\nIN ELSE : Brand new series\n";
	    my $series_prefix = "kb|series_test";  
	    $series_id = $series_prefix .".".$id_server->allocate_id_range( $series_prefix, 1 );
#	    my $series_prefix = "kb|series";
#	    my $temp_id_hash_ref = $id_server->register_ids($series_prefix,"GEO",[$gse_object_ref->{'gseID'}]);
#	    $series_id = $temp_id_hash_ref->{$gse_object_ref->{'gseID'}};
            #resolve result
	    my $result = "Full Success";
	    if ($passing_gsm_count == 0)
	    {
                return "0 - $current_gse_id had no passing GSMs, but should not have reached this error \n";             
	    }
	    if ($failing_gsm_count > 0)
	    {
		$result = "Partial Success";
	    }
            my @gse_warnings = @{$gse_object_ref->{'gseWarnings'}}; 
            my $warning_messages = join("___",@gse_warnings); 
	    open (GSE_RESULTS_FILE, ">>".$gse_results_file) or return "0 - Unable to make/append to $gse_results_file \n";
	    print GSE_RESULTS_FILE $current_gse_id . "\t" . $series_id . "\t".$result."\t".$warning_messages."\t".
		join(",",sort(keys(%sample_ids_in_series)))."\n";  
	    close (GSE_RESULTS_FILE);
	}
	my @gse_sample_ids = sort(keys(%sample_ids_in_series));

	my %genome_sample_ids_hash; #key genome id =>[sample_ids]
	foreach my $temp_sample_id (sort(keys(%sample_ids_in_series)))
	{
	    push(@{$genome_sample_ids_hash{$sample_ids_in_series{$temp_sample_id}}},$temp_sample_id);
	}

	#BUILD UP SERIES OBJECT and WRITE OUT SERIES OBJECT
	my $series_object_ref = {"id"=>$series_id,
				 "source_id"=>$gse_object_ref->{'gseID'},
				 "genome_expression_sample_ids_map"=>\%genome_sample_ids_hash,
				 "title"=>$gse_object_ref->{'gseTitle'},
				 "summary"=>$gse_object_ref->{'gseSummary'},
				 "design"=>$gse_object_ref->{'gseDesign'},
				 "publication_id"=>$gse_object_ref->{'gsePubMedID'},
				 "external_source_date"=>$gse_object_ref->{'gseSubmissionDate'}};
	#Write out object  
	#CREATE JSON OBJECT FILE   
	my $temp_series_file_name = $series_id;
	$temp_series_file_name =~ s/kb\|//;
	my $series_file_name = $typed_objects_directory."/".$temp_series_file_name;
	open(SERIES_FILE, ">".$series_file_name) or return "0 - Unable to make to $series_file_name \n"; 
	print SERIES_FILE to_json($series_object_ref);
	close(SERIES_FILE);
    }
    return "1";
}


sub get_processed_gse_hash
{
    my $gse_results_file = shift;
    #returns a hash key gse_id => value kb|series.#
    my %return_hash;
    if (-e $gse_results_file)
    {
        #THIS FILE HAS 5 columns (tab delimited)(only 3 are brought back for this hash)
        #the first column is the GSE_ID
        #the second column is the KBase Series ID (if it exists)
        #the third column is the upload result (3 possible values "Full Success","Partial Success"(some of GSMs passed, but not all),"Failure"
        #the fourth column is the warning and error messages (separated by "___", 3 underscores)
	#the fifth column is comma separated list of ids for the samples that the series contains.
        open (GSE_RESULTS,$gse_results_file) or return "0 - Unable to open $gse_results_file , it was supposed to exist";
        my @gse_results_lines = (<GSE_RESULTS>);
        foreach my $gse_result_line (@gse_results_lines)
        {
	    my ($gse_id,$kbase_id,$result,$messages,$sample_ids) = split('\t',trim($gse_result_line));
            if (($result ne "Failure") && (trim($kbase_id) ne '') && (trim($gse_id) ne ''))
            {
		$return_hash{$gse_id}{"id"} = trim($kbase_id);
            }
	    $return_hash{$gse_id}{"result"} = trim($result);
	    $return_hash{$gse_id}{"sample_ids"} = trim($sample_ids);
        }
        close(GSE_RESULTS);
    }
    return %return_hash;
}

sub get_processed_gpl_hash
{
    my $gpl_results_file = shift;
    #returns a hash key gpl_id => value kb|platform.#
    my %return_hash;
    if (-e $gpl_results_file)
    {
        #THIS FILE HAS 2 columns (tab delimited)
        #the first column is the GPL_ID
        #the second column is the KBase Platform ID (if it exists)
        open (GPL_RESULTS,$gpl_results_file) or return "0 - Unable to open $gpl_results_file , it was supposed to exist";
        my @gpl_results_lines = (<GPL_RESULTS>);
        foreach my $gpl_result_line (@gpl_results_lines)
        {
            my ($gpl_id,$kbase_id) = split('\t',trim($gpl_result_line));
            if ((trim($kbase_id) ne '') && (trim($gpl_id) ne ''))
            { 
                $return_hash{$gpl_id} = trim($kbase_id);
            }
        }
        close(GPL_RESULTS); 
    } 
    return %return_hash; 
}

sub get_processed_gsm_hash
{
    my $gsm_results_file = shift;
    #returns a hash key gsm_id => {genome => {data_quality_level => value kb|sample}}.#
    my %return_hash;
    if (-e $gsm_results_file)
    {
        #THIS FILE HAS 5 columns (tab delimited)(only 4 are brought back for this hash)
        #the first column is the GSM_ID
        #the second column is the Genome (kbase genome id)
        #the third column is the DataQualityLevel (currently 3 possible int values - 
        #        "1" for kbase pipeline processed data, "2" for seq blat mapped geo data,  "3" for synonym mapped geo data  
        #the fourth column is the KBase Sample ID (if it exists)
        #the fifth column is the warning and error messages (separated by "___", 3 underscores)
        open (GSM_RESULTS,$gsm_results_file) or return "0 - Unable to open $gsm_results_file , it was supposed to exist";
        my @gsm_results_lines = (<GSM_RESULTS>);
        foreach my $gsm_result_line (@gsm_results_lines)
        {
            my ($gsm_id,$genome_id, $dql, $kbase_id,$messages) = split('\t',trim($gsm_result_line));
            if ((trim($kbase_id) ne '') && (trim($gsm_id) ne '') && (trim($genome_id) ne '') && (trim($dql) ne ''))
            { 
                $return_hash{$gsm_id}{$genome_id}{$dql} = trim($kbase_id);
            }
        }
        close(GSM_RESULTS); 
    } 
    return %return_hash; 
}

sub create_sample_genome_hash
{
    my $gsm_results_file = shift; 
    #returns a hash key sample_id => genome
    my %return_hash; 
    if (-e $gsm_results_file) 
    { 
        #THIS FILE HAS 5 columns (tab delimited)(only 4 are brought back for this hash)                         
        #the first column is the GSM_ID
        #the second column is the Genome (kbase genome id)  
        #the third column is the DataQualityLevel (currently 3 possible int values -   
        #        "1" for kbase pipeline processed data, "2" for seq blat mapped geo data,  "3" for synonym mapped geo data 
        #the fourth column is the KBase Sample ID (if it exists) 
        #the fifth column is the warning and error messages (separated by "___", 3 underscores)
        open (GSM_RESULTS,$gsm_results_file) or return "0 - Unable to open $gsm_results_file , it was supposed to exist";
        my @gsm_results_lines = (<GSM_RESULTS>);
        foreach my $gsm_result_line (@gsm_results_lines)
        { 
            my ($gsm_id,$genome_id, $dql, $kbase_id,$messages) = split('\t',trim($gsm_result_line)); 
            if ((trim($kbase_id) ne '') && (trim($genome_id) ne ''))
            { 
                $return_hash{trim($kbase_id)}=trim($genome_id);
            } 
        } 
        close(GSM_RESULTS); 
    } 
    return %return_hash; 
}


1;
