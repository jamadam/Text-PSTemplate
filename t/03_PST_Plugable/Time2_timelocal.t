use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::DateTime;
use Text::PSTemplate::Plugin::Time2;

    __PACKAGE__->runtests;
    
    sub _fix_month_year_add : Test(3) {
        is(join(',', Text::PSTemplate::DateTime::_carry(2011, 11, 12)), '2011,11');
        is(join(',', Text::PSTemplate::DateTime::_carry(2011, 12, 12)), '2012,0');
        is(join(',', Text::PSTemplate::DateTime::_carry(2011, 24, 12)), '2013,0');
    }
    
    sub _fix_month_year_subtract : Test(4) {
        is(join(',', Text::PSTemplate::DateTime::_carry(2011, -1, 12)), '2010,11');
        is(join(',', Text::PSTemplate::DateTime::_carry(2011, -13, 12)), '2009,11');
        is(join(',', Text::PSTemplate::DateTime::_carry(2011, -24, 12)), '2009,0');
        is(join(',', Text::PSTemplate::DateTime::_carry(2011, -25, 12)), '2008,11');
    }
    
    sub fix_date_hour_add : Test(4) {
        is(join(',', Text::PSTemplate::DateTime::_carry(2, 24, 24)), '3,0');
        is(join(',', Text::PSTemplate::DateTime::_carry(2, 23, 24)), '2,23');
        is(join(',', Text::PSTemplate::DateTime::_carry(2, 47, 24)), '3,23');
        is(join(',', Text::PSTemplate::DateTime::_carry(2, 48, 24)), '4,0');
    }
    
    sub fix_date_hour_subract : Test(5) {
        is(join(',', Text::PSTemplate::DateTime::_carry(2, -1, 24)), '1,23');
        is(join(',', Text::PSTemplate::DateTime::_carry(2, -24, 24)), '1,0');
        is(join(',', Text::PSTemplate::DateTime::_carry(2, -25, 24)), '0,23');
        is(join(',', Text::PSTemplate::DateTime::_carry(2, -48, 24)), '0,0');
        is(join(',', Text::PSTemplate::DateTime::_carry(2, -49, 24)), '-1,23');
    }

    sub timelocal : Test(6) {
        {
            my $a = Text::PSTemplate::DateTime::_timelocal([1,1,1,1,13,2011]);
            my @b = Text::PSTemplate::DateTime::_localtime($a);
            is(join(',', @b[0..5]), '1,1,1,1,1,2012');
        }
        {
            my $a = Text::PSTemplate::DateTime::_timelocal([1,1,1,32,12,2011]);
            my @b = Text::PSTemplate::DateTime::_localtime($a);
            is(join(',', @b[0..5]), '1,1,1,1,1,2012');
        }
        {
            my $a = Text::PSTemplate::DateTime::_timelocal([1,1,1,32,13,2011]);
            my @b = Text::PSTemplate::DateTime::_localtime($a);
            is(join(',', @b[0..5]), '1,1,1,1,2,2012');
        }
        {
            my $a = Text::PSTemplate::DateTime::_timelocal([1,1,1,1,1,2011]);
            my @b = Text::PSTemplate::DateTime::_localtime($a);
            is(join(',', @b[0..5]), '1,1,1,1,1,2011');
        }
        {
            my $a = Text::PSTemplate::DateTime::_timelocal([1,1,1,0,1,2011]);
            my @b = Text::PSTemplate::DateTime::_localtime($a);
            is(join(',', @b[0..5]), '1,1,1,31,12,2010');
        }
        {
            my $a = Text::PSTemplate::DateTime::_timelocal([1,1,1,-1,1,2011]);
            my @b = Text::PSTemplate::DateTime::_localtime($a);
            is(join(',', @b[0..5]), '1,1,1,30,12,2010');
        }
    }
