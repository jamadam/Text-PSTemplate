package Text::PSTemplate::PluginBase;
use strict;
use warnings;
use Text::PSTemplate;
use Attribute::Handlers;
use 5.005;
use Scalar::Util qw{blessed};
use Class::C3;
use base qw(Class::FileCacheable::Lite);

our $VERSION = '0.01';
    
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
                    return undef;
                }
                my $ret = $pkg->new->{ini}->{$name};
                if (defined $ret) {
                    return $ret;
                }
            }
            return undef;
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
        
        my $plug_id = ref $self;
        my $as = $tpl->{pluged}->{$plug_id}->{as};
        
        if (my $namespace_base = $tpl->{namespace_base}) {
            $plug_id =~ s{$namespace_base\:\:}{};
        }

        my $_tpl_exports = _get_tpl_exports(ref $self);
        
        foreach my $sym (@$_tpl_exports) {
            
            my $ref = \&$sym;
            my $rapper = sub {
                #my $self = (blessed($_[0])) ? shift : $self;
                my $ret = $self->$ref(@_);
                return (defined $ret ? $ret : '');
            };
            
            my $subname = ((scalar *$sym) =~ m{([^:]+$)})[0];
            
            $tpl->set_func($plug_id. '::'. $subname => $rapper);
            if (defined $as) {
                if ($as) {
                    $tpl->set_func($as. '::'. $subname => $rapper);
                } else {
                    $tpl->set_func($subname => $rapper);
                }
            }
            
            if (my $default_plugin = $tpl->{default_plugin}) {
                if ($plug_id eq $default_plugin) {
                    $tpl->set_func($subname => $rapper);
                } elsif ($plug_id =~ /^$default_plugin\::(.+)/) {
                    $tpl->set_func('::'. $1. '::'. $subname => $rapper);
                }
            }
        }
        
        return $self;
    }

1;

__END__

=head1 NAME

Text::PSTemplate::PlugBase - Plugin Abstract Class

=head1 SYNOPSIS

    package MyPlug1;
    use strict;
    use warnings;
    use base qw(Text::PSTemplate::PluginBase);
    
    sub say_hello_to : TplExport {
        my ($plugin, $name) = (@_);
        return "Hello $name";
        
        my $value = $plugin->ini('some_key');
    }
    
    # in templates ..
    # {% &say_hello_to('Jamadam') %}

    # Template functions can be cached into files
    
    use LWP::Simple;
    
    sub insert_remote_data : TplExport FileCacheable {
        my ($plugin, $url) = (@_);
        return LWP::Simple::get($url);
    }
    
    # in templates ..
    # {% &insert_remote_data('http://example.com/') %}
    
=head1 DESCRIPTION

[DRAFT]

This is an Abstract Class which represents plugins for
Text::PSTemplate::Plugable.

The Plugins are thought of singleton pattern so each plugins instanciates the
one and only one instance. The new constractor is also behave as instance
getter.

The plugin classes can contain subroutins with TplExport attribute. These
subroutins are targeted as template function.

Text::PSTemplate::PluginBase is a sub class of Class::FileCacheable so
subtoutins can have FileCacheable attribute. See also
L<Class::FileCacheable>.

The Plugins can inherit other plugins. The new constractor automatically
instanciates all depended plugins and template functions are inherited even in
templates.

This class also manage ini datas for each plugins.

=head1 METHODS

=head2 new

Constractor. This makes 

=head2 set_ini

ini setter

=head2 ini

ini getter

=head1 ATTRIBUTE

=head2 TplExport

=head2 FileCacheable

See L<Class::FileCacheable>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
