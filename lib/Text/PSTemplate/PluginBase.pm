package Text::PSTemplate::PluginBase;
use strict;
use warnings;
use Text::PSTemplate;
use Attribute::Handlers;
use 5.005;
use Scalar::Util qw{blessed};
use Carp;
use Scalar::Util qw(weaken);
use Digest::MD5 qw(md5_hex);
use File::Spec;
use File::Path;
use Fcntl qw(:flock);

    my %_tpl_exports;
    my %_cacheable_funcs;
    my %_cacheable_fnames;
    my %_cacheable_redefined;
    my %_instanciated;
    my %_findsym2_tbl;
    
    my $MEM_INI = 1;
    my $MEM_AS  = 2;
    my $MEM_TPL = 3;
    
    ### ---
    ### Constractor
    ### ---
    sub new {
        
        my ($class, $tpl, $as) = (@_);
        if (! $tpl || ! $tpl->isa('Text::PSTemplate::Plugable')) {
            croak 'template is not given';
        }
        
        no strict 'refs';
        foreach my $pkg (@{$class. '::ISA'}) {
            if ($pkg ne __PACKAGE__) {
                $tpl->plug($pkg);
            }
        }
        my $self = bless {
            $MEM_INI    => {},
            $MEM_TPL    => $tpl,
            $MEM_AS     => $as,
        }, $class;
        
        if (! $_instanciated{$class}) {
            $class->_init_tpl_exports;
            $class->_init_cacheable_funcs;
            $_instanciated{$class} = 1;
        }
        $class->_make_class_cacheable($tpl);
        $self->_set_tpl_funcs($tpl);
        
        weaken $self->{$MEM_TPL};
        return $self;
    }
    
    sub _init_tpl_exports {
        
        my $class = shift;
        if (my $a = $_tpl_exports{$class}) {
            my $tbl = _findsym2($class);
            for my $entry (@$a) {
                $entry->[2] = $tbl->{$entry->[0]};
            }
        }
    }
    
    sub _init_cacheable_funcs {
        
        my $class = shift;
        if (my $a = $_cacheable_funcs{$class}) {
            my $tbl = _findsym2($class);
            for my $entry (@$a) {
                $entry->[2] = $tbl->{$entry->[0]};
            }
        }
    }
    
    sub _findsym2 {
        
        my ($pkg, $ref) = @_;
        if (! exists $_findsym2_tbl{$pkg}) {
            no strict 'refs';
            my $out = {};
            my $sym_tbl = \%{$pkg."::"};
            for my $key (keys %$sym_tbl) {
                my $val = $sym_tbl->{$key};
                if (ref \$val eq 'GLOB' && *{$val}{'CODE'}) {
                    $out->{\&{$val}} = $key;
                }
            }
            $_findsym2_tbl{$pkg} = $out;
        }
        return $_findsym2_tbl{$pkg};
    }
    
    ### ---
    ### Get template function entries
    ### ---
    sub _get_tpl_exports {
        
        my $pkg = shift;
        my @out = ();
        no strict 'refs';
        foreach my $super (@{$pkg. '::ISA'}) {
            if ($super ne __PACKAGE__) {
                push(@out, @{_get_tpl_exports($super)});
            }
        }
        if (my $a = $_tpl_exports{$pkg}) {
            push(@out, @$a);
        }
        return \@out;
    }
    
    ### ---
    ### Set ini
    ### ---
    sub set_ini {
        
        my ($self, $hash) = (@_);
        $self->{$MEM_INI} = $hash || {};
        return $self;
    }
    
    ### ---
    ### Get ini
    ### ---
    sub ini {
        
        my ($self, $name) = (@_);
        
        if (exists $self->{$MEM_INI}->{$name}) {
            return $self->{$MEM_INI}->{$name};
        }
        return (undef) if wantarray;
        return;
    }
    
    ### ---
    ### Template function Attribute
    ### ---
    sub TplExport : ATTR(BEGIN) {
        
        my($pkg, undef, $ref, undef, $data, undef) = @_;
        push(@{$_tpl_exports{$pkg}}, [$ref, $data ? {@$data} : {}]);
    }
    
    ### ---
    ### Define FileCacheable attribute
    ### ---
    sub FileCacheable : ATTR(BEGIN) {
        
        my($pkg, undef, $ref, undef, $data, undef) = @_;
        push(@{$_cacheable_funcs{$pkg}}, [$ref, $data ? {@$data} : {}]);
    }
    
    ### ---
    ### Register template functions
    ### ---
    sub _set_tpl_funcs {
        
        my ($self, $tpl) = (@_);
        my @namespaces = ();
        
        my $org = ref $self;
        if (defined $self->{$MEM_AS}) {
            push(@namespaces, $self->{$MEM_AS});
        } else {
            my $org = $org;
            if (my $short = $tpl->get_base($org)) {
                $org = $short;
            }
            push(@namespaces, $org);
            if (my $default_plugin = $tpl->{default_plugin}) {
                if ($org eq $default_plugin) {
                    push(@namespaces, '');
                } elsif ($org =~ /^$default_plugin\::(.+)/) {
                    push(@namespaces, '::'. $1);
                }
            }
        }
        
        @namespaces = map {$_ ? $_.'::' : $_} grep {defined $_} @namespaces;
        
        my $_tpl_exports = _get_tpl_exports($org);
        foreach my $func (@$_tpl_exports) {
            my $ref = $func->[0];
            my $rapper = sub {
                Text::PSTemplate::set_chop($func->[1]->{chop});
                my $ret = $self->$ref(@_);
                return (defined $ret ? $ret : '');
            };
            for my $namespace (@namespaces) {
                $tpl->set_func($namespace. $func->[2] => $rapper);
            }
        }
        
        return $self;
    }
    
    ### ---
    ### die with context
    ### ---
    sub die {
        
        my $at =
            (Text::PSTemplate::get_current_filename)
                ? ' at '. Text::PSTemplate::get_current_filename. "\n"
                : '';
        Carp::croak $_[1]. $at;
    }
    
    sub _make_class_cacheable {
        
        my ($class) = @_;
        
        if ($_cacheable_redefined{$class}) {
            return;
        } else {
            $_cacheable_redefined{$class} = 1;
        }
        my $funcs = $_cacheable_funcs{$class};
        for my $func (@$funcs) {
            no warnings 'redefine';
            no strict 'refs';
            my $sym = $func->[2];
            my $ref = \&{$class. '::'. $sym};
            *{"$class\::$sym"} = sub {
                my $self = shift;
                my %opt = (
                    %{__PACKAGE__->file_cache_options},
                    %{$self->file_cache_options}
                );
                my $args = $func->[1];
                my $cache_id_seed = $args->{key} || $opt{default_key};
                my $cache_id = *{$sym}. "\t". ($cache_id_seed || '');
                if ($opt{number_cache_id}) {
                    $cache_id .= "\t" . ($_cacheable_fnames{*{$sym}}++);
                }
                
                my $output;
                
                my @idarray = split(//, md5_hex($cache_id), $opt{cache_depth} + 1);
                
                ### check if cache has expired
                my $fpath = File::Spec->catfile(
                    $opt{cache_root},
                    $opt{namespace},
                    @idarray,
                );
                
                if (-f $fpath) {
                    if (my $cache_tp = (stat $fpath)[9]) {
                        if ($args->{expire}) {
                            if (! $args->{expire}->($self, $cache_tp)) {
                                $output = _get_cache($fpath);
                            }
                        } elsif (! $self->file_cache_expire($cache_tp)) {
                            $output = _get_cache($fpath);
                        }
                    }
                }
                
                ### generate cache
                if (! defined($output)) {
                    no strict 'refs';
                    $output = $self->$ref(@_);
                    
                    if (! defined $output) {
                        return;
                    }
                    
                    umask $opt{directory_umask};
                    
                    pop(@idarray);
                    mkpath(File::Spec->catfile($opt{cache_root}, $opt{namespace}, @idarray));
                    
                    if (open(my $OUT, '>:utf8', $fpath)) {
                        binmode($OUT, "utf8");
                        print $OUT $output;
                        close($OUT);
                    } else {
                        print STDERR "Cache \"$fpath\" write failed";
                    }
                }
                
                return $output;
            }
        }
    }
    
    ### ---
    ### Get Cache
    ### ---
    sub _get_cache {
        
        my ($fpath) = @_;
        
        my $FH;
        if (open($FH, "<:utf8", $fpath) and flock($FH, LOCK_EX)) {
            my $a = do { local $/; <$FH> };
            close($FH);
            return $a;
        }
        CORE::die "Cache open failed";
    }
    
    ### ---
    ### return true if cache *EXPIRED*
    ### ---
    sub file_cache_expire {
        return 0;
    }
    
    ### ---
    ### return options
    ### ---
    sub file_cache_options {
        return {
            cache_root => File::Spec->catdir(File::Spec->tmpdir(), 'FileCache'),
            cache_depth     => 3,
            directory_umask => '000',
            number_cache_id => 0,
            namespace       => 'Default',
        };
    }

1;

__END__

=head1 NAME

Text::PSTemplate::PluginBase - Plugin Abstract Class

=head1 SYNOPSIS

    package MyApp;
    
    my $tpl = Text::PSTemplate::Plugable->new;
    
    my $plugin = $tpl->plug('MyPlug1');
    # ..or..
    my $plugin = $tpl->plug('MyPlug1', 'Your::Namespace');
    
    $plugin->set_ini({key => 'value'});
    
    package MyPlug1;
    
    use base qw(Text::PSTemplate::PluginBase);
    
    sub say_hello_to : TplExport {
    
        my ($plugin, $name) = (@_);
        
        my $value = $plugin->ini($some_key);
        
        return "Hello $name";
    }
    
    # in templates ..
    # <% Your::Namespace::say_hello_to('Jamadam') %>

    # Template functions can be cached into files
    
    use LWP::Simple;
    
    sub insert_remote_data : TplExport FileCacheable {
        my ($plugin, $url) = (@_);
        return LWP::Simple::get($url);
    }
    
    # in templates ..
    # <% insert_remote_data('http://example.com/') %>
    
=head1 DESCRIPTION

This is an Abstract Class which represents plugins for
Text::PSTemplate::Plugable.

The plugin classes can contain subroutins with TplExport attribute.
These subroutins are targeted as template function.

Text::PSTemplate::PluginBase is also a sub class of Class::FileCacheable so
subtoutins can have FileCacheable attribute. See also
L<Class::FileCacheable>.

The Plugins can inherit other plugins. The new constractor automatically
instanciates all depended plugins and template functions are inherited even in
templates.

This class also capable of managing ini datas for each plugins.

=head1 METHODS

=head2 Text::PSTemplate::PluginBase->new($template)

Constractor. This takes template instance as argument.

    my $tpl = Text::PSTemplate::Plugable->new;
    my $myplug = My::Plug->new($tpl);

=head2 $instance->set_ini($hash)

ini setter.

    $myplug->set_ini($hash_ref);

=head2 $instance->ini($key)

Returns ini data for given key.

    my $value = $myplug->ini($some_key);

Note that in list context, this always returns an array with 1 element.
If the key doesn't exists, this returns (undef).

=head2 $instance->die($message)

=head2 file_cache_expire

This is a callback method for specifying the condition for cache expiretion.
Your module can override the method if necessary.

file_cache_exipre will be called as instance method when the target method
called. This method takes timestamp of the cache as argument.

    sub file_cache_expire {
        my ($self, $timestamp) = @_;
        if (some_condifion) {
            return 1;
        }
    }

=head2 file_cache_options

This is a callback method for specifying options. Your module can override
the method if necessary.

    sub file_cache_options {
        return {
            'namespace' => 'Test',
            'cache_root' => 't/cache',
        };
    }

you can set options bellow

=over

=item cache_root

The location in the filesystem that will hold the root of the cache. Defaults
to the 'FileCache' under the OS default temp directory ( often '/tmp' on
UNIXes ) unless explicitly set.

=item cache_depth

The number of subdirectories deep to cache object item. This should be large
enough that no cache directory has more than a few hundred objects. Defaults
to 3 unless explicitly set.

=item directory_umask

The directories in the cache on the filesystem should be globally writable to
allow for multiple users. While this is a potential security concern, the
actual cache entries are written with the user's umask, thus reducing the risk
of cache poisoning. If you desire it to only be user writable, set
the 'directory_umask' option to '077' or similar. Defaults to '000' unless
explicitly set.

=item namespace

The namespace associated with this cache. Defaults to "Default" if not explicitly set.

=item number_cache_id

This takes 1 or 0 for value. '1' causes the cache ids automatically numbered so
the caches doesn't affect in single process. This is useful if you want to
cache the function calls as a sequence.

=back

=head1 ATTRIBUTE

=head2 TplExport [(chop => 1)]

This attribute makes the subroutine availabe in templates.

    sub your_func : TplExport {
        
    }

chop => 1 causes the following line breaks to be ommited.

    sub your_func : TplExport(chop => 1) {
        
    }

=head2 FileCacheable

=head2 FileCacheable(\%args)

This attribute makes the subroutine cacheable. See also L<Class::FileCacheable>

    sub your_func : FileCacheable {
        
    }

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
