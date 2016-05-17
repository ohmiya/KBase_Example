package Bio::KBase::AWE::Constants;

use constant        APIServerURL   => '';
use constant        SiteServerURL   => '';

use base 'Exporter';
our @EXPORT_OK = qw(APIServerURL SiteServerURL );
our %EXPORT_TAGS = ( urls => [ qw(APIServerURL SiteServerURL) ] );


1;

