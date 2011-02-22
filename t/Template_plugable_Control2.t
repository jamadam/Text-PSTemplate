use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;
use File::Spec;

    __PACKAGE__->runtests;
    
    sub basic : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		my $parsed = $tpl->parse(q(test<% &include('t/template/Template_plugable_control_switch.txt') %>test));
		is($parsed, 'testoktest');
    }
    
    sub basedir : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		$tpl->set_filename_trans_coderef(sub{File::Spec->catfile('t/template', $_[0])});
		my $parsed = $tpl->parse(q(test<% &include('Template_plugable_control_switch.txt') %>test));
		is($parsed, 'testoktest');
    }
