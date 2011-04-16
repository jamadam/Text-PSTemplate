package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
	sub undefined_func : Test(3) {
		
		my $tpl = Text::PSTemplate->new;
		eval {
			$tpl->parse('<% undefined_func() %>');
		};
		like($@, qr/function/i);
		like($@, qr/undefined/i);
		like($@, qr{error_message.t});
	}
    
	sub runtime_error : Test(2) {
		
		my $tpl = Text::PSTemplate->new;
        $tpl->set_func(a => sub{''});
		eval {
			$tpl->parse('<% a(1/0) %>');
		};
		like($@, qr/Illegal/i);
		like($@, qr{error_message\.t});
	}
    
	sub undef_func_in_file : Test(3) {
		
		my $tpl = Text::PSTemplate->new;
        $tpl->set_func(a => sub{''});
		eval {
			$tpl->parse_file('t/01_PST/template/error_message.txt');
		};
		like($@, qr/function/i);
		like($@, qr/undefined/i);
        like($@, qr/template\/error_message\.txt/);
	}
    
	sub undef_func_in_file2 : Test(3) {
		
		my $tpl = Text::PSTemplate->new;
        $tpl->set_func(a => sub{''});
		eval {
			$tpl->parse_file('t/01_PST/template/error_message2.txt');
		};
		like($@, qr/variable/i);
		like($@, qr/undefined/i);
        like($@, qr/template\/error_message2\.txt/);
	}
    
    sub nonexist_file : Test(2) {
        
		my $tpl = Text::PSTemplate->new;
		eval {
            $tpl->get_file('dummy.txt');
		};
        like($@, qr/open/);
        like($@, qr/dummy\.txt/);
    }

__END__
