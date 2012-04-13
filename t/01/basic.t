package Template_Basic;
use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 56;
    
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
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_func(put_tpl => sub {
        my $tpl = Text::PSTemplate::get_block(0);
        my $a = Text::PSTemplate->new();
        return $a->parse($tpl);
    });
    $parsed = $tpl->parse_file('t/01/template/basic.txt');
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
    $parsed = $tpl->parse_file('t/01/template/basic_2.txt');
    is indent_optimize($parsed), 'Female: yes', 'right result';
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_var(a => undef);
    is $tpl->var('a'), undef, 'right value in variable';
    
    $tpl = Text::PSTemplate->new();
    $tpl2 = Text::PSTemplate->new($tpl);
    $tpl->set_var(a => 'a');
    $tpl2->set_var(a => undef);
    is $tpl->var('a'), 'a', 'right value in variable';
    is $tpl2->var('a'), 'a', 'right value in variable';
    
    $tpl = Text::PSTemplate->new;
    is $tpl->{2}, '<%', 'right delimiter';
    $tpl2 = Text::PSTemplate->new($tpl);
    is $tpl2->{2}, undef, 'right delimiter';
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_func(test => sub {
        my $tpl2 = Text::PSTemplate->new();
        is $tpl2->{2}, undef, 'right delimiter';
    });
    $tpl->parse('<% test() %>');
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(test => sub {
        my $tpl2 = Text::PSTemplate->new(undef);
        is $tpl2->{2}, '<%', 'right delimiter';
    });
    $tpl->parse('<% test() %>');
    
    {
        $tpl = Text::PSTemplate->new;
        $tpl->set_func(somefunc => sub {$_[0]});
        $tpl->set_func(somefunc2 => sub {'a'});
        my $a = $tpl->parse('<% somefunc(somefunc2()) %>');
        is $a, 'a', 'right persed string';
    }
    
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

    $tpl = Text::PSTemplate->new();
    $tpl->set_var(title => 'TITLE');
    is $tpl->parse(q!<% $title %>!), 'TITLE', 'right parsed result';
    is $tpl->parse(q!\\<% $title %>!), q!<% $title %>!, 'right parsed result';
    is $tpl->parse(q!\\\\<% $title %>!), '\\TITLE', 'right parsed result';
    is $tpl->parse(q!\\\\\\<% $title %>!), '\\<% $title %>', 'right parsed result';
    
    {
        $tpl = Text::PSTemplate->new;
        my $current_file_parser = $tpl;
        $tpl->set_func(a => sub {
            my $current = Text::PSTemplate::get_current_file_parser;
            is $current, $current_file_parser, 'right parser';
            return '';
        });
        $tpl->set_func(include => sub {
            my $tpl2 = Text::PSTemplate->new;
            $current_file_parser = $tpl2;
            return $tpl2->parse_file($_[0]);
        });
        my $a = $tpl->parse_file('t/01/template/get_file_context_mother1.txt');
    }
    
    {
        my $tpl = Text::PSTemplate->new;
        is(ref $tpl, 'Text::PSTemplate');
        my $tpl2 = Text::PSTemplate->new($tpl);
        is(ref $tpl2, 'Text::PSTemplate');
        my $tpl3 = Text::PSTemplate->new($tpl);
        is(ref $tpl3, 'Text::PSTemplate');
        my $tpl4 = Text::PSTemplate->new($tpl);
        is(ref $tpl4, 'Text::PSTemplate');
    }
    
    {
        my $tpl;
        my $tpl2;
        my $tpl3;
        
        $tpl = Text::PSTemplate->new;
        $tpl2 = Text::PSTemplate->new($tpl);
        is ref $tpl2, 'Text::PSTemplate', 'right class';
        isnt $tpl2, $tpl, 'right instance';
        is $tpl2->get_current_parser, $tpl, 'right instance';
            
        $tpl = PST2->new;
        $tpl2 = PST2->new($tpl);
        is ref $tpl2, 'PST2', 'right class';
        isnt $tpl2, $tpl, 'right instance';
        is $tpl2->get_current_parser, $tpl, 'right instance';
        
        $tpl = PST2->new;
        $tpl2 = PST2->new($tpl);
        is ref $tpl2, 'PST2', 'right class';
        isnt $tpl2, $tpl, 'right instance';
        is $tpl2->get_current_parser, $tpl, 'right instance';
        
        $tpl = PST2->new;
        $tpl2 = Text::PSTemplate->new($tpl);
        is ref $tpl2, 'Text::PSTemplate', 'right class';
        isnt $tpl2, $tpl, 'right instance';
        is $tpl2->get_current_parser, $tpl, 'right instance';
        
        $tpl = PST2->new;
        $tpl3 = PST3->new;
        $tpl2 = PST3->new($tpl);
        is ref $tpl2, 'PST3', 'right class';
        isnt $tpl2, $tpl, 'right instance';
        isnt $tpl2, $tpl3, 'right instance';
        is $tpl2->get_current_parser, $tpl, 'right instance';
    }
    
    sub compress_html {
        my $sql = shift;
        $sql =~ s/[\s\r\n]+//gs;
        $sql =~ s/[\s\r\n]+$//gs;
        return $sql;
    }
    
    sub indent_optimize {
        my $in = shift;
        $in =~ s{\s+}{ }g;
        $in =~ s{ $}{};
        return $in;
    }

package PST2;
use strict;
use warnings;
use base qw(Text::PSTemplate);

package PST3;
use strict;
use warnings;
use base qw(Text::PSTemplate);
