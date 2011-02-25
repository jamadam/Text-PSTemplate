use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;

    __PACKAGE__->runtests;
    
    sub basic : Test {
        
        my $tpl = Text::PSTemplate->new;
		my $var = {a => 'b', c => 'd'};
		$tpl->set_var(var => $var);
		#my $parsed = $tpl->parse(q{<% ex$var,'a') %>});
        #is($parsed, 'b');
    }
