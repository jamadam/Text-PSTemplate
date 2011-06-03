use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugin::Time2::DateTime;
use Text::PSTemplate::Plugin::Time2;

    __PACKAGE__->runtests;
    
    sub timelocal : Test(3) {
        {
            my $a = Text::PSTemplate::Plugin::Time2::DateTime::_timelocal(1,1,1,1,13,2011);
            my @b = Text::PSTemplate::Plugin::Time2::DateTime::_localtime($a);
            is(join(',', @b[0..5]), '1,1,1,1,1,2012');
        }
        {
            my $a = Text::PSTemplate::Plugin::Time2::DateTime::_timelocal(1,1,1,32,12,2011);
            my @b = Text::PSTemplate::Plugin::Time2::DateTime::_localtime($a);
            is(join(',', @b[0..5]), '1,1,1,1,1,2012');
        }
        {
            my $a = Text::PSTemplate::Plugin::Time2::DateTime::_timelocal(1,1,1,32,13,2011);
            my @b = Text::PSTemplate::Plugin::Time2::DateTime::_localtime($a);
            is(join(',', @b[0..5]), '1,1,1,1,2,2012');
        }
    }
    
    sub add : Test(7) {
        
        my $a = Text::PSTemplate::Plugin::Time2::DateTime->parse('2011-01-01 12:13:14');
        is($a->add(years => 1)->strftime('%Y-%m-%d %H:%M:%S'), '2012-01-01 12:13:14');
        is($a->add(months => 1)->strftime('%Y-%m-%d %H:%M:%S'), '2012-02-01 12:13:14');
        is($a->add(months => -1)->strftime('%Y-%m-%d %H:%M:%S'), '2012-01-01 12:13:14');
        is($a->add(months => 10)->strftime('%Y-%m-%d %H:%M:%S'), '2012-11-01 12:13:14');
        is($a->add(months => 1)->strftime('%Y-%m-%d %H:%M:%S'), '2012-12-01 12:13:14');
        is($a->add(months => 1)->strftime('%Y-%m-%d %H:%M:%S'), '2013-01-01 12:13:14');
        is($a->add(hours => -13)->strftime('%Y-%m-%d %H:%M:%S'), '2012-12-31 23:13:14');
    }
    
    sub constractor : Test(21) {
        
        my $epoch = 1293851594;
        my $a = Text::PSTemplate::Plugin::Time2::DateTime->from_epoch(epoch => $epoch);
        is($a->epoch, 1293851594);
        is($a->year, 2011);
        is($a->month, 1);
        is($a->day, 1);
        is($a->hour, 12);
        is($a->minute, 13);
        is($a->second, 14);
        is($a->ymd, '2011-01-01');
        is($a->ymd('/'), '2011/01/01');
        is($a->iso8601, '2011-01-01 12:13:14');
        is($a->day_of_week, 6);
        is($a->day_of_year, 0);
        is($a->day_name, 'Saturday');
        is($a->month_name, 'January');
        is($a->day_abbr, 'Sat');
        is($a->month_abbr, 'Jan');
        is($a->year_abbr, '11');
        is($a->am_or_pm, 'PM');
        is($a->hour_12_0, 0);
        is($a->is_leap_year, '');
        is($a->strftime('%Y-%m-%d %H:%M:%S'), '2011-01-01 12:13:14');
    }
    
    sub constractor2 : Test(1) {
        
        is(Text::PSTemplate::Plugin::Time2::DateTime->new(year => 2011, month => 12, day => 1)->iso8601, '2011-12-01 00:00:00');
    }
    
    sub parse : Test(20) {
        
        my $a = Text::PSTemplate::Plugin::Time2::DateTime->parse('2011-01-01 12:13:14');
        is($a->epoch, 1293851594);
        is($a->year, 2011);
        is($a->month, 1);
        is($a->day, 1);
        is($a->hour, 12);
        is($a->minute, 13);
        is($a->second, 14);
        is($a->ymd, '2011-01-01');
        is($a->ymd('/'), '2011/01/01');
        is($a->iso8601, '2011-01-01 12:13:14');
        is($a->day_of_week, 6);
        is($a->day_of_year, 0);
        is($a->day_name, 'Saturday');
        is($a->month_name, 'January');
        is($a->day_abbr, 'Sat');
        is($a->month_abbr, 'Jan');
        is($a->year_abbr, '11');
        is($a->hour_12_0, 0);
        is($a->is_leap_year, '');
        is($a->strftime('%Y-%m-%d %H:%M:%S'), '2011-01-01 12:13:14');
    }
    
    sub parse_zero_padding : Test(8) {
        
        my $a = Text::PSTemplate::Plugin::Time2::DateTime->parse('2011-01-01 02:03:04');
        is($a->hour, 2);
        is($a->minute, 3);
        is($a->second, 4);
        is($a->ymd, '2011-01-01');
        is($a->ymd('/'), '2011/01/01');
        is($a->iso8601, '2011-01-01 02:03:04');
        is($a->hour_12_0, 2);
        is($a->strftime('%Y-%m-%d %H:%M:%S'), '2011-01-01 02:03:04');
    }
    
    sub now : Test(1) {
        
        my $a = Text::PSTemplate::Plugin::Time2->now();
        my @d = localtime(time);
        my $expect = sprintf('%04s-%02s-%02s %02s:%02s:%02s', $d[5] + 1900,$d[4] + 1,$d[3],$d[2],$d[1],$d[0]);
        is($a, $expect);
    }
    
    sub strftime : Test(1) {
        
        my $a = Text::PSTemplate::Plugin::Time2->strftime('2011/01/01 12:13:14', '%Y-%m-%d %H:%M:%S');
        is($a, '2011-01-01 12:13:14');
    }
    
    sub before : Test(2) {
        
        my $a = Text::PSTemplate::Plugin::Time2->before('2011/01/01 12:13:14', '2011/01/01 12:13:15');
        is($a, 1);
        my $b = Text::PSTemplate::Plugin::Time2->before('2011/01/01 12:13:14', '2011/01/01 12:13:13');
        is($b, undef);
    }
