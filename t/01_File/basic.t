package Template_Basic;
use strict;
use warnings;
use Test::More;
use lib 'lib';
use Text::PSTemplate::File;
use Data::Dumper;
use utf8;

	use Test::More tests => 24;
    
    my $file ;
    $file = Text::PSTemplate::File->new('t/01_File/template/ok.txt');
    is $file->name, 't/01_File/template/ok.txt', 'right file name';
    is $file->content, 'ok', 'right content';
    is $file->detected_encoding, 'utf8', 'right encoding';
    
    $file = Text::PSTemplate::File->new('t/01_File/template/utf8.txt');
    is $file->name, 't/01_File/template/utf8.txt', 'right file name';
    is $file->content, 'あ', 'right content';
    is $file->detected_encoding, 'utf8', 'right encoding';
    
    $file = Text::PSTemplate::File->new('t/01_File/template/utf8.txt', 'utf8');
    is $file->name, 't/01_File/template/utf8.txt', 'right file name';
    is $file->content, 'あ', 'right content';
    is $file->detected_encoding, 'utf8', 'right encoding';
    
    $file = Text::PSTemplate::File->new('t/01_File/template/cp932.txt', 'cp932');
    is $file->name, 't/01_File/template/cp932.txt', 'right file name';
    is $file->content, 'あ', 'right content';
    is $file->detected_encoding, 'cp932', 'right encoding';
    
    $file = Text::PSTemplate::File->new('t/01_File/template/utf8.txt', ['cp932','utf8']);
    is $file->name, 't/01_File/template/utf8.txt', 'right file name';
    is $file->content, 'あ', 'right file name';
    is $file->detected_encoding, 'utf8', 'right encoding detected';
    
    $file = Text::PSTemplate::File->new('t/01_File/template/cp932.txt', ['cp932','utf8']);
    is $file->name, 't/01_File/template/cp932.txt', 'right file name';
    is $file->content, 'あ', 'right content';
    is $file->detected_encoding, 'cp932', 'right encoding detected';
    
    $file = Text::PSTemplate::File->new('t/01_File/template/utf8.txt', ['utf8', 'cp932']);
    is $file->name, 't/01_File/template/utf8.txt', 'right file name';
    is $file->content, 'あ', 'right content';
    is $file->detected_encoding, 'utf8', 'right encoding detected';
    
    $file = Text::PSTemplate::File->new('t/01_File/template/cp932.txt', ['utf8', 'cp932']);
    is $file->name, 't/01_File/template/cp932.txt', 'right file name';
    is $file->content, 'あ', 'right content';
    is $file->detected_encoding, 'cp932', 'right encoding detected';
