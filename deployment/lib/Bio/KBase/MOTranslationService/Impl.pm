package Bio::KBase::MOTranslationService::Impl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

MOTranslation

=head1 DESCRIPTION

This module will translate KBase ids to MicrobesOnline ids and
vice-versa. For features, it will initially use MD5s to perform
the translation.

The MOTranslation module will ultimately be deprecated, once all
MicrobesOnline data types are natively stored in KBase. In general
the module and methods should not be publicized, and are mainly intended
to be used internally by other KBase services (specifically the protein
info service).

=cut

#BEGIN_HEADER

use Bio::KBase;
use Data::Dumper;
use Benchmark;
use List::Util qw[min max];
use Config::Simple;

use Bio::KBase::CDMI::CDMIClient;
use Bio::KBase::ERDB_Service::Client;
use DBKernel;

#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR

        # do we need this call to KBase->new anymore?  can we remove this dependency? -mike
#	my $kb = Bio::KBase->new();
	my $cdmi = Bio::KBase::CDMI::CDMIClient->new;

        my $configFile = $ENV{KB_DEPLOYMENT_CONFIG};
        # don't want this hardcoded; figure out what make puts out
            my $SERVICE = $ENV{SERVICE};

            my $config = Config::Simple->new();
            $config->read($configFile);
            my @paramList = qw(dbname sock user pass dbhost port dbms erdb_url blast_db_dir);
            my %params;
            foreach my $param (@paramList)
            {
                my $value = $config->param("$SERVICE.$param");
                if ($value)
                {
                    $params{$param} = $value;
                }
            }

        my $dbKernel = DBKernel->new(
                $params{dbms}, $params{dbname},
                 $params{user}, $params{pass}, $params{port},
                 $params{dbhost}, $params{sock},
                );
        my $moDbh=$dbKernel->{_dbh};

	# need to use config file here to get the url!!!!! 
	my $erdb = Bio::KBase::ERDB_Service::Client->new($params{erdb_url});
	
	$self->{moDbh}=$moDbh;
	$self->{cdmi}=$cdmi;
	$self->{erdb}=$erdb;
	
	# change this to where you want the blast databases stored...
	# use deploy.cfg instead
	$self->{scratch_space}=$params{blast_db_dir};

    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 fids_to_moLocusIds

  $return = $obj->fids_to_moLocusIds($fids)

=over 4

=item Parameter and return types

=begin html

<pre>
$fids is a reference to a list where each element is a fid
$return is a reference to a hash where the key is a fid and the value is a reference to a list where each element is a moLocusId
fid is a string
moLocusId is an int

</pre>

=end html

=begin text

$fids is a reference to a list where each element is a fid
$return is a reference to a hash where the key is a fid and the value is a reference to a list where each element is a moLocusId
fid is a string
moLocusId is an int


=end text



=item Description

fids_to_moLocusIds translates a list of fids into MicrobesOnline
locusIds. It uses proteins_to_moLocusIds internally.

=back

=cut

sub fids_to_moLocusIds
{
    my $self = shift;
    my($fids) = @_;

    my @_bad_arguments;
    (ref($fids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"fids\" (value was \"$fids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to fids_to_moLocusIds:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'fids_to_moLocusIds');
    }

    my $ctx = $Bio::KBase::MOTranslationService::Service::CallContext;
    my($return);
    #BEGIN fids_to_moLocusIds

	$return={};
	my $cdmi=$self->{cdmi};
	my $f2proteins=$cdmi->fids_to_proteins($fids);
	my @proteins=values %{$f2proteins};
	my $p2mo=$self->proteins_to_moLocusIds(\@proteins);

	foreach my $fid (keys %{$f2proteins})
	{
		$return->{$fid}=$p2mo->{$f2proteins->{$fid}};
	}

    #END fids_to_moLocusIds
    my @_bad_returns;
    (ref($return) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to fids_to_moLocusIds:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'fids_to_moLocusIds');
    }
    return($return);
}




=head2 proteins_to_moLocusIds

  $return = $obj->proteins_to_moLocusIds($proteins)

=over 4

=item Parameter and return types

=begin html

<pre>
$proteins is a reference to a list where each element is a protein
$return is a reference to a hash where the key is a protein and the value is a reference to a list where each element is a moLocusId
protein is a string
moLocusId is an int

</pre>

=end html

=begin text

$proteins is a reference to a list where each element is a protein
$return is a reference to a hash where the key is a protein and the value is a reference to a list where each element is a moLocusId
protein is a string
moLocusId is an int


=end text



=item Description

proteins_to_moLocusIds translates a list of proteins (MD5s) into
MicrobesOnline locusIds.

=back

=cut

sub proteins_to_moLocusIds
{
    my $self = shift;
    my($proteins) = @_;

    my @_bad_arguments;
    (ref($proteins) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"proteins\" (value was \"$proteins\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to proteins_to_moLocusIds:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'proteins_to_moLocusIds');
    }

    my $ctx = $Bio::KBase::MOTranslationService::Service::CallContext;
    my($return);
    #BEGIN proteins_to_moLocusIds

	$return={};

	if (scalar @$proteins)
	{
		my $moDbh=$self->{moDbh};

		my $sql='SELECT aaMD5,locusId,count(*) FROM Locus2MD5 WHERE aaMD5 IN (';
		my $placeholders='?,' x (scalar @$proteins);
		chop $placeholders;
		$sql.=$placeholders.') group by aaMD5, locusId';

		my $sth=$moDbh->prepare($sql);
		$sth->execute(@$proteins);
		while (my $row=$sth->fetch)
		{
			push @{$return->{$row->[0]}},$row->[1];
		}
	}

    #END proteins_to_moLocusIds
    my @_bad_returns;
    (ref($return) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to proteins_to_moLocusIds:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'proteins_to_moLocusIds');
    }
    return($return);
}




=head2 moLocusIds_to_fids

  $return = $obj->moLocusIds_to_fids($moLocusIds)

=over 4

=item Parameter and return types

=begin html

<pre>
$moLocusIds is a reference to a list where each element is a moLocusId
$return is a reference to a hash where the key is a moLocusId and the value is a reference to a list where each element is a fid
moLocusId is an int
fid is a string

