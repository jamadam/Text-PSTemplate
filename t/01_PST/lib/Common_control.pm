package Common_control;
use strict;
use warnings;
use base qw(Text::PSTemplate);
    
    sub new {
        
        my $class = shift;
        my $template = Text::PSTemplate->new();
        $template->set_func(if => \&if);
        $template->set_func(each => \&each);
        return bless $template, $class;
    }
    
    sub if {
        
        my $cond = shift;
        my $then = (Text::PSTemplate::get_block(0) || '');
        my $else = (Text::PSTemplate::get_block(1) || '');
        if ($cond) {
            return $then;
        } else {
            return $else;
        }
    }
    
    sub each {
        
        my ($array, $asign) = (@_);
        my $template = (Text::PSTemplate::get_block(0) || '');
        my $sub = __PACKAGE__->new();
        my $out = '';
        for my $elem (@$array) {
            $sub->set_var($asign => $elem);
            $out .= $sub->parse($template);
        }
        return $out;
    }
1;
