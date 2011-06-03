

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
    my $dt = Text::PSTemplate::DateTime->new( year => 1900, month => 12, day => 1 );

    is( "$dt", '1900-12-01T00:00:00', 'stringification overloading' );
}

{
    my $dt = Text::PSTemplate::DateTime->new(
        year => 2050, month  => 1,  day    => 15,
        hour => 20,   minute => 10, second => 10
    );

    my $before_string = '2050-01-15T20:10:09';
    my $same_string   = '2050-01-15T20:10:10';
    my $after_string  = '2050-01-15T20:10:11';

    is( "$dt", $same_string, 'stringification overloading' );
    ok( $dt eq $same_string, 'eq overloading true' );
    ok( !( $dt eq $after_string ), 'eq overloading false' );
    ok( $dt ne $after_string, 'ne overloading true' );
    ok( !( $dt ne $same_string ), 'ne overloading false' );

    is( $dt cmp $same_string,  0,  'cmp overloading' );
    is( $dt cmp $after_string, -1, '  less than' );
    ok( $dt lt $after_string,     'lt overloading' );
    ok( !( $dt lt $same_string ), '  not' );

    {

        package Other::Date;
        use overload
            q[""] => sub { return ${ $_[0] }; },
            fallback => 1;

        sub new {
            my ( $class, $date ) = @_;
            return bless \$date, $class;
        }
    }

    my $same_od   = Other::Date->new($same_string);
    my $after_od  = Other::Date->new($after_string);
    my $before_od = Other::Date->new($before_string);

    ok( $dt eq $same_od, "Text::PSTemplate::DateTime eq non-Text::PSTemplate::DateTime overloaded object true" );
    ok( !( $dt eq $after_od ), "  eq false" );
    ok( $dt ne $after_od, "  ne true" );
    ok( !( $dt ne $same_od ), "  ne false" );

    is( $dt cmp $same_od,  0,  'cmp overloading' );
    is( $dt cmp $after_od, -1, '  lt overloading' );
    ok( $dt lt $after_od,     'lt overloading' );
    ok( !( $dt lt $same_od ), '  not' );

    is_deeply(
        [
            map { $_ . ' - ' . ( ref $_ || 'no ref' ) }
                sort { $a cmp $b or ref $a cmp ref $b } $same_od, $after_od,
            $before_od, $dt, $same_string, $after_string, $before_string
        ],
        [
            map { $_ . ' - ' . ( ref $_ || 'no ref' ) } $before_string,
            $before_od, $same_string, $dt, $same_od, $after_string, $after_od
        ],
        "eq sort"
    );

    eval { my $x = $dt + 1 };
    like(
        $@, qr/Cannot add 1 to a Text::PSTemplate::DateTime object/,
        'Cannot add plain scalar to a Text::PSTemplate::DateTime object'
    );

    eval { my $x = $dt + bless {}, 'FooBar' };
    like(
        $@, qr/Cannot add FooBar=HASH\([^\)]+\) to a Text::PSTemplate::DateTime object/,
        'Cannot add plain FooBar object to a Text::PSTemplate::DateTime object'
    );

    eval { my $x = $dt - 1 };
    like(
        $@, qr/Cannot subtract 1 from a Text::PSTemplate::DateTime object/,
        'Cannot subtract plain scalar from a Text::PSTemplate::DateTime object'
    );

    eval { my $x = $dt - bless {}, 'FooBar' };
    like(
        $@, qr/Cannot subtract FooBar=HASH\([^\)]+\) from a Text::PSTemplate::DateTime object/,
        'Cannot subtract plain FooBar object from a Text::PSTemplate::DateTime object'
    );

    eval { my $x = $dt > 1 };
    like(
        $@,
        qr/A Text::PSTemplate::DateTime object can only be compared to another Text::PSTemplate::DateTime object/,
        'Cannot compare a Text::PSTemplate::DateTime object to a scalar'
    );

    eval { my $x = $dt > bless {}, 'FooBar' };
    like(
        $@,
        qr/A Text::PSTemplate::DateTime object can only be compared to another Text::PSTemplate::DateTime object/,
        'Cannot compare a Text::PSTemplate::DateTime object to a FooBar object'
    );

    ok(
        !( $dt eq 'some string' ),
        'Text::PSTemplate::DateTime object always compares false to a string'
    );

    ok(
        $dt ne 'some string',
        'Text::PSTemplate::DateTime object always compares false to a string'
    );

    ok(
        $dt eq $dt->clone,
        'Text::PSTemplate::DateTime object is equal to a clone of itself'
    );

    ok(
        !( $dt ne $dt->clone ),
        'Text::PSTemplate::DateTime object is equal to a clone of itself (! ne)'
    );
}

done_testing();

