use strict;
use warnings;
use Test::More;
use Text::PSTemplate::DateTime;
use Text::PSTemplate::Plugin::Time2;

	use Test::More tests => 22;
    
    is(join(',', Text::PSTemplate::DateTime::_carry(2011, 11, 12)), '2011,11');
    is(join(',', Text::PSTemplate::DateTime::_carry(2011, 12, 12)), '2012,0');
    is(join(',', Text::PSTemplate::DateTime::_carry(2011, 24, 12)), '2013,0');
    
    is(join(',', Text::PSTemplate::DateTime::_carry(2011, -1, 12)), '2010,11');
    is(join(',', Text::PSTemplate::DateTime::_carry(2011, -13, 12)), '2009,11');
    is(join(',', Text::PSTemplate::DateTime::_carry(2011, -24, 12)), '2009,0');
    is(join(',', Text::PSTemplate::DateTime::_carry(2011, -25, 12)), '2008,11');
    
    is(join(',', Text::PSTemplate::DateTime::_carry(2, 24, 24)), '3,0');
    is(join(',', Text::PSTemplate::DateTime::_carry(2, 23, 24)), '2,23');
    is(join(',', Text::PSTemplate::DateTime::_carry(2, 47, 24)), '3,23');
    is(join(',', Text::PSTemplate::DateTime::_carry(2, 48, 24)), '4,0');
    
    is(join(',', Text::PSTemplate::DateTime::_carry(2, -1, 24)), '1,23');
    is(join(',', Text::PSTemplate::DateTime::_carry(2, -24, 24)), '1,0');
    is(join(',', Text::PSTemplate::DateTime::_carry(2, -25, 24)), '0,23');
    is(join(',', Text::PSTemplate::DateTime::_carry(2, -48, 24)), '0,0');
    is(join(',', Text::PSTemplate::DateTime::_carry(2, -49, 24)), '-1,23');

    my $a;
    my @b;
    
    $a = Text::PSTemplate::DateTime::_timelocal([1,1,1,1,13,2011]);
    @b = Text::PSTemplate::DateTime::_localtime($a);
    is(join(',', @b[0..5]), '1,1,1,1,1,2012');

    $a = Text::PSTemplate::DateTime::_timelocal([1,1,1,32,12,2011]);
    @b = Text::PSTemplate::DateTime::_localtime($a);
    is(join(',', @b[0..5]), '1,1,1,1,1,2012');

    $a = Text::PSTemplate::DateTime::_timelocal([1,1,1,32,13,2011]);
    @b = Text::PSTemplate::DateTime::_localtime($a);
    is(join(',', @b[0..5]), '1,1,1,1,2,2012');

    $a = Text::PSTemplate::DateTime::_timelocal([1,1,1,1,1,2011]);
    @b = Text::PSTemplate::DateTime::_localtime($a);
    is(join(',', @b[0..5]), '1,1,1,1,1,2011');

    $a = Text::PSTemplate::DateTime::_timelocal([1,1,1,0,1,2011]);
    @b = Text::PSTemplate::DateTime::_localtime($a);
    is(join(',', @b[0..5]), '1,1,1,31,12,2010');

    $a = Text::PSTemplate::DateTime::_timelocal([1,1,1,-1,1,2011]);
    @b = Text::PSTemplate::DateTime::_localtime($a);
    is(join(',', @b[0..5]), '1,1,1,30,12,2010');
