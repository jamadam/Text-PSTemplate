use strict;
use warnings;
use lib 'lib';
use lib 't/lib', 't/03_PST_Plugable/lib';
use base 'Test::Class';
use Test::More;
eval {
	require 'lib/Text/PSTemplate/Plugable.pm';
};

    __PACKAGE__->runtests;
    
	sub require : Test(1) {
        my $tpl = Text::PSTemplate::Plugable->new;
        my $tpl2 = Text::PSTemplate::Plugable->new;
		is(ref $tpl2,'Text::PSTemplate::Plugable');
	}
    
    sub basic : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		$tpl->plug('require_ok','');
		my $parsed = $tpl->parse('<% extend()<<EOF %><% block() %><% EOF %>');
		is($parsed, 'block');
    }
