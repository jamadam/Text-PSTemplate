package Text::PSTemplate::Plugin::Time2::DateTime;
use strict;
use warnings;
use Time::Local;
use Carp;
    
    my $months  =
        [qw(January February March April May June July August
        September October November December)];
    
    my $wdays   =
        [qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday)];
    
    my $format = '%04s-%02s-%02s %02s:%02s:%02s';
    
    sub new {
        
        my ($class, $epoch) = @_;
        $epoch ||= time;
        return bless {
            epoch => $epoch,
            parts => [],
            asset => [$months, $wdays]
        }, $class;
    }
    
    sub parse {
        
        my ($class, $str) = @_;
        my @a = map {$_ + 0} _split_date($str);
        my $epoch = _timelocal(@a);
        return bless {
            epoch => $epoch,
            parts => \@a,
            asset => [$months, $wdays]
        }, $class;
    }
    
    sub set_month_asset {
        my ($self, $asset) = @_;
        $self->{asset}->[0] = $asset;
    }
    
    sub set_weekday_asset {
        my ($self, $asset) = @_;
        $self->{asset}->[1] = $asset;
    }
    
    sub epoch {
        my $self = shift;
        return $self->{epoch};
    }
    
    sub ymd {
        
        my ($self, $delim) = @_;
        $delim ||= '-';
        my (undef, undef, undef, $mday, $mon, $year) = _localtime($self->{epoch});
        return sprintf("%04d$delim%02d$delim%02d", $year, $mon, $mday);
    }
    
    ### ---
    ### 2000-01-01 23:23:23
    ### ---
    sub iso8601 {
        
        my ($self) = @_;
        my ($sec, $min, $hour, $mday, $mon, $year) = _localtime($self->{epoch});
        return sprintf($format, $year, $mon, $mday, $hour, $min, $sec);
    }
    
    sub year {
        my ($self) = @_;
        if (! $self->{parts}->[5]) {
            $self->{parts} = [_localtime($self->{epoch})];
        }
        return $self->{parts}->[5];
    }
    
    sub month {
        my ($self) = @_;
        if (! $self->{parts}->[4]) {
            $self->{parts} = [_localtime($self->{epoch})];
        }
        return $self->{parts}->[4];
    }
    
    sub day {
        my ($self) = @_;
        if (! $self->{parts}->[3]) {
            $self->{parts} = [_localtime($self->{epoch})];
        }
        return $self->{parts}->[3];
    }
    
    sub hour {
        my ($self) = @_;
        if (! $self->{parts}->[2]) {
            $self->{parts} = [_localtime($self->{epoch})];
        }
        return $self->{parts}->[2];
    }
    
    sub minute {
        my ($self) = @_;
        if (! $self->{parts}->[1]) {
            $self->{parts} = [_localtime($self->{epoch})];
        }
        return $self->{parts}->[1];
    }
    
    sub second {
        my ($self) = @_;
        if (! $self->{parts}->[0]) {
            $self->{parts} = [_localtime($self->{epoch})];
        }
        return $self->{parts}->[0];
    }
    
    sub day_of_week {
        my ($self) = @_;
        if (! $self->{parts}->[6]) {
            $self->{parts} = [_localtime($self->{epoch})];
        }
        return $self->{parts}->[6];
    }
    
    sub day_of_year {
        my ($self) = @_;
        if ($self->{parts}->[7]) {
            $self->{parts} = [_localtime($self->{epoch})];
        }
        return $self->{parts}->[7];
    }
    
    sub month_name {
        my $self = shift;
        return $self->{asset}->[0]->[$self->month - 1];
    }
    
    sub month_abbr {
        my $self = shift;
        return substr($self->month_name, 0, 3)
    }
    
    sub day_name {
        my $self = shift;
        $self->{asset}->[1]->[$self->day_of_week];
    }
    
    sub day_abbr {
        my $self = shift;
        return substr($self->day_name, 0, 3)
    }
    
    sub year_abbr {
        my $self = shift;
        return substr($self->year, 2, 2);
    }
    
    sub am_or_pm {
        my $self = shift;
        return $self->hour < 12 ? 'AM' : 'PM'
    }
    
    sub hour_12_0 {
        my $self = shift;
        my $hour = $self->hour;
        return $hour < 12 ? $hour : $hour - 12,    
    }
    
    sub is_leap_year {
        my $self = shift;
        _is_leap_year($self->year);
    }
    
    ### ---
    ### Split any date string to array
    ### ---
    sub _split_date {
        
        my ($date) = @_;
        if (! $date) {
            return;
        }
        if ($date =~ qr{^(\d{4})([\./-]?)(\d\d?)(?:\2(\d\d?)(?:( |T|\2)(\d\d?)([:-]?)(\d\d?)(?:\7(\d\d?)(\.\d+)?)?([\+\-]\d\d:?\d\d)?Z?)?)?$}) {
            return ($9 or 0), ($8 or 0), ($6 or 0), ($4 or 1), ($3 or 1), $1;
        }
        croak "Invalid date format: $date";
    }
    
    ### ---
    ### custom localtime
    ### ---
    sub _localtime {
        my ($epoch) = @_;
        my @t = localtime($epoch || time);
        $t[5] += 1900;
        $t[4] += 1;
        return @t;
    }
    
    ### ---
    ### Flexible timelocal wrapper
    ### ---
    sub _timelocal {
        
        my ($sec, $minute, $hour, $date, $month, $year) = @_;
        $minute += int($sec / 60);
        $sec     = $sec % 60;
        $hour   += int($minute / 60);
        $minute  = $minute % 60;
        $date   += int($hour / 24);
        $hour    = $hour % 24;
        
        my $lastday = _day_count($year, $month);
        
        $month = ($date > $lastday) ? $month + 1 : $month;
        $date  = ($date > $lastday) ? $date - $lastday : $date;
        
        $year += int($month / 12);
        $month = $month % 12;
        
        my $ret = eval{
            timelocal($sec, $minute, $hour, $date, $month - 1, $year - 1900);
        };
        if ($@ && $@ =~ 'Day too big') {
            warn 'Date overflow';
            return '4458326400'; # I know this is bull shit
        }
        return $ret;
    }
    
    my @_normal = (31,30,31,30,31,30,31,31,30,31,30,31);
    my @_leaped = (31,28,31,30,31,30,31,31,30,31,30,31);
    
    sub _day_count {
        
        my ($year, $month) = @_;
        return _is_leap_year($year) ? $_leaped[$month] : $_normal[$month];
    }
    
    sub _is_leap_year {
    
        return(
            ($_[0]% 400 == 0 )
            or
            (
                ($_[0] % 100 != 0)
                and
                ($_[0] % 4 == 0)
            )
        );
    }

1;

__END__

=head1 NAME

Text::PSTemplate::Plugin::Time2::DateTime - Time Utility [Experimental]

=head1 SYNOPSIS
    
=head1 DESCRIPTION

Pure perl DateTime Class

=head1 Method

=head2 new

=head2 parse

=head2 set_month_asset

=head2 set_weekday_asset

=head2 epoch

=head2 ymd

=head2 iso8601

=head2 year

=head2 month

=head2 day

=head2 hour

=head2 minute

=head2 second

=head2 day_of_week

=head2 day_of_year

=head2 month_name

=head2 month_abbr

=head2 day_name

=head2 day_abbr

=head2 year_abbr

=head2 am_or_pm

=head2 hour_12_0

=head2 is_leap_year

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
