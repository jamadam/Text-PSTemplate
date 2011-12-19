use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 1;
    
    my $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::Plugin2');
    my $parsed1 = $tpl->parse(q[<% Test::Plugin2::some_function() %>]);
    is($parsed1, 'some_function');
