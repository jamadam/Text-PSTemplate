package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 1;
    
    my $t = Text::PSTemplate->new;
    my $res = eval {
        $t->parse('<% if(0)<<EOF %>a');
    };
    like $@, qr/unclosed block EOF found/;
