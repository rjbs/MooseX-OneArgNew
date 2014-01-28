package MooseX::OneArgNew;

use MooseX::Role::Parameterized 1.0;
# ABSTRACT: teach ->new to accept single, non-hashref arguments

=head1 SYNOPSIS

In our class definition:

  package Delivery;
  use Moose;
  with('MooseX::OneArgNew' => {
    type     => 'Existing::Message::Type',
    init_arg => 'message',
  });

  has message => (isa => 'Existing::Message::Type', required => 1);

  has to => (
    is   => 'ro',
    isa  => 'Str',
    lazy => 1,
    default => sub {
      my ($self) = @_;
      $self->message->get('To');
    },
  );

When making a message:

  # The traditional way:

  my $delivery = Delivery->new({ message => $message });
  # or
  my $delivery = Delivery->new({ message => $message, to => $to });

  # With one-arg new:

  my $delivery = Delivery->new($message);

=head1 DESCRIPTION

MooseX::OneArgNew lets your constructor take a single argument, which will be
translated into the value for a one-entry hashref.  It is a L<parameterized
role|MooseX::Role::Parameterized> with three parameters:

=begin  :list

= type

The Moose type that the single argument must be for the one-arg form to work.
This should be an existing type, and may be either a string type or a
MooseX::Type.

= init_arg

This is the string that will be used as the key for the hashref constructed
from the one-arg call to new.

= coerce

If true, a single argument to new will be coerced into the expected type if
possible.  Keep in mind that if there are no coercions for the type, this will
be an error, and that if a coercion from HashRef exists, you might be getting
yourself into a weird situation.

=end :list

=head2 WARNINGS

You can apply MooseX::OneArgNew more than once, but if more than one
application's type matches a single argument to C<new>, the behavior is
undefined and likely to cause bugs.

It would be a B<very bad idea> to supply a type that could accept a normal
hashref of arguments to C<new>.

=cut

use Moose::Util::TypeConstraints;

use namespace::autoclean;

subtype 'MooseX::OneArgNew::_Type',
  as 'Moose::Meta::TypeConstraint';

coerce 'MooseX::OneArgNew::_Type',
  from 'Str',
  via { Moose::Util::TypeConstraints::find_type_constraint($_) };

parameter type => (
  isa      => 'MooseX::OneArgNew::_Type',
  coerce   => 1,
  required => 1,
);

parameter coerce => (
  isa      => 'Bool',
  default  => 0,
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

    my $value = $p->coerce ? $p->type->coerce($_[0]) : $_[0];
    return $self->$orig(@_) unless $p->type->check($value);

    return { $p->init_arg => $value }
  };
};

1;
