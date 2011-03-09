package PST_Plugable_require_ok3_1;
use strict;
use warnings;
use base qw(PST_Plugable_require_ok3);

	sub file_cache_options {
		return {
			namespace => 'Test',
			cache_root => 't/cache',
		}
	}
	
	sub internal_use : FileCacheable {
		shift->next::method();
	}

package _Test::_Sub3;
use strict;
use warnings;
use base qw(PST_Plugable_require_ok3);

	sub internal_use {
		'b';
	}

package _Test::_Sub2;
use strict;
use warnings;
use base qw(PST_Plugable_require_ok3_1 _Test::_Sub3);

1;
