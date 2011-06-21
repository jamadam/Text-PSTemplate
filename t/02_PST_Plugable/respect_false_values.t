use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub zero : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Test::_Plugin');
        my $parsed = $tpl->parse(q[left <% Test::_Plugin::zero() %> right]);
        is($parsed, 'left 0 right');
    }
	
    sub null_string : Test(1) {
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Test::_Plugin');
        my $parsed = $tpl->parse(q[left <% Test::_Plugin::null_string() %> right]);
        is($parsed, 'left  right');
	}
	
    sub undefined : Test(1) {
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Test::_Plugin');
        my $parsed = $tpl->parse(q[left <% Test::_Plugin::undefined() %> right]);
        is($parsed, 'left  right');
	}

package Test::_Plugin;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);

    sub zero : TplExport {
        
        my $self = shift;
        return 0;
    }

    sub null_string : TplExport {
        
        my $self = shift;
        return '';
    }

    sub undefined : TplExport {
        
        my $self = shift;
        return;
    }
