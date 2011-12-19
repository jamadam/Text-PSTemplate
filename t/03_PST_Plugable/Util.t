use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
    
    __PACKAGE__->runtests;
    
    sub counter : Test(2) {
        
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
    }
