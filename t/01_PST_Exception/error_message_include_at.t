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
        $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at1_1.txt');
    };
    like($@, qr{t/01_PST_Exception/template/error_message_include_at1_1.txt line 5});
    is((() = $@ =~ / at /g), 1);
    
    $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at1_2.txt');
    };
    like($@, qr{t/01_PST_Exception/template/error_message_include_at1_2.txt line 5});
    is((() = $@ =~ / at /g), 1);
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func('if' => sub{$tpl->parse_block(0)});
    eval {
        $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at1_3.txt');
    };
    like($@, qr{t/01_PST_Exception/template/error_message_include_at1_3.txt line 7});
    is((() = $@ =~ / at /g), 1);

__END__
