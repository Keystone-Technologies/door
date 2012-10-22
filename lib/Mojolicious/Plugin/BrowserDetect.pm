package Mojolicious::Plugin::BrowserDetect;
use Mojo::Base 'Mojolicious::Plugin';

use HTTP::BrowserDetect;
 
sub register {
  my ($self, $app, $conf) = @_;
  $app->helper(
    browser_detect => sub {
      my $self = shift;
      return HTTP::BrowserDetect->new($self->req->headers->user_agent);
    }
  );
}
 
1;
