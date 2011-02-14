package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub escape_tag : Test(4) {
        
        my $tpl = Text::PSTemplate->new();
        $tpl->set_var(title => 'TITLE');
        is($tpl->parse(q!{%$title%}!), 'TITLE');
        is($tpl->parse(q!\\{%$title%}!), q!{%$title%}!);
        is($tpl->parse(q!\\\\{%$title%}!), '\\TITLE');
        is($tpl->parse(q!\\\\\\{%$title%}!), '\\{%$title%}');
    }
    
    sub indent_optimize {
        my $in = shift;
        $in =~ s{\s+}{ }g;
        $in =~ s{ $}{};
        return $in;
    }

__END__
