package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 2;
    
    my $tpl = Text::PSTemplate->new;
    $tpl->set_func(somefunc => sub {'a'});
    eval {$tpl->parse('<% somefunc(parse()) %>')};
    like $@, qr/function/i, 'right error';
    like $@, qr/Undefined/i, 'right error';

__END__
