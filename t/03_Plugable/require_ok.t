use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;
	
	use Test::More tests => 2;
	
	require 'Text/PSTemplate.pm';
    
    my $tpl;
	
    $tpl = Text::PSTemplate->new;
	$tpl->plug('RequireOk');
	is ref $tpl->func('RequireOk::some_func'), 'CODE';
	is $tpl->parse('<% RequireOk::some_func() %>'), 'some_func called';
