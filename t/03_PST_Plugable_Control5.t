use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;

    __PACKAGE__->runtests;
    
    sub extract : Test(2) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		my $var = {a => 'b', c => 'd'};
		$tpl->set_var(var => $var);
		my $parsed = $tpl->parse(q{<% extract($var,'a') %>});
        is($parsed, 'b');
		my $parsed2 = eval {
			$tpl->parse(q{<% extract($var,'e') %>});
		};
        isnt($@, undef);
    }
