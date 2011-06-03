

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

BEGIN {
    eval "use Text::PSTemplate::DateTime::Format::Strptime 1.2000";
    if ($@) {
        plan skip_all => "Text::PSTemplate::DateTime::Format::Strptime 1.2000+ not installed";
    }
}

use Text::PSTemplate::DateTime;

my $formatter = Text::PSTemplate::DateTime::Format::Strptime->new(
    pattern => '%Y%m%d %T',
    locale  => 'en_US',
);

my $dt = Text::PSTemplate::DateTime->from_epoch( epoch => time(), formatter => $formatter );
ok( $dt, "Constructor (from_epoch) : $@" );

$dt = eval {
    Text::PSTemplate::DateTime->new(
        year      => 2004,
        month     => 9,
        day       => 2,
        hour      => 13,
        minute    => 23,
        second    => 34,
        formatter => $formatter
    );
};
ok( $dt, "Constructor (new) : $@" );

$dt
    = eval { Text::PSTemplate::DateTime->from_object( object => $dt, formatter => $formatter ) };
ok( $dt, "Constructor (from_object) : $@" );

is( $dt->formatter, $formatter, "check from_object copies formatter" );

is( $dt->_stringify(), '20040902 13:23:34', 'Format Text::PSTemplate::DateTime' );

# check stringification (with formatter)
is( $dt->_stringify, "$dt", "Stringification (with formatter)" );

# check that set() and truncate() don't lose formatter
$dt->set( hour => 3 );
is( $dt->_stringify, '20040902 03:23:34',
    'formatter is preserved after set()' );

$dt->truncate( to => 'minute' );
is( $dt->_stringify, '20040902 03:23:00',
    'formatter is preserved after truncate()' );

# check if the default behavior works
$dt->set_formatter(undef);
is( $dt->_stringify(), $dt->iso8601, 'Default iso8601 works' );

# check stringification (default)
is( $dt->_stringify, "$dt",
    "Stringification (no formatter -> format_Text::PSTemplate::DateTime)" );
is( $dt->iso8601, "$dt", "Stringification (no formatter -> iso8601)" );

done_testing();

