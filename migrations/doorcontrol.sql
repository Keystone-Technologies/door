-- 1 up

create table if not exists users (
    name        text not null,
    pin         int not null,
    authorized  int not null,
    created     timestamptz not null default now()
);

insert into users (name, pin, authorized) values ('admin', 6292, 1);

-- 1 down

drop table if exists users;

--2 up

create table if not exists log (
    id          serial primary key,
    action      text not null,
    result      text not null,
    name        text not null,
    created     timestamptz not null default now()
);

insert into log (id, name, action, result) values (0, 'tester', 'lock', 'succeed');

-- 2 down

drop table if exists log;

--3 up

create table if not exists badges(
    badge_id    int not null,
    name        text not null,
    authorized  int not null
);

insert into badges(badge_id, name, authorized) values (0123456, 'tester', 1);
--3 down

drop table if exists badges;