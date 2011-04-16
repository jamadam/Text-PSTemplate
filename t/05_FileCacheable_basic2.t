package main;
use strict;
use warnings;
use lib 't/lib05';
use Test::More;
use base 'Test::Class';
use File::Path;
use Text::PSTemplate::Plugable;

    my $cache_namespace_base = 't/cache/Test';
    
    __PACKAGE__->runtests;
    
    sub dynamicaly_asign_id : Test(3) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        my $a = $tpl->plug('TestModule6');
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        {
            is($a->get_lwp_count, 0);
            $a->get_url('http://example.com/');
            is($a->get_lwp_count, 1);
            $a->get_url('http://example.com/');
            is($a->get_lwp_count, 1);
        }
    }
    
    END {
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
    }
    