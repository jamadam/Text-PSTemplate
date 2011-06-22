use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub set_namespace : Test {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->plug('Test::Plugin1', 'Hoge');
        my $parsed = $tpl->parse(q[left <% Hoge::some_function() %> right]);
        is($parsed, 'left Test::Plugin1::some_function called right');
    }
    
    sub set_namespace_null : Test {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->plug('Test::Plugin1', '');
        my $parsed = $tpl->parse(q[left <% some_function() %> right]);
        is($parsed, 'left Test::Plugin1::some_function called right');
    }
