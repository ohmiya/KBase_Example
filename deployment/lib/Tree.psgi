use Bio::KBase::Tree::TreeImpl;

use Bio::KBase::Tree::Service;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = Bio::KBase::Tree::TreeImpl->new;
    push(@dispatch, 'Tree' => $obj);
}


my $server = Bio::KBase::Tree::Service->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
