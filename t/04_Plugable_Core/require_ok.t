use strict;
use warnings;
use Test::More;
eval {
    require 'lib/Text/PSTemplate/Plugable.pm';
};

	use Test::More tests => 6;
    
    my $tpl;
    
    $tpl = Text::PSTemplate->new;
    my $tpl2 = Text::PSTemplate->new;
    is(ref $tpl2,'Text::PSTemplate');
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('_Test','');
    my $parsed = $tpl->parse('<% test()<<EOF %><% subtest() %><% EOF %>');
    is($parsed, 'ok');
    my $parsed2 = eval {
        $tpl->parse('<% subtest() %>');
    };
    isnt($@, '');
    
    $tpl = Text::PSTemplate->new;
    is(ref $tpl,'Text::PSTemplate');
    is(_Test->internal_use(), 'a');
    is(_Test::_Sub2->internal_use(), 'a');

package _Test;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
    
    sub internal_use {
        
        return 'a';
    }

    sub test : TplExport {
        
        my ($self) = @_;
        my $block = Text::PSTemplate::get_block(0);
        my $tpl = Text::PSTemplate->new;
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
        shift->SUPER::internal_use();
    }
