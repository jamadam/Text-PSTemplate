package Template_Basic;
use strict;
use warnings;
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
    
	use Test::More tests => 11;
    
    my $tpl;
    
    $tpl = Text::PSTemplate->new;
    eval {$tpl->parse('<% undefined_func() %>')};
    like $@, qr{function &undefined_func undefined at t/02_Exception/error_message.t line 13}i, 'right error';
    like $@, qr{error_message\.t}, 'right error';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(a => sub{''});
    eval {$tpl->parse('<% a(1/0) %>')};
    like $@, qr/Illegal/i, 'right error';
    like $@, qr{error_message\.t}, 'right error';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(a => sub{''});
    eval {$tpl->parse_file('t/02_Exception/template/error_message.txt')};
    like $@, qr/function \&undef_func undefined/i, 'right error';
    like $@, qr/template\/error_message\.txt/, 'right error';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(a => sub{''});
    $tpl->set_var_exception($Text::PSTemplate::Exception::PARTIAL_NONEXIST_DIE);
    eval {$tpl->parse_file('t/02_Exception/template/error_message2.txt')};
    like $@, qr/variable \$undef undefined/i, 'right error';
    like $@, qr/template\/error_message2\.txt/, 'right error';
    
    $tpl = Text::PSTemplate->new;
    eval {$tpl->get_file('dummy.txt')};
    like $@, qr/not found/, 'right error';
    like $@, qr/dummy\.txt/, 'right error';
    
    $tpl = Text::PSTemplate->new;
    $tpl->set_func(a => sub {
        my $tpl2 = Text::PSTemplate->new;
        $tpl->parse('<% b() %>');
    });
    eval {$tpl->parse('<% a() %>')};
    like $@, qr/function &b undefined/i, 'right error';

__END__
