use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;
use Test::Plugin2;

    __PACKAGE__->runtests;
    
    sub ini : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Test::Plugin2');
        my $parsed1 = $tpl->parse(q[<% Test::Plugin2::some_function() %>]);
        is($parsed1, 'some_function');
    }
