package main;
use strict;
use warnings;
use lib 't/05_FileCacheable/lib';
use Test::More;
use base 'Test::Class';
use File::Path;
use Text::PSTemplate::Plugable;
    
    my $cache_namespace_base = 't/05_FileCacheable/cache/Test';
    
    __PACKAGE__->runtests;
    
    sub dynamicaly_asign_id : Test(4) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
		
		my $tpl = Text::PSTemplate::Plugable->new;
		my $plug = $tpl->plug('TestModule7');
		
		is($plug->get_method1_count, 0);
		$plug->method1;
		is($plug->get_method1_count, 1);
		$plug->method1;
		is($plug->get_method1_count, 1);
		sleep(3);
		$plug->method1;
		is($plug->get_method1_count, 2);
    }
	
    sub file_cache_expire_gets_timestamp : Test(3) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        
        my $tpl = Text::PSTemplate::Plugable->new;
        my $plug = $tpl->plug('TestModule4');
        
        is(TestModule4->get_debug_timestamp, undef);
        $plug->sub1('test');
        is(TestModule4->get_debug_timestamp, undef);
        $plug->sub1('test');
        isnt(TestModule4->get_debug_timestamp, undef);
    }
    
    sub specify_expire_ref : Test(2) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        
        my $tpl = Text::PSTemplate::Plugable->new;
        my $plug = $tpl->plug('TestModule4');
        
        is($plug->sub2('sub2-1'), 'sub2-1'); # must be cached
        is($plug->sub2('sub2-2'), 'sub2-2'); # must be cached
    }
    
    END {
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
    }

1;
