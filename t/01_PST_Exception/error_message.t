package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 13;
    
    my $tpl;
    
    $tpl = Text::PSTemplate->new;
    eval {$tpl->parse('<% undefined_func() %>')};
    like($@, qr/function/i);
    like($@, qr/undefined/i);
    like($@, qr{error_message.t});
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(a => sub{''});
    eval {$tpl->parse('<% a(1/0) %>')};
    like($@, qr/Illegal/i);
    like($@, qr{error_message\.t});
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(a => sub{''});
    eval {$tpl->parse_file('t/01_PST_Exception/template/error_message.txt')};
    like($@, qr/function/i);
    like($@, qr/undefined/i);
    like($@, qr/template\/error_message\.txt/);
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(a => sub{''});
    eval {$tpl->parse_file('t/01_PST_Exception/template/error_message2.txt')};
    like($@, qr/variable/i);
    like($@, qr/undefined/i);
    like($@, qr/template\/error_message2\.txt/);
    
    $tpl = Text::PSTemplate->new;
    eval {$tpl->get_file('dummy.txt')};
    like($@, qr/not found/);
    like($@, qr/dummy\.txt/);

__END__
