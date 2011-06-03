

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

{

    package Text::PSTemplate::DateTime::MySubclass;
    use base 'Text::PSTemplate::DateTime';

    sub duration_class {'Text::PSTemplate::DateTime::Duration::MySubclass'}

    package Text::PSTemplate::DateTime::Duration::MySubclass;
    use base 'Text::PSTemplate::DateTime::Duration';

    sub is_my_subclass {1}
}

my $dt    = Text::PSTemplate::DateTime::MySubclass->now;
my $delta = $dt - $dt;

isa_ok( $delta,       'Text::PSTemplate::DateTime::Duration::MySubclass' );
isa_ok( $dt + $delta, 'Text::PSTemplate::DateTime::MySubclass' );

my $delta_days = $dt->delta_days($dt);
isa_ok( $delta_days, 'Text::PSTemplate::DateTime::Duration::MySubclass' );

done_testing();

