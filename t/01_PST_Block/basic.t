package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 'lib';
use Text::PSTemplate;
use Text::PSTemplate::Block;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub basic1 : Test(4) {
        
        my $block = Text::PSTemplate::Block->new('TTT', \do{"bbb<% TTT %>ccccaaa"}, '<%', '%>');
        is($block->content(0), 'bbb');
        is($block->get_left_chomp(0), undef);
        is($block->get_followers_offset, 12);
        is($block->delimiter(0), '<% TTT %>');
    }
    
    sub basic2 : Test(7) {
        
        my $block = Text::PSTemplate::Block->new('TTT,TTT2', \do{"bbb<% TTT %>bbb2<% TTT2 %>ccccaaa"}, '<%', '%>');
        is($block->content(0), 'bbb');
        is($block->content(1), 'bbb2');
        is($block->get_left_chomp(0), undef);
        is($block->get_left_chomp(1), undef);
        is($block->get_followers_offset, 26);
        is($block->delimiter(0), '<% TTT %>');
        is($block->delimiter(1), '<% TTT2 %>');
    }
    
    sub basic3 : Test(6) {
        
        my $block = Text::PSTemplate::Block->new('TTT', \do{"\nbbb\n<% TTT %>ccccaaa"}, '<%', '%>');
        is($block->content(0), "\nbbb\n");
        is($block->content(0, {chop_left => 1}), "bbb\n");
        is($block->content(0, {chop_right => 1}), "\nbbb");
        is($block->content(0, {chop_left => 1, chop_right => 1}), "bbb");
        is($block->get_left_chomp(0), "\n");
        is($block->get_followers_offset, 14);
    }
    
    sub basic4 : Test(11) {
        
        my $block = Text::PSTemplate::Block->new('TTT,TTT2', \do{"\nbbb\n<% TTT %>\nbbb2\n<% TTT2 %>ccccaaa"}, '<%', '%>');
        is($block->content(0), "\nbbb\n");
        is($block->content(1), "\nbbb2\n");
        is($block->content(0, {chop_left => 1}), "bbb\n");
        is($block->content(0, {chop_right => 1}), "\nbbb");
        is($block->content(0, {chop_left => 1, chop_right => 1}), "bbb");
        is($block->content(1, {chop_left => 1}), "bbb2\n");
        is($block->content(1, {chop_right => 1}), "\nbbb2");
        is($block->content(1, {chop_left => 1, chop_right => 1}), "bbb2");
        is($block->get_left_chomp(0), "\n");
        is($block->get_left_chomp(1), "\n");
        is($block->get_followers_offset, 30);
    }
    
    sub win_type_newline : Test(3) {
        
        my $block = Text::PSTemplate::Block->new('TTT', \do{"\r\nbbb<% TTT %>ccccaaa"}, '<%', '%>');
        is($block->content(0), "\r\nbbb");
        is($block->get_left_chomp(0), "\r\n");
        is($block->get_followers_offset, 14);
    }
    
    sub double_newline : Test(4) {
        
        my $block = Text::PSTemplate::Block->new('TTT', \do{"\r\n\r\nbbb<% TTT %>ccccaaa"}, '<%', '%>');
        is($block->content(0), "\r\n\r\nbbb");
        is($block->content(0, {chop_left => 1}), "\r\nbbb");
        is($block->get_left_chomp(0), "\r\n");
        is($block->get_followers_offset, 16);
    }
