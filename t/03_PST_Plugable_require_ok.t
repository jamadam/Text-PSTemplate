use strict;
use warnings;
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
    
    sub basic : Test(2) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		$tpl->plug('_Test','');
		my $parsed = $tpl->parse('<% test()<<EOF %><% subtest() %><% EOF %>');
		is($parsed, 'ok');
		my $parsed2 = eval {
			$tpl->parse('<% subtest() %>');
		};
		isnt($@, '');
    }
	
	sub internal_use : Test(3) {
		
        my $tpl = Text::PSTemplate::Plugable->new;
		is(ref $tpl,'Text::PSTemplate::Plugable');
		is(_Test->internal_use(), 'a');
		is(_Test::_Sub2->internal_use(), 'a');
	}

package _Test;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use Class::C3;
	
	sub internal_use {
		
		return 'a';
	}
	
    sub test : TplExport {
        
        my ($self) = @_;
		my $block = Text::PSTemplate::get_block(0);
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('_Test::_Sub', '');
		$tpl->parse($block);
    }

package _Test::_Sub;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
    
    sub subtest : TplExport {
		return 'ok';
    }

package _Test::_Sub2;
use strict;
use warnings;
use base qw(_Test);

	sub internal_use {
		shift->next::method();
	}