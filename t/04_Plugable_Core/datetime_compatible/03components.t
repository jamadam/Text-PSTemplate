use strict;
use warnings;
use Test::More;
use Text::PSTemplate::DateTime;

my $d = Text::PSTemplate::DateTime->new(
    year      => 2001,
    month     => 7,
    day       => 5,
    hour      => 2,
    minute    => 12,
    second    => 50,
    time_zone => 'UTC',
);

is( $d->year,           2001,   '->year' );
is( $d->month,          7,      '->month' );
is( $d->quarter,        3,      '->quarter' );
is( $d->month_0,        6,      '->month_0' );
is( $d->month_name,     'July', '->month_name' );
is( $d->month_abbr,     'Jul',  '->month_abbr' );
is( $d->day_of_month,   5,      '->day_of_month' );
is( $d->day_of_month_0, 4,      '->day_of_month_0' );
is( $d->day,            5,      '->day' );
is( $d->day_0,          4,      '->day_0' );
is( $d->mday,           5,      '->mday' );
is( $d->mday_0,         4,      '->mday_0' );
is( $d->mday,           5,      '->mday' );
is( $d->mday_0,         4,      '->mday_0' );
is( $d->hour,           2,      '->hour' );
is( $d->hour_1,         2,      '->hour_1' );
is( $d->hour_12,        2,      '->hour_12' );
is( $d->hour_12_0,      2,      '->hour_12_0' );
is( $d->minute,         12,     '->minute' );
is( $d->min,            12,     '->min' );
is( $d->second,         50,     '->second' );
is( $d->sec,            50,     '->sec' );

is( $d->day_of_year,      186,        '->day_of_year' );
is( $d->day_of_year_0,    185,        '->day_of_year' );
is( $d->day_of_week,      4,          '->day_of_week' );
is( $d->day_of_week_0,    3,          '->day_of_week_0' );
is( $d->wday,             4,          '->wday' );
is( $d->wday_0,           3,          '->wday_0' );
is( $d->day_name,         'Thursday', '->day_name' );
is( $d->day_abbr,         'Thu',      '->day_abrr' );

is( $d->ymd,      '2001-07-05', '->ymd' );
is( $d->ymd('!'), '2001!07!05', "->ymd('!')" );
is( $d->date,     '2001-07-05', '->ymd' );

is( $d->mdy,      '07-05-2001', '->mdy' );
is( $d->mdy('!'), '07!05!2001', "->mdy('!')" );

is( $d->dmy,      '05-07-2001', '->dmy' );
is( $d->dmy('!'), '05!07!2001', "->dmy('!')" );

is( $d->hms,      '02:12:50', '->hms' );
is( $d->hms('!'), '02!12!50', "->hms('!')" );
is( $d->time,     '02:12:50', '->hms' );

is( $d->datetime, '2001-07-05T02:12:50', '->datetime' );
is( $d->iso8601,  '2001-07-05T02:12:50', '->iso8601' );

is( $d->is_leap_year, 0, '->is_leap_year' );

my $leap_d = Text::PSTemplate::DateTime->new(
    year      => 2004,
    month     => 7,
    day       => 5,
    hour      => 2,
    minute    => 12,
    second    => 50,
    time_zone => 'UTC',
);

is( $leap_d->is_leap_year, 1, '->is_leap_year' );

my $sunday = Text::PSTemplate::DateTime->new(
    year      => 2003,
    month     => 1,
    day       => 26,
    time_zone => 'UTC',
);

is( $sunday->day_of_week, 7, "Sunday is day 7" );

my $monday = Text::PSTemplate::DateTime->new(
    year      => 2003,
    month     => 1,
    day       => 27,
    time_zone => 'UTC',
);

is( $monday->day_of_week, 1, "Monday is day 1" );

{

    # time zone offset should not affect the values returned
    my $d = Text::PSTemplate::DateTime->new(
        year      => 2001,
        month     => 7,
        day       => 5,
        hour      => 2,
        minute    => 12,
        second    => 50,
        time_zone => '-0124',
    );

    is( $d->year,         2001, '->year' );
    is( $d->month,        7,    '->month' );
    is( $d->day_of_month, 5,    '->day_of_month' );
    is( $d->hour,         2,    '->hour' );
    is( $d->hour_1,       2,    '->hour_1' );
    is( $d->minute,       12,   '->minute' );
    is( $d->second,       50,   '->second' );
}

# test doy in leap year
{
    my $dt = Text::PSTemplate::DateTime->new(
        year      => 2000, month => 1, day => 5,
        time_zone => 'UTC',
    );

    is( $dt->day_of_year,   5, 'doy for 2000-01-05 should be 5' );
    is( $dt->day_of_year_0, 4, 'doy_0 for 2000-01-05 should be 4' );
}

{
    my $dt = Text::PSTemplate::DateTime->new(
        year      => 2000, month => 2, day => 29,
        time_zone => 'UTC',
    );

    is( $dt->day_of_year,   60, 'doy for 2000-02-29 should be 60' );
    is( $dt->day_of_year_0, 59, 'doy_0 for 2000-02-29 should be 59' );
}

{
    my $dt = Text::PSTemplate::DateTime->new( year => 1996, month => 2, day => 1 );

    is( $dt->quarter,        1,  '->quarter is 1' );
}

{
    my $dt = Text::PSTemplate::DateTime->new( year => 1996, month => 5, day => 1 );

    is( $dt->quarter,        2,  '->quarter is 2' );
}

{
    my $dt = Text::PSTemplate::DateTime->new( year => 1996, month => 8, day => 1 );

    is( $dt->quarter,        3,  '->quarter is 3' );
}

{
    my $dt = Text::PSTemplate::DateTime->new( year => 1996, month => 11, day => 1 );

    is( $dt->quarter,        4,  '->quarter is 4' );
}

done_testing();
