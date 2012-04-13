package Template_Basic;
use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 8;
    
    my $tpl;
    $tpl = Text::PSTemplate->new;
    eval {$tpl->parse_file('does_not_exist')};
    like($@, qr/not found/i);
    like($@, qr{does_not_exist});
    like($@, qr{line 12});
    is((() = $@ =~ / at /g), 1);
    
    $tpl = Text::PSTemplate->new;
    eval {$tpl->get_file('does_not_exist')};
    like($@, qr/not found/i);
    like($@, qr{does_not_exist});
    like($@, qr{line 19});
    is((() = $@ =~ / at /g), 1);

__END__
