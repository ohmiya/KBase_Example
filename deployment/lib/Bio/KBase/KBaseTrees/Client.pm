package Bio::KBase::KBaseTrees::Client;

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

Bio::KBase::KBaseTrees::Client

=head1 DESCRIPTION


Phylogenetic Tree and Multiple Sequence Alignment Services

This service provides a set of data types and methods for operating with multiple
sequence alignments (MSAs) and phylogenetic trees.

Authors
---------
Michael Sneddon, LBL (mwsneddon@lbl.gov)
Fangfang Xia, ANL (fangfang.xia@gmail.com)
Keith Keller, LBL (kkeller@lbl.gov)
Matt Henderson, LBL (mhenderson@lbl.gov)
Dylan Chivian, LBL (dcchivian@lbl.gov)
Roman Sutormin, LBL (rsutormin@lbl.gov)


=cut

sub new
{
    my($class, $url, @args) = @_;
    
    if (!defined($url))
    {
	$url = 'https://kbase.us/services/trees';
    }

    my $self = {
	client => Bio::KBase::KBaseTrees::Client::RpcClient->new,
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




=head2 replace_node_names

  $return = $obj->replace_node_names($tree, $replacements)

=over 4

=item Parameter and return types

=begin html

<pre>
$tree is a newick_tree
$replacements is a reference to a hash where the key is a node_id and the value is a node_name
$return is a newick_tree
newick_tree is a tree
tree is a string
node_id is a string
node_name is a string

</pre>

=end html

=begin text

$tree is a newick_tree
$replacements is a reference to a hash where the key is a node_id and the value is a node_name
$return is a newick_tree
newick_tree is a tree
tree is a string
node_id is a string
node_name is a string


=end text

=item Description

Given a tree in newick format, replace the node names indicated as keys in the 'replacements' mapping
with new node names indicated as values in the 'replacements' mapping.  Matching is EXACT and will not handle
regular expression patterns.

=back

=cut

sub replace_node_names
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function replace_node_names (received $n, expecting 2)");
    }
    {
	my($tree, $replacements) = @args;

	my @_bad_arguments;
        (!ref($tree)) or push(@_bad_arguments, "Invalid type for argument 1 \"tree\" (value was \"$tree\")");
        (ref($replacements) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"replacements\" (value was \"$replacements\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to replace_node_names:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'replace_node_names');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.replace_node_names",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'replace_node_names',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method replace_node_names",
					    status_line => $self->{client}->status_line,
					    method_name => 'replace_node_names',
				       );
    }
}



=head2 remove_node_names_and_simplify

  $return = $obj->remove_node_names_and_simplify($tree, $removal_list)

=over 4

=item Parameter and return types

=begin html

<pre>
$tree is a newick_tree
$removal_list is a reference to a list where each element is a node_id
$return is a newick_tree
newick_tree is a tree
tree is a string
node_id is a string

</pre>

=end html

=begin text

$tree is a newick_tree
$removal_list is a reference to a list where each element is a node_id
$return is a newick_tree
newick_tree is a tree
tree is a string
node_id is a string


=end text

=item Description

Given a tree in newick format, remove the nodes with the given names indicated in the list, and
simplify the tree.  Simplifying a tree involves removing unnamed internal nodes that have only one
child, and removing unnamed leaf nodes.  During the removal process, edge lengths (if they exist) are
conserved so that the summed end to end distance between any two nodes left in the tree will remain the same.

=back

=cut

sub remove_node_names_and_simplify
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function remove_node_names_and_simplify (received $n, expecting 2)");
    }
    {
	my($tree, $removal_list) = @args;

	my @_bad_arguments;
        (!ref($tree)) or push(@_bad_arguments, "Invalid type for argument 1 \"tree\" (value was \"$tree\")");
        (ref($removal_list) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"removal_list\" (value was \"$removal_list\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to remove_node_names_and_simplify:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'remove_node_names_and_simplify');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.remove_node_names_and_simplify",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'remove_node_names_and_simplify',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method remove_node_names_and_simplify",
					    status_line => $self->{client}->status_line,
					    method_name => 'remove_node_names_and_simplify',
				       );
    }
}



=head2 merge_zero_distance_leaves

  $return = $obj->merge_zero_distance_leaves($tree)

=over 4

=item Parameter and return types

=begin html

<pre>
$tree is a newick_tree
$return is a newick_tree
newick_tree is a tree
tree is a string

</pre>

=end html

=begin text

$tree is a newick_tree
$return is a newick_tree
newick_tree is a tree
tree is a string


=end text

=item Description

Some KBase trees keep information on canonical feature ids, even if they have the same protien sequence
in an alignment.  In these cases, some leaves with identical sequences will have zero distance so that
information on canonical features is maintained.  Often this information is not useful, and a single
example feature or genome is sufficient.  This method will accept a tree in newick format (with distances)
and merge all leaves that have zero distance between them (due to identical sequences), and keep arbitrarily
only one of these leaves.

=back

=cut

sub merge_zero_distance_leaves
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function merge_zero_distance_leaves (received $n, expecting 1)");
    }
    {
	my($tree) = @args;

	my @_bad_arguments;
        (!ref($tree)) or push(@_bad_arguments, "Invalid type for argument 1 \"tree\" (value was \"$tree\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to merge_zero_distance_leaves:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'merge_zero_distance_leaves');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.merge_zero_distance_leaves",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'merge_zero_distance_leaves',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method merge_zero_distance_leaves",
					    status_line => $self->{client}->status_line,
					    method_name => 'merge_zero_distance_leaves',
				       );
    }
}



=head2 extract_leaf_node_names

  $return = $obj->extract_leaf_node_names($tree)

=over 4

=item Parameter and return types

=begin html

<pre>
$tree is a newick_tree
$return is a reference to a list where each element is a node_name
newick_tree is a tree
tree is a string
node_name is a string

</pre>

=end html

=begin text

$tree is a newick_tree
$return is a reference to a list where each element is a node_name
newick_tree is a tree
tree is a string
node_name is a string


=end text

=item Description

Given a tree in newick format, list the names of the leaf nodes.

=back

=cut

sub extract_leaf_node_names
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function extract_leaf_node_names (received $n, expecting 1)");
    }
    {
	my($tree) = @args;

	my @_bad_arguments;
        (!ref($tree)) or push(@_bad_arguments, "Invalid type for argument 1 \"tree\" (value was \"$tree\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to extract_leaf_node_names:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'extract_leaf_node_names');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.extract_leaf_node_names",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'extract_leaf_node_names',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method extract_leaf_node_names",
					    status_line => $self->{client}->status_line,
					    method_name => 'extract_leaf_node_names',
				       );
    }
}



=head2 extract_node_names

  $return = $obj->extract_node_names($tree)

=over 4

=item Parameter and return types

=begin html

<pre>
$tree is a newick_tree
$return is a reference to a list where each element is a node_name
newick_tree is a tree
tree is a string
node_name is a string

</pre>

=end html

=begin text

$tree is a newick_tree
$return is a reference to a list where each element is a node_name
newick_tree is a tree
tree is a string
node_name is a string


=end text

=item Description

Given a tree in newick format, list the names of ALL the nodes.  Note that for some trees, such as
those originating from MicrobesOnline, the names of internal nodes may be bootstrap values, but will still
be returned by this function.

=back

=cut

sub extract_node_names
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function extract_node_names (received $n, expecting 1)");
    }
    {
	my($tree) = @args;

	my @_bad_arguments;
        (!ref($tree)) or push(@_bad_arguments, "Invalid type for argument 1 \"tree\" (value was \"$tree\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to extract_node_names:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'extract_node_names');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.extract_node_names",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'extract_node_names',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method extract_node_names",
					    status_line => $self->{client}->status_line,
					    method_name => 'extract_node_names',
				       );
    }
}



=head2 get_node_count

  $return = $obj->get_node_count($tree)

=over 4

=item Parameter and return types

=begin html

<pre>
$tree is a newick_tree
$return is an int
newick_tree is a tree
tree is a string

</pre>

=end html

=begin text

$tree is a newick_tree
$return is an int
newick_tree is a tree
tree is a string


=end text

=item Description

Given a tree, return the total number of nodes, including internal nodes and the root node.

=back

=cut

sub get_node_count
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_node_count (received $n, expecting 1)");
    }
    {
	my($tree) = @args;

	my @_bad_arguments;
        (!ref($tree)) or push(@_bad_arguments, "Invalid type for argument 1 \"tree\" (value was \"$tree\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_node_count:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_node_count');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_node_count",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_node_count',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_node_count",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_node_count',
				       );
    }
}



=head2 get_leaf_count

  $return = $obj->get_leaf_count($tree)

=over 4

=item Parameter and return types

=begin html

<pre>
$tree is a newick_tree
$return is an int
newick_tree is a tree
tree is a string

</pre>

=end html

=begin text

$tree is a newick_tree
$return is an int
newick_tree is a tree
tree is a string


=end text

=item Description

Given a tree, return the total number of leaf nodes, (internal and root nodes are ignored).  When the
tree was based on a multiple sequence alignment, the number of leaves will match the number of sequences
that were aligned.

=back

=cut

