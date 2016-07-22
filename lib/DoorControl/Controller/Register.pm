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
    my $auth = $self->param('auth');
    
    my $response->{results} = 0;
    
    my $results = eval {
        $self->pg->db->query("select * from users where name = ? and pin = ?;", $name, $pin)->hash;
    };
    
    if($results->{authorized} == 1) {
        $response->{results} = 1;
        $self->pg->db->query("insert into users (name, pin, authorized) values (?, ?, ?);", $newName, $newPin, $auth);
    };
    
    $self->render(json => $response);
}

sub badges {
    my $self = shift;
    
    my $name = $self->param('name');
    my $pin = $self->param('pin');
    my $start = $self->param('start');
    my $end = $self->param('end');
    
    my $results = eval {
        $self->pg->db->query("select * from users where name = ? and pin = ?;", $name, $pin)->hash;
    };
    
    if($results->{authorized} == 1) {
        $results = eval {
            $self->pg->db->query("select * from badges where badge_id >= ? and badge_id <= ?", $start, $end)->hashes->to_array;
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
    
    my $results = eval {
        $self->pg->db->query("select * from users where name = ? and pin = ?;", $name, $pin)->hash;
    };
    
    if($results->{authorized} == 1) {
        $response->{results} = 1;
        $results = eval {
            $self->pg->db->query("delete from badges where badge_id = ?", $badge);
            $self->pg->db->query("insert into badges (badge_id, name, authorized) values (?, ?, ?);", $badge, $newName, $auth);
        };
    };
    
    $self->render(json => $response);
}

1;
