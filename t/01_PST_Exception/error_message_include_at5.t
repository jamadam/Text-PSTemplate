package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 6;
    
    my $tpl;
    
    $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at5_1_1.txt');
    };
    like($@, qr{t/01_PST_Exception/template/error_message_include_at5_1_2.txt line 2});
    is((() = $@ =~ / at /g), 1);
    
    $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at5_2_1.txt');
    };
    like($@, qr{t/01_PST_Exception/template/error_message_include_at5_2_2.txt line 28});
    is((() = $@ =~ / at /g), 1);
    
    $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at5_3_1.txt');
    };
    like($@, qr{t/01_PST_Exception/template/error_message_include_at5_3_2.txt line 10});
    is((() = $@ =~ / at /g), 1);
