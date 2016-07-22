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
    
    my $results = eval {
        $self->pg->db->query("select * from users where name = ? and pin = ?;", $name, $pin)->hash;
    };
    
    if($results->{authorized} == 1) {
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
    
    my $response->{results} = 0;
    
    my $results = eval {
        $self->pg->db->query("select * from users where name = ? and pin = ?;", $name, $pin)->hash;
    };
    
    if($results->{authorized} == 1) {
        $response->{results} = 1;
        $self->pg->db->query("insert into users (name, pin, authorized) values (?, ?, 1);", $newName, $newPin);
    };
    
    $self->render(json => $response);
}

1;
