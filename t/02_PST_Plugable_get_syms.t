use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub flock_ok : Test {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        my $plug = eval {
			$tpl->plug('_Test');
		};
		is($@, '');
    }

package _Test;
use strict;
use warnings;
use base 'Text::PSTemplate::PluginBase';
use Fcntl qw(:flock);
use Carp;

	sub hoge : TplExport {
		
	}
