package RequireOk;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
	
	sub some_func : TplExport {
		return 'some_func called';
	}
1;
