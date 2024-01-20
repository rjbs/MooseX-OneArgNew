use strict;
use warnings;

use Test::More 0.96;

use Test::Exception;

use Moose::Util::TypeConstraints;

subtype 'Vote' 
    => as 'Int'
    => where { $_ == -1 or $_ == 1 };

enum VoteString => [qw/ ++ -- /];

coerce 'Vote', from 'VoteString', via {
    $_ eq '++' ? 1 : -1
};

throws_ok {
  package Object;
  use Moose;
  use MooseX::OneArgNew;

  has size => (is => 'ro', isa => 'Int',           traits => [qw/ OneArgNew /]);
  has nums => (is => 'ro', isa => 'ArrayRef[Int]', traits => [qw/ OneArgNew /]);

  has vote => ( is => 'ro', isa => 'Vote', coerce => 1, traits => [qw/ OneArgNew /]);
} qr/both attributes.*only one allowed/, 'there can only be one';

{
  package ObjectSize;
  use Moose;
  use MooseX::OneArgNew;

  has size => (is => 'ro', isa => 'Int',           traits => [qw/ OneArgNew /]);
}

{
  package ObjectNums;
  use Moose;
  use MooseX::OneArgNew;

  has nums => (is => 'ro', isa => 'ArrayRef[Int]', traits => [qw/ OneArgNew /]);
}

{
  package ObjectVote;
  use Moose;
  use MooseX::OneArgNew;

  has vote => ( is => 'ro', isa => 'Vote', coerce => 1, traits => [qw/ OneArgNew /]);
}

subtest ObjectSize => sub {
  is(ObjectSize->new({size => 10})->size, 10, 
          "hashref args to ->new worked"
  );

  is( ObjectSize->new( size => 10 )->size => 10,
      'new( size => 10 )'
  );

  is( ObjectSize->new( 10 )->size => 10,
      'new( 10 )'
  );
};

subtest ObjectNums => sub {
  is_deeply(ObjectNums->new({nums => [1,2]})->nums, [1,2], 
          "hashref args to ->new worked"
  );

  is_deeply( ObjectNums->new( nums => [3,4] )->nums => [3,4],
      'new( nums => [] )'
  );

  is_deeply( ObjectNums->new( [5,6] )->nums => [5,6],
      'new( [] )'
  );
};

subtest ObjectVote => sub {
  is_deeply(ObjectVote->new({vote => '++'})->vote, 1, 
          "hashref args to ->new worked"
  );

  is_deeply( ObjectVote->new( vote => '--' )->vote => -1,
      'new( vote => "--" )'
  );

  is_deeply( ObjectVote->new( 1 )->vote => 1,
      'new( 1 )'
  );
};

{
  my $obj = eval { Object->new('ten') };
  my $err = $@;
  ok(! $obj, "couldn't construct Object with non-{} non-Int single-arg new");
  like($err, qr/parameters to new/, "...error message seems plausible");
}

subtest OneDefaultObject => sub {
    package OneDefaultObject;

    use Moose;
    use MooseX::OneArgNew;

    has theone => (is => 'ro', traits => [qw/ OneArgNew /]);

    my $obj = OneDefaultObject->new('Hi!');

    ::is( $obj->theone => 'Hi!', 'one arg goes to "theone"' );

    ::is( OneDefaultObject->new( theone => 'hello' )->theone => 'hello', "regular call" );

    ::is( OneDefaultObject->new()->theone => undef, "no argument" );
};

done_testing;
