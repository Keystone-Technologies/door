package Mojolicious::Plugin::RemoteAddressCondition;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app) = @_;

  # "remote_addr" condition
  $app->routes->add_condition(remote_address => sub { _check($_[1]->tx->remote_address, $_[3]) });
}

sub _check {
  my ($value, $pattern) = @_;
  return 1 if $value && $pattern && ref $pattern eq 'Regexp' && $value =~ $pattern;
  return $value && defined $pattern && $pattern eq $value ? 1 : undef;
}

1;
