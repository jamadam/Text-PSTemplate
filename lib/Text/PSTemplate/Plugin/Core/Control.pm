package Text::PSTemplate::Plugin::Core::Control;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use Text::PSTemplate;

our $VERSION = '0.01';
    
    ### ---
    ### Parse inline template if the variable is in array
    ### ---
    sub if_in_array : TplExport {
        
        my ($self, $target, $array_ref, $then, $else) = @_;
        
        my $tpl = Text::PSTemplate->new;
        
        if (grep {$_ eq $target} @$array_ref) {
            if ($then) {
                return $then;
            } elsif (my $inline = Text::PSTemplate::inline_data(0)) {
                return $tpl->parse($inline);
            }
        } else {
            if ($else) {
                return $else;
            } elsif (my $inline = Text::PSTemplate::inline_data(1)) {
                return $tpl->parse($inline);
            }
        }
        return;
    }
    
    ### ---
    ### Parse inline template if the variable equals to value
    ### ---
    sub if : TplExport {
        
        my ($self, $condition, $then, $else) = @_;
        
        my $tpl = Text::PSTemplate->new;
        
        if ($condition) {
            if ($then) {
                return $then;
            } elsif (my $inline = Text::PSTemplate::inline_data(0)) {
                return $tpl->parse($inline);
            }
        } else {
            if ($else) {
                return $else;
            } elsif (my $inline = Text::PSTemplate::inline_data(1)) {
                return $tpl->parse($inline);
            }
        }
        return;
    }
    
    ### ---
    ### Parse inline template if the variable equals to value
    ### ---
    sub if_equals : TplExport {
        
        my ($self, $target, $value, $then, $else) = @_;
        
        my $tpl = Text::PSTemplate->new;
        
        if ($target eq $value) {
            if ($then) {
                return $then;
            } elsif (my $inline = Text::PSTemplate::inline_data(0)) {
                return $tpl->parse($inline);
            }
        } else {
            if ($else) {
                return $else;
            } elsif (my $inline = Text::PSTemplate::inline_data(1)) {
                return $tpl->parse($inline);
            }
        }
        return;
    }
    
    ### ---
    ### Parse inline template if the variable equals to value
    ### ---
    sub if_like : TplExport {
        
        my ($self, $target, $pattern, $then, $else) = @_;
        
        my $tpl = Text::PSTemplate->new;
        
        if ($target =~ /$pattern/) {
            if ($then) {
                return $then;
            } elsif (my $inline = Text::PSTemplate::inline_data(0)) {
                return $tpl->parse($inline);
            }
        } else {
            if ($else) {
                return $else;
            } elsif (my $inline = Text::PSTemplate::inline_data(1)) {
                return $tpl->parse($inline);
            }
        }
        return;
    }
    
    ### ---
    ### Switch inline Templates and parse on given cases
    ### ---
    sub switch : TplExport {
        
        my ($self, $target, $case_ref, $default) = @_;
        
        my $tpl = Text::PSTemplate->new;
        
        if (ref $case_ref eq 'ARRAY') {
            my $i = 0;
            for (; $i < scalar @$case_ref; $i++) {
                if ($target eq $case_ref->[$i]) {
                    return $tpl->parse(Text::PSTemplate::inline_data($i));
                }
            }
            if (defined $default) {
                return $tpl->parse($default);
            } elsif (my $inline = Text::PSTemplate::inline_data($i)) {
                return $tpl->parse($inline);
            }
        } elsif (ref $case_ref eq 'HASH') {
            if (exists $case_ref->{$target}) {
                return $case_ref->{$target};
            }
            return $default;
        }
        return;
    }
    
    ### ---
    ### Switch file Templates and parse on given cases
    ### ---
    sub tpl_switch : TplExport {
        
        my ($self, $target, $case_ref, $default) = @_;
        
        my $tpl = Text::PSTemplate->new;
        
        if (exists $case_ref->{$target}) {
            return $tpl->parse(file => $case_ref->{$target});
        } else {
            if ($default) {
                return $tpl->parse(file => $default);
            }
        }
        return;
    }
    
    ### ---
    ### Get Environment variable
    ### ---
    sub env : TplExport {
        
        my ($self, $key) = @_;
        return $ENV{$key};
    }
    
    ### ---
    ### Get Environment variable
    ### ---
    sub if_env : TplExport {
        
        my ($self, $key, @args) = @_;
        return $self->if($ENV{$key}, @args);
    }
    
    ### ---
    ### Get Environment variable
    ### ---
    sub if_env_equals : TplExport {
        
        my ($self, $key, @args) = @_;
        return $self->if_equals($ENV{$key}, @args);
    }
    
    ### ---
    ### Get Environment variable
    ### ---
    sub if_env_like : TplExport {
        
        my ($self, $key, @args) = @_;
        return $self->if_like($ENV{$key}, @args);
    }
    
    ### ---
    ### Substr
    ### ---
    sub each : TplExport {
        
        my ($self, $data, $asign1, $asign2) = @_;
        
        my $tplstr = Text::PSTemplate::inline_data(0);
        my $tpl = Text::PSTemplate->new;
		
		if (! ref $data) {
			$data = [$data];
		}
		
        my $out = '';
        if (ref $data eq 'ARRAY') {
            if (scalar @_ == 3) {
                for my $val (@$data) {
                    $tpl->set_var($asign1 => $val);
                    $out .= $tpl->parse($tplstr);
                }
            } elsif (scalar @_ == 4) {
                my $idx = 0;
                for my $val (@$data) {
                    $tpl->set_var($asign1 => $idx++);
                    $tpl->set_var($asign2 => $val);
                    $out .= $tpl->parse($tplstr);
                }
            }
        } elsif (ref $data eq 'HASH') {
            if (scalar @_ == 3) {
                while (my ($key, $value) = each(%$data)) {
                    $tpl->set_var($asign1 => $value);
                    $out .= $tpl->parse($tplstr);
                }
            } elsif (scalar @_ == 4) {
                while (my ($key, $value) = each(%$data)) {
                    $tpl->set_var($asign1 => $key);
                    $tpl->set_var($asign2 => $value);
                    $out .= $tpl->parse($tplstr);
                }
            }
        }
        return $out;
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

1;

__END__

=head1 NAME

Text::PSTemplate::Plugin::Util - Common controll structures

=head1 SYNOPSIS

    {% &if_equals($some_var, 'a', 'then', 'else') %}
    
    {% &if_equals($some_var, 'a')<<THEN,ELSE %}
    then
    {%THEN%}
    else
    {%ELSE%}
    
    {% &if($some_var, 'true', 'not true') %}
    
    {% &if($some_var)<<THEN,ELSE %}
    true
    {%THEN%}
    not true
    {%ELSE%}
    
    {% &if_in_array($some_var, ['a','b','c'], 'found', 'not found') %}
    
    {% &if_in_array($some_var, ['a','b','c'])<<THEN,ELSE %}
    found
    {%THEN%}
    not found
    {%ELSE%}
    
    {% &switch($some_var, {a => 'match a', b => 'match b'}, 'default') %}
    
    {% &switch($some_var, ['a', 'b'])<<CASE1,CASE2,DEFAULT %}
    match a
    {%CASE1%}
    match b
    {%CASE2%}
    default
    {%DEFAULT%}
    
    {% &tpl_switch($some_var, {
        a => 'path/to/tpl_a.txt',
        b => 'path/to/tpl_b.txt',
    }, 'path/to/tpl_default.txt) %}
    
    {% &substr($some_var, 0, 2, '...') %}
    
    {% &each($array_ref, 'name')<<TPL %}
    This is {%$name%}.
    {%TPL%}

    {% &each($array_ref, 'index' => 'name')<<TPL %}
    No.{%$index%} is {%$name%}.
    {%TPL%}

    {% &each($hash_ref, 'name')<<TPL %}
    This is {%$name%}.
    {%TPL%}

    {% &each($has_href, 'key' => 'name')<<TPL %}
    Key '{%$key%}' contains {%$name%}.
    {%TPL%}

=head1 DESCRIPTION

This is a Plugin for Text::PSTemplate. This adds Common controll structures into
your template engine.

To activate this plugin, your template have to load it as follows

    use Text::PSTemplate::Plugable;
    use Text::PSTemplate::Plugin::Util;
    
    my $tpl = Text::PSTemplate::Plugable->new;
    $tpl->plug('Text::PSTemplate::Plugin::Util', '');


=head1 TEMPLATE FUNCTIONS

=head2 if_equals

=head2 if

=head2 if_in_array

=head2 switch

=head2 tpl_switch

=head2 env

=head2 if_env

=head2 if_env_equals

=head2 if_env_like

=head2 each

=head2 substr

=head2 if_like

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
