package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 'lib';
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub crop : Test(4) {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->set_var(title => 'TITLE');
        $tpl->set_func(func => sub {
			Text::PSTemplate->set_chop(1);
			return $_[0];
		});
        my $parsed1 = $tpl->parse(qq{<% func(\$title) %><% \$title %>\n});
        is($parsed1, "TITLETITLE\n");
        my $parsed2 = $tpl->parse(qq{<% func(\$title) %>\n\n<% \$title %>});
        is($parsed2, "TITLE\nTITLE");
        my $parsed3 = $tpl->parse(qq{<% func(\$title) %>\n<% \$title %>});
        is($parsed3, "TITLETITLE");

        $tpl->set_func(func2 => sub {
			Text::PSTemplate->set_chop(0);
			return $_[0];
		});
		
        my $parsed4 = $tpl->parse(qq{<% func2(&func(\$title)) %>\n<% \$title %>});
        is($parsed4, "TITLE\nTITLE");
    }
