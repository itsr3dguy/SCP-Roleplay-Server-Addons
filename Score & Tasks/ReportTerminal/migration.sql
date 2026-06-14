create table reports (
    id bigint primary key generated always as identity,
    player text,
    message text,
    created_at timestamptz default now()
);