sub get_leaf_count
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_leaf_count (received $n, expecting 1)");
    }
    {
	my($tree) = @args;

	my @_bad_arguments;
        (!ref($tree)) or push(@_bad_arguments, "Invalid type for argument 1 \"tree\" (value was \"$tree\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_leaf_count:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_leaf_count');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_leaf_count",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_leaf_count',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_leaf_count",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_leaf_count',
				       );
    }
}



=head2 get_tree

  $return = $obj->get_tree($tree_id, $options)

=over 4

=item Parameter and return types

=begin html

<pre>
$tree_id is a kbase_id
$options is a reference to a hash where the key is a string and the value is a string
$return is a tree
kbase_id is a string
tree is a string

</pre>

=end html

=begin text

$tree_id is a kbase_id
$options is a reference to a hash where the key is a string and the value is a string
$return is a tree
kbase_id is a string
tree is a string


=end text

=item Description

Returns the specified tree in the specified format, or an empty string if the tree does not exist.
The options hash provides a way to return the tree with different labels replaced or with different attached meta
information.  Currently, the available flags and understood options are listed below. 

    options = [
        format => 'newick',
        newick_label => 'none' || 'raw' || 'feature_id' || 'protein_sequence_id' ||
                        'contig_sequence_id' || 'best_feature_id' || 'best_genome_id',
        newick_bootstrap => 'none' || 'internal_node_labels'
        newick_distance => 'none' || 'raw'
    ];
 
The 'format' key indicates what string format the tree should be returned in.  Currently, there is only
support for 'newick'. The default value if not specified is 'newick'.

The 'newick_label' key only affects trees returned as newick format, and specifies what should be
placed in the label of each leaf.  'none' indicates that no label is added, so you get the structure
of the tree only.  'raw' indicates that the raw label mapping the leaf to an alignement row is used.
'feature_id' indicates that the label will have an examplar feature_id in each label (typically the
feature that was originally used to define the sequence). Note that exemplar feature_ids are not
defined for all trees, so this may result in an empty tree! 'protein_sequence_id' indicates that the
kbase id of the protein sequence used in the alignment is used.  'contig_sequence_id' indicates that
the contig sequence id is added.  Note that trees are typically built with protein sequences OR
contig sequences. If you select one type of sequence, but the tree was built with the other type, then
no labels will be added.  'best_feature_id' is used in the frequent case where a protein sequence has
been mapped to multiple feature ids, and an example feature_id is used.  Similarly, 'best_genome_id'
replaces the labels with the best example genome_id.  The default value if none is specified is 'raw'.

The 'newick_bootstrap' key allows control over whether bootstrap values are returned if they exist, and
how they are returned.  'none' indicates that no bootstrap values are returned. 'internal_node_labels'
indicates that bootstrap values are returned as internal node labels.  Default value is 'internal_node_labels';

The 'newick_distance' key allows control over whether distance labels are generated or not.  If set to
'none', no distances will be output. Default is 'raw', which outputs the distances exactly as they appeared
when loaded into KBase.

=back

=cut

sub get_tree
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_tree (received $n, expecting 2)");
    }
    {
	my($tree_id, $options) = @args;

	my @_bad_arguments;
        (!ref($tree_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"tree_id\" (value was \"$tree_id\")");
        (ref($options) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"options\" (value was \"$options\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_tree:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_tree');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_tree",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_tree',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_tree",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_tree',
				       );
    }
}



=head2 get_alignment

  $return = $obj->get_alignment($alignment_id, $options)

=over 4

=item Parameter and return types

=begin html

<pre>
$alignment_id is a kbase_id
$options is a reference to a hash where the key is a string and the value is a string
$return is an alignment
kbase_id is a string
alignment is a string

</pre>

=end html

=begin text

$alignment_id is a kbase_id
$options is a reference to a hash where the key is a string and the value is a string
$return is an alignment
kbase_id is a string
alignment is a string


=end text

=item Description

Returns the specified alignment in the specified format, or an empty string if the alignment does not exist.
The options hash provides a way to return the alignment with different labels replaced or with different attached meta
information.  Currently, the available flags and understood options are listed below. 

    options = [
        format => 'fasta',
        sequence_label => 'none' || 'raw' || 'feature_id' || 'protein_sequence_id' || 'contig_sequence_id',
    ];
 
The 'format' key indicates what string format the alignment should be returned in.  Currently, there is only
support for 'fasta'. The default value if not specified is 'fasta'.

The 'sequence_label' specifies what should be placed in the label of each sequence.  'none' indicates that
no label is added, so you get the sequence only.  'raw' indicates that the raw label of the alignement row
is used. 'feature_id' indicates that the label will have an examplar feature_id in each label (typically the
feature that was originally used to define the sequence). Note that exemplar feature_ids are not
defined for all alignments, so this may result in an unlabeled alignment.  'protein_sequence_id' indicates
that the kbase id of the protein sequence used in the alignment is used.  'contig_sequence_id' indicates that
the contig sequence id is used.  Note that trees are typically built with protein sequences OR
contig sequences. If you select one type of sequence, but the alignment was built with the other type, then
no labels will be added.  The default value if none is specified is 'raw'.

=back

=cut

sub get_alignment
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_alignment (received $n, expecting 2)");
    }
    {
	my($alignment_id, $options) = @args;

	my @_bad_arguments;
        (!ref($alignment_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"alignment_id\" (value was \"$alignment_id\")");
        (ref($options) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"options\" (value was \"$options\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_alignment:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_alignment');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_alignment",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_alignment',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_alignment",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_alignment',
				       );
    }
}



=head2 get_tree_data

  $return = $obj->get_tree_data($tree_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$tree_ids is a reference to a list where each element is a kbase_id
$return is a reference to a hash where the key is a kbase_id and the value is a TreeMetaData
kbase_id is a string
TreeMetaData is a reference to a hash where the following keys are defined:
	alignment_id has a value which is a kbase_id
	type has a value which is a string
	status has a value which is a string
	date_created has a value which is a timestamp
	tree_contruction_method has a value which is a string
	tree_construction_parameters has a value which is a string
	tree_protocol has a value which is a string
	node_count has a value which is an int
	leaf_count has a value which is an int
	source_db has a value which is a string
	source_id has a value which is a string
timestamp is a string

</pre>

=end html

=begin text

$tree_ids is a reference to a list where each element is a kbase_id
$return is a reference to a hash where the key is a kbase_id and the value is a TreeMetaData
kbase_id is a string
TreeMetaData is a reference to a hash where the following keys are defined:
	alignment_id has a value which is a kbase_id
	type has a value which is a string
	status has a value which is a string
	date_created has a value which is a timestamp
	tree_contruction_method has a value which is a string
	tree_construction_parameters has a value which is a string
	tree_protocol has a value which is a string
	node_count has a value which is an int
	leaf_count has a value which is an int
	source_db has a value which is a string
	source_id has a value which is a string
timestamp is a string


=end text

=item Description

Get meta data associated with each of the trees indicated in the list by tree id.  Note that some meta
data may not be available for trees which are not built from alignments.  Also note that this method
computes the number of nodes and leaves for each tree, so may be slow for very large trees or very long
lists.  If you do not need this full meta information structure, it may be faster to directly query the
CDS for just the field you need using the CDMI.

=back

=cut

sub get_tree_data
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_tree_data (received $n, expecting 1)");
    }
    {
	my($tree_ids) = @args;

	my @_bad_arguments;
        (ref($tree_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"tree_ids\" (value was \"$tree_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_tree_data:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_tree_data');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_tree_data",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_tree_data',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_tree_data",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_tree_data',
				       );
    }
}



=head2 get_alignment_data

  $return = $obj->get_alignment_data($alignment_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$alignment_ids is a reference to a list where each element is a kbase_id
$return is a reference to a hash where the key is a kbase_id and the value is an AlignmentMetaData
kbase_id is a string
AlignmentMetaData is a reference to a hash where the following keys are defined:
	tree_ids has a value which is a reference to a list where each element is a kbase_id
	status has a value which is a string
	sequence_type has a value which is a string
	is_concatenation has a value which is a string
	date_created has a value which is a timestamp
	n_rows has a value which is an int
	n_cols has a value which is an int
	alignment_construction_method has a value which is a string
	alignment_construction_parameters has a value which is a string
	alignment_protocol has a value which is a string
	source_db has a value which is a string
	source_id has a value which is a string
timestamp is a string

</pre>

=end html

=begin text

$alignment_ids is a reference to a list where each element is a kbase_id
$return is a reference to a hash where the key is a kbase_id and the value is an AlignmentMetaData
kbase_id is a string
AlignmentMetaData is a reference to a hash where the following keys are defined:
	tree_ids has a value which is a reference to a list where each element is a kbase_id
	status has a value which is a string
	sequence_type has a value which is a string
	is_concatenation has a value which is a string
	date_created has a value which is a timestamp
	n_rows has a value which is an int
	n_cols has a value which is an int
	alignment_construction_method has a value which is a string
	alignment_construction_parameters has a value which is a string
	alignment_protocol has a value which is a string
	source_db has a value which is a string
	source_id has a value which is a string
timestamp is a string


=end text

=item Description

Get meta data associated with each of the trees indicated in the list by tree id.  Note that some meta
data may not be available for trees which are not built from alignments.  Also note that this method
computes the number of nodes and leaves for each tree, so may be slow for very large trees or very long
lists.  If you do not need this full meta information structure, it may be faster to directly query the
CDS for just the field you need using the CDMI.

=back

=cut

sub get_alignment_data
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_alignment_data (received $n, expecting 1)");
    }
    {
	my($alignment_ids) = @args;

	my @_bad_arguments;
        (ref($alignment_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"alignment_ids\" (value was \"$alignment_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_alignment_data:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_alignment_data');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_alignment_data",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_alignment_data',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_alignment_data",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_alignment_data',
				       );
    }
}



