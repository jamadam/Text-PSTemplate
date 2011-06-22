package main;
use strict;
use warnings;
use lib 'lib';
use lib 't/05_FileCacheable/lib';
use Test::More;
use base 'Test::Class';
use File::Path;
use Text::PSTemplate;
    
    my $cache_namespace_base = 't/05_FileCacheable/cache/Test';
    
    __PACKAGE__->runtests;
    
    sub oop_basic : Test(10) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        
        my $tpl = Text::PSTemplate->new;
        my $plug = $tpl->plug('TestModule3');
        
        is(TestModule3->get_class, 'TestModule3'); # must be cached
        is(TestModule3->get_class, 'TestModule3');
        
        is(TestModule3->sub1('test'), 'test'); # must be cached
        is(TestModule3->sub1('test2'), 'test');
        
        like($plug->get_instance, qr{^TestModule3}); # must be cached
        like($plug->get_instance, qr{^TestModule3});
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        
        is($plug->sub1('test'), 'test'); # must be cached
        is($plug->sub1('test2'), 'test');
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        
        is(TestModule3->sub1('test'), 'test'); # must be cached
        is($plug->sub1('test2'), 'test');
    }
    
    sub specify_expire_ref : Test(2) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        
        my $tpl = Text::PSTemplate->new;
        my $plug = $tpl->plug('TestModule4');
        
        is($plug->sub2('sub2-1'), 'sub2-1'); # must be cached
        is($plug->sub2('sub2-2'), 'sub2-2'); # must be cached
    }
    
    sub oop_subclass_basic : Test(6) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        eval {
            require 'TestModule5.pm';
        };
        my $tpl = Text::PSTemplate->new;
        my $plug = $tpl->plug('TestModule5sub');
        
        is(TestModule5sub->file_cache_expire_called, undef);
        is(TestModule5sub->get_file_cache_options_called, undef);
        is(TestModule5sub->sub1('TestModule5sub'), 'TestModule5sub'); # must be cached
        is(TestModule5sub->get_file_cache_options_called, 1);
        is(TestModule5sub->sub1('TestModule5sub-2'), 'TestModule5sub');
        is(TestModule5sub->file_cache_expire_called, 1);
    }
    
    END {
        if (-d $cache_namespace_base) {
            #rmtree($cache_namespace_base);
        }
    }
