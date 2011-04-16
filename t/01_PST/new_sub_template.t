package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
	sub basic : Test(3) {
		
        my $tpl = Text::PSTemplate->new;
		my $tpl2 = Text::PSTemplate->new($tpl);
		is(ref $tpl2, 'Text::PSTemplate');
		isnt($tpl2, $tpl);
		is($tpl2->get_current_parser, $tpl);
	}
	
	sub basic2 : Test(3) {
		
        my $tpl = PST2->new;
		my $tpl2 = PST2->new($tpl);
		is(ref $tpl2, 'PST2');
		isnt($tpl2, $tpl);
		is($tpl2->get_current_parser, $tpl);
	}
	
	sub basic3 : Test(3) {
		
        my $tpl = PST2->new;
		my $tpl2 = PST2->new($tpl);
		is(ref $tpl2, 'PST2');
		isnt($tpl2, $tpl);
		is($tpl2->get_current_parser, $tpl);
	}
	
	sub basic4 : Test(3) {
		
        my $tpl = PST2->new;
		my $tpl2 = Text::PSTemplate->new($tpl);
		is(ref $tpl2, 'Text::PSTemplate');
		isnt($tpl2, $tpl);
		is($tpl2->get_current_parser, $tpl);
	}
	
	sub basic5 : Test(4) {
		
        my $tpl = PST2->new;
        my $tpl3 = PST3->new;
		my $tpl2 = PST3->new($tpl);
		is(ref $tpl2, 'PST3');
		isnt($tpl2, $tpl);
		isnt($tpl2, $tpl3);
		is($tpl2->get_current_parser, $tpl);
	}

package PST2;
use strict;
use warnings;
use base qw(Text::PSTemplate);

package PST3;
use strict;
use warnings;
use base qw(Text::PSTemplate);
