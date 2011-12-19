use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use Test::More;
use Text::PSTemplate;
use Data::Dumper;
use File::Spec;
    
	use Test::More tests => 2;
    
    my $tpl;
    my $parsed;
    
    $tpl = Text::PSTemplate->new;
    $parsed = $tpl->parse_file('t/03_PST_Plugable/template/Control4_1.txt');
    is($parsed, 'ok');
    
    $tpl = Text::PSTemplate->new;
    $tpl->plug('Test::DB', '');
    $parsed = $tpl->parse_file('t/03_PST_Plugable/template/Control4_4.txt');
    is($parsed, 'a:30:a:30:okb:31:okc:32:ok//b:31:a:30:okb:31:okc:32:ok//c:32:a:30:okb:31:okc:32:ok//');

### ---
### row DB plugin
### ---
package Test::DB;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);

    sub list : TplExport {
        
        my ($self, $file) = @_;
        my $tpl = NT::Plugin::DB::RowTemplate->new;
        my $data = [
            {name => 'a', age => 30},
            {name => 'b', age => 31},
            {name => 'c', age => 32},
        ];
        my $out = '';
        my $tpl_str = $tpl->get_file($file);
        while (my $result = shift @$data) {
            $tpl->list_row_loop(
                data        => $result,
                fields      => ['name', 'age'],
            );
            $out .= $tpl->parse_str($tpl_str);
        }
        return $out;
    }

### ---
### row template
### ---
package NT::Plugin::DB::RowTemplate;
use strict;
use warnings;
use base qw(Text::PSTemplate);
    
    sub set_table_info {
        
        my ($self, $tableinfo) = (@_);
        $self->{_RowTemplate_tableinfo} = $tableinfo;
    }
    
    sub list_row_loop {
        
        my ($self, %args) = (@_);
        my $row_num = 0;
        foreach my $key (@{$args{fields}}) {
            $self->set_var(
                $row_num =>
                    defined $args{data}->{$key} ? $args{data}->{$key} : '',
            );
            $row_num++;
        }
    }
