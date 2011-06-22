use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub tpl_switch : Test(3) {
        
        my $tpl = Text::PSTemplate->new;
        
        $tpl->set_var(
            some_var1 => '1',
            some_var2 => '2',
            some_var3 => '3',
            null_string => '',
            zero => 0,
        );
        my $parsed1 = $tpl->parse(q{<% tpl_switch($some_var1,{1 => 't/03_PST_Plugable/template/Control2.txt', 2 => ''}) %>});
        is($parsed1, 'ok');
        my $parsed2 = $tpl->parse(q{<% tpl_switch($some_var2,{1 => '', 2 => 't/03_PST_Plugable/template/Control2.txt'}) %>});
        is($parsed2, 'ok');
        my $parsed3 = $tpl->parse(q{<% tpl_switch($some_var3,{1 => '', 2 => ''}) %>});
        is($parsed3, '');
    }
    
    sub substr : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
        
        $tpl->set_var(
            some_var1 => '1',
            some_var2 => '2',
            some_var3 => '3',
            null_string => '',
            zero => 0,
        );
        my $parsed1 = $tpl->parse(q{<% substr('abcde', 0, 2) %>});
        is($parsed1, 'ab');
        my $parsed2 = $tpl->parse(q{<% substr('abcde', 0, 2, '..') %>});
        is($parsed2, 'ab..');
    }
    
    sub each : Test(5) {
        
        my $tpl = Text::PSTemplate->new;
        
        $tpl->set_var(
            array => [1,2,3,4],
            hash => {a => 1, b => 2},
            scalar => 1,
            zero => 0,
        );
        my $parsed1 = $tpl->parse(q{<% each($array, 'name')<<EOF%><% $name %><% EOF %>});
        is($parsed1, '1234');
        my $parsed2 = $tpl->parse(q{<% each($array, 'key' => 'value')<<EOF %><% $key %><% $value %><% EOF %>});
        is($parsed2, '01122334');
        my $parsed3 = $tpl->parse(q{<% each($hash, 'name')<<EOF%><% $name %><% EOF %>});
        is($parsed3, '12');
        my $parsed4 = $tpl->parse(q{<% each($hash, 'key' => 'value')<<EOF %><% $key %><% $value %><% EOF %>});
        is($parsed4, 'a1b2');
        my $parsed5 = $tpl->parse(q{<% each($scalar, 'key' => 'value')<<EOF %><% $key %><% $value %><% EOF %>});
        is($parsed5, '01');
    }
    
    sub each_not_affect_mother : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
        
        $tpl->set_var(
            array => [1,2,3,4],
            respect => 'org',
        );
        my $parsed1 = $tpl->parse(q{<% each($array, 'respect')<<EOF%><% $respect %><% EOF %>});
        is($parsed1, '1234');
        is($tpl->var('respect'), 'org');
    }
    
    sub each_affects_mother : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
        
        $tpl->set_var(
            array => [1,2,3,4],
            respect => 'org',
        );
        my $parsed1 = $tpl->parse(q{<% each($array, 'respect')<<EOF%><% $respect %><% set_var(respect => 'sub') %><% EOF %>});
        is($parsed1, '1234');
        is($tpl->var('respect'), 'sub');
    }
