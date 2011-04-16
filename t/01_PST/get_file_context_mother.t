use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;
    
    __PACKAGE__->runtests;
	
    sub get_current_file_parser : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
		$tpl->set_func(a => sub {
			my $tpl2 = Text::PSTemplate::get_current_file_parser;
			is($tpl2, $tpl);
			return 'ok';
		});
		$tpl->parse_file('t/01_PST/template/get_file_context_mother.txt');
		
		$tpl->set_func(include => sub {
			my $tpl2 = Text::PSTemplate->new;
			return $tpl2->parse_file($_[0]);
		});
		$tpl->parse_file('t/01_PST/template/get_file_context_mother2.txt');
    }