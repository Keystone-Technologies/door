package DoorControl::Command::getty;
use Mojo::Base 'Mojolicious::Command';
use Date::Manip;

has description => 'Show versions of available modules';
has usage => sub { shift->extract_usage };

sub run {
    my $self = shift;
    
    while(1) {
        my $userinput = <STDIN>;
        my $results = "FAILED";
        chomp ($userinput);
        
        my $request = eval {
            $self->app->pg->db->query("select * from badges where badge_id = ?;", $userinput)->hash;
        };
        
        if($request->{authorized} == 1 || ($request->{authorized} == 2 && Date_IsWorkDay(ParseDate('now'), 1))) {
            my $req = HTTP::Request->new(GET => "http://theofficialjosh.com/test");
            my $ua = LWP::UserAgent->new;
            $results = $ua->request($req)->is_success ? "SUCCESS" : "FAILED";
        }
        if(defined $request->{name}) {
            $userinput = $request->{name};
        }
        
        $self->app->pg->db->query("insert into log (name, action, result) values (?, 'unlock', ?);", $userinput, $results);
    }
}

1;