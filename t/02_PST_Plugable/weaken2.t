use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub set_namespace : Test(3) {
        
        my $plug;
        {
            my $tpl = Text::PSTemplate::Plugable->new;
            $tpl->plug('Some::Plug');
            is(ref $tpl->get_plugin('Some::Plug'), 'Some::Plug');
            is(ref $tpl->get_plugin('Text::PSTemplate::Plugin::Control'), 'Text::PSTemplate::Plugin::Control');
            $plug = $tpl->{pluged};
        }
        is($plug->{'Some::Plug'}, undef);
    }

package Some::Plug;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
    
    ### Plugin must have a template function
    ### because weaken reduce the empty plugin
    ### This must be a bug.
    sub dummy : TplExport {
        
    }