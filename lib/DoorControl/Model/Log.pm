package DoorControl::Model::Log;
use Mojo::Base -base;

has 'pg';

sub log {
    my ($self, $name, $action, $results, $method) = @_;
    
    $self->pg->db->query("insert into log (name, action, result, method) values (?, ?, ?, ?);", $name, $action, $results, $method);
    
    return 1;
}

sub getLog {
    my ($self, $limit) = @_;
    
    return $self->pg->db->query("select id, action, method, result, name, created from log order by created desc limit ?;", $limit)->hashes->to_array;
}

1;