package Text::PSTemplate::Plugable;
use strict;
use warnings;
use base qw(Text::PSTemplate);
use Text::PSTemplate::PluginBase;

our $VERSION = '0.01';
    
    sub plug {
        
        my ($self, $plug_array_ref) = (@_);
        foreach my $plug_name (@{$plug_array_ref}) {
            $plug_name->new($self);
        }
        $self->{pluged} = 1;
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
    
    my $tpl = tplText::PSTemplate::Plugable->new;
    $tpl->plug(['MyPlug1', ...]);
    $tpl->set_namespace_base('Foo::Bar');
    $tpl->set_default_plugin('Foo::Bar');
    $tpl->parse('...{%&say_hello_to('Kenji')%}...');
    
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

=head2 plug

=head2 set_namespace_base

=head2 set_default_plugin

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
