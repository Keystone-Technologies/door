package Door::Strike;

use strict;
use warnings;
use Date::Manip;
use LWP::UserAgent;
use Data::Dumper;

#Strike($ENV{PIN}, $schema->resultset('Door')->find({pin=>$ENV{PIN}}));
Date_Init('WorkDayBeg = 07:00', 'WorkDayEnd = 18:00');

sub new {
	my $class = shift;

	my $self = {
		schema => shift,
		@_
	};

	return bless $self, $class;
}

sub strike {
	my $self = shift;
	my $hashref = shift;
	my %opt = %{$hashref};
	my $schema = $self->{schema};

	my ($user_id, $name, $ok, $label, $rfid, $pin);
	if ( $opt{state} == 0 ) {
		$self->state($opt{state});
	} elsif ( defined $opt{ok} ) {
		($user_id, $name, $ok) = (undef, "Internal Request", $opt{ok});
	} elsif ( my $rs = $schema->resultset('Door')->find({pin=>$opt{pin}}) ) {
		($user_id, $name, $ok, $label, $rfid, $pin) = ($rs->user_id, $rs->user->name, $rs->acl, $rs->badge, $rs->sn, $rs->pin);
	} else {
		($user_id, $name, $ok) = (undef, "Wrong PIN ($opt{pin})", -1);
	}
	$name = "$name ($opt{note})" if $opt{note};

	if ( $opt{pin} && $pin && $opt{pin} ne $pin ) {
		$self->deny("Wrong PIN ($opt{pin}): $name");
	} elsif ( !$opt{note} ) {
		$self->deny("Deny No Note Provied: $name");
	} elsif ( $ok == 1 || ($ok == 2 && Date_IsWorkDay(ParseDate('now'), 1)) ) {  # 7a-6p
		if ( $self->state($opt{state}) ) {
			$self->allow("Allow: $name");
		} else {
			$self->deny("Allow (FAILED): $name");
		}
	} elsif ( $ok == 2 ) {
		$self->deny("Deny After Hours: $name");
	} elsif ( $ok == 0 ) {
		$self->deny("Deny: $name");
	} else {
		$self->deny("Deny Unknown Attempt: $name");
	}

	$schema->resultset('Log')->create({dt=>\'now()', user_id=>$user_id, message=>$self->message});
	warn Dumper({ok=>$self->ok, message=>$self->message});
	return (ok=>$self->ok, message=>$self->message);
}

sub state {
	my $self = shift;
	if ( $self->{nobuzz} ) {
		return 1;
	} else {
		my $state = shift // 2;
		my $ua = LWP::UserAgent->new;
warn "\nGET http://webrelay.cogstonestl.com/state.xml?relayState=$state\n\n";
		my $req = HTTP::Request->new(GET => "http://webrelay.cogstonestl.com/state.xml?relayState=$state");
		my $res = $ua->request($req);
		return $res->is_success;
	}
}

sub allow {
	my $self = shift;
	$self->{__OK} = 1;
	$self->{__MESSAGE} = shift;
}

sub deny {
	my $self = shift;
	$self->{__OK} = 0;
	$self->{__MESSAGE} = shift;
}

sub ok { shift->{__OK} }

sub message {
	my $self = shift;
	$self->{__MESSAGE}.($self->{remote_address} ? " from $self->{remote_address}" : '');
}

1;
