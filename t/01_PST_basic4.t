package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub make_sure_non_mother_template_member_not_set : Test(2) {
        
        my $tpl = Text::PSTemplate->new();
		is($tpl->{2}, '<%');
        my $tpl2 = Text::PSTemplate->new($tpl);
		is($tpl2->{2}, undef);
    }
    
    sub make_sure_non_mother_template_member_not_set2 : Test(1) {
        
        my $tpl = Text::PSTemplate->new();
		$tpl->set_func(test => sub {
			my $tpl2 = Text::PSTemplate->new();
			is($tpl2->{2}, undef);
		});
		$tpl->parse('<% test() %>');
    }
    
    sub make_sure_non_mother_template_member_not_set3 : Test(1) {
        
        my $tpl = Text::PSTemplate->new();
		$tpl->set_func(test => sub {
			my $tpl2 = Text::PSTemplate->new(undef);
			is($tpl2->{2}, '<%');
		});
		$tpl->parse('<% test() %>');
    }

__END__
