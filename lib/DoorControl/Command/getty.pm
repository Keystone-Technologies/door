package DoorControl::Command::getty;
use Mojo::Base 'Mojolicious::Command';
use Date::Manip;
use Mojo::UserAgent;

has description => 'Show versions of available modules';
has usage => sub { shift->extract_usage };

sub run {
    my $self = shift;
    
    while(1) {
        my $userinput = <STDIN>;
        my $results = "FAILED";
        chomp ($userinput);
        
        my $user = $self->app->authenticate->authenticateBadge($userinput);
        
        $results = $self->app->doorcontrol->unlock($user->{authorized}, 0) ? "SUCCESS" : "FAILED";
        
        if(defined $user->{name}) {
            $userinput = $user->{name};
        }
        
        $self->app->logger->log($userinput, "unlock", $results, "badge");
    }
}

1;