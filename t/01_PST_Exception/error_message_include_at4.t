package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub tag_syntax_error : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
        eval {
            $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at4_1.txt');
        };
        like($@, qr{t/01_PST_Exception/template/error_message_include_at4_1.txt line 1});
        is((() = $@ =~ / at /g), 1);
    }
