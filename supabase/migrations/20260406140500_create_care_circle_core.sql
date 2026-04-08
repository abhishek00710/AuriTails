create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  email text not null default '',
  avatar_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.pets (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references public.profiles(id) on delete restrict,
  name text not null default '',
  species text not null default '',
  breed text not null default '',
  age_description text not null default '',
  weight_description text not null default '',
  favorite_treat text not null default '',
  bond_statement text not null default '',
  energy_summary text not null default '',
  photo_path text,
  bond_photo_path text,
  cloud_media_bytes_limit bigint not null default 10485760,
  cloud_media_bytes_used bigint not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint pets_cloud_media_nonnegative check (
    cloud_media_bytes_limit >= 0
    and cloud_media_bytes_used >= 0
    and cloud_media_bytes_used <= cloud_media_bytes_limit
  )
);

create table public.pet_memberships (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null check (role in ('owner', 'caregiver')),
  status text not null check (status in ('pending', 'active')),
  invited_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (pet_id, user_id)
);

create table public.pet_invites (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  email text not null,
  role text not null check (role in ('caregiver')),
  token text not null unique,
  status text not null check (status in ('pending', 'accepted', 'revoked', 'expired')),
  expires_at timestamptz not null,
  created_by uuid not null references public.profiles(id) on delete restrict,
  accepted_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.care_activity_events (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  actor_user_id uuid references public.profiles(id) on delete set null,
  type text not null,
  title text not null,
  detail text not null default '',
  system_image text not null default 'sparkles',
  tone text not null default 'lagoon',
  created_at timestamptz not null default now()
);

create index profiles_email_idx on public.profiles (email);
create index pets_created_by_idx on public.pets (created_by);
create index pet_memberships_pet_id_idx on public.pet_memberships (pet_id);
create index pet_memberships_user_id_idx on public.pet_memberships (user_id);
create index pet_invites_pet_id_idx on public.pet_invites (pet_id);
create index pet_invites_email_idx on public.pet_invites (email);
create index pet_invites_token_idx on public.pet_invites (token);
create index care_activity_events_pet_id_created_at_idx on public.care_activity_events (pet_id, created_at desc);

create trigger set_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger set_pets_updated_at
before update on public.pets
for each row execute function public.set_updated_at();

create trigger set_pet_memberships_updated_at
before update on public.pet_memberships
for each row execute function public.set_updated_at();

create trigger set_pet_invites_updated_at
before update on public.pet_invites
for each row execute function public.set_updated_at();
