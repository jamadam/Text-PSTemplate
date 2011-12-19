package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 3;
    
    my $tpl;
    my $tpl2;
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_var(a => undef);
    is($tpl->var('a'), undef, 'right value in variable');
    
    $tpl = Text::PSTemplate->new();
    $tpl2 = Text::PSTemplate->new($tpl);
    $tpl->set_var(a => 'a');
    $tpl2->set_var(a => undef);
    is($tpl->var('a'), 'a', 'right value in variable');
    is($tpl2->var('a'), 'a', 'right value in variable');

__END__
