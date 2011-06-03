

use Test::More;

BEGIN {
    unless ( $ENV{RELEASE_TESTING} ) {
        plan skip_all => 'these tests are for testing by the release';
    }

    $ENV{PERL_Text::PSTemplate::DateTime_PP} = 1;
}

use strict;
use warnings;

use Test::Exception;
use Test::More;

use Text::PSTemplate::DateTime;
use overload;

my $dt = Text::PSTemplate::DateTime->now;

throws_ok { $dt->set_formatter('Invalid::Formatter') }
qr/can format_Text::PSTemplate::DateTime/, 'set_format is validated';

SKIP:
{
    skip 'This test requires Text::PSTemplate::DateTime::Format::Strptime 1.2000+', 1
        unless eval "use Text::PSTemplate::DateTime::Format::Strptime 1.2000";

    my $formatter = Text::PSTemplate::DateTime::Format::Strptime->new(
        pattern => '%Y%m%d %T',
    );

    is(
        $dt->set_formatter($formatter),
       $dt,
        'set_format returns the Text::PSTemplate::DateTime object'
    );
}

done_testing();

