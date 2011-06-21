use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;
    
    __PACKAGE__->runtests;
    
    sub file_test : Test(7) {
        
        my $tpl = Text::PSTemplate::Plugable->new();
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS') %>"});
			is($res, q{res:"1"});
		}
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS','f') %>"});
			is($res, q{res:"1"});
		}
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS','d') %>"});
			is($res, q{res:""});
		}
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS','e') %>"});
			is($res, q{res:"1"});
		}
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS','M') %>"});
			like($res, qr{res:"\d+\.\d+"});
		}
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS','C') %>"});
			like($res, qr{res:"\d+\.\d+"});
		}
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS','A') %>"});
			like($res, qr{res:"\d+\.\d+"});
		}
    }
    
    sub findfile : Test(2) {
        
        my $tpl = Text::PSTemplate::Plugable->new();
		{
			my $res = $tpl->parse(q{res:"<% extract(&FS::find('t/03_PST_Plugable/template','FS'), 0) %>"});
			is($res, q{res:"t/03_PST_Plugable/template/FS"});
		}
		{
			my $res = $tpl->parse(q{res:"<% extract(&FS::find('t/03_PST_Plugable/template','FS2','not_found'), 0) %>"});
			is($res, q{res:"not_found"});
		}
	}
	