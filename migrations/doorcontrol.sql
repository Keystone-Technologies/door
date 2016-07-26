-- 1 up

create table if not exists users (
    name        text not null,
    pin         int not null,
    authorized  int not null,
    created     timestamptz not null default now()
);

create table if not exists log (
    id          serial primary key,
    action      text not null,
    result      text not null,
    name        text not null,
    created     timestamptz not null default now(),
    method      text not null
);


create table if not exists badges(
    badge_id    int not null,
    name        text not null,
    authorized  int not null
);

insert into badges(badge_id, name, authorized) values (10, 'tester', 1);
insert into users (name, pin, authorized) values ('admin', 6292, 1);
insert into log (id, name, action, result, method) values (0, 'tester', 'lock', 'succeed', 'badge');

-- 1 down

drop table if exists users;

drop table if exists log;

drop table if exists badges;
