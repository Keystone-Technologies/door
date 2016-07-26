package DoorControl::Controller::Register;
use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $self = shift;
    
    $self->render(template => 'Register/index', format => 'html', handler => 'ep');
}

sub signin {
    my $self = shift;
    
    my $name = $self->param('name');
    my $pin = $self->param('pin');
    
    my $response->{results} = 0;
    
    my $authorized = $self->authenticate->authenticateUser($name, $pin);
    
    if($authorized == DoorControl::FULL_AUTHORIZATION) {
        $response->{results} = 1;
    };
    
    $self->render(json => $response);
}

sub adduser {
    my $self = shift;
    
    my $name = $self->param('name');
    my $pin = $self->param('pin');
    my $newName = $self->param('newName');
    my $newPin = $self->param('newPin');
    my $auth = $self->param('auth');
    
    my $response->{results} = 0;
    
    my $authorized = $self->authenticate->authenticateUser($name, $pin);
    
    if($authorized == DoorControl::FULL_AUTHORIZATION) {
        $response->{results} = 1;
        $self->register->insertUser($newName, $newPin, $auth);
    };
    
    $self->render(json => $response);
}

sub badges {
    my $self = shift;
    
    my $name = $self->param('name');
    my $pin = $self->param('pin');
    my $start = $self->param('start');
    my $end = $self->param('end');
    
    my $authorized = $self->authenticate->authenticateUser($name, $pin);
    
    my $results;
    
    if($authorized == DoorControl::FULL_AUTHORIZATION) {
        $results = eval {
            $self->register->getBadges($start, $end);
        };
    };
    
    $self->render(json => $results);
}

sub addbadge {
    my $self = shift;
    
    my $name = $self->param('name');
    my $pin = $self->param('pin');
    my $badge = $self->param('badge');
    my $newName = $self->param('newName');
    my $auth = $self->param('auth');
    
    my $response->{results} = 0;
    
    my $authorized = $self->authenticate->authenticateUser($name, $pin);
    
    if($authorized == DoorControl::FULL_AUTHORIZATION) {
        $response->{results} = 1;
        $self->register->deleteBadge($badge);
        $self->register->insertBadge($badge, $newName, $auth);
    };
    
    $self->render(json => $response);
}

1;
