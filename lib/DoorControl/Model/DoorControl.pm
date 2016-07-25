package DoorControl::Model::DoorControl;
use Mojo::Base -base;

use Date::Manip;

sub unlock {
    my ($self, $authorized, $internal) = @_;
    
    $authorized //= 0;
    my $results = 0;
    
    if($authorized == 1 || $internal || ($authorized == 2 && Date_IsWorkDay(ParseDate('now'), 1))) {
        my $ua = Mojo::UserAgent->new;
        $results = $ua->get('theofficialjosh.com/test')->res->code == 200 ? 1 : 0;
    }
    
    return $results;
}

sub lock {
    my ($self) = @_;
    
    my $results = 0;
    
    my $ua = Mojo::UserAgent->new;
    $results = $ua->get('theofficialjosh.com/test')->res->code == 200 ? 1 : 0;
    
    return $results;
}

1;