use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub set_namespace : Test {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Test::Plugin1', 'Hoge');
        my $parsed = $tpl->parse(q[left <% Hoge::some_function() %> right]);
        is($parsed, 'left Test::Plugin1::some_function called right');
    }
    
    sub set_namespace_null : Test {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Test::Plugin1', '');
        my $parsed = $tpl->parse(q[left <% some_function() %> right]);
        is($parsed, 'left Test::Plugin1::some_function called right');
    }
