=head1 NAME

Bio::KBase::Tree::Community

=head1 DESCRIPTION


Methods exposed by the Tree service which perform functionality for microbial communities and
metagenomic analysis.


created 1/31/2013 - msneddon

=cut

package Bio::KBase::Tree::Community;

use strict;
use warnings;
use Data::Dumper;
use Benchmark;

use JSON;
use LWP::UserAgent;
use File::Temp;
use Digest::MD5 qw(md5_hex);
use Scalar::Util qw(looks_like_number);

use Bio::KBase::ERDB_Service::Client;
use Bio::KBase::Tree::TreeCppUtil;

#
# create a new Community object with the URLs and scratch space specified.  The order
# of arguments is 1) erdb URL, 2) communities base URL (including 'sequence') and 3)
# path to scratch space.
#
sub new
{
    my($class, @args) = @_;
    my $self = {};
    bless $self, $class;
    
    my $n_args=scalar(@args);
    if($n_args==0) {
	$self->{erdb} = Bio::KBase::ERDB_Service::Client->new("http://kbase.us/services/erdb_service");
	#$self->{erdb} = Bio::KBase::ERDB_Service::Client->new("http://localhost:7099");
	#OLD URL: $self->{mg_base_url} = "http://api.metagenomics.anl.gov/sequences/";
	$self->{mg_base_url} = 'http://www.kbase.us/services/communities/1/annotation/sequence/';
	$self->{scratch} = "/mnt/";
	#$self->{scratch} = "/home/msneddon/Desktop/scratch";
    } else {
	if($n_args!=3) {
	    die "Incorrect number of arguments passed to Bio::KBase::Tree::Community!\n";
	}
	$self->{erdb} = Bio::KBase::ERDB_Service::Client->new($args[0]);
	$self->{mg_base_url} = $args[1];
	$self->{scratch} = $args[2];
    }
    
    return $self;
}



#
#  run uclust and parse the results for the given parameters
#    this method accepts a single argument, a ref to a hash with the following keys defined:
#       protFamName => the ID of the protein family
#       protFamSource => the type of protein family, only COG is supported currently
#       mgId => the ID of the metagenomic sample to operate on
#
#
sub runQiimeUclust {
    my $self=shift;
    my $params=shift;
    my $protFamName=$params->{'protein_family_name'};
    my $protFamSource=$params->{'protein_family_source'};
    my $mgId=$params->{'metagenomic_sample_id'};
    my $treeId=$params->{'tree_id'};
    my $authkey=$params->{'mg_auth_key'};
    # may be possible to lookup tree based on protein family name and type, but this is not yet implemented
    #my $treeId = $self->findKBaseTreeByProteinFamilyName($params);
    my $percentIdentityThreshold=$params->{'percent_identity_threshold'};
    my $sequenceLengthThreshold=$params->{'match_length_threshold'};
    
    # step 1 - get the isolate sequences used to build the tree, and save it to a fasta file
    print "\n1) getting isolate sequences\n";
    my $isolate_seq_list = $self->getTreeProtSeqList($treeId);
    my $isolate_seq_fasta = $self->convertSeqListToFasta($isolate_seq_list);
    my $isolate_seq_file_name_template = $self->{scratch}.$protFamName.'.XXXXXX';
    my $isoFh = new File::Temp(TEMPLATE=>$isolate_seq_file_name_template,SUFFIX=>'.faa',UNLINK=>1);
    print $isoFh $isolate_seq_fasta;
    close $isoFh;
	
    # step 2 - query the communities service to get metagenomic reads for the specified mgId, save the reads to a fasta file
    # note: here we make sure we only save a single copy of each unique read sequence, and count the total number of each
    # unique read, then encode that in the ID of the read
    print "2) getting mg sequences\n";
    my $mg_seq_list = $self->getMgSeqsByProtFam($params);
    my $unique_mg_seq_list = $self->getUniqueSequenceList($mg_seq_list);
    my $mg_seq_fasta = $self->convertSeqListToFasta($unique_mg_seq_list);
    my $mg_seq_file_name_template = $self->{scratch}.$mgId.'.XXXXXX';
    my $mgFh = new File::Temp(TEMPLATE=>$mg_seq_file_name_template,SUFFIX=>'.faa',UNLINK=>1);
    print $mgFh $mg_seq_fasta;
    close $mgFh;
    
    
    # step 3 - prep the output file, make the system call, handle errors if the run failed
    print "3) running uclust\n";
    my $uclust_out_file_name_template = $self->{scratch}.$protFamName."-".$mgId.'.XXXXXX';
    my $uclustFh=new File::Temp (TEMPLATE=>$uclust_out_file_name_template,SUFFIX=>'.uc',UNLINK=>1);
    close $uclustFh;
    my $uclustProcOut=`uclust --quiet --amino --libonly --id 0.70 --input $mgFh --lib $isoFh --uc $uclustFh`;
    print $mgFh."\n";
    print $isoFh."\n";
    print $uclustFh."\n";
    my $exit_code = ($? >> 8);
    if($exit_code!=0) {
	die 'ERROR RUNNING UCLUST';
    }
    
    
    # step 4 - parse and return the results
    print "4) parsing results\n";
    my ($abundance_counts,$n_hits,$n_query_seqs) = $self->computeAbundancesFromUclustOut($uclustFh,$percentIdentityThreshold,$sequenceLengthThreshold);
    
    #print "could map ".$n_hits." of ".$n_query_seqs."\n";
    #foreach my $isolate_seq (@$isolate_seq_list) {
#	$abundance_counts->{$isolate_seq->[0]} = 0;
 #   }

    return ($abundance_counts,$n_hits,$n_query_seqs);
}




