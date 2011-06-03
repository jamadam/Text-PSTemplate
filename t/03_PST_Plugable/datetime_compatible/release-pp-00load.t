

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

use_ok('Text::PSTemplate::DateTime');

done_testing();

