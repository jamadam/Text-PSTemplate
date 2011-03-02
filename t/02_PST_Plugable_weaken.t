use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub set_namespace : Test {
        
        my $plug;
        {
            my $tpl = Text::PSTemplate::Plugable->new;
            $plug = $tpl->{pluged};
        }
        is($plug->{'Text::PSTemplate::Plugin::Control'}, undef);
    }
