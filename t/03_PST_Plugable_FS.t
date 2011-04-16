use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;
    
    __PACKAGE__->runtests;
    
    sub file_test : Test(7) {
        
        my $tpl = Text::PSTemplate::Plugable->new();
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/file/03_PST_Plugable_FS') %>"});
			is($res, q{res:"1"});
		}
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/file/03_PST_Plugable_FS','f') %>"});
			is($res, q{res:"1"});
		}
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/file/03_PST_Plugable_FS','d') %>"});
			is($res, q{res:""});
		}
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/file/03_PST_Plugable_FS','e') %>"});
			is($res, q{res:"1"});
		}
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/file/03_PST_Plugable_FS','M') %>"});
			like($res, qr{res:"\d+\.\d+"});
		}
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/file/03_PST_Plugable_FS','C') %>"});
			like($res, qr{res:"\d+\.\d+"});
		}
		{
			my $res = $tpl->parse(q{res:"<% FS::test('t/file/03_PST_Plugable_FS','A') %>"});
			like($res, qr{res:"\d+\.\d+"});
		}
    }
    
    sub findfile : Test(2) {
        
        my $tpl = Text::PSTemplate::Plugable->new();
		{
			my $res = $tpl->parse(q{res:"<% extract(&FS::find('t/file','03_PST_Plugable_FS'), 0) %>"});
			is($res, q{res:"t/file/03_PST_Plugable_FS"});
		}
		{
			my $res = $tpl->parse(q{res:"<% extract(&FS::find('t/file','03_PST_Plugable_FS2','not_found'), 0) %>"});
			is($res, q{res:"not_found"});
		}
	}
	