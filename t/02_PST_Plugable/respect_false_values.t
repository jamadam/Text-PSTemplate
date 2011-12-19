use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 3;
    
    my $tpl;
    my $parsed;
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::_Plugin');
    $parsed = $tpl->parse(q[left <% Test::_Plugin::zero() %> right]);
    is($parsed, 'left 0 right');
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::_Plugin');
    $parsed = $tpl->parse(q[left <% Test::_Plugin::null_string() %> right]);
    is($parsed, 'left  right');
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::_Plugin');
    $parsed = $tpl->parse(q[left <% Test::_Plugin::undefined() %> right]);
    is($parsed, 'left  right');

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
