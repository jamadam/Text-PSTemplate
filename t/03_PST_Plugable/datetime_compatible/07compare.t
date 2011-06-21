use strict;
use warnings;
use lib 'lib';

use Test::More;

use Text::PSTemplate::DateTime;

my $date1 = Text::PSTemplate::DateTime->new(
    year      => 1997, month  => 10, day    => 24,
    hour      => 12,   minute => 0,  second => 0,
    time_zone => 'UTC'
);
my $date2 = Text::PSTemplate::DateTime->new(
    year      => 1997, month  => 10, day    => 24,
    hour      => 12,   minute => 0,  second => 0,
    time_zone => 'UTC'
);

# make sure that comparing to itself eq 0
my $identity = $date1->compare($date2);

ok( $identity == 0, "Identity comparison" );

$date2 = Text::PSTemplate::DateTime->new(
    year      => 1997, month  => 10, day    => 24,
    hour      => 12,   minute => 0,  second => 1,
    time_zone => 'UTC'
);
ok( $date1->compare($date2) == -1, 'Comparison $a < $b, 1 second diff' );

$date2 = Text::PSTemplate::DateTime->new(
    year      => 1997, month  => 10, day    => 24,
    hour      => 12,   minute => 1,  second => 0,
    time_zone => 'UTC'
);
ok( $date1->compare($date2) == -1, 'Comparison $a < $b, 1 minute diff' );

$date2 = Text::PSTemplate::DateTime->new(
    year      => 1997, month  => 10, day    => 24,
    hour      => 13,   minute => 0,  second => 0,
    time_zone => 'UTC'
);
ok( $date1->compare($date2) == -1, 'Comparison $a < $b, 1 hour diff' );

$date2 = Text::PSTemplate::DateTime->new(
    year      => 1997, month  => 10, day    => 25,
    hour      => 12,   minute => 0,  second => 0,
    time_zone => 'UTC'
);
ok( $date1->compare($date2) == -1, 'Comparison $a < $b, 1 day diff' );

$date2 = Text::PSTemplate::DateTime->new(
    year      => 1997, month  => 11, day    => 24,
    hour      => 12,   minute => 0,  second => 0,
    time_zone => 'UTC'
);
ok( $date1->compare($date2) == -1, 'Comparison $a < $b, 1 month diff' );

$date2 = Text::PSTemplate::DateTime->new(
    year      => 1998, month  => 10, day    => 24,
    hour      => 12,   minute => 0,  second => 0,
    time_zone => 'UTC'
);
ok( $date1->compare($date2) == -1, 'Comparison $a < $b, 1 year diff' );

# $a > $b tests

$date2 = Text::PSTemplate::DateTime->new(
    year      => 1997, month  => 10, day    => 24,
    hour      => 11,   minute => 59, second => 59,
    time_zone => 'UTC'
);
ok( $date1->compare($date2) == 1, 'Comparison $a > $b, 1 second diff' );

$date2 = Text::PSTemplate::DateTime->new(
    year      => 1997, month  => 10, day    => 24,
    hour      => 11,   minute => 59, second => 0,
    time_zone => 'UTC'
);
ok( $date1->compare($date2) == 1, 'Comparison $a > $b, 1 minute diff' );

$date2 = Text::PSTemplate::DateTime->new(
    year      => 1997, month  => 10, day    => 24,
    hour      => 11,   minute => 0,  second => 0,
    time_zone => 'UTC'
);
ok( $date1->compare($date2) == 1, 'Comparison $a > $b, 1 hour diff' );

$date2 = Text::PSTemplate::DateTime->new(
    year      => 1997, month  => 10, day    => 23,
    hour      => 12,   minute => 0,  second => 0,
    time_zone => 'UTC'
);
ok( $date1->compare($date2) == 1, 'Comparison $a > $b, 1 day diff' );

$date2 = Text::PSTemplate::DateTime->new(
    year      => 1997, month  => 9, day    => 24,
    hour      => 12,   minute => 0, second => 0,
    time_zone => 'UTC'
);
ok( $date1->compare($date2) == 1, 'Comparison $a > $b, 1 month diff' );

$date2 = Text::PSTemplate::DateTime->new(
    year      => 1996, month  => 10, day    => 24,
    hour      => 12,   minute => 0,  second => 0,
    time_zone => 'UTC'
);
ok( $date1->compare($date2) == 1, 'Comparison $a > $b, 1 year diff' );

{
    my $date1 = Text::PSTemplate::DateTime->new(
        year       => 2000, month  => 10, day    => 24,
        hour       => 12,   minute => 0,  second => 0,
        nanosecond => 10000,
    );

    my $date2 = Text::PSTemplate::DateTime->new(
        year       => 2000, month  => 10, day    => 24,
        hour       => 12,   minute => 0,  second => 0,
        nanosecond => 10000,
    );

    is( $date1->compare( $date2 ), 0,
        'Comparison with floating time (cmp)' );
    is( ( $date1 <=> $date2 ), 0, 'Comparison with floating time (<=>)' );
    is( ( $date1 cmp $date2 ), 0, 'Comparison with floating time (cmp)' );
}

{

    package DT::Test;

    sub new { shift; bless [@_] }

    sub utc_rd_values { @{ $_[0] } }
}

done_testing();
