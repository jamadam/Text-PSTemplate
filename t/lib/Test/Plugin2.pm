package Test::Plugin2;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);

    sub some_function : TplExport {
        
        my $self = shift;
        return 'some_function';
    }

1;
