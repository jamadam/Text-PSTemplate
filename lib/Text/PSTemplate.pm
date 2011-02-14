package Text::PSTemplate;

use strict;
use warnings;
use Fcntl qw(:flock);
our $VERSION = '0.12';
use 5.005;
use Carp;
no warnings 'recursion';

    my $ARG_MOTHER          = 1;
    my $ARG_DELIMITER_LEFT  = 2;
    my $ARG_DELIMITER_RIGHT = 3;
    my $ARG_ENCODING        = 4;
    my $ARG_NONEXIST        = 5;
    my $ARG_RECUR_LIMIT     = 6;
    my $ARG_FUNC            = 7;
    my $ARG_VAR             = 8;
    
    my %arg_name_tbl = (
        'mother'            => $ARG_MOTHER,
        'delimiter_left'    => $ARG_DELIMITER_LEFT,
        'delimiter_right'   => $ARG_DELIMITER_RIGHT,
        'encoding'          => $ARG_ENCODING,
        'nonexist'          => $ARG_NONEXIST,
        'recur_limit'       => $ARG_RECUR_LIMIT,
    );
    
    ### ---
    ### constractor
    ### ---
    sub new {
        
        my $class = shift;
        my $self = {
            $ARG_MOTHER      => ($Text::PSTemplate::self || undef), 
            $ARG_NONEXIST    => undef, 
            $ARG_ENCODING    => undef,
            $ARG_RECUR_LIMIT => undef,
            $ARG_FUNC        => {},
            $ARG_VAR         => {},
        };
        while ((my $a = shift) && (my $b = shift)) {
            $self->{$arg_name_tbl{$a}} = $b;
        }
        
        bless $self, $class;
        
        if (! defined $self->{$ARG_MOTHER}) {
            $self->{$ARG_ENCODING}          ||= 'utf8';
            $self->{$ARG_RECUR_LIMIT}       ||= 10;
            $self->{$ARG_NONEXIST} 		    ||= \&nonExistDie;
            $self->{$ARG_DELIMITER_LEFT}    ||= '{%';
            $self->{$ARG_DELIMITER_RIGHT}   ||= '%}';
        }
        
        if ($self->_count_recursion() > $self->get_param($ARG_RECUR_LIMIT)) {
            croak 'Deep Recursion over '. $self->get_param($ARG_RECUR_LIMIT);
        }
        return $self;
    }
    
    ### ---
    ### Get mother in caller context
    ### ---
    sub mother {
        
        return $Text::PSTemplate::self;
    }
    
    ### ---
    ### Get current file name
    ### ---
    sub context {
        
        return $Text::PSTemplate::file;
    }
    
    ### ---
    ### Get inline data
    ### ---
    sub inline_data {
        
        if (defined $_[0]) {
            return $Text::PSTemplate::inline_data->[$_[0]];
        } else {
            return $Text::PSTemplate::inline_data;
        }
    }
    
    ### ---
    ### Set params
    ### ---
    sub set_param {
        
        while ((my $a = shift) && (my $b = shift)) {
            $_[0]->{$arg_name_tbl{$a}} = $b;
        }
        return $_[0];
    }
    
    ### ---
    ### Get a param
    ### ---
    sub get_param {
        
        if (defined $_[1]) {
            if (defined $_[0]->{$_[1]}) {
                return $_[0]->{$_[1]};
            }
            if (defined $_[0]->{$ARG_MOTHER}) {
                return $_[0]->{$ARG_MOTHER}->get_param($_[1]);
            }
        }
        return;
    }
    
    ### ---
    ### Set delimiter
    ### ---
    sub set_delimiter {
        
        $_[0]->{$ARG_DELIMITER_LEFT} = $_[1];
        $_[0]->{$ARG_DELIMITER_RIGHT} = $_[2];
        return $_[0];
    }
    
    ### ---
    ### Get delimiter
    ### ---
    sub get_delimiter {
        
        my $name = ($ARG_DELIMITER_LEFT, $ARG_DELIMITER_RIGHT)[$_[1]];
        if (defined $_[0]->{$name}) {
            return $_[0]->{$name};
        }
        if (defined $_[0]->{$ARG_MOTHER}) {
            return $_[0]->{$ARG_MOTHER}->get_delimiter($_[1]);
        }
        return;
    }
    
    ### ---
    ### Set template variables
    ### ---
    sub set_var {
        
        my ($self, %args) = (@_);
        while ((my $key, my $value) = each %args) {
            $self->{$ARG_VAR}->{$key} = $value;
        }
        return $self;
    }
    
    ### ---
    ### Get a template variable
    ### ---
    sub var {
        
        if (defined $_[1]) {
            if (defined $_[0]->{$ARG_VAR}->{$_[1]}) {
                return $_[0]->{$ARG_VAR}->{$_[1]};
            }
            if (defined $_[0]->{$ARG_MOTHER}) {
                return $_[0]->{$ARG_MOTHER}->var($_[1]);
            }
        }
        return;
    }
    
    ### ---
    ### Set template function
    ### ---
    sub set_func {
        
        my ($self, %args) = (@_);
        while ((my $key, my $value) = each %args) {
            $self->{$ARG_FUNC}->{$key} = $value;
        }
        return $self;
    }
    
    ### ---
    ### Get template function
    ### ---
    sub func {
        
        if (defined $_[1]) {
            if (defined $_[0]->{$ARG_FUNC}->{$_[1]}) {
                return $_[0]->{$ARG_FUNC}->{$_[1]};
            }
            if (defined $_[0]->{$ARG_MOTHER}) {
                return $_[0]->{$ARG_MOTHER}->func($_[1]);
            }
        }
        return;
    }
    
    ### ---
    ### Parse template
    ### ---
    sub parse {
        
        my $self = shift;
        my $str;
        local $Text::PSTemplate::file = $Text::PSTemplate::file;
        
        if (scalar @_ == 1) {
            $str = shift;
        } else {
            my %args = (@_);
            if ($args{file}) {
                $str = $self->_get_file($args{file});
                $Text::PSTemplate::file = $args{file};
            } elsif ($Text::PSTemplate::inline_data) {
                $str = shift @{Text::PSTemplate->inline_data};
            } else {
                croak "Template not found";
            }
        }
        
        (defined $str) or croak 'No template string found';
        
        my $delim_l = $self->get_param($ARG_DELIMITER_LEFT);
        my $delim_r = $self->get_param($ARG_DELIMITER_RIGHT);
        my ($left, $escape, $tag, $right) =
            split(m{(\\*)$delim_l(.+?)$delim_r}s, $str, 2);
        
        if (defined $right) {
            my $len = length($escape);
            my $out = ('\\' x int($len / 2));
            if ($len % 2 == 1) {
                $out .= $delim_l. $tag. $delim_r;
            } else {
                local $Text::PSTemplate::inline_data;
                $tag =~ s{(<<[a-zA-Z0-9,]*)}{};
                if (my $inline = $1) {
                    for my $a (split(',', substr($inline, 2))) {
                        $right =~ s{(.+?)$delim_l($a)$delim_r}{}s;
                        push(@{$Text::PSTemplate::inline_data}, $1);
                    }
                }
                
                local $Text::PSTemplate::self = $self;
                
                my $result = eval $self->_interpolate($tag); ## no critic
                
                if (defined $result) {
                    $out .= $result;
                } else {
                    no strict 'refs';
                    $out .= $self->get_param($ARG_NONEXIST)->($self, $tag, $@);
                }
            }
            return $left. $out. $self->parse($right);
        } else {
            return $str;
        }
    }
    
    ### ---
    ### interpolate variables and functions
    ### ---
    sub _interpolate {
        
        my ($self, $str) = (@_);
        $str =~ s{(\\*)([\$\&])([\w:]+)}{
            my $out;
            my $escaped;
            if ($1) {
                my $len = length($1);
                $out = '\\' x int($len / 2);
                if ($len % 2 == 1) {
                    $escaped = 1;
                    $out .= $2. $3;
                }
            }
            if (! $escaped) {
                if ($2 eq '$') {
                    if (defined $self->var($3)) {
                        $out .= qq!\$self->var('$3')!;
                    } else {
                        $out .=
                        "'\Q".
                        $self->get_param($ARG_NONEXIST)->($self, $2. $3).
                        "\E'";
                    }
                } elsif ($2 eq '&') {
                    if ($self->func($3)) {
                        $out .= qq!\$self->func('$3')->!;
                    } else {
                        $out .=
                        "'\Q".
                        $self->get_param($ARG_NONEXIST)->($self, $2. $3).
                        "\E'";
                    }
                } else {
                    $out .= $2. $3;
                }
            }
            $out;
        }ge;
        return $str;
    }
    
    ### ---
    ### Get template from a file
    ### ---
    sub _get_file {
        
        my ($self, $name) = (@_);
        my $encode = $self->get_param($ARG_ENCODING);
        my $fh;
        
        if ($encode) {
            open($fh, "<:encoding($encode)", $name);
        } else {
            open($fh, "<:utf8", $name);
        }
        
        if ($fh and flock($fh, LOCK_EX)) {
			my $out = do { local $/; <$fh> };
            close($fh);
            return $out;
        }
        croak "Template '$name' cannot open";
    }
    
    ### ---
    ### default callback for error handle
    ### ---
    sub nonExistNull {
        
        return '';
    }
    
    sub nonExistNoaction {
        
        my ($self, $line, $err) = (@_);
        return 
            $self->get_param($ARG_DELIMITER_LEFT)
            . '\\'. $line
            . $self->get_param($ARG_DELIMITER_RIGHT);
    }
    
    sub nonExistDie {
        
        my ($self, $line, $err) = (@_);
        if ($err) {
            if ($err =~ /as a subroutine/) {
                croak "Cannot parse template line($line)";
            }
            croak "$err This error was in eval($line)";
        }
        croak "Error occured in eval($line)";
    }
    
    ### ---
    ### couunt recursion
    ### ---
    sub _count_recursion {
        
        my ($self) = (@_);
        
        if (defined $self->{$ARG_MOTHER}) {
            return $self->{$ARG_MOTHER}->_count_recursion() + 1;
        }
        return 0;
    }

