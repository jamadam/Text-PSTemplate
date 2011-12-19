package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub parse_file : Test(4) {
        
        my $tpl = Text::PSTemplate->new;
        eval {
            $tpl->parse_file('does_not_exist');
        };
        like($@, qr/not found/i);
        like($@, qr{does_not_exist});
        like($@, qr{line 16});
        is((() = $@ =~ / at /g), 1);
    }
    
    sub get_file : Test(4) {
        
        my $tpl = Text::PSTemplate->new;
        eval {
            $tpl->get_file('does_not_exist');
        };
        like($@, qr/not found/i);
        like($@, qr{does_not_exist});
        like($@, qr{line 28});
        is((() = $@ =~ / at /g), 1);
    }

__END__
