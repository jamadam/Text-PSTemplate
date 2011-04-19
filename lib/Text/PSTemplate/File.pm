package Text::PSTemplate::File;
use strict;
use warnings;
use Fcntl qw(:flock);
use Carp;

    my $MEM_FILENAME    = 1;
    my $MEM_CONTENT     = 2;
    
    sub new {
        
        my ($class, $name, $encode) = @_;
        my $fh;
        
        if (! $name) {
            die "file name is empty\n";
        }
        
        if ($encode) {
            open($fh, "<:encoding($encode)", $name) || die "File '$name' cannot be opened\n";
        } else {
            open($fh, "<:utf8", $name) || die "File '$name' cannot be opened\n";
        }
        if ($fh and flock($fh, LOCK_EX)) {
            my $out = do { local $/; <$fh> };
            close($fh);
            return bless {
                $MEM_FILENAME => $name,
                $MEM_CONTENT => $out,
            }, $class;
        } else {
            die "File '$name' cannot be opened\n";
        }
    }
    
    sub name {
        return $_[0]->{$MEM_FILENAME};
    }
    
    sub content {
        return $_[0]->{$MEM_CONTENT};
    }

1;

__END__

=head1 NAME

Text::PSTemplate::Block - A Class represents template blocks

=head1 SYNOPSIS
    
=head1 DESCRIPTION

This class represents template files. With this class, you can take file
contents with the original file path. This class instance can be thrown at
parse_file method and parse_str method. This is useful if you have to iterate
template parse for same file.

=head1 METHODS

=head2 TEXT::PSTemplate::File->new($filename)

Constractor. The filename must be given in string.

=head2 $instance->name

Returns file name may be with path name.

=head2 $instance->content

Returns file content.

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
