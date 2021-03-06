use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 6;
    
    my $tpl;
    my $parsed;

    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::Plugin1');
    $parsed = $tpl->parse(q[left <% &Test::Plugin1::some_function() %> right]);
    is($parsed, 'left Test::Plugin1::some_function called right');
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::Plugin1');
    $parsed = $tpl->parse(q[left <% &Test::Plugin1::some_function() %> right]);
    is($parsed, 'left Test::Plugin1::some_function called right');
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::Plugin1');
    $parsed = $tpl->parse(q[left <% Test::Plugin1::some_function() %> right]);
    is($parsed, 'left Test::Plugin1::some_function called right');
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::Plugin1');
    $tpl->plug('Test::Plugin2');
    $parsed = $tpl->parse(q[left <% Test::Plugin1::some_function() %> <% Test::Plugin2::some_function() %> right]);
    is($parsed, 'left Test::Plugin1::some_function called Test::Plugin2::some_function called right');
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::Plugin1' => undef, 'Test::Plugin2' => undef);
    $parsed = $tpl->parse(q[left <% Test::Plugin1::some_function() %> <% Test::Plugin2::some_function() %> right]);
    is($parsed, 'left Test::Plugin1::some_function called Test::Plugin2::some_function called right');
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::Plugin2');
    my $parsed1 = $tpl->parse(q[<% Test::Plugin2::some_function() %>]);
    is($parsed1, 'Test::Plugin2::some_function called');
