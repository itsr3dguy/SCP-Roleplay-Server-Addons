-- Enable RLS on all tables
alter table player_scores enable row level security;
alter table deliveries enable row level security;
alter table reports enable row level security;

-- Allow the public/anon key to ONLY read
create policy "Public read player_scores" on player_scores for select using (true);
create policy "Public read deliveries"    on deliveries    for select using (true);
create policy "Public read reports"       on reports       for select using (true);

-- No insert/update/delete policies = those are all blocked for anon
