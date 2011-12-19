package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 6;
    
    my $tpl;
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_filter('', sub {$_[0]. '+'});
    $tpl->set_var(foo => 'bar');
    is $tpl->parse(q{<% $foo %>}), 'bar+';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_filter('=', sub {$_[0]. '+'});
    $tpl->set_var(foo => 'bar');
    is $tpl->parse(q{<%= $foo %>}), 'bar+';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_filter('=', sub {$_[0]. '+'});
    $tpl->set_filter('=', sub {$_[0]. '-'});
    $tpl->set_filter('==', sub {$_[0]. '1'});
    $tpl->set_filter('==', sub {$_[0]. '2'});
    $tpl->set_var(foo => 'bar');
    is $tpl->parse(q{<%= $foo %>}), 'bar+-';
    is $tpl->parse(q{<%== $foo %>}), 'bar12';
        
    $tpl = Text::PSTemplate->new;
    $tpl->set_delimiter('<%=','%>');
    $tpl->set_filter('', \&escape);
    $tpl->set_var(foo => '&');
    is $tpl->parse(q{<%= $foo %>}), '&amp;';
    is $tpl->parse(q{<%== $foo %>}), '&';
    
    sub escape {
        
        my ($html) = @_;
        $html =~ s/&/&amp;/go;
        $html =~ s/</&lt;/go;
        $html =~ s/>/&gt;/go;
        $html =~ s/"/&quot;/go;
        $html =~ s/'/&#39;/go;
        return $html;
    }
