package Template_Basic;
use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 6;
    
    my $tpl;
    
    $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/02_Exception/template/error_message_include_at3_1.txt');
    };
    like($@, qr{t/02_Exception/template/error_message_include_at3_1.txt line 6});
    is((() = $@ =~ / at /g), 1);
    
    $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/02_Exception/template/error_message_include_at3_3.txt');
    };
    like($@, qr{t/02_Exception/template/error_message_include_at3_3.txt line 2});
    is((() = $@ =~ / at /g), 1);
    
    $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/02_Exception/template/error_message_include_at3_4.txt');
    };
    like($@, qr{t/02_Exception/template/error_message_include_at3_4.txt line 2});
    is((() = $@ =~ / at /g), 1);
