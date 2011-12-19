package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 7;
    
    my $tpl;
    my $parsed;
    
    $tpl= Text::PSTemplate->new();
    $tpl->set_var(title => 'TITLE');
    $tpl->set_func(hoge => sub {return '-'. $_[0]});
    $parsed = $tpl->parse(q!left <% hoge('./?a=1\&b=2')%> right!);
    is $parsed, 'left -./?a=1&b=2 right', 'right parsed result';
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_var(title => 'TITLE');
    $tpl->set_func(hoge => sub {return '-'. Text::PSTemplate::get_block(0)});
    $parsed = $tpl->parse(q!left <% hoge()<<EOF%>./?a=1&b=2<%EOF%> right!);
    is $parsed, 'left -./?a=1&b=2 right', 'right parsed result';
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_var(title => 'TITLE');
    $tpl->set_func(hoge => sub {
        if ($_[0]) {
            return '-'. $_[0];
        } else {
            return '-'. Text::PSTemplate::get_block(0);
        }
    });
    $parsed = $tpl->parse(q!left <% hoge()<<EOF %>./?a=1&b=2<% EOF %> right!);
    is $parsed, 'left -./?a=1&b=2 right', 'right parsed result';
    $parsed = $tpl->parse(q!left <% hoge('./?a=1\&b=2') %> right!);
    is $parsed, 'left -./?a=1&b=2 right', 'right parsed result';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_exception($Text::PSTemplate::Exception::TAG_ERROR_NO_ACTION);
    $tpl->set_var_exception($Text::PSTemplate::Exception::PARTIAL_NONEXIST_DIE);
    $parsed = $tpl->parse(q!-<% $title %>-!);
    is $parsed, q!-<% $title %>-!, 'right parsed result';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_exception(sub {q{error at 'hoge' ""}});
    $parsed = $tpl->parse(q!-<% title($a) %>-!);
    is $parsed, q{-error at 'hoge' ""-}, 'right parsed result';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_var(a => 'a');
    $tpl->set_func(hello => sub {
        my $name = shift || Text::PSTemplate::get_block(0);
        my $tpl = Text::PSTemplate->new();
        return $tpl->parse("hello $name!");
    });
    is $tpl->parse(<<'EOF'), <<'EXPECTED', 'right parsed result';
<% hello()<<END1 %>takashi"<% END1 %>
EOF
hello takashi"!
EXPECTED

__END__
