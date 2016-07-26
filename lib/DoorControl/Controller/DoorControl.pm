package DoorControl::Controller::DoorControl;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub init {
  my $self = shift;

  $self->stash(pin => $self->session->{pin}, name => $self->session->{name});
  $self->render(template => 'DoorControl/index', format => 'html', handler => 'ep');
}

sub unlock {
    my $self = shift;
    
    my $name = $self->param('name');
    my $pin = $self->param('pin');
    my $remember = $self->param('remember');
    
    my $results = "FAILED";
    my $response->{response} = 0;
    
    my $authorized = $self->authenticate->authenticateUser($name, $pin);
    
    $response->{response} = $self->doorcontrol->unlock($authorized, $self->internal);
    
    if($response->{response} == 1) {
        $results = "SUCCESS";
        
        if($remember) {
            $self->session->{pin} = $pin;
            $self->session->{name} = $name;
        }
    }
    
    $self->logger->log($name, 'unlock', $results, 'website');
    
    $self->render(json => $response);
}

sub lock {
    my $self = shift;
    #locks the door, maybe happens automatically after unlocking it?
    my $response->{response} = $self->doorcontrol->lock();
    
    $self->logger->log("Door", "Lock", $response->{response} ? 'SUCCESS' : 'FAILED', "website");
    
    $self->render(json => $response);
}

sub log {
    my $self = shift;
    my $limit = $self->param('count');
    my $results = $self->logger->getLog($limit); 

    $self->stash(logs => $results);
    
    $self->render(template => 'DoorControl/log', format => 'html', handler => 'ep');
}

sub forget {
    my $self = shift;
    $self->session(expires=>1);
    
    my $response->{success} = 1;
    
    $self->render(json => $response);
}

1;
