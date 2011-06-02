use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Text::PSTemplate::Plugin::Time2::DateTime;
use Text::PSTemplate::Plugin::Time2;

    __PACKAGE__->runtests;
    
    sub constractor : Test(20) {
        
        my $epoch = 1293851594;
        my $a = Text::PSTemplate::Plugin::Time2::DateTime->new($epoch);
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
    }
    
    sub parse : Test(19) {
        
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
    }
    
    sub now : Test(1) {
        
        my $a = Text::PSTemplate::Plugin::Time2->now();
        my @d = localtime(time);
        my $expect = sprintf('%04s-%02s-%02s %02s:%02s:%02s', $d[5] + 1900,$d[4] + 1,$d[3],$d[2],$d[1],$d[0]);
        is($a, $expect);
    }
    
    sub reformat : Test(1) {
        
        my $a = Text::PSTemplate::Plugin::Time2->reformat('2011/01/01 12:13:14');
        is($a, '2011-01-01 12:13:14');
    }
    
    sub before : Test(2) {
        
        my $a = Text::PSTemplate::Plugin::Time2->before('2011/01/01 12:13:14', '2011/01/01 12:13:15');
        is($a, 1);
        my $b = Text::PSTemplate::Plugin::Time2->before('2011/01/01 12:13:14', '2011/01/01 12:13:13');
        is($b, undef);
    }
