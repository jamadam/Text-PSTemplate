package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;
use Data::Dumper;
    
    __PACKAGE__->runtests;

	sub overload_ok : Test(6) {
		
		my $a = Text::PSTemplate::Exception->new('hoge');
		my $res1 = eval {$a eq 'a'};
		is($@, '');
		isnt($res1, 1);
		my $res2 = eval {$a ne 'a'};
		is($@, '');
		is($res2, 1);
		like($a, qr/hoge/);
		like($a, qr/basic.t/);
	}

	sub overload_ok2 : Test(1) {
		
		my $a = Text::PSTemplate::Exception->new('hoge');
		is(ref $a, 'Text::PSTemplate::Exception');
	}
