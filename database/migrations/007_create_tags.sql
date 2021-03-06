-- +migrate up
-- +migrate start
create function set_timestamp() returns trigger as $$
  begin
    new.updated_at = now();
    return new;
  end;
$$ language plpgsql;
-- +migrate end

create table tags (
  id int generated by default as identity primary key,
  guild_id bigint not null,
  user_id bigint not null,
  name text not null,
  content text not null,
  updated_at timestamptz default now() not null,
  created_at timestamptz default now() not null
);

create unique index uix_tags_guild_name on tags(guild_id, name);

create trigger tr_tags_timestamp
  before update on tags
  for each row
  execute procedure set_timestamp();

create table tag_uses (
  tag_id int references tags on delete cascade,
  user_id bigint not null,
  "timestamp" timestamptz default now() not null
);

-- +migrate down
drop table tag_uses;
drop table tags;
drop function set_timestamp();
