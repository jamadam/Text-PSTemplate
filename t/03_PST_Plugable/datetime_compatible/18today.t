use strict;
use warnings;

use Test::More;

use Text::PSTemplate::DateTime;

{
    my $now   = Text::PSTemplate::DateTime->now;
    my $today = Text::PSTemplate::DateTime->today;

    is( $today->year,  $now->year,  'today->year' );
    is( $today->month, $now->month, 'today->month' );
    is( $today->day,   $now->day,   'today->day' );

    is( $today->hour,   0, 'today->hour' );
    is( $today->minute, 0, 'today->hour' );
    is( $today->second, 0, 'today->hour' );
}

done_testing();
