use strict;
use warnings;

use Test::More tests => 5;

use Text::PSTemplate::DateTime::Locale;

Text::PSTemplate::DateTime::Locale->add_aliases( foo => 'root' );
Text::PSTemplate::DateTime::Locale->add_aliases( bar => 'foo' );
Text::PSTemplate::DateTime::Locale->add_aliases( baz => 'bar' );
eval { Text::PSTemplate::DateTime::Locale->add_aliases( bar => 'baz' ) };

like( $@, qr/loop/, 'cannot add an alias that would cause a loop' );

my $l = Text::PSTemplate::DateTime::Locale->load('baz');
isa_ok( $l, 'Text::PSTemplate::DateTime::Locale' );
is( $l->id, 'baz', 'id is baz' );

ok( Text::PSTemplate::DateTime::Locale->remove_alias('baz'), 'remove_alias should return true' );

eval { Text::PSTemplate::DateTime::Locale->load('baz') };
like( $@, qr/invalid/i, 'removed alias should be gone' );
