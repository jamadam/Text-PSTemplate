package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 'lib';
use Text::PSTemplate::File;
use Data::Dumper;
use utf8;

    __PACKAGE__->runtests;
    
    sub basic : Test(3) {
        
        my $file = Text::PSTemplate::File->new('t/01_File/template/ok.txt');
        is($file->name, 't/01_File/template/ok.txt');
        is($file->content, 'ok');
        is($file->detected_encoding, 'utf8');
    }
    
    sub utf8: Test(3) {
        
        my $file = Text::PSTemplate::File->new('t/01_File/template/utf8.txt');
        is($file->name, 't/01_File/template/utf8.txt');
        is($file->content, 'あ');
        is($file->detected_encoding, 'utf8');
    }
    
    sub utf8_2: Test(3) {
        
        my $file = Text::PSTemplate::File->new('t/01_File/template/utf8.txt', 'utf8');
        is($file->name, 't/01_File/template/utf8.txt');
        is($file->content, 'あ');
        is($file->detected_encoding, 'utf8');
    }
    
    sub cp932: Test(3) {
        
        my $file = Text::PSTemplate::File->new('t/01_File/template/cp932.txt', 'cp932');
        is($file->name, 't/01_File/template/cp932.txt');
        is($file->content, 'あ');
        is($file->detected_encoding, 'cp932');
    }
    
    sub guess_detect_utf8 : Test(3) {
        
        my $file = Text::PSTemplate::File->new('t/01_File/template/utf8.txt', ['cp932','utf8']);
        is($file->name, 't/01_File/template/utf8.txt');
        is($file->content, 'あ');
        is($file->detected_encoding, 'utf8');
    }
    
    sub guess_detect_cp932 : Test(3) {
        
        my $file = Text::PSTemplate::File->new('t/01_File/template/cp932.txt', ['cp932','utf8']);
        is($file->name, 't/01_File/template/cp932.txt');
        is($file->content, 'あ');
        is($file->detected_encoding, 'cp932');
    }
    
    sub guess_detect_utf8_case2 : Test(3) {
        
        my $file = Text::PSTemplate::File->new('t/01_File/template/utf8.txt', ['utf8', 'cp932']);
        is($file->name, 't/01_File/template/utf8.txt');
        is($file->content, 'あ');
        is($file->detected_encoding, 'utf8');
    }
    
    sub guess_detect_cp932_case2 : Test(3) {
        
        my $file = Text::PSTemplate::File->new('t/01_File/template/cp932.txt', ['utf8', 'cp932']);
        is($file->name, 't/01_File/template/cp932.txt');
        is($file->content, 'あ');
        is($file->detected_encoding, 'cp932');
    }
