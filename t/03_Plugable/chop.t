use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
use Data::Dumper;

	use Test::More tests => 5;
    
    my $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::Plugin1','');
    my $parsed1 = $tpl->parse(q[a<% test1('b') %>c]);
    is($parsed1, 'abc');
    my $parsed2 = $tpl->parse(qq[a<% test1('b') %>\nc]);
    is($parsed2, "ab\nc");
    my $parsed3 = $tpl->parse(qq[a<% test2('b') %>\nc]);
    is($parsed3, "abc");
    my $parsed4 = $tpl->parse(qq[a<% test1(&test2('b')) %>\nc]);
    is($parsed4, "ab\nc");
    my $parsed5 = $tpl->parse(qq[a<% test2(&test1('b')) %>\nc]);
    is($parsed5, "abc");

package Test::Plugin1;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
    
    sub test1 : TplExport {
        
        my ($self, $str) = @_;
        return $str;
    }
    
    sub test2 : TplExport(chop => 1) {
        
        my ($self, $str) = @_;
        return $str;
    }