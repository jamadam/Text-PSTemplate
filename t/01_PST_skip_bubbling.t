use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;
    
    __PACKAGE__->runtests;
	
    sub bubbling : Test(3) {
        
        my $tpl1 = Text::PSTemplate->new;
		my $tpl2 = Text::PSTemplate->new($tpl1);
		my $tpl3 = Text::PSTemplate->new($tpl2);
		is($tpl2->mother, $tpl1);
		is($tpl3->mother, $tpl2);
		$tpl2->bypass_mother_search;
		is($tpl3->mother, $tpl1);
    }
