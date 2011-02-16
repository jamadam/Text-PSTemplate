use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;
use Test::Plugin1;

    __PACKAGE__->runtests;
    
    sub get_template_pluged : Test {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug(['Test::Plugin1']);
        my $parsed = $tpl->parse(q[left {%&Test::Plugin1::some_function()%} right]);
        is($parsed, 'left Test::Plugin1::some_function called right');
    }
    
    sub get_template_pluged_twice : Test {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug(['Test::Plugin1']);
        my $parsed = $tpl->parse(q[left {%&Test::Plugin1::some_function()%} right]);
        is($parsed, 'left Test::Plugin1::some_function called right');
    }

