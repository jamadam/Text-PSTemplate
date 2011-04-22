package Text::PSTemplate::Exception;
use strict;
use warnings;
use Carp;
use Text::PSTemplate::File;
use Scalar::Util qw( blessed );
use overload (
    q{""} => \&_stringify,
    fallback => 1,
);

    sub _stringify {
        
        my ($self) = @_;
        my $out = $self->message || 'Unknown Error';
        $out =~ s{(\s)+}{ }g;
        my $position = $self->position;
        my $line     = $self->{line_number};
		my $file 	 = $self->file;
		if (blessed($file) && $file->isa('Text::PSTemplate::File')) {
			my $line_number = _line_number($file->content, $position);
			$out = (split(/ at /, $out))[0];
			$out .= sprintf(" at %s line %s", $file->name, $line_number);
        } elsif ($self->{filename}) {
            $out .= " at ". $self->{filename};
            if ($line) {
                $out .= " line $line";
            }
        }
        return $out;
    }

    sub new {
        
        my ($class, $message, $position, $file) = @_;
        
        if (ref $_[1] eq __PACKAGE__) {
            return $_[1];
        }
        my $self = bless {
            message     => $message,
            position    => $position,
            file        => $file,
            line_number => undef,
        }, $class;
		
        if (! $Text::PSTemplate::current_file) {
            my $at = Carp::shortmess_heavy();
            if ($at =~ qr{at (.+?) line (\d+)}) {
                $self->{filename} = $1;
                $self->{line_number} = $2;
            }
        }
        return $self;
    }
    
    sub set_message {
        my ($self, $value) = @_;
        $self->{message} = $value;
    }
    
    sub set_position {
        my ($self, $value) = @_;
        $self->{position} = $value;
    }
    
    sub set_file {
        my ($self, $value) = @_;
        $self->{file} = $value;
    }
    
    sub message {
        my ($self) = @_;
        return $self->{message};
    }
    
    sub position {
        my ($self) = @_;
        return $self->{position};
    }
    
    sub file {
        my ($self) = @_;
        return $self->{file};
    }
    
    sub _line_number {
        
        my ($all, $pos) = @_;
        if (! defined $pos) {
            $pos = length($all);
        }
        my $errstr = substr($all, 0, $pos);
        my $line_num = (() = $errstr =~ /\r\n|\r|\n/g);
        return $line_num + 1;
    }
    
    sub line_number_to_pos {
        
        my ($str, $num) = @_;
        my $found = 0;
        my $pos;
        for ($pos = 0; $found < $num - 1 && $pos < length($str); $pos++) {
            if (substr($str, $pos, 2) =~ /\r\n/) {
                $found++;
                $pos++;
                next;
            }
            if (substr($str, $pos, 1) =~ /\r|\n/) {
                $found++;
                next;
            }
        }
        return $pos;
    }
    
    ### ---
    ### return null string
    ### ---
    our $PARTIAL_NONEXIST_NULL = sub {
        return '';
    };
    
    our $PARTIAL_NONEXIST_DIE = sub {
        my ($parser, $var, $type) = (@_);
        CORE::die "$type $var undefined\n";
    };
    
    ### ---
    ### return null string
    ### ---
    our $TAG_ERROR_NULL = sub {
        return '';
    };
    
    ### ---
    ### returns template tag itself
    ### ---
    our $TAG_ERROR_NO_ACTION = sub {
        my ($parser, $line, $self) = (@_);
        my $delim_l = Text::PSTemplate::get_current_parser()->get_delimiter(0);
        my $delim_r = Text::PSTemplate::get_current_parser()->get_delimiter(1);
        return $delim_l. $line. $delim_r;
    };
    
    ### ---
    ### returns nothing and just die;
    ### ---
    our $TAG_ERROR_DIE = sub {
        my ($parser, $line, $self) = (@_);
        CORE::die $self;
    };

1;

__END__

=head1 NAME

TEXT::PSTemplate::Exception - A Class represents exceptions

=head1 SYNOPSIS

    use Text::PSTemplate::Exception;
    
=head1 DESCRIPTION

This class represents exceptions which contains error messages and the line
numbers together. This class also provides some common error callback
subroutines. They can be thrown at exception setters.

=head1 METHODS

=head2 TEXT::PSTemplate::Exception->new($message, $line_number)

=head2 $instance->set_message

=head2 $instance->set_position

=head2 $instance->set_file

=head2 $instance->message

=head2 $instance->position

=head2 $instance->file

=head2 TEXT::PSTemplate::Exception->line_number_to_pos;

=head2 $TEXT::PSTemplate::Exception::PARTIAL_NONEXIST_NULL;

    Text::PSTemplate::set_exception($code_ref)
    Text::PSTemplate::set_var_exception($code_ref)
    Text::PSTemplate::set_func_exception($code_ref)

=head2 $TEXT::PSTemplate::Exception::PARTIAL_NONEXIST_NULL;

This callback returns null string.

=head2 $TEXT::PSTemplate::Exception::PARTIAL_NONEXIST_DIE;

This callback dies with message. This is the default option for both function
parse errors and variable parse errors.

=head2 $TEXT::PSTemplate::Exception::TAG_ERROR_DIE;

This callback dies with message. This is the default option for tag parse.

=head2 $TEXT::PSTemplate::Exception::TAG_ERROR_NULL;

This callback returns null string. The template will be parsed as if the tag wasn't
there. This is good if you don't want wrong tags visible to public.

=head2 $TEXT::PSTemplate::Exception::TAG_ERROR_NO_ACTION;

This callback returns tag description itself. The template will be parsed as if
the tag was escaped.

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
