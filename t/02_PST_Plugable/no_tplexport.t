use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 1;
    
    my $tpl = Text::PSTemplate->new;
    my $p = $tpl->plug('_Test');
    is($p->some_function, 'ok');

package _Test;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);

    sub some_function {
        
        my $self = shift;
        return 'ok';
    }

1;
