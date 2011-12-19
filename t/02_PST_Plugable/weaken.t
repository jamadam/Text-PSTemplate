use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 1;
    
    my $plug;
    {
        my $tpl = Text::PSTemplate->new;
        $plug = $tpl->{pluged};
    }
    is($plug->{'Text::PSTemplate::Plugin::Control'}, undef);
