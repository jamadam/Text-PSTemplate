package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;
use Data::Dumper;
    
    __PACKAGE__->runtests;

	sub line_number_to_pos : Test(3) {
		my $pos1 = Text::PSTemplate::_EvalStage::line_number_to_pos("line1\nline2\nline3\n", 2);
		is($pos1, 6);
		my $pos2 = Text::PSTemplate::_EvalStage::line_number_to_pos("line1\nline2\nline3\n", 1);
		is($pos2, 0);
		my $pos3 = Text::PSTemplate::_EvalStage::line_number_to_pos("line1\r\nline2\r\nline3\r\n", 2);
		is($pos3, 7);
	}

	sub error_include_line_number: Test(1) {
		
		my $tpl = Text::PSTemplate::Plugable->new;
		eval {
			$tpl->parse_file('t/template/01_PST_error_message_include_at3_1.txt');
		};
		like($@, qr{t/template/01_PST_error_message_include_at3_1.txt line 6});
	}
