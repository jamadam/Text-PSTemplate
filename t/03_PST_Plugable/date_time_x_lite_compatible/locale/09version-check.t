use strict;
use warnings;

use Test::More
    skip_all => "Unimplemented";

=head1
eval { require Test::Output };
if ($@)
{
    plan skip_all => 'These tests require Test::Output.';
}

plan tests => 1;
{
    package Text::PSTemplate::DateTime::Locale::fake;

    use strict;
    use warnings;

    use Text::PSTemplate::DateTime::Locale;

    use base 'Text::PSTemplate::DateTime::Locale::root';

    sub cldr_version { '0.1' }

    sub _default_date_format_length { 'medium' }

    sub _default_time_format_length { 'medium' }

    Text::PSTemplate::DateTime::Locale->register( id          => 'fake',
                                en_language => 'Fake',
                              );
}

{
    Test::Output::stderr_like
        ( sub { Text::PSTemplate::DateTime::Locale->load('fake') },
          qr/\Qfrom an older version (0.1)/,
          'loading timezone where olson version is older than current'
        );
}
=cut
