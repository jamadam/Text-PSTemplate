package Text::PSTemplate::Plugin::Extends;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use Text::PSTemplate::Plugable;

our $VERSION = '0.01';
    
    ### ---
    ### Extend
    ### ---
    sub extends : TplExport {
        
        my ($self, $file) = @_;
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->plug('Text::PSTemplate::Plugin::Extends::_Sub', '');
        $tpl->parse(Text::PSTemplate::inline_data(0));
        return $tpl->parse_file($file);
    }

package Text::PSTemplate::Plugin::Extends::_Sub;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use Text::PSTemplate;
    
    ### ---
    ### block specification
    ### ---
    sub block : TplExport {
        
        my ($self, $name) = @_;
        my $tpl = Text::PSTemplate->mother;
        $tpl->set_var($name => $tpl->parse(Text::PSTemplate::inline_data(0)));
        return;
    }
    
    ### ---
    ### placeholder specification
    ### ---
    sub placeholder : TplExport {
        
        my ($self, $name) = @_;
        my $tpl = Text::PSTemplate::mother;
        if (my $val = $tpl->var($name)) {
            return $val;
        } else {
            return $tpl->parse(Text::PSTemplate::inline_data(0));
        }
    }

1;

__END__

=head1 NAME

Text::PSTemplate::Plugin::Extends - Port of Extends syntax from Django
[EXPERIMENTAL]

=head1 SYNOPSIS

    base.html
    
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
        <link rel="stylesheet" href="style.css" />
        <title><% placeholder('title')<<DEFAULT %>My amazing site<% DEFAULT %></title>
    </head>
    
    <body>
        <div id="sidebar">
            <% placeholder('sidebar')<<DEFAULT %>
            <ul>
                <li><a href="/">Home</a></li>
                <li><a href="/blog/">Blog</a></li>
            </ul>
            <% DEFAULT %>
        </div>
    
        <div id="content">
            <% placeholder('content')<<DEFAULT %><% DEFAULT %>
        </div>
    </body>
    </html>
    
    child.html
    
    <% extends('base.html')<<EXTENDS %>
        <% block('title')<<BLOCK %>My amazing blog<% BLOCK %>
        <% block('content')<<BLOCK %><% each($blog_entries, 'entry')<<ENTRIES %>
            <h2><% $entry->{title} %></h2>
            <p><% $entry->{body} %></p>
        <% ENTRIES %><% BLOCK %>
    <% EXTENDS %>

=head1 DESCRIPTION

This is a Plugin for Text::PSTemplate. This adds Common controll structures into
your template engine.

To activate this plugin, your template have to load it as follows

    use Text::PSTemplate::Plugable;
    use Text::PSTemplate::Plugin::Control;
    
    my $tpl = Text::PSTemplate::Plugable->new;
    $tpl->plug('Text::PSTemplate::Plugin::Control', '');

=head1 TEMPLATE FUNCTIONS

=head2 extends

=head2 block

=head2 placeholder

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
