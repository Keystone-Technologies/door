package DoorControl::Model::Register;
use Mojo::Base -base;

has 'pg';

sub insertUser {
    my ($self, $newName, $newPin, $auth) = @_;
    
    $self->pg->db->query("insert into users (name, pin, authorized) values (?, ?, ?);", $newName, $newPin, $auth);

    return 1;
}

sub getBadges {
    my ($self, $start, $end) = @_;
    
        $self->pg->db->query("select * from badges where badge_id >= ? and badge_id <= ?", $start, $end)->hashes->to_array;

}

sub deleteBadge {
    my ($self, $badge) = @_;
    
    $self->pg->db->query("delete from badges where badge_id = ?", $badge);
    
    return 1;
}



sub insertBadge {
    my ($self, $badge, $newName, $auth) = @_;
    
    $self->pg->db->query("insert into badges (badge_id, name, authorized) values (?, ?, ?);", $badge, $newName, $auth);
    
    return 1;
}

1;