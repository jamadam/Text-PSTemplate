use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;

    __PACKAGE__->runtests;
    
    sub dereference_hash : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
		my $var = {a => 'b', c => 'd'};
		$tpl->set_var(var => $var);
		my $parsed2 = $tpl->parse(q{<% $var->{a} %>});
        is($parsed2, 'b');
		my $parsed3 = eval {
			$tpl->parse(q{<% $var->{e} %>})
		};
        isnt($@, undef);
    }
    
    sub dereference_array : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
		my $var = [0,1,2,3];
		$tpl->set_var(var => $var);
		my $parsed2 = $tpl->parse(q{<% $var->[3] %>});
        is($parsed2, '3');
		my $parsed3 = eval {
			$tpl->parse(q{<% $var->{4} %>})
		};
        isnt($@, undef);
    }
