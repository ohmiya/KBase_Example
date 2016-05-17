########################################################################
# Bio::KBase::ObjectAPI::KBaseFBA::ModelCompartment - This is the moose object corresponding to the ModelCompartment object
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
# Date of module creation: 2012-03-26T23:22:35
########################################################################
use strict;
use Bio::KBase::ObjectAPI::KBaseFBA::DB::ModelCompartment;
package Bio::KBase::ObjectAPI::KBaseFBA::ModelCompartment;
use Moose;
use namespace::autoclean;
extends 'Bio::KBase::ObjectAPI::KBaseFBA::DB::ModelCompartment';
#***********************************************************************************************************
# ADDITIONAL ATTRIBUTES:
#***********************************************************************************************************
has name  => ( is => 'rw', isa => 'Str',printOrder => '-1', type => 'msdata', metaclass => 'Typed', lazy => 1, builder => '_buildname' );

#***********************************************************************************************************
# BUILDERS:
#***********************************************************************************************************
sub _buildname {
	my ($self) = @_;
	return $self->compartment()->name().$self->compartmentIndex();
}

#***********************************************************************************************************
# CONSTANTS:
#***********************************************************************************************************

#***********************************************************************************************************
# FUNCTIONS:
#***********************************************************************************************************


__PACKAGE__->meta->make_immutable;
1;