</pre>

=end html

=begin text

$moLocusIds is a reference to a list where each element is a moLocusId
$return is a reference to a hash where the key is a moLocusId and the value is a reference to a list where each element is a fid
moLocusId is an int
fid is a string


=end text



=item Description

moLocusIds_to_fids translates a list of MicrobesOnline locusIds
into KBase fids. It uses moLocusIds_to_proteins internally.

=back

=cut

sub moLocusIds_to_fids
{
    my $self = shift;
    my($moLocusIds) = @_;

    my @_bad_arguments;
    (ref($moLocusIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"moLocusIds\" (value was \"$moLocusIds\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to moLocusIds_to_fids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'moLocusIds_to_fids');
    }

    my $ctx = $Bio::KBase::MOTranslationService::Service::CallContext;
    my($return);
    #BEGIN moLocusIds_to_fids

	$return={};
	my $cdmi=$self->{cdmi};
	my $mo2proteins=$self->moLocusIds_to_proteins($moLocusIds);
	my @proteins=values %{$mo2proteins};
	my $proteins2fids=$cdmi->proteins_to_fids(\@proteins);

	foreach my $moLocusId (keys %{$mo2proteins})
	{
		$return->{$moLocusId}=$proteins2fids->{$mo2proteins->{$moLocusId}} ?
		    $proteins2fids->{$mo2proteins->{$moLocusId}} : [];
	}

    #END moLocusIds_to_fids
    my @_bad_returns;
    (ref($return) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to moLocusIds_to_fids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'moLocusIds_to_fids');
    }
    return($return);
}




=head2 moLocusIds_to_proteins

  $return = $obj->moLocusIds_to_proteins($moLocusIds)

=over 4

=item Parameter and return types

=begin html

<pre>
$moLocusIds is a reference to a list where each element is a moLocusId
$return is a reference to a hash where the key is a moLocusId and the value is a protein
moLocusId is an int
protein is a string

</pre>

=end html

=begin text

$moLocusIds is a reference to a list where each element is a moLocusId
$return is a reference to a hash where the key is a moLocusId and the value is a protein
moLocusId is an int
protein is a string


=end text



=item Description

moLocusIds_to_proteins translates a list of MicrobesOnline locusIds
into proteins (MD5s).

=back

=cut

sub moLocusIds_to_proteins
{
    my $self = shift;
    my($moLocusIds) = @_;

    my @_bad_arguments;
    (ref($moLocusIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"moLocusIds\" (value was \"$moLocusIds\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to moLocusIds_to_proteins:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'moLocusIds_to_proteins');
    }

    my $ctx = $Bio::KBase::MOTranslationService::Service::CallContext;
    my($return);
    #BEGIN moLocusIds_to_proteins

	$return={};

	if (scalar @$moLocusIds)
	{
		my $moDbh=$self->{moDbh};

		my $sql='SELECT locusId,aaMD5 FROM Locus2MD5 WHERE locusId IN (';
		my $placeholders='?,' x (scalar @$moLocusIds);
		chop $placeholders;
		$sql.=$placeholders.')';

		my $sth=$moDbh->prepare($sql);
		$sth->execute(@$moLocusIds);
		while (my $row=$sth->fetch)
		{
			$return->{$row->[0]}=$row->[1];
		}
	}

    #END moLocusIds_to_proteins
    my @_bad_returns;
    (ref($return) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to moLocusIds_to_proteins:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'moLocusIds_to_proteins');
    }
    return($return);
}




=head2 map_to_fid

  $return_1, $log = $obj->map_to_fid($query_sequences, $genomeId)

=over 4

=item Parameter and return types

=begin html

<pre>
$query_sequences is a reference to a list where each element is a query_sequence
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a protein_id and the value is a result
$log is a status
query_sequence is a reference to a hash where the following keys are defined:
	id has a value which is a protein_id
	seq has a value which is a protein_sequence
	start has a value which is a position
	stop has a value which is a position
protein_id is a string
protein_sequence is a string
position is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string

</pre>

=end html

=begin text

$query_sequences is a reference to a list where each element is a query_sequence
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a protein_id and the value is a result
$log is a status
query_sequence is a reference to a hash where the following keys are defined:
	id has a value which is a protein_id
	seq has a value which is a protein_sequence
	start has a value which is a position
	stop has a value which is a position
protein_id is a string
protein_sequence is a string
position is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string


=end text



=item Description

A general method to lookup the best matching feature id in a specific genome for a given protein sequence.

NOTE: currently the intended use of this method is to map identical genomes with different gene calls, although it still
can work for fairly similar genomes.  But be warned!!  It may produce incorrect results for genomes that differ!

This method operates by first checking the MD5 and position of each sequence and determining if there is an exact match,
(or an exact MD5 match +- 30bp).  If none are found, then a simple blast search is performed.  Currently the blast search
is completely overkill as it is used simply to look for 50% overlap of genes. Blast was chosen, however, because it is
anticipated that this, or a very similar implementation of this method, will be used more generally for mapping features
on roughly similar genomes.  Keep very much in mind that this method is not designed to be a general homology search, which
should be done with more advanced methods.  Rather, this method is designed more for bookkeeping purposes when data based on
one genome with a set of gene calls needs to be applied to a genome with a second set of gene calls.

see also the cooresponds method of the CDMI.

=back

=cut

