package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
	sub error_include_line_number: Test(1) {
		
		my $tpl = Text::PSTemplate->new;
		eval {
			$tpl->parse_file('t/template/01_PST_error_message_include_at.txt');
		};
		like($@, qr{t/template/01_PST_error_message_include_at.txt line 5});
	}
    
	sub error_include_line_number2: Test(1) {
		
		my $tpl = Text::PSTemplate->new;
		eval {
			$tpl->parse_file('t/template/01_PST_error_message_include_at2.txt');
		};
		like($@, qr{t/template/01_PST_error_message_include_at2.txt line 5});
	}
    
	sub error_include_line_number3: Test(1) {
		
		my $tpl = Text::PSTemplate->new;
		$tpl->set_func('if' => sub{
			$tpl->parse(Text::PSTemplate::get_block(0));
		});
		eval {
			$tpl->parse_file('t/template/01_PST_error_message_include_at3.txt');
		};
		like($@, qr{t/template/01_PST_error_message_include_at3.txt line 7});
	}

__END__
