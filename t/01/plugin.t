package Template_Basic;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;
use CommonControl;
use Data::Dumper;
    
	use Test::More tests => 1;
    
    my $inst = CommonControl->new;
    $inst->set_var(var1 => 'value1');
    $inst->set_var(var2 => [3,4,5]);

    is($inst->parse(<<'TPL'), <<'EXPECTED');
<% if($var1 eq 'value1')<<THEN,ELSE %>then<% THEN %>else<% ELSE %>
<% each($var2, 'this')<<SUB %>"<% $this %>" found
<% SUB %>
TPL
then
"3" found
"4" found
"5" found

EXPECTED

1;