sub map_to_fid
{
    my $self = shift;
    my($query_sequences, $genomeId) = @_;

    my @_bad_arguments;
    (ref($query_sequences) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"query_sequences\" (value was \"$query_sequences\")");
    (!ref($genomeId)) or push(@_bad_arguments, "Invalid type for argument \"genomeId\" (value was \"$genomeId\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to map_to_fid:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'map_to_fid');
    }

    my $ctx = $Bio::KBase::MOTranslationService::Service::CallContext;
    my($return_1, $log);
    #BEGIN map_to_fid
	
	# start a timer so we can map progress
	my $t_start = Benchmark->new;
	
	# construct the return objects and a map for quickly finding our query positions
	$return_1 = {}; $log = '';
	my $query_count = scalar @{$query_sequences};
	my $results = {}; my $query_id_to_start = {};
	foreach my $query (@$query_sequences) {
	    $results->{$query->{id}} = {best_match=>'',status=>''};
	    $query_id_to_start->{$query->{id}} = $query->{start};
	}
	
	# grab the feature location and md5 values
	$log.=" -> mapping based on md5 values and positions first\n";
	$log.=" -> looking up CDM data for your target genome\n";
	#need a custom approach because the current cdmi methods don't limit the results based on genomes
	my $erdb = $self->{erdb};
	my $objectNames = 'ProteinSequence IsProteinFor Feature IsOwnedBy IsLocatedIn';
	my $filterClause = 'IsLocatedIn(ordinal)=0 AND IsOwnedBy(to-link)=?';
	my $parameters = [$genomeId];
	my $fields = 'Feature(id) ProteinSequence(id) IsLocatedIn(begin) IsLocatedIn(len) IsLocatedIn(dir)';
	my $count = 0; #as per ERDB doc, setting to zero returns all results
	my @feature_list = @{$erdb->GetAll($objectNames, $filterClause, $parameters, $fields, $count)};
	my $target_feature_count = scalar @feature_list;
	$log.=" -> found $target_feature_count features with protein sequences for your target genome\n     ".timestr(timediff(Benchmark->new,$t_start))."\n";
	
	# create a hash for faster lookups of the features based on md5
	my $md5_2_feature_map = {}; my $feature_to_start = {};
	my $feature_match = {};
	foreach my $feature (@feature_list) {
	    my $start_pos; # the start position of the gene!  in the cds, start stores the left most position
	    if(${$feature}[4] eq '+') {
		$start_pos = ${$feature}[2];
	    } else {
		$start_pos = ${$feature}[2] + ${$feature}[3] - 1;
	    }
	    $md5_2_feature_map->{${$feature}[1]}->{${$feature}[0]}=[$start_pos,${$feature}[3]];
	    $feature_match->{${$feature}[0]} = '';
	    $feature_to_start->{${$feature}[0]} = $start_pos;
	}
	
	##########################################################################
	# actually try to do the mapping based on MD5 and exact position
	my $exact_match_count = 0;
	my $exact_md5_only_count = 0;
	my $likely_match_count = 0;
	my $best_likely_match = {};
	my $no_match_count = 0;
	use Digest::MD5  qw(md5_hex);
	foreach my $query (@$query_sequences) {
	    my $md5_value = md5_hex($query->{seq});
	    if(exists($md5_2_feature_map->{$md5_value})) {
		my $found_match = 0;
		my @keys = keys %{$md5_2_feature_map->{$md5_value}};
		foreach my $fid (@keys) {
		    if($query->{start} == $md5_2_feature_map->{$md5_value}->{$fid}->[0]) {
			if ($feature_match->{$fid} eq '') {
			    $feature_match->{$fid} = $query->{id};
			    $results->{$query->{id}}->{best_match} = $fid;
			    $results->{$query->{id}}->{status} = "exact MD5 and start position match";
			} else {
			    die "two exact matches for $fid!! ($query->{id} and $feature_match->{$fid}";
			}
			$found_match=1;
			$exact_match_count++;
		    } elsif ( 30 > abs($query->{start} - $md5_2_feature_map->{$md5_value}->{$fid}->[0]) ) {
			if ($feature_match->{$fid} eq '') {
			    $feature_match->{$fid} = $query->{id};
			    $results->{$query->{id}}->{best_match} = $fid;
			    $results->{$query->{id}}->{status} = "exact MD5; start position within 30bp";
			} else {
			    die "two overlapping matches for $fid!! ($query->{id} and $feature_match->{$fid}";
			}
			$exact_md5_only_count++;
		    }
		}
		if($found_match==0) {
		    # we may still be able to match if we get an exact md5 match AND there is only one matching feature,
		    # but we have to make sure that the feature is not mapped to anything closer
		    
		    my $best_match = ""; my $best_hit_distance=99999999;
		    foreach my $fid (@keys) {
			if ($feature_match->{$fid} eq '') {
			    my $hit_distance = abs($query->{start} - $md5_2_feature_map->{$md5_value}->{$fid}->[0]);
			    if($hit_distance<=$best_hit_distance) {
				$best_match = $fid; $best_hit_distance = $hit_distance;
			    }
			}
		    }
		    $best_likely_match->{$query->{id}} = $best_match;
		    
		}
	    } else {
		$no_match_count++;
	    }
	}
	
	# go through the likely matches, if it has not been matched yet, then just do it.
	foreach my $likely_match (keys %$best_likely_match) {
	    my $fid = $best_likely_match->{$likely_match};
	    if ($feature_match->{$fid} ne '') {
		$likely_match_count++;
		$feature_match->{$fid} = $likely_match;
		$results->{$likely_match}->{best_match} = $fid;
		$results->{$likely_match}->{status} = "exact MD5 match. chose closest unmatched feature at xx bp away, but that is probably not correct.";
	    }
	}
	
	
	$log.= " -> exactly matched: $exact_match_count of $query_count query sequences\n";
	$log.= " -> matched MD5 +- 30bp: $exact_md5_only_count of $query_count query sequences\n";
	$log.= " -> matched exact MD5 to likely match: $likely_match_count of $query_count query sequences\n";
	my $total = $exact_match_count +$exact_md5_only_count + $likely_match_count;
	$log.= " -> mapped: $total of $target_feature_count target genome features\n     ".timestr(timediff(Benchmark->new,$t_start))."\n";
	
	##########################################################################
	### now we try to blast if there are some not matched....
	if( $query_count > $total ) {
	    
	    #figure out first where we should look for a blast DB
	    my $scratch_space = $self->{scratch_space};
	    my $fasta_file_name = $scratch_space.substr($genomeId,3);
	    
	    if (-e $fasta_file_name) {
		$log.=" -> blast database for target genome already exists. awesome.\n";
	    } else { 
		$log.="-> building BLAST database for the target genome $genomeId\n";
		# get all the features with a protein coding sequence, and also get that protein sequence and MD5
		my $objectNames = 'ProteinSequence IsProteinFor Feature IsOwnedBy';
		my $filterClause = 'IsOwnedBy(to-link)=?';
		my $parameters = [$genomeId];
		my $fields = 'Feature(id) ProteinSequence(id) ProteinSequence(sequence)';
		my $count = 0; #as per ERDB doc, setting to zero returns all results
		my @feature_list = @{$erdb->GetAll($objectNames, $filterClause, $parameters, $fields, $count)};
		
		# put each feature in a fasta file that we can convert to a BLAST DB
		open (FASTA_DB, ">$fasta_file_name");
		foreach my $feature (@feature_list) {
		    my $fid_simple = substr(${$feature}[0],3);
		    print FASTA_DB ">".$fid_simple."\n"; # the feature ID is pos 0
		    print FASTA_DB ${$feature}[2]."\n"; # the feature protein sequence in pos 0
		}
		close (FASTA_DB);
		
		# convert the fasta file to a blast DB
		system("formatdb","-p","T","-l","formatdb.log","-i",$fasta_file_name);
		
		$log.="-> BLAST database has been constructed\n";
		$log.="     ".timestr(timediff(Benchmark->new,$t_start))."\n";
	    }
	    
	    #$File::Temp::KEEP_ALL = 1; # FOR DEBUGGING ONLY, WE DON't WANT TO KEEP ALL FILES IN PRODUCTION
	    my $tmp_file = File::Temp->new( TEMPLATE => 'queryXXXXXXXXXX',
				DIR => $scratch_space,
				SUFFIX => '.fasta.tmp');
	    # save all the files that we couldn't match (note, this step could be rolled into the loop of the md5 matching...)
	    my $blast_query_count=0;
	    foreach my $query (@$query_sequences) {
		if($results->{$query->{id}}->{best_match} eq '') {
		    print $tmp_file ">".$query->{id}."\n";
		    print $tmp_file $query->{seq}."\n";
		    $blast_query_count++;
		}
	    }
	    $log.=" -> generated query consisting of $blast_query_count sequences\n";
	    $log.="     ".timestr(timediff(Benchmark->new,$t_start))."\n";
	    
	    # time to blast:
	    # options for blasting:
	    #  we expect the genomes to be identical for now, so we do not expect gapped alignments, but we do not
	    #      enforce this because we might want to extend this method in the future for similar genomes
	    #  (note that if we turn off gaps, we must also turn off comp_based_stats)
	    #  we set the evalue threshold to be 0.01 (since really, for now, we are looking for exact matches)
	    #  we set the output format to 6, which is simple tabular format with the specified ordering
	    open(RESULTS,"blastp ".
		 #"-ungapped ".
		 #"-comp_based_stats F ".
		 "-evalue 0.01 ".
		 # Fields: query id, subject id, evalue, bit score, identical, alignment length, query length, subject length
		 "-outfmt='6 qseqid sseqid evalue bitscore nident length qlen slen' ".
		 "-db $fasta_file_name ".
		 "-query ".$tmp_file->filename." |") || die "Failed: $!\n";
	    
	    # compile the results
	    my $last_query = ''; my $last_hit = []; my $c=0; my $match_count=0;
	    while(my $line=<RESULTS>) {
		chomp($line);
		my @hit = split("\t",$line);
		
		# in case we want to iterate over the hits for a single query, we can do this here
		#if( $hit[0] ne $last_query ) {
		#    print "----";
		#    $last_query=$hit[0];
		#}
		
		# compute number of identical matches over the query and subject sequences
		my $query_coverage = $hit[4] / $hit[6];
		my $subject_coverage = $hit[4] / $hit[7];
		
		my $query_id = $hit[0];
		my $fid = 'kb|'.$hit[1];
		
		# coverage must be (arbitrarily) over 50% bidirectional
		my $min_coverage = 0.5;
		if( $query_coverage>=$min_coverage  &&  $subject_coverage>=$min_coverage ) {
		    #print $line."\n";
		    #print "possible hit: q:".$hit[0]." h:".$hit[1]." qc:".$query_coverage." sc:".$subject_coverage."\n";
		    
		    # and if the start positions are within the length of the alignment (note that this cannot be
		    # trusted unless genomes are identical!!  If they are merely similar, than we have to do more!)
		    my $max_allowed_distance = 0;
		    if ($hit[6]>=$hit[7]) { $max_allowed_distance = $hit[6]-$hit[5]+1; }
		    else { $max_allowed_distance = $hit[7]-$hit[5]+1; }
		    $max_allowed_distance = $max_allowed_distance * 3;
		    
		    my $hit_distance = abs($query_id_to_start->{$query_id} - $feature_to_start->{$fid});
		    if($max_allowed_distance > $hit_distance ) {
			
			if ($results->{$query_id}->{best_match} eq '') {
			    if ($feature_match->{$fid} eq '') {
				    $feature_match->{$fid} = $query_id;
				    $results->{$query_id}->{best_match} = $fid;
				    $results->{$query_id}->{status} = ">50% identity blast hit with start positions that differ by $hit_distance bp";
				    $match_count++;
			    } else {
				    $results->{$query_id}->{status} = "found a good blast hit ($fid), but $fid was already mapped to $feature_match->{$fid}.";
			    }
			}
			# we could expand this to find the closest hit like so....
			#else {
			#    my $first_hit_distance = abs($query_id_to_start->{$query_id} - $feature_to_start->{$results->{$query_id}->{best_match}});
			#    #print "first hit distance: ".$first_hit_distance."\n";
			#    if($hit_distance < $first_hit_distance) {
			#	if ($feature_match->{$fid} eq '') {
			#	    $feature_match->{$fid} = $query_id;
			#	    $results->{$query_id}->{best_match} = $fid;
			#	    $results->{$query_id}->{status} = ">50% identity blast hit with start positions that differ by $hit_distance bp";
			#	} else {
			#	    $results->{$query_id}->{status} = "found a good blast hit ($fid), but $fid was already mapped to $feature_match->{$fid}.";
			#	}
			#   }
			#}
		    }
		    $c++;
		}
	    }
	    $log.=" -> blast could map $match_count of $blast_query_count sequences\n";
	    $log.="     ".timestr(timediff(Benchmark->new,$t_start))."\n";
	}
	
	
	##########################################################################
	# admit defeat for those genes we could not match, then wrap up
	my $no_good_match_counter=0;
	foreach my $query (@$query_sequences) {
	    if($results->{$query->{id}}->{best_match} eq '') {
		$no_good_match_counter++;
		$results->{$query->{id}}->{status} = "could not find a match: ".$results->{$query->{id}}->{status};
	    }
	}
	
	$log.=" -> we were unable to map $no_good_match_counter of $query_count query sequences\n";
	
	$return_1 = $results;
	
    #END map_to_fid
    my @_bad_returns;
    (ref($return_1) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return_1\" (value was \"$return_1\")");
    (!ref($log)) or push(@_bad_returns, "Invalid type for return variable \"log\" (value was \"$log\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to map_to_fid:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'map_to_fid');
    }
    return($return_1, $log);
}




