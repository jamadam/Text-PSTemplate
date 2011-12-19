use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub flock_ok : Test {
        
        my $tpl = Text::PSTemplate->new;
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
