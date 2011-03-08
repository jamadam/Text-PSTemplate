use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';

    __PACKAGE__->runtests;
	
	sub c3 : Test(2) {
		
        eval {
            require 'lib/Text/PSTemplate/Plugable.pm';
        };
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('PST_Plugable_require_ok3_1');
		is(PST_Plugable_require_ok3_1->internal_use(), 'a');
		is(_Test::_Sub2->internal_use(), 'b');
	}
