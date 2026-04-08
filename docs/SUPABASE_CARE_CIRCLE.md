# Supabase Care Circle Blueprint

This document defines the first production-ready backend shape for `AuriTails` family sharing.

The goal is to support one shared pet space with multiple trusted caregivers while keeping the app private by default.

## Product Model

- One `pet` can have multiple members.
- Members belong to a `Care Circle`.
- Roles:
  - `owner`
  - `caregiver`
- Shared data:
  - pet profile
  - routines
  - behavior check-ins
  - weight entries
  - vaccines
  - medical history
  - medications
  - symptoms
  - food preferences
  - memories
- Personal data stays user-specific:
  - auth identity
  - account profile
  - local notification preferences

## Auth Recommendation

Use Supabase Auth with email magic links for v1.

Why:

- simpler onboarding
- no password reset UX
- easier invite acceptance
- good fit for consumer iOS app flows

## Database Schema

```sql
create extension if not exists pgcrypto;

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
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
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
```

## Shared Content Tables

Each shared content table should include:

- `id uuid primary key default gen_random_uuid()`
- `pet_id uuid not null references public.pets(id) on delete cascade`
- `created_by uuid references public.profiles(id) on delete set null`
- `updated_by uuid references public.profiles(id) on delete set null`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Examples:

- `routines`
- `behavior_snapshots`
- `weight_entries`
- `vaccines`
- `medical_entries`
- `medications`
- `symptoms`
- `food_preferences`
- `memories`

## Suggested Example Table

```sql
create table public.behavior_snapshots (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  weekday smallint not null check (weekday between 1 and 7),
  energy double precision not null check (energy between 0 and 1),
  calmness double precision not null check (calmness between 0 and 1),
  appetite double precision not null check (appetite between 0 and 1),
  sleep_hours double precision not null check (sleep_hours >= 0),
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (pet_id, weekday)
);
```

## Updated At Trigger

```sql
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
```

Apply it to every mutable table:

```sql
create trigger set_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();
```

Repeat for:

- `pets`
- `pet_memberships`
- `pet_invites`
- all shared content tables

## Helper Functions For RLS

```sql
create or replace function public.is_active_pet_member(target_pet_id uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.pet_memberships pm
    where pm.pet_id = target_pet_id
      and pm.user_id = auth.uid()
      and pm.status = 'active'
  );
$$;

create or replace function public.is_pet_owner(target_pet_id uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.pet_memberships pm
    where pm.pet_id = target_pet_id
      and pm.user_id = auth.uid()
      and pm.role = 'owner'
      and pm.status = 'active'
  );
$$;
```

## Enable RLS

```sql
alter table public.profiles enable row level security;
alter table public.pets enable row level security;
alter table public.pet_memberships enable row level security;
alter table public.pet_invites enable row level security;
alter table public.care_activity_events enable row level security;
alter table public.behavior_snapshots enable row level security;
```

Repeat for all shared content tables.

## RLS Policies

### Profiles

```sql
create policy "profiles are readable by self"
on public.profiles
for select
using (id = auth.uid());

create policy "profiles are insertable by self"
on public.profiles
for insert
with check (id = auth.uid());

create policy "profiles are updatable by self"
on public.profiles
for update
using (id = auth.uid())
with check (id = auth.uid());
```

### Pets

```sql
create policy "pets readable by active members"
on public.pets
for select
using (public.is_active_pet_member(id));

create policy "pets insertable by signed in users"
on public.pets
for insert
with check (created_by = auth.uid());

create policy "pets updatable by owners"
on public.pets
for update
using (public.is_pet_owner(id))
with check (public.is_pet_owner(id));

create policy "pets deletable by owners"
on public.pets
for delete
using (public.is_pet_owner(id));
```

### Pet Memberships

```sql
create policy "memberships readable by active members"
on public.pet_memberships
for select
using (public.is_active_pet_member(pet_id));

create policy "memberships insertable by owners"
on public.pet_memberships
for insert
with check (public.is_pet_owner(pet_id));

create policy "memberships updatable by owners"
on public.pet_memberships
for update
using (public.is_pet_owner(pet_id))
with check (public.is_pet_owner(pet_id));

create policy "memberships deletable by owners"
on public.pet_memberships
for delete
using (public.is_pet_owner(pet_id));
```

