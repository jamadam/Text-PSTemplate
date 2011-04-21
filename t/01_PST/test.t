package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub exception_in_args : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
		my $e = sub {
	        my ($self, $line, $err) = (@_);
			return 
				$self->get_delimiter(0)
				. $line
				. $self->get_delimiter(1);
		};
        $tpl->set_exception($e);
		$tpl->set_func(myfunc => sub {'a'});
		my $parsed = eval {
			$tpl->parse(q[<% myfunc(&hoge()) %>])
		};
		is($@, '');
		is($parsed, '<% myfunc(&hoge()) %>');
    }
    
    sub indent_optimize {
        my $in = shift;
        $in =~ s{\s+}{ }g;
        $in =~ s{ $}{};
        return $in;
    }

__END__
