use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub incrementally_basic : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->plug('Test::Plugin1');
        my $parsed = $tpl->parse(q[left <% Test::Plugin1::some_function() %> right]);
        is($parsed, 'left Test::Plugin1::some_function called right');
		
        $tpl->plug('Test::Plugin2');
        my $parsed2 = $tpl->parse(q[left <% Test::Plugin2::some_function() %> right]);
        is($parsed2, 'left Test::Plugin2::some_function called right');
    }
    
    sub incrementally_basic_twice : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->plug('Test::Plugin1');
        my $parsed = $tpl->parse(q[left <% Test::Plugin1::some_function() %> right]);
        is($parsed, 'left Test::Plugin1::some_function called right');
		
        $tpl->plug('Test::Plugin2');
        my $parsed2 = $tpl->parse(q[left <% Test::Plugin2::some_function() %> right]);
        is($parsed2, 'left Test::Plugin2::some_function called right');
    }
