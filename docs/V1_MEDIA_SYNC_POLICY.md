# AuriTails V1 Media Sync Policy

This document defines how media should behave in `AuriTails` V1 when family sharing is introduced through `Care Circle`.

The most important rule:

- media is always saved locally first
- cloud sync is optional and selective
- cloud quota must never block local use of the app

## Core Principle

`AuriTails` remains local-first.

That means:

- every photo or certificate the user adds is stored locally on device
- local viewing and editing do not depend on Supabase
- cloud upload exists only to support sharing and cross-device family access
- if cloud sync fails, local behavior still works

## V1 Quota Rule

`10 MB cloud media quota per Care Circle`

This quota applies only to cloud-synced shared media.

It does not apply to:

- local media saved on device
- local cache
- local backup/export files

## What Must Always Save Locally

These should always be stored locally first:

- owner photo
- pet photo
- bond photo
- memory photos
- vaccine certificate images
- future attachments or wellness documents

If the app is still installed, these local files should remain available regardless of cloud state.

## What Can Be Uploaded To Cloud In V1

Only media needed for shared family access should be eligible for upload.

Recommended V1 upload-eligible media:

- pet photo
- bond photo
- memory photos explicitly marked for sharing
- vaccine certificates explicitly tied to shared wellness records

Everything else can remain local-only in V1.

## V1 Sync Priority

Use this order when deciding what media should consume Care Circle quota:

1. pet photo
2. bond photo
3. vaccine certificates
4. selected memory photos

If quota becomes tight, lower-priority uploads should stop first.

## Local vs Shared States

Each media item should have a clear sync state:

- `localOnly`
  saved locally and not uploaded
- `pendingUpload`
  eligible for sharing, waiting to upload
- `synced`
  uploaded and available to Care Circle members
- `uploadDeferred`
  saved locally but not uploaded because quota or network blocked it
- `uploadFailed`
  saved locally but upload failed

## Product Rule

Local save must succeed before any upload begins.

Never do:

- upload first, local second
- reject local save because quota is full
- remove local media because remote sync failed

## Compression Rules

For V1, compress before upload but keep the original local copy if practical.

Recommended cloud upload rules:

- image max long edge: `1600 px`
- format: `JPEG`
- default quality: `0.72` to `0.78`
- strip unnecessary metadata where possible

For certificates:

- if scanned/imported as image, compress similarly
- if PDF is needed later, keep PDF local but upload a smaller preview image in V1 unless full remote document sharing is required

## Quota Accounting

Quota should be tracked per `Care Circle`, not per user.

Track:

- `cloud_media_bytes_used`
- `cloud_media_bytes_limit`

Default:

- `cloud_media_bytes_limit = 10 * 1024 * 1024`

Suggested accounting behavior:

- count actual uploaded file size after compression
- recalculate when shared media is deleted or replaced

## Upload Eligibility Rules

A media item can upload only if:

- the pet belongs to a Care Circle
- the user has permission to share it
- the item is marked shareable for V1
- there is enough remaining Care Circle quota
- network is available
- auth/session is valid

If any of those fail, the item still remains local.

## Fallback Behavior When Quota Is Full

If quota is full:

- save media locally
- mark item `uploadDeferred`
- keep metadata syncing if possible
- show that the media is `local only` or `not yet shared`

Do not block:

- creating a memory
- adding a vaccine certificate
- updating the pet profile

The only blocked action is cloud sharing of that media.

## Replacement Rules

If a shared media item is replaced:

- keep the new local version immediately
- delete or supersede old remote asset
- update quota usage after replacement

If replacement would exceed quota:

- keep new local version
- leave remote version unchanged until user resolves quota
- surface a status explaining this clearly

## Deletion Rules

If a user deletes a media item:

- remove local reference immediately
- if synced, queue remote deletion
- reclaim remote quota after deletion succeeds

If remote deletion fails:

- local deletion should still remain respected in UI
- app can retry remote cleanup later

## Suggested UI Surfaces

### Care Circle Settings

Show:

- `Cloud media used: 4.2 MB of 10 MB`
- progress bar
- list of largest shared uploads
- actions to remove old shared media

### Media Item UI

Show one of:

- `Stored locally`
- `Shared with Care Circle`
- `Saved locally, waiting to upload`
- `Saved locally, not shared because circle storage is full`

### Upload CTA Copy

Examples:

- `Share with Care Circle`
- `Keep local only`
- `Shared copy paused until more cloud space is available`

## Recommended V1 UX Copy

Short system copy:

- `Saved locally on this device.`
- `Shared with your Care Circle.`
- `Saved locally, but not shared because your Care Circle has reached its 10 MB cloud limit.`
- `You can still use this media normally on your device.`

## Suggested Data Model Additions

For each media-backed record, consider:

- `localMediaPath`
- `remoteMediaPath`
- `syncStatus`
- `remoteBytes`
- `isShareEligible`
- `lastSyncAttemptAt`

For Care Circle:

- `cloudMediaBytesUsed`
- `cloudMediaBytesLimit`

## Sync Strategy

Recommended V1 flow:

1. user adds media
2. app saves local media
3. app creates/updates local record
4. app checks share eligibility
5. if eligible and quota allows, compress and upload
6. if upload succeeds, mark `synced`
7. if upload cannot proceed, keep `localOnly` or `uploadDeferred`

## Offline Behavior

Offline must not change local behavior.

If offline:

- save locally
- mark item `pendingUpload`
- retry later

## Relationship To Firebase

For V1:

- Firebase stores shared media only
- Firebase quota affects only remote shared copies
- Firebase is not the only copy of user media
- local device storage remains the primary immediate source

## Non-Goals For V1

Do not attempt in V1:

- full-resolution cloud archival for all media
- unlimited family gallery sync
- automatic background upload of every photo
- cross-device recovery of all local-only media after uninstall

Those can come later when storage and pricing strategy are stronger.

## Practical Outcome

This policy lets `AuriTails`:

- feel reliable offline
- stay beautiful and local-first
- keep Firebase free-tier usage under control
- support real family sharing without making cloud sync a hard dependency
