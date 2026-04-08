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
      and pm.status = 'active'
      and pm.role = 'owner'
  );
$$;

create or replace function public.can_claim_media_bytes(target_pet_id uuid, requested_bytes bigint)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.pets p
    where p.id = target_pet_id
      and (p.cloud_media_bytes_used + requested_bytes) <= p.cloud_media_bytes_limit
  );
$$;

alter table public.profiles enable row level security;
alter table public.pets enable row level security;
alter table public.pet_memberships enable row level security;
alter table public.pet_invites enable row level security;
alter table public.care_activity_events enable row level security;
alter table public.routines enable row level security;
alter table public.behavior_snapshots enable row level security;
alter table public.weight_entries enable row level security;
alter table public.vaccines enable row level security;
alter table public.medical_entries enable row level security;
alter table public.medications enable row level security;
alter table public.symptoms enable row level security;
alter table public.food_preferences enable row level security;
alter table public.memories enable row level security;
alter table public.shared_media_assets enable row level security;

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

create policy "activity readable by active members"
on public.care_activity_events
for select
using (public.is_active_pet_member(pet_id));

create policy "activity insertable by active members"
on public.care_activity_events
for insert
with check (
  public.is_active_pet_member(pet_id)
  and actor_user_id = auth.uid()
);

create policy "routines readable by active members"
on public.routines
for select
using (public.is_active_pet_member(pet_id));

create policy "routines insertable by active members"
on public.routines
for insert
with check (public.is_active_pet_member(pet_id) and created_by = auth.uid());

create policy "routines updatable by active members"
on public.routines
for update
using (public.is_active_pet_member(pet_id))
with check (public.is_active_pet_member(pet_id));

create policy "routines deletable by owners or creators"
on public.routines
for delete
using (public.is_pet_owner(pet_id) or created_by = auth.uid());

create policy "behavior readable by active members"
on public.behavior_snapshots
for select
using (public.is_active_pet_member(pet_id));

create policy "behavior insertable by active members"
on public.behavior_snapshots
for insert
with check (public.is_active_pet_member(pet_id) and created_by = auth.uid());

create policy "behavior updatable by active members"
on public.behavior_snapshots
for update
using (public.is_active_pet_member(pet_id))
with check (public.is_active_pet_member(pet_id));

create policy "behavior deletable by owners or creators"
on public.behavior_snapshots
for delete
using (public.is_pet_owner(pet_id) or created_by = auth.uid());

create policy "weights readable by active members"
on public.weight_entries
for select
using (public.is_active_pet_member(pet_id));

create policy "weights insertable by active members"
on public.weight_entries
for insert
with check (public.is_active_pet_member(pet_id) and created_by = auth.uid());

create policy "weights updatable by active members"
on public.weight_entries
for update
using (public.is_active_pet_member(pet_id))
with check (public.is_active_pet_member(pet_id));

create policy "weights deletable by owners or creators"
on public.weight_entries
for delete
using (public.is_pet_owner(pet_id) or created_by = auth.uid());

create policy "vaccines readable by active members"
on public.vaccines
for select
using (public.is_active_pet_member(pet_id));

create policy "vaccines insertable by active members"
on public.vaccines
for insert
with check (public.is_active_pet_member(pet_id) and created_by = auth.uid());

create policy "vaccines updatable by active members"
on public.vaccines
for update
using (public.is_active_pet_member(pet_id))
with check (public.is_active_pet_member(pet_id));

create policy "vaccines deletable by owners or creators"
on public.vaccines
for delete
using (public.is_pet_owner(pet_id) or created_by = auth.uid());

create policy "medical entries readable by active members"
on public.medical_entries
for select
using (public.is_active_pet_member(pet_id));

create policy "medical entries insertable by active members"
on public.medical_entries
for insert
with check (public.is_active_pet_member(pet_id) and created_by = auth.uid());

create policy "medical entries updatable by active members"
on public.medical_entries
for update
using (public.is_active_pet_member(pet_id))
with check (public.is_active_pet_member(pet_id));

create policy "medical entries deletable by owners or creators"
on public.medical_entries
for delete
using (public.is_pet_owner(pet_id) or created_by = auth.uid());

create policy "medications readable by active members"
on public.medications
for select
using (public.is_active_pet_member(pet_id));

create policy "medications insertable by active members"
on public.medications
for insert
with check (public.is_active_pet_member(pet_id) and created_by = auth.uid());

create policy "medications updatable by active members"
on public.medications
for update
using (public.is_active_pet_member(pet_id))
with check (public.is_active_pet_member(pet_id));

