use Bio::KBase::IdMap::IdMapImpl;

use Bio::KBase::IdMap::Service;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = Bio::KBase::IdMap::IdMapImpl->new;
    push(@dispatch, 'IdMap' => $obj);
}


my $server = Bio::KBase::IdMap::Service->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
