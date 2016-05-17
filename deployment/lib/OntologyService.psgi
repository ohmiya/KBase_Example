use Bio::KBase::OntologyService::OntologyServiceImpl;

use Bio::KBase::OntologyService::Service;



my @dispatch;

{
    my $obj = Bio::KBase::OntologyService::OntologyServiceImpl->new;
    push(@dispatch, 'Ontology' => $obj);
}


my $server = Bio::KBase::OntologyService::Service->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler;
