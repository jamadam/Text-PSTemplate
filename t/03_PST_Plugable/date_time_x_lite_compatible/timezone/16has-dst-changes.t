use strict;
use warnings;

use File::Spec;
use Test::More;

use lib File::Spec->catdir( File::Spec->curdir, 't' );

use Text::PSTemplate::DateTime::TimeZone;

plan tests => 4;

ok( ! Text::PSTemplate::DateTime::TimeZone->load( name => 'UTC' )->has_dst_changes,
    'UTC has no DST changes' );
ok( ! Text::PSTemplate::DateTime::TimeZone->load( name => 'floating' )->has_dst_changes,
    'floating has no DST changes' );
ok( ! Text::PSTemplate::DateTime::TimeZone->load( name => 'Asia/Thimphu' )->has_dst_changes,
    'Asia/Thimphu has no DST changes' );
ok( Text::PSTemplate::DateTime::TimeZone->load( name => 'America/Chicago' )->has_dst_changes,
    'America/chicago has DST changes' );
