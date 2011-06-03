use strict;
use warnings;

use Test::More;

use Text::PSTemplate::DateTime::Locale;


my @aliases = qw( C POSIX chi per khm );

plan tests => 5 + scalar @aliases;


for my $alias (@aliases)
{
    my $locale = eval { Text::PSTemplate::DateTime::Locale->load($alias) };
    ok( !$@ && $locale, "alias mapping for $alias exists" );
}

my $locale = Text::PSTemplate::DateTime::Locale->load('eng_US');

is( $locale->id, 'eng_US', 'variant()' );

is( $locale->name, 'English United States', 'name()' );
is( $locale->language, 'English', 'language()' );
is( $locale->territory, 'United States', 'territory()' );
is( $locale->variant, undef, 'variant()' );
