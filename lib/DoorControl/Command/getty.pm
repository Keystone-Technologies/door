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
        
        my $request = eval {
            $self->app->pg->db->query("select * from badges where badge_id = ?;", $userinput)->hash;
        };
        
        if($request->{authorized} == 1 || ($request->{authorized} == 2 && Date_IsWorkDay(ParseDate('now'), 1))) {
            my $ua = Mojo::UserAgent->new;
            $results = $ua->get('theofficialjosh.com/test')->res->code == 200 ? "SUCCESS" : "FAILED";
        }
        if(defined $request->{name}) {
            $userinput = $request->{name};
        }
        
        $self->app->pg->db->query("insert into log (name, action, result, method) values (?, 'unlock', ?, 'badge');", $userinput, $results);
    }
}

1;