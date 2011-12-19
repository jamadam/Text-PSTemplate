package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 4;
    
    my $tpl;
    
    $tpl = Text::PSTemplate->new;
    is $tpl->{2}, '<%', 'right delimiter';
    my $tpl2 = Text::PSTemplate->new($tpl);
    is $tpl2->{2}, undef, 'right delimiter';
    
    $tpl = Text::PSTemplate->new();
    $tpl->set_func(test => sub {
        my $tpl2 = Text::PSTemplate->new();
        is($tpl2->{2}, undef, 'right delimiter');
    });
    $tpl->parse('<% test() %>');
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(test => sub {
        my $tpl2 = Text::PSTemplate->new(undef);
        is($tpl2->{2}, '<%', 'right delimiter');
    });
    $tpl->parse('<% test() %>');

__END__
