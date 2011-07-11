use strict;
use warnings;
use lib 'lib';
use lib 't/lib', 't/03_PST_Plugable/lib';
use base 'Test::Class';
use Test::More;
use File::Path;

    __PACKAGE__->runtests;
	
	sub c3 : Test(2) {
		
		require 'Text/PSTemplate.pm';
        my $tpl = Text::PSTemplate->new;
        $tpl->plug('require_ok3_1');
		is(require_ok3_1->internal_use(), 'a');
        rmtree('t/03_PST_Plugable/cache/Test');
		is(_Test::_Sub2->internal_use(), 'b');
        rmtree('t/03_PST_Plugable/cache/Test');
	}
