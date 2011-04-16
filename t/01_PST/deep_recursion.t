package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Scalar::Util qw(blessed);
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub default_recuresion_limit : Test(2) {
        
        my $tpl01 = Text::PSTemplate->new();
        my $tpl02 = eval {Text::PSTemplate->new($tpl01)};
        my $tpl03 = eval {Text::PSTemplate->new($tpl02)};
        my $tpl04 = eval {Text::PSTemplate->new($tpl03)};
        my $tpl05 = eval {Text::PSTemplate->new($tpl04)};
        my $tpl06 = eval {Text::PSTemplate->new($tpl05)};
        my $tpl07 = eval {Text::PSTemplate->new($tpl06)};
        my $tpl08 = eval {Text::PSTemplate->new($tpl07)};
        my $tpl09 = eval {Text::PSTemplate->new($tpl08)};
        my $tpl10 = eval {Text::PSTemplate->new($tpl09)};
        my $tpl11 = eval {Text::PSTemplate->new($tpl10)};
        is($@, '');
        my $tpl12 = eval {Text::PSTemplate->new($tpl11)};
        like($@, qr/Deep Recursion/);
    }
    
    sub recuresion_limit_custom : Test(2) {
        
        my $tpl01 = Text::PSTemplate->new;
        $tpl01->set_recur_limit(2);
        my $tpl02 = eval {Text::PSTemplate->new($tpl01)};
        my $tpl03 = eval {Text::PSTemplate->new($tpl02)};
        is($@, '');
        my $tpl04 = eval {Text::PSTemplate->new($tpl03)};
        like($@, qr/Deep Recursion/);
    }

__END__