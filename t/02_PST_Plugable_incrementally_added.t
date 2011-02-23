use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;
use Test::Plugin1;

    __PACKAGE__->runtests;
    
    sub incrementally_basic : Test(2) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug(['Test::Plugin1']);
        my $parsed = $tpl->parse(q[left <% Test::Plugin1::some_function() %> right]);
        is($parsed, 'left Test::Plugin1::some_function called right');
		
        $tpl->plug(['Test::Plugin2']);
        my $parsed2 = $tpl->parse(q[left <% Test::Plugin2::some_function() %> right]);
        is($parsed2, 'left Test::Plugin2::some_function called right');
    }
    
    sub incrementally_basic_twice : Test(2) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug(['Test::Plugin1']);
        my $parsed = $tpl->parse(q[left <% Test::Plugin1::some_function() %> right]);
        is($parsed, 'left Test::Plugin1::some_function called right');
		
        $tpl->plug(['Test::Plugin2']);
        my $parsed2 = $tpl->parse(q[left <% Test::Plugin2::some_function() %> right]);
        is($parsed2, 'left Test::Plugin2::some_function called right');
    }
