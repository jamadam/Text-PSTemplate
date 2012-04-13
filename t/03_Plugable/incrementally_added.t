use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 4;
    
    my $tpl;
    my $parsed;
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::Plugin1');
    $parsed = $tpl->parse(q[left <% Test::Plugin1::some_function() %> right]);
    is($parsed, 'left Test::Plugin1::some_function called right');
    
    $tpl->plug('Test::Plugin2');
    $parsed = $tpl->parse(q[left <% Test::Plugin2::some_function() %> right]);
    is($parsed, 'left Test::Plugin2::some_function called right');
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::Plugin1');
    $parsed = $tpl->parse(q[left <% Test::Plugin1::some_function() %> right]);
    is($parsed, 'left Test::Plugin1::some_function called right');
    
    $tpl->plug('Test::Plugin2');
    $parsed = $tpl->parse(q[left <% Test::Plugin2::some_function() %> right]);
    is($parsed, 'left Test::Plugin2::some_function called right');
