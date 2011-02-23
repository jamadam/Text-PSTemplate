package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 'lib';
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub no_parse : Test {
        
        my $tpl = Text::PSTemplate->new();
        $tpl->set_var(title => 'TITLE');
        my $parsed = $tpl->parse(q!leftright!);
        is($parsed, 'leftright');
    }
    
    sub get_delimiter : Test(4) {
        
        my $tpl = Text::PSTemplate->new();
        is($tpl->get_delimiter(0), '<%');
        is($tpl->get_delimiter(1), '%>');
        my $tpl2 = Text::PSTemplate->new($tpl);
        is($tpl2->get_delimiter(0), '<%');
        is($tpl2->get_delimiter(1), '%>');
    }
    
    sub set_vars1 : Test {
        
        my $tpl = Text::PSTemplate->new();
        $tpl->set_var(title => 'TITLE');
        my $parsed = $tpl->parse(q!left <% $title %> right!);
        is($parsed, 'left TITLE right');
    }
    
    sub set_vars2 : Test {
        
        my $tpl = Text::PSTemplate->new();
        $tpl->set_var(title => 'TITLE');
        my $parsed = $tpl->parse(q!<% $title %>!);
        is($parsed, 'TITLE');
    }
    
    sub set_func : Test {
        
        my $tpl = Text::PSTemplate->new();
        $tpl->set_func(hello => sub {
            'hello '. shift;
        });
        my $parsed = $tpl->parse(q!<% hello('world') %>!);
        is($parsed, 'hello world');
    }
    
    sub var_not_found : Test {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->set_var_exception($Text::PSTemplate::Exception::PARTIAL_NONEXIST_DIE);
        my $parsed = eval {
            $tpl->parse(q!<% $title %>!)
        };
        like($@, qr/variable \$title not defined/);
    }
    
    sub var_not_found2 : Test {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->set_var_exception(sub {$_[1]});
        my $parsed = $tpl->parse(q!<% $title %>!);
        is($parsed, '$title');
    }
    
    sub var_not_found3 : Test {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->set_exception(sub {''});
        my $parsed = $tpl->parse(q!a<% $title %>b!);
        is($parsed, 'ab');
    }
    
    sub recurs : Test(2) {
        
        my $tpl = Text::PSTemplate->new();
        
        my $tpl_str = <<EOF;
<div>
    <% hello('Takashi', 'Taro') %>
</div>
EOF
        
        my $expected = <<EOF;
<div>
    hello Takashi! hello Taro!
</div>
EOF
        my $mother = $tpl;
        $tpl->set_func(hello => sub {
            
            my (@array) = @_;
            my $tpl = Text::PSTemplate->new;
            $tpl->set_exception(sub {''});
            is($tpl->mother, $mother);
            my $out = '';
            for my $elem (@array) {
                $out .= $tpl->parse("hello $elem! ");
            }
            $out =~ s/ $//;
            return $out;
        });
        is($tpl->parse($tpl_str), $expected);
    }
    
    sub inline_data2 : Test(1) {
        
        my $tpl = Text::PSTemplate->new();
        
        my $html = <<'EOF';
        <% hello()<<END1 %>takashi$a<% END1 %>
EOF
        
        my $expected = <<'EOF';
        hello takashi$a!
EOF
        my $mother = $tpl;
        $tpl->set_var(a => 'a');
        $tpl->set_func(hello => sub {
            my (@array) = (Text::PSTemplate::inline_data(0));
            my $tpl = Text::PSTemplate->new();
            my $out = '';
            for my $elem (@array) {
                $elem =~ s/\n//gs;
                $out .= $tpl->parse("hello $elem! ");
            }
            $out =~ s/ $//;
            return $out;
        });
        is($tpl->parse($html), $expected);
    }
    
    sub inline_data : Test(1) {
        
        my $tpl = Text::PSTemplate->new();
        
        my $expected = <<EOF;
        hello Hiroshi!
EOF
        
        my $html = <<EOF;
        <% hello()<<EOF %>Hiroshi<% EOF %>
EOF
        my $mother = $tpl;
        $tpl->set_func(hello => sub {
            my $target =  shift || Text::PSTemplate::inline_data(0);
            return "hello $target!";
        });
        is($tpl->parse($html), $expected);
    }
    
    sub xslate_compatible : Test {
        
        my $expected = <<'EXPECTED';
<ol>
    <li>プログラミングPerl Vol.1 708 pages / ISBN-13 : 978-4873110967</li>
    <li>プログラミングPerl Vol.2 1303 pages / ISBN-13 : 978-4873110974</li>
    <li>Программирование на Perl 1152 pages / ISBN-13 : 978-5932860205</li>
    <li>Programming Perl 1092 pages / ISBN-13 : 978-0596000271</li>

</ol>
EXPECTED
    
        my $books = {
            "978-0596000271" => {
                name  => "Programming Perl",
                pages => 1092,
            },
            "978-5932860205" => {
                name => "Программирование на Perl",
                pages => 1152,
            },
            "978-4873110967" => {
                name  => "プログラミングPerl Vol.1",
                pages => 708,
            },
            "978-4873110974" => {
                name  => "プログラミングPerl Vol.2",
                pages => 1303,
            },
        };
        
        my $template = Text::PSTemplate->new;
        $template->set_var(
            title    => "Perl Books",
            books    => $books,
        );
        $template->set_func(dump => sub {
            my $a = Dumper(shift);
            $a =~ s{\$VAR1 = }{}g;
            return $a;
        });
        $template->set_func(each => sub {
            my ($hash, $as, $tpl) = (@_);
            $tpl ||= Text::PSTemplate::inline_data(0);
            my $template2 = Text::PSTemplate->new;
            my $out = '';
            for my $k (keys %$hash) {
                $template2->set_var(
                    'hash'  => $hash,
                    $as     => $k,
                );
                $out .= $template2->parse($tpl);
            }
            $out;
        });
        
        my $parsed = $template->parse(<<'EOF');
<ol>
    <% each($books, 'isbn')<<EOF2 %><li><% $hash->{$isbn}->{name} %> <% $hash->{$isbn}->{pages} %> pages / ISBN-13 : <% $isbn %></li>
    <% EOF2 %>
</ol>
EOF
        is(indent_optimize($parsed), indent_optimize($expected));
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
        return $in;
    }
