use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    my $tpl = Text::PSTemplate->new;
    
    $tpl->set_var(
        some_var1 => '1',
        some_var2 => '2',
        some_var3 => '3',
        null_string => '',
        zero => 0,
    );

    use Benchmark qw( timethese cmpthese countit);
    warn countit(5, sub{
        my $parsed1 = $tpl->parse(q{<% if($some_var1)<<THEN %>exists<% THEN %>});
        my $parsed2 = $tpl->parse(q{<% if($null_string)<<THEN %>exists<% THEN %>});
        my $parsed3 = $tpl->parse(q{<% if($zero)<<THEN %>exists<% THEN %>});
        my $parsed4 = $tpl->parse(q{<% if($zero)<<THEN,ELSE %>exists<% THEN %>not exists<% ELSE %>});
        my $parsed5 = $tpl->parse(q{<% if($some_var1, 'exists', 'not exists') %>});
        my $parsed6 = $tpl->parse(q{<% if($zero, 'exists', 'not exists') %>});
    })->iters;
