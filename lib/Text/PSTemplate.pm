package Text::PSTemplate;
use strict;
use warnings;
use Fcntl qw(:flock);
use Text::PSTemplate::Exception;
use Text::PSTemplate::Block;
use Text::PSTemplate::File;
our $VERSION = '0.27';
use 5.005;
use Carp;
use Try::Tiny;
no warnings 'recursion';

    my $MEM_MOTHER                  = 1;
    my $MEM_DELIMITER_LEFT          = 2;
    my $MEM_DELIMITER_RIGHT         = 3;
    my $MEM_ENCODING                = 4;
    my $MEM_RECUR_LIMIT             = 5;
    my $MEM_FUNC                    = 6;
    my $MEM_VAR                     = 7;
    my $MEM_FILENAME_TRANS          = 8;
    my $MEM_NONEXIST                = 9;
    my $MEM_FUNC_NONEXIST           = 10;
    my $MEM_VAR_NONEXIST            = 11;
	
	### ---
	### debug
	### ---
	sub dump {
        use Data::Dumper;
		my $dump = Dumper($_[0]); $dump =~ s/\\x{([0-9a-z]+)}/chr(hex($1))/ge;
		return $dump;
	}
    
	### ---
	### wrapper for die
	### ---
    sub _croak {
        
        my ($err) = @_;
        my $out;
        my $position;
        if (ref $err eq 'Text::PSTemplate::Exception') {
            $out = $err->message;
            $position = $err->position;
        } else {
            $out = $err;
        }
        $out ||= 'Unknown Error';
        $out =~ s{(\s)+}{ }g;
        if (my $file = $Text::PSTemplate::current_file) {
            if ((caller(4))[3] !~ /Text::PSTemplate/) {
                if ($position) {
                    my $file_name = $file->name;
                    my $file_content = $file->content;
                    my $line_number = _line_number($file_content, $position);
                    $out = (split(/ at /, $out))[0];
                    $out .= " at $file_name line $line_number";
                }
                die "$out\n";
            }
            if ($position) {
                my $file_name = $file->name;
                $out = (split(/ at /, $out))[0];
                $out .= " at $file_name position $position";
            }
            die "$out\n";
        }
        my $i = 1;
        while (my @a = caller($i++)) {
            if ($a[0] =~ __PACKAGE__ || $a[0] =~ /Try::Tiny/) {
                next;
            }
            die "$out at $a[1] line $a[2]\n";
        }
        die "$out\n";
    }
    
    ### ---
    ### constractor
    ### ---
    sub new {
        
        my ($class, $mother) = @_;
        
        if (scalar @_ == 2 && ! defined $mother) {
            $mother = undef;
        } else {
            $mother ||= $Text::PSTemplate::self;
        }
        
        my $self = bless {
            $MEM_MOTHER      => $mother, 
            $MEM_FUNC        => {},
            $MEM_VAR         => {},
        }, $class;
        
        if (! defined $self->{$MEM_MOTHER}) {
            $self->{$MEM_ENCODING}          = 'utf8';
            $self->{$MEM_RECUR_LIMIT}       = 10;
            $self->{$MEM_DELIMITER_LEFT}    = '<%';
            $self->{$MEM_DELIMITER_RIGHT}   = '%>';
            $self->{$MEM_FUNC_NONEXIST}     =
                            $Text::PSTemplate::Exception::PARTIAL_NONEXIST_DIE;
            $self->{$MEM_VAR_NONEXIST}      =
                            $Text::PSTemplate::Exception::PARTIAL_NONEXIST_DIE;
            $self->{$MEM_NONEXIST}          =
                            $Text::PSTemplate::Exception::TAG_ERROR_DIE;
        }
        
        if ($self->_count_recursion() > $self->get_param($MEM_RECUR_LIMIT)) {
            _croak 'Deep Recursion over '. $self->get_param($MEM_RECUR_LIMIT);
        }
        return $self;
    }
    
    ### ---
    ### Get mother in caller context
    ### ---
    sub get_current_parser {
        
        my $self_or_class = shift;
        if (ref $self_or_class) {
            return $self_or_class->{$MEM_MOTHER};
        } else {
            return $Text::PSTemplate::self;
        }
    }
    
    ### ---
    ### Get file context mother
    ### ---
    sub get_current_file_parser {
        
        return
            $Text::PSTemplate::current_file_parser
            || Text::PSTemplate::get_current_parser->get_current_parser
            || Text::PSTemplate::get_current_parser;
    }
    
    ### ---
    ### Get current file name
    ### ---
    sub get_current_filename {
        
        if ($Text::PSTemplate::current_file) {
            return $Text::PSTemplate::current_file->name;
        }
    }
    
    ### ---
    ### Set Exception
    ### ---
    sub set_exception {
        
        my ($self, $code_ref) = @_;
        $self->{$MEM_NONEXIST} = $code_ref;
    }
    
    ### ---
    ### Set Exception
    ### ---
    sub set_func_exception {
        
        my ($self, $code_ref) = @_;
        $self->{$MEM_FUNC_NONEXIST} = $code_ref;
    }
    
    ### ---
    ### Set Exception
    ### ---
    sub set_var_exception {
        
        my ($self, $code_ref) = @_;
        $self->{$MEM_VAR_NONEXIST} = $code_ref;
    }
    
    ### ---
    ### Set Exception
    ### ---
    sub set_recur_limit {
        
        my ($self, $limit) = @_;
        $self->{$MEM_RECUR_LIMIT} = $limit;
    }
    
    ### ---
    ### Set Encoding
    ### ---
    sub set_encoding {
        
        my ($self, $encoding) = @_;
        $self->{$MEM_ENCODING} = $encoding;
    }
    
    ### ---
    ### Get a param
    ### ---
    sub get_param {
        
        if (defined $_[1]) {
            if (defined $_[0]->{$_[1]}) {
                return $_[0]->{$_[1]};
            }
            if (defined $_[0]->{$MEM_MOTHER}) {
                return $_[0]->{$MEM_MOTHER}->get_param($_[1]);
            }
        }
        return;
    }
    
    ### ---
    ### Set chop option which reduce newline chars
    ### ---
    sub set_chop {
        
        my ($mode) = @_;
        $Text::PSTemplate::chop = $mode;
    }
    
    ### ---
    ### Set delimiter
    ### ---
    sub set_delimiter {
        
        my ($self, $left, $right) = @_;
        $self->{$MEM_DELIMITER_LEFT} = $left;
        $self->{$MEM_DELIMITER_RIGHT} = $right;
        return $self;
    }
    
    ### ---
    ### Get delimiter
    ### ---
    sub get_delimiter {
        
        my ($self, $index) = @_;
        my $name = ($MEM_DELIMITER_LEFT, $MEM_DELIMITER_RIGHT)[$index];
        if (defined $self->{$name}) {
            return $self->{$name};
        }
        if (defined $self->{$MEM_MOTHER}) {
            return $self->{$MEM_MOTHER}->get_delimiter($index);
        }
        return;
    }
    
    ### ---
    ### Set template variables
    ### ---
    sub set_var {
        
        my ($self, %args) = (@_);
        while ((my $key, my $value) = each %args) {
            $self->{$MEM_VAR}->{$key} = $value;
        }
        return $self;
    }
    
    ### ---
    ### Get a template variable
    ### ---
    sub var {
        
        my ($self, $name) = @_;
        if (defined $name) {
            if (defined $self->{$MEM_VAR}->{$name}) {
                return $self->{$MEM_VAR}->{$name};
            }
            if (defined $self->{$MEM_MOTHER}) {
                return $self->{$MEM_MOTHER}->var($name);
            }
            if (! exists $self->{$MEM_VAR}->{$name}) {
                return $self->get_param($MEM_VAR_NONEXIST)->($self, '$'. $name, 'variable');
            }
            return;
        }
        return $self->{$MEM_VAR};
    }
    
    ### ---
    ### Set template function
    ### ---
    sub set_func {
        
        my ($self, %args) = (@_);
        while ((my $key, my $value) = each %args) {
            $self->{$MEM_FUNC}->{$key} = $value;
        }
        return $self;
    }
    
    ### ---
    ### Get template function
    ### ---
    sub func {
        
        my ($self, $name) = @_;
        if (defined $name) {
            if (defined $self->{$MEM_FUNC}->{$name}) {
                return $self->{$MEM_FUNC}->{$name};
            }
            if (defined $self->{$MEM_MOTHER}) {
                return $self->{$MEM_MOTHER}->func($name);
            }
            if (! exists $self->{$MEM_FUNC}->{$name}) {
                return $self->get_param($MEM_FUNC_NONEXIST)->($self, '&'. $name, 'function');
            }
            return;
        }
        return;
    }
    
    ### ---
    ### Parse template
    ### ---
    sub parse_file {
        
        my ($self, $file) = @_;
        local $Text::PSTemplate::current_file = $Text::PSTemplate::current_file;
        my $str;
        if (ref $_[1] eq 'Text::PSTemplate::File') {
            $Text::PSTemplate::current_file = $_[1];
            $str = $_[1]->content;
        } else {
            my $translate_ref = $self->get_param($MEM_FILENAME_TRANS);
            if (ref $translate_ref eq 'CODE') {
                $file = $translate_ref->($file);
            }
            my $file = $self->get_file($file, undef);
            $Text::PSTemplate::current_file = $file;
            $str = $file->content;
        }
        local $Text::PSTemplate::current_file_parser =
                                        $Text::PSTemplate::get_current_parser;

        my $res = try {
            $self->_parse_backend($str);
        } catch {
            my $exception = $_;
            _croak $exception;
        };
        return $res;
    }
    
    ### ---
    ### Parse template
    ### ---
    sub parse_str {
        
        my ($self, $str) = @_;
        if (ref $_[1] eq 'Text::PSTemplate::File') {
            local $Text::PSTemplate::current_file_parser =
                                        $Text::PSTemplate::get_current_parser;
            $Text::PSTemplate::current_file = $_[1];
            $str = $_[1]->content;
        }
        my $res = try {
            $self->_parse_backend($str);
        } catch {
            my $exception = $_;
            _croak $exception;
        };
        return $res;
    }
    
    sub get_block {
        
        my ($index, $args) = @_;
        if (ref $Text::PSTemplate::block && defined $index) {
            return $Text::PSTemplate::block->content($index, $args);
        } else {
            return $Text::PSTemplate::block;
        }
    }

    ### ---
    ### Get block and parse
    ### ---
    sub parse_block {
        
        my ($self, $index, $option) = @_;
        my $str = Text::PSTemplate::get_block($index, $option);
        if ($str) {
            my $res = try {
                $self->_parse_backend($str);
            } catch {
                my $exception = $_;
                my $pos = $exception->position - 1;
                my $chomp = $Text::PSTemplate::block->get_left_chomp($index);
                $pos += ($option->{chop_left}) ? length($chomp) : 0;
                for (my $i = 0; $i < $index; $i++) {
                    my $block = Text::PSTemplate::get_block($i);
                    $pos += length($block);
                }
                die Text::PSTemplate::Exception->new($exception->message, $pos);
                _croak(Text::PSTemplate::Exception->new($exception->message, $pos));
            };
            return $res;
        }
        return '';
    }
    
    ### ---
    ### Parse str
    ### ---
    sub parse {
        
        my ($self, @args) = @_;
        my $res = try {
            $self->_parse_backend(@args);
        } catch {
            my $exception = $_;
            _croak $exception;
        };
        return $res;
    }
    
    ### ---
    ### Parse str
    ### ---
    sub _parse_backend {
        
        my ($self, $str) = @_;
        my $str_org = $str;
        
        if (! defined $str) {
            die 'No template string found';
        }
        my $out = '';
        my $eval_pos = 0;
        while ($str) {
            my $delim_l = $self->get_param($MEM_DELIMITER_LEFT);
            my $delim_r = $self->get_param($MEM_DELIMITER_RIGHT);
            my ($left, $all, $escape, $space_l, $prefix, $tag, $space_r, $right) =
            split(m{((\\*)$delim_l(\s*)([\&\$]*)(.+?)(\s*)$delim_r)}s, $str, 2);
            
            if (! defined $tag) {
                return $out. $str;
            }
            $eval_pos += length($left) + length($all);
            $out .= $left;
            
            my $len = length($escape);
            $out .= ('\\' x int($len / 2));
            if ($len % 2 == 1) {
                $out .= $delim_l. $space_l. $prefix. $tag. $space_r. $delim_r;
            } else {
                local $Text::PSTemplate::block;
                local $Text::PSTemplate::self = $self;
                local $Text::PSTemplate::chop;
                
                if ($tag =~ s{<<([a-zA-Z0-9_,]+)}{}) {
                    $Text::PSTemplate::block = 
                    Text::PSTemplate::Block->new($1, \$right, $delim_l, $delim_r);
                }
                
                my $interp = ($prefix || '&'). $tag;
                $interp =~ s{(\\*)([\$\&])([\w:]+)}{
                    $self->_interpolate_partial($1, $2, $3)
                }ge;
                
                my $result = try {
                    Text::PSTemplate::_EvalStage::_do($self, $interp);
                } catch {
                    my $exception = $_;
                    my $org = $space_l. $prefix. $tag. $space_r;
                    my $err = $exception->message;
                    my $position = $exception->position || 0;
                    my $ret = try {
                        $self->get_param($MEM_NONEXIST)->($self, $org, $err);
                    } catch {
                        my $exception = $_;
                        $position += $eval_pos;
                        if (ref $exception eq 'Text::PSTemplate::Exception') {
                            die Text::PSTemplate::Exception->new($exception->message, $position);
                        }
                        die Text::PSTemplate::Exception->new($exception, $position);
                    };
                    return $ret;
                };
                
                if ($Text::PSTemplate::chop) {
                    $right =~ s{^(\r\n|\r|\n)}{};
                    $eval_pos += length($1);
                }
                
                $out .= $result;
                if ($Text::PSTemplate::block) {
                    $eval_pos += $Text::PSTemplate::block->get_followers_offset;
                }
            }
            $str = $right;
        }
        return $out;
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
    
    sub _interpolate_partial {
        
        my ($self, $escape, $prefix, $ident)= @_;
        my $out;
        my $escaped;
        if ($escape) {
            my $len = length($escape);
            $out = '\\' x int($len / 2);
            if ($len % 2 == 1) {
                $escaped = 1;
                $out .= $prefix. $ident;
            }
        }
        if (! $escaped) {
            if ($prefix eq '$') {
                $out .= qq{\$self->var('$ident')};
            } elsif ($prefix eq '&') {
                $out .= qq!\$self->func('$ident')->!;
            } else {
                $out .= $prefix . $ident;
            }
        }
        return $out;
    }
    
    ### ---
    ### Get template from a file
    ### ---
    sub get_file {
        
        my ($self, $name, $translate_ref) = (@_);
        if (! $name) {
            _croak 'file name is empty';
        }
        if (scalar @_ == 2) {
            $translate_ref = $self->get_param($MEM_FILENAME_TRANS);
        }
        if (ref $translate_ref eq 'CODE') {
            $name = $translate_ref->($name);
        }
        my $encode = $self->get_param($MEM_ENCODING);
        my $file = try {
            Text::PSTemplate::File->new($name, $encode);
        } catch {
            my $exception = $_;
            _croak $exception;
        };
        return $file;
    }
    
    ### ---
    ### Set file name transform callback
    ### ---
    sub set_filename_trans_coderef {
        
        my ($self, $coderef) = @_;
        $self->{$MEM_FILENAME_TRANS} = $coderef;
    }
    
    ### ---
    ### couunt recursion
    ### ---
    sub _count_recursion {
        
        my ($self) = (@_);
        
        if (defined $self->{$MEM_MOTHER}) {
            return $self->{$MEM_MOTHER}->_count_recursion() + 1;
        }
        return 0;
    }
    
package Text::PSTemplate::_EvalStage;
use strict;
use warnings;
use Carp qw(shortmess);
    
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
    
    {
        my $self;
        sub _do {
            $self = $_[0];
            my $str = $_[1];
            my $res = eval $str; ## no critic
            if ($@) {
                if (ref $@ eq 'Text::PSTemplate::Exception') {
                    die $@;
                }
                my $position;
                if (my $line_number = ($@ =~ qr{line (\d+)})[0]) {
                    $position = 0;
                    #$position = line_number_to_pos($str, $line_number); ### suspect!!!
                } else {
                    $position = ($@ =~ qr{position (\d+)})[0];
                }
                my $err_split = (split(/ at /, $@))[0];
                die Text::PSTemplate::Exception->new($err_split, $position);
            }
            if (! defined $res) {
                die Text::PSTemplate::Exception->new('Tag resulted undefined', 0);
            }
            return $res;
        }
        sub AUTOLOAD {
            our $AUTOLOAD;
            my $name = ($AUTOLOAD =~ qr/([^:]+)$/)[0];
            if ($self->func($name)) {
                return $self->func($name)->(@_);
            }
            die "Undefined subroutine $name called\n";
        }
    }

1;

__END__

=head1 NAME

Text::PSTemplate - Multi purpose template engine

=head1 SYNOPSIS

    use Text::PSTemplate;
    
    $template = Text::PSTemplate->new;
    $template->set_encoding($encodiing);
    $template->set_recur_limit($number);
    $template->set_exception($code_ref);
    $template->set_filename_trans_coderef($code_ref);
    $template->set_delimiter($left, $right);
    
    $template->set_var(key1 => $value1, key2 => $value2);
    $template->set_func(key1 => \&func1, key2 => \&func2);
    
    $str = $template->parse($str);
    $str = $template->parse_str($str);
    $str = $template->parse_str($file_obj);
    $str = $template->parse_file($filename);
    $str = $template->parse_file($file_obj);
    $str = $template->parse_block($index);
    
    $filename       = Text::PSTemplate::get_current_filename();
    $mother_obj     = Text::PSTemplate::get_current_parser();
    $block_data     = Text::PSTemplate::get_block($number, $options);
    
    $file_obj = Text::PSTemplate::File->new($filename);
    $file_obj->content;
    $file_obj->name;
    
    $code_ref = $Text::PSTemplate::PARTIAL_NULL;
    $code_ref = $Text::PSTemplate::PARTIAL_DIE;
    $code_ref = $Text::PSTemplate::TAG_NULL;
    $code_ref = $Text::PSTemplate::TAG_NO_ACTION;
    $code_ref = $Text::PSTemplate::TAG_DIE;
    
=head1 DESCRIPTION

Text::PSTemplate is a multi purpose template engine.
This module allows you to include variables and fucntion calls in your
templates.

This module doesn't provide any template functions in default. This doesn't
provide any control structures such as 'if-then' or 'for'. Functions will be
available by specifying code refs. Any control structures are feasible by
implementing functions by yourself. See also L<Text::PSTemplate::Plugin::Util>
for example.

This module requires less sytaxes than popular template engines. Template
designers only have to learn following rules.

=over

=item Special tagging

    <% ... %>

=item escaping

    \<% ... %>

=item Perl style variable and function calls

    <% $some_var %>
    <% some_func(...) %>

=item Block syntax

    <% some_func()<<EOF,EOF2 %>
    inline data
    <% EOF %>
    inline data2
    <% EOF2 %>

=back

=head1 METHODS

=head2 Text::PSTemplate->new($mother)

Constractor. This method can take an argument $mother which should be a
Text::PSTemplate instance. Most member attributes will be inherited from their
mother at refering phase. So you don't have to set all settings again and
again. Just tell a mother to the constractor. If this constractor is
called from a template function, meaning the instanciation is recursive, this
constractor auto detects the nearest mother to be set to new instance's mother.

If you want really new instance, give an undef to constractor explicitly.

    Text::PSTemplate->new(undef)

=head2 Text::PSTemplate::get_current_parser()

This can be called from template functions. If current context is recursed
instance, this returns mother instance.

=head2 Text::PSTemplate::get_current_file_parser()

This can be called from template functions. This returns file-contextual mother
template instance. 

=head2 Text::PSTemplate::get_current_filename()

This can be called from template functions. If current context is origined from
a file, this returns the file name.

=head2 Text::PSTemplate::set_chop($mode)

This method set the behavior of the parser how they should treat follow up line
breaks. If argument $mode is 1, line breaks will not to be output. 0 is default.

=head2 Text::PSTemplate::get_block($index, $options)

This can be called from template functions. This Returns block data specified
in templates.
    
In a template
    
    <% your_func()<<EOF1,EOF2 %>
    foo
    <% EOF1 %>
    bar
    <% EOF2 %>
    
Function definision
    
    sub your_func() {
        my $block1 = Text::PSTemplate::get_block(0) # foo with newline chara
        my $block2 = Text::PSTemplate::get_block(1) # bar with newline chara
        my $block1 = Text::PSTemplate::get_block(0, {chop_left => 1}) # foo
        my $block2 = Text::PSTemplate::get_block(1, {chop_right => 1}) # bar
    }

=head2 $instance->set_encoding($encode)

This setting will be thrown at file open method. Default is 'utf8'.

=head2 $instance->set_exception($code_ref)

This is a callback setter. If an error occurs at parsing phase, the $code_ref
will be called. Your callback subroutine can get following arguments.

    my ($self, $line, $err) = (@_);

With these arguments, you can log the error, do nothing and return '', or
reconstract the tag and return it as if the tag was escaped. See also
Text::PSTemplate::Exception Class for example.

=head2 $instance->set_var_exception($code_ref)

=head2 $instance->set_func_exception($code_ref)

=head2 $instance->set_recur_limit($number)

This class instance can recursively have a mother instance as an attribute.
This setting limits the recursion at given number.

=head2 $instance->get_param($name)

=head2 $instance->set_delimiter($left, $right)

Set delimiters.

    $instance->set_delimiter('<!-- ', ' -->')

=head2 $instance->get_delimiter(0 or 1)

Get delimiters

    $instance->get_delimiter(0) # left delimiter
    $instance->get_delimiter(1) # right delimiter

=head2 $instance->set_var(%datasets)

This method Sets variables which can be referred from templates.

    $instance->set_var(a => 'b', c => 'd')

This can take null string too. You can't set undef for value.

=head2 $instance->var($name)

Get template variables

    $instance->var('a')

=head2 $instance->set_func(some_name => $code_ref)

Set template functions

    $a = sub {
        return 'Hello '. $_[0];
    };
    $instance->set_func(say_hello_to => $a)
    
    Inside template...
    <% say_hello_to('Fujitsu san') %>

=head2 $instance->func(name)

Get template functions. This method is aimed at internal use.

=head2 $instance->parse($str)

This method parses templates given in string.

    $tpl->parse('...')

=head2 $instance->parse_str($str)

=head2 $instance->parse_str($file_obj)

This method parses templates given in string or Text::PSTemplate::File
instance.

    $tpl->parse_str('...')
    $tpl->parse_str($obj)

=head2 $instance->parse_file($file_path)

=head2 $instance->parse_file($file_obj)

This method parses templates given in filename or Text::PSTemplate::File
instance.

    $tpl->parse_file($file_path)
    $tpl->parse_file($obj)

=head2 $instance->parse_block($index, $args)

    $tpl->parse_block(0, {chop_left => 1})

=head2 $instance->get_file($name, $trans_ref)

This returns a Text::PSTemplate::File instance of given file name which contains
file name and file content together. If $trans_ref is set or $instance already
has a translation code in its attribute, the file name is translated
with the code. You can set undef for $trans_ref then both options are
bypassed.

=head2 $instance->set_filename_trans_coderef($code_ref)

This method sets a callback subroutine which defines a translating rule for file
name.

This example sets the base template directory.

    $trans = sub {
        my $name = shift;
        return '/path/to/template/base/directory'. $name;
    }
    $tpl->set_filename_trans_coderef($trans)

This example allows common extension to be ommited.

    $trans = sub {
        my $name = shift;
        if ($name !~ /\./) {
            return $name . '.html'
        }
        return $name;
    }
    $tpl->set_filename_trans_coderef($trans)

This also let you set a default template in case the template not found.

=head2 Text::PSTemplate::dump($object)

Debug

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
