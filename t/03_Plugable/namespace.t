use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 2;
    
    my $tpl;
    my $parsed;
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::Plugin1', 'Hoge');
    $parsed = $tpl->parse(q[left <% Hoge::some_function() %> right]);
    is($parsed, 'left Test::Plugin1::some_function called right');
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::Plugin1', '');
    $parsed = $tpl->parse(q[left <% some_function() %> right]);
    is($parsed, 'left Test::Plugin1::some_function called right');
