package Template_Basic;
use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 2;
    
    my $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/02_Exception/template/error_message_include_at7_1.txt');
    };
    like($@, qr{t/02_Exception/template/error_message_include_at7_2.txt line 2});
    is((() = $@ =~ / at /g), 1);

