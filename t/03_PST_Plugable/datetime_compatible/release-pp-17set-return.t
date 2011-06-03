

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
use Text::PSTemplate::DateTime::Duration;

{
    my $dt = Text::PSTemplate::DateTime->new( year => 2008, month => 2, day => 28 );
    my $du = Text::PSTemplate::DateTime::Duration->new( years => 1 );

    my $p;

    $p = $dt->set( year => 1882 );
    is( Text::PSTemplate::DateTime->compare( $p, $dt ), 0, "set() returns self" );

    $p = $dt->set_time_zone('Australia/Sydney');
    is( Text::PSTemplate::DateTime->compare( $p, $dt ), 0, "set_time_zone() returns self" );

    $p = $dt->add_duration($du);
    is( Text::PSTemplate::DateTime->compare( $p, $dt ), 0, "add_duration() returns self" );

    $p = $dt->add( years => 2 );
    is( Text::PSTemplate::DateTime->compare( $p, $dt ), 0, "add() returns self" );

    $p = $dt->subtract_duration($du);
    is( Text::PSTemplate::DateTime->compare( $p, $dt ), 0, "subtract_duration() returns self" );

    $p = $dt->subtract( years => 3 );
    is( Text::PSTemplate::DateTime->compare( $p, $dt ), 0, "subtract() returns self" );

    $p = $dt->truncate( to => 'day' );
    is( Text::PSTemplate::DateTime->compare( $p, $dt ), 0, "truncate() returns self" );

}

done_testing();

