package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub recursion : Test {
        
        my $tpl = Text::PSTemplate->new();
        my $put_tpl = sub {
            my $tpl = Text::PSTemplate::get_block(0);
            my $a = Text::PSTemplate->new();
            return $a->parse($tpl);
        };
        $tpl->set_func(put_tpl => $put_tpl);
        my $parsed = $tpl->parse_file('t/01_PST/template/basic.txt');
        is(indent_optimize($parsed), 'left inline template inline template2 right');
    }
    
    sub if_implementation : Test {
        
        my $tpl = Text::PSTemplate->new();
        my $if = sub {
            if ($_[0]) {
                return Text::PSTemplate::get_block(0);
            } else {
                return Text::PSTemplate::get_block(1);
            }
        };
        $tpl->set_func(if => $if);
        $tpl->set_var(is_female => 1);
        my $parsed = $tpl->parse_file('t/01_PST/template/basic_2.txt');
        is(indent_optimize($parsed), 'Female: yes');
    }
    
    sub catch_exception : Test(1) {
        
        my $tpl = Text::PSTemplate->new;
        eval {
            $tpl->parse(q[<% hoge() %>])
        };
        like($@, qr/undefined/);
    }
    
    sub no_exception : Test(1) {
        
        my $tpl = Text::PSTemplate->new;
        my $e = sub {'hoge'};
        $tpl->set_exception($e);
        eval {
            $tpl->parse(q[<% hoge() %>])
        };
        is($@, '');
    }
    
    sub reconstruct_tag : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
        my $e = sub {
            my ($self, $line, $err) = (@_);
            return 
                $self->get_delimiter(0)
                . $line
                . $self->get_delimiter(1);
        };
        $tpl->set_exception($e);
        my $parsed = eval {
            $tpl->parse(q[<% hoge() %>])
        };
        is($@, '');
        is($parsed, '<% hoge() %>');
    }
    
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