=head2 get_tree_ids_by_feature

  $return = $obj->get_tree_ids_by_feature($feature_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$feature_ids is a reference to a list where each element is a kbase_id
$return is a reference to a list where each element is a kbase_id
kbase_id is a string

</pre>

=end html

=begin text

$feature_ids is a reference to a list where each element is a kbase_id
$return is a reference to a list where each element is a kbase_id
kbase_id is a string


=end text

=item Description

Given a list of feature ids in kbase, the protein sequence of each feature (if the sequence exists)
is identified and used to retrieve all trees by ID that were built using the given protein seqence.

=back

=cut

sub get_tree_ids_by_feature
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_tree_ids_by_feature (received $n, expecting 1)");
    }
    {
	my($feature_ids) = @args;

	my @_bad_arguments;
        (ref($feature_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"feature_ids\" (value was \"$feature_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_tree_ids_by_feature:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_tree_ids_by_feature');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_tree_ids_by_feature",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_tree_ids_by_feature',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_tree_ids_by_feature",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_tree_ids_by_feature',
				       );
    }
}



=head2 get_tree_ids_by_protein_sequence

  $return = $obj->get_tree_ids_by_protein_sequence($protein_sequence_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$protein_sequence_ids is a reference to a list where each element is a kbase_id
$return is a reference to a list where each element is a kbase_id
kbase_id is a string

</pre>

=end html

=begin text

$protein_sequence_ids is a reference to a list where each element is a kbase_id
$return is a reference to a list where each element is a kbase_id
kbase_id is a string


=end text

=item Description

Given a list of kbase ids of a protein sequences (their MD5s), retrieve the tree ids of trees that
were built based on these sequences.

=back

=cut

sub get_tree_ids_by_protein_sequence
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_tree_ids_by_protein_sequence (received $n, expecting 1)");
    }
    {
	my($protein_sequence_ids) = @args;

	my @_bad_arguments;
        (ref($protein_sequence_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"protein_sequence_ids\" (value was \"$protein_sequence_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_tree_ids_by_protein_sequence:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_tree_ids_by_protein_sequence');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_tree_ids_by_protein_sequence",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_tree_ids_by_protein_sequence',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_tree_ids_by_protein_sequence",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_tree_ids_by_protein_sequence',
				       );
    }
}



=head2 get_alignment_ids_by_feature

  $return = $obj->get_alignment_ids_by_feature($feature_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$feature_ids is a reference to a list where each element is a kbase_id
$return is a reference to a list where each element is a kbase_id
kbase_id is a string

</pre>

=end html

=begin text

$feature_ids is a reference to a list where each element is a kbase_id
$return is a reference to a list where each element is a kbase_id
kbase_id is a string


=end text

=item Description

Given a list of feature ids in kbase, the protein sequence of each feature (if the sequence exists)
is identified and used to retrieve all alignments by ID that were built using the given protein sequence.

=back

=cut

sub get_alignment_ids_by_feature
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_alignment_ids_by_feature (received $n, expecting 1)");
    }
    {
	my($feature_ids) = @args;

	my @_bad_arguments;
        (ref($feature_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"feature_ids\" (value was \"$feature_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_alignment_ids_by_feature:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_alignment_ids_by_feature');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_alignment_ids_by_feature",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_alignment_ids_by_feature',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_alignment_ids_by_feature",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_alignment_ids_by_feature',
				       );
    }
}



=head2 get_alignment_ids_by_protein_sequence

  $return = $obj->get_alignment_ids_by_protein_sequence($protein_sequence_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$protein_sequence_ids is a reference to a list where each element is a kbase_id
$return is a reference to a list where each element is a kbase_id
kbase_id is a string

</pre>

=end html

=begin text

$protein_sequence_ids is a reference to a list where each element is a kbase_id
$return is a reference to a list where each element is a kbase_id
kbase_id is a string


=end text

=item Description

Given a list of kbase ids of a protein sequences (their MD5s), retrieve the alignment ids of trees that
were built based on these sequences.

=back

=cut

sub get_alignment_ids_by_protein_sequence
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_alignment_ids_by_protein_sequence (received $n, expecting 1)");
    }
    {
	my($protein_sequence_ids) = @args;

	my @_bad_arguments;
        (ref($protein_sequence_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"protein_sequence_ids\" (value was \"$protein_sequence_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_alignment_ids_by_protein_sequence:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_alignment_ids_by_protein_sequence');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_alignment_ids_by_protein_sequence",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_alignment_ids_by_protein_sequence',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_alignment_ids_by_protein_sequence",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_alignment_ids_by_protein_sequence',
				       );
    }
}



=head2 get_tree_ids_by_source_id_pattern

  $return = $obj->get_tree_ids_by_source_id_pattern($pattern)

=over 4

=item Parameter and return types

=begin html

<pre>
$pattern is a string
$return is a reference to a list where each element is a reference to a list where each element is a kbase_id
kbase_id is a string

</pre>

=end html

=begin text

$pattern is a string
$return is a reference to a list where each element is a reference to a list where each element is a kbase_id
kbase_id is a string


=end text

=item Description

This method searches for a tree having a source ID that matches the input pattern.  This method accepts
one argument, which is the pattern.  The pattern is very simple and includes only two special characters,
wildcard character, '*', and a match-once character, '.'  The wildcard character matches any number (including
0) of any character, the '.' matches exactly one of any character.  These special characters can be escaped
with a backslash.  To match a blackslash literally, you must also escape it.  Note that source IDs are
generally defined by the gene family model which was used to identifiy the sequences to be included in
the tree.  Therefore, matching a source ID is a convenient way to find trees for a specific set of gene
families.

=back

=cut

sub get_tree_ids_by_source_id_pattern
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_tree_ids_by_source_id_pattern (received $n, expecting 1)");
    }
    {
	my($pattern) = @args;

	my @_bad_arguments;
        (!ref($pattern)) or push(@_bad_arguments, "Invalid type for argument 1 \"pattern\" (value was \"$pattern\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_tree_ids_by_source_id_pattern:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_tree_ids_by_source_id_pattern');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_tree_ids_by_source_id_pattern",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_tree_ids_by_source_id_pattern',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_tree_ids_by_source_id_pattern",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_tree_ids_by_source_id_pattern',
				       );
    }
}



=head2 get_leaf_to_protein_map

  $return = $obj->get_leaf_to_protein_map($tree_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$tree_id is a kbase_id
$return is a reference to a hash where the key is a kbase_id and the value is a kbase_id
kbase_id is a string

</pre>

=end html

=begin text

$tree_id is a kbase_id
$return is a reference to a hash where the key is a kbase_id and the value is a kbase_id
kbase_id is a string


=end text

=item Description

Given a tree id, this method returns a mapping from a tree's unique internal ID to
a protein sequence ID.

=back

=cut

sub get_leaf_to_protein_map
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_leaf_to_protein_map (received $n, expecting 1)");
    }
    {
	my($tree_id) = @args;

	my @_bad_arguments;
        (!ref($tree_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"tree_id\" (value was \"$tree_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_leaf_to_protein_map:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_leaf_to_protein_map');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_leaf_to_protein_map",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_leaf_to_protein_map',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_leaf_to_protein_map",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_leaf_to_protein_map',
				       );
    }
}



=head2 get_leaf_to_feature_map

  $return = $obj->get_leaf_to_feature_map($tree_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$tree_id is a kbase_id
$return is a reference to a hash where the key is a kbase_id and the value is a kbase_id
kbase_id is a string

</pre>

=end html

=begin text

$tree_id is a kbase_id
$return is a reference to a hash where the key is a kbase_id and the value is a kbase_id
kbase_id is a string


=end text

=item Description

Given a tree id, this method returns a mapping from a tree's unique internal ID to
a KBase feature ID if and only if a cannonical feature id exists.

=back

=cut

sub get_leaf_to_feature_map
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_leaf_to_feature_map (received $n, expecting 1)");
    }
    {
	my($tree_id) = @args;

	my @_bad_arguments;
        (!ref($tree_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"tree_id\" (value was \"$tree_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_leaf_to_feature_map:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_leaf_to_feature_map');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.get_leaf_to_feature_map",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_leaf_to_feature_map',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_leaf_to_feature_map",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_leaf_to_feature_map',
				       );
    }
}



=head2 import_tree_from_cds

  $info = $obj->import_tree_from_cds($selection, $targetWsNameOrId)

=over 4

=item Parameter and return types

=begin html

<pre>
$selection is a reference to a list where each element is a CdsImportTreeParameters
$targetWsNameOrId is a string
$info is a reference to a list where each element is an object_info
CdsImportTreeParameters is a reference to a hash where the following keys are defined:
	tree_id has a value which is a kbase_id
	load_alignment_for_tree has a value which is a boolean
	ws_tree_name has a value which is a string
	additional_tree_ws_metadata has a value which is a reference to a hash where the key is a string and the value is a string
	ws_alignment_name has a value which is a string
	additional_alignment_ws_metadata has a value which is a reference to a hash where the key is a string and the value is a string
	link_nodes_to_best_feature has a value which is a boolean
	link_nodes_to_best_genome has a value which is a boolean
	link_nodes_to_best_genome_name has a value which is a boolean
	link_nodes_to_all_features has a value which is a boolean
	link_nodes_to_all_genomes has a value which is a boolean
	link_nodes_to_all_genome_names has a value which is a boolean
	default_label has a value which is a string
