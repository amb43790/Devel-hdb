use strict;
use warnings;

use lib 't';
use HdbHelper;
use Devel::hdb::Client;

use Test::More;
if ($^O =~ m/^MS/) {
    plan skip_all => 'Test hangs on Windows';
} else {
    plan tests => 5;
}

my $url = start_test_program();
my $client = Devel::hdb::Client->new(url => $url);

my $resp = $client->continue(next_statement => 1, next_fragment => 0);
my $filename = $resp->{filename};
is_deeply($resp,
    {   filename => $filename,
        line => 6,
        subroutine => 'main::one',
        running => 1,
        stack_depth => 2,
        next_statement => '$a = 6',
        next_fragment => '6',
    },
    'Run to first breakpoint');

$resp = $client->status(next_statement => 1, next_fragment => 1);
is_deeply($resp,
    {   filename => $filename,
        line => 6,
        subroutine => 'main::one',
        running => 1,
        stack_depth => 2,
        next_statement => '$a = 6',
        next_fragment => '$a = 6',
    },
    'status');

$resp = $client->stepin(next_statement => 1);
is_deeply($resp,
    {   filename => $filename,
        line => 6,
        subroutine => 'main::one',
        running => 1,
        stack_depth => 2,
        next_statement => '$b = 6',
    },
    'step in to line 6');
    

$resp = $client->stepout(next_statement => 1);
is_deeply($resp,
    {   filename => $filename,
        line => 2,
        subroutine => 'MAIN',
        running => 1,
        stack_depth => 1,
        next_statement => 'two()',
    },
    'step out to line 2');

$resp = $client->stepover(next_fragment => 0);
is_deeply($resp,
    {   filename => $filename,
        line => 3,
        subroutine => 'MAIN',
        running => 1,
        stack_depth => 1,
        next_fragment => '3',
    },
    'step over to line 3');

__DATA__
one();
two();
$c = 3;
sub one {
    $DB::single=1;
    my $a = 6; my $b = 6;
    7;
}
sub two {
    subtwo();
    11;
    12;
}
sub subtwo {
    $DB::single=1;
    16;
    17;
}
