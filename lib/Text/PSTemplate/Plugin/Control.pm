package Text::PSTemplate::Plugin::Control;
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
    
    ### ---
    ### Do nothing and returns null string
    ### <!-- {%&bypass(' -->
    ### <base href="../">
    ### <!-- ')%} -->
    ### ---
    sub bypass : TplExport {
        
        return '';
    }

1;

__END__

=head1 NAME

Text::PSTemplate::Plugin::Control - Common controll structures

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
    use Text::PSTemplate::Plugin::Control;
    
    my $tpl = Text::PSTemplate::Plugable->new;
    $tpl->plug('Text::PSTemplate::Plugin::Control', '');

Since this has promoted to core plugin, you don't have to explicitly load it.

=head1 TEMPLATE FUNCTIONS

Note that this document contains many keywords for specifing block endings such
as THEN or ELSE etc. These keywords are just a example. As the matter of
fact, you can say 'EOF' for all of them. The template engine only matters
the order of BLOCKs. So do not memorize any of them. 

=head2 &if_equals($var, $case, $then, [$else])

=head2 &if_equals($var, $case)<<THEN[,ELSE]

Conditional branch. If $var equals to $case, $then is returned. Otherwise
returns $else. $else if optional.

    {% &if_equals($a, '1', 'matched') %}

Instead of arguments, you can pass 1 or 2 blocks for each conditions. The blocks
will be parsed as template.

    {% &if_equals($a, '1')<<THEN %}
        This is {% &escape_or_something($a) %}.
    {%THEN%}

=head2 &if($var, $then, [$else])

=head2 &if($var)<<THEN[,ELSE]

Conditional branch. If $var is a true value, returns $then. Otherwise returns
$else. The true means 'not 0' and 'not 0 length'. The exact definition about
true, see documents of perl itself. 

    {% if($var, 'true', 'not true') %}

For more about Block syntax, See if_equals function.

    {% if($var)<<THEN,ELSE %}
        This is {% &escape_or_something_if_you_need($var) %}.
    {%THEN%}
        not true
    {%ELSE%}

=head2 &if_in_array($var, $array_ref, $then, [$else])

=head2 &if_in_array($var, $array_ref)<<THEN[,ELSE]

Conditional branch for searching in array. If $var is in the array, returns
$then, otherwize returns $else.

    {% if_in_array($var, [1,2,3,'a'], 'found', 'not found') %}

Block syntax is also available.

    {% if_in_array($var, [1,2,3,'a'])<<THEN,ELSE %}
        Found {% &escape_or_something_if_you_need($var) %}.
    {%THEN%}
        Not found
    {%ELSE%}

=head2 &switch($var, $hash_ref, [$default])

=head2 &switch($var, $array_ref, [$default])<<CASE1,CASE2,...

Conditional branch for switching many cases.

    &switch($var, {1 => 'case1', 2 => 'case2'}, 'default')

Block syntax is also available.

    &switch($var, [1, 2])<<CASE1,CASE2,DEFAULT %}
        case1
    {%CASE1%}
        case2 {% &escape_or_something_if_you_need($var) %}
    {%CASE2%}
        default
    {%DEFAULT%}

=head2 &tpl_switch($var, $hash_ref)

Conditional branch for switching many cases. This function parses file templates
for each cases and returns the parsed string.

=head2 &if_like($var, $pattern, $then, $else)

=head2 &if_like($var, $pattern)<<THEN,ELSE

Not written yet.

=head2 &each($var, $value)<<TPL

=head2 &each($var, $key => $value)<<TPL

Not written yet.

=head2 &substr($var, $start, [$length, $alterative])

Not written yet.

=head2 &bypass('')

This function do nothing and returns null string.

    <!-- {%&bypass(' -->
    <base href="../">
    <!-- ')%} -->

PSTemplate parses above as..

    <!--  -->

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