### Pet Invites

```sql
create policy "invites readable by owners"
on public.pet_invites
for select
using (public.is_pet_owner(pet_id));

create policy "invites insertable by owners"
on public.pet_invites
for insert
with check (public.is_pet_owner(pet_id) and created_by = auth.uid());

create policy "invites updatable by owners"
on public.pet_invites
for update
using (public.is_pet_owner(pet_id))
with check (public.is_pet_owner(pet_id));
```

Note:

- invite acceptance is better handled in a secure server-side function or Edge Function
- do not let arbitrary clients activate memberships purely from the device

### Shared Content Tables

Pattern for all shared pet content:

```sql
create policy "behavior snapshots readable by active members"
on public.behavior_snapshots
for select
using (public.is_active_pet_member(pet_id));

create policy "behavior snapshots insertable by active members"
on public.behavior_snapshots
for insert
with check (
  public.is_active_pet_member(pet_id)
  and created_by = auth.uid()
);

create policy "behavior snapshots updatable by active members"
on public.behavior_snapshots
for update
using (public.is_active_pet_member(pet_id))
with check (public.is_active_pet_member(pet_id));

create policy "behavior snapshots deletable by owners or creators"
on public.behavior_snapshots
for delete
using (
  public.is_pet_owner(pet_id)
  or created_by = auth.uid()
);
```

Apply the same pattern to:

- `routines`
- `weight_entries`
- `vaccines`
- `medical_entries`
- `medications`
- `symptoms`
- `food_preferences`
- `memories`
- `care_activity_events`

## Storage Layout

Recommended buckets:

- `profile-media`
- `pet-media`
- `memory-media`
- `vaccine-certificates`

Recommended path structure:

- `profiles/{user_id}/avatar.jpg`
- `pets/{pet_id}/profile.jpg`
- `pets/{pet_id}/bond-photo.jpg`
- `pets/{pet_id}/memories/{memory_id}.jpg`
- `pets/{pet_id}/vaccines/{vaccine_id}.jpg`

## Storage Access Strategy

- keep buckets private
- only return signed URLs to clients
- validate access by active pet membership before issuing the URL

For v1, use an Edge Function or server-side path check to generate signed URLs after membership validation.

## Invite Acceptance Flow

1. Owner creates invite with email + role.
2. Backend creates `pet_invites` row with secure token.
3. App sends email link or copies invite link.
4. Invitee opens app and signs in with magic link.
5. App calls secure backend function:
   - verify token
   - verify email matches invite
   - create or activate `pet_memberships`
   - mark invite as accepted
   - write `care_activity_events`

Do not perform this entirely from open client writes.

## Suggested Edge Function Responsibilities

- `accept-pet-invite`
- `revoke-pet-invite`
- `create-signed-media-url`

## iOS Integration Plan

Recommended app services:

- `SupabaseService`
- `AuthService`
- `CareCircleRepository`
- `SyncCoordinator`

Recommended rollout:

1. Add auth only.
2. Create profile row on first login.
3. Create remote `pet` and `owner membership`.
4. Connect existing local `Care Circle` UI to remote membership data.
5. Move shared records one domain at a time:
   - profile + pet
   - routines
   - behavior/weight
   - vaccines/medical
   - meds/symptoms
   - memories/photos

## Suggested MVP Scope

Ship v1 with:

- one shared pet space
- owner + caregiver roles only
- magic link login
- invites by email
- server-validated invite acceptance
- no realtime required yet
- sync on launch, foreground, and after writes

Add later:

- push-based realtime collaboration
- more granular permissions
- multiple pets per account
- family activity notifications

## Notes For AuriTails

- Keep notification preferences local per user.
- Keep shared care records remote by `pet_id`.
- Keep attribution fields on every shared row.
- Mirror remote data into local Core Data only as a cache, not as the long-term source of truth.
