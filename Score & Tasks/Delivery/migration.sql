-- Delivery log
create table deliveries (
    id bigint primary key generated always as identity,
    player text,
    score_awarded bigint,
    created_at timestamptz default now()
);

-- Persistent player scores
create table player_scores (
    player text primary key,
    total_score bigint default 0
);
