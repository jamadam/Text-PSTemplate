use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
    
	use Test::More tests => 1;
    
    my $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/03_PST_Plugable/template/partial_exception1.txt');
    };
    like($@, qr/undefined/);
