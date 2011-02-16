package Text::PSTemplate::Plugin;
package NT::Plugin;
use strict;
use warnings;
use Text::PSTemplate;
use Attribute::Handlers;
use 5.005;
use Scalar::Util qw{blessed};
use File::Spec;
use base qw(Class::FileCacheable::Lite);

our $VERSION = '0.05';

### ---
### Class::FileCachableオプション
### ---
sub file_cache_options {
	return {
		namespace => 'NT',
		cache_root => File::Spec->catdir('.', 'cache'),
	}
}

### ---
### constractor
### ---
sub new {
	
	my ($class, $ini_ref) = (@_);
	no strict 'refs';
	my $instance = \${$class. '::_instance'};
	if (! blessed($$instance)) {
		$$instance = bless {ini => {}}, $class;
		$$instance->set_ini($ini_ref);
		$$instance->_set_tpl_funcs();
		$$instance->init();
	}
	return $$instance;
}

### ---
### Set ini 
### ---
sub set_ini {
	
	my ($self, $hash) = (@_);
	$self->{ini} = ($hash || {});
    return $self;
}

### ---
### init
### ---
sub init {
	
}

### ---
### Get ini data by name
### ---
sub ini {
	
	my ($self, $name) = (@_);
	
	if (exists $self->{ini}->{$name}) {
		return $self->{ini}->{$name};
	}
}

my %_tpl_exports = ();

### ---
### テンプレート関数アトリビュート
### ---
sub TplExport : ATTR(CHECK) {
	
    my($pkg, $sym, undef, undef, undef, undef) = @_;
	push(@{$_tpl_exports{$pkg}}, $sym);
}

### ---
### テンプレート関数の登録
### ---
sub _set_tpl_funcs {
    
	my $self = shift;
	my $_tpl_exports = get_tpl_exports(ref $self);
	
    foreach my $sym (@$_tpl_exports) {
		
		my $ref = \&$sym;
		my $rapper = sub {
			my $self = (blessed($_[0])) ? shift : $self;
			my $ret = $self->$ref(@_);
			return (defined $ret ? $ret : '');
		};
		
		my @a = split(/::/, scalar *$sym);
		my $subname = pop(@a);
		
		### Set template funcs in template object
		NT->tpl->set_func((ref $self). '::'. $subname => $rapper);
	}
	
    return $self;
}

### ---
### テンプレート関数の配列を返す
### ---
sub get_tpl_exports {
	
	my $pkg = shift;
	my @out = ();
	no strict 'refs';
	foreach my $super (@{$pkg. '::ISA'}) {
		if ($super ne __PACKAGE__) {
			push(@out, @{get_tpl_exports($super)});
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

Text::PSTemplate::Plugin - 

=head1 SYNOPSIS

    use Text::PSTemplate::Plugin;
    Text::PSTemplate::Plugin->new;

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
