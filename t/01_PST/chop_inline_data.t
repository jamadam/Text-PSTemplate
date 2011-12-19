package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
    
    __PACKAGE__->runtests;
    
    sub get_block_chop : Test(4) {
        
        my $tpl = Text::PSTemplate->new();
        $tpl->set_func(a => sub {
            my $a = Text::PSTemplate::get_block(0);
            is($a, "\nhoge\n");
            my $b = Text::PSTemplate::get_block(0, {chop_left => 1});
            is($b, "hoge\n");
            my $c = Text::PSTemplate::get_block(0, {chop_right => 1});
            is($c, "\nhoge");
            my $d = Text::PSTemplate::get_block(0, {chop_left => 1,chop_right => 1});
            is($d, "hoge");
        });
        $tpl->parse(<<EOF);
<% a()<<AAA %>
hoge
<% AAA %>
EOF
    }
    
    sub get_block_chop_2blocks : Test(2) {
        
        my $tpl = Text::PSTemplate->new();
        $tpl->set_func(a => sub {
            my $a = Text::PSTemplate::get_block(0, {chop_left => 1,chop_right => 1});
            is($a, "hoge");
            my $b = Text::PSTemplate::get_block(1, {chop_left => 1,chop_right => 1});
            is($b, "hoge");
        });
        $tpl->parse(<<EOF);
<% a()<<AAA,BBB %>
hoge
<% AAA %>
hoge
<% BBB %>
EOF
    }

__END__
