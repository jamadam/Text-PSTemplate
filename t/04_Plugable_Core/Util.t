use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
    
	use Test::More tests => 1;
    
    my $tpl = Text::PSTemplate->new;
    my $parsed = $tpl->parse(<<EOF);
<% counter(start => 10, skip => 5) %>
<% counter() %>
<% counter() %>
<% counter(start => 10, direction => 'down') %>
<% counter() %>
EOF
    is($parsed, <<EOF);
10
15
20
10
5
EOF
