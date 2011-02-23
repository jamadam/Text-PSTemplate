use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 't/lib';
use Text::PSTemplate::Plugable;
use Data::Dumper;
use File::Spec;

    __PACKAGE__->runtests;
    
    sub basic : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
        $tpl->set_var(a => 'hoge');
		my $parsed = $tpl->parse(q(test <% include('t/template/02_PST_Plugable_Control3.txt') %> test));
		is($parsed, 'test ok hoge test');
    }
    
    sub basedir : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		$tpl->set_filename_trans_coderef(sub{File::Spec->catfile('t/template', $_[0])});
        $tpl->set_var(a => 'hoge');
		my $parsed = $tpl->parse(q(test <% include('02_PST_Plugable_Control3.txt') %> test));
		is($parsed, 'test ok hoge test');
    }
    
    sub var_asign : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		$tpl->set_filename_trans_coderef(sub{File::Spec->catfile('t/template', $_[0])});
        $tpl->set_var(a => 'hoge');
		my $parsed = $tpl->parse(q(test <% include('02_PST_Plugable_Control3.txt', {a => 'foo'}) %> test));
		is($parsed, 'test ok foo test');
    }
    
    sub set_var : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		my $parsed = $tpl->parse(<<'EOF');
<% set_var(var1 => 'a', var2 => 'b') %>
<% $var1 %><% $var2 %>
EOF

		is($parsed, <<'EOF');

ab
EOF
    }
    
    sub set_delimiter : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new;
		my $parsed = $tpl->parse(<<'EOF');
<% set_var(var1 => 'a', var2 => 'b') %><% set_delimiter('%%', '%%') %>
%% $var1 %%%% $var2 %%
EOF

		is($parsed, <<'EOF');

ab
EOF
    }
