package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub recursion : Test {
        
        my $tpl = Text::PSTemplate->new();
        my $put_tpl = sub {
            my $tpl = Text::PSTemplate::inline_data(0);
            my $a = Text::PSTemplate->new();
            return $a->parse($tpl);
        };
        $tpl->set_func(put_tpl => $put_tpl);
        my $parsed = $tpl->parse(file => 't/template/Template_basic2.txt');
        is(indent_optimize($parsed), 'left inline template inline template2 right');
    }
    
    sub if_implementation : Test {
        
        my $tpl = Text::PSTemplate->new();
        my $if = sub {
            if ($_[0]) {
                return Text::PSTemplate::inline_data(0);
            } else {
                return Text::PSTemplate::inline_data(1);
            }
        };
        $tpl->set_func(if => $if);
        $tpl->set_var(is_female => 1);
        my $parsed = $tpl->parse(file => 't/template/Template_basic2_2.txt');
        is(indent_optimize($parsed), 'Female: yes');
    }
    
    sub indent_optimize {
        my $in = shift;
        $in =~ s{\s+}{ }g;
        $in =~ s{ $}{};
        return $in;
    }

__END__
