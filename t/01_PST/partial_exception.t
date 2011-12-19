package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 2;
    
    my $tpl = Text::PSTemplate->new;
    eval {$tpl->parse('<% a() %>')};
    like($@, qr/undefined/);
    
    $tpl->set_func(a => sub {
        my $tpl2 = Text::PSTemplate->new;
        $tpl->parse('<% b() %>');
    });
    eval {$tpl->parse('<% a() %>')};
    like($@, qr/undefined/);

package PST2;
use strict;
use warnings;
use base qw(Text::PSTemplate);

package PST3;
use strict;
use warnings;
use base qw(Text::PSTemplate);
