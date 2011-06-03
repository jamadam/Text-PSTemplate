use strict;
use warnings;

use Test::More tests => 2;

use Text::PSTemplate::DateTime::Locale;


my $locale = Text::PSTemplate::DateTime::Locale->load( 'en-US' );

ok( $locale, 'loaded locale with dash in name' );
is( $locale->id, 'en_US', 'id is en_US' );

