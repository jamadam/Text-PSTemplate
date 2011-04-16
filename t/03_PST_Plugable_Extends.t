use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub basic : Test {
        
        my $tpl = Text::PSTemplate::Plugable->new();
        $tpl->plug('Text::PSTemplate::Plugin::Extends','');
        
        $tpl->set_var(blog_entries => [
            {title => 'Entry one', body => 'This is my first entry.'},
            {title => 'Entry two', body => 'This is my second entry.'},
        ]);
        
        my $parsed = $tpl->parse_file('t/template/03_PST_Plugable_Extends2.txt');
        my $expected = $tpl->get_file('t/template/03_PST_Plugable_Extends3.txt')->content;
        is(compress_html($parsed), compress_html($expected));
    }
    
    sub compress_html {
        
        my $sql = shift;
        $sql =~ s/[\s\r\n]+//gs;
        $sql =~ s/[\s\r\n]+$//gs;
        return $sql;
    }
