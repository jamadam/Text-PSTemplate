package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 2;
    
    my $tpl = Text::PSTemplate->new;
    $tpl->set_func(hoge => sub {
        if (! $_[0]) {
            die 'say something';
        }
        return 1;
    });
    eval {
        $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at6_1.txt');
    };
    like($@, qr{t/01_PST_Exception/template/error_message_include_at6_1.txt line 4});
    is((() = $@ =~ / at /g), 1);

