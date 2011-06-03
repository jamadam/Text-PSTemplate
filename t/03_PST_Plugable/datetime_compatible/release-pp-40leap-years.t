

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

for my $y ( 0, 400, 2000, 2004 ) {
    ok( Text::PSTemplate::DateTime->_is_leap_year($y), "$y is a leap year" );
}

for my $y ( 1, 100, 1900, 2133 ) {
    ok( !Text::PSTemplate::DateTime->_is_leap_year($y), "$y is not a leap year" );
}

done_testing();

