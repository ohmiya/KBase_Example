=head1 NAME

Bio::KBase::Tree::Util

=head1 DESCRIPTION


Utility methods for the Tree service.


created 1/31/2013 - msneddon

=cut

package Bio::KBase::KBaseTrees::Util;

use strict;
use warnings;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(get_tree_client);

# simply returns a new copy of the Tree client based on given URL
sub get_tree_client {
    my $url = shift;
    if (defined($url)) {
	return Bio::KBase::KBaseTrees::Client->new($url);
    }
    return Bio::KBase::KBaseTrees::Client->new();
}

1;