package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;

    sub line_number_to_pos : Test(3) {
        my $pos1 = Text::PSTemplate::Exception::line_number_to_pos("line1\nline2\nline3\n", 2);
        is($pos1, 6);
        my $pos2 = Text::PSTemplate::Exception::line_number_to_pos("line1\nline2\nline3\n", 1);
        is($pos2, 0);
        my $pos3 = Text::PSTemplate::Exception::line_number_to_pos("line1\r\nline2\r\nline3\r\n", 2);
        is($pos3, 7);
    }
    
    sub error_include_line_number: Test(2) {
        
        my $tpl = Text::PSTemplate->new;
        eval {
            $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at3_1.txt');
        };
        like($@, qr{t/01_PST_Exception/template/error_message_include_at3_1.txt line 6});
        is((() = $@ =~ / at /g), 1);
    }
    
    sub tag_syntax_error_in_block : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
        eval {
            $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at3_3.txt');
        };
        like($@, qr{t/01_PST_Exception/template/error_message_include_at3_3.txt line 2});
        is((() = $@ =~ / at /g), 1);
    }
    
    sub amp_omitted : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
        eval {
            $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at3_4.txt');
        };
        like($@, qr{t/01_PST_Exception/template/error_message_include_at3_4.txt line 2});
        is((() = $@ =~ / at /g), 1);
    }
