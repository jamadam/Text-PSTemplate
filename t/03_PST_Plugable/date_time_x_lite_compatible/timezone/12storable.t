use strict;
use warnings;

use File::Spec;
use Test::More;

use lib File::Spec->catdir( File::Spec->curdir, 't' );


use Text::PSTemplate::DateTime::TimeZone;
use Text::PSTemplate::DateTime::TimeZone::OffsetOnly;
use Storable;

plan tests => 10;


{
    my $tz1 = Text::PSTemplate::DateTime::TimeZone->load( name => 'America/Chicago' );
    my $frozen = Storable::nfreeze($tz1);

    test_thaw_and_clone( $tz1 );
}

{
    for my $obj ( Text::PSTemplate::DateTime::TimeZone::OffsetOnly->new( offset => '+0100' ),
                  Text::PSTemplate::DateTime::TimeZone::Floating->new(),
                  Text::PSTemplate::DateTime::TimeZone::UTC->new(),
                )
    {
        test_thaw_and_clone($obj);
    }
}

sub test_thaw_and_clone
{
    my $tz1 = shift;
    my $name = $tz1->name;

    my $tz2 = Storable::thaw( Storable::nfreeze($tz1) );

    my $class = ref $tz1;
    is( $tz2->name, $name, "thaw frozen $class" );

    if ( exists $tz1->{spans} )
    {
        is_deeply( $tz1->{spans}, $tz2->{spans}, "spans remain shared for $class after freeze/thaw");
    }

    my $tz3 = Storable::dclone($tz1);
    is( $tz3->name, $name, "dclone $class" );

    if ( exists $tz1->{spans} )
    {
        is_deeply( $tz1->{spans}, $tz3->{spans}, "spans remain shared for $class after dclone");
    }
}
