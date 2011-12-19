use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 4;
    
    my $tpl = Text::PSTemplate->new;
    is(ref $tpl, 'Text::PSTemplate');
    my $tpl2 = Text::PSTemplate->new($tpl);
    is(ref $tpl2, 'Text::PSTemplate');
    my $tpl3 = Text::PSTemplate->new($tpl);
    is(ref $tpl3, 'Text::PSTemplate');
    my $tpl4 = Text::PSTemplate->new($tpl);
    is(ref $tpl4, 'Text::PSTemplate');
