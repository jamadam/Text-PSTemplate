use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub get_template_pluged : Test {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->plug('Test::Plugin1');
        my $parsed = $tpl->parse(q[left <%&Test::Plugin1::some_function()%> right]);
        is($parsed, 'left Test::Plugin1::some_function called right');
    }
    
    sub get_template_pluged_twice : Test {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->plug('Test::Plugin1');
        my $parsed = $tpl->parse(q[left <%&Test::Plugin1::some_function()%> right]);
        is($parsed, 'left Test::Plugin1::some_function called right');
    }

