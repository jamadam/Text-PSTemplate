use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
    
	use Test::More tests => 1;
    
    my $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/02_Exception/template/partial_exception1.txt');
    };
    like($@, qr/undefined/);
