use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 1;
    
    my $p = Test::Plugin1->new;
    is $p->test1('hoge'), 'hoge', 'Plugin testable';

package Test::Plugin1;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
    
    sub test1 : TplExport {
        my ($self, $str) = @_;
        return $str;
    }
