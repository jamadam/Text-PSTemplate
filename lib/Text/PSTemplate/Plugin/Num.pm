package Text::PSTemplate::Plugin::Num;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use Text::PSTemplate;
    
    ### ---
	### Conver to comma separated number
    ### ---
    sub commify : TplExport {
        
        my ($self, $num) = @_;
		
        if ($num) {
            while($num =~ s/(.*\d)(\d\d\d)/$1,$2/){};
            return $num;
        }
        if ($num eq '0') {
            return 0;
        }
        return;
    }

1;

__END__

=head1 NAME

Text::PSTemplate::Plugin::Num - 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 TEMPLATE FUNCTIONS

=head2 commify

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
