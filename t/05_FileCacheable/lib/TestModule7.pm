package TestModule7;
use strict;
use warnings;
use base 'Text::PSTemplate::PluginBase';
    
    my $method1_count = 0;
    
    sub get_method1_count {
        return $method1_count;
    }
    
    sub method1 : FileCacheable {
        my $self = shift;
        $method1_count++;
    }
    
    sub file_cache_options {
        my $self = shift;
        return {
            namespace => 'Test',
            cache_root => 't/05_FileCacheable/cache',
            default_key => $self->{url},
        };
    }
	
	sub file_cache_expire {
		my ($self, $timestamp) = (@_);
		if (time() - $timestamp >= 3) {
			return 1;
		}
	}

1;
