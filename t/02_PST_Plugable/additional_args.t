use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub set_namespace : Test(4) {
        
        my $plug;
        my $tpl = Text::PSTemplate::Plugable->new;
        my $plugin = $tpl->plug('Some::Plug');
        $tpl->parse(q{<% Some::Plug::some_func('arg') %>});
    }

package Some::Plug;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use Test::More;
    
    ### Plugin must have a template function
    ### because weaken reduce the empty plugin
    ### This must be a bug.
    sub some_func : TplExport {
        
        my ($self, $context, $controller, $arg) = @_;
        is(ref $self, __PACKAGE__);
        is($context, 'Context');
        is($controller, 'Controller');
        is($arg, 'arg');
    }
    
    sub preceding_args {
        return ('Context', 'Controller');
    }