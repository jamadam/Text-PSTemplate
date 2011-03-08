use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
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
		$tpl->plug('PST_Plugable_require_ok','');
		my $parsed = $tpl->parse('<% extend()<<EOF %><% block() %><% EOF %>');
		is($parsed, 'block');
    }
