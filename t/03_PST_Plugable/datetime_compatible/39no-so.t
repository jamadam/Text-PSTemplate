# no pp test

use strict;
use warnings;

use Test::More;

no warnings 'once', 'redefine';

require XSLoader;

my $orig = \&XSLoader::load;

my $sub = sub {
    if ( $_[0] eq 'Text::PSTemplate::DateTime' ) {
        die q{Can't locate loadable object for module Text::PSTemplate::DateTime in @INC};
    }
    else {
        goto $orig;
    }
};

*XSLoader::load = $sub;

eval { require Text::PSTemplate::DateTime };
is( $@, '', 'No error loading Text::PSTemplate::DateTime without Text::PSTemplate::DateTime.so file' );
ok( $Text::PSTemplate::DateTime::IsPurePerl, '$Text::PSTemplate::DateTime::IsPurePerl is true' );

ok(
    Text::PSTemplate::DateTime->new( year => 2005 ),
    'can make Text::PSTemplate::DateTime object without Text::PSTemplate::DateTime.so file'
);

done_testing();