=head2 map_to_fid_fast

  $return_1, $log = $obj->map_to_fid_fast($query_md5s, $genomeId)

=over 4

=item Parameter and return types

=begin html

<pre>
$query_md5s is a reference to a list where each element is a query_md5
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a protein_id and the value is a result
$log is a status
query_md5 is a reference to a hash where the following keys are defined:
	id has a value which is a protein_id
	md5 has a value which is a protein
	start has a value which is a position
	stop has a value which is a position
protein_id is a string
protein is a string
position is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string

</pre>

=end html

=begin text

$query_md5s is a reference to a list where each element is a query_md5
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a protein_id and the value is a result
$log is a status
query_md5 is a reference to a hash where the following keys are defined:
	id has a value which is a protein_id
	md5 has a value which is a protein
	start has a value which is a position
	stop has a value which is a position
protein_id is a string
protein is a string
position is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string


=end text



=item Description

Performs the same function as map_to_fid, except it does not require protein sequences to be defined. Instead, it assumes
genomes are identical and simply looks for genes on the same strand that overlap by at least 50%. Since no sequences are
compared, this method is fast.  But, since no sequences are compared, this method only makes sense for identical genomes

=back

=cut

sub map_to_fid_fast
{
    my $self = shift;
    my($query_md5s, $genomeId) = @_;

    my @_bad_arguments;
    (ref($query_md5s) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"query_md5s\" (value was \"$query_md5s\")");
    (!ref($genomeId)) or push(@_bad_arguments, "Invalid type for argument \"genomeId\" (value was \"$genomeId\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to map_to_fid_fast:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'map_to_fid_fast');
    }

    my $ctx = $Bio::KBase::MOTranslationService::Service::CallContext;
    my($return_1, $log);
    #BEGIN map_to_fid_fast
    
	# start a timer so we can map progress
	my $t_start = Benchmark->new;
	
	# construct the return objects and a map for quickly finding our query positions
	$return_1 = {}; $log = '';
	my $query_count = scalar @{$query_md5s};
	my $results = {};
	foreach my $query (@$query_md5s) {
	    $results->{$query->{id}} = {best_match=>'',status=>''};
	}
	
	# grab the feature location and md5 values
	$log.=" -> looking up CDM data for your target genome\n";
	#need a custom approach because the current cdmi methods don't limit the results based on genomes
	my $erdb = $self->{erdb};
	my $objectNames = 'IsProteinFor Feature IsOwnedBy IsLocatedIn';
	my $filterClause = 'IsLocatedIn(ordinal)=0 AND IsOwnedBy(to-link)=?';
	my $parameters = [$genomeId];
	my $fields = 'Feature(id) IsProteinFor(from_link) IsLocatedIn(begin) IsLocatedIn(len) IsLocatedIn(dir)';
	my $count = 0; #as per ERDB doc, setting to zero returns all results
	my @feature_list = @{$erdb->GetAll($objectNames, $filterClause, $parameters, $fields, $count)};
	my $target_feature_count = scalar @feature_list;
	$log.=" -> found $target_feature_count features with protein sequences for your target genome\n";
	$log.="     ".timestr(timediff(Benchmark->new,$t_start))."\n";
	
	# create a hash for faster lookups of the features based on md5
	my $md5_2_feature_map = {};
	my $feature_match = {};
	foreach my $feature (@feature_list) {
	    my $start_pos; # the start position of the gene!  in the CDS, start stores the left most position
	    if(${$feature}[4] eq '+') {
		$start_pos = ${$feature}[2];
	    } else {
		$start_pos = ${$feature}[2] + ${$feature}[3] - 1;
	    }
	    $md5_2_feature_map->{${$feature}[1]}->{${$feature}[0]}=[$start_pos,${$feature}[3],${$feature}[4]];
	    $feature_match->{${$feature}[0]} = '';
	}
	$log.=" -> built data structure md5 maps for your target genome\n";
	$log.="     ".timestr(timediff(Benchmark->new,$t_start))."\n";
    
	##########################################################################
	# actually try to do the mapping based on MD5 and exact position
	$log.=" -> mapping based on exact md5 values and positions\n";
	my $exact_match_count = 0;
	my $likely_match_count = 0;
	my $best_likely_match = {};
	my $no_match_count = 0;
	my $no_match_list = [];
	foreach my $query (@$query_md5s) {
	    my $md5_value = $query->{md5};
	    if(exists($md5_2_feature_map->{$md5_value})) {
		my $found_match = 0;
		my @keys = keys %{$md5_2_feature_map->{$md5_value}};
		foreach my $fid (@keys) {
		    if($query->{start} == $md5_2_feature_map->{$md5_value}->{$fid}->[0]) {
			if ($feature_match->{$fid} eq '') {
			    $feature_match->{$fid} = $query->{id};
			    $results->{$query->{id}}->{best_match} = $fid;
			    $results->{$query->{id}}->{status} = "exact MD5 and start position match";
			} else {
			    die "two exact matches for $fid!! ($query->{id} and $feature_match->{$fid}";
			}
			$found_match=1;
			$exact_match_count++;
		    }
		}
	    } else {
		$no_match_count++;
		push @$no_match_list, $query;
	    }
	}
	$log.= " -> exactly matched: $exact_match_count of $query_count query sequences\n";
	$log.= "     ".timestr(timediff(Benchmark->new,$t_start))."\n";
	
	# now we consider overlapping matches.  We could use the locations_to_fids method of the cdmi, but it makes
	# a separate database query for each location!!  here, we have all the data, so we should be able to do better
	# right now, though, this hack solution just performs a nested loop.  we should sort one of the lists to get
	# better performance!
	$log.=" -> mapping based on positional overlap\n";
	my $unmatched_features = [];
	foreach my $feature (@feature_list) {
	    if($feature_match->{${$feature}[0]} eq '') {
		push @$unmatched_features, $feature;
	    }
	}
	
	#################
	# we should purge and ignore the fids that have multiple locations here!!!
	#################
	
	# loop over every possible match
	my $overlap_matches=0;
	foreach my $query (@$no_match_list) {
	    foreach my $feature (@$unmatched_features) {
		
		# first identify the query strand
		my $query_strand="+";
		if( $query->{stop} < $query->{start} ) { $query_strand="-"; }
		
		# make sure the strands match, and if so, check for an overlap
		if ($query_strand eq ${$feature}[4]) {
		    
		    # first get the lengths of the sequences
		    my $query_length = abs($query->{stop}-$query->{start});
		    my $feature_length = ${$feature}[3];
		    
		    if(${$feature}[4] eq '+') {
			my $fid_start = ${$feature}[2];
			my $fid_stop = ${$feature}[2] + ${$feature}[3] - 1;
			my $overlap = max(0, min($query->{stop},$fid_stop) - max($query->{start},$fid_start));
			my $query_overlap = $overlap / $query_length;
			my $target_overlap = $overlap / $feature_length;
			if ( $query_overlap>0.5 && $target_overlap>0.5 ) {
			    $feature_match->{${$feature}[0]} = $query->{id};
			    $results->{$query->{id}}->{best_match} = ${$feature}[0];
			    $results->{$query->{id}}->{status} = "overlapping positions: $query_overlap query coverage, $target_overlap target coverage.";
			    $overlap_matches++;
			    last;  # for now, find the first match, and return. This could be bad if there are more matches!!!!
			}
		    } else {
			my $fid_start = ${$feature}[2] + ${$feature}[3] - 1;
			my $fid_stop = ${$feature}[2];
			my $overlap = max(0, min($query->{start},$fid_start) - max($query->{stop},$fid_stop));
			my $query_overlap = $overlap / $query_length;
			my $target_overlap = $overlap / $feature_length;
			if ( $query_overlap>0.5 && $target_overlap>0.5 ) {
			    $feature_match->{${$feature}[0]} = $query->{id};
			    $results->{$query->{id}}->{best_match} = ${$feature}[0];
			    $results->{$query->{id}}->{status} = "overlapping positions: $query_overlap query coverage, $target_overlap target coverage.";
			    $overlap_matches++;
			    last; # for now, find the first match, and return. This could be bad if there are more matches!!!!
			}
		    }
		}
	    }
	}
	$log.= " -> overlapped comparisons matched: $overlap_matches of $no_match_count remaining query sequences\n";
	$log.= "     ".timestr(timediff(Benchmark->new,$t_start))."\n";
	
	
	
	##########################################################################
	# admit defeat for those genes we could not match, then wrap up
	my $no_good_match_counter=0;
	foreach my $query (@$query_md5s) {
	    if($results->{$query->{id}}->{best_match} eq '') {
		$no_good_match_counter++;
		$results->{$query->{id}}->{status} = "could not find a match: ".$results->{$query->{id}}->{status};
	    }
	}
	
	my $total = $exact_match_count + $overlap_matches;
	$log.= " -> mapped: $total of $target_feature_count target genome features\n";
	$log.= " -> mapped: $total of $query_count query sequences\n";
	$log.=" -> we were unable to map $no_good_match_counter of $query_count query sequences\n";
	
	$return_1 = $results;
    
    
    
    
    #END map_to_fid_fast
    my @_bad_returns;
    (ref($return_1) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return_1\" (value was \"$return_1\")");
    (!ref($log)) or push(@_bad_returns, "Invalid type for return variable \"log\" (value was \"$log\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to map_to_fid_fast:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'map_to_fid_fast');
    }
    return($return_1, $log);
}




