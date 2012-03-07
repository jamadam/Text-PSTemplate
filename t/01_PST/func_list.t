package Template_Basic;
use strict;
use warnings;
use Test::More;
use lib 'lib';
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 1;
    
    my $tpl;
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::_Plugin');
    $tpl->plug('Test::_Plugin2');
    my $list = $tpl->get_func_list;
    my $expected = <<'EOF';
=============================================================
List of all available template functions
=============================================================

-- Text::PSTemplate::Plugin::Control namespace

<% if_in_array() %>
<% if() %>
<% if_equals() %>
<% if_like() %>
<% switch() %>
<% tpl_switch() %>
<% each() %>
<% bypass() %>
<% include() %>
<% extract() %>
<% set_var() %>
<% assign() %>
<% set_delimiter() %>
<% default() %>
<% with() %>
<% echo() %>


-- Test::_Plugin namespace

<% Test::_Plugin::some_func() %>


-- Text::PSTemplate::Plugin::Env namespace

<% env() %>
<% if_env() %>
<% if_env_equals() %>
<% if_env_like() %>


-- Test::_Plugin2 namespace

<% Test::_Plugin2::some_func() %>
<% Test::_Plugin2::some_func2() %>


-- Text::PSTemplate::Plugin::Extends namespace

<% extends() %>


-- Text::PSTemplate::Plugin::Util namespace

<% commify() %>
<% length() %>
<% substr() %>
<% counter() %>
<% split_line() %>
<% line_count() %>
<% replace() %>
<% space2linebreak() %>
<% delete_space() %>
<% split() %>
<% int() %>
<% randomize() %>
<% random_string() %>


-- Text::PSTemplate::Plugin::FS namespace

<% FS::test() %>
<% FS::find() %>
EOF
    
    is $list, $expected;

package Test::_Plugin;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);

    sub some_func : TplExport {
    }

package Test::_Plugin2;
use strict;
use warnings;
use base qw(Test::_Plugin);

    sub some_func2 : TplExport {
    }
