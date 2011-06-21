use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use base 'Test::Class';
use Test::More;
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