=head2 moLocusIds_to_fid_in_genome

  $return_1, $log = $obj->moLocusIds_to_fid_in_genome($moLocusIds, $genomeId)

=over 4

=item Parameter and return types

=begin html

<pre>
$moLocusIds is a reference to a list where each element is a moLocusId
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a moLocusId and the value is a result
$log is a status
moLocusId is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string

</pre>

=end html

=begin text

$moLocusIds is a reference to a list where each element is a moLocusId
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a moLocusId and the value is a result
$log is a status
moLocusId is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string


=end text



=item Description

A method designed to map MicrobesOnline locus ids to the features of a specific target genome in kbase.  Under the hood, this
method simply fetches MicrobesOnline data and calls the 'map_to_fid' method defined in this service.  Therefore, all the caveats
and disclaimers of the 'map_to_fid' method apply to this function as well, so be sure to read the documenation for the 'map_to_fid'
method as well!

=back

=cut

sub moLocusIds_to_fid_in_genome
{
    my $self = shift;
    my($moLocusIds, $genomeId) = @_;

    my @_bad_arguments;
    (ref($moLocusIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"moLocusIds\" (value was \"$moLocusIds\")");
    (!ref($genomeId)) or push(@_bad_arguments, "Invalid type for argument \"genomeId\" (value was \"$genomeId\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to moLocusIds_to_fid_in_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'moLocusIds_to_fid_in_genome');
    }

    my $ctx = $Bio::KBase::MOTranslationService::Service::CallContext;
    my($return_1, $log);
    #BEGIN moLocusIds_to_fid_in_genome
    
    
    my $t_start = Benchmark->new;
    
    # first go to MO and get the locus inforamation
    my $moDbh = $self->{moDbh};
    my $sql='SELECT Locus.locusId,Position.begin,Position.end,AASeq.sequence,Position.strand FROM AASeq,Locus,Scaffold,Position WHERE '.
            'Locus.priority=1 AND Locus.locusId=AASeq.locusId AND Locus.version=AASeq.version AND '.
            'Locus.posId=Position.posId AND Locus.scaffoldId=Scaffold.scaffoldId AND Locus.locusId IN (';
    my $placeholders='?,' x (scalar @$moLocusIds);
    chop $placeholders;
    $sql.=$placeholders.')';
    my $sth=$moDbh->prepare($sql);
    $sth->execute(@$moLocusIds);
    
    # process the query results and store them in an object we can pass to the map_to_fid method
    my $query_sequences = [];
    while (my $row=$sth->fetch) {
	# switch the start and stop if we are on the minus strand
	if (${$row}[4] eq '+') {
	    push @$query_sequences, {id=>${$row}[0],start=>${$row}[1], stop=>${$row}[2], seq=>${$row}[3] };
	} else {
	    push @$query_sequences, {id=>${$row}[0],start=>${$row}[2], stop=>${$row}[1], seq=>${$row}[3] };
	}
    }
    my $query_time = timestr(timediff(Benchmark->new,$t_start));
    
    # then we can call the method and save the results
    my ($res, $l) = $self->map_to_fid($query_sequences,$genomeId);
    $return_1 = $res;
    $log = $l;
    $log =" -> query on microbes online for locus information\n     ".$query_time."\n".$log;
    
    
    #END moLocusIds_to_fid_in_genome
    my @_bad_returns;
    (ref($return_1) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return_1\" (value was \"$return_1\")");
    (!ref($log)) or push(@_bad_returns, "Invalid type for return variable \"log\" (value was \"$log\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to moLocusIds_to_fid_in_genome:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'moLocusIds_to_fid_in_genome');
    }
    return($return_1, $log);
}




=head2 moLocusIds_to_fid_in_genome_fast

  $return_1, $log = $obj->moLocusIds_to_fid_in_genome_fast($moLocusIds, $genomeId)

=over 4

=item Parameter and return types

=begin html

<pre>
$moLocusIds is a reference to a list where each element is a moLocusId
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a moLocusId and the value is a result
$log is a status
moLocusId is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string

</pre>

=end html

=begin text

$moLocusIds is a reference to a list where each element is a moLocusId
$genomeId is a genomeId
$return_1 is a reference to a hash where the key is a moLocusId and the value is a result
$log is a status
moLocusId is an int
genomeId is a kbaseId
kbaseId is a string
result is a reference to a hash where the following keys are defined:
	best_match has a value which is a fid
	status has a value which is a status
fid is a string
status is a string


=end text



=item Description

Performs the same function as moLocusIds_to_fid_in_genome, but does not retrieve protein sequences for the locus Ids - it simply
uses md5 information and start/stop positions to identify matches.  It is therefore faster, but will not work if genomes are not
identical.

=back

=cut

sub moLocusIds_to_fid_in_genome_fast
{
    my $self = shift;
    my($moLocusIds, $genomeId) = @_;

    my @_bad_arguments;
    (ref($moLocusIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"moLocusIds\" (value was \"$moLocusIds\")");
    (!ref($genomeId)) or push(@_bad_arguments, "Invalid type for argument \"genomeId\" (value was \"$genomeId\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to moLocusIds_to_fid_in_genome_fast:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'moLocusIds_to_fid_in_genome_fast');
    }

    my $ctx = $Bio::KBase::MOTranslationService::Service::CallContext;
    my($return_1, $log);
    #BEGIN moLocusIds_to_fid_in_genome_fast
    
	my $t_start = Benchmark->new;
	
	# first go to MO and get the locus information
	my $moDbh = $self->{moDbh};
	my $sql='SELECT Locus.locusId,Position.begin,Position.end,Locus2MD5.aaMD5,Position.strand FROM Locus,Position,Locus2MD5 WHERE '.
		'Locus.priority=1 AND Locus.locusId=Locus2MD5.locusId AND Locus.version=Locus2MD5.version AND '.
		'Locus.posId=Position.posId AND Locus.locusId IN (';
	my $placeholders='?,' x (scalar @$moLocusIds);
	chop $placeholders;
	$sql.=$placeholders.')';
	my $sth=$moDbh->prepare($sql);
	$sth->execute(@$moLocusIds);
	
	# process the query results and store them in an object we can pass to the map_to_fid method
	my $query_md5s = [];
	while (my $row=$sth->fetch) {
	    # switch the start and stop if we are on the minus strand
	    if (${$row}[4] eq '+') {
		push @$query_md5s, {id=>${$row}[0],start=>${$row}[1], stop=>${$row}[2], md5=>${$row}[3] };
	    } else {
		push @$query_md5s, {id=>${$row}[0],start=>${$row}[2], stop=>${$row}[1], md5=>${$row}[3] };
	    }
	}
	my $query_time = timestr(timediff(Benchmark->new,$t_start));
    
	
	# then we can call the method and save the results
	my ($res, $l) = $self->map_to_fid_fast($query_md5s,$genomeId);
	$return_1 = $res;
	$log = $l;
	$log =" -> query on microbes online for locus information\n     ".$query_time."\n".$log;
    
    
    #END moLocusIds_to_fid_in_genome_fast
    my @_bad_returns;
    (ref($return_1) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return_1\" (value was \"$return_1\")");
    (!ref($log)) or push(@_bad_returns, "Invalid type for return variable \"log\" (value was \"$log\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to moLocusIds_to_fid_in_genome_fast:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'moLocusIds_to_fid_in_genome_fast');
    }
    return($return_1, $log);
}




=head2 moTaxonomyId_to_genomes

  $return = $obj->moTaxonomyId_to_genomes($moTaxonomyId)

=over 4

=item Parameter and return types

=begin html

<pre>
$moTaxonomyId is a moTaxonomyId
$return is a reference to a list where each element is a genomeId
moTaxonomyId is an int
genomeId is a kbaseId
kbaseId is a string

</pre>

=end html

=begin text

$moTaxonomyId is a moTaxonomyId
$return is a reference to a list where each element is a genomeId
moTaxonomyId is an int
genomeId is a kbaseId
kbaseId is a string


=end text



=item Description

A method to map a MicrobesOnline genome (identified by taxonomy Id) to the set of identical kbase genomes based on an MD5 checksum
of the contig sequences.  If you already know your MD5 value for your genome (computed in the KBase way), then you should avoid this
method and directly query the CDS using the CDMI API, which includes a method 'md5s_to_genomes'.

=back

=cut

sub moTaxonomyId_to_genomes
{
    my $self = shift;
    my($moTaxonomyId) = @_;

    my @_bad_arguments;
    (!ref($moTaxonomyId)) or push(@_bad_arguments, "Invalid type for argument \"moTaxonomyId\" (value was \"$moTaxonomyId\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to moTaxonomyId_to_genomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'moTaxonomyId_to_genomes');
    }

    my $ctx = $Bio::KBase::MOTranslationService::Service::CallContext;
    my($return);
    #BEGIN moTaxonomyId_to_genomes

    # setup the return array ref
    $return = [];
    
    # make sure we have some input
    if ($moTaxonomyId ne "") {
        my $mo_genome_md5s = [];

        # query the Genome2MD5 table for matches
        my $moDbh=$self->{moDbh};
        my $sql = 'SELECT DISTINCT genomeMD5 FROM Genome2MD5 WHERE taxonomyId=?';
        my $query_handle=$moDbh->prepare($sql);
        $query_handle->execute($moTaxonomyId);

        # get each matching row
        while (my $row=$query_handle->fetch()) {
            push(@$mo_genome_md5s, $row->[0]);
        }
       
        # check if we didn't find any results
        if( scalar @{$mo_genome_md5s} > 0 ) {
	    #my $test_mo_genome_md5s = ['4138384cbf747edbde549398d1e123d0'];
	    # call KBase cdmi api to fetch genomes that match these MD5s
	    my $cdmi = $self->{cdmi};
	    my $genomes = $cdmi->md5s_to_genomes($mo_genome_md5s);
    
	    # transform results into a single list of KBase genome ids
	    foreach my $genome_id_list (values %{$genomes}) {
		foreach my $gid (@{$genome_id_list}) {
		    push @$return, $gid;
		}
	    } 
	}
    }

    #END moTaxonomyId_to_genomes
    my @_bad_returns;
    (ref($return) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to moTaxonomyId_to_genomes:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'moTaxonomyId_to_genomes');
    }
    return($return);
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



=head2 protein

=over 4



=item Description

protein is an MD5 in KBase. It is the primary lookup between
KBase fids and MicrobesOnline locusIds.


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



=head2 kbaseId

=over 4



=item Description

kbaseId can represent any object with a KBase identifier. 
In the future this may be used to translate between other data
types, such as contig or genome.


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



=head2 genomeId

=over 4



=item Description

genomeId is a kbase id of a genome


=item Definition

=begin html

<pre>
a kbaseId
</pre>

=end html

=begin text

a kbaseId

=end text

=back



=head2 fid

=over 4



=item Description

fid is a feature id in KBase.


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



=head2 moLocusId

=over 4



=item Description

moLocusId is a locusId in MicrobesOnline. It is analogous to a fid
in KBase.


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



=head2 moScaffoldId

=over 4



=item Description

moScaffoldId is a scaffoldId in MicrobesOnline.  It is analogous to
a contig kbId in KBase.


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



=head2 moTaxonomyId

=over 4



=item Description

moTaxonomyId is a taxonomyId in MicrobesOnline.  It is somewhat analogous
to a genome kbId in KBase.  It generally stores the NCBI taxonomy ID,
though sometimes can store an internal identifier instead.


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



=head2 protein_sequence

=over 4



=item Description

AA sequence of a protein


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



=head2 protein_id

=over 4



=item Description

internally consistant and unique id of a protein (could just be integers 0..n), necessary
for returning results


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



=head2 position

=over 4



=item Description

Used to indicate a single nucleotide/residue location in a sequence


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



=head2 status

=over 4



=item Description

A short note used to convey the status or explanaton of a result, or in some cases a log of the
method that was run


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



=head2 query_sequence

=over 4



=item Description

A structure for specifying the input sequence queries for the map_to_fid method.  This structure, for
now, assumes you will be making queries with identical genomes, so it requires the start and stop.  In the
future, if this assumption is relaxed, then start and stop will be optional parameters.  We should probably
also add an MD5 string which can optionally be provided so that we don't have to compute it on the fly.

        protein_id id         - arbitrary ID that must be unique within the set of query sequences
        protein_sequence seq  - the one letter code AA sequence of the protein
        position start        - the start position of the start codon in the genome contig (may be a larger
                                number than stop if the gene is on the reverse strand)
        position stop         - the last position of he stop codon in the genome contig


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a protein_id
seq has a value which is a protein_sequence
start has a value which is a position
stop has a value which is a position

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a protein_id
seq has a value which is a protein_sequence
start has a value which is a position
stop has a value which is a position


=end text

=back



=head2 query_md5

=over 4



=item Description

A structure for specifying the input md5 queries for the map_to_fid_fast method.  This structure assumes
you will be making queries with identical genomes, so it requires the start and stop.

        protein_id id         - arbitrary ID that must be unique within the set of query sequences
        protein md5           - the computed md5 of the protein sequence
        position start        - the start position of the start codon in the genome contig (may be a larger
                                number than stop if the gene is on the reverse strand)
        position stop         - the last position of he stop codon in the genome contig


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a protein_id
md5 has a value which is a protein
start has a value which is a position
stop has a value which is a position

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a protein_id
md5 has a value which is a protein
start has a value which is a position
stop has a value which is a position


=end text

=back



=head2 result

=over 4



=item Description

A simple structure which returns the best matching FID to a given query (see query_sequence) and attaches
a short status string indicating how the match was made, or which consoles you after a match could not
be made.

        fid best_match - the feature ID of a KBase feature that offers the best mapping to your query
        status status  - a short note explaining how the match was made


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
best_match has a value which is a fid
status has a value which is a status

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
best_match has a value which is a fid
status has a value which is a status


=end text

=back



=cut

1;
