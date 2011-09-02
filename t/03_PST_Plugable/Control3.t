use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
use File::Spec;

    __PACKAGE__->runtests;
    
    sub basic : Test(1) {
        
        my $tpl = Text::PSTemplate->new;
        $tpl->set_var(a => 'hoge');
		my $parsed = $tpl->parse(q(test <% include('t/03_PST_Plugable/template/Control3.txt') %> test));
		is($parsed, 'test ok hoge test');
    }
    
    sub basedir : Test(1) {
        
        my $tpl = Text::PSTemplate->new;
		$tpl->set_filename_trans_coderef(sub{File::Spec->catfile('t/03_PST_Plugable/template', $_[0])});
        $tpl->set_var(a => 'hoge');
		my $parsed = $tpl->parse(q(test <% include('Control3.txt') %> test));
		is($parsed, 'test ok hoge test');
    }
    
    sub var_asign : Test(1) {
        
        my $tpl = Text::PSTemplate->new;
		$tpl->set_filename_trans_coderef(sub{File::Spec->catfile('t/03_PST_Plugable/template', $_[0])});
        $tpl->set_var(a => 'hoge');
		my $parsed = $tpl->parse(q(test <% include('Control3.txt', {a => 'foo'}) %> test));
		is($parsed, 'test ok foo test');
    }
    
    sub set_var : Test(1) {
        
        my $tpl = Text::PSTemplate->new;
		my $parsed = $tpl->parse(<<'EOF');
<% assign(var1 => 'a', var2 => 'b') %>
<% $var1 %><% $var2 %>
EOF

		is($parsed, <<'EOF');
ab
EOF
    }
    
    sub set_delimiter : Test(1) {
        
        my $tpl = Text::PSTemplate->new;
		my $parsed = $tpl->parse(<<'EOF');
<% assign(var1 => 'a', var2 => 'b') %>
<% set_delimiter('%%', '%%') %>
%% $var1 %%%% $var2 %%
EOF

		is($parsed, <<'EOF');
ab
EOF
    }
    
    sub bypass : Test(1) {
        
        my $tpl = Text::PSTemplate->new;
		my $parsed = $tpl->parse(q{<% bypass('aa') %>});
		is($parsed, q{});
    }
    
    sub regex_capture_bug : Test(1) {
        
        my $tpl = Text::PSTemplate->new;
		my $parsed = $tpl->parse(<<EOF);
<% if(1)<<EOF1 %>
	<% if(1)<<EOF2 %>1<% EOF2 %>
	<% if(1, '1')%>
	<% if(1)<<EOF2 %>1<% EOF2 %>
<% EOF1 %>
EOF

		is($parsed, <<EOF);
	1
	1
	1
EOF
    }
