package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
	sub runtime_error : Test(2) {
		
		my $tpl = Text::PSTemplate->new;
        $tpl->set_func(a => sub{''});
		eval {
			$tpl->parse('<% a(1/0) %>');
		};
		like($@, qr/Illegal/i);
		like($@, qr{error_message\.t});
	}
1;
