package Template_Basic;
use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
    
	use Test::More tests => 10;
    
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

    $tpl = Text::PSTemplate->new;
    $tpl->set_var(title => 'TITLE');
    $tpl->set_func(func => sub {
        Text::PSTemplate::set_chop(1);
        return $_[0];
    });
    my $parsed1 = $tpl->parse(qq{<% func(\$title) %><% \$title %>\n});
    is $parsed1, "TITLETITLE\n", 'right parsed string';
    my $parsed2 = $tpl->parse(qq{<% func(\$title) %>\n\n<% \$title %>});
    is $parsed2, "TITLE\nTITLE", 'right parsed string';
    my $parsed3 = $tpl->parse(qq{<% func(\$title) %>\n<% \$title %>});
    is $parsed3, "TITLETITLE", 'right parsed string';

    $tpl->set_func(func2 => sub {
        Text::PSTemplate::set_chop(0);
        return $_[0];
    });
    
    my $parsed4 = $tpl->parse(qq{<% func2(&func(\$title)) %>\n<% \$title %>});
    is $parsed4, "TITLE\nTITLE", 'right parsed string';

__END__
