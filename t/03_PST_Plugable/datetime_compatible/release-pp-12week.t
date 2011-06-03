

use Test::More;

BEGIN {
    unless ( $ENV{RELEASE_TESTING} ) {
        plan skip_all => 'these tests are for testing by the release';
    }

    $ENV{PERL_Text::PSTemplate::DateTime_PP} = 1;
}

use strict;
use warnings;

use Test::More;

use Text::PSTemplate::DateTime;

my @tests = (
    [ [ 1964, 12, 31 ], [ 1964, 53 ] ],
    [ [ 1965, 1,  1 ],  [ 1964, 53 ] ],
    [ [ 1971, 9,  7 ],  [ 1971, 36 ] ],
    [ [ 1971, 10, 25 ], [ 1971, 43 ] ],
    [ [ 1995, 1,  1 ],  [ 1994, 52 ] ],
    [ [ 1995, 11, 18 ], [ 1995, 46 ] ],
    [ [ 1995, 12, 31 ], [ 1995, 52 ] ],
    [ [ 1996, 12, 31 ], [ 1997, 1 ] ],
    [ [ 2001, 4,  28 ], [ 2001, 17 ] ],
    [ [ 2001, 8,  2 ],  [ 2001, 31 ] ],
    [ [ 2001, 9,  11 ], [ 2001, 37 ] ],
    [ [ 2002, 12, 25 ], [ 2002, 52 ] ],
    [ [ 2002, 12, 31 ], [ 2003, 1 ] ],
    [ [ 2003, 1,  1 ],  [ 2003, 1 ] ],
    [ [ 2003, 12, 31 ], [ 2004, 1 ] ],
    [ [ 2004, 1,  1 ],  [ 2004, 1 ] ],
    [ [ 2004, 12, 31 ], [ 2004, 53 ] ],
    [ [ 2005, 1,  1 ],  [ 2004, 53 ] ],
    [ [ 2005, 12, 31 ], [ 2005, 52 ] ],
    [ [ 2006, 1,  1 ],  [ 2005, 52 ] ],
    [ [ 2006, 12, 31 ], [ 2006, 52 ] ],
    [ [ 2007, 1,  1 ],  [ 2007, 1 ] ],
    [ [ 2007, 12, 31 ], [ 2008, 1 ] ],
    [ [ 2008, 1,  1 ],  [ 2008, 1 ] ],
    [ [ 2008, 12, 31 ], [ 2009, 1 ] ],
    [ [ 2009, 1,  1 ],  [ 2009, 1 ] ],
);

foreach my $test (@tests) {
    my @args    = @{ $test->[0] };
    my @results = @{ $test->[1] };

    my $dt = Text::PSTemplate::DateTime->new(
        year      => $args[0],
        month     => $args[1],
        day       => $args[2],
        time_zone => 'UTC',
    );

    my ( $year, $week ) = $dt->week();

    is( "$year-W$week", "$results[0]-W$results[1]" );
}

done_testing();

