use strict;

use RPC::Pipelined::Client;
use RPC::Pipelined::Server;

use Test::More tests => 5;


my $c = RPC::Pipelined::Client->new;
my $s = RPC::Pipelined::Server->new;

sub add { $_[0] + $_[1] }
sub mult { $_[0] * $_[1] }

my $counter = 0;
sub inc_counter { $counter++ };


## Single non-pipelined call, no promises

{
  $c->run(undef, 'add', 7, 9);
  my $r = $c->unpack_response($s->exec($c->pack_msg));
  is($r->{val}, 16, '7+9');
}


## 2 pipelined calls, no promises

{
  $c->run(undef, 'inc_counter');
  is($counter, 0, 'counter not incremeted yet');
  $c->run(undef, 'mult', 8, 12);
  my $r = $c->unpack_response($s->exec($c->pack_msg));
  is($counter, 1, 'counter incremeted');
  is($r->{val}, 96, '8*12');
}


## 2 pipelined calls, promises passed in on second call

{
  my $pr = $c->run(undef, 'add', 30, 4);
  $c->run(undef, 'mult', $pr, $pr);
  my $r = $c->unpack_response($s->exec($c->pack_msg));
  is($r->{val}, 1156, '(30+4)**2');
}


## Queued messages, promises used across queue

{
  my $pr = $c->run(undef, 'add', 15, 13);
  $c->run(undef, 'mult', $pr, $pr);
  my $msg1 = $c->pack_msg;

  my $pr2 = $c->run(undef, 'add', 71, 42);
  $c->run(undef, 'mult', 5, $pr2);

  my $pr3 = $c->run(undef, 'mult', $pr, $pr2);
  my $pr4 = $c->run(undef, 'add', $pr3, $pr);
  $c->run(undef, 'mult', $pr, $pr4);

  my $r1 = $c->unpack_response($s->exec($msg1));
  my $msg2 = $c->pack_msg;
  my $r2 = $c->unpack_response($s->exec($msg2));
  my $msg3 = $c->pack_msg;
  my $r3 = $c->unpack_response($s->exec($msg3));

  print "$r1->{val}\n";
  print "$r2->{val}\n";
  print "$r3->{val}\n";
}