kbase_id is a string
boolean is an int
object_info is a reference to a list containing 11 items:
	0: (objid) an int
	1: (name) a string
	2: (type) a string
	3: (save_date) a string
	4: (version) an int
	5: (saved_by) a string
	6: (wsid) an int
	7: (workspace) a string
	8: (chsum) a string
	9: (size) an int
	10: (meta) a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$selection is a reference to a list where each element is a CdsImportTreeParameters
$targetWsNameOrId is a string
$info is a reference to a list where each element is an object_info
CdsImportTreeParameters is a reference to a hash where the following keys are defined:
	tree_id has a value which is a kbase_id
	load_alignment_for_tree has a value which is a boolean
	ws_tree_name has a value which is a string
	additional_tree_ws_metadata has a value which is a reference to a hash where the key is a string and the value is a string
	ws_alignment_name has a value which is a string
	additional_alignment_ws_metadata has a value which is a reference to a hash where the key is a string and the value is a string
	link_nodes_to_best_feature has a value which is a boolean
	link_nodes_to_best_genome has a value which is a boolean
	link_nodes_to_best_genome_name has a value which is a boolean
	link_nodes_to_all_features has a value which is a boolean
	link_nodes_to_all_genomes has a value which is a boolean
	link_nodes_to_all_genome_names has a value which is a boolean
	default_label has a value which is a string
kbase_id is a string
boolean is an int
object_info is a reference to a list containing 11 items:
	0: (objid) an int
	1: (name) a string
	2: (type) a string
	3: (save_date) a string
	4: (version) an int
	5: (saved_by) a string
	6: (wsid) an int
	7: (workspace) a string
	8: (chsum) a string
	9: (size) an int
	10: (meta) a reference to a hash where the key is a string and the value is a string


=end text

=item Description



=back

=cut

sub import_tree_from_cds
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function import_tree_from_cds (received $n, expecting 2)");
    }
    {
	my($selection, $targetWsNameOrId) = @args;

	my @_bad_arguments;
        (ref($selection) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"selection\" (value was \"$selection\")");
        (!ref($targetWsNameOrId)) or push(@_bad_arguments, "Invalid type for argument 2 \"targetWsNameOrId\" (value was \"$targetWsNameOrId\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to import_tree_from_cds:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'import_tree_from_cds');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.import_tree_from_cds",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'import_tree_from_cds',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method import_tree_from_cds",
					    status_line => $self->{client}->status_line,
					    method_name => 'import_tree_from_cds',
				       );
    }
}



=head2 compute_abundance_profile

  $abundance_result = $obj->compute_abundance_profile($abundance_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$abundance_params is an AbundanceParams
$abundance_result is an AbundanceResult
AbundanceParams is a reference to a hash where the following keys are defined:
	tree_id has a value which is a kbase_id
	protein_family_name has a value which is a string
	protein_family_source has a value which is a string
	metagenomic_sample_id has a value which is a string
	percent_identity_threshold has a value which is an int
	match_length_threshold has a value which is an int
	mg_auth_key has a value which is a string
kbase_id is a string
AbundanceResult is a reference to a hash where the following keys are defined:
	abundances has a value which is a reference to a hash where the key is a string and the value is an int
	n_hits has a value which is an int
	n_reads has a value which is an int

</pre>

=end html

=begin text

$abundance_params is an AbundanceParams
$abundance_result is an AbundanceResult
AbundanceParams is a reference to a hash where the following keys are defined:
	tree_id has a value which is a kbase_id
	protein_family_name has a value which is a string
	protein_family_source has a value which is a string
	metagenomic_sample_id has a value which is a string
	percent_identity_threshold has a value which is an int
	match_length_threshold has a value which is an int
	mg_auth_key has a value which is a string
kbase_id is a string
AbundanceResult is a reference to a hash where the following keys are defined:
	abundances has a value which is a reference to a hash where the key is a string and the value is an int
	n_hits has a value which is an int
	n_reads has a value which is an int


=end text

=item Description

Given an input KBase tree built from a sequence alignment, a metagenomic sample, and a protein family, this method
will tabulate the number of reads that match to every leaf of the input tree.  First, a set of assembled reads from
a metagenomic sample are pulled from the KBase communities service which have been determined to be a likely hit
to the specified protein family.  Second, the sequences aligned to generate the tree are retrieved.  Third, UCLUST [1]
is used to map reads to target sequences of the tree.  Finally, for each leaf in the tree, the number of hits matching
the input search criteria is tabulated and returned.  See the defined objects 'abundance_params' and 'abundance_result'
for additional details on specifying the input parameters and handling the results.

[1] Edgar, R.C. (2010) Search and clustering orders of magnitude faster than BLAST, Bioinformatics 26(19), 2460-2461.

=back

=cut

sub compute_abundance_profile
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compute_abundance_profile (received $n, expecting 1)");
    }
    {
	my($abundance_params) = @args;

	my @_bad_arguments;
        (ref($abundance_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"abundance_params\" (value was \"$abundance_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compute_abundance_profile:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compute_abundance_profile');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.compute_abundance_profile",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compute_abundance_profile',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compute_abundance_profile",
					    status_line => $self->{client}->status_line,
					    method_name => 'compute_abundance_profile',
				       );
    }
}



=head2 filter_abundance_profile

  $abundance_data_processed = $obj->filter_abundance_profile($abundance_data, $filter_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$abundance_data is an abundance_data
$filter_params is a FilterParams
$abundance_data_processed is an abundance_data
abundance_data is a reference to a hash where the key is a string and the value is an abundance_profile
abundance_profile is a reference to a hash where the key is a string and the value is a float
FilterParams is a reference to a hash where the following keys are defined:
	cutoff_value has a value which is a float
	use_cutoff_value has a value which is a boolean
	cutoff_number_of_records has a value which is a float
	use_cutoff_number_of_records has a value which is a boolean
	normalization_scope has a value which is a string
	normalization_type has a value which is a string
	normalization_post_process has a value which is a string
boolean is an int

</pre>

=end html

=begin text

$abundance_data is an abundance_data
$filter_params is a FilterParams
$abundance_data_processed is an abundance_data
abundance_data is a reference to a hash where the key is a string and the value is an abundance_profile
abundance_profile is a reference to a hash where the key is a string and the value is a float
FilterParams is a reference to a hash where the following keys are defined:
	cutoff_value has a value which is a float
	use_cutoff_value has a value which is a boolean
	cutoff_number_of_records has a value which is a float
	use_cutoff_number_of_records has a value which is a boolean
	normalization_scope has a value which is a string
	normalization_type has a value which is a string
	normalization_post_process has a value which is a string
boolean is an int


=end text

=item Description

ORDER OF OPERATIONS:
1) using normalization scope, defines whether process should occur per column or globally over every column
2) using normalization type, normalize by dividing values by the option indicated
3) apply normalization post process if set (ie take log of the result)
4) apply the cutoff_value threshold to all records, eliminating any that are not above the specified threshold
5) apply the cutoff_number_of_records (always applies per_column!!!), discarding any record that are not in the top N record values for that column

- if a value is not a valid number, it is ignored

=back

=cut

sub filter_abundance_profile
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function filter_abundance_profile (received $n, expecting 2)");
    }
    {
	my($abundance_data, $filter_params) = @args;

	my @_bad_arguments;
        (ref($abundance_data) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"abundance_data\" (value was \"$abundance_data\")");
        (ref($filter_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"filter_params\" (value was \"$filter_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to filter_abundance_profile:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'filter_abundance_profile');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.filter_abundance_profile",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'filter_abundance_profile',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method filter_abundance_profile",
					    status_line => $self->{client}->status_line,
					    method_name => 'filter_abundance_profile',
				       );
    }
}



=head2 draw_html_tree

  $return = $obj->draw_html_tree($tree, $display_options)

=over 4

=item Parameter and return types

=begin html

<pre>
$tree is a newick_tree
$display_options is a reference to a hash where the key is a string and the value is a string
$return is a html_file
newick_tree is a tree
tree is a string
html_file is a string

</pre>

=end html

=begin text

$tree is a newick_tree
$display_options is a reference to a hash where the key is a string and the value is a string
$return is a html_file
newick_tree is a tree
tree is a string
html_file is a string


=end text

=item Description

Given a tree structure in newick, render it in HTML/JAVASCRIPT and return the page as a string. display_options
provides a way to pass parameters to the tree rendering algorithm, but currently no options are recognized.

=back

=cut

sub draw_html_tree
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function draw_html_tree (received $n, expecting 2)");
    }
    {
	my($tree, $display_options) = @args;

	my @_bad_arguments;
        (!ref($tree)) or push(@_bad_arguments, "Invalid type for argument 1 \"tree\" (value was \"$tree\")");
        (ref($display_options) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"display_options\" (value was \"$display_options\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to draw_html_tree:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'draw_html_tree');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.draw_html_tree",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'draw_html_tree',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method draw_html_tree",
					    status_line => $self->{client}->status_line,
					    method_name => 'draw_html_tree',
				       );
    }
}



