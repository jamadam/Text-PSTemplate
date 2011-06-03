
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

use strict;
use warnings;

use Cwd qw( abs_path );
use Test::More;

BEGIN {
    plan skip_all =>
        'Must set Text::PSTemplate::DateTime_TEST_DEPS to true in order to run these tests'
        unless $ENV{Text::PSTemplate::DateTime_TEST_DEPS};
}

use Test::DependentModules qw( test_all_dependents );

$ENV{PERL_TEST_DM_LOG_DIR} = abs_path('.');

my $exclude = $ENV{Text::PSTemplate::DateTime_TEST_DEPS} eq 'all'
    ? qr/(?:^App-)
                 |
                 ^(?:
                   Archive-RPM
                   |
                   Video-Xine
                  )$
                 /x
    : qr/^(?!Text::PSTemplate::DateTime-)/;

test_all_dependents( 'Text::PSTemplate::DateTime', { exclude => $exclude } );
