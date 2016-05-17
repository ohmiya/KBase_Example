use Bio::KBase::NarrativeJobService::NarrativeJobServiceImpl;

use Bio::KBase::NarrativeJobService::Service;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = Bio::KBase::NarrativeJobService::NarrativeJobServiceImpl->new;
    push(@dispatch, 'NarrativeJobService' => $obj);
}


my $server = Bio::KBase::NarrativeJobService::Service->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
