package Template_Basic;
use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 1;
    
    my $tpl = Text::PSTemplate->new();
    my $a = sub {$_[0]. '.txt'};
    $tpl->set_filename_trans_coderef($a);
    my $str = $tpl->get_file('t/01/template/filename_trans');
    is $str->content, 'ok', 'right content';
