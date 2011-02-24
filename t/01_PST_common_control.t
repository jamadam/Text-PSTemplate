package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use PST_common_control;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub if_and_each : Test {
        
		my $inst = PST_common_control->new();
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
    }

1;