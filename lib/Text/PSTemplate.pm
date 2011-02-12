package Text::PSTemplate;

use strict;
use warnings;
use Fcntl qw(:flock);
our $VERSION = '0.11';
use 5.005;
use Carp;
no warnings 'recursion';
    
    ### ---
    ### constractor
    ### ---
    sub new {
        
        my $class = shift;
        my $self = {
            mother      => ($Text::PSTemplate::self || undef), 
            nonexist    => undef, 
            encoding    => undef,
            recur_limit => undef,
            func        => {},
            var         => {},
            @_};
        
        bless $self, $class;
        
        if (! defined $self->{mother}) {
            $self->{encoding}          ||= 'utf8';
            $self->{recur_limit}       ||= 10;
            $self->{nonexist} 		   ||= \&nonExistDie;
            $self->{left_delimiter}    ||= '{%';
            $self->{right_delimiter}   ||= '%}';
        }
        
        if ($self->_count_recursion() > $self->get_param('recur_limit')) {
            croak 'Deep Recursion over '. $self->get_param('recur_limit');
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
        
        my $idx = shift;
        if (defined $idx) {
            return $Text::PSTemplate::inline_data->[$idx];
        } else {
            return $Text::PSTemplate::inline_data;
        }
    }
    
    ### ---
    ### Set params
    ### ---
    sub set_param {
        
        my ($self, %args) = (@_);
        foreach my $key (keys %args) {
            $self->{$key} = $args{$key};
        }
        return $self;
    }
    
    ### ---
    ### Get a param
    ### ---
    sub get_param {
        
        my ($self, $name) = (@_);
        if (defined $name) {
            if (defined $self->{$name}) {
                return $self->{$name};
            }
            if (defined $self->{mother}) {
                return $self->{mother}->get_param($name);
            }
        }
        return undef;
    }
    
    ### ---
    ### Set delimiter
    ### ---
    sub set_delimiter {
        
        my ($self, $left, $right) = @_;
        $self->{left_delimiter} = $left;
        $self->{right_delimiter} = $right;
        return $self;
    }
    
    ### ---
    ### Get delimiter
    ### ---
    sub get_delimiter {
        
        my ($self, $name) = (@_);
        $name ||= 'left';
        my $key = $name. "_delimiter";
        
        if (defined $self->{$key}) {
            return $self->{$key};
        }
        if (defined $self->{mother}) {
            return $self->{mother}->get_delimiter($name);
        }
        return;
    }
    
    ### ---
    ### Set template variables
    ### ---
    sub set_var {
        
        my ($self, %args) = (@_);
        while ((my $key, my $value) = each %args) {
            $self->{var}->{$key} = $value;
        }
        return $self;
    }
    
    ### ---
    ### Get a template variable
    ### ---
    sub var {
        
        my ($self, $name) = (@_);
        if (defined $name) {
            if (defined $self->{var}->{$name}) {
                return $self->{var}->{$name};
            }
            if (defined $self->{mother}) {
                return $self->{mother}->var($name);
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
            $self->{func}->{$key} = $value;
        }
        return $self;
    }
    
    ### ---
    ### Get template function
    ### ---
    sub func {
        
        my ($self, $name) = (@_);
        if (defined $name) {
            if (defined $self->{func}->{$name}) {
                return $self->{func}->{$name};
            }
            if (defined $self->{mother}) {
                return $self->{mother}->func($name);
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
        
        my $delim_l = $self->get_param('left_delimiter');
        my $delim_r = $self->get_param('right_delimiter');
        my ($left, $escape, $tag, $right) =
            split(m{(\\*)$delim_l(.+?)$delim_r}s, $str, 2);
        
        if (defined $right) {
            my $len = length($escape);
            my $out = ('\\' x int($len / 2));
            if ($len % 2 == 1) {
                $out .= $delim_l. $tag. $delim_r;
            } else {
                local $Text::PSTemplate::inline_data;
                #$tag =~ m{()};
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
                    $out .= $self->get_param('nonexist')->($self, $tag, $@);
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
        $str =~ s{(\\*)([\$\&])([\w:]+)(\()?}{
            my $len = length($1 or '');
            my $out = '\\' x int($len / 2);
            if ($len % 2 == 1) {
                $out .= $2. $3. ($4 || '');
            } else {
                if ($2 eq '$') {
                    if (defined $self->var($3)) {
                        $out .= qq!\$self->var('$3')!;
                    } else {
                        $out .=
                        "'\Q".
                        $self->get_param('nonexist')->($self, $2. $3).
                        "\E'";
                    }
                } elsif ($2 eq '&' and $4) {
                    if ($self->func($3)) {
                        $out .= qq!\$self->func('$3')->(!;
                    } else {
                        $out .=
                        "'\Q".
                        $self->get_param('nonexist')->($self, $2. $3).
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
        my $encode = $self->get_param('encoding');
        my $fh;
        
        if ($encode) {
            open($fh, "<:encoding($encode)", $name);
        } else {
            open($fh, "<:utf8", $name);
        }
        
        if ($fh and flock($fh, LOCK_EX)) {
            my $out = join('', <$fh>);
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
            $self->get_param('left_delimiter')
            . '\\'. $line
            . $self->get_param('right_delimiter');
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
        if (defined $self->{mother}) {
            return $self->{mother}->_count_recursion() + 1;
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
    $value = $template->get_param($name);
    $template->set_delimiter($left, $right);
    $str = $template->get_delimiter($left_or_right);
    $template->set_var(key1 => $value1, key2 => $value2);
    $value = $template->var($name);
    $template->set_func(key1 => \&func1, key2 => \&func2);
    $str = $template->parse(file => $filename);
    $str = $template->parse_str(str => $str);
    $context = $template->context();
    $inline_data = $template->inline_data();
    $mother_obj = $template->mother();

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
specify PSTemplate instance the mother. 

=item nonexist

This paramete takes code ref for catching excepton. When variables/functions
found in template are undefined, the parse method calls the subroutine to deal
with the statements. 

=back

=head2 Text::PSTemplate::mother

If current context is recursed instance, this returns mother instance.

=head2 Text::PSTemplate::context

If current context is origined from file, this returns file name.

=head2 Text::PSTemplate::inline_data

Returns inline data specified in template

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

=head2 $instance->get_delimiter($left_or_right)

Get delimiters

    $instance->get_delimiter('left')
    $instance->get_delimiter('right')

=head2 $instance->set_var(%datasets)

This Sets variables. It can take null string too. If you give it undef, the
variable inherits the mother's. 

    $instance->set_var(a => 'b', c => 'd')

=head2 $instance->var($name)

Get template variables

    $instance->set_var(a)

=head2 $instance->set_func(some_name => $code_ref)

Set template functions

    $a = sub {
        return 'Hello '. $_[0];
    };
    $instance->set_func(say_hello_to => $a)
    
    Inside template...
    {%say_hello_to('Fujitsu san')%}

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
