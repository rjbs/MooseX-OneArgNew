package MooseX::OneArgNew;
use MooseX::Role::Parameterized;

use Moose::Util::TypeConstraints;

use namespace::autoclean;

subtype 'MooseX::SingleNewArg::_Type',
  as 'Moose::Meta::TypeConstraint';

coerce 'MooseX::SingleNewArg::_Type',
  from 'Str',
  via { Moose::Util::TypeConstraints::find_type_constraint($_) };

parameter type => (
  isa      => 'MooseX::SingleNewArg::_Type',
  coerce   => 1,
  required => 1,
);

parameter init_arg => (
  isa      => 'Str',
  required => 1,
);

role {
  my $p = shift;

  around BUILDARGS => sub {
    my $orig = shift;
    my $self = shift;
    return $self->$orig(@_) unless @_ == 1;

    return $self->$orig(@_) unless $p->type->check($_[0]);

    return { $p->init_arg => $_[0] }
  };
};

1;
