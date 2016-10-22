use strict;
use warnings;

use Test::More 0.96;

{
  package Object;
  use Moose;
  use MooseX::OneArgNew;

  use Moose::Util::TypeConstraints;

  subtype 'Vote' 
    => as 'Int'
    => where { $_ == -1 or $_ == 1 };

  enum VoteString => [qw/ ++ -- /];

  coerce 'Vote', from 'VoteString', via {
      $_ eq '++' ? 1 : $_ eq '--'
  };

  has size => (is => 'ro', isa => 'Int',           traits => [qw/ OneArgNew /]);
  has nums => (is => 'ro', isa => 'ArrayRef[Int]', traits => [qw/ OneArgNew /]);

  has vote => ( is => 'ro', isa => 'Vote', coerce => 1, traits => [qw/ OneArgNew /]);
}

{
  my $obj = Object->new(10);
  isa_ok($obj, 'Object');
  is($obj->size, 10, "one-arg-new worked");
}

{
  my $obj = Object->new({ size => 10 });
  isa_ok($obj, 'Object');
  is($obj->size, 10, "hashref args to ->new worked");
}

{
  my $obj = Object->new(size => 10);
  isa_ok($obj, 'Object');
  is($obj->size, 10, "pair args to ->new worked");
}

{
  my $obj = Object->new([ 1, 2, 3 ]);
  isa_ok($obj, 'Object');
  is($obj->size, undef, 'no size after ->new([...])');
  is_deeply($obj->nums, [1, 2, 3], "arrayref args to ->new worked");
}

{
  my $obj = Object->new('++');
  isa_ok($obj, 'Object');
  is($obj->size, undef, 'no size after ->new([...])');
  is($obj->nums, undef, "no nums");
  is $obj->vote => 1, 'vote is "1"';
}

{
  my $obj = eval { Object->new('ten') };
  my $err = $@;
  ok(! $obj, "couldn't construct Object with non-{} non-Int single-arg new");
  like($err, qr/parameters to new/, "...error message seems plausible");
}

{
  package OneDefaultObject;
  use Moose;
  use MooseX::OneArgNew;

  has theone => (is => 'ro', traits => [qw/ OneArgNew /]);
}

subtest OneDefaultObject => sub {
    my $obj = OneDefaultObject->new('Hi!');

    is $obj->theone => 'Hi!', 'one arg goes to "theone"';

    is( OneDefaultObject->new( theone => 'hello' )->theone => 'hello', "regular call" );

    is( OneDefaultObject->new()->theone => undef, "no argument" );
};

done_testing;
