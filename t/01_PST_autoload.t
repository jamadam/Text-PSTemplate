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
		$tpl->set_func(somefunc => sub {$_[0]});
		$tpl->set_func(somefunc2 => sub {'a'});
		my $a = eval {
			$tpl->parse('<% somefunc(somefunc2()) %>');
		};
		is($a, 'a');
	}

__END__
