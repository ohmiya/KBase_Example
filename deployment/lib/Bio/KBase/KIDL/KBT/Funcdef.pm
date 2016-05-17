package Bio::KBase::KIDL::KBT::Funcdef;

use Moose;
use Data::Dumper;

has 'return_type' => (is => 'rw');
has 'name' => (isa => 'Str', is => 'rw');
has 'async' => (isa => 'Bool', is => 'rw', default => 0);
has 'doc' => (isa => 'Str', is => 'rw');
has 'parameters' => (isa => 'ArrayRef', is => 'rw');
has 'comment' => (isa => 'Maybe[Str]', is => 'rw');
has 'authentication' => (isa => 'Maybe[Str]', is => 'rw');

sub as_string
{
    my($self) = @_;
    return join(" ", "funcdef", $self->return_type->as_string, $self->name,
		'(', join(", ", map { $_->{type}->as_string } @{$self->parameters}), ')') . ";";
}

1;
