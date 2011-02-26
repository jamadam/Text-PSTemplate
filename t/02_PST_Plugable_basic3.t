use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub ini : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Test::_Plugin')->set_ini({locale => 'jp'});
        my $parsed1 = $tpl->parse(q[<% Test::_Plugin::put_locale() %>]);
        is($parsed1, 'jp');
    }
	
	sub cascading_ini : Test(2) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Test::_Plugin')->set_ini({locale => 'jp'});
        $tpl->plug('Test::_Plugin::Sub');
        my $parsed1 = $tpl->parse(q[<% Test::_Plugin::put_locale() %>]);
        is($parsed1, 'jp');
        my $parsed3 = $tpl->parse(q[<% Test::_Plugin::Sub::put_locale() %>]);
        is($parsed3, 'jp');
	}
	
	sub cascading_ini_with_shortcut : Test(2) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		$tpl->set_default_plugin('Test::_Plugin');
        $tpl->plug('Test::_Plugin')->set_ini({locale => 'jp'});
		$tpl->plug('Test::_Plugin::Sub');
        my $parsed1 = $tpl->parse(q[<% put_locale() %>]);
        is($parsed1, 'jp');
        my $parsed3 = $tpl->parse(q[<% ::Sub::put_locale() %>]);
        is($parsed3, 'jp');
	}

package Test::_Plugin;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);

    sub some_func1 : TplExport {
        
        my $plugin = shift;
		my $args = shift;
        return $args;
    }

    sub some_func2 : TplExport {
        
        my $plugin = shift;
		my $args = shift;
        return $args;
    }
	
	sub put_locale : TplExport {
		
		my $plugin = shift;
		return $plugin->ini('locale');
	}

package Test::_Plugin::Sub;
use strict;
use warnings;
use base qw(Test::_Plugin);
