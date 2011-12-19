package require_ok3_1;
use strict;
use warnings;
use base qw(require_ok3);
    
    sub file_cache_options {
        return {
            namespace => 'Test',
            cache_root => 't/03_PST_Plugable/cache',
        }
    }
    
    sub internal_use {
        shift->next::method();
    }

package _Test::_Sub3;
use strict;
use warnings;
use base qw(require_ok3);
    
    sub internal_use {
        'b';
    }

package _Test::_Sub2;
use strict;
use warnings;
use base qw(require_ok3_1 _Test::_Sub3);

1;
