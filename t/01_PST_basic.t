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
        like($@, qr/variable \$title undefined/);
    }
    
    sub var_not_found2 : Test {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->set_var_exception(sub {$_[1]});
        my $parsed = $tpl->parse(q!<% $title %>!);
        is($parsed, '$title');
    }
    
    sub var_not_found3 : Test {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->set_var_exception(sub {''});
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
            is($tpl->get_current_parser, $mother);
            my $out = '';
            for my $elem (@array) {
                $out .= $tpl->parse("hello $elem! ");
            }
            $out =~ s/ $//;
            return $out;
        });
        is($tpl->parse($tpl_str), $expected);
    }
    
    sub get_block2 : Test(1) {
        
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
            my (@array) = (Text::PSTemplate::get_block(0));
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
    
    sub get_block : Test(1) {
        
        my $tpl = Text::PSTemplate->new();
        
        my $expected = <<EOF;
        hello Hiroshi!
EOF
        
        my $html = <<EOF;
        <% hello()<<EOF %>Hiroshi<% EOF %>
EOF
        my $mother = $tpl;
        $tpl->set_func(hello => sub {
            my $target =  shift || Text::PSTemplate::get_block(0);
            return "hello $target!";
        });
        is($tpl->parse($html), $expected);
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
