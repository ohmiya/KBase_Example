=head1 NAME

Bio::KBase::Tree::Util

=head1 DESCRIPTION


Utility methods for the Tree service.


created 1/31/2013 - msneddon

=cut

package Bio::KBase::Tree::Util;

use strict;
use warnings;
use Data::Dumper;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(getTreeURL get_tree_client);

our $defaultTreeURL = "https://kbase.us/services/tree";


# simply returns a new copy of the Tree client based on the currently set URL
sub get_tree_client {
    return Bio::KBase::Tree::Client->new(getTreeURL());
}


sub getTreeURL {
    my $set = shift;
    my $CurrentURL;
    if (defined($set)) {
    	if ($set eq "default") {
            $set = $defaultTreeURL;
        }
    	$CurrentURL = $set;
    	if (!defined($ENV{KB_RUNNING_IN_IRIS})) {
	    my $filename = "$ENV{HOME}/.kbase_treeURL";
	    open(my $fh, ">", $filename) || return;
	    print $fh $CurrentURL;
	    close($fh);
    	} elsif ($ENV{KB_TREEURL}) {
    	    $ENV{KB_TREEURL} = $CurrentURL;
    	}
    } elsif (!defined($CurrentURL)) {
    	if (!defined($ENV{KB_RUNNING_IN_IRIS})) {
	    my $filename = "$ENV{HOME}/.kbase_treeURL";
	    if( -e $filename ) {
		open(my $fh, "<", $filename) || return;
		$CurrentURL = <$fh>;
		chomp $CurrentURL;
		close($fh);
	    } else {
	    	$CurrentURL = $defaultTreeURL;
	    }
    	} elsif (defined($ENV{KB_TREEURL})) {
	    	$CurrentURL = $ENV{KB_TREEURL};
	    } else {
		$CurrentURL = $defaultTreeURL;
    	} 
    }
    return $CurrentURL;
}





1;