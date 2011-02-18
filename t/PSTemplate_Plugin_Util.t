use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;
use Text::PSTemplate::Plugin::Util;

    __PACKAGE__->runtests;
    
    sub if_equals : Test(5) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Text::PSTemplate::Plugin::Util', '');
		
		$tpl->set_var(
			some_var1 => '1',
			some_var2 => '2',
			some_var3 => '3',
			null_string => '',
			zero => 0,
		);
		
        my $parsed1 = $tpl->parse(q{{% &if_equals($some_var1,'1')<<THEN %}equal{%THEN%}});
        is($parsed1, 'equal');
        my $parsed2 = $tpl->parse(q{{% &if_equals($some_var1,'1')<<THEN,ELSE %}equal{%THEN%}not equal{%ELSE%}});
        is($parsed2, 'equal');
        my $parsed3 = $tpl->parse(q{{% &if_equals($some_var1,'2')<<THEN,ELSE %}equal{%THEN%}not equal{%ELSE%}});
        is($parsed3, 'not equal');
        my $parsed4 = $tpl->parse(q{{% &if_exists($some_var1, 'equal', 'not equal')%}});
        is($parsed4, 'equal');
        my $parsed5 = $tpl->parse(q{{% &if_exists($zero, 'equal', 'not equal')%}});
        is($parsed5, 'not equal');
    }
    
    sub if_exists : Test(6) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Text::PSTemplate::Plugin::Util', '');
		
		$tpl->set_var(
			some_var1 => '1',
			some_var2 => '2',
			some_var3 => '3',
			null_string => '',
			zero => 0,
		);
		
        my $parsed1 = $tpl->parse(q{{% &if_exists($some_var1)<<THEN %}exists{%THEN%}});
        is($parsed1, 'exists');
        my $parsed2 = $tpl->parse(q{{% &if_exists($null_string)<<THEN %}exists{%THEN%}});
        is($parsed2, '');
        my $parsed3 = $tpl->parse(q{{% &if_exists($zero)<<THEN %}exists{%THEN%}});
        is($parsed3, '');
        my $parsed4 = $tpl->parse(q{{% &if_exists($zero)<<THEN,ELSE %}exists{%THEN%}not exists{%ELSE%}});
        is($parsed4, 'not exists');
        my $parsed5 = $tpl->parse(q{{% &if_exists($some_var1, 'exists', 'not exists')%}});
        is($parsed5, 'exists');
        my $parsed6 = $tpl->parse(q{{% &if_exists($zero, 'exists', 'not exists')%}});
        is($parsed6, 'not exists');
    }
    
    sub if_in_array : Test(5) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Text::PSTemplate::Plugin::Util', '');
		
		$tpl->set_var(
			some_var1 => '1',
			some_var2 => '2',
			some_var3 => '3',
			null_string => '',
			zero => 0,
		);
		
        my $parsed1 = $tpl->parse(q{{% &if_in_array($some_var1,[1,2])<<THEN %}found{%THEN%}});
        is($parsed1, 'found');
        my $parsed2 = $tpl->parse(q{{% &if_in_array($some_var3,[1,2])<<THEN %}found{%THEN%}});
        is($parsed2, '');
        my $parsed3 = $tpl->parse(q{{% &if_in_array($some_var3,[1,2])<<THEN,ELSE %}found{%THEN%}not found{%ELSE%}});
        is($parsed3, 'not found');
        my $parsed4 = $tpl->parse(q{{% &if_in_array($some_var3,[1,2],'found') %}});
        is($parsed4, '');
        my $parsed5 = $tpl->parse(q{{% &if_in_array($some_var3,[1,2],'found','not found')%}});
        is($parsed5, 'not found');
    }
    
    sub switch : Test(8) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Text::PSTemplate::Plugin::Util', '');
		
		$tpl->set_var(
			some_var1 => '1',
			some_var2 => '2',
			some_var3 => '3',
			null_string => '',
			zero => 0,
		);
		
        my $parsed1 = $tpl->parse(q{{% &switch($some_var1,[1,2])<<CASE1,CASE2 %}case1{%CASE1%}case2{%CASE2%}});
        is($parsed1, 'case1');
        my $parsed2 = $tpl->parse(q{{% &switch($some_var2,[1,2])<<CASE1,CASE2 %}case1{%CASE1%}case2{%CASE2%}});
        is($parsed2, 'case2');
        my $parsed3 = $tpl->parse(q{{% &switch($some_var3,[1,2])<<CASE1,CASE2,DEFAULT %}case1{%CASE1%}case2{%CASE2%}default{%DEFAULT%}});
        is($parsed3, 'default');
        my $parsed4 = $tpl->parse(q{{% &switch($some_var3,[1,2])<<CASE1,CASE2%}case1{%CASE1%}case2{%CASE2%}});
        is($parsed4, '');
        my $parsed5 = $tpl->parse(q{{% &switch($some_var3,[1,2],'default')<<CASE1,CASE2%}case1{%CASE1%}case2{%CASE2%}});
        is($parsed5, 'default');
        my $parsed6 = $tpl->parse(q{{% &switch($some_var1,{1 => 'case1', 2 => 'case2'})%}});
        is($parsed6, 'case1');
        my $parsed7 = $tpl->parse(q{{% &switch($some_var2,{1 => 'case1', 2 => 'case2'})%}});
        is($parsed7, 'case2');
        my $parsed8 = $tpl->parse(q{{% &switch($some_var3,{1 => 'case1', 2 => 'case2'}, 'default')%}});
        is($parsed8, 'default');
    }
    
    sub tpl_switch : Test(3) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Text::PSTemplate::Plugin::Util', '');
		
		$tpl->set_var(
			some_var1 => '1',
			some_var2 => '2',
			some_var3 => '3',
			null_string => '',
			zero => 0,
		);
		my $parsed1 = $tpl->parse(q{{% &tpl_switch($some_var1,{1 => 't/template/Template_Plugin_Util.txt', 2 => ''})%}});
        is($parsed1, 'ok');
		my $parsed2 = $tpl->parse(q{{% &tpl_switch($some_var2,{1 => '', 2 => 't/template/Template_Plugin_Util.txt'})%}});
        is($parsed2, 'ok');
		my $parsed3 = $tpl->parse(q{{% &tpl_switch($some_var3,{1 => '', 2 => ''})%}});
        is($parsed3, '');
    }
