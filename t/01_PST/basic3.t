package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub var_undef : Test {
        
        my $tpl = Text::PSTemplate->new();
		$tpl->set_var(a => undef);
		is($tpl->var('a'), undef);
    }
    
    sub var_undef2 : Test(2) {
        
        my $tpl = Text::PSTemplate->new();
		my $tpl2 = Text::PSTemplate->new($tpl);
		$tpl->set_var(a => 'a');
		$tpl2->set_var(a => undef);
		is($tpl->var('a'), 'a');
		is($tpl2->var('a'), 'a');
    }

__END__
