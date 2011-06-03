use strict;
use warnings;

use File::Spec;
use Test::More;
use Text::PSTemplate::DateTime::TimeZone;

use lib File::Spec->catdir( File::Spec->curdir, 't' );


plan tests => 1;

{
    my $tz = eval { Text::PSTemplate::DateTime::TimeZone->load( name => 'America/Chicago; print "hello, world\n";' ) };
    like( $@, qr/invalid name/, 'make sure potentially malicious code cannot sneak into eval' );
}
