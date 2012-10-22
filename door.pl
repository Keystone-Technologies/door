use Mojolicious::Lite;
use lib 'door/lib';
use Door::Strike;
use Door::Schema;
use HTTP::BrowserDetect;
use Data::Dumper;

use constant INTERNAL => qr/^127\.|^(172\.16\.254\.\d{1,3})$/;

app->config(hypnotoad => {pid_file=>'.door', listen=>['http://*:3005'], proxy=>1});

helper internal => sub { shift->tx->remote_address=~INTERNAL?1:0 };
helper door => sub { Door::Schema->connect({dsn=>'DBI:mysql:database=door;host=localhost',user=>'door',password=>'door'}) };
helper striker => sub { my $self = shift; Door::Strike->new($self->door, remote_address=>$self->tx->remote_address, internal=>$self->internal, nobuzz=>0); };

plugin 'IsXHR';
plugin 'BrowserDetect';

get '/' => 'index';
get '/forget' => sub { my $self = shift; $self->session(expires=>1); $self->redirect_to('index'); };

post '/ofd' => (is_xhr => 1) => sub {
	my $self = shift;
	my $pin = $self->param('pin') || $self->session->{pin} || undef;
	#warn Dumper([remember=>$self->param('remember')//undef, pin=>$pin, param=>$self->param('pin') || undef, session=>$self->session->{pin} || undef]);
	my $strike = $self->striker->strike(pin=>$pin, note=>$self->param('note')//undef, state=>$self->param('state')||0);
	if ( $self->param('pin') && $self->param('remember') && $strike->{ok} ) {
		$self->session->{pin} = $self->param('pin');
		$self->session->{name} = $strike->{name};
		$self->session(expiration => 31_536_000);
	}
	warn Dumper($strike);
	return $self->render_json($strike);
};

get '/log/:rows' => sub {
	my $self = shift;
	my $rows = $self->param('rows');
	my @log = $self->door->resultset('Log')->search(undef, {select => ['id', {date_format=>['dt', '"%a, %b %e, %Y %r"'],-as=>'dt'}, 'user_id', 'message'], order_by => { -desc => 'id'}, rows => $rows})
		or return $self->redirect_to('index');
	$self->render('log', log => \@log);
};

app->start;

__DATA__
@@ index.html.ep
<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>Cogstone Door</title>
<style type="text/css">
<!--/* <![CDATA[ */
    buzz {color:red;}
    #name {cursor:pointer;text-decoration:underline;color:blue}
    #ofd, #login, #dialog-message {display:none}
    #hold {cursor:pointer;text-decoration:underline}
    #click {cursor:pointer;text-decoration:underline;color:blue;font-size:12px}
/* ]]> */-->
</style>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link   href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" type="text/css" rel="stylesheet" media="all" />
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8/jquery.min.js" type="text/javascript"></script>
<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js" type="text/javascript"></script>
<link rel="stylesheet" href="http://code.jquery.com/mobile/1.2.0/jquery.mobile-1.2.0.min.css" />
<script src="http://code.jquery.com/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
<script type="text/javascript">//<![CDATA[
% if ( $self->browser_detect->mobile ) {
$(document).delegate('#data', 'pageinit', function() {
% } else {
$(document).ready(function(){
//$(document).delegate('#data', 'pageinit', function() {
% }
    if ( $("#note").val() != "" ) {
        $("#ofd").show();
    }
    $("#note").keyup(function(){
        if ( $(this).val() == "" ) {
            $("#ofd").hide();
        } else {
            $("#ofd").show();
        }
    });
    $("#name").click(function(){
        $.get("/forget", {}, function(){
            % unless ( $self->internal || session 'pin' ) {
                $("#login").show();
            % }
        });
    });
    $("#hold").css("color", "blue").bind('vmousedown', function(e){
        e.preventDefault();
        $(this).css("color", "red");
        $.post("/ofd", {state: 1, note: $('#note').val(), pin: $('#pin').val(), remember: $('#remember').is(":checked")?1:0}, function(data){
            if ( data.ok ) {
                if ( $('#remember').is(":checked") ) {
                    $("#login").hide();
                }
                if ( data.name ) {
                    $("#name").html(data.name);
                }
            } else {
                $("#login").show();
                $("#strike-message").html(data.message);
                $("#dialog-message").dialog({
                    modal: true,
                    buttons: {
                        Ok: function() {
                            $("#hold").css("color", "blue");
                            $(this).dialog("close");
                        }
                    }
                });
            }
        });
    }).bind('vmouseup', function(e){
        e.preventDefault();
        $(this).css("color", "blue");
        $.post("/ofd");
    });
    $("#click").click(function(){
        $.post("/ofd", {state: 2, note: $('#note').val(), pin: $('#pin').val(), remember: $('#remember').is(":checked")?1:0}, function(data){
            if ( data.ok ) {
                if ( $('#remember').is(":checked") ) {
                    $("#login").hide();
                    $("#name").html(data.name);
                }
            } else {
                $("#login").show();
                $("#strike-message").html(data.message);
                $("#dialog-message").dialog({
                    modal: true,
                    buttons: {
                        Ok: function() { $(this).dialog("close"); }
                    }
                });
            }
            return true;
	});
    });
% unless ( $self->internal || session 'pin' ) {
    $("#login").show();
% }
});
//]]></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
</head>
<body>
<div id="data" data-url="data" data-role="page">
<div data-role="header">
<h1><a href="/log/20" rel="external">Door Access!</a></h1>
</div>
<div data-role="content">
Welcome, <span id="name"><%= session('name') || 'stranger' %></span> from <%= $self->tx->remote_address %>

<div data-role="fieldcontain">
    <label for="note">For whom?</label>
    <%= text_field 'note' => "", id=>'note' %>
</div>
<div id="login">
<div data-role="fieldcontain">
    <label for="pin">PIN</label>
    <%= password_field 'pin', id=>'pin' %>
</div>
<div data-role="fieldcontain">
    <label for="remember">Remember this device</label>
    <%= check_box remember => 1, id=>'remember' %>
</div>
</div>

<br />
<div id="ofd">
    % if ( 0 && $self->browser_detect->mobile ) {
      <div id="click"><br /><br />Pulse Front Door Buzzer</div>
    % } else {
      <div id="hold" data-role="button" data-icon="gear">Front Door Buzzer</div><br />
    % }
</div>
<div id="dialog-message" title="Failed to unlock">
    <p>
        <span class="ui-icon ui-icon-circle-close" style="float: left; margin: 0 7px 50px 0;"></span>
        Your attempt to remotely unlock the door has failed.
    </p>
    <p>
        <span id="strike-message"></span>
    </p>
</div>
</div>
</div>
</body>
</html>

@@ log.html.ep
<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>Cogstone Door : Log</title>
</head>
<body>
% foreach my $entry ( reverse @$log ) {
    <%= $entry->get_column('dt'); %> <%= $entry->message %><br />
% }
</body>
</html>
