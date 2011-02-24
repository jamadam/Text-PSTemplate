package Text::PSTemplate;
use strict;
use warnings;
use Fcntl qw(:flock);
our $VERSION = '0.17';
use 5.005;
use Carp;
no warnings 'recursion';

    my $MEM_MOTHER                  = 1;
    my $MEM_DELIMITER_LEFT          = 2;
    my $MEM_DELIMITER_RIGHT         = 3;
    my $MEM_ENCODING                = 4;
    my $MEM_RECUR_LIMIT             = 5;
    my $MEM_FUNC                    = 6;
    my $MEM_VAR                     = 7;
    my $MEM_FILENAME_TRANS          = 8;
    my $MEM_BYPASS_MOTHER_SEARCH    = 9;
    my $MEM_NONEXIST                = 10;
    my $MEM_FUNC_NONEXIST           = 11;
    my $MEM_VAR_NONEXIST            = 12;
    
    ### ---
    ### constractor
    ### ---
    sub new {
        
        my ($class, $mother) = @_;
        
        if (ref $class) {
            $mother ||= $class;
            $class = ref $class;
        } elsif (scalar @_ == 1) {
            $mother = $Text::PSTemplate::self || undef;
        }
        
        my $self = bless {
            $MEM_MOTHER      => $mother, 
            $MEM_FUNC        => {},
            $MEM_VAR         => {},
        }, $class;
        
        if (! defined $mother) {
            $self->{$MEM_ENCODING}          = 'utf8';
            $self->{$MEM_RECUR_LIMIT}       = 10;
            $self->{$MEM_FUNC_NONEXIST}     = $Text::PSTemplate::Exception::PARTIAL_NONEXIST_DIE;
            $self->{$MEM_VAR_NONEXIST}      = $Text::PSTemplate::Exception::PARTIAL_NONEXIST_DIE;
            $self->{$MEM_NONEXIST}          = $Text::PSTemplate::Exception::TAG_ERROR_DIE;
            $self->{$MEM_DELIMITER_LEFT}    = '<%';
            $self->{$MEM_DELIMITER_RIGHT}   = '%>';
        }
        
        if ($self->_count_recursion() > $self->get_param($MEM_RECUR_LIMIT)) {
            croak 'Deep Recursion over '. $self->get_param($MEM_RECUR_LIMIT);
        }
        return $self;
    }
    
    ### ---
    ### Sub template factory[deprecated]
    ### ---
    sub new_sub_template {
        
        return shift->new;
    }
    
    ### ---
    ### Get mother in caller context
    ### ---
    sub mother {
        
        if (ref $_[0]) {
            if ($_[0]->{$MEM_MOTHER}->{$MEM_BYPASS_MOTHER_SEARCH}) {
                return $_[0]->{$MEM_MOTHER}->mother;
            }
            return $_[0]->{$MEM_MOTHER};
        } else {
            if ($Text::PSTemplate::self->{$MEM_BYPASS_MOTHER_SEARCH}) {
                return $Text::PSTemplate::self->mother;
            }
            return $Text::PSTemplate::self;
        }
    }
    
    ### ---
    ### Get current file name
    ### ---
    sub bypass_mother_search {
        
        $_[0]->{$MEM_BYPASS_MOTHER_SEARCH} = 1;
    }
    
    ### ---
    ### Get current file name
    ### ---
    sub context {
        
        return $Text::PSTemplate::context;
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
    ### Set delimiter
    ### ---
    sub set_delimiter {
        
        $_[0]->{$MEM_DELIMITER_LEFT} = $_[1];
        $_[0]->{$MEM_DELIMITER_RIGHT} = $_[2];
        return $_[0];
    }
    
    ### ---
    ### Get delimiter
    ### ---
    sub get_delimiter {
        
        my $name = ($MEM_DELIMITER_LEFT, $MEM_DELIMITER_RIGHT)[$_[1]];
        if (defined $_[0]->{$name}) {
            return $_[0]->{$name};
        }
        if (defined $_[0]->{$MEM_MOTHER}) {
            return $_[0]->{$MEM_MOTHER}->get_delimiter($_[1]);
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
        
        if (defined $_[1]) {
            if (defined $_[0]->{$MEM_VAR}->{$_[1]}) {
                return $_[0]->{$MEM_VAR}->{$_[1]};
            }
            if (defined $_[0]->{$MEM_MOTHER}) {
                return $_[0]->{$MEM_MOTHER}->var($_[1]);
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
            $self->{$MEM_FUNC}->{$key} = $value;
        }
        return $self;
    }
    
    ### ---
    ### Get template function
    ### ---
    sub func {
        
        if (defined $_[1]) {
            if (defined $_[0]->{$MEM_FUNC}->{$_[1]}) {
                return $_[0]->{$MEM_FUNC}->{$_[1]};
            }
            if (defined $_[0]->{$MEM_MOTHER}) {
                return $_[0]->{$MEM_MOTHER}->func($_[1]);
            }
        }
        return;
    }
    
    ### ---
    ### Parse template
    ### ---
    sub parse_file {
        
        my ($self, $file) = @_;
        local $Text::PSTemplate::context = $Text::PSTemplate::context;
        my $str;
        if (ref $_[1] eq 'Text::PSTemplate::File') {
            $Text::PSTemplate::context = $_[1]->name;
            $str = $_[1]->content;
        } else {
            my $translate_ref = $self->get_param($MEM_FILENAME_TRANS);
            if (ref $translate_ref eq 'CODE') {
                $file = $translate_ref->($file);
            }
            my $file = $self->get_file($file, 1, undef);
            $Text::PSTemplate::context = $file->name;
            $str = $file->content;
        }
        return $self->parse($str);
    }
    
    ### ---
    ### Parse template
    ### ---
    sub parse_str {
        
        my ($self, $str) = @_;
        if (ref $_[1] eq 'Text::PSTemplate::File') {
            $Text::PSTemplate::context = $_[1]->name;
            $str = $_[1]->content;
        }
        return $self->parse($str);
    }
    
    sub parse {
        
        my ($self, $str) = @_;
        
        if (! defined $str) {
            croak 'No template string found';
        }
        
        my $delim_l = $self->get_param($MEM_DELIMITER_LEFT);
        my $delim_r = $self->get_param($MEM_DELIMITER_RIGHT);
        my ($left, $escape, $space_l, $tag, $space_r, $right) =
            split(m{(\\*)$delim_l(\s*)(.+?)(\s*)$delim_r}s, $str, 2);
        
        if (! $tag) {
            return $str;
        }
        
        my $len = length($escape);
        my $out = ('\\' x int($len / 2));
        if ($len % 2 == 1) {
            $out .= $delim_l. $space_l. $tag. $space_r. $delim_r;
        } else {
            local $Text::PSTemplate::inline_data;
            local $Text::PSTemplate::self = $self;
            
            if ($tag =~ s{<<([a-zA-Z0-9,]+)}{}) {
                for my $a (split(',', $1)) {
                    if ($right =~ s{(.*?)$delim_l\s*$a\s*$delim_r}{}s) {
                        push(@{$Text::PSTemplate::inline_data}, $1);
                    }
                }
            }
            
            my $interp;
            if (substr($tag, 0, 1) !~ /\$|\&/) {
                $interp = eval {$self->_interpolate('&'.$tag)};
            } else {
                $interp = eval {$self->_interpolate($tag)};
            }
            
            if ($@) {
                my $org = $space_l. $tag. $space_r;
                $out .= $self->get_param($MEM_NONEXIST)->($self, $org, $@);
            } else {
                my $result = eval $interp; ## no critic
                if ($@) {
                    my $org = $space_l. $tag. $space_r;
                    $out .= $self->get_param($MEM_NONEXIST)->($self, $org, $@);
                } else {
                    $out .= $result;
                }
            }
        }
        return $left. $out. $self->parse($right);
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
                        $out .= "'\Q".
                        $self->get_param($MEM_VAR_NONEXIST)->($self, $2.$3, 'variable').
                        "\E'";
                    }
                } elsif ($2 eq '&') {
                    if ($self->func($3)) {
                        $out .= qq!\$self->func('$3')->!;
                    } else {
                        $out .= "'\Q".
                        $self->get_param($MEM_FUNC_NONEXIST)->($self, $2.$3, 'function').
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
    sub get_file {
        
        my ($self, $name, $translate_ref) = (@_);
        if (! $name) {
            croak 'file name is empty';
        }
        if (scalar @_ == 2) {
            $translate_ref = $self->get_param($MEM_FILENAME_TRANS);
        }
        if (ref $translate_ref eq 'CODE') {
            $name = $translate_ref->($name);
        }
        
        my $encode = $self->get_param($MEM_ENCODING);
        return Text::PSTemplate::File->new($name, $encode);
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

package Text::PSTemplate::File;
use strict;
use warnings;
use Carp;
use Fcntl qw(:flock);

    my $MEM_FILENAME    = 1;
    my $MEM_CONTENT     = 2;
    
    sub new {
        
        my ($class, $name, $encode) = @_;
        my $fh;
        
        if (! $name) {
            croak 'file name is empty';
        }
        
        if ($encode) {
            open($fh, "<:encoding($encode)", $name) || croak "$name cannot open";
        } else {
            open($fh, "<:utf8", $name) || croak "$name cannot open";
        }
        if ($fh and flock($fh, LOCK_EX)) {
            my $out = do { local $/; <$fh> };
            close($fh);
            return bless {
                $MEM_FILENAME => $name,
                $MEM_CONTENT => $out,
            }, $class;
        } else {
            croak "Template '$name' cannot open";
        }
    }
    
    sub name {
        return $_[0]->{$MEM_FILENAME};
    }
    
    sub content {
        return $_[0]->{$MEM_CONTENT};
    }

package Text::PSTemplate::Exception;
use strict;
use warnings;
use Carp;
    
    ### ---
    ### return null string
    ### ---
    our $PARTIAL_NONEXIST_NULL = sub {
        return '';
    };
    
    our $PARTIAL_NONEXIST_DIE = sub {
        my ($self, $var, $type) = (@_);
        croak "$type $var not defined";
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
        my $delim_l = Text::PSTemplate->mother->get_delimiter(0);
        my $delim_r = Text::PSTemplate->mother->get_delimiter(1);
        return $delim_l. $line. $delim_r;
    };
    
    ### ---
    ### returns nothing and just die;
    ### ---
    our $TAG_ERROR_DIE = sub {
        my ($self, $line, $err) = (@_);
        if ($err) {
            if ($err =~ /as a subroutine/) {
                croak "Cannot parse template line($line)";
            }
            croak "$err This error was in eval($line)";
        }
        croak "Error occured in eval($line)";
    };

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
    $template->set_filename_trans_coderef($code_ref);
    $template->set_delimiter($left, $right);
    
    $template->set_var(key1 => $value1, key2 => $value2);
    $template->set_func(key1 => \&func1, key2 => \&func2);
    
    $str = $template->parse($str);
    $str = $template->parse_str($str);
    $str = $template->parse_str($file_obj);
    $str = $template->parse_file($filename);
    $str = $template->parse_file($file_obj);
    
    $context        = Text::PSTemplate->context();
    $mother_obj     = Text::PSTemplate->mother();
    $inline_data    = Text::PSTemplate->inline_data($number);
    
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

Constractor. This method can take a argument $mother which should be a
Text::PSTemplate instance. Most member attributes will be inherited from their
mother at refering phase. So you don't have to set all settings again and
again. Just tell a mother to the constractor. If this constractor is
called from a template function, meaning the instanciation is recursive, this
constractor auto detects the nearest mother to be set to new instance's mothor.

If you want really new instance, give an undef to constractor explicitly.

    Text::PSTemplate->new(undef)

=head2 Text::PSTemplate::mother()

This can be called from template functions. If current context is recursed
instance, this returns mother instance.

=head2 Text::PSTemplate::context()

This can be called from template functions. If current context is origined from
a file, this returns the file name.

=head2 Text::PSTemplate::inline_data($index)

This can be called from template functions. This Returns inline data specified
in templates.
    
In a template
    
    <% your_func()<<EOF1,EOF2 %>
    foo
    <% EOF1 %>
    bar
    <% EOF2 %>
    
Function definision
    
    sub your_func() {
        my $block1 = Text::PSTemplate::inline_data(0) # foo
        my $block2 = Text::PSTemplate::inline_data(1) # bar
    }

=head2 $instance->set_encoding($encode)

This setting will be thrown at file open method. Default is 'utf8'.

=head2 $instance->set_exception($code_ref)

This is a callback setter. If a error occurs at parsing phase, the $code_ref
will be called. Your call back subroutine can get following arguments.

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

=head2 $instance->new_sub_template() [deprecated]

This is an arias to new method.

=head2 $instance->get_file($name, $trans_ref)

This returns the file content of given name. If $trans_ref is set or $instance
already has a translation code in its attribute, the file name is translated
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

=head2 $instance->bypass_mother_search()

=head1 TEXT::PSTemplate::File CLASS

This class represents a template file. With this class, you can take file
contents with the original file path. This class instance can be thrown at
parse_file method and parse_str method. This is useful if you have to iterate
template parse for same file.

=head2 TEXT::PSTemplate::File->new($filename)

Constractor

=head2 $instance->name

Returns file name may be with path name

=head2 $instance->content

Returns file content

=head1 TEXT::PSTemplate::Exception CLASS

This class provides some common error callback subroutines. They can be thrown
at exception setters.

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
