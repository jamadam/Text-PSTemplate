package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 7;
    
    my $e;
    
    $e = Text::PSTemplate::Exception->new('hoge');
    my $res1 = eval {$e eq 'a'};
    is($@, '');
    isnt($res1, 1);
    my $res2 = eval {$e ne 'a'};
    is($@, '');
    is($res2, 1);
    like($e, qr/hoge/);
    like($e, qr/basic.t/);

    $e = Text::PSTemplate::Exception->new('hoge');
    is(ref $e, 'Text::PSTemplate::Exception');
