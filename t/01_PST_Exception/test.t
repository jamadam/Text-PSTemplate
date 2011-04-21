package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;
use Data::Dumper;

my $a = MyException->new;
print $a;
print $a->{hoge};

package MyException;
use overload (
	q{""} => sub {
		my ($self) = @_;
		return 'hoge at $self';
	}
);

	sub new {
		return bless {'hoge' => 'val'}, shift;
	}