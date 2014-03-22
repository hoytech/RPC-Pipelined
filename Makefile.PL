use strict;

use ExtUtils::MakeMaker;


my %args = (
    NAME => 'RPC::Pipelined',
    VERSION_FROM => 'lib/RPC/Pipelined.pm',
    PREREQ_PM => {
      'Sereal::Encoder' => 2,
      'Sereal::Decoder' => 2,
      'Data::Rmap' => 0,
    },
    LIBS => [],
    DEFINE => '',
    LICENSE => 'perl',
    dist => {
      PREOP => 'perldoc -uT lib/RPC/Pipelined.pm > README.pod; pod2text README.pod > $(DISTVNAME)/README',
    },
);


my $eummv = eval ($ExtUtils::MakeMaker::VERSION);
if ($eummv >= 6.45) {
    $args{META_MERGE} = {
        resources => {
            repository => 'git://github.com/hoytech/RPC-Pipelined.git',
            bugtracker => 'https://github.com/hoytech/RPC-Pipelined/issues',
        },
    };
}

WriteMakefile(%args);
