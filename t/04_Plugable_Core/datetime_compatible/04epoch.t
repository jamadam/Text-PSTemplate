use strict;
use warnings;
use Test::More;
use Text::PSTemplate::DateTime;

{

    # Tests creating objects from epoch time
    my $t1 = Text::PSTemplate::DateTime->from_epoch( epoch => 0 , time_zone => 'GMT');
    is( $t1->epoch, 0, "epoch should be 0" );

    is( $t1->second, 0,    "seconds are correct on epoch 0" );
    is( $t1->minute, 0,    "minutes are correct on epoch 0" );
    is( $t1->hour,   0,    "hours are correct on epoch 0" );
    is( $t1->day,    1,    "days are correct on epoch 0" );
    is( $t1->month,  1,    "months are correct on epoch 0" );
    is( $t1->year,   1970, "year is correct on epoch 0" );
}

{
    my $dt = Text::PSTemplate::DateTime->from_epoch( epoch => '3600', time_zone => 'GMT');
    is( $dt->epoch, 3600,
        'creation test from epoch = 3600 (compare to epoch)' );
}

{

    # these tests could break if the time changed during the next three lines
    my $now      = time;
    my $nowtest  = Text::PSTemplate::DateTime->now();
    my $nowtest2 = Text::PSTemplate::DateTime->from_epoch( epoch => $now);
    is( $nowtest->hour,   $nowtest2->hour,   "Hour: Create without args" );
    is( $nowtest->month,  $nowtest2->month,  "Month : Create without args" );
    is( $nowtest->minute, $nowtest2->minute, "Minute: Create without args" );
}

{
    my $epochtest = Text::PSTemplate::DateTime->from_epoch( epoch => '997121000' , time_zone => 'GMT');

    is(
        $epochtest->epoch, 997121000,
        "epoch method returns correct value"
    );
    is( $epochtest->hour, 18, "hour" );
    is( $epochtest->min,  3,  "minute" );
}

{

    my $dt = Text::PSTemplate::DateTime->from_epoch(
        epoch     => 0,
        time_zone => '-1',
    );

    is( $dt->offset, -3600, 'offset should be -3600' );
    is( $dt->epoch,  0,     'epoch is 0' );
}

# Adding/subtracting should affect epoch
{
    my $expected = 1049160602;
    my $epochtest = Text::PSTemplate::DateTime->from_epoch( epoch => $expected );
    $epochtest->set_time_zone(0);
    is(
        $epochtest->epoch, $expected,
        "epoch method returns correct value ($expected)"
    );
    is( $epochtest->hour, 1,  "hour" );
    is( $epochtest->min,  30, "minute" );

    $epochtest->add( hours => 2 );
    $expected += 2 * 60 * 60;

    is( $epochtest->hour, 3, "adjusted hour" );
    is(
        $epochtest->epoch, $expected,
        "epoch method returns correct adjusted value ($expected)"
    );

}

done_testing();
