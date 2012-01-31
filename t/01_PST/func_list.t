package Template_Basic;
use strict;
use warnings;
use Test::More;
use lib 'lib';
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 2;
    
    my $tpl;
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::_Plugin');
    my $list = $tpl->get_func_list;
    like $list, qr{<% if\(\) %>}, 'core func included in list';
    like $list, qr{<% Test::_Plugin::some_func\(\) %>}, 'additional func included in list';

package Test::_Plugin;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);

    sub some_func : TplExport {
    }
