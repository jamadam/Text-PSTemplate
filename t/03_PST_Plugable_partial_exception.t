use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;

    __PACKAGE__->runtests;
    
    sub include_file_include_error : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		eval {
			$tpl->parse_file('t/template/03_PST_Plugable_partial_exception1.t');
		};
		like($@, qr/undefined/);
    }
