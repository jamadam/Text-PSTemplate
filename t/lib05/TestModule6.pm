package TestModule6;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use LWP::Simple;
    
    my $lwp_count = 0;
    
    sub get_lwp_count {
        return $lwp_count;
    }
    
    sub get_url : FileCacheable {
        my ($self, $url) = @_;
        $lwp_count++;
        return LWP::Simple::get($url);
    }
    
    sub file_cache_options {
        my $self = shift;
        return {
            namespace => 'Test',
            cache_root => 't/cache',
            default_key => $self->{url},
        };
    }

1;
