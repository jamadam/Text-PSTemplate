package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugable;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub var_exception_for_child_tpl_detected : Test {
        
        my $tpl_m = Text::PSTemplate->new;
        my $tpl = Text::PSTemplate->new($tpl_m);
        $tpl->set_var_exception(sub {''});
        my $parsed = $tpl->parse(q!a<% $title %>b!);
        is($parsed, 'ab');
    }
