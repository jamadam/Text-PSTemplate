package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub ampersand_in_function : Test {
        
        my $tpl = Text::PSTemplate->new();
        $tpl->set_var(title => 'TITLE');
        $tpl->set_func(hoge => sub {return '-'. $_[0]});
        my $parsed = $tpl->parse(q!left <%&hoge('./?a=1\&b=2')%> right!);
        is($parsed, 'left -./?a=1&b=2 right');
    }
    
    sub ampersand_in_inline_data : Test {
        
        my $tpl = Text::PSTemplate->new();
        $tpl->set_var(title => 'TITLE');
        $tpl->set_func(hoge => sub {return '-'. Text::PSTemplate::inline_data(0)});
        my $parsed = $tpl->parse(q!left <%&hoge()<<EOF%>./?a=1&b=2<%EOF%> right!);
        is($parsed, 'left -./?a=1&b=2 right');
    }
    
    sub to_way_function_implementation : Test(2) {
        
        my $tpl = Text::PSTemplate->new();
        $tpl->set_var(title => 'TITLE');
        $tpl->set_func(hoge => sub {
            if ($_[0]) {
                return '-'. $_[0];
            } else {
                return '-'. Text::PSTemplate::inline_data(0);
            }
        });
        my $parsed1 = $tpl->parse(q!left <%&hoge()<<EOF%>./?a=1&b=2<%EOF%> right!);
        is($parsed1, 'left -./?a=1&b=2 right');
        my $parsed2 = $tpl->parse(q!left <%&hoge('./?a=1\&b=2')%> right!);
        is($parsed2, 'left -./?a=1&b=2 right');
    }
    
    sub error_msg_include_quote : Test {
        
        my $err = sub {q{error at 'hoge' ""}};
        my $tpl = Text::PSTemplate->new;
        $tpl->set_exception($err);
        my $parsed = $tpl->parse(q!-<%$title%>-!);
        is($parsed, q{-error at 'hoge' ""-});
    }
    
    sub error_msg_include_quote_sub : Test {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->set_exception(sub {q{error at 'hoge' ""}});
        my $parsed = $tpl->parse(q!-<%&title($a)%>-!);
        is($parsed, q{-error at 'hoge' ""-});
    }
    
    sub inline_data_include_quote : Test(1) {
        
        my $tpl = Text::PSTemplate->new();
        
        my $expected = <<'EOF';
        hello takashi"!
EOF
        $tpl->set_var(a => 'a');
        $tpl->set_func(hello => sub {
            my $name = shift || Text::PSTemplate::inline_data(0);
            my $tpl = Text::PSTemplate->new();
            return $tpl->parse("hello $name!");
        });
        is($tpl->parse(<<'EOF'), $expected);
        <%&hello()<<END1%>takashi"<%END1%>
EOF
    
    }
    
    sub indent_optimize {
        my $in = shift;
        $in =~ s{\s+}{ }g;
        $in =~ s{ $}{};
        return $in;
    }

__END__
