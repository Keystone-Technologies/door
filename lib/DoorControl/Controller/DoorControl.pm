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
    
    my $results = eval {
        $self->pg->db->query("select * from users where name = ? and pin = ?", $name, $pin)->hash;
    };
    
    my $response->{result} = 0;
    
    if($results->{authorized} == 1) {
        $response->{result} = 1;
        my $req = HTTP::Request->new(GET => "http://theofficialjosh.com/test");
        my $ua = LWP::UserAgent->new;
        $response->{response} = $ua->request($req)->as_string;
        
        if($remember) {
            $self->session->{pin} = $pin;
            $self->session->{name} = $name;
        }
    }
    
    if(!$self->param('hold')) {
        $self->delay(
            sub { Mojo::IOLoop->timer(30 => shift->begin) },
            sub { $self->lock },
        );
    }
    
    $self->pg->db->query("insert into log (name, action, result) values (?, 'unlock', 'success?');", $name);
    
    $self->render(json => $response);
}

sub lock {
    my $self = shift;
    #locks the door, maybe happens automatically after unlocking it?
    my $req = HTTP::Request->new(GET => "http://theofficialjosh.com/test");
    my $ua = LWP::UserAgent->new;
    $ua->request($req)->as_string;
    
    my $response->{response} = 1;
    
    $self->pg->db->query("insert into log (name, action, result) values ('door', 'lock', 'success');");
    
    $self->render(json => $response);
}

sub log {
    my $self = shift;
    my $limit = $self->param('count');
    my $results = eval {
        $self->pg->db->query("select id, action, result, name, created from log order by created desc limit ?;", $limit)->hashes->to_array;
    };
    
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