=head2 construct_species_tree

  $return = $obj->construct_species_tree($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a ConstructSpeciesTreeParams
$return is a job_id
ConstructSpeciesTreeParams is a reference to a hash where the following keys are defined:
	new_genomes has a value which is a reference to a list where each element is a genome_ref
	genomeset_ref has a value which is a ws_genomeset_id
	out_workspace has a value which is a string
	out_tree_id has a value which is a string
	use_ribosomal_s9_only has a value which is an int
	nearest_genome_count has a value which is an int
genome_ref is a string
ws_genomeset_id is a string
job_id is a string

</pre>

=end html

=begin text

$input is a ConstructSpeciesTreeParams
$return is a job_id
ConstructSpeciesTreeParams is a reference to a hash where the following keys are defined:
	new_genomes has a value which is a reference to a list where each element is a genome_ref
	genomeset_ref has a value which is a ws_genomeset_id
	out_workspace has a value which is a string
	out_tree_id has a value which is a string
	use_ribosomal_s9_only has a value which is an int
	nearest_genome_count has a value which is an int
genome_ref is a string
ws_genomeset_id is a string
job_id is a string


=end text

=item Description

Build a species tree out of a set of given genome references.

=back

=cut

sub construct_species_tree
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function construct_species_tree (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to construct_species_tree:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'construct_species_tree');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.construct_species_tree",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'construct_species_tree',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method construct_species_tree",
					    status_line => $self->{client}->status_line,
					    method_name => 'construct_species_tree',
				       );
    }
}



=head2 construct_multiple_alignment

  $return = $obj->construct_multiple_alignment($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ConstructMultipleAlignmentParams
$return is a job_id
ConstructMultipleAlignmentParams is a reference to a hash where the following keys are defined:
	gene_sequences has a value which is a reference to a hash where the key is a string and the value is a string
	featureset_ref has a value which is a ws_featureset_id
	alignment_method has a value which is a string
	is_protein_mode has a value which is an int
	out_workspace has a value which is a string
	out_msa_id has a value which is a string
ws_featureset_id is a string
job_id is a string

</pre>

=end html

=begin text

$params is a ConstructMultipleAlignmentParams
$return is a job_id
ConstructMultipleAlignmentParams is a reference to a hash where the following keys are defined:
	gene_sequences has a value which is a reference to a hash where the key is a string and the value is a string
	featureset_ref has a value which is a ws_featureset_id
	alignment_method has a value which is a string
	is_protein_mode has a value which is an int
	out_workspace has a value which is a string
	out_msa_id has a value which is a string
ws_featureset_id is a string
job_id is a string


=end text

=item Description

Build a multiple sequence alignment based on gene sequences.

=back

=cut

sub construct_multiple_alignment
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function construct_multiple_alignment (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to construct_multiple_alignment:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'construct_multiple_alignment');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.construct_multiple_alignment",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'construct_multiple_alignment',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method construct_multiple_alignment",
					    status_line => $self->{client}->status_line,
					    method_name => 'construct_multiple_alignment',
				       );
    }
}



=head2 construct_tree_for_alignment

  $return = $obj->construct_tree_for_alignment($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ConstructTreeForAlignmentParams
$return is a job_id
ConstructTreeForAlignmentParams is a reference to a hash where the following keys are defined:
	msa_ref has a value which is a ws_alignment_id
	tree_method has a value which is a string
	min_nongap_percentage_for_trim has a value which is an int
	out_workspace has a value which is a string
	out_tree_id has a value which is a string
ws_alignment_id is a string
job_id is a string

</pre>

=end html

=begin text

$params is a ConstructTreeForAlignmentParams
$return is a job_id
ConstructTreeForAlignmentParams is a reference to a hash where the following keys are defined:
	msa_ref has a value which is a ws_alignment_id
	tree_method has a value which is a string
	min_nongap_percentage_for_trim has a value which is an int
	out_workspace has a value which is a string
	out_tree_id has a value which is a string
ws_alignment_id is a string
job_id is a string


=end text

=item Description

Build a tree based on MSA object.

=back

=cut

sub construct_tree_for_alignment
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function construct_tree_for_alignment (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to construct_tree_for_alignment:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'construct_tree_for_alignment');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.construct_tree_for_alignment",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'construct_tree_for_alignment',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method construct_tree_for_alignment",
					    status_line => $self->{client}->status_line,
					    method_name => 'construct_tree_for_alignment',
				       );
    }
}



=head2 find_close_genomes

  $return = $obj->find_close_genomes($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a FindCloseGenomesParams
$return is a reference to a list where each element is a genome_ref
FindCloseGenomesParams is a reference to a hash where the following keys are defined:
	query_genome has a value which is a genome_ref
	max_mismatch_percent has a value which is an int
genome_ref is a string

</pre>

=end html

=begin text

$params is a FindCloseGenomesParams
$return is a reference to a list where each element is a genome_ref
FindCloseGenomesParams is a reference to a hash where the following keys are defined:
	query_genome has a value which is a genome_ref
	max_mismatch_percent has a value which is an int
genome_ref is a string


=end text

=item Description

Find closely related public genomes based on COG of ribosomal s9 subunits.

=back

=cut

sub find_close_genomes
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function find_close_genomes (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to find_close_genomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'find_close_genomes');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.find_close_genomes",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'find_close_genomes',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method find_close_genomes",
					    status_line => $self->{client}->status_line,
					    method_name => 'find_close_genomes',
				       );
    }
}



=head2 guess_taxonomy_path

  $return = $obj->guess_taxonomy_path($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a GuessTaxonomyPathParams
$return is a string
GuessTaxonomyPathParams is a reference to a hash where the following keys are defined:
	query_genome has a value which is a genome_ref
genome_ref is a string

</pre>

=end html

=begin text

$params is a GuessTaxonomyPathParams
$return is a string
GuessTaxonomyPathParams is a reference to a hash where the following keys are defined:
	query_genome has a value which is a genome_ref
genome_ref is a string


=end text

=item Description

Search for taxonomy path from closely related public genomes (approach similar to find_close_genomes).

=back

=cut

sub guess_taxonomy_path
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function guess_taxonomy_path (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to guess_taxonomy_path:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'guess_taxonomy_path');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.guess_taxonomy_path",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'guess_taxonomy_path',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method guess_taxonomy_path",
					    status_line => $self->{client}->status_line,
					    method_name => 'guess_taxonomy_path',
				       );
    }
}



