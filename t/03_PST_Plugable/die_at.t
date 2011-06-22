use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;

    __PACKAGE__->runtests;
    
    sub die_in_plugin : Test(2) {
        
        my $tpl = Text::PSTemplate->new;
		$tpl->plug('Test::_Plugin','');
		my $parsed = eval {
			$tpl->parse_file('t/03_PST_Plugable/template/PST_die_at.txt');
		};
        like($@, qr/PST_die_at.txt/);
        like($@, qr/ERROR/);
    }

package Test::_Plugin;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);

    sub test : TplExport {
		
		my $self = shift;
		die 'ERROR';
    }
