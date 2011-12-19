package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Scalar::Util qw(blessed);
use Data::Dumper;
    
	use Test::More tests => 4;
    
    my $tpl01 = Text::PSTemplate->new();
    my $tpl02 = eval {Text::PSTemplate->new($tpl01)};
    my $tpl03 = eval {Text::PSTemplate->new($tpl02)};
    $tpl03->set_recur_limit(2);
    is($@, '');
    my $tpl04 = eval {Text::PSTemplate->new($tpl03)};
    like($@, qr/Deep Recursion/);

    my $tpl05 = eval {Text::PSTemplate->new($tpl02)};
    is($@, '');
    my $tpl06 = eval {Text::PSTemplate->new($tpl05)};
    is($@, '');

__END__