=head2 build_genome_set_from_tree

  $genomeset_ref = $obj->build_genome_set_from_tree($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a BuildGenomeSetFromTreeParams
$genomeset_ref is a ws_genomeset_id
BuildGenomeSetFromTreeParams is a reference to a hash where the following keys are defined:
	tree_ref has a value which is a ws_tree_id
	genomeset_ref has a value which is a ws_genomeset_id
ws_tree_id is a string
ws_genomeset_id is a string

</pre>

=end html

=begin text

$params is a BuildGenomeSetFromTreeParams
$genomeset_ref is a ws_genomeset_id
BuildGenomeSetFromTreeParams is a reference to a hash where the following keys are defined:
	tree_ref has a value which is a ws_tree_id
	genomeset_ref has a value which is a ws_genomeset_id
ws_tree_id is a string
ws_genomeset_id is a string


=end text

=item Description



=back

=cut

sub build_genome_set_from_tree
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function build_genome_set_from_tree (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to build_genome_set_from_tree:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'build_genome_set_from_tree');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KBaseTrees.build_genome_set_from_tree",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'build_genome_set_from_tree',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method build_genome_set_from_tree",
					    status_line => $self->{client}->status_line,
					    method_name => 'build_genome_set_from_tree',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "KBaseTrees.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'build_genome_set_from_tree',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method build_genome_set_from_tree",
            status_line => $self->{client}->status_line,
            method_name => 'build_genome_set_from_tree',
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
        warn "New client version available for Bio::KBase::KBaseTrees::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::KBaseTrees::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 boolean

=over 4



=item Description

Indicates true or false values, false = 0, true = 1
@range [0,1]


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



=head2 timestamp

=over 4



=item Description

Time in units of number of seconds since the epoch


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

Integer number indicating a 1-based position in an amino acid / nucleotide sequence
@range [1,


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



=head2 kbase_id

=over 4



=item Description

A KBase ID is a string starting with the characters "kb|".  KBase IDs are typed. The types are
designated using a short string. For instance," g" denotes a genome, "tree" denotes a Tree, and
"aln" denotes a sequence alignment. KBase IDs may be hierarchical.  For example, if a KBase genome
identifier is "kb|g.1234", a protein encoding gene within that genome may be represented as
"kb|g.1234.peg.771".
@id kb


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



=head2 tree

=over 4



=item Description

A string representation of a phylogenetic tree.  The format/syntax of the string is
specified by using one of the available typedefs declaring a particular format, such as 'newick_tree',
'phylo_xml_tree' or 'json_tree'.  When a format is not explictily specified, it is possible to return
trees in different formats depending on addtional parameters. Regardless of format, all leaf nodes
in trees built from MSAs are indexed to a specific MSA row.  You can use the appropriate functionality
of the API to replace these IDs with other KBase Ids instead. Internal nodes may or may not be named.
Nodes, depending on the format, may also be annotated with structured data such as bootstrap values and
distances.


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



=head2 newick_tree

=over 4



=item Description

Trees are represented in KBase by default in newick format (http://en.wikipedia.org/wiki/Newick_format)
and are returned to you in this format by default.


=item Definition

=begin html

<pre>
a tree
</pre>

=end html

=begin text

a tree

=end text

=back



=head2 phylo_xml_tree

=over 4



=item Description

Trees are represented in KBase by default in newick format (http://en.wikipedia.org/wiki/Newick_format),
but can optionally be converted to the more verbose phyloXML format, which is useful for compatibility or
when additional information/annotations decorate the tree.


=item Definition

=begin html

<pre>
a tree
</pre>

=end html

=begin text

a tree

=end text

=back



=head2 json_tree

=over 4



=item Description

Trees are represented in KBase by default in newick format (http://en.wikipedia.org/wiki/Newick_format),
but can optionally be converted to JSON format where the structure of the tree matches the structure of
the JSON object.  This is useful when interacting with the tree in JavaScript, for instance.


=item Definition

=begin html

<pre>
a tree
</pre>

=end html

=begin text

a tree

=end text

=back



=head2 alignment

=over 4



=item Description

String representation of a sequence alignment, the format of which may be different depending on
input options for retrieving the alignment.


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



=head2 ws_obj_id

=over 4



=item Description

@id ws


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



=head2 ws_tree_id

=over 4



=item Description

A workspace ID that references a Tree data object.
@id ws KBaseTrees.Tree


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



=head2 ws_alignment_id

=over 4



=item Description

###  KBaseTrees.ConcatMSA KBaseTrees.MS
        @id ws KBaseTrees.MSA


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



=head2 ws_tree_id

=over 4



=item Description

@id ws KBaseTrees.Tree


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



=head2 ws_genome_id

=over 4



=item Description

A workspace ID that references a Genome data object.
@id ws KBaseGenomes.Genome


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



=head2 ws_genomeset_id

=over 4



=item Description

A workspace ID that references a GenomeSet data object.
@id ws KBaseSearch.GenomeSet


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



=head2 ws_featureset_id

=over 4



=item Description

A workspace ID that references a FeatureSet data object.
@id ws KBaseSearch.FeatureSet


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



=head2 node_id

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



=head2 is_leaf

=over 4



=item Definition

=begin html

<pre>
a boolean
</pre>

=end html

=begin text

a boolean

=end text

=back



=head2 label

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



=head2 ref_type

=over 4



=item Description

An enumeration of reference types for a node.  Either the one letter abreviation or full
name can be given.  For large trees, it is strongly advised you use the one letter abreviations.
Supported types are:
    g | genome  => genome typed object or CDS data
    p | protein => protein sequence object or CDS data, often given as the MD5 of the sequence
    n | dna     => dna sequence object or CDS data, often given as the MD5 of the sequence
    f | feature => feature object or CDS data


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



=head2 Tree

=over 4



=item Description

Data type for phylogenetic trees.

    @optional name description type tree_attributes
    @optional default_node_labels ws_refs kb_refs leaf_list


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
description has a value which is a string
type has a value which is a string
tree has a value which is a newick_tree
tree_attributes has a value which is a reference to a hash where the key is a string and the value is a string
default_node_labels has a value which is a reference to a hash where the key is a node_id and the value is a label
ws_refs has a value which is a reference to a hash where the key is a node_id and the value is a reference to a hash where the key is a ref_type and the value is a reference to a list where each element is a ws_obj_id
kb_refs has a value which is a reference to a hash where the key is a node_id and the value is a reference to a hash where the key is a ref_type and the value is a reference to a list where each element is a kbase_id
leaf_list has a value which is a reference to a list where each element is a node_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
description has a value which is a string
type has a value which is a string
tree has a value which is a newick_tree
tree_attributes has a value which is a reference to a hash where the key is a string and the value is a string
default_node_labels has a value which is a reference to a hash where the key is a node_id and the value is a label
ws_refs has a value which is a reference to a hash where the key is a node_id and the value is a reference to a hash where the key is a ref_type and the value is a reference to a list where each element is a ws_obj_id
kb_refs has a value which is a reference to a hash where the key is a node_id and the value is a reference to a hash where the key is a ref_type and the value is a reference to a list where each element is a kbase_id
leaf_list has a value which is a reference to a list where each element is a node_id


=end text

=back



=head2 tree_elt_id

=over 4



=item Description

may include leaves, nodes, and branches


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



=head2 tree_leaf_id

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



=head2 tree_node_id

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



=head2 tree_branch_id

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



=head2 collapsed_node_flag

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



=head2 substructure

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 2 items:
0: (substructure_label) a string
1: (substructure_class) a string

</pre>

=end html

=begin text

a reference to a list containing 2 items:
0: (substructure_label) a string
1: (substructure_class) a string


=end text

=back



=head2 viz_val_string

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 2 items:
0: (value) a string
1: (viz_type) a string

</pre>

=end html

=begin text

a reference to a list containing 2 items:
0: (value) a string
1: (viz_type) a string


=end text

=back



=head2 viz_val_int

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 2 items:
0: (value) an int
1: (viz_type) a string

</pre>

=end html

=begin text

a reference to a list containing 2 items:
0: (value) an int
1: (viz_type) a string


=end text

=back



=head2 viz_val_float

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 2 items:
0: (value) a float
1: (viz_type) a string

</pre>

=end html

=begin text

a reference to a list containing 2 items:
0: (value) a float
1: (viz_type) a string


=end text

=back



=head2 TreeDecoration

=over 4



=item Description

something looks strange with this field:  it was removed so we can compile
 mapping<tree_leaf_id tree_leaf_id, tuple<string substructure_label, string> substructure_by_leaf;


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
tree_id has a value which is a ws_tree_id
viz_title has a value which is a string
string_dataset_labels has a value which is a reference to a list where each element is a string
string_dataset_viz_types has a value which is a reference to a list where each element is a string
int_dataset_labels has a value which is a reference to a list where each element is a string
int_dataset_viz_types has a value which is a reference to a list where each element is a string
float_dataset_labels has a value which is a reference to a list where each element is a string
float_dataset_viz_types has a value which is a reference to a list where each element is a string
tree_val_list_string has a value which is a reference to a hash where the key is a tree_elt_id and the value is a reference to a list where each element is a viz_val_string
tree_val_list_int has a value which is a reference to a hash where the key is a tree_elt_id and the value is a reference to a list where each element is a viz_val_int
tree_val_list_float has a value which is a reference to a hash where the key is a tree_elt_id and the value is a reference to a list where each element is a viz_val_float
collapsed_by_node has a value which is a reference to a hash where the key is a tree_node_id and the value is a collapsed_node_flag
substructure_by_node has a value which is a reference to a hash where the key is a tree_node_id and the value is a substructure
rooted_flag has a value which is a string
alt_root_id has a value which is a node_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
tree_id has a value which is a ws_tree_id
viz_title has a value which is a string
string_dataset_labels has a value which is a reference to a list where each element is a string
string_dataset_viz_types has a value which is a reference to a list where each element is a string
int_dataset_labels has a value which is a reference to a list where each element is a string
int_dataset_viz_types has a value which is a reference to a list where each element is a string
float_dataset_labels has a value which is a reference to a list where each element is a string
float_dataset_viz_types has a value which is a reference to a list where each element is a string
tree_val_list_string has a value which is a reference to a hash where the key is a tree_elt_id and the value is a reference to a list where each element is a viz_val_string
tree_val_list_int has a value which is a reference to a hash where the key is a tree_elt_id and the value is a reference to a list where each element is a viz_val_int
tree_val_list_float has a value which is a reference to a hash where the key is a tree_elt_id and the value is a reference to a list where each element is a viz_val_float
collapsed_by_node has a value which is a reference to a hash where the key is a tree_node_id and the value is a collapsed_node_flag
substructure_by_node has a value which is a reference to a hash where the key is a tree_node_id and the value is a substructure
rooted_flag has a value which is a string
alt_root_id has a value which is a node_id


=end text

=back



=head2 row_id

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



=head2 sequence

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



=head2 start_pos_in_parent

=over 4



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



=head2 end_pos_in_parent

=over 4



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



=head2 parent_len

=over 4



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



=head2 parent_md5

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



=head2 trim_info

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 4 items:
0: a start_pos_in_parent
1: an end_pos_in_parent
2: a parent_len
3: a parent_md5

</pre>

=end html

=begin text

a reference to a list containing 4 items:
0: a start_pos_in_parent
1: an end_pos_in_parent
2: a parent_len
3: a parent_md5


=end text

=back



=head2 MSA

=over 4



=item Description

Type for multiple sequence alignment.
sequence_type - 'protein' in case sequences are amino acids, 'dna' in case of 
        nucleotides.
int alignment_length - number of columns in alignment.
mapping<row_id, sequence> alignment - mapping from sequence id to aligned sequence.
list<row_id> row_order - list of sequence ids defining alignment order (optional). 
ws_alignment_id parent_msa_ref - reference to parental alignment object to which 
        this object adds some new aligned sequences (it could be useful in case of
        profile alignments where you don't need to insert new gaps in original msa).
@optional name description sequence_type
@optional trim_info alignment_attributes row_order 
@optional default_row_labels ws_refs kb_refs
@optional parent_msa_ref


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
description has a value which is a string
sequence_type has a value which is a string
alignment_length has a value which is an int
alignment has a value which is a reference to a hash where the key is a row_id and the value is a sequence
trim_info has a value which is a reference to a hash where the key is a row_id and the value is a trim_info
alignment_attributes has a value which is a reference to a hash where the key is a string and the value is a string
row_order has a value which is a reference to a list where each element is a row_id
default_row_labels has a value which is a reference to a hash where the key is a node_id and the value is a label
ws_refs has a value which is a reference to a hash where the key is a node_id and the value is a reference to a hash where the key is a ref_type and the value is a reference to a list where each element is a ws_obj_id
kb_refs has a value which is a reference to a hash where the key is a node_id and the value is a reference to a hash where the key is a ref_type and the value is a reference to a list where each element is a kbase_id
parent_msa_ref has a value which is a ws_alignment_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
description has a value which is a string
sequence_type has a value which is a string
alignment_length has a value which is an int
alignment has a value which is a reference to a hash where the key is a row_id and the value is a sequence
trim_info has a value which is a reference to a hash where the key is a row_id and the value is a trim_info
alignment_attributes has a value which is a reference to a hash where the key is a string and the value is a string
row_order has a value which is a reference to a list where each element is a row_id
default_row_labels has a value which is a reference to a hash where the key is a node_id and the value is a label
ws_refs has a value which is a reference to a hash where the key is a node_id and the value is a reference to a hash where the key is a ref_type and the value is a reference to a list where each element is a ws_obj_id
kb_refs has a value which is a reference to a hash where the key is a node_id and the value is a reference to a hash where the key is a ref_type and the value is a reference to a list where each element is a kbase_id
parent_msa_ref has a value which is a ws_alignment_id


=end text

=back



=head2 MSASetElement

=over 4



=item Description

Type for MSA collection element. There could be mutual exclusively 
defined either ref or data field.
@optional metadata
@optional ref
@optional data


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
metadata has a value which is a reference to a hash where the key is a string and the value is a string
ref has a value which is a ws_alignment_id
data has a value which is an MSA

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
metadata has a value which is a reference to a hash where the key is a string and the value is a string
ref has a value which is a ws_alignment_id
data has a value which is an MSA


=end text

=back



=head2 MSASet

=over 4



=item Description

Type for collection of MSA objects.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
description has a value which is a string
elements has a value which is a reference to a list where each element is an MSASetElement

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
description has a value which is a string
elements has a value which is a reference to a list where each element is an MSASetElement


=end text

=back



=head2 node_name

=over 4



=item Description

The string representation of the parsed node name (may be a kbase_id, but does not have to be).  Note that this
is not the full, raw label in a newick_tree (which may include comments).


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



=head2 TreeMetaData

=over 4



=item Description

Meta data associated with a tree.

    kbase_id alignment_id - if this tree was built from an alignment, this provides that alignment id
    string type - the type of tree; possible values currently are "sequence_alignment" and "genome" for trees
                  either built from a sequence alignment, or imported directly indexed to genomes.
    string status - set to 'active' if this is the latest built tree for a particular gene family
    timestamp date_created - time at which the tree was built/loaded in seconds since the epoch
    string tree_contruction_method - the name of the software used to construct the tree
    string tree_construction_parameters - any non-default parameters of the tree construction method
    string tree_protocol - simple free-form text which may provide additional details of how the tree was built
    int node_count - total number of nodes in the tree
    int leaf_count - total number of leaf nodes in the tree (generally this cooresponds to the number of sequences)
    string source_db - the source database where this tree originated, if one exists
    string source_id - the id of this tree in an external database, if one exists


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
alignment_id has a value which is a kbase_id
type has a value which is a string
status has a value which is a string
date_created has a value which is a timestamp
tree_contruction_method has a value which is a string
tree_construction_parameters has a value which is a string
tree_protocol has a value which is a string
node_count has a value which is an int
leaf_count has a value which is an int
source_db has a value which is a string
source_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
alignment_id has a value which is a kbase_id
type has a value which is a string
status has a value which is a string
date_created has a value which is a timestamp
tree_contruction_method has a value which is a string
tree_construction_parameters has a value which is a string
tree_protocol has a value which is a string
node_count has a value which is an int
leaf_count has a value which is an int
source_db has a value which is a string
source_id has a value which is a string


=end text

=back



=head2 AlignmentMetaData

=over 4



=item Description

Meta data associated with an alignment.

    list<kbase_id> tree_ids - the set of trees that were built from this alignment
    string status - set to 'active' if this is the latest alignment for a particular set of sequences
    string sequence_type - indicates what type of sequence is aligned (e.g. protein vs. dna)
    boolean is_concatenation - true if the alignment is based on the concatenation of multiple non-contiguous
                            sequences, false if each row cooresponds to exactly one sequence (possibly with gaps)
    timestamp date_created - time at which the alignment was built/loaded in seconds since the epoch
    int n_rows - number of rows in the alignment
    int n_cols - number of columns in the alignment
    string alignment_construction_method - the name of the software tool used to build the alignment
    string alignment_construction_parameters - set of non-default parameters used to construct the alignment
    string alignment_protocol - simple free-form text which may provide additional details of how the alignment was built
    string source_db - the source database where this alignment originated, if one exists
    string source_id - the id of this alignment in an external database, if one exists


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
tree_ids has a value which is a reference to a list where each element is a kbase_id
status has a value which is a string
sequence_type has a value which is a string
is_concatenation has a value which is a string
date_created has a value which is a timestamp
n_rows has a value which is an int
n_cols has a value which is an int
alignment_construction_method has a value which is a string
alignment_construction_parameters has a value which is a string
alignment_protocol has a value which is a string
source_db has a value which is a string
source_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
tree_ids has a value which is a reference to a list where each element is a kbase_id
status has a value which is a string
sequence_type has a value which is a string
is_concatenation has a value which is a string
date_created has a value which is a timestamp
n_rows has a value which is an int
n_cols has a value which is an int
alignment_construction_method has a value which is a string
alignment_construction_parameters has a value which is a string
alignment_protocol has a value which is a string
source_db has a value which is a string
source_id has a value which is a string


=end text

=back



=head2 CdsImportTreeParameters

=over 4



=item Description

Parameters for importing phylogentic tree data from the Central Data Store to
the Workspace, which allows you to manipulate, edit, and use the tree data in
the narrative interface.

load_alignment_for_tree - if true, load the alignment that was used to build the tree (default = false)

default label => one of protein_md5, feature, genome, genome_species

@optional load_alignment_for_tree

@optional ws_tree_name additional_tree_ws_metadata
@optional ws_alignment_name additional_alignment_ws_metadata

@optional link_nodes_to_best_feature link_nodes_to_best_genome link_nodes_to_best_genome_name
@optional link_nodes_to_all_features link_nodes_to_all_genomes link_nodes_to_all_genome_names
@optional default_label


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
tree_id has a value which is a kbase_id
load_alignment_for_tree has a value which is a boolean
ws_tree_name has a value which is a string
additional_tree_ws_metadata has a value which is a reference to a hash where the key is a string and the value is a string
ws_alignment_name has a value which is a string
additional_alignment_ws_metadata has a value which is a reference to a hash where the key is a string and the value is a string
link_nodes_to_best_feature has a value which is a boolean
link_nodes_to_best_genome has a value which is a boolean
link_nodes_to_best_genome_name has a value which is a boolean
link_nodes_to_all_features has a value which is a boolean
link_nodes_to_all_genomes has a value which is a boolean
link_nodes_to_all_genome_names has a value which is a boolean
default_label has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
tree_id has a value which is a kbase_id
load_alignment_for_tree has a value which is a boolean
ws_tree_name has a value which is a string
additional_tree_ws_metadata has a value which is a reference to a hash where the key is a string and the value is a string
ws_alignment_name has a value which is a string
additional_alignment_ws_metadata has a value which is a reference to a hash where the key is a string and the value is a string
link_nodes_to_best_feature has a value which is a boolean
link_nodes_to_best_genome has a value which is a boolean
link_nodes_to_best_genome_name has a value which is a boolean
link_nodes_to_all_features has a value which is a boolean
link_nodes_to_all_genomes has a value which is a boolean
link_nodes_to_all_genome_names has a value which is a boolean
default_label has a value which is a string


=end text

=back



=head2 object_info

=over 4



=item Description

Information about an object, including user provided metadata.

        obj_id objid - the numerical id of the object.
        obj_name name - the name of the object.
        type_string type - the type of the object.
        timestamp save_date - the save date of the object.
        obj_ver ver - the version of the object.
        username saved_by - the user that saved or copied the object.
        ws_id wsid - the workspace containing the object.
        ws_name workspace - the workspace containing the object.
        string chsum - the md5 checksum of the object.
        int size - the size of the object in bytes.
        usermeta meta - arbitrary user-supplied metadata about
                the object.


=item Definition

=begin html

<pre>
a reference to a list containing 11 items:
0: (objid) an int
1: (name) a string
2: (type) a string
3: (save_date) a string
4: (version) an int
5: (saved_by) a string
6: (wsid) an int
7: (workspace) a string
8: (chsum) a string
9: (size) an int
10: (meta) a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

a reference to a list containing 11 items:
0: (objid) an int
1: (name) a string
2: (type) a string
3: (save_date) a string
4: (version) an int
5: (saved_by) a string
6: (wsid) an int
7: (workspace) a string
8: (chsum) a string
9: (size) an int
10: (meta) a reference to a hash where the key is a string and the value is a string


=end text

=back



=head2 AbundanceParams

=over 4



=item Description

Structure to group input parameters to the compute_abundance_profile method.

    kbase_id tree_id                - the KBase ID of the tree to compute abundances for; the tree is
                                      used to identify the set of sequences that were aligned to build
                                      the tree; each leaf node of a tree built from an alignment will
                                      be mapped to a sequence; the compute_abundance_profile method
                                      assumes that trees are built from protein sequences
    string protein_family_name      - the name of the protein family used to pull a small set of reads
                                      from a metagenomic sample; currently only COG families are supported
    string protein_family_source    - the name of the source of the protein family; currently supported
                                      protein families are: 'COG'
    string metagenomic_sample_id    - the ID of the metagenomic sample to lookup; see the KBase communities
                                      service to identifiy metagenomic samples
    int percent_identity_threshold  - the minimum acceptable percent identity for hits, provided as a percentage
                                      and not a fraction (i.e. set to 87.5 for 87.5%)
    int match_length_threshold      - the minimum acceptable length of a match to consider a hit


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
tree_id has a value which is a kbase_id
protein_family_name has a value which is a string
protein_family_source has a value which is a string
metagenomic_sample_id has a value which is a string
percent_identity_threshold has a value which is an int
match_length_threshold has a value which is an int
mg_auth_key has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
tree_id has a value which is a kbase_id
protein_family_name has a value which is a string
protein_family_source has a value which is a string
metagenomic_sample_id has a value which is a string
percent_identity_threshold has a value which is an int
match_length_threshold has a value which is an int
mg_auth_key has a value which is a string


=end text

=back



=head2 AbundanceResult

=over 4



=item Description

Structure to group output of the compute_abundance_profile method.

    mapping <string,int> abundances - maps the raw row ID of each leaf node in the input tree to the number
                                      of hits that map to the given leaf; only row IDs with 1 or more hits
                                      are added to this map, thus missing leaf nodes imply 0 hits
    int n_hits                      - the total number of hits in this sample to any leaf
    int n_reads                     - the total number of reads that were identified for the input protein
                                      family; if the protein family could not be found this will be zero.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
abundances has a value which is a reference to a hash where the key is a string and the value is an int
n_hits has a value which is an int
n_reads has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
abundances has a value which is a reference to a hash where the key is a string and the value is an int
n_hits has a value which is an int
n_reads has a value which is an int


=end text

=back



=head2 abundance_profile

=over 4



=item Description

map an id to a number (e.g. feature_id mapped to a log2 normalized abundance value)


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a float
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a float

=end text

=back



=head2 abundance_data

=over 4



=item Description

map the name of the profile with the profile data


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is an abundance_profile
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is an abundance_profile

=end text

=back



=head2 FilterParams

=over 4



=item Description

cutoff_value                  => def: 0 || [any_valid_float_value]
use_cutoff_value              => def: 0 || 1
normalization_scope           => def:'per_column' || 'global'
normalization_type            => def:'none' || 'total' || 'mean' || 'max' || 'min'
normalization_post_process    => def:'none' || 'log10' || 'log2' || 'ln'


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
cutoff_value has a value which is a float
use_cutoff_value has a value which is a boolean
cutoff_number_of_records has a value which is a float
use_cutoff_number_of_records has a value which is a boolean
normalization_scope has a value which is a string
normalization_type has a value which is a string
normalization_post_process has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
cutoff_value has a value which is a float
use_cutoff_value has a value which is a boolean
cutoff_number_of_records has a value which is a float
use_cutoff_number_of_records has a value which is a boolean
normalization_scope has a value which is a string
normalization_type has a value which is a string
normalization_post_process has a value which is a string


=end text

=back



=head2 html_file

=over 4



=item Description

String in HTML format, used in the KBase Tree library for returning rendered trees.


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



=head2 genome_ref

=over 4



=item Description

A convenience type representing a genome id reference. This might be a kbase_id (in the case of 
a CDM genome) or, more likely, a workspace reference of the structure "ws/obj/ver"


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



=head2 scientific_name

=over 4



=item Description

A string representation of the scientific name of a species.


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



=head2 ConstructSpeciesTreeParams

=over 4



=item Description

Input data type for construct_species_tree method. Method produces object of Tree type.

        new_genomes - (optional) the list of genome references to use in constructing a tree; either
            new_genomes or genomeset_ref field should be defined.
        genomeset_ref - (optional) reference to genomeset object; either new_genomes or genomeset_ref
            field should be defined.
        out_workspace - (required) the workspace to deposit the completed tree
        out_tree_id - (optional) the name of the newly constructed tree (will be random if not present or null)
        use_ribosomal_s9_only - (optional) 1 means only one protein family (Ribosomal S9) is used for 
            tree construction rather than all 49 improtant families, default value is 0.
        nearest_genome_count - (optional) defines maximum number of public genomes nearest to
            requested genomes that will show in output tree.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
new_genomes has a value which is a reference to a list where each element is a genome_ref
genomeset_ref has a value which is a ws_genomeset_id
out_workspace has a value which is a string
out_tree_id has a value which is a string
use_ribosomal_s9_only has a value which is an int
nearest_genome_count has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
new_genomes has a value which is a reference to a list where each element is a genome_ref
genomeset_ref has a value which is a ws_genomeset_id
out_workspace has a value which is a string
out_tree_id has a value which is a string
use_ribosomal_s9_only has a value which is an int
nearest_genome_count has a value which is an int


=end text

=back



=head2 job_id

=over 4



=item Description

A string representing a job id for manipulating trees. This is an id for a job that is
registered with the User and Job State service.


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



=head2 ConstructMultipleAlignmentParams

=over 4



=item Description

Input data type for construct_multiple_alignment method. Method produces object of MSA type.

        gene_sequences - (optional) the mapping from gene ids to their sequences; either gene_sequences
            or featureset_ref should be defined.
featureset_ref - (optional) reference to FeatureSet object; either gene_sequences or
            featureset_ref should be defined.
        alignment_method - (optional) alignment program, one of: Muscle, Clustal, ProbCons, T-Coffee, 
Mafft (default is Clustal).
        is_protein_mode - (optional) 1 in case sequences are amino acids, 0 in case of nucleotides 
(default value is 1).
        out_workspace - (required) the workspace to deposit the completed alignment
        out_msa_id - (optional) the name of the newly constructed msa (will be random if not present 
or null)


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
gene_sequences has a value which is a reference to a hash where the key is a string and the value is a string
featureset_ref has a value which is a ws_featureset_id
alignment_method has a value which is a string
is_protein_mode has a value which is an int
out_workspace has a value which is a string
out_msa_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
gene_sequences has a value which is a reference to a hash where the key is a string and the value is a string
featureset_ref has a value which is a ws_featureset_id
alignment_method has a value which is a string
is_protein_mode has a value which is an int
out_workspace has a value which is a string
out_msa_id has a value which is a string


=end text

=back



=head2 ConstructTreeForAlignmentParams

=over 4



=item Description

Input data type for construct_tree_for_alignment method. Method produces object of Tree type.

msa_ref - (required) reference to MSA input object.
        tree_method - (optional) tree construction program, one of 'Clustal' (Neighbor-joining approach) or 
'FastTree' (where Maximum likelihood is used), (default is 'Clustal').
        min_nongap_percentage_for_trim - (optional) minimum percentage of non-gapped positions in alignment column,
if you define this parameter in 50, then columns having less than half non-gapped letters are trimmed
(default value is 0 - it means no trimming at all). 
        out_workspace - (required) the workspace to deposit the completed tree
        out_tree_id - (optional) the name of the newly constructed tree (will be random if not present or null)


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
msa_ref has a value which is a ws_alignment_id
tree_method has a value which is a string
min_nongap_percentage_for_trim has a value which is an int
out_workspace has a value which is a string
out_tree_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
msa_ref has a value which is a ws_alignment_id
tree_method has a value which is a string
min_nongap_percentage_for_trim has a value which is an int
out_workspace has a value which is a string
out_tree_id has a value which is a string


=end text

=back



=head2 FindCloseGenomesParams

=over 4



=item Description

Input data type for find_close_genomes method. Method produces list of refereces to public genomes similar to query.

        query_genome - (required) query genome reference
        max_mismatch_percent - (optional) defines maximum mismatch percentage when compare aminoacids from user genome with 
            public genomes (defualt value is 5).


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
query_genome has a value which is a genome_ref
max_mismatch_percent has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
query_genome has a value which is a genome_ref
max_mismatch_percent has a value which is an int


=end text

=back



=head2 GuessTaxonomyPathParams

=over 4



=item Description

Input data type for guess_taxonomy_path method. Method produces taxonomy path string.

        query_genome - (required) query genome reference


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
query_genome has a value which is a genome_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
query_genome has a value which is a genome_ref


=end text

=back



=head2 BuildGenomeSetFromTreeParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
tree_ref has a value which is a ws_tree_id
genomeset_ref has a value which is a ws_genomeset_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
tree_ref has a value which is a ws_tree_id
genomeset_ref has a value which is a ws_genomeset_id


=end text

=back



=cut

package Bio::KBase::KBaseTrees::Client::RpcClient;
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
