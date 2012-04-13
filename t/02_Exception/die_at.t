use strict;
use warnings;
use Test::More;
use Text::PSTemplate;

	use Test::More tests => 1;
    
    my $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::_Plugin','');
    my $parsed = eval {
        $tpl->parse_file('t/02_Exception/template/die_at.txt');
    };
    like($@, qr{ERROR at t/02_Exception/template/die_at.txt line 1});

package Test::_Plugin;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
    
    sub test : TplExport {
        my $self = shift;
        die 'ERROR';
    }
