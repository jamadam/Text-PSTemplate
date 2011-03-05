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
	
	sub array_context : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        my $plug = $tpl->plug('Test::_Plugin')->set_ini({locale => 'jp'});
		my %a = (locale => $plug->ini('locale'));
		is($a{locale}, 'jp');
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
