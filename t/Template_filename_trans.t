package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
	sub basic : Test {
		
        my $tpl = Text::PSTemplate->new();
		my $a = sub {$_[0]. '.txt'};
		$tpl->set_filename_trans_coderef($a);
		my $str = $tpl->get_file('t/template/Template_filename_trans');
		is($str->content, 'ok');
	}
