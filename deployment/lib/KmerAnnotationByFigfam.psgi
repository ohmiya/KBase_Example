use Bio::KBase::KmerAnnotationByFigfam::KmerAnnotationByFigfamImpl;

use Bio::KBase::KmerAnnotationByFigfam::Service;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = Bio::KBase::KmerAnnotationByFigfam::KmerAnnotationByFigfamImpl->new;
    push(@dispatch, 'KmerAnnotationByFigfam' => $obj);
}


my $server = Bio::KBase::KmerAnnotationByFigfam::Service->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
