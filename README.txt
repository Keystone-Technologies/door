Initial setup commands:

cpanm Mojolicious::Plugin::BrowserDetect

Postgres setup:

create database doorcontrol;
create user doorcontrol;
\password doorcontrol
new pass: doorcontrol
again: doorcontrol
grant all on database doorcontrol to doorcontrol


Each Time Run:
sudo /etc/init.d/postgresql restart
morbo -l http://*:8080 script/door_control