use strict;
use warnings;
use lib 'lib';
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
	
	sub default : Test(2) {
		
        my $tpl = Text::PSTemplate::Plugable->new;
		$tpl->set_var_exception(sub{''});
		$tpl->set_var(var => 'a');
		my $parsed = $tpl->parse(q{<% default($var,'default') %>});
        is($parsed, 'a');
		my $parsed2 = $tpl->parse(q{<% default($var2,'default') %>});
        is($parsed2, 'default');
	}
	
	sub with : Test(1) {
		
        my $tpl = Text::PSTemplate::Plugable->new();
		$tpl->set_var(arr => {foo => 'bar'});
        my $parsed = $tpl->parse(<<'EOF');
<% $arr->{foo} %>
<% with($arr)<<BLOCK %><% $foo %> / <% $arr->{foo} %><% BLOCK %>
EOF

        is($parsed, <<EOF);
bar
bar / bar
EOF
	}
