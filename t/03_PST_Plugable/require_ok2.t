use strict;
use warnings;
use lib 'lib';
use lib 't/lib', 't/03_PST_Plugable/lib';
use base 'Test::Class';
use Test::More;
require 'Text/PSTemplate.pm';
    
    __PACKAGE__->runtests;
    
    sub require : Test(1) {
        my $tpl = Text::PSTemplate->new;
        my $tpl2 = Text::PSTemplate->new;
        is(ref $tpl2,'Text::PSTemplate');
    }
    
    sub basic : Test(1) {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->plug('require_ok','');
        my $parsed = $tpl->parse('<% extend()<<EOF %><% block() %><% EOF %>');
        is($parsed, 'block');
    }
