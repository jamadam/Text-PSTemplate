package TestModule3;
use strict;
use warnings;
use base 'Text::PSTemplate::PluginBase';
    
    sub sub1 : FileCacheable {
        my $class = shift;
        return shift;
    }

    sub get_class : FileCacheable {
        return shift;
    }

    sub get_instance : FileCacheable {
        return shift;
    }
    
    sub file_cache_expire {
        return 0;
    }
    
    sub file_cache_options {
        return {
            'namespace' => 'Test',
            'cache_root' => 't/cache',
        };
    }

1;
