use strict;
use warnings;
use lib 'lib';
use Test::Memory::Cycle;
use Test::More;
use Text::PSTemplate;

use Test::More tests => 2;

my $tpl = Text::PSTemplate->new;
my $ctrl = $tpl->get_plugin('Text::PSTemplate::Plugin::Control');
memory_cycle_ok( $ctrl );
memory_cycle_ok( $tpl );

__END__