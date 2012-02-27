package Template_Basic;
use strict;
use warnings;
use Test::More;
use lib 'lib';
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 15;
    
    my $tpl;
    my $tpl2;
    my $parsed;

    $tpl = Text::PSTemplate->new;
    $tpl->set_var(title => 'TITLE');
    $parsed = $tpl->parse(q!leftright!);
    is $parsed, 'leftright', 'right parsed string';
    
    $tpl = Text::PSTemplate->new;
    is $tpl->get_delimiter(0), '<%', 'right delimiter';
    is $tpl->get_delimiter(1), '%>', 'right delimiter';
    $tpl2 = Text::PSTemplate->new($tpl);
    is $tpl2->get_delimiter(0), '<%', 'right delimiter';
    is $tpl2->get_delimiter(1), '%>', 'right delimiter';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_var(title => 'TITLE');
    $parsed = $tpl->parse(q!left <% $title %> right!);
    is $parsed, 'left TITLE right', 'right parsed string';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_var(title => 'TITLE');
    $parsed = $tpl->parse(q!<% $title %>!);
    is $parsed, 'TITLE', 'right parsed string';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(hello => sub {'hello '. shift});
    $parsed = $tpl->parse(q!<% hello('world') %>!);
    is $parsed, 'hello world', 'right parsed string';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_var_exception($Text::PSTemplate::Exception::PARTIAL_NONEXIST_DIE);
    $parsed = eval {$tpl->parse(q!<% $title %>!)};
    like($@, qr/variable \$title undefined/, 'right error');
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_var_exception(sub {$_[1]});
    $parsed = $tpl->parse(q!<% $title %>!);
    is $parsed, '$title', 'right parsed string';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_var_exception(sub {''});
    $parsed = $tpl->parse(q!a<% $title %>b!);
    is $parsed, 'ab', 'right parsed string';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(hello => sub {
        my (@array) = @_;
        my $tpl2 = Text::PSTemplate->new;
        is $tpl2->get_current_parser, $tpl, 'right parser id';
        my $out = '';
        for my $elem (@array) {
            $out .= $tpl2->parse("hello $elem! ");
        }
        $out =~ s/ $//;
        return $out;
    });
    is $tpl->parse(<<'TEMPLATE'), <<'EXPECTED', 'right parsed string';
<div>
    <% hello('Takashi', 'Taro') %>
</div>
TEMPLATE
<div>
    hello Takashi! hello Taro!
</div>
EXPECTED
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_var(a => 'a');
    $tpl->set_func(hello => sub {
        my (@array) = (Text::PSTemplate::get_block(0));
        my $tpl2 = Text::PSTemplate->new();
        my $out = '';
        for my $elem (@array) {
            $elem =~ s/\n//gs;
            $out .= $tpl2->parse("hello $elem! ");
        }
        $out =~ s/ $//;
        return $out;
    });
    is $tpl->parse(<<'TEMPLATE'), <<'EXPECTED', 'right parsed string';
<% hello()<<END1 %>takashi$a<% END1 %>
TEMPLATE
hello takashi$a!
EXPECTED
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_func(hello => sub {
        my $target =  shift || Text::PSTemplate::get_block(0);
        return "hello $target!";
    });
    is $tpl->parse(<<'TEMPLATE'), <<'EXPECTED', 'right parsed string';
<% hello()<<EOF %>Hiroshi<% EOF %>
TEMPLATE
hello Hiroshi!
EXPECTED
    
    sub compress_html {
        my $sql = shift;
        $sql =~ s/[\s\r\n]+//gs;
        $sql =~ s/[\s\r\n]+$//gs;
        return $sql;
    }
    
    sub indent_optimize {
        my $in = shift;
        $in =~ s{\s+}{ }g;
        return $in;
    }
