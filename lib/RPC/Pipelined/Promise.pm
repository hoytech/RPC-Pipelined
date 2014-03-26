package RPC::Pipelined::Promise;

use strict;

our $AUTOLOAD;


sub AUTOLOAD {
  my $self = shift;

  my $name = $AUTOLOAD;
  $name =~ s/.*://;

  return if !$self->{client};

  my @args = ($self, $name, @_);

  if ($self->{client}->{queue_request}) {
    $self->{client}->{queue_request}->(@args);
  } else {
    $self->{client}->run(@args);
  }
}


sub _set_id {
  my ($self, $id) = @_;

  die "promise already has an id"
    if exists $self->{id};

  $self->{id} = $id;
}


sub DESTROY {
}


sub FREEZE {
  my ($self, $serializer) = @_;
  return $self->{id};
}
 
sub THAW {
  my ($class, $serializer, $data) = @_;
  bless { id => $data }, $class;
}


1;
