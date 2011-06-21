use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub constractor_check : Test(4) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        is(ref $tpl, 'Text::PSTemplate::Plugable');
        my $tpl2 = Text::PSTemplate::Plugable->new($tpl);
        is(ref $tpl2, 'Text::PSTemplate::Plugable');
        my $tpl3 = Text::PSTemplate::Plugable->new($tpl);
        is(ref $tpl3, 'Text::PSTemplate::Plugable');
        my $tpl4 = Text::PSTemplate->new($tpl);
        is(ref $tpl4, 'Text::PSTemplate');
    }
