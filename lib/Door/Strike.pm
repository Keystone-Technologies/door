package Door::Strike;

use strict;
use warnings;
use Date::Manip;
use LWP::UserAgent;
use Data::Dumper;

sub new {
	my $class = shift;
	my $schema = shift or return undef;
	bless {schema=>$schema,@_}, $class;
}

sub strike {
	my $self = shift;
	my %opt = @_; # pin, note, state
	my $schema = $self->{schema};

	if ( $opt{state} == 0 ) {
		$self->state($opt{state});
		return {ok=>1};
	} elsif ( $self->{internal} ) {
		$self->name('Internal Request');
		if ( $self->state($opt{state}) ) {
			$self->ok("Allow");
		} else {
			$self->fail("Allow (FAILED)");
		}
	} elsif ( !$self->note($opt{note}) ) {
		$self->fail("Deny No Note Provided");
	} elsif ( defined $self->pin($opt{pin}) ) {
		if ( my $rs = $schema->resultset('Door')->find({pin=>$self->pin}) ) {
			Date_Init('WorkDayBeg = 07:00', 'WorkDayEnd = 18:00');
			$self->name($rs->user->name);
			$self->user_id($rs->user_id);
			if ( $rs->acl == 1 || ($rs->acl == 2 && Date_IsWorkDay(ParseDate('now'), 1)) ) {  # 7a-6p
				if ( $self->state($opt{state}) ) {
					$self->ok("Allow");
				} else {
					$self->fail("Allow (FAILED)");
				}
			} elsif ( $rs->acl == 2 ) {
				$self->fail("Deny After Hours");
			} elsif ( $rs->acl == 0 ) {
				$self->fail("Deny");
			} else {
				$self->fail("Deny Unknown Attempt");
			}
		} else {
			$self->name("Wrong PIN");
			$self->fail("Deny");
		}
	} else {
		$self->fail("Deny Incomplete Attempt");
	}
}

sub state {
	my $self = shift;
	if ( $self->{nobuzz} ) {
		return 1;
	} else {
		my $state = shift // 2;
		my $ua = LWP::UserAgent->new;
		#warn "\nGET http://webrelay.cogstonestl.com/state.xml?relayState=$state\n\n";
		my $req = HTTP::Request->new(GET => "http://webrelay.cogstonestl.com/state.xml?relayState=$state");
		my $res = $ua->request($req);
		return $res->is_success;
	}
}

sub ok {
	my $self = shift;
	$self->{__OK} = 1;
	$self->{__MESSAGE} = shift;
	return $self->log;
}

sub fail {
	my $self = shift;
	$self->{__OK} = 0;
	$self->{__MESSAGE} = shift;
	return $self->log;
}

sub log {
	my $self = shift;
	if ( my $message = $self->message ) {
		if ( my $pin = $self->pin ) {
			$message =~ s/Wrong PIN/Wrong PIN ($pin)/;
		}
		#warn Dumper({ok=>$self->{__OK}, message=>$message});
		$self->{schema}->resultset('Log')->create({dt=>\'now()', user_id=>$self->user_id, message=>$self->message});
	}
	return {ok=>$self->{__OK}, message=>$self->message, name=>$self->name};
}

sub note {
	my $self = shift;
	if ( $_[0] ) {
		$self->{__NOTE} = $_[0];
	}
	return $self->{__NOTE};
}

sub pin {
	my $self = shift;
	if ( $_[0] ) {
		$self->{__PIN} = $_[0];
	}
	return $self->{__PIN};
}

sub name {
	my $self = shift;
	if ( $_[0] ) {
		$self->{__NAME} = $_[0];
	}
	return $self->{__NAME};
}

sub user_id {
	my $self = shift;
	if ( $_[0] ) {
		$self->{__USERID} = $_[0];
	}
	return $self->{__USERID};
}

sub message {
	my $self = shift;
	$self->{__MESSAGE} .
		($self->name ? ': '.$self->name : '') .
		($self->note ? ' ('.$self->note.')' : '') .
		($self->{remote_address} ? " from $self->{remote_address}" : '');
}

1;
