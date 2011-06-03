

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
use Text::PSTemplate::DateTime::Locale;

eval { Text::PSTemplate::DateTime->new( year => 100, locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval { Text::PSTemplate::DateTime->now( locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval { Text::PSTemplate::DateTime->today( locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval { Text::PSTemplate::DateTime->from_epoch( epoch => 1, locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval {
    Text::PSTemplate::DateTime->last_day_of_month( year => 100, month => 2, locale => 'en_US' );
};
is( $@, '', 'make sure constructor accepts locale parameter' );

{

    package DT::Object;
    sub utc_rd_values { ( 0, 0 ) }
}

eval {
    Text::PSTemplate::DateTime->from_object( object => ( bless {}, 'DT::Object' ),
        locale => 'en_US' );
};
is( $@, '', 'make sure constructor accepts locale parameter' );

eval {
    Text::PSTemplate::DateTime->new( year => 100, locale => Text::PSTemplate::DateTime::Locale->load('en_US') );
};
is( $@, '', 'make sure constructor accepts locale parameter as object' );

Text::PSTemplate::DateTime->DefaultLocale('it');
is( Text::PSTemplate::DateTime->now->locale->id, 'it', 'default locale should now be "it"' );

done_testing();

