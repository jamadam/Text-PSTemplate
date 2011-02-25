package Text::PSTemplate::PluginBase;
use strict;
use warnings;
use Text::PSTemplate;
use Attribute::Handlers;
use 5.005;
use Scalar::Util qw{blessed};
use Class::C3;
use base qw(Class::FileCacheable::Lite);
use Carp;

    my %_tpl_exports = ();
    
    ### ---
    ### Constractor
    ### ---
    sub new {
        
        my ($class, $tpl) = (@_);
        no strict 'refs';
        my $instance = \${$class. '::_instance'};
        if (! blessed($$instance)) {
            foreach my $pkg (@{$class. '::ISA'}) {
                if ($pkg ne __PACKAGE__) {
                    $pkg->new($tpl);
                }
            }
            $$instance = bless {ini => {}}, $class;
        }
        if ($tpl && $tpl->isa('Text::PSTemplate::Plugable')) {
            if (! exists $tpl->{pluged}->{$class}->{ok}) {
                $$instance->_set_tpl_funcs($tpl);
                $tpl->{pluged}->{$class}->{ok} = 1;
            }
        }
        return $$instance;
    }
    
    ### ---
    ### Get ini
    ### ---
    sub ini {
        
        my ($self, $name) = (@_);
        
        if (exists $self->{ini}->{$name}) {
            return $self->{ini}->{$name};
        } else {
            no strict 'refs';
            for my $pkg (Class::C3::calculateMRO(ref $self)) {
                if ($pkg eq __PACKAGE__) {
                    return (undef) if wantarray;
                    return;
                }
                my $ret = $pkg->new->{ini}->{$name};
                if (defined $ret) {
                    return $ret;
                }
            }
            return (undef) if wantarray;
            return;
        }
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
        if (! blessed $self) {
            $self = $self->new;
        }
        $self->{ini} = $hash || {};
        return $self;
    }
    
    ### ---
    ### Template function Attribute
    ### ---
    sub TplExport : ATTR(CHECK) {
        
        my($pkg, $sym, undef, undef, undef, undef) = @_;
        push(@{$_tpl_exports{$pkg}}, $sym);
    }
    
    ### ---
    ### Register template functions
    ### ---
    sub _set_tpl_funcs {
        
        my ($self, $tpl) = (@_);
        
        my @namespaces = ();
        
        my $org = ref $self;
        my $as = $tpl->get_as($org);
        if (defined $as) {
            push(@namespaces, $as);
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
        
        foreach my $sym (@$_tpl_exports) {
            my $ref = \&$sym;
            my $rapper = sub {
                my $ret = $self->$ref(@_);
                return (defined $ret ? $ret : '');
            };
            my $subname = ((scalar *$sym) =~ m{([^:]+$)})[0];
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
            (Text::PSTemplate::context) ? ' at '. Text::PSTemplate::context : '';
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
    
    # or
    
    $tpl->plug('MyPlug1', 'AnyNamespace');
    
    package MyPlug1;
    
    use base qw(Text::PSTemplate::PluginBase);
    
    sub say_hello_to : TplExport {
    
        my ($plugin, $name) = (@_);
        
        return "Hello $name";
    }
    
    # in templates ..
    # <% say_hello_to('Jamadam') %>

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

The Plugins are thought of singleton pattern so each plugins instanciates the
one and only one instance. The new constractor also behave as instance
getter. The plugin classes can contain subroutins with TplExport attribute.
These subroutins are targeted as template function.

Text::PSTemplate::PluginBase is a sub class of Class::FileCacheable so
subtoutins can have FileCacheable attribute. See also
L<Class::FileCacheable>.

The Plugins can inherit other plugins. The new constractor automatically
instanciates all depended plugins and template functions are inherited even in
templates.

This class also capable of managing ini datas for each plugins.

=head1 METHODS

=head2 Text::PSTemplate::PluginBase->new($template)

Constractor and instance getter. This makes an singleton instance for the
plugin. This takes plugable template instance as argument.

    my $tpl = Text::PSTemplate::Plugable->new;
    my $myplug = My::Plug->new($tpl);
    
    # ...later
    
    my $myplug2 = My::Plugin->new ### Always returns same instance 

=head2 $instance->set_ini($hash)

ini setter.

    $myplug->set_ini($hash_ref);

=head2 $instance->ini($key)

ini getter. The ini settings inherits the super classes. If your Plugin don't
have ini setting for given key by itself, this method searches the super class's
ini with C3 algorithm.

    my $value = $myplug->ini($some_key);

=head2 $instance->die($message)

=head1 ATTRIBUTE

=head2 TplExport

This attribute makes the subroutine availabe in templates.

    sub your_func : TplExport {
        
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
