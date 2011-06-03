package Text::PSTemplate::DateTime;
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
        
        my ($class, %args) = @_;
        if (scalar @_ == 1) {
            return bless {
                epoch => time,
                parts => [],
                asset => [$months, $wdays]
            }, $class;
        } else {
            my @parts = (
                $args{second}, $args{minute}, $args{hour},
                $args{day}, $args{month}, $args{year}
            );
            return bless {
                epoch => _timelocal(@parts),
                parts => [],
                asset => [$months, $wdays]
            }, $class;
        }
    }
    
    sub from_epoch {
        
        my ($class, %args) = @_;
        return bless {
            epoch => $args{epoch},
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
    
    sub add {
        my ($self, %args) = @_;
        my %new_args = (
            year    => $self->year,
            month   => $self->month,
            day     => $self->day,
            hour    => $self->hour,
            minute  => $self->minute,
            second  => $self->second,
        );
        if ($args{years}) {
            $new_args{year} += $args{years};
        }
        if ($args{months}) {
            $new_args{month} += $args{months};
        }
        if ($args{days}) {
            $new_args{day} += $args{days};
        }
        if ($args{hours}) {
            $new_args{hour} += $args{hours};
        }
        if ($args{minutes}) {
            $new_args{minute} += $args{minutes};
        }
        if ($args{seconds}) {
            $new_args{second} += $args{seconds};
        }
        %$self = %{(ref $self)->new(%new_args)};
        return $self;
    }
    
    my $_strftime_tbl = {
        a => sub {$_[0]->day_abbr},
        A => sub {$_[0]->day_name},
        b => sub {$_[0]->month_abbr},
        B => sub {$_[0]->month_name},
        c => sub {'not implemented yet'},
        C => sub {'not implemented yet'},
        d => sub {sprintf('%02d', $_[0]->day)},
        D => sub {'not implemented yet'},
        e => sub {'not implemented yet'},
        f => sub {'not implemented yet'},
        F => sub {'not implemented yet'},
        g => sub {'not implemented yet'},
        G => sub {'not implemented yet'},
        h => sub {'not implemented yet'},
        H => sub {sprintf('%02d', $_[0]->hour)},
        I => sub {sprintf('%02d', $_[0]->hour_12_0)},
        j => sub {sprintf('%03d', $_[0]->day_of_year)},
        k => sub {sprintf('%02d', $_[0]->hour)},
        l => sub {sprintf('%02d', $_[0]->hour_12_0)},
        m => sub {sprintf('%02d', $_[0]->month)},
        M => sub {sprintf('%02d', $_[0]->minute)},
        n => sub {'not implemented yet'},
        N => sub {'not implemented yet'},
        p => sub {$_[0]->am_or_pm},
        P => sub {lc $_[0]->am_or_pm},
        r => sub {'not implemented yet'},
        R => sub {'not implemented yet'},
        s => sub {$_[0]->epoch},
        S => sub {sprintf('%02d', $_[0]->second)},
        t => sub {'not implemented yet'},
        T => sub {'not implemented yet'},
        u => sub {$_[0]->day_of_week},
        U => sub {'not implemented yet'},
        V => sub {'not implemented yet'},
        w => sub {'not implemented yet'},
        W => sub {'not implemented yet'},
        x => sub {'not implemented yet'},
        X => sub {'not implemented yet'},
        y => sub {$_[0]->year_abbr},
        Y => sub {$_[0]->year},
        z => sub {'not implemented yet'},
        Z => sub {'not implemented yet'},
        '%' => sub {'not implemented yet'},
    };
    
    sub strftime {
        
        my ($self, $format) = @_;
        $format ||= '%04s-%02s-%02s %02s:%02s:%02s';
        $format =~ s{%(.)}{
            if (exists $_strftime_tbl->{$1}) {
                $_strftime_tbl->{$1}->($self);
            } else {
                '%'.$1;
            }
        }ge;
        return $format;
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
        $sec ||= 0;
        $minute ||= 0;
        $hour ||= 0;
        $date = ! defined $date ? 1 : $date; # $date must be 1..31
        $date--;
        $month = ! defined $month ? 1 : $month; # $month must be 1..12
        $month--;
        
        ($minute, $sec) = _carry($minute, $sec, 60);
        ($hour, $minute) = _carry($hour, $minute, 60);
        ($date, $hour) = _carry($date, $hour, 24);
        ($year, $month) = _carry($year, $month, 12);
        
        my $ret = eval {
            timelocal($sec, $minute, $hour, 1, $month, $year - 1900);
        };
        if ($@ && $@ =~ 'Day too big') {
            warn 'Date overflow';
            return '4458326400'; # I know this is bull shit
        }
        $ret += $date * 86400;
        return $ret;
    }
    
    sub _carry {
        
        my ($super, $sub, $limit) = @_;
        if ($sub >= 0) {
            $super += int($sub / $limit);
            $sub = $sub % $limit;
        } else {
            my $tmp = abs($sub) - 1;
            $super -= (int($tmp / $limit) + 1);
            $sub = $limit - (($tmp) % $limit + 1);
        }
        return ($super, $sub);
    }
    
    sub last_day_of_month {
        my ($class, %args) = @_;
        my $self = $class->new(year => $args{year}, month => $args{month} + 1);
        $self->add(days => -1);
    }
    
    my @_normal = (31,30,31,30,31,30,31,31,30,31,30,31);
    my @_leaped = (31,28,31,30,31,30,31,31,30,31,30,31);
    
    sub _day_count {
        
        my ($year, $month) = @_;
        return
            _is_leap_year($year)
                ? $_leaped[($month % 12) - 1] : $_normal[($month % 12) - 1];
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

Text::PSTemplate::DateTime - Time Utility

=head1 SYNOPSIS
    
=head1 DESCRIPTION

Pure perl DateTime Class

=head1 Method

=head2 new

=head2 parse

=head2 from_epoch

=head2 strftime

=head2 set_month_asset

=head2 set_weekday_asset

=head2 add

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