create policy "medications deletable by owners or creators"
on public.medications
for delete
using (public.is_pet_owner(pet_id) or created_by = auth.uid());

create policy "symptoms readable by active members"
on public.symptoms
for select
using (public.is_active_pet_member(pet_id));

create policy "symptoms insertable by active members"
on public.symptoms
for insert
with check (public.is_active_pet_member(pet_id) and created_by = auth.uid());

create policy "symptoms updatable by active members"
on public.symptoms
for update
using (public.is_active_pet_member(pet_id))
with check (public.is_active_pet_member(pet_id));

create policy "symptoms deletable by owners or creators"
on public.symptoms
for delete
using (public.is_pet_owner(pet_id) or created_by = auth.uid());

create policy "food preferences readable by active members"
on public.food_preferences
for select
using (public.is_active_pet_member(pet_id));

create policy "food preferences insertable by active members"
on public.food_preferences
for insert
with check (public.is_active_pet_member(pet_id) and created_by = auth.uid());

create policy "food preferences updatable by active members"
on public.food_preferences
for update
using (public.is_active_pet_member(pet_id))
with check (public.is_active_pet_member(pet_id));

create policy "food preferences deletable by owners or creators"
on public.food_preferences
for delete
using (public.is_pet_owner(pet_id) or created_by = auth.uid());

create policy "memories readable by active members"
on public.memories
for select
using (public.is_active_pet_member(pet_id));

create policy "memories insertable by active members"
on public.memories
for insert
with check (public.is_active_pet_member(pet_id) and created_by = auth.uid());

create policy "memories updatable by active members"
on public.memories
for update
using (public.is_active_pet_member(pet_id))
with check (public.is_active_pet_member(pet_id));

create policy "memories deletable by owners or creators"
on public.memories
for delete
using (public.is_pet_owner(pet_id) or created_by = auth.uid());

create policy "shared media readable by active members"
on public.shared_media_assets
for select
using (public.is_active_pet_member(pet_id));

create policy "shared media insertable by active members within quota"
on public.shared_media_assets
for insert
with check (
  public.is_active_pet_member(pet_id)
  and owner_user_id = auth.uid()
  and public.can_claim_media_bytes(pet_id, bytes_used)
);

create policy "shared media updatable by active members"
on public.shared_media_assets
for update
using (public.is_active_pet_member(pet_id))
with check (public.is_active_pet_member(pet_id));

create policy "shared media deletable by owners or uploaders"
on public.shared_media_assets
for delete
using (public.is_pet_owner(pet_id) or owner_user_id = auth.uid());

insert into storage.buckets (id, name, public)
values
  ('pet-media', 'pet-media', false),
  ('memory-media', 'memory-media', false),
  ('vaccine-certificates', 'vaccine-certificates', false)
on conflict (id) do nothing;

create policy "pet-media objects readable by active members"
on storage.objects
for select
using (
  bucket_id = 'pet-media'
  and public.is_active_pet_member((storage.foldername(name))[2]::uuid)
);

create policy "pet-media objects insertable by active members"
on storage.objects
for insert
with check (
  bucket_id = 'pet-media'
  and public.is_active_pet_member((storage.foldername(name))[2]::uuid)
);

create policy "pet-media objects removable by owners or creators"
on storage.objects
for delete
using (
  bucket_id = 'pet-media'
  and public.is_active_pet_member((storage.foldername(name))[2]::uuid)
);

create policy "memory-media objects readable by active members"
on storage.objects
for select
using (
  bucket_id = 'memory-media'
  and public.is_active_pet_member((storage.foldername(name))[2]::uuid)
);

create policy "memory-media objects insertable by active members"
on storage.objects
for insert
with check (
  bucket_id = 'memory-media'
  and public.is_active_pet_member((storage.foldername(name))[2]::uuid)
);

create policy "memory-media objects removable by owners or creators"
on storage.objects
for delete
using (
  bucket_id = 'memory-media'
  and public.is_active_pet_member((storage.foldername(name))[2]::uuid)
);

create policy "vaccine-certificate objects readable by active members"
on storage.objects
for select
using (
  bucket_id = 'vaccine-certificates'
  and public.is_active_pet_member((storage.foldername(name))[2]::uuid)
);

create policy "vaccine-certificate objects insertable by active members"
on storage.objects
for insert
with check (
  bucket_id = 'vaccine-certificates'
  and public.is_active_pet_member((storage.foldername(name))[2]::uuid)
);

create policy "vaccine-certificate objects removable by owners or creators"
on storage.objects
for delete
using (
  bucket_id = 'vaccine-certificates'
  and public.is_active_pet_member((storage.foldername(name))[2]::uuid)
);
