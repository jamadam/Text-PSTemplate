use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;
use Text::PSTemplate::Plugin::Extends;
use Data::Dumper;
use utf8;

    __PACKAGE__->runtests;
    
    sub xslate_compatible : Test {
    
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
        
        my $template = Text::PSTemplate::Plugable->new;
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
        
        my $parsed = $template->parse_file('t/template/03_PST_Plugable_xslate_compatible.txt');
        my $expected = $template->get_file('t/template/03_PST_Plugable_xslate_compatible_expected.txt');
        is(indent_optimize($parsed), indent_optimize($expected->content));
    }
    
    sub indent_optimize {
        my $in = shift;
        $in =~ s{\s+}{ }g;
        return $in;
    }