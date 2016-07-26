package DoorControl;
use Mojo::Base 'Mojolicious';
use Mojo::UserAgent;
use Mojo::Pg;
use Date::Manip;

use DoorControl::Model::DoorControl;
use DoorControl::Model::Authenticate;
use DoorControl::Model::Log;
use DoorControl::Model::Register;

use constant INTERNAL => qr/^127\.|^(172\.16\.254\.\d{1,3})$/;
use constant FULL_AUTHORIZATION => 1;
use constant LIMITED_AUTHORIZATION => 2;

# This method will run once at server start
sub startup {
  my $self = shift;
  
  push @{$self->commands->namespaces}, 'DoorControl::Command';
  
  $self->plugin('browser_detect');
  my $config = $self->plugin('Config');
  #exit unless necessary ulrs are defined in config
  #die "no access";
  
  $self->helper('unlock_url' =>{config => $self->config->{unlock_url}});
  $self->helper('lock_url' =>{config => $self->config->{lock_url}});

  Date_Init('WorkDayBeg = 07:00', 'WorkDayEnd = 18:00');

  $self->helper(internal => sub { shift->tx->remote_address=~INTERNAL?1:0 });
  $self->helper(pg => sub {state $pg = Mojo::Pg->new(shift->config('pg')) });
  $self->helper(doorcontrol => sub { state $doorcontrol = DoorControl::Model::DoorControl->new(FULL_AUTHORIZATION => FULL_AUTHORIZATION, unlock_url => @_[0]->config('unlock_url'), lock_url => @_[0]->config('lock_url')) });
  $self->helper(authenticate => sub { state $authenticate = DoorControl::Model::Authenticate->new(pg => shift->pg) });
  $self->helper(logger => sub { state $log = DoorControl::Model::Log->new(pg => shift->pg) });
  $self->helper(register => sub { state $register = DoorControl::Model::Register->new(pg => shift->pg) });

  $self->sessions->default_expiration(86400*365*10);
  
  my $path = $self->home->rel_file('migrations/doorcontrol.sql');
  $self->pg->migrations->name('doorcontrol')->from_file($path)->migrate;

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('DoorControl#init');
  $r->get('/forget')->to('DoorControl#forget')->name('forget');
  $r->get('/log/:count')->to('DoorControl#log')->name('log');
  $r->get('/register')->to('Register#index')->name('register');
  $r->get('/register/badges')->to('Register#badges')->name('badges');
  
  $r->post('/unlock')->to('DoorControl#unlock')->name('unlock');
  $r->post('/lock')->to("DoorControl#lock")->name('lock');
  $r->post('/register/signin')->to('Register#signin')->name('signin');
  $r->post('/register/adduser')->to('Register#adduser')->name('adduser');
  $r->post('/register/addbadge')->to('Register#addbadge')->name('addbadge');
}

1;
