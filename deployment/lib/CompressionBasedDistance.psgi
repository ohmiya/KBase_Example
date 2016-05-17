use CompressionBasedDistanceImpl;

use CompressionBasedDistanceServer;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = CompressionBasedDistanceImpl->new;
    push(@dispatch, 'CompressionBasedDistance' => $obj);
}


my $server = CompressionBasedDistanceServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
