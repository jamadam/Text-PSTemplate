package Template_Basic;
use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 1;
    
    my $tpl_m = Text::PSTemplate->new;
    my $tpl = Text::PSTemplate->new($tpl_m);
    $tpl->set_var_exception(sub {''});
    my $parsed = $tpl->parse(q!a<% $title %>b!);
    is($parsed, 'ab');
