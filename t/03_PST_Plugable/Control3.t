use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
use File::Spec;

	use Test::More tests => 7;
    
    my $tpl;
    my $parsed;
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_var(a => 'hoge');
    $parsed = $tpl->parse(q(test <% include('t/03_PST_Plugable/template/Control3.txt') %> test));
    is($parsed, 'test ok hoge test');
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_filename_trans_coderef(sub{File::Spec->catfile('t/03_PST_Plugable/template', $_[0])});
    $tpl->set_var(a => 'hoge');
    $parsed = $tpl->parse(q(test <% include('Control3.txt') %> test));
    is($parsed, 'test ok hoge test');
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_filename_trans_coderef(sub{File::Spec->catfile('t/03_PST_Plugable/template', $_[0])});
    $tpl->set_var(a => 'hoge');
    $parsed = $tpl->parse(q(test <% include('Control3.txt', {a => 'foo'}) %> test));
    is($parsed, 'test ok foo test');
    
    $tpl = Text::PSTemplate->new;

    is($tpl->parse(<<'TEMPLATE'), <<'EXPECTED');
<% assign(var1 => 'a', var2 => 'b') %>
<% $var1 %><% $var2 %>
TEMPLATE
ab
EXPECTED
    
    $tpl = Text::PSTemplate->new;
    
    is($tpl->parse(<<'TEMPLATE'), <<'EXPECTED');
<% assign(var1 => 'a', var2 => 'b') %>
<% set_delimiter('%%', '%%') %>
%% $var1 %%%% $var2 %%
TEMPLATE
ab
EXPECTED
        
    $tpl = Text::PSTemplate->new;
    $parsed = $tpl->parse(q{<% bypass('aa') %>});
    is($parsed, q{});
    
    $tpl = Text::PSTemplate->new;

    is($tpl->parse(<<'TEMPLATE'), <<'EXPECTED');
<% if(1)<<EOF1 %>
    <% if(1)<<EOF2 %>1<% EOF2 %>
    <% if(1, '1')%>
    <% if(1)<<EOF2 %>1<% EOF2 %>
<% EOF1 %>
TEMPLATE
    1
    1
    1
EXPECTED
