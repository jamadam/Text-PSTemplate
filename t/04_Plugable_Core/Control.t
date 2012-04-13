use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 52;
    
    my $tpl;
    my $parsed;
    
    $tpl = Text::PSTemplate->new;
    
    $tpl->set_var(
        some_var1 => '1',
        some_var2 => '2',
        some_var3 => '3',
        null_string => '',
        zero => 0,
    );
    
    $parsed = $tpl->parse(q{<% if_equals($some_var1,'1')<<THEN %>equal<% THEN %>});
    is $parsed, 'equal';
    $parsed = $tpl->parse(q{<% if_equals($some_var1,'1')<<THEN,ELSE %>equal<% THEN %>not equal<% ELSE %>});
    is $parsed, 'equal';
    $parsed = $tpl->parse(q{<% if_equals($some_var1,'2')<<THEN,ELSE %>equal<% THEN %>not equal<% ELSE %>});
    is $parsed, 'not equal';
    $parsed = $tpl->parse(q{<% if_equals($some_var1, '1', 'equal', 'not equal') %>});
    is $parsed, 'equal';
    $parsed = $tpl->parse(q{<% if_equals($zero, '1', 'equal', 'not equal') %>});
    is $parsed, 'not equal';
    
    $tpl = Text::PSTemplate->new;
    
    $tpl->set_var(
        some_var1 => '1',
        some_var2 => '2',
        some_var3 => '3',
        null_string => '',
        zero => 0,
    );
    
    $parsed = $tpl->parse(q{<% if($some_var1)<<THEN %>exists<% THEN %>});
    is $parsed, 'exists';
    $parsed = $tpl->parse(q{<% if($null_string)<<THEN %>exists<% THEN %>});
    is $parsed, '';
    $parsed = $tpl->parse(q{<% if($zero)<<THEN %>exists<% THEN %>});
    is $parsed, '';
    $parsed = $tpl->parse(q{<% if($zero)<<THEN,ELSE %>exists<% THEN %>not exists<% ELSE %>});
    is $parsed, 'not exists';
    $parsed = $tpl->parse(q{<% if($some_var1, 'exists', 'not exists') %>});
    is $parsed, 'exists';
    $parsed = $tpl->parse(q{<% if($zero, 'exists', 'not exists') %>});
    is $parsed, 'not exists';
    
    $tpl = Text::PSTemplate->new;
    
    $tpl->set_var(
        respect => 'org',
        some_var1=> 1,
    );
    
    $parsed = $tpl->parse(q{<% if($some_var1)<<THEN %><% assign(respect => 'sub') %><% THEN %>});
    is $parsed, '';
    is $tpl->var('respect'), 'sub';
    
    $tpl = Text::PSTemplate->new;
    
    $tpl->set_var(
        some_var1 => '1',
        some_var2 => '2',
        some_var3 => '3',
        null_string => '',
        zero => 0,
    );
    
    $parsed = $tpl->parse(q{<% if_in_array($some_var1,[1,2])<<THEN %>found<% THEN %>});
    is $parsed, 'found';
    $parsed = $tpl->parse(q{<% if_in_array($some_var3,[1,2])<<THEN %>found<% THEN %>});
    is $parsed, '';
    $parsed = $tpl->parse(q{<% if_in_array($some_var3,[1,2])<<THEN,ELSE %>found<% THEN %>not found<% ELSE %>});
    is $parsed, 'not found';
    $parsed = $tpl->parse(q{<% if_in_array($some_var3,[1,2],'found') %>});
    is $parsed, '';
    $parsed = $tpl->parse(q{<% if_in_array($some_var3,[1,2],'found','not found') %>});
    is $parsed, 'not found';
    
    $tpl = Text::PSTemplate->new;
    
    $tpl->set_var(
        some_var1 => '1',
        some_var2 => '2',
        some_var3 => '3',
        null_string => '',
        zero => 0,
    );
    
    $parsed = $tpl->parse(q{<% switch($some_var1,[1,2])<<CASE1,CASE2 %>case1<% CASE1 %>case2<% CASE2 %>});
    is $parsed, 'case1';
    $parsed = $tpl->parse(q{<% switch($some_var2,[1,2])<<CASE1,CASE2 %>case1<% CASE1 %>case2<% CASE2 %>});
    is $parsed, 'case2';
    $parsed = $tpl->parse(q{<% switch($some_var3,[1,2])<<CASE1,CASE2,DEFAULT %>case1<% CASE1 %>case2<% CASE2 %>default<% DEFAULT %>});
    is $parsed, 'default';
    $parsed = $tpl->parse(q{<% switch($some_var3,[1,2])<<CASE1,CASE2 %>case1<% CASE1 %>case2<% CASE2 %>});
    is $parsed, '';
    $parsed = $tpl->parse(q{<% switch($some_var3,[1,2],'default')<<CASE1,CASE2 %>case1<% CASE1 %>case2<% CASE2 %>});
    is $parsed, 'default';
    $parsed = $tpl->parse(q{<% switch($some_var1,{1 => 'case1', 2 => 'case2'}) %>});
    is $parsed, 'case1';
    $parsed = $tpl->parse(q{<% switch($some_var2,{1 => 'case1', 2 => 'case2'}) %>});
    is $parsed, 'case2';
    $parsed = $tpl->parse(q{<% switch($some_var3,{1 => 'case1', 2 => 'case2'}, 'default') %>});
    is $parsed, 'default';
    
    $tpl = Text::PSTemplate->new;
    
    $tpl->set_var(
        some_var1 => '1',
        some_var2 => '2',
        some_var3 => '3',
        null_string => '',
        zero => 0,
    );
    
    $parsed = $tpl->parse(q{<% tpl_switch($some_var1,{1 => 't/04_Plugable_Core/template/Control2.txt', 2 => ''}) %>});
    is $parsed, 'ok';
    $parsed = $tpl->parse(q{<% tpl_switch($some_var2,{1 => '', 2 => 't/04_Plugable_Core/template/Control2.txt'}) %>});
    is $parsed, 'ok';
    $parsed = $tpl->parse(q{<% tpl_switch($some_var3,{1 => '', 2 => ''}) %>});
    is $parsed, '';
    
    $tpl = Text::PSTemplate->new;
    
    $tpl->set_var(
        some_var1 => '1',
        some_var2 => '2',
        some_var3 => '3',
        null_string => '',
        zero => 0,
    );
    
    $parsed = $tpl->parse(q{<% substr('abcde', 0, 2) %>});
    is $parsed, 'ab';
    $parsed = $tpl->parse(q{<% substr('abcde', 0, 2, '..') %>});
    is $parsed, 'ab..';
    
    $tpl = Text::PSTemplate->new;
    
    $tpl->set_var(
        array => [1,2,3,4],
        hash => {a => 1, b => 2},
        scalar => 1,
        zero => 0,
    );
    
    $parsed = $tpl->parse(q{<% each($array, 'name')<<EOF%><% $name %><% EOF %>});
    is $parsed, '1234';
    $parsed = $tpl->parse(q{<% each($array, 'key' => 'value')<<EOF %><% $key %><% $value %><% EOF %>});
    is $parsed, '01122334';
    $parsed = $tpl->parse(q{<% each($hash, 'name')<<EOF%><% $name %><% EOF %>});
    is $parsed, '12';
    $parsed = $tpl->parse(q{<% each($hash, 'key' => 'value')<<EOF %><% $key %><% $value %><% EOF %>});
    is $parsed, 'a1b2';
    $parsed = $tpl->parse(q{<% each($scalar, 'key' => 'value')<<EOF %><% $key %><% $value %><% EOF %>});
    is $parsed, '01';
    
    $tpl = Text::PSTemplate->new;
    
    $tpl->set_var(
        array => [1,2,3,4],
        respect => 'org',
    );
    
    $parsed = $tpl->parse(q{<% each($array, 'respect')<<EOF%><% $respect %><% EOF %>});
    is $parsed, '1234';
    is $tpl->var('respect'), 'org';
    
    $tpl = Text::PSTemplate->new;
    
    $tpl->set_var(
        array => [1,2,3,4],
        respect => 'org',
    );
    
    $parsed = $tpl->parse(q{<% each($array, 'respect')<<EOF%><% $respect %><% assign(respect => 'sub') %><% EOF %>});
    is $parsed, '1234';
    is $tpl->var('respect'), 'sub';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_var(a => 'hoge');
    $parsed = $tpl->parse(q(test <% include('t/04_Plugable_Core/template/Control3.txt') %> test));
    is $parsed, 'test ok hoge test';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_filename_trans_coderef(sub{File::Spec->catfile('t/04_Plugable_Core/template', $_[0])});
    $tpl->set_var(a => 'hoge');
    $parsed = $tpl->parse(q(test <% include('Control3.txt') %> test));
    is $parsed, 'test ok hoge test';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_filename_trans_coderef(sub{File::Spec->catfile('t/04_Plugable_Core/template', $_[0])});
    $tpl->set_var(a => 'hoge');
    $parsed = $tpl->parse(q(test <% include('Control3.txt', {a => 'foo'}) %> test));
    is $parsed, 'test ok foo test';
    
    $tpl = Text::PSTemplate->new;

    is $tpl->parse(<<'TEMPLATE'), <<'EXPECTED';
