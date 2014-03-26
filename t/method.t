use strict;

use RPC::Pipelined::Client;
use RPC::Pipelined::Server;

use Test::More tests => 1;


my $c = RPC::Pipelined::Client->new;
my $s = RPC::Pipelined::Server->new;

{
  package Mock::Obj;

  sub new {
    my ($class, %arg) = @_;
    bless \%arg, $class;
  }

  sub get {
    my ($self, $val) = @_;
    return uc $self->{$val};
  }
}

{
  my $generator = $c->run('Mock::Obj', 'new', blah => "hello");
  $generator->get("blah");
  my $r = $c->unpack($s->exec($c->prepare->pack));
  is($r->{val}, 'HELLO', 'got uc val');
}
