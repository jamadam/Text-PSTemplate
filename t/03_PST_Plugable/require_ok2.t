use strict;
use warnings;
use lib 'lib';
use lib 't/lib', 't/03_PST_Plugable/lib';
use Test::More;
require 'Text/PSTemplate.pm';
    
	use Test::More tests => 2;
    
    my $tpl = Text::PSTemplate->new;
    my $tpl2 = Text::PSTemplate->new;
    is(ref $tpl2,'Text::PSTemplate');
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('require_ok','');
    my $parsed = $tpl->parse('<% extend()<<EOF %><% block() %><% EOF %>');
    is($parsed, 'block');
