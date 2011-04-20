package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
	sub parse_file : Test(5) {
		
		my $tpl = Text::PSTemplate->new;
		eval {
			$tpl->parse_file('does_not_exist');
		};
		like($@, qr/file/i);
		like($@, qr/open/i);
		like($@, qr{does_not_exist});
		like($@, qr{line 15});
		is((() = $@ =~ / at /g), 1);
	}
    
	sub get_file : Test(5) {
		
		my $tpl = Text::PSTemplate->new;
		eval {
			$tpl->get_file('does_not_exist');
		};
		like($@, qr/file/i);
		like($@, qr/open/i);
		like($@, qr{does_not_exist});
		like($@, qr{line 28});
		is((() = $@ =~ / at /g), 1);
	}

__END__