1;

__END__

=head1 NAME

Text::PSTemplate - Multi purpose template engine

=head1 SYNOPSIS

    use Text::PSTemplate;
    
    $template = Text::PSTemplate->new(%args);
    $template->set_param(%args);
    
    $template->set_delimiter($left, $right);
    
    $template->set_var(key1 => $value1, key2 => $value2);
    $value = $template->var($name);
    
    $template->set_func(key1 => \&func1, key2 => \&func2);
    
    $str = $template->parse(file => $filename);
    $str = $template->parse_str(str => $str);
    
    $context        = Text::PSTemplate->context();
    $inline_data    = Text::PSTemplate->inline_data($number);
    $mother_obj     = Text::PSTemplate->mother();

=head1 DESCRIPTION

Text::PSTemplate is a multi purpose template engine.
This module allows you to include variables and fucntion calls in your template.

This module doesn't provide any template functions in default. This doesn't
provide any controll structure such as 'if-then' or 'for'. Fucntions will be
available by specifying code refs. Any controll structures are feasible by
implementing functions.

This module requires less sytaxes than popular template engines. Template
designers only have to learn following rules.

=over

=item Special tagging

    {% ... %}

=item escaping

    \{% ... %}

=item Perl style variable and function call

    {% $some_var %}
    {% &some_func(...) %}

