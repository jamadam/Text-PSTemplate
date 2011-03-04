package Text::PSTemplate::Plugin::Util;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use Text::PSTemplate;
    
    ### ---
	### Conver to comma separated number
    ### ---
    sub commify : TplExport {
        
        my ($self, $num) = @_;
		
        if ($num) {
            while($num =~ s/(.*\d)(\d\d\d)/$1,$2/){};
            return $num;
        }
        if ($num eq '0') {
            return 0;
        }
        return;
    }
    
    ### ---
    ### Substr
    ### ---
    sub substr : TplExport {
        
        my ($self, $target, $start, $length, $alter) = @_;
        
        defined $target or return '';
        
        my $output = substr($target, $start, $length);
        
        if ($alter && length($target) != length($output)) {
            $output .= $alter;
        }
        return $output;
    }
    
    ### ---
    ### Counter 
    ### ---
    my $_counters = {};
    
    sub counter : TplExport {
        
        my $self = shift;
        my %args = (
            name => 'default',
            print => 1,
            @_);
        
        my $name = ($Text::PSTemplate::get_current_filename||''). $args{name};
        
        $_counters->{$name} ||= _make_counter(%args);
        
        if ($args{start}||$args{skip}||$args{direction}) {
            $_counters->{$name}->{init}->(%args);
        } else {
            $_counters->{$name}->{count}->();
        }
        if ($args{print}) {
            return $_counters->{$name}->{show}->();
        }
        return;
    }
    
    sub _make_counter {
        
        my $a = {
            start       => 1,
            skip        => 1,
            direction   => "up",
            @_};
        
        return {
            init    => sub{
                $a = {%$a, @_};
            },
            count   => sub{
                my $direction = {up => '1', down => '-1'}->{$a->{direction}};
                $a->{start} = $a->{start} + $a->{skip} * $direction;
            },
            show    => sub {
                return $a->{start};
            },
        };
    }

1;

__END__

=head1 NAME

Text::PSTemplate::Plugin::Util - Utility functions

=head1 SYNOPSIS
    
    <% commify($num) %>
    
    <% substr($var, $start, $length, $alterative) %>
    <% substr($some_var, 0, 2, '...') %>

    <% counter(start=10, skip=5) %>
    <% counter() %>
    <% counter() %>
    <% counter(start=10, direction=down) %>
    <% counter() %>

=head1 DESCRIPTION

This is a Plugin for Text::PSTemplate. This adds Utility functions into
your template engine.

To activate this plugin, your template have to load it as follows

    use Text::PSTemplate::Plugable;
    use Text::PSTemplate::Plugin::Util;
    
    my $tpl = Text::PSTemplate::Plugable->new;
    $tpl->plug('Text::PSTemplate::Plugin::Util', '');

Since this has promoted to core plugin, you don't have to explicitly load it.

=head1 TEMPLATE FUNCTIONS

=head2 commify($num)

Not written yet.

=head2 substr($var, $start, [$length, $alterative])

Not written yet.

=head2 counter([ string $name = 'default', [ int $start = 1, [ int $skip = 1, [ string $direction = "up", [ bool $print = true, [ string $assign = null ]]]]]])

Example

    <% counter(start=10, skip=5) %>
    <% counter() %>
    <% counter() %>
    <% counter(start=10, direction=down) %>
    <% counter() %>

Output

    10
    15
    20
    10
    5

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
