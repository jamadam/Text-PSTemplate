package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;

	sub error_include_line_number: Test(2) {
		
		my $tpl = Text::PSTemplate->new;
		eval {
			$tpl->parse_file('t/01_PST_Exception/template/error_message_include_at1_1.txt');
		};
		like($@, qr{t/01_PST_Exception/template/error_message_include_at1_1.txt line 5});
		is((() = $@ =~ / at /g), 1);
	}
    
	sub error_include_line_number2: Test(2) {
		
		my $tpl = Text::PSTemplate->new;
		eval {
			$tpl->parse_file('t/01_PST_Exception/template/error_message_include_at1_2.txt');
		};
		like($@, qr{t/01_PST_Exception/template/error_message_include_at1_2.txt line 5});
		is((() = $@ =~ / at /g), 1);
	}

	sub error_include_line_number3: Test(2) {
		
		my $tpl = Text::PSTemplate->new;
		$tpl->set_func('if' => sub{
			$tpl->parse_block(0);
		});
		eval {
			$tpl->parse_file('t/01_PST_Exception/template/error_message_include_at1_3.txt');
		};
		like($@, qr{t/01_PST_Exception/template/error_message_include_at1_3.txt line 7});
		is((() = $@ =~ / at /g), 1);
	}

__END__
