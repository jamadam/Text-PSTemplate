use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;

	use Test::More tests => 4;
    
    my $tpl;
    my $var;
    
    $tpl = Text::PSTemplate->new;
    $var = {a => 'b', c => 'd'};
    $tpl->set_var(var => $var);
    is($tpl->parse(q{<% $var->{a} %>}), 'b');
    eval {$tpl->parse(q{<% $var->{e} %>})};
    isnt($@, undef);
    
    $tpl = Text::PSTemplate->new;
    $var = [0,1,2,3];
    $tpl->set_var(var => $var);
    is($tpl->parse(q{<% $var->[3] %>}), '3');
    eval {$tpl->parse(q{<% $var->{4} %>})};
    isnt($@, undef);
