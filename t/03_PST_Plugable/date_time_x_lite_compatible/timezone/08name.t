use strict;
use warnings;

use File::Spec;
use Test::More;

use lib File::Spec->catdir( File::Spec->curdir, 't' );

use Text::PSTemplate::DateTime::TimeZone;

plan tests => 4;

{
    my $tz = Text::PSTemplate::DateTime::TimeZone->load( name => '-0300' );
    is( $tz->name, '-0300', 'name should match value given in constructor' );
}

{
    my $tz = Text::PSTemplate::DateTime::TimeZone->load( name => 'floating' );
    is( $tz->name, 'floating', 'name should match value given in constructor' );
}

{
    my $tz = Text::PSTemplate::DateTime::TimeZone->load( name => 'America/Chicago' );
    is( $tz->name, 'America/Chicago', 'name should match value given in constructor' );
}

{
    my $tz = Text::PSTemplate::DateTime::TimeZone->load( name => 'UTC' );
    is( $tz->name, 'UTC', 'name should match value given in constructor' );
}
