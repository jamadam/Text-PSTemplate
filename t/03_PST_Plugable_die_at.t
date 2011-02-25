use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;

    __PACKAGE__->runtests;
    
    sub die_in_plugin : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		$tpl->plug('Test::_Plugin','');
		my $parsed = eval {
			$tpl->parse_file('t/template/01_PST_die_at.txt');
		};
        like($@, qr/01_PST_die_at.txt/);
    }

package Test::_Plugin;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);

    sub test : TplExport {
		
		my $self = shift;
		$self->die('ERROR');
    }