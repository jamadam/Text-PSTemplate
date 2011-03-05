package Text::PSTemplate::PluginBase;
use strict;
use warnings;
use Text::PSTemplate;
use Attribute::Handlers;
use 5.005;
use Scalar::Util qw{blessed};
use base qw(Class::FileCacheable::Lite);
use Carp;
use Scalar::Util qw(weaken);

    my %_tpl_exports = ();
    
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
        my $instance = $tpl->{pluged}->{$class};
        if (! blessed($instance)) {
            foreach my $pkg (@{$class. '::ISA'}) {
                if ($pkg ne __PACKAGE__) {
                    $pkg->new($tpl);
                }
            }
            $instance = bless {
                $MEM_INI    => {},
                $MEM_TPL    => $tpl,
                $MEM_AS     => $as,
            }, $class;
            $instance->_set_tpl_funcs($tpl);
            $tpl->{pluged}->{$class} = $instance;
            weaken $instance->{$MEM_TPL};
            weaken $tpl->{pluged}->{$class};
        }
        return $instance;
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
    sub TplExport : ATTR(CHECK) {
        
        my($pkg, $sym, undef, undef, $data, undef) = @_;
        push(@{$_tpl_exports{$pkg}}, [$sym, $data ? {@$data} : {}]);
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
            my $ref = \&{$func->[0]};
            my $rapper = sub {
                Text::PSTemplate->set_chop($func->[1]->{chop});
                my $ret = $self->$ref(@_);
                return (defined $ret ? $ret : '');
            };
            my $subname = ((scalar *{$func->[0]}) =~ m{([^:]+$)})[0];
            for my $namespace (@namespaces) {
                $tpl->set_func($namespace. $subname => $rapper);
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

1;

__END__

=head1 NAME

Text::PSTemplate::PlugBase - Plugin Abstract Class

=head1 SYNOPSIS

    package MyApp;
    
    my $tpl = Text::PSTemplate::Plugable->new;
    
    $tpl->plug('MyPlug1');
    $tpl->plug('MyPlug1', 'Your::Namespace');
    
    package MyPlug1;
    
    use base qw(Text::PSTemplate::PluginBase);
    
    sub say_hello_to : TplExport {
    
        my ($plugin, $name) = (@_);
        
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
    
    # ...later
    
    my $myplug2 = My::Plugin->new ### Always returns same instance 

=head2 $instance->set_ini($hash)

ini setter.

    $myplug->set_ini($hash_ref);

=head2 $instance->ini($key)

Returns ini data for given key.

    my $value = $myplug->ini($some_key);

Note that in list context, this always returns an array with 1 element.
If the key doesn't exists, this returns (undef).

=head2 $instance->die($message)

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
