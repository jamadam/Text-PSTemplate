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

    <html>
    <title><!-- $title --></title>
    <body>
        <p>today: <!-- &access_counter(name => 'today') --></p>
        <p>yesterday: <!-- &access_counter(name => 'yesterday') --></p>
        
        <!-- &set_delimiter(left => '%%', right => '%%') -->
        <img src="%%&access_counter(name => 'today', by_image => 1)%%">
        
        <p>
            %%&put_google_news_headlines(count => 10)%%
        </p>
    </body>
    </html>
    %%&access_counter::count()%%

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
