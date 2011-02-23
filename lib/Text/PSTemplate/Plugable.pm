package Text::PSTemplate::Plugable;
use strict;
use warnings;
use Carp;
use base qw(Text::PSTemplate);
use Text::PSTemplate::PluginBase;
use Text::PSTemplate::Plugin::Control;
use Text::PSTemplate::Plugin::Num;
use Text::PSTemplate::Plugin::Env;

our $VERSION = '0.01';
our @CORE_LIST = qw(Control Num Env);

	sub new {
		
		my $class = shift;
		my $tpl = bless $class->SUPER::new(@_), $class;
		
		for my $name (@CORE_LIST) {
			$tpl->plug('Text::PSTemplate::Plugin::'. $name, '');
		}
		
		return $tpl;
	}
	
    sub plug {
        
        my ($self, $plugin, $as) = (@_);
        
        $self->{pluged} ||= {};
        
        if (ref $plugin eq 'ARRAY') {
            foreach my $plug_name (@{$plugin}) {
                $plug_name->new($self);
            }
        } else {
            $self->{pluged}->{$plugin} = {as => $as};
            $plugin->new($self);
        }
    }
    
	sub get_as {
		
		my ($self, $plug_id) = @_;
		return $self->{pluged}->{$plug_id}->{as};
	}
	
	sub get_base {
		
		my ($self, $plug_id) = @_;
		if (my $namespace_base = $self->{namespace_base}) {
			$plug_id =~ s{^$namespace_base\:\:}{};
			return $plug_id;
		}
		return;
	}
	
    sub set_namespace_base {
        
        my $self = shift;
        $self->{namespace_base} = shift;
    }
    
    sub set_default_plugin {
        
        my $self = shift;
        $self->{default_plugin} = shift;
    }
1;

__END__

=head1 NAME

Text::PSTemplate::Plugable - Plugable template engine

=head1 SYNOPSIS

    use Text::PSTemplate::Plugable;
    
    my $tpl = Text::PSTemplate::Plugable->new;
    
    $tpl->plug(['MyPlug1', 'MyPlug2' ...]);
    # or..
    $tpl->plug('MyPlug1','My::Name::Space');
    $tpl->plug('MyPlug2','My::Name::Space');
    #...
    
    $tpl->set_namespace_base('Foo::Bar');
    $tpl->set_default_plugin('Foo::Bar');
    
    $tpl->parse('...<% say_hello_to('Kenji') %}...');
    
    package MyPlug1;
    use strict;
    use warnings;
    use base qw(Text::PSTemplate::PluginBase);
    sub say_hello_to : TplExport {
        my ($plugin, $name) = (@_);
        return "Hello $name";
    }

=head1 DESCRIPTION

Text::PSTemplate::Plugable Class is a sub class of Text::PSTemplate.
This extends some feature to Text::PSTemplate plugable.

=head1 METHODS

=head2 Text:PSTemplate::Plugable->new(%args)

Constractor. This only does SUPER::new and loads some core plugins. See also
new constractor of L<Text:PSTemplate>.

    my $template = Text:PSTemplate::Plugable->new();

=head2 $instance->plug($array_ref, $namespace)

This method adds some controll structures into your PSTemplate instance.

    $instance->plug('Path::To::SomePlugin');

The plugins will available as follows.

    <% Path::To::SomePlugin::some_function(...) %>

Or you can set an alias name as follows.

    $instance->plug('Path::To::SomePlugin', 'MyNamespace');

This plugin will available as follows

    <% MyNamespace::some_function(...) %>

You can marge plugins into single namespace.

    $instance->plug(['Plugin1','Plugin2',...], 'MyNamespace');

=head2 $instance->get_base($plug_id) [experimental];

=head2 $instance->set_namespace_base [experimental]

This method sets a namespace base. Namespace base strips long modificated
functions into short. If you set 'A::B' for namespace base, A::B::func()
can call as just func(). Also, A::B::C::func() is active as C::func().

=head2 $instance->set_default_plugin [experimental]

Default plugin setting causes the fucntions can be called as ::func() style.

=head2 $instance->get_as($plug_id)

This method returns the namespace for the plugin. Since it's just to be called
from PluginBase abstract class, you don't warry about it.

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
