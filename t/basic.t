use strict;
use warnings;

use Test::More 0.96;

{
  package Object;
  use Moose;
  with 'MooseX::OneArgNew' => {
    type     => 'Int',
    init_arg => 'size',
  };

  has size => (is => 'ro', isa => 'Int');
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
  my $obj = eval { Object->new('ten') };
  my $err = $@;
  ok(! $obj, "couldn't construct Object with non-{} non-Int single-arg new");
  like($err, qr/parameters to new/, "...error message seems plausible");
}

done_testing;
