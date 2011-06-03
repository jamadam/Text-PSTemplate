

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

{
    eval {
        Text::PSTemplate::DateTime->new(
            year => 2003, month     => 4, day => 6,
            hour => 2,    time_zone => 'America/Chicago',
        );
    };

    like( $@, qr/Invalid local time .+/, 'exception for invalid time' );

    eval {
        Text::PSTemplate::DateTime->new(
            year      => 2003, month  => 4,  day    => 6,
            hour      => 2,    minute => 59, second => 59,
            time_zone => 'America/Chicago',
        );
    };
    like( $@, qr/Invalid local time .+/, 'exception for invalid time' );
}

{
    eval {
        Text::PSTemplate::DateTime->new(
            year      => 2003, month  => 4,  day    => 6,
            hour      => 1,    minute => 59, second => 59,
            time_zone => 'America/Chicago',
        );
    };
    ok( !$@, 'no exception for valid time' );

    my $dt = Text::PSTemplate::DateTime->new(
        year      => 2003, month => 4, day => 5,
        hour      => 2,
        time_zone => 'America/Chicago',
    );

    eval { $dt->add( days => 1 ) };
    like( $@, qr/Invalid local time .+/,
        'exception for invalid time produced via add' );
}

done_testing();

