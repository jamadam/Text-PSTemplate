package Text::PSTemplate::Exception;
use strict;
use warnings;
use Text::PSTemplate::File;

    sub new {
		
        my ($class, $message, $position, $file) = @_;
		
		my $self = bless {
			message     => $message,
			position	=> $position,
			file		=> $file,
		}, $class;
		
		if (scalar @_ >= 3) {
			$self->{message} = (split(/ at /, $self->{message}))[0];
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
    
	### ---
	### wrapper for die
	### ---
    sub die {
        
		my ($self) = @_;
		my $out 		= $self->message || 'Unknown Error';
        $out =~ s{(\s)+}{ }g;
		my $position 	= $self->position;
		my $file = ($self->file || $Text::PSTemplate::current_file);
        if ($file) {
			my $file_name 		= $file->name;
			my $file_content 	= $file->content;
			warn '===1.5';
			warn $file->name;
			warn ((caller(4))[3]);
            if ((caller(4))[3] !~ /Text::PSTemplate/) {
                if ($position) {
                    my $line_number = _line_number($file_content, $position);
                    $out = (split(/ at /, $out))[0];
                    $out .= " at $file_name line $line_number";
                }
                CORE::die "$out\n";
            }
			CORE::die $self;
        } else {
			warn '===========================5';
			my $i = 1;
			while (my @a = caller($i++)) {
				if ($a[0] =~ /Text::PSTemplate/ || $a[0] =~ /Try::Tiny/) {
					next;
				}
				CORE::die "$out at $a[1] line $a[2]\n";
			}
			CORE::die "$out\n";
		}
    }
    
    ### ---
    ### return null string
    ### ---
    our $PARTIAL_NONEXIST_NULL = sub {
        return '';
    };
    
    our $PARTIAL_NONEXIST_DIE = sub {
        my ($self, $var, $type) = (@_);
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
        my ($self, $line, $err) = (@_);
        my $delim_l = Text::PSTemplate::get_current_parser()->get_delimiter(0);
        my $delim_r = Text::PSTemplate::get_current_parser()->get_delimiter(1);
        return $delim_l. $line. $delim_r;
    };
    
    ### ---
    ### returns nothing and just die;
    ### ---
    our $TAG_ERROR_DIE = sub {
        my ($self, $line, $err) = (@_);
		warn '===1';
		$self->die;
        $err ||= "Unknown error occured in eval($line)";
        $err =~ s{\r\n|\r|\n}{};
        CORE::die $err. "\n";
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

=head2 $TEXT::PSTemplate::Exception->new($message, $line_number)

=head2 $instance->set_message

=head2 $instance->set_position

=head2 $instance->set_file

=head2 $instance->message

=head2 $instance->position

=head2 $instance->file

=head2 $instance->die

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
