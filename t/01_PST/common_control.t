package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use lib 't/lib', 't/01_PST/lib';
use Test::More;
use Common_control;
use Data::Dumper;
    
	use Test::More tests => 1;
    
    my $inst = Common_control->new;
    $inst->set_var(var1 => 'value1');
    $inst->set_var(var2 => [3,4,5]);
    my $parsed = $inst->parse(<<'EOF');
<% if($var1 eq 'value1')<<THEN,ELSE %>then<% THEN %>else<% ELSE %>
<% each($var2, 'this')<<SUB %>"<% $this %>" found
<% SUB %>
EOF
    my $expected = <<'EOF';
then
"3" found
"4" found
"5" found

EOF
    is($parsed, $expected);

1;
