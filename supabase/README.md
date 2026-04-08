# Supabase Setup

This folder contains the first backend migration scaffold for `AuriTails`.

These migrations are designed for the future `Care Circle` rollout and align with:

- [SUPABASE_CARE_CIRCLE.md](/Users/abhishekgangdeb/Documents/GIT/AuriTails/docs/SUPABASE_CARE_CIRCLE.md)
- [V1_MEDIA_SYNC_POLICY.md](/Users/abhishekgangdeb/Documents/GIT/AuriTails/docs/V1_MEDIA_SYNC_POLICY.md)

## What These Migrations Cover

- user profiles
- pets
- Care Circle memberships
- invites
- care activity feed
- shared wellness and routine tables
- shared media asset tracking
- `10 MB` cloud media quota per Care Circle
- row-level security

## Important V1 Principle

These migrations support shared cloud state.

They do **not** change the app's local-first rule:

- local data remains primary on device
- media is always saved locally first
- cloud upload is selective and quota-constrained

## Suggested Rollout

1. Create Supabase project.
2. Apply migrations in `supabase/migrations`.
3. Enable Auth with magic links.
4. Add iOS auth integration.
5. Connect `Care Circle` UI to remote membership data.
6. Sync shared records one domain at a time.
