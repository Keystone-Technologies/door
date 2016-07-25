package DoorControl::Model::Authenticate;
use Mojo::Base -base;

has 'pg';

sub authenticateUser {
    my ($self, $name, $pin) = @_;
    
    my $user = $self->pg->db->query("select * from users where name = ? and pin = ?", $name, $pin)->hash;
    
    return $user->{authorized};
}

sub authenticateBadge {
    my ($self, $badge) = @_;
    
    my $user = $self->pg->db->query("select * from badges where badge_id = ?;", $badge)->hash;
    
    return $user;
}

1;