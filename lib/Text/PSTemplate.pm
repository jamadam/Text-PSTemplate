package Text::PSTemplate;
use strict;
use warnings;
use Fcntl qw(:flock);
use Text::PSTemplate::Exception;
use Text::PSTemplate::Block;
use Text::PSTemplate::File;
our $VERSION = '0.34';
use 5.005;
use Carp;
use Try::Tiny;
use Scalar::Util qw( blessed weaken );
no warnings 'recursion';
$Carp::Internal{ (__PACKAGE__) }++;

    our $current_file;
    our $current_file_parser;
    our $current_parser;
    our $block;
    our $chop;
    
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

    #my @CORE_LIST = qw(Control Env Extends Util);
    my %CORE_LIST = (
        Control => '',
        Env     => '',
        Extends => '',
        Util    => '',
        FS      => 'FS',
    );
    
    ### ---
    ### debug
    ### ---
    sub dump {
        use Data::Dumper;
        my $dump = Dumper($_[0]); $dump =~ s/\\x{([0-9a-z]+)}/chr(hex($1))/ge;
        return $dump;
    }
    
    ### ---
    ### constructor
    ### ---
    sub new {
        
        my ($class, $mother) = @_;
        
        if (scalar @_ == 2 && ! defined $mother) {
            $mother = undef;
        } else {
            $mother ||= $current_parser;
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
            my $err = 'Deep Recursion over '. $self->get_param($MEM_RECUR_LIMIT);
            die Text::PSTemplate::Exception->new($err);
        }
        
        if (! $mother) {
            for my $key (keys %CORE_LIST) {
                $self->plug('Text::PSTemplate::Plugin::'. $key, $CORE_LIST{$key});
            }
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
            return $current_parser;
        }
    }
    
    ### ---
    ### Get file context mother
    ### ---
    sub get_current_file_parser {
        return
            $current_file_parser
            || $current_parser->get_current_parser
            || $current_parser;
    }
    
    ### ---
    ### Get current file name
    ### ---
    sub get_current_filename {
        
        if ($current_file) {
            return $current_file->name;
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
        $chop = $mode;
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
        
        my ($self, $name, $error_callback) = @_;
        
        $error_callback ||= $self->{$MEM_VAR_NONEXIST};
        
        if (defined $name) {
            if (defined $self->{$MEM_VAR}->{$name}) {
                return $self->{$MEM_VAR}->{$name};
            }
            if (defined $self->{$MEM_MOTHER}) {
                return $self->{$MEM_MOTHER}->var($name, $error_callback);
            }
            if (! exists $self->{$MEM_VAR}->{$name}) {
                return $error_callback->($self, '$'. $name, 'variable');
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
        
        my ($self, $name, $error_callback) = @_;
        
        $error_callback ||= $self->{$MEM_VAR_NONEXIST};
        
        if (defined $name) {
            if (defined $self->{$MEM_FUNC}->{$name}) {
                return $self->{$MEM_FUNC}->{$name};
            }
            if (defined $self->{$MEM_MOTHER}) {
                return $self->{$MEM_MOTHER}->func($name, $error_callback);
            }
            if (! exists $self->{$MEM_FUNC}->{$name}) {
                return $error_callback->($self, '&'. $name, 'function');
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
        
        local $current_file = $current_file;
        
        my $str;
        if (blessed($file) && $file->isa('Text::PSTemplate::File')) {
            $current_file = $file;
            $str = $file->content;
        } else {
            my $translate_ref = $self->get_param($MEM_FILENAME_TRANS);
            if (ref $translate_ref eq 'CODE') {
                $file = $translate_ref->($file);
            }
            $current_file = $self->get_file($file, undef);
            $str = $current_file->content;
        }
        local $current_file_parser = $self;

        my $res = try {
            $self->parse($str);
        } catch {
            $_->set_file($current_file);
            $_->finalize;
            die $_;
        };
        return $res;
    }
    
    ### ---
    ### Parse template
    ### ---
    sub parse_str {
        
        my ($self, $str) = @_;
        if (blessed($str) && $str->isa('Text::PSTemplate::File')) {
            local $current_file_parser = $self;
            $current_file = $_[1];
            $str = $_[1]->content;
        }
        return $self->parse($str);
    }
    
    sub get_block {
        
        my ($index, $args) = @_;
        if (ref $block && defined $index) {
            return $block->content($index, $args);
        } else {
            return $block;
        }
    }

    ### ---
    ### Get block and parse
    ### ---
    sub parse_block {
        
        my ($self, $index, $option) = @_;
        if (ref $block && defined $index) {
            my $res = try {
                $self->parse($block->content($index, $option) || '');
            } catch {
                my $exception = Text::PSTemplate::Exception->new($_);
                my $pos = $exception->position - 1;
                $pos += length($block->get_left_chomp($index));
                for (my $i = 0; $i < $index; $i++) {
                    $pos += length($block->content($i));
                    $pos += length($block->delimiter($i));
                }
                $exception->set_position($pos);
                die $exception;
            };
            return $res;
        }
        return '';
    }
    
    ### ---
    ### Parse str
    ### ---
    sub parse {
        
        my ($self, $str) = @_;
        my $str_org = $str;
        
        if (! defined $str) {
            die Text::PSTemplate::Exception->new('No template string found');
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
                local $block;
                local $current_parser = $self;
                local $chop;
                
                if ($tag =~ s{<<([a-zA-Z0-9_,]+)}{}) {
                    $block = 
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
                    my $position = $exception->position || 0;
                    my $ret = try {
                        $self->get_param($MEM_NONEXIST)->($self, $org, $exception);
                    } catch {
                        my $exception = Text::PSTemplate::Exception->new($_);
                        $exception->set_position($position + $eval_pos);
                        die $exception;
                    };
                    return $ret;
                };
                
                if ($chop) {
                    $right =~ s{^(\r\n|\r|\n)}{};
                    $eval_pos += length($1);
                }
                
                $out .= $result;
                if ($block) {
                    $eval_pos += $block->get_followers_offset;
                }
            }
            $str = $right;
        }
        return $out;
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
        
        if (scalar @_ == 2) {
            $translate_ref = $self->get_param($MEM_FILENAME_TRANS);
        }
        if (ref $translate_ref eq 'CODE') {
            $name = $translate_ref->($name);
        }
        my $file = try {
            Text::PSTemplate::File->new($name, $self->get_param($MEM_ENCODING));
        } catch {
            die Text::PSTemplate::Exception->new($_);
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
    
    sub plug {
        
        my ($self, $plugin, $as) = (@_);
        $self->{pluged} ||= {};
        my $p_instance = $self->{pluged}->{$plugin};
        if (! blessed($p_instance)) {
            no strict 'refs';
            if (! %{"$plugin\::"}) {
                my $file = $plugin;
                $file =~ s{::}{/}g;
                eval {require "$file.pm"}; ## no critic
                if ($@) {
                    croak $@;
                }
            }
            $p_instance = $plugin->new($self, $as);
            $self->{pluged}->{$plugin} = $p_instance;
            weaken $self->{pluged}->{$plugin};
        }
        return $self->{pluged}->{$plugin};
    }
    
    sub get_plugin {
        
        my ($self, $name) = @_;
        if (exists $self->{pluged}->{$name}) {
            return $self->{pluged}->{$name};
        }
        croak "Plugin $name not loaded";
    }

    sub get_func_list {

        my $self = shift;
        my $out = <<EOF;
=============================================================
List of all available template functions
=============================================================
EOF

        for my $plug (keys %{$self->{pluged}}) {

            $out .= "\n-- $plug namespace";
            $out .= "\n";
            $out .= "\n";

            my $as = $self->{pluged}->{$plug}->{2};
            for my $func (@{$plug->_get_tpl_exports}) {
                $out .= '<% '. join('::', grep {$_} $as, $func->[2]) . '() %>';
                $out .= "\n";
            }
            $out .= "\n";
        }
        return $out;
    }
    
package Text::PSTemplate::_EvalStage;
use strict;
use warnings;
use Carp qw(shortmess);
$Carp::Internal{ (__PACKAGE__) }++;
    
    {
        my $self;
        sub _do {
            $self = $_[0];
            my $str = $_[1];
            my $res = eval $str; ## no critic
            if ($@) {
                die Text::PSTemplate::Exception->new($@);
            }
            if (! defined $res) {
                die Text::PSTemplate::Exception->new('Tag resulted undefined');
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
    $template->set_encoding($encoding);
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
    
    # Plugin feature
    
    $template->plug('MyPlug');
    $template->plug('MyPlug','My::Name::Space');
    
    $template->parse('...<% say_hello_to('Nick') %>...');
    
    package MyPlug;
    use strict;
    use warnings;
    use base qw(Text::PSTemplate::PluginBase);
    sub say_hello_to : TplExport(chop => 1) {
        my ($plugin, $name) = (@_);
        return "Hello $name";
    }

=head1 DESCRIPTION

Text::PSTemplate is a multi purpose template engine.
This module allows you to include variables and function calls in your
templates.

This module requires less syntaxes than popular template engines. The essential
syntax for writing template is as follows.

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

Constructor. This method can take an argument $mother which should be a
Text::PSTemplate instance. Most member attributes will be inherited from their
mother at referring phase. So you don't have to set all settings again and
again. Just tell a mother to the constructor. If this constructor is
called from a template function, meaning the instantiation is recursive, this
constructor auto detects the nearest mother to be set to new instance's mother.

If you want really new instance, give an undef to constructor explicitly.

    Text::PSTemplate->new(undef)

=head2 Text::PSTemplate::get_current_parser()

This can be called from template functions. If current context is recursed
instance, this returns mother instance.

=head2 Text::PSTemplate::get_current_file_parser()

This can be called from template functions. This returns file-contextual mother
template instance. 

=head2 Text::PSTemplate::get_current_filename()

This can be called from template functions. If current context is originated
from a file, this returns the file name.

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
    
Function definition
    
    sub your_func {
        my $block1 = Text::PSTemplate::get_block(0) # foo with newline chara
        my $block2 = Text::PSTemplate::get_block(1) # bar with newline chara
        my $block1 = Text::PSTemplate::get_block(0, {chop_left => 1}) # foo
        my $block2 = Text::PSTemplate::get_block(1, {chop_right => 1}) # bar
    }

=head2 $instance->set_encoding($encode or $encode_array_ref)

This setting will be thrown at file open method. Default is 'utf8'.

    $instance->set_encoding('cp932')

You can set a array reference for guessing encoding. The value will be thrown at
Encode::guess_encoding.

    $instance->set_encoding(['euc-jp', 'shiftjis', '7bit-jis'])

=head2 $instance->set_exception($code_ref)

This is a callback setter. If any errors occurred at parsing phase, the $code_ref
will be called. Your callback subroutine can get following arguments.

    my ($self, $line, $err) = (@_);

With these arguments, you can log the error, do nothing and return '', or
reconstruct the tag and return it as if the tag was escaped. See also
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

This example allows common extension to be omitted.

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

=head2 $instance->plug($package, $namespace)

This method activates a plugin into your template instance.

    $instance->plug('Path::To::SomePlugin');

The functions will available as follows.

    <% Path::To::SomePlugin::some_function(...) %>

You can load plugins into specific namespaces.

    $instance->plug('Path::To::SomePlugin', 'MyNamespace');

This functions will available as follows

    <% MyNamespace::some_function(...) %>

You can merge plugins into single namespace or even the root namespace which
used by core plugins.

    $instance->plug('Plugin1', 'MyNamespace');
    $instance->plug('Plugin2', 'MyNamespace');
    $instance->plug('Plugin1', '');

=head2 $instance->get_plugin($name)

This method returns the plugin instance for given name.

=head2 $instance->get_as($plug_id)

This method returns the namespace for the plugin. Since it's just to be called
from PluginBase abstract class, you don't worry about it.

=head2 get_func_list

Output list of available template function in text format.

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
