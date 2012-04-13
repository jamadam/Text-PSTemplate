use strict;
use warnings;
use Test::More;
use Text::PSTemplate;

	use Test::More tests => 5;
    
    my $tpl;
    my $parsed;
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_var(var => {a => 'b', c => 'd'});
    $parsed = $tpl->parse(q{<% extract($var,'a') %>});
    is($parsed, 'b');
    my $parsed2 = eval {
        $tpl->parse(q{<% extract($var,'e') %>});
    };
    isnt($@, undef);
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_var_exception(sub{''});
    $tpl->set_var(var => 'a');
    $parsed = $tpl->parse(q{<% default($var,'default') %>});
    is($parsed, 'a');
    $parsed2 = $tpl->parse(q{<% default($var2,'default') %>});
    is($parsed2, 'default');
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_var(arr => {foo => 'bar'});
    $parsed = $tpl->parse(<<'EOF');
<% $arr->{foo} %>
<% with($arr)<<BLOCK %><% $foo %> / <% $arr->{foo} %><% BLOCK %>
EOF

    is($parsed, <<EOF);
bar
bar / bar
EOF
