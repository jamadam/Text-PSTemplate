use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
    
	use Test::More tests => 9;
    
    my $tpl;
    my $res;
    
    $tpl = Text::PSTemplate->new();
    $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS') %>"});
    is($res, q{res:"1"});
    $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS','f') %>"});
    is($res, q{res:"1"});
    $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS','d') %>"});
    is($res, q{res:""});
    $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS','e') %>"});
    is($res, q{res:"1"});
    $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS','M') %>"});
    like($res, qr{res:"\d+\.\d+"});
    $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS','C') %>"});
    like($res, qr{res:"\d+\.\d+"});
    $res = $tpl->parse(q{res:"<% FS::test('t/03_PST_Plugable/template/FS','A') %>"});
    like($res, qr{res:"\d+\.\d+"});
    
    use File::Spec;
    
    $tpl = Text::PSTemplate->new();
    
    $res = $tpl->parse(q{res:"<% extract(&FS::find('t/03_PST_Plugable/template','FS'), 0) %>"});
    my $expected_path = File::Spec->catfile(qw(t 03_PST_Plugable template FS));
    is($res, qq{res:"$expected_path"});
    $res = $tpl->parse(q{res:"<% extract(&FS::find('t/03_PST_Plugable/template','FS2','not_found'), 0) %>"});
    is($res, q{res:"not_found"});
