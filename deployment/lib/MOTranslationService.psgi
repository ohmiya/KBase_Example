use Bio::KBase::MOTranslationService::Impl;

use Bio::KBase::MOTranslationService::Service;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = Bio::KBase::MOTranslationService::Impl->new;
    push(@dispatch, 'MOTranslation' => $obj);
}


my $server = Bio::KBase::MOTranslationService::Service->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
