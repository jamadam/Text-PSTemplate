package PST_Plugable_require_ok;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
    
	our $global = 'test';
	
    sub extend : TplExport {
        my ($self) = @_;
		my $block = Text::PSTemplate::get_block(0);
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('PST_Plugable_require_ok::_Sub', '');
		$tpl->parse($block);
    }

package PST_Plugable_require_ok::_Sub;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
    
    sub block : TplExport {
        'block';
    }
