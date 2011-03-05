package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
	sub eval_scope : Test(1) {
		
		my $tpl = Text::PSTemplate->new;
		$tpl->set_func(somefunc => sub {'a'});
		eval {
			$tpl->parse('<% somefunc(parse()) %>');
		};
		like($@, qr/Undefined subroutine/);
	}

__END__
