use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 1;
    
    my $tpl = Text::PSTemplate->new();
    $tpl->plug('Text::PSTemplate::Plugin::Extends','');
    
    $tpl->set_var(blog_entries => [
        {title => 'Entry one', body => 'This is my first entry.'},
        {title => 'Entry two', body => 'This is my second entry.'},
    ]);
    
    my $parsed = $tpl->parse_file('t/03_PST_Plugable/template/Extends2.txt');
    my $expected = $tpl->get_file('t/03_PST_Plugable/template/Extends3.txt')->content;
    is(compress_html($parsed), compress_html($expected));
    
    sub compress_html {
        my $sql = shift;
        $sql =~ s/[\s\r\n]+//gs;
        $sql =~ s/[\s\r\n]+$//gs;
        return $sql;
    }
