package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 16;
    
    my $tpl;
    my $tpl2;
    my $tpl3;
    
    $tpl = Text::PSTemplate->new;
    $tpl2 = Text::PSTemplate->new($tpl);
    is(ref $tpl2, 'Text::PSTemplate');
    isnt($tpl2, $tpl);
    is($tpl2->get_current_parser, $tpl);
        
    $tpl = PST2->new;
    $tpl2 = PST2->new($tpl);
    is(ref $tpl2, 'PST2');
    isnt($tpl2, $tpl);
    is($tpl2->get_current_parser, $tpl);
    
    $tpl = PST2->new;
    $tpl2 = PST2->new($tpl);
    is(ref $tpl2, 'PST2');
    isnt($tpl2, $tpl);
    is($tpl2->get_current_parser, $tpl);
    
    $tpl = PST2->new;
    $tpl2 = Text::PSTemplate->new($tpl);
    is(ref $tpl2, 'Text::PSTemplate');
    isnt($tpl2, $tpl);
    is($tpl2->get_current_parser, $tpl);
    
    $tpl = PST2->new;
    $tpl3 = PST3->new;
    $tpl2 = PST3->new($tpl);
    is(ref $tpl2, 'PST3');
    isnt($tpl2, $tpl);
    isnt($tpl2, $tpl3);
    is($tpl2->get_current_parser, $tpl);

package PST2;
use strict;
use warnings;
use base qw(Text::PSTemplate);

package PST3;
use strict;
use warnings;
use base qw(Text::PSTemplate);
