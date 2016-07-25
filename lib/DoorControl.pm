package DoorControl;
use Mojo::Base 'Mojolicious';
use Mojo::UserAgent;
use Mojo::Pg;
use Date::Manip;

use DoorControl::Model::DoorControl;
use DoorControl::Model::Authenticate;
use DoorControl::Model::Log;

use constant INTERNAL => qr/^127\.|^(172\.16\.254\.\d{1,3})$/;

# This method will run once at server start
sub startup {
  my $self = shift;
  
  push @{$self->commands->namespaces}, 'DoorControl::Command';
  
  $self->plugin('browser_detect');
  my $config = $self->plugin('Config');

  Date_Init('WorkDayBeg = 07:00', 'WorkDayEnd = 18:00');

  $self->helper(internal => sub { shift->tx->remote_address=~INTERNAL?1:0 });
  $self->helper(pg => sub {state $pg = Mojo::Pg->new(shift->config('pg')) });
  $self->helper(doorcontrol => sub { state $doorcontrol = DoorControl::Model::DoorControl->new(pg => shift->pg) });
  $self->helper(authenticate => sub { state $authenticate = DoorControl::Model::Authenticate->new(pg => shift->pg) });
  $self->helper(logger => sub { state $log = DoorControl::Model::Log->new(pg => shift->pg) });

  $self->sessions->default_expiration(86400*365*10);
  
  my $path = $self->home->rel_file('migrations/doorcontrol.sql');
  $self->pg->migrations->name('doorcontrol')->from_file($path)->migrate;

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('DoorControl#init');
  $r->get('/forget')->to('DoorControl#forget');
  $r->get('/log/:count')->to('DoorControl#log');
  $r->get('/register')->to('Register#index');
  $r->get('/register/badges')->to('Register#badges');
  
  $r->post('/unlock')->to('DoorControl#unlock');
  $r->post('/lock')->to("DoorControl#lock");
  $r->post('/register/signin')->to('Register#signin');
  $r->post('/register/adduser')->to('Register#adduser');
  $r->post('/register/addbadge')->to('Register#addbadge');
}

1;
