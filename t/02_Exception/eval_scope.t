package Template_Basic;
use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 1;
    
    my $tpl = Text::PSTemplate->new;
    $tpl->set_func(somefunc => sub {'a'});
    eval {$tpl->parse('<% somefunc(parse()) %>')};
    like $@, qr/function &parse undefined/i, 'right error';

__END__
