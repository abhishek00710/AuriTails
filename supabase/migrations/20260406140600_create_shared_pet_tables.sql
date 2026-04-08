create table public.routines (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  title text not null,
  subtitle text not null default '',
  weekday smallint not null check (weekday between 1 and 7),
  hour smallint not null check (hour between 0 and 23),
  minute smallint not null check (minute between 0 and 59),
  duration_minutes integer not null check (duration_minutes >= 0),
  system_image text not null default 'calendar',
  category text not null,
  tone text not null default 'lagoon',
  is_completed boolean not null default false,
  notifications_enabled boolean not null default true,
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

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

create table public.weight_entries (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  logged_at timestamptz not null,
  kilograms_value double precision not null check (kilograms_value >= 0),
  unit text not null check (unit in ('kilograms', 'pounds')),
  note text not null default '',
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.vaccines (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  title text not null,
  last_given timestamptz not null,
  next_due timestamptz not null,
  status text not null,
  note text not null default '',
  certificate_media_id uuid,
  notifications_enabled boolean not null default true,
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.medical_entries (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  title text not null,
  occurred_at timestamptz not null,
  summary text not null default '',
  clinician text not null default '',
  tone text not null default 'lagoon',
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.medications (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  title text not null,
  dosage text not null default '',
  schedule_note text not null default '',
  purpose text not null default '',
  next_dose timestamptz not null,
  status text not null,
  tone text not null default 'lagoon',
  notifications_enabled boolean not null default true,
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.symptoms (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  title text not null,
  detail text not null default '',
  observed_at timestamptz not null,
  severity text not null,
  system_image text not null default 'exclamationmark.triangle.fill',
  tone text not null default 'apricot',
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.food_preferences (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  title text not null,
  detail text not null default '',
  system_image text not null default 'fork.knife.circle.fill',
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.memories (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  title text not null,
  occurred_at timestamptz not null,
  caption text not null default '',
  detail text not null default '',
  photo_media_id uuid,
  system_image text not null default 'film.stack.fill',
  tone text not null default 'lagoon',
  is_annual_celebration boolean not null default false,
  notifications_enabled boolean not null default true,
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.shared_media_assets (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  owner_user_id uuid not null references public.profiles(id) on delete cascade,
  category text not null check (category in ('pet_photo', 'bond_photo', 'memory_photo', 'vaccine_certificate')),
  record_type text not null,
  record_id uuid,
  storage_bucket text not null,
  storage_path text not null unique,
  bytes_used bigint not null check (bytes_used >= 0),
  status text not null check (status in ('pending_upload', 'synced', 'upload_deferred', 'upload_failed', 'deleted')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.vaccines
add constraint vaccines_certificate_media_fk
foreign key (certificate_media_id)
references public.shared_media_assets(id)
on delete set null;

alter table public.memories
add constraint memories_photo_media_fk
foreign key (photo_media_id)
references public.shared_media_assets(id)
on delete set null;

create index routines_pet_id_idx on public.routines (pet_id);
create index behavior_snapshots_pet_id_idx on public.behavior_snapshots (pet_id);
create index weight_entries_pet_id_logged_at_idx on public.weight_entries (pet_id, logged_at desc);
create index vaccines_pet_id_next_due_idx on public.vaccines (pet_id, next_due asc);
create index medical_entries_pet_id_occurred_at_idx on public.medical_entries (pet_id, occurred_at desc);
create index medications_pet_id_next_dose_idx on public.medications (pet_id, next_dose asc);
create index symptoms_pet_id_observed_at_idx on public.symptoms (pet_id, observed_at desc);
create index food_preferences_pet_id_idx on public.food_preferences (pet_id);
create index memories_pet_id_occurred_at_idx on public.memories (pet_id, occurred_at desc);
create index shared_media_assets_pet_id_idx on public.shared_media_assets (pet_id);
create index shared_media_assets_record_idx on public.shared_media_assets (record_type, record_id);

create trigger set_routines_updated_at
before update on public.routines
for each row execute function public.set_updated_at();

create trigger set_behavior_snapshots_updated_at
before update on public.behavior_snapshots
for each row execute function public.set_updated_at();

create trigger set_weight_entries_updated_at
before update on public.weight_entries
for each row execute function public.set_updated_at();

create trigger set_vaccines_updated_at
before update on public.vaccines
for each row execute function public.set_updated_at();

create trigger set_medical_entries_updated_at
before update on public.medical_entries
for each row execute function public.set_updated_at();

create trigger set_medications_updated_at
before update on public.medications
for each row execute function public.set_updated_at();

create trigger set_symptoms_updated_at
before update on public.symptoms
for each row execute function public.set_updated_at();

create trigger set_food_preferences_updated_at
before update on public.food_preferences
for each row execute function public.set_updated_at();

create trigger set_memories_updated_at
before update on public.memories
for each row execute function public.set_updated_at();

create trigger set_shared_media_assets_updated_at
before update on public.shared_media_assets
for each row execute function public.set_updated_at();
