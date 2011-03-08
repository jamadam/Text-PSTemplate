package PST_Plugable_require_ok3_1;
use strict;
use warnings;
use base qw(PST_Plugable_require_ok3);

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

	sub internal_use {
		shift->next::method();
	}

1;