#  search kbase for a tree built from a protein family (that is the source ID) that matches the input pattern
#    this method accepts one argument, which is the pattern.  The pattern is very simple and includes only
#    two special characters, wildcard character, '*', and a match-once character, '.'  The wildcard character
#    matches any number (including 0) of any character, the '.' matches exactly one of any character.  These
#    special characters can be escaped with a backslash.  To match a blackslash literally, you must also escape it.
#
#    this method returns a ref to a list of lists with the format below.  If there are
#    no matches, a ref to an empty list is returned.
#
#      [
#        [ treeID_1, sourceID_1],
#        [ treeID_2, sourceID_2],
#        ...
#        [ treeID_n, sourceID_n]
#      ];
#
sub findKBaseTreeByProteinFamilyName {
    my $self=shift;
    my $pattern=shift;
    #chomp($pattern);
    #if ($pattern eq '') { return []; }
    
    # escape the mysql built in match single character
    $pattern =~ s/_/\\_/g;
    # escape the mysql built in match anything character
    $pattern =~ s/%/\\%/g;
    # match * characters that are not escaped, and replace with mysql wildcard character
    $pattern =~ s/(?<!\\)\*/%/g;
    # match * characters that are escaped and replace them with exactly that character
    $pattern =~ s/\\\*/*/g;
    # match * characters that are not escaped, and replace with mysql wildcard character
    $pattern =~ s/(?<!\\)\./_/g;
    # match * characters that are escaped and replace them with exactly that character
    $pattern =~ s/\\\././g;
    
    #print $pattern."\n";
    
    # grab the erdb service, which we need for queries
    my $erdb = $self->{'erdb'};

    # search the db
    my $objectNames = 'Tree';
    my $fields = 'Tree(id) Tree(source-id)';
    my $filterClause = 'Tree(source-id) LIKE ?';
    my $parameters = [$pattern];
    my $count = 0; #as per ERDB doc, setting to zero returns all results
    my @matching_tree_list = @{$erdb->GetAll($objectNames, $filterClause, $parameters, $fields, $count)};
   
    return \@matching_tree_list;
}



# given a reference to a list of sequences, return a FASTA encoding as a string
# the list should be formatted as so:
#   [
#      [ seqId1, seq1],
#      [ seqId2, seq2],
#      ...
#      [ seqIdN, seqN]
#   ];
#
# note that this is the default output format of the getTreeProtSeqs method
sub convertSeqListToFasta {
    my $self=shift;
    my $seq_list=shift;
    
    my $fasta_encoding = '';
    foreach my $seq (@$seq_list) {
	$fasta_encoding .= '>'.$seq->[0]."\n";
	$fasta_encoding .= $seq->[1]."\n";
    }
    return $fasta_encoding;
}


# given a kbase tree id, get all the sequences that comprise the alignment that was
# used to build the tree.  call this method as: $c->getTreeProtSeqs("kb|tree.0");
sub getTreeProtSeqList {
    my $self=shift;
    my $treeId=shift;
    
    # grab the erdb service, which we need for queries
    my $erdb = $self->{'erdb'};

    # get the sequences that comprise the alignment that was used to build the tree
    my $objectNames = 'ProteinSequence IsAlignedProteinComponentOf AlignmentRow IsAlignmentRowIn Alignment IsUsedToBuildTree';
    my $filterClause = 'IsUsedToBuildTree(to-link)=?';
    my $parameters = [$treeId];
    my $fields = 'AlignmentRow(row-id) AlignmentRow(sequence)';
    my $count = 0; #as per ERDB doc, setting to zero returns all results
    my @tree_seq_list = @{$erdb->GetAll($objectNames, $filterClause, $parameters, $fields, $count)};
	
    # remove gap characters from the sequences
    foreach my $row (@tree_seq_list) {
	$row->[1] =~ s/-//g;
    }
    
    return \@tree_seq_list;
}



# given a raw list of sequences, this method eliminates repeats (based on MD5), but counts the number of
# sequences
#   raw sequence information should be passed in a list like so:
#   [
#      [ seqId1, seq1],
#      [ seqId2, seq2],
#      ...
#      [ seqIdN, seqN]
#   ];
#
#  results are returned in the same structure, with seqIDs in the form "MD5_[md5]_[n]" where [md5] is the MD5
#  of the unique sequence, and [n] is the number of matching reads.  The sum over all n, therefore, should be
#  equal to the total number of raw input sequences
sub getUniqueSequenceList {
    my $self=shift;
    my $raw_sequence_list=shift;
    
    # identify unique sequences
    my $unique_seqs = {}; my $unique_seq_counts = {};
    foreach my $seq (@$raw_sequence_list) {
	my $md5 = md5_hex($seq->[1]);
	if(exists($unique_seqs->{$md5})) { $unique_seq_counts->{$md5}++; }
	else {
	    $unique_seq_counts->{$md5} = 1;
	    $unique_seqs->{$md5} = $seq->[1];
	}
    }
    #print Dumper($unique_seq_counts)."\n";
    
    # save the unique sequences to a list that we can return
    my $unique_sequence_list = [];
    foreach my $md5 (keys %$unique_seqs) {
	my $row = [$md5."_".$unique_seq_counts->{$md5},$unique_seqs->{$md5}];
	push @$unique_sequence_list, $row;
    }
    return $unique_sequence_list;
}


#
# Fetches metagenomic reads from MG rast
# call with one argument, which is a reference to a hash with the following keys defined:
#  protFamName => the ID of the protein family
#  protFamSource => the type of protein family, only COG is supported currently
#  mgId => the ID of the metagenomic sample to operate on
#
# returns the json response of the query, or empty string if nothing was returned
#
sub getMgSeqsByProtFam {
    my $self=shift;
    my $params=shift;
    
    my $protFamName=$params->{'protein_family_name'};
    my $protFamSource=$params->{'protein_family_source'};
    my $mgId=$params->{'metagenomic_sample_id'};
    my $authkey=$params->{'mg_auth_key'};
    
    my $base_url = $self->{mg_base_url};
    my $full_url=$base_url.$mgId.'/?type=ontology&source='.$protFamSource.'&filter='.$protFamName;
    if($authkey ne '') {
	$full_url .= "&auth=".$authkey;
    }
    print "\ngetMgSeqsByProtFam: fetching from URL: ".$full_url."\n";
    my $start_run = time();
    
    my $ua = LWP::UserAgent->new;
    $ua->timeout(1200);
    
    my $sequence_list = [];
    my $response=$ua->get($full_url);
    if ($response->is_success) {
	# now we need to parse the response, which always has a header
	my $tab_data=$response->content;
	my @lines = split /\n/, $tab_data;
	my $is_header = 1;
	foreach my $line (@lines) {
	    if ($is_header) { $is_header=0; next; }
	    my @tokens = split /\t/, $line;
	    next if(scalar(@tokens)!=4);
	    
	    # get every reading frame
	    my $dna_seq = $tokens[3];
	    
	    my $seq1 = Bio::KBase::Tree::TreeCppUtil::translateToProt($dna_seq);
	    my $res1 = [$tokens[1], $seq1];
	    push @$sequence_list, $res1;
	    
	    my $seq2 = Bio::KBase::Tree::TreeCppUtil::translateToProt(substr($dna_seq,1));
	    my $res2 = [$tokens[1], $seq2];
	    push @$sequence_list, $res2;
	    
	    my $seq3 = Bio::KBase::Tree::TreeCppUtil::translateToProt(substr($dna_seq,2));
	    my $res3 = [$tokens[1], $seq3];
	    push @$sequence_list, $res3;
	    
	    my $dna_rev = scalar(reverse($dna_seq));
	    my @dna_rev = split //, $dna_rev;
	    my @rev_comp;
	    foreach my $base (@dna_rev) {
		my $comp = '';
		if ($base eq 'A') { $comp='T'; }
		if ($base eq 'T') { $comp='A'; }
		if ($base eq 'C') { $comp='G'; }
		if ($base eq 'G') { $comp='C'; }
		push(@rev_comp,$comp);
	    }
	    my $rev_comp = join('',@rev_comp);
	    
	    my $seq4 = Bio::KBase::Tree::TreeCppUtil::translateToProt($rev_comp);
	    my $res4 = [$tokens[1], $seq4];
	    push @$sequence_list, $res4;
	    
	    my $seq5 = Bio::KBase::Tree::TreeCppUtil::translateToProt(substr($rev_comp,1));
	    my $res5 = [$tokens[1], $seq5];
	    push @$sequence_list, $res5;
	    
	    my $seq6 = Bio::KBase::Tree::TreeCppUtil::translateToProt(substr($rev_comp,2));
	    my $res6 = [$tokens[1], $seq6];
	    push @$sequence_list, $res6;
	}
	
    }
    
    my $end_run = time();
    my $run_time = $end_run - $start_run;
    print "mg query took $run_time seconds and found ".scalar(@$sequence_list)." sequences.\n";
    
    
    return $sequence_list;
}


#
# Given the full path name of the uclust output file, this method computes abundance counts.  It accepts and requires
# three args, the name of the file, a threshold for percent identity for the hit, and a threshold for the sequence
# length, in that order.  Thresholds are interpreted as greater than or equal to.   Percent identity is given as a
# percent, not a fraction (e.g use 87.5 to specify 87.5% identity, NOT 0.875!). This method returns three
# values in a list.  The first element is a ref to a hash where the keys are the names of the target sequences, and
# the value is the number of hits. The second element is the total number of hits.  The last element is the total
# number of query read sequences that were run.
#   ex. my ($abundance_counts,$n_hits,$n_query_seqs) = $c->computeAbundancesFromUclustOut("uclust.out",90,20);
#
sub computeAbundancesFromUclustOut {
    my $self=shift;
    my $results_file_name=shift;
    my $percentIdentityThreshold=shift;
    my $sequenceLengthThreshold=shift;
    
    my $abundance_counts = {};
    
    my $hit_counter=0;  my $seq_counter=0;
    open (my $QIIME_UCLUST_OUT, $results_file_name);
    while (my $line = <$QIIME_UCLUST_OUT>) {
	chomp $line;
	next if ($line !~ /^(H|N)/); # skip everything except for hits and nonhits
	
	my ($Type, $ClusterNr, $SeqLength, $PctId, $Strand, $QueryStart, $SeedStart, $Alignment, $QueryLabel, $TargetLabel) = split (/\t/, $line);
	my ($md5,$n_seq) = split(/_/,$QueryLabel);
	
	#print $md5." ---- ".$n_seq."\n";
	$seq_counter += $n_seq;
	
	# if we found a hit, check if it meets our threshold constraints, then count it.
	if( ($Type eq 'H') && ($PctId >= $percentIdentityThreshold) && ($SeqLength >= $sequenceLengthThreshold) ) {
	    $hit_counter += $n_seq;
	    if(exists($abundance_counts->{$TargetLabel})) {
		$abundance_counts->{$TargetLabel} += $n_seq;
	    } else {
		$abundance_counts->{$TargetLabel} = $n_seq;
	    }
	}
    }
    close ($QIIME_UCLUST_OUT);
    return ($abundance_counts, $hit_counter, $seq_counter);
}


# WARNING: this method does no error checking on parameters.  Error checking should be performed
# in the calling function.
sub filter_abundance_profile {
    my $self=shift;
    my $abundance_data=shift;
    my $filter_params=shift;
    
    
    my $cutoff_value = $filter_params->{'cutoff_value'};
    my $use_cutoff_value = $filter_params->{'use_cutoff_value'};
    my $cutoff_number_of_records = $filter_params->{'cutoff_number_of_records'};
    my $use_cutoff_number_of_records = $filter_params->{'use_cutoff_number_of_records'};
    
    # can't believe I am writing this in perl, but here is the mostly quick & dirty method
    # pass 1: compute total, avg, mean, min, max of each column and globally
    my $gmin; my $gmax; my $gsum=0; my $gn=0; my $gavg;
    my $min={}; my $max={}; my $sum={}; my $n={}; my $avg={};
    foreach my $label (keys %$abundance_data) {
    	my $data = $abundance_data->{$label};
    	$sum->{$label}=0; $n->{$label}=0;
    	foreach my $feature (keys %$data) {
    	    my $value = $data->{$feature};
    	    if(looks_like_number($value)) {
	    	    if($gmin) { if($value<$gmin){ $gmin=$value; } } else { $gmin=$value; }
	    	    if($min->{$label}) { if($value<$min->{$label}){ $min->{$label}=$value; } } else { $min->{$label}=$value; }
	        	if($gmax) { if($value>$gmax){ $gmax=$value; } } else { $gmax=$value; }
	    		if($max->{$label}) { if($value<$max->{$label}){ $max->{$label}=$value; } } else { $max->{$label}=$value; }
	     	    $gsum += $value;
	      	    $sum->{$label} += $value;
	       	    $gn   += 1;
        	    $n->{$label}   += 1;
        	} else {
        	    delete $abundance_data->{$label}->{$feature};
        	}
    	}
    	$avg->{$label}=$sum->{$label} / $n->{$label};
    }
    $gavg = $gsum / $gn;
    
    #print 'min:'.Dumper($min)."\n";
    #print 'max:'.Dumper($max)."\n";
    #print 'sum:'.Dumper($sum)."\n";
    #print 'n:'.Dumper($n)."\n";
    #print 'gmin:'.$gmin."\n";
    #print 'gmin:'.$gmax."\n";
    #print 'gmin:'.$gsum."\n";
    #print 'gmin:'.$gn."\n";
    
    
    #pass 2: normalize / post normalize processing
    my $useGlobal; if( $filter_params->{'normalization_scope'} eq 'global') { $useGlobal=1; }
    foreach my $label (keys %$abundance_data) {
        my $data = $abundance_data->{$label};
        my $factor = 1;
    	if( $filter_params->{'normalization_type'} eq 'total' ) {
    	    if($useGlobal) { $factor = $gsum; }
    	    else {           $factor = $sum->{$label}; }
    	} elsif( $filter_params->{'normalization_type'} eq 'mean' ) {
    	    if($useGlobal) { $factor = $gavg; }
    	    else {           $factor = $avg->{$label}; }
    	} elsif( $filter_params->{'normalization_type'} eq 'max' ) {
    	    if($useGlobal) { $factor = $gmax; }
    	    else {           $factor = $max->{$label}; }
    	} elsif( $filter_params->{'normalization_type'} eq 'min' ) {
    	    if($useGlobal) { $factor = $gmin; }
    	    else {           $factor = $min->{$label}; }
    	}
    	
    	foreach my $feature (keys %$data) {
    	    my $value = $data->{$feature};
    	    $value = $value / $factor;
    	    if( $filter_params->{'normalization_post_process'} eq 'log2' ) {
	        if($value) { $value = log($value)/log(2); }     
		else { $value=''; }
    	    } elsif( $filter_params->{'normalization_post_process'} eq 'log10' ) {
    	        if($value) { $value = log($value)/log(10); }
		else { $value=''; }
    	    } elsif( $filter_params->{'normalization_post_process'} eq 'ln' ) {
    	        if($value) { $value = log($value); }
		else { $value=''; }
    	    }
    	    $data->{$feature} = $value;
    	    
    	    # remove if we don't make the cut
    	    if($use_cutoff_value) {
    	        if( $value < $cutoff_value ) {
    	            delete $abundance_data->{$label}->{$feature};
    	        }
    	    }
    	    
    	}
    }
    
    # pass 3: now the (more) tricky part- we have to sort and return only the top n hits
    if($use_cutoff_number_of_records) {
        if($useGlobal) {
            # we need a global sort of all the values, then we can delete all those that
            # don't make the cut  NOT YET IMPLEMENTED!!!
            
            
            
        } else {
            # we have to sort each column individually, and grab only the top N
            foreach my $label (keys %$abundance_data) {
            
                my $data = $abundance_data->{$label};
                my @sortedKeys = sort { $data->{$a} <=> $data->{$b} } keys %$data;
                print "sorted: ".Dumper(\@sortedKeys)."\n";
                print "number in list: ".scalar(@sortedKeys)."\n";
                my $cut_count = scalar(@sortedKeys) - $cutoff_number_of_records;
                for (my $i=0; $i<$cut_count; $i++) {
                    delete $abundance_data->{$label}->{$sortedKeys[$i]};
                } 
            }
        }
    }
    
    
    
    
    return $abundance_data;
}



1;
