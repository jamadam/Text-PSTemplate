use strict;
use warnings;

use File::Spec;
use Test::More;

use lib File::Spec->catdir( File::Spec->curdir, 't' );


use Text::PSTemplate::DateTime::TimeZone;

my @links = Text::PSTemplate::DateTime::TimeZone::links();

plan tests => @links + 2;

for my $link (@links)
{
    my $tz = Text::PSTemplate::DateTime::TimeZone->load( name => $link );
    isa_ok( $tz, 'Text::PSTemplate::DateTime::TimeZone' );
}

my $tz = Text::PSTemplate::DateTime::TimeZone->load( name => 'Libya' );
is( $tz->name, 'Africa/Tripoli', 'check ->name' );

$tz = Text::PSTemplate::DateTime::TimeZone->load( name => 'US/Central' );
is( $tz->name, 'America/Chicago', 'check ->name' );
