package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 4;

    my $tpl = Text::PSTemplate->new();
    $tpl->set_var(title => 'TITLE');
    is $tpl->parse(q!<% $title %>!), 'TITLE', 'right parsed result';
    is $tpl->parse(q!\\<% $title %>!), q!<% $title %>!, 'right parsed result';
    is $tpl->parse(q!\\\\<% $title %>!), '\\TITLE', 'right parsed result';
    is $tpl->parse(q!\\\\\\<% $title %>!), '\\<% $title %>', 'right parsed result';

__END__
