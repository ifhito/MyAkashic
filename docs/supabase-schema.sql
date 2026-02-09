-- Supabase schema for Knowledge App (MVP)
-- Assumes Supabase Postgres with auth schema available

-- Extensions
create extension if not exists "pgcrypto";

-- Helper: updated_at trigger
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- knowledge_notes
create table if not exists public.knowledge_notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  body text,
  raw_text text not null,
  capture_status text not null check (capture_status in ('inbox','structured')),
  learned_period text,
  period_granularity text check (period_granularity in ('year','quarter','month','day')),
  visibility text not null default 'private' check (visibility in ('private','public')),
  source_type text check (source_type in ('book','company','experience','other')),
  source_ref text,
  structured_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists knowledge_notes_user_status_created_idx
  on public.knowledge_notes (user_id, capture_status, created_at desc);

create index if not exists knowledge_notes_user_learned_period_idx
  on public.knowledge_notes (user_id, learned_period);

create trigger set_knowledge_notes_updated_at
before update on public.knowledge_notes
for each row execute function public.set_updated_at();

-- tags
create table if not exists public.tags (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, name)
);

create index if not exists tags_user_name_idx
  on public.tags (user_id, name);

create trigger set_tags_updated_at
before update on public.tags
for each row execute function public.set_updated_at();

-- note_tags
create table if not exists public.note_tags (
  note_id uuid not null references public.knowledge_notes(id) on delete cascade,
  tag_id uuid not null references public.tags(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (note_id, tag_id)
);

create index if not exists note_tags_user_note_idx
  on public.note_tags (user_id, note_id);

-- note_links
create table if not exists public.note_links (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  from_note_id uuid not null references public.knowledge_notes(id) on delete cascade,
  to_note_id uuid not null references public.knowledge_notes(id) on delete cascade,
  relation_type text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (from_note_id <> to_note_id)
);

create index if not exists note_links_user_from_idx
  on public.note_links (user_id, from_note_id);

create trigger set_note_links_updated_at
before update on public.note_links
for each row execute function public.set_updated_at();

-- RLS
alter table public.knowledge_notes enable row level security;
alter table public.tags enable row level security;
alter table public.note_tags enable row level security;
alter table public.note_links enable row level security;

-- Policies: knowledge_notes
create policy "knowledge_notes_select_own" on public.knowledge_notes
for select using (user_id = auth.uid());

create policy "knowledge_notes_insert_own" on public.knowledge_notes
for insert with check (user_id = auth.uid());

create policy "knowledge_notes_update_own" on public.knowledge_notes
for update using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "knowledge_notes_delete_own" on public.knowledge_notes
for delete using (user_id = auth.uid());

-- Policies: tags
create policy "tags_select_own" on public.tags
for select using (user_id = auth.uid());

create policy "tags_insert_own" on public.tags
for insert with check (user_id = auth.uid());

create policy "tags_update_own" on public.tags
for update using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "tags_delete_own" on public.tags
for delete using (user_id = auth.uid());

-- Policies: note_tags
create policy "note_tags_select_own" on public.note_tags
for select using (user_id = auth.uid());

create policy "note_tags_insert_own" on public.note_tags
for insert with check (user_id = auth.uid());

create policy "note_tags_delete_own" on public.note_tags
for delete using (user_id = auth.uid());

-- Policies: note_links
create policy "note_links_select_own" on public.note_links
for select using (user_id = auth.uid());

create policy "note_links_insert_own" on public.note_links
for insert with check (user_id = auth.uid());

create policy "note_links_update_own" on public.note_links
for update using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "note_links_delete_own" on public.note_links
for delete using (user_id = auth.uid());
