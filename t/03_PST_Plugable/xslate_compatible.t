use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
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
        
        my $template = Text::PSTemplate->new;
        $template->set_var(
            title    => "Perl Books",
            books    => $books,
        );
        
        my $parsed = $template->parse_file('t/03_PST_Plugable/template/xslate_compatible.txt');
        my $expected = $template->get_file('t/03_PST_Plugable/template/xslate_compatible_expected.txt');
        is(indent_optimize($parsed), indent_optimize($expected->content));
    }
    
    sub indent_optimize {
        my $in = shift;
        $in =~ s{\s+}{ }g;
        return $in;
    }
