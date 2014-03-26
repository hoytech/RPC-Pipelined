package RPC::Pipelined::Client;

use strict;

use Scalar::Util;
use Sereal::Encoder;
use Sereal::Decoder;

use RPC::Pipelined::Promise;


sub new {
  my ($class, %args) = @_;

  my $self = \%args;
  bless $self, $class;

  $self->{calls_building} = [];
  $self->{calls_in_flight} = [];

  return $self;
}


sub run {
  my ($self, @args) = @_;

  die "run only supports scalar and void context" if wantarray;

  my $call = { args => \@args, wa => wantarray, };

  if (defined wantarray) {
    $call->{promise} = { client => $self, };
    Scalar::Util::weaken($call->{promise}->{client});
    bless $call->{promise}, 'RPC::Pipelined::Promise';
  }

  push @{$self->{calls_building}}, $call;

  if (defined wantarray) {
    return $call->{promise};
  }

  return;
}

sub prepare {
  my ($self) = @_;

  my $calls = $self->{calls_building};
  $self->{calls_building} = [];

  push @{ $self->{calls_in_flight} }, $calls;

  return RPC::Pipelined::Client::Message->new({ cmd => 'do', calls => $calls, });
}

sub unpack {
  my ($self, $encoded_response) = @_;

  my $msg = Sereal::Decoder::decode_sereal($encoded_response, { freeze_callbacks => 1, });

  my $calls = shift @{ $self->{calls_in_flight} };

  foreach my $call (@$calls) {
    if (exists $call->{promise}) {
      $call->{promise}->_set_id(shift @{ $msg->{promise_ids} });
    }
  }

  delete $msg->{promise_ids};

  return $msg;
}

sub terminate {
  my ($self) = @_;

  return RPC::Pipelined::Client::Message->new({ cmd => 'dn', });
}



package RPC::Pipelined::Client::Message;

use strict;

use Sereal::Encoder;


sub new {
  my ($class, $data) = @_;

  my $self = { data => $data, };
  bless $self, $class;

  return $self;
}


sub pack {
  my ($self) = @_;

  return Sereal::Encoder::encode_sereal($self->{data}, { freeze_callbacks => 1, });
}


1;
