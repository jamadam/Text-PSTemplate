use strict;
use warnings;
use Test::More;
use Text::PSTemplate::DateTime;
use Text::PSTemplate::Plugin::Time2;

	use Test::More tests => 84;
    
    is(Text::PSTemplate::DateTime::Catalog::get_offset('Asia/Tokyo'), 32400);
    
    my $a;
    
    $a = Text::PSTemplate::DateTime->parse('2011-01-01 12:13:14');
    is($a->add(years => 1)->strftime('%Y-%m-%d %H:%M:%S'), '2012-01-01 12:13:14');
    is($a->add(months => 1)->strftime('%Y-%m-%d %H:%M:%S'), '2012-02-01 12:13:14');
    is($a->add(months => -1)->strftime('%Y-%m-%d %H:%M:%S'), '2012-01-01 12:13:14');
    is($a->add(months => 10)->strftime('%Y-%m-%d %H:%M:%S'), '2012-11-01 12:13:14');
    is($a->add(months => 1)->strftime('%Y-%m-%d %H:%M:%S'), '2012-12-01 12:13:14');
    is($a->add(months => 1)->strftime('%Y-%m-%d %H:%M:%S'), '2013-01-01 12:13:14');
    is($a->add(hours => -13)->strftime('%Y-%m-%d %H:%M:%S'), '2012-12-31 23:13:14');
    
    my $epoch = 1293851594;
    $a = Text::PSTemplate::DateTime->from_epoch(epoch => $epoch, time_zone => 'Asia/Tokyo');
    is($a->epoch, 1293851594);
    is($a->year, 2011);
    is($a->month, 1);
    is($a->day, 1);
    is($a->hour, 12);
    is($a->minute, 13);
    is($a->second, 14);
    is($a->ymd, '2011-01-01');
    is($a->ymd('/'), '2011/01/01');
    is($a->iso8601(' '), '2011-01-01 12:13:14');
    is($a->day_of_week, 6);
    is($a->day_of_year, 1);
    is($a->day_name, 'Saturday');
    is($a->month_name, 'January');
    is($a->day_abbr, 'Sat');
    is($a->month_abbr, 'Jan');
    is($a->year_abbr, '11');
    is($a->am_or_pm, 'PM');
    is($a->hour_12_0, 0);
    is($a->is_leap_year, 0);
    is($a->strftime('%Y-%m-%d %H:%M:%S'), '2011-01-01 12:13:14');
    
    $a = Text::PSTemplate::DateTime->new(year => 2011, month => 12, day => 1);
    is($a->iso8601(' '), '2011-12-01 00:00:00');
    
    $a = Text::PSTemplate::DateTime->parse('2011-01-01 12:13:14', 'Asia/Tokyo');
    is($a->epoch, 1293851594);
    is($a->year, 2011);
    is($a->month, 1);
    is($a->day, 1);
    is($a->hour, 12);
    is($a->minute, 13);
    is($a->second, 14);
    is($a->ymd, '2011-01-01');
    is($a->ymd('/'), '2011/01/01');
    is($a->iso8601(' '), '2011-01-01 12:13:14');
    is($a->day_of_week, 6);
    is($a->day_of_year, 1);
    is($a->day_name, 'Saturday');
    is($a->month_name, 'January');
    is($a->day_abbr, 'Sat');
    is($a->month_abbr, 'Jan');
    is($a->year_abbr, '11');
    is($a->hour_12_0, 0);
    is($a->is_leap_year, 0);
    is($a->strftime('%Y-%m-%d %H:%M:%S'), '2011-01-01 12:13:14');
    
    $a = Text::PSTemplate::DateTime->parse('2011-01-06 12:13:14', 'Asia/Tokyo');
    is($a->epoch, 1294283594);
    is($a->year, 2011);
    is($a->month, 1);
    is($a->day, 6);
    is($a->hour, 12);
    is($a->minute, 13);
    is($a->second, 14);
    is($a->ymd, '2011-01-06');
    is($a->ymd('/'), '2011/01/06');
    is($a->iso8601(' '), '2011-01-06 12:13:14');
    is($a->day_of_week, 4);
    is($a->day_of_year, 6);
    is($a->day_name, 'Thursday');
    is($a->month_name, 'January');
    is($a->day_abbr, 'Thu');
    is($a->month_abbr, 'Jan');
    is($a->year_abbr, '11');
    is($a->hour_12_0, 0);
    is($a->is_leap_year, 0);
    is($a->strftime('%Y-%m-%d %H:%M:%S'), '2011-01-06 12:13:14');
        
    $a = Text::PSTemplate::DateTime->parse('2011-01-01 02:03:04');
    is($a->hour, 2);
    is($a->minute, 3);
    is($a->second, 4);
    is($a->ymd, '2011-01-01');
    is($a->ymd('/'), '2011/01/01');
    is($a->iso8601(' '), '2011-01-01 02:03:04');
    is($a->hour_12_0, 2);
    is($a->strftime('%Y-%m-%d %H:%M:%S'), '2011-01-01 02:03:04');
    
    my $backup = $ENV{TZ}; $ENV{TZ} = 'Asia/Tokyo';
    $a = Text::PSTemplate::Plugin::Time2->now();
    my @d = localtime(time);
    my $expect = sprintf('%04s-%02s-%02s %02s:%02s:%02s', $d[5] + 1900,$d[4] + 1,$d[3],$d[2],$d[1],$d[0]);
    is($a, $expect);
    $ENV{TZ} = $backup;
    
    $a = Text::PSTemplate::Plugin::Time2->strftime('2011/01/01 12:13:14', '%Y-%m-%d %H:%M:%S');
    is($a, '2011-01-01 12:13:14');
    
    $a = Text::PSTemplate::Plugin::Time2->before('2011/01/01 12:13:14', '2011/01/01 12:13:15');
    is($a, 1);
    my $b = Text::PSTemplate::Plugin::Time2->before('2011/01/01 12:13:14', '2011/01/01 12:13:13');
    is($b, undef);
    
    $a = Text::PSTemplate::DateTime->from_epoch(epoch => 0, time_zone => 'GMT');
    is($a->iso8601(' '), '1970-01-01 00:00:00');
    $a = Text::PSTemplate::DateTime->from_epoch(epoch => 0, time_zone => 'Asia/Tokyo');
    is($a->iso8601(' '), '1970-01-01 09:00:00');
