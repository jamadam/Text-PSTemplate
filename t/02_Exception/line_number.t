package Template_Basic;
use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 4;
    
    my $num;
    
    $num = Text::PSTemplate::Exception::_line_number("1\n2\n3\n", 4);
    is($num, '3');
    
    $num = Text::PSTemplate::Exception::_line_number("1       \r\n  2    \r\n   3    \r\n", 20);
    is($num, '3');
    
    $num = Text::PSTemplate::Exception::_line_number("1       \n  2    \n   3    \n", 20);
    is($num, '3');
    
    $num = Text::PSTemplate::Exception::_line_number("1       \n  2    \n   3    \n");
    is($num, '4');

__END__
