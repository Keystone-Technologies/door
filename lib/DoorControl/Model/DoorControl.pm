package DoorControl::Model::DoorControl;
use Mojo::Base -base;

use Date::Manip;

has 'FULL_AUTHORIZATION';
has 'LIMITED_AUTHORIZATION';
has 'unlock_url';
has 'lock_url';

sub unlock {
    my ($self, $authorized, $internal) = @_;
    
    my $results = 0;
    
    if($authorized == $self->FULL_AUTHORIZATION || $internal || ($authorized == $self->LIMITED_AUTHORIZATION && Date_IsWorkDay(ParseDate('now'), 1))) {
        my $ua = Mojo::UserAgent->new;
        $results = $ua->get($self->unlock_url)->res->code == 200 ? 1 : 0;
    }
    
    return $results;
}

sub lock {
    my ($self) = @_;
    
    my $results = 0;
    
    my $ua = Mojo::UserAgent->new;
    $results = $ua->get($self->lock_url)->res->code == 200 ? 1 : 0;
    
    return $results;
}

1;