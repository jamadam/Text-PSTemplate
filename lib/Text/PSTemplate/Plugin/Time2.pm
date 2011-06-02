package Text::PSTemplate::Plugin::Time2;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use Text::PSTemplate;
use Time::Local;
use Carp;
    
    sub before : TplExport {
        
        my ($self, $date1, $date2, $include_equal) = @_;
        my $ep1 = Text::PSTemplate::Plugin::Time2::DateTime->parse($date1)->epoch;
        my $ep2 = Text::PSTemplate::Plugin::Time2::DateTime->parse($date2)->epoch;
        if (($ep1 < $ep2) || ($include_equal && $ep1 == $ep2)) {
            return 1;
        } else {
            return;
        }
    }
    
    sub after : TplExport {
        
        my ($self, $date1, $date2, $include_equal) = @_;
        my $ep1 = Text::PSTemplate::Plugin::Time2::DateTime->parse($date1)->epoch;
        my $ep2 = Text::PSTemplate::Plugin::Time2::DateTime->parse($date2)->epoch;
        if (($ep1 > $ep2) || ($include_equal && $ep1 == $ep2)) {
            return 1;
        } else {
            return;
        }
    }
    
    ### ---
    ### Reformat time string
    ### ---
    sub reformat : TplExport {
        
        my ($self, $ts, $format, $data, $asset) = @_;
        $format ||= '%04s-%02s-%02s %02s:%02s:%02s';
        $data   ||= [5,4,3,2,1,0,10];
        
        my $dt = Text::PSTemplate::Plugin::Time2::DateTime->parse($ts);
        if ($asset->{months}) {
            $dt->set_month_asset($asset->{months});
        }
        if ($asset->{wdays}) {
            $dt->set_weekday_asset($asset->{wdays});
        }
        
        my @elems = (
            sub {$dt->second},
            sub {$dt->minute},
            sub {$dt->hour},
            sub {$dt->day},
            sub {$dt->month},
            sub {$dt->year},
            sub {$dt->day_of_week},
            sub {$dt->day_of_year},
            sub {undef}, # isdst deprecated
            sub {$dt->epoch},
            sub {$dt->day_name},
            sub {$dt->day_abbr},
            sub {$dt->month_name},
            sub {$dt->month_abbr},
            sub {$dt->year_abbr},
            sub {$dt->am_or_pm},
            sub {$dt->hour_12_0},
        );
        
        return sprintf($format, map {$elems[$_]->()} @$data);
    }
    
    sub now : TplExport {
        
        my ($self) = @_;
        return Text::PSTemplate::Plugin::Time2::DateTime->new->iso8601;
    }
    
    ### ---
    ### extract date part from datetime
    ### ---
    sub date : TplExport {
        
        my ($self, $date, $delim) = @_;
        return Text::PSTemplate::Plugin::Time2::DateTime->parse($date)->ymd($delim);
    }
    
    ### ---
    ### 2000-01-01 23:23:23
    ### ---
    sub iso8601 : TplExport {
        
        my ($self, $date) = @_;
        return Text::PSTemplate::Plugin::Time2::DateTime->parse($date)->iso8601;
    }
    
    ### ---
    ### Convert any date string to epoch
    ### ---
    sub epoch : TplExport {
        
        my ($self, $date) = @_;
        return Text::PSTemplate::Plugin::Time2::DateTime->parse($date)->epoch;
    }

1;

__END__

=head1 NAME

Text::PSTemplate::Plugin::Time2 - Time Utility [Experimental]

=head1 SYNOPSIS

    <% date() %>
    <% epoch() %>
    <% iso8601() %>
    <% now() %>
    <% reformat() %>
    
=head1 DESCRIPTION

This is a Plugin for Text::PSTemplate. This adds Time Utility functions into
your template engine.

To activate this plugin, your template have to load it as follows

    use Text::PSTemplate::Plugable;
    
    my $tpl = Text::PSTemplate::Plugable->new;
    $tpl->plug('Text::PSTemplate::Plugin::Time', '');

=head1 TEMPLATE FUNCTIONS

=head2 date([$date_string])

=head2 epoch([$date_string])

=head2 iso8601([$date_string])

=head2 now()

=head2 reformat($ts, $format, $data, $asset)

=head2 before($date1, $date2)

=head2 after($date1, $date2)

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
