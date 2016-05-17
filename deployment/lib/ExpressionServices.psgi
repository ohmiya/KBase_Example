use Bio::KBase::ExpressionServices::ExpressionServicesImpl;

use Bio::KBase::ExpressionServices::Service;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = Bio::KBase::ExpressionServices::ExpressionServicesImpl->new;
    push(@dispatch, 'ExpressionServices' => $obj);
}


my $server = Bio::KBase::ExpressionServices::Service->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
