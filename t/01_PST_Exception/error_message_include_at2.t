package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 8;
    
    my $tpl;
    
    $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at2_1.txt');
    };
    like($@, qr{t/01_PST_Exception/template/error_message_include_at2_1.txt line 4});
    is((() = $@ =~ / at /g), 1);
    
    $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at2_2.txt');
    };
    like($@, qr{t/01_PST_Exception/template/error_message_include_at2_2.txt line 7});
    is((() = $@ =~ / at /g), 1);
    
    $tpl = Text::PSTemplate->new;
    eval {
        $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at2_3.txt');
    };
    like($@, qr{t/01_PST_Exception/template/error_message_include_at2_3.txt line 5});
    is((() = $@ =~ / at /g), 1);
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('_Test', '');
    eval {
        $tpl->parse_file('t/01_PST_Exception/template/error_message_include_at2_4.txt');
    };
    like($@, qr{t/01_PST_Exception/template/error_message_include_at2_4.txt line 2});
    is((() = $@ =~ / at /g), 1);

package _Test;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use Text::PSTemplate;
    
    ### ---
    ### Parse inline template if the variable is in array
    ### ---
    sub test : TplExport {
        
        my ($self, $target, $array_ref, $then, $else) = @_;
        
        my $tpl = Text::PSTemplate->new;
        
        return $tpl->parse_block(0, {chop_left => 1, chop_right => 1});
        return;
    }

__END__
