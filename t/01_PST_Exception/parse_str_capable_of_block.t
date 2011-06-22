package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
	sub normal : Test(1) {
        my $rend = Text::PSTemplate->new;
		$rend->plug('SomePlug', '');
		my $parsed = $rend->parse(q{<% hoge3('parsed') %>});
		is($parsed, 'parsedparsedparsed');
	}
    
	sub block : Test(1) {
        my $rend = Text::PSTemplate->new;
		$rend->plug('SomePlug', '');
		my $parsed = $rend->parse(q{<% hoge3()<<TPL,TPL2 %>parsed<% TPL %>parsed<% TPL2 %>});
		is($parsed, 'parsedparsedparsed');
	}
    
	sub block_err : Test(2) {
        my $rend = Text::PSTemplate->new;
		$rend->plug('SomePlug', '');
		eval {
			$rend->parse_file('./t/01_PST_Exception/template/parse_str_capable_of_block.txt');
		};
		like($@, qr/parse_str_capable_of_block.txt/);
		like($@, qr/line 10/);
	}

package SomePlug;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);

	sub hoge3 : TplExport {
		
		my ($self, $tpl) = @_;
		my $rend = Text::PSTemplate->new;
		my $out = '';
		if ($tpl) {
			for my $i (1..3) {
				$out .= $rend->parse_str($tpl);
			}
		} else {
			for my $i (1..3) {
				$out .= $rend->parse_block(1);
			}
		}
		return $out;
	}
