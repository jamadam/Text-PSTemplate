use strict;
use warnings;
use ExtUtils::MakeMaker;

my %params = (
    NAME          => 'Text::PSTemplate',
    AUTHOR        => 'Sugama Keita <sugama@jamadam.com>',
    VERSION_FROM  => 'lib/Text/PSTemplate.pm',
    ABSTRACT_FROM => 'lib/Text/PSTemplate.pm',
    LICENSE       => 'perl',
    PREREQ_PM     => {
    },
    BUILD_REQUIRES => {
        'Test::Class' => '0.36',
        'Test::More'          => '0.47',
        'Test::UseAllModules' => '0.10',
        'Try::Tiny'           => '0.06',
    },
    META_MERGE => {
        resources => {
            repository => '',
        },
    },
    test => {TESTS => 't/*.t t/*/*.t'},
);

my $eumm = $ExtUtils::MakeMaker::VERSION;
delete $params{LICENSE}          if $eumm < 6.31;
delete $params{MIN_PERL_VERSION} if $eumm < 6.48;
delete $params{META_MERGE}       if $eumm < 6.46;
delete $params{META_ADD}         if $eumm < 6.46;
delete $params{LICENSE}          if $eumm < 6.31;

if ($eumm < 6.52 && $params{CONFIGURE_REQUIRES}) {
    $params{PREREQ_PM} = {
        %{ $params{PREREQ_PM}          || {} },
        %{ $params{CONFIGURE_REQUIRES} },
    };
    delete $params{CONFIGURE_REQUIRES};
}
if ($eumm < 6.5503 && $params{BUILD_REQUIRES}) {
    $params{PREREQ_PM} = {
        %{ $params{PREREQ_PM}      || {} },
        %{ $params{BUILD_REQUIRES} },
    };
    delete $params{BUILD_REQUIRES};
}

WriteMakefile(%params);
