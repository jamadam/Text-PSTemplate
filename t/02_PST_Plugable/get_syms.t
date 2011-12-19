use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 1;
    
    my $tpl = Text::PSTemplate->new;
    my $plug = eval {
        $tpl->plug('_Test');
    };
    is($@, '');

package _Test;
use strict;
use warnings;
use base 'Text::PSTemplate::PluginBase';
use Fcntl qw(:flock);
use Carp;

    sub hoge : TplExport {
        
    }
