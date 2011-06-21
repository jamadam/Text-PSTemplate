package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
	sub eval_scope : Test(2) {
		
		my $tpl = Text::PSTemplate->new;
		$tpl->set_func(somefunc => sub {'a'});
		eval {
			$tpl->parse('<% somefunc(parse()) %>');
		};
		like($@, qr/function/i);
		like($@, qr/Undefined/i);
	}

__END__
