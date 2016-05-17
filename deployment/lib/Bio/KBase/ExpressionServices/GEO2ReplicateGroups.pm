package Bio::KBase::ExpressionServices::GEO2ReplicateGroups;
use strict;
#use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

ExpressionServices

=head1 DESCRIPTION


=cut

#BEGIN_HEADER
use Storable qw(dclone);
use Config::Simple;
use Data::Dumper; 
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
use IO::File; 
use Bio::KBase;
use Bio::KBase::CDMI::CDMIClient; 
use JSON::RPC::Client; 
use JSON;
use Bio::KBase::IDServer::Client;

#require Exporter;

our (@ISA,@EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(new geo2ReplicateGroups);


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

sub geo2ReplicateGroups
{
    #Takes in 4 arguements :
    # 1) a file path and name of a Replicate Groups Info file
    #       This file should be in this format:
    #       GSM133956       Fukuda_1-1_0A_Rep1      1000 
    #       GSM133957       Fukuda_1-2_0B_Rep2      1000 
    #       GSM133958       Fukuda_1-3_2A_Rep1      1001 
    #       GSM133959       Fukuda_1-4_2B_Rep2      1001  
    # 2) file path and name of the GSM results file (in this file format)
    #       GSM969605       kb|g.20848      3       kb|sample_test.185 
    #       GSM969611       kb|g.20848      3       kb|sample_test.186 
    # 3) directory where to write the workspace typed objects in json format
    # 4) the name of the replicate groups warnings file (note usually same directory as arg 2.
    #creates ExpressionReplicateGroup typed objects
    #Also creates a warning 
    #returns a "1"  if successful or a "0 - error_string" if failed
    #The typed objects will be stored in json format in $typed_objects_directory (arg3)

    my $self = shift;
    my $replicate_groups_file = shift;
    my $gsm_results_file = shift;
    my $replicate_group_json_file_directory = shift;
    my $replicate_group_warnings_file = shift;

    my $id_server = Bio::KBase::IDServer::Client->new("http://kbase.us/services/idserver");

    open (REP_FILE,$replicate_groups_file) or return "0 - Unable to open $replicate_groups_file , it was supposed to exist"; 
    my @rep_lines= (<REP_FILE>); 
    close(REP_FILE);

    my %rep_groups_hash; #key = repId, value = [of GSM IDs]
    foreach my $rep_line (@rep_lines)
    {
	my ($gsm_id,$dummy,$rep_id) = split(/\t/,trim($rep_line));
	push(@{$rep_groups_hash{$rep_id}},$gsm_id);
    }
    #print Dumper(\%rep_groups_hash);

    open (GSM_FILE,$gsm_results_file) or return "0 - Unable to open $gsm_results_file , it was supposed to exist"; 
    my @gsm_lines= (<GSM_FILE>); 
    close(GSM_FILE);

    my %gsm_info_hash; #key gsm->{genome_id->{data qualuty level =>kb sample id}}
    foreach my $gsm_line (@gsm_lines)
    {
	my ($gsm_id, $genome_id, $dql, $sample_id) = split(/\t/,trim($gsm_line)); 
	$gsm_info_hash{$gsm_id}->{$genome_id}->{$dql}=$sample_id;
    }
    #print Dumper(\%gsm_info_hash);

    open (REP_WARNINGS_FILE, ">>".$replicate_group_warnings_file) or return "0 - Unable to make/append to $replicate_group_warnings_file \n";
    #go through each rep group
    foreach my $temp_rep_group_id (keys(%rep_groups_hash))
    {
	my @gsms_array = @{$rep_groups_hash{$temp_rep_group_id}};
	my @gsms_not_found_gsm_level;
	my %replicate_groups_needed;  #key {genome}->{dql}->[Kb Sample_ids]
	foreach my $test_gsm_id (@gsms_array)
	{
	    if (exists($gsm_info_hash{$test_gsm_id}))
	    {
		#found number gsms through levels
		my @genomes = keys(%{$gsm_info_hash{$test_gsm_id}});
		foreach my $genome_id (@genomes)
		{
		    #Through Data Quality Levels (dql)
		    my @dqls_array = keys(%{$gsm_info_hash{$test_gsm_id}->{$genome_id}});
		    foreach my $dql (@dqls_array)
		    {
			if (($gsm_info_hash{$test_gsm_id}->{$genome_id}->{$dql} eq '') ||
			    (!(defined($gsm_info_hash{$test_gsm_id}->{$genome_id}->{$dql}))))
			{
			    print REP_WARNINGS_FILE "GSM:" . $test_gsm_id . " -- " . "Genome:" . $genome_id . " -- " . 
				"DataQualityLevel:". $dql ." did not have a succesful sample creation, thus it could not be added to a replicate group.\n";
			}
			else
			{
			    push(@{$replicate_groups_needed{$genome_id}->{$dql}},$gsm_info_hash{$test_gsm_id}->{$genome_id}->{$dql});
			}
		    }
		}
	    }
	    else 
	    {
		push(@gsms_not_found_gsm_level,$test_gsm_id);
	    }
	}
	foreach my $genome_id (keys(%replicate_groups_needed))
	{
	    foreach my $dql (keys(%{$replicate_groups_needed{$genome_id}}))
	    {
		#GET replciate group id
		#make the group_key (sorted kb_sample_ids with "__" delimiter)
		my @sample_ids = @{$replicate_groups_needed{$genome_id}->{$dql}};
		my $replicate_group_key = join("__",sort(@sample_ids));

#mext two lines for testing IDS
		my $replicate_group_prefix = "kb|repGroup_test";  
		my $kb_rep_group_id = $replicate_group_prefix .".".$id_server->allocate_id_range( $replicate_group_prefix, 1 ); 
#next three lines for real ids (comment out above two lines)
#               my $replicate_group_prefix = "kb|repGroup";                                                                          
#               my $temp_id_hash_ref = $id_server->register_ids($replicate_group_prefix,"KB",[$replicate_group_key]);                            
#               my $kb_rep_group_id = $temp_id_hash_ref->{$replicate_group_key}; 
 
		#make replicate group data structure
		my $rep_group_object_hash = {"id" => $kb_rep_group_id,
					     "expression_sample_ids" => \@sample_ids};
		#CREATE JSON OBJECT FILE                                                                                              
                my $temp_rep_group_file_name = $kb_rep_group_id;   
                $temp_rep_group_file_name =~ s/kb\|//;
                my $rep_group_file_name = $replicate_group_json_file_directory ."/".$temp_rep_group_file_name; 
                open(REP_GROUP_FILE, ">".$rep_group_file_name) or return "0 - Unable to make to $rep_group_file_name \n"; 
                print REP_GROUP_FILE to_json($rep_group_object_hash); 
                close(REP_GROUP_FILE); 
	    }
	}
	if (scalar(@gsms_not_found_gsm_level) > 0)
	{
	    print REP_WARNINGS_FILE scalar(@gsms_not_found_gsm_level) . " of " . scalar(@gsms_array) . 
		" total GSMs in the replicate group ". $temp_rep_group_id . 
		" were not found to have been attempted to be processed.  The GSM(s) were ".
		join(",",@gsms_not_found_gsm_level).".\n";
	}
    }
    close(REP_WARNINGS_FILE);
}

1;
