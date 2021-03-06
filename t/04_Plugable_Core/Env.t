use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
    
	use Test::More tests => 8;
    
    my $tpl = Text::PSTemplate->new();
    $ENV{'test'} = 'value';
    my $parsed1 = $tpl->parse(q{<% env('test') %>});
    is($parsed1, 'value');
    my $parsed1_1 = $tpl->parse(q{<% env('test2') %>});
    is($parsed1_1, '');
    my $parsed2 = $tpl->parse(q{<% if_env('test','yes') %>});
    is($parsed2, 'yes');
    my $parsed2_2 = $tpl->parse(q{<% if_env('test2','yes','no') %>});
    is($parsed2_2, 'no');
    my $parsed3 = $tpl->parse(q{<% if_env_equals('test','value','yes') %>});
    is($parsed3, 'yes');
    my $parsed3_3 = $tpl->parse(q{<% if_env_equals('test','value1','yes','no') %>});
    is($parsed3_3, 'no');
    my $parsed4 = $tpl->parse(q{<% if_env_like('test','val','yes') %>});
    is($parsed4, 'yes');
    my $parsed4_4 = $tpl->parse(q{<% if_env_like('test','hoge','yes','no') %>});
    is($parsed4_4, 'no');