<% assign(var1 => 'a', var2 => 'b') %>
<% $var1 %><% $var2 %>
TEMPLATE
ab
EXPECTED
    
    $tpl = Text::PSTemplate->new;
    
    is $tpl->parse(<<'TEMPLATE'), <<'EXPECTED';
<% assign(var1 => 'a', var2 => 'b') %>
<% set_delimiter('%%', '%%') %>
%% $var1 %%%% $var2 %%
TEMPLATE
ab
EXPECTED
        
    $tpl = Text::PSTemplate->new;
    $parsed = $tpl->parse(q{<% bypass('aa') %>});
    is $parsed, q{};
    
    $tpl = Text::PSTemplate->new;

    is $tpl->parse(<<'TEMPLATE'), <<'EXPECTED';
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
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_var(var => {a => 'b', c => 'd'});
    $parsed = $tpl->parse(q{<% extract($var,'a') %>});
    is $parsed, 'b';
    my $parsed2 = eval {
        $tpl->parse(q{<% extract($var,'e') %>});
    };
    isnt $@, undef;
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_var_exception(sub{''});
    $tpl->set_var(var => 'a');
    $parsed = $tpl->parse(q{<% default($var,'default') %>});
    is $parsed, 'a';
    $parsed2 = $tpl->parse(q{<% default($var2,'default') %>});
    is $parsed2, 'default';
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_var(arr => {foo => 'bar'});
    $parsed = $tpl->parse(<<'EOF');
<% $arr->{foo} %>
<% with($arr)<<BLOCK %><% $foo %> / <% $arr->{foo} %><% BLOCK %>
EOF

    is $parsed, <<EOF;
bar
bar / bar
EOF
