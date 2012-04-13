package Test::Plugin1;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);

    sub some_function : TplExport {
        my $self = shift;
        return 'Test::Plugin1::some_function called';
    }

1;