=item Inline data syntax [Advansed]

    {% &some_func()<<EOF,EOF2 %}
    inline data
    {%EOF%}
    inline data2
    {%EOF2%}

=back

=head1 METHODS

=head2 Text::PSTemplate->new()

Constractor. This method takes following arguments.

=over

=item mother

The template variables and functions inherit their mother's. This argument
specify PSTemplate instance for the mother. 

=item nonexist

This paramete takes code ref for catching excepton. When variables/functions
found in template are undefined, the parse method calls the subroutine to deal
with the statements. 

=back

=head2 Text::PSTemplate::mother()

This can be called from template function. If current context is recursed
instance, this returns mother instance.

=head2 Text::PSTemplate::context()

This can be called from template function. If current context is origined from
file, this returns file name.

=head2 Text::PSTemplate::inline_data()

This can be called from template function. This Returns inline data specified
in template

=head2 $instance->set_param(%hash)

This can sets following parameters.

=over

=item mother

=item nonexist

=item encoding 

=item recur_limit

=back

=head2 $instance->get_param($name)

=head2 $instance->set_delimiter($left, $right)

Set delimiters.

    $instance->set_delimiter('<!-- ', ' -->')

=head2 $instance->get_delimiter(0 or 1)

Get delimiters

    $instance->get_delimiter(1) # left delimiter
    $instance->get_delimiter(2) # right delimiter

=head2 $instance->set_var(%datasets)

This Sets variables. It can take null string too. If you give it undef, the
variable inherits the mother's. 

    $instance->set_var(a => 'b', c => 'd')

=head2 $instance->var($name)

Get template variables

    $instance->var(a)

=head2 $instance->set_func(some_name => $code_ref)

Set template functions

    $a = sub {
        return 'Hello '. $_[0];
    };
    $instance->set_func(say_hello_to => $a)
    
    Inside template...
    {%&say_hello_to('Fujitsu san')%}

=head2 $instance->func(name)

Get template functions.

=head2 $instance->parse($str)

=head2 $instance->parse(file => $file_path)

=head2 $instance->parse()

Template Parse.
    
    $tpl->parse('...')
    $tpl->parse(file => $file_path)
    $tpl->parse()

=head2 $instance->nonExistNull

=head2 $instance->nonExistNoaction

=head2 $instance->nonExistDie

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
