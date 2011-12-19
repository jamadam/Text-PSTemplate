package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 1;
    
    my $tpl = Text::PSTemplate->new;
    $tpl->set_func(somefunc => sub {$_[0]});
    $tpl->set_func(somefunc2 => sub {'a'});
    my $a = eval {
        $tpl->parse('<% somefunc(somefunc2()) %>');
    };
    is($a, 'a', 'right persed string');

__END__
