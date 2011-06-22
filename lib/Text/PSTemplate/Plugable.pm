package Text::PSTemplate::Plugable;
use strict;
use warnings;
use Scalar::Util qw{blessed};
use Carp;
use base qw(Text::PSTemplate);
use Text::PSTemplate::PluginBase;
use Scalar::Util qw(weaken);

    #my @CORE_LIST = qw(Control Env Extends Util);
    my %CORE_LIST = (
        Control => '',
        Env     => '',
        Extends => '',
        Util    => '',
        FS      => 'FS',
    );

    sub new {
        
        my $class = shift;
        my $self = $class->SUPER::new(@_);
        
        if (! scalar @_) {
            for my $key (keys %CORE_LIST) {
                $self->plug('Text::PSTemplate::Plugin::'. $key, $CORE_LIST{$key});
            }
        }
        
        return $self;
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

1;

__END__

=head1 NAME

Text::PSTemplate::Plugable - Plugable template engine [DEPRECATED]

=head1 SYNOPSIS

    use Text::PSTemplate::Plugable;
    
    my $tpl = Text::PSTemplate::Plugable->new;
    
    $tpl->plug('MyPlug');
    $tpl->plug('MyPlug','My::Name::Space');
    
    $tpl->parse('...<% say_hello_to('Nick') %>...');
    
    package MyPlug;
    use strict;
    use warnings;
    use base qw(Text::PSTemplate::PluginBase);
    sub say_hello_to : TplExport(chop => 1) {
        my ($plugin, $name) = (@_);
        return "Hello $name";
    }

=head1 DESCRIPTION

Text::PSTemplate::Plugable Class is a sub class of Text::PSTemplate.
This extends some feature to Text::PSTemplate plugable.

=head1 METHODS

=head2 Text:PSTemplate::Plugable->new($mother)

Constractor. This only does SUPER::new and loads some core plugins. See also
new constractor of L<Text:PSTemplate>.

    my $template = Text:PSTemplate::Plugable->new();

=head2 $instance->plug($package, $namespace)

This method activates a plugin into your template instance.

    $instance->plug('Path::To::SomePlugin');

The functions will available as follows.

    <% Path::To::SomePlugin::some_function(...) %>

You can load plugins into specific namespaces.

    $instance->plug('Path::To::SomePlugin', 'MyNamespace');

This functions will available as follows

    <% MyNamespace::some_function(...) %>

You can marge plugins into single namespace or even the root namespace which
used by core plugins.

    $instance->plug('Plugin1', 'MyNamespace');
    $instance->plug('Plugin2', 'MyNamespace');
    $instance->plug('Plugin1', '');

=head2 $instance->get_plugin($name)

This method returns the plugin instance for given name.

=head2 $instance->get_as($plug_id)

This method returns the namespace for the plugin. Since it's just to be called
from PluginBase abstract class, you don't warry about it.

=head2 get_func_list

Output list of available template function in text format.

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
