use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub no_tplexport : Test {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        my $p = $tpl->plug('_Test');
		is($p->some_function, 'ok');
    }

package _Test;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);

    sub some_function {
        
        my $self = shift;
        return 'ok';
    }

1;
