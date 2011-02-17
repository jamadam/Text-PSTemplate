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
			if (! exists $tpl->{pluged}->{$class}) {
				$$instance->_set_tpl_funcs($tpl);
				$tpl->{pluged}->{$class} = 1;
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
    
    my %_tpl_exports = ();
    
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
            
            ### Set template funcs in template object
            $tpl->set_func($plug_id. '::'. $subname => $rapper);
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

=head1 DESCRIPTION

This is an Abstract Class whitch represents plugins for
Text::PSTemplate::Plugable Class.

=head1 METHODS

=head2 new

=head2 set_ini

=head2 ini

=head1 ATTRIBUTE

=head2 TplExport

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
