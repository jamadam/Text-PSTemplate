use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub get_current_file_parser : Test(3) {
        
        my $tpl = Text::PSTemplate->new;
        my $current_file_parser = $tpl;
        $tpl->set_func(a => sub {
            my $current = Text::PSTemplate::get_current_file_parser;
            is($current, $current_file_parser);
            return '';
        });
        $tpl->set_func(include => sub {
            my $tpl2 = Text::PSTemplate->new;
            $current_file_parser = $tpl2;
            return $tpl2->parse_file($_[0]);
        });
        my $a = $tpl->parse_file('t/01_PST/template/get_file_context_mother1.txt');
    }
