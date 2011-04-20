package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;
use Data::Dumper;

my $a = MyScalar->new;
print $a;
#my $b = tied($a);
#print $b;
#print $scalar->hoge;
print "\n";

package MyScalar;

	sub new {
		my $class = @_;
		tie my $self, '_MyScalar';
		$self = {a => 1, b => 2};
		return bless {tied => $self}, $class;
	}

package _MyScalar;
use strict;
use warnings;

	sub TIESCALAR {
		my $pkg = shift;
		return bless {}, $pkg;
	}
	sub FETCH($) {
		my $this = shift;
		return $this->{a}. $this->{b};
	}
	sub STORE($$) {
		my ( $this, $value ) = @_;
		%$this = %$value;
	}
	sub DESTROY {
		my $this = shift;
	}
	sub hoge {
		'hoge';
	}
