package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 6;
    
    my $tpl;
    my $parsed;
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_func(put_tpl => sub {
        my $tpl = Text::PSTemplate::get_block(0);
        my $a = Text::PSTemplate->new();
        return $a->parse($tpl);
    });
    $parsed = $tpl->parse_file('t/01_PST/template/basic.txt');
    is indent_optimize($parsed), 'left inline template inline template2 right';
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_func(if => sub {
        if ($_[0]) {
            return Text::PSTemplate::get_block(0);
        } else {
            return Text::PSTemplate::get_block(1);
        }
    });
    $tpl->set_var(is_female => 1);
    $parsed = $tpl->parse_file('t/01_PST/template/basic_2.txt');
    is(indent_optimize($parsed), 'Female: yes');
    
    $tpl = Text::PSTemplate->new;
    eval {$tpl->parse(q[<% hoge() %>])};
    like($@, qr/undefined/, 'right error');
    
    $tpl = Text::PSTemplate->new;
    eval {$tpl->parse(q[<% hoge() %>])};
    like($@, qr{function &hoge undefined at t/01_PST/basic2.t}, 'right error');
    
    $tpl = Text::PSTemplate->new;
    $parsed = eval {$tpl->parse(q[<% hoge() %>])};
    like $@, qr{function &hoge undefined at t/01_PST/basic2.t line 44}, 'right error';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(myfunc => sub {warn '====='; 'a'});
    $parsed = eval {$tpl->parse(q[<% myfunc(&hoge()) %>])};
    like($@, qr{function &hoge undefined at t/01_PST/basic2.t line 49}, 'right error');
    
    sub indent_optimize {
        my $in = shift;
        $in =~ s{\s+}{ }g;
        $in =~ s{ $}{};
        return $in;
    }

__END__
