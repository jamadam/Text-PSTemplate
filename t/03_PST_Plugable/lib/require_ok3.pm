package require_ok3;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use Class::C3;
	
	sub internal_use {
		
		return 'a';
	}
	
    sub test : TplExport {
    }


1;
