use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;

    __PACKAGE__->runtests;
    
    sub ini_c3 : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		_PlugA->set_ini({pkg => '_PlugA'});
		#_PlugB->set_ini({pkg => '_PlugB'});
		_PlugC->set_ini({pkg => '_PlugC'});
		#_PlugD->set_ini({pkg => '_PlugD'});
        $tpl->plug(['_PlugD']);
        my $parsed1 = $tpl->parse(q[<% _PlugD::put_pkg() %>]);
        is($parsed1, '_PlugC');
    }

package _PlugA;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
	
	sub put_pkg : TplExport {
		
		my $plugin = shift;
		return $plugin->ini('pkg');
	}

package _PlugB;
use strict;
use warnings;
use base qw(_PlugA);

package _PlugC;
use strict;
use warnings;
use base qw(_PlugA);

package _PlugD;
use strict;
use warnings;
use base qw(_PlugB _PlugC);
