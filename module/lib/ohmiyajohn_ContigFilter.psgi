use ohmiyajohn_ContigFilter::ohmiyajohn_ContigFilterImpl;

use ohmiyajohn_ContigFilter::ohmiyajohn_ContigFilterServer;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = ohmiyajohn_ContigFilter::ohmiyajohn_ContigFilterImpl->new;
    push(@dispatch, 'ohmiyajohn_ContigFilter' => $obj);
}


my $server = ohmiyajohn_ContigFilter::ohmiyajohn_ContigFilterServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
