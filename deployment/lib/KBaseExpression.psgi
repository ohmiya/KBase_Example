use Bio::KBase::KBaseExpression::KBaseExpressionImpl;

use Bio::KBase::KBaseExpression::Service;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = Bio::KBase::KBaseExpression::KBaseExpressionImpl->new;
    push(@dispatch, 'KBaseExpression' => $obj);
}


my $server = Bio::KBase::KBaseExpression::Service->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
