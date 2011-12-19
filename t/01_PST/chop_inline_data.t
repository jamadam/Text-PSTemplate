package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
    
	use Test::More tests => 6;
    
    my $tpl;
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(a => sub {
        my $a = Text::PSTemplate::get_block(0);
        is($a, "\nhoge\n", 'right block value');
        my $b = Text::PSTemplate::get_block(0, {chop_left => 1});
        is($b, "hoge\n", 'right block value');
        my $c = Text::PSTemplate::get_block(0, {chop_right => 1});
        is($c, "\nhoge", 'right block value');
        my $d = Text::PSTemplate::get_block(0, {chop_left => 1,chop_right => 1});
        is($d, "hoge", 'right block value');
    });
    $tpl->parse(<<'EOF');
<% a()<<AAA %>
hoge
<% AAA %>
EOF
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(a => sub {
        my $a = Text::PSTemplate::get_block(0, {chop_left => 1,chop_right => 1});
        is($a, "hoge", 'right block value');
        my $b = Text::PSTemplate::get_block(1, {chop_left => 1,chop_right => 1});
        is($b, "hoge", 'right block value');
    });
    $tpl->parse(<<'EOF');
<% a()<<AAA,BBB %>
hoge
<% AAA %>
hoge
<% BBB %>
EOF

__END__
