package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub line_number : Test(1) {
        
        my $num = Text::PSTemplate::Exception::_line_number("1\n2\n3\n", 4);
        is($num, '3');
    }
    
    sub line_number2 : Test(1) {
        
        my $num = Text::PSTemplate::Exception::_line_number("1       \r\n  2    \r\n   3    \r\n", 20);
        is($num, '3');
    }
    
    sub line_number3 : Test(1) {
        
        my $num = Text::PSTemplate::Exception::_line_number("1       \n  2    \n   3    \n", 20);
        is($num, '3');
    }
    
    sub pos_omitted : Test(1) {
        
        my $num = Text::PSTemplate::Exception::_line_number("1       \n  2    \n   3    \n");
        is($num, '4');
    }

__END__
