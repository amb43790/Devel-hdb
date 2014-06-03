use strict;
use warnings;

use lib 't';
use HdbHelper;
use Devel::hdb::Client;

use Test::More;
if ($^O =~ m/^MS/) {
    plan skip_all => 'Test hangs on Windows';
} else {
    plan tests => 12;
}

my $url = start_test_program();
my $client = Devel::hdb::Client->new(url => $url);

my $stack = $client->stack();
ok($stack, 'Request stack position');
$stack = strip_stack($stack);
is_deeply($stack,
    [ { line => 1, subroutine => 'main::MAIN' } ],
    'Stopped on line 1');

my $resp = $client->stepin();
ok($resp, 'step in');
$stack = strip_stack($client->stack);
is_deeply($stack,
    [ { line => 1, subroutine => '(eval)' },
      { line => 1, subroutine => 'main::MAIN' } ],
    'Still stopped on line 1, in the eval');

$resp = $client->stepin();
ok($resp, 'step in');
$stack = strip_stack($client->stack);
is_deeply($stack,
  [ { line => 4, subroutine => 'main::foo' },
    { line => 1, subroutine => '(eval)' },
    { line => 1, subroutine => 'main::MAIN' } ],
    'Stopped on line 4, frame above is line 1');

$resp = $client->stepin();
ok($resp, 'step in');
$stack = strip_stack($client->stack);
is_deeply($stack,
  [ { line => 8, subroutine => 'main::bar' },
    { line => 4, subroutine => 'main::foo' },
    { line => 1, subroutine => '(eval)' },
    { line => 1, subroutine => 'main::MAIN' } ],
    'Stopped on line 8, frames above are lines 4 and 1');

$resp = $client->stepin();
ok($resp, 'step in');
$stack = strip_stack($client->stack);
is_deeply($stack,
  [ { line => 2, subroutine => 'main::MAIN' } ],
    'Stopped on line 2 after the eval');

$resp = $client->stepin();
ok($resp, 'step in');
$stack = strip_stack($client->stack);
is_deeply($stack,
    [ { line => 12, subroutine => 'main::END' },
      { line => 2, subroutine => '(eval)' },
      { line => 2, subroutine => 'main::MAIN' },
    ],
    'Stopped in END block');


__DATA__
eval { foo(); };
exit(2);
sub foo {
    bar();
    5;
}
sub bar {
    die "8";
    9;
}
END {
    12;
}
