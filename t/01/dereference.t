use strict;
use warnings;
use Test::More;
use Text::PSTemplate;

	use Test::More tests => 4;
    
    my $tpl;
    my $var;
    
    $tpl = Text::PSTemplate->new;
    $var = {a => 'b', c => 'd'};
    $tpl->set_var(var => $var);
    is $tpl->parse(q{<% $var->{a} %>}), 'b', 'right result';
    eval {$tpl->parse(q{<% $var->{e} %>})};
    isnt $@, undef, 'no error';
    
    $tpl = Text::PSTemplate->new;
    $var = [0,1,2,3];
    $tpl->set_var(var => $var);
    is $tpl->parse(q{<% $var->[3] %>}), '3', 'right result';
    eval {$tpl->parse(q{<% $var->{4} %>})};
    isnt $@, undef, 'no error';
