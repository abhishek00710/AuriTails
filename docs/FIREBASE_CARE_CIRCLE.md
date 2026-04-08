# Firebase Care Circle Blueprint

This document defines the Firebase-based backend plan for `AuriTails` V1.

The goal is to support one shared pet space with multiple trusted caregivers while preserving the app's current local-first behavior.

## Why Firebase For V1

Firebase fits `AuriTails` well if the priority is:

- fast Apple SDK integration
- managed auth
- realtime shared data
- crash reporting and analytics in the same stack

Recommended Firebase products for `AuriTails`:

- `Firebase Authentication`
- `Cloud Firestore`
- `Firebase Storage`
- `Firebase Analytics`
- `Firebase Crashlytics`

## Product Rules That Stay The Same

These do not change just because the backend changes:

- all user data continues to save locally first
- all media continues to save locally first
- local use must never be blocked by cloud quota
- cloud sync exists for `Care Circle`, not as the only copy
- shared cloud media is still capped at `10 MB per Care Circle` for V1

## Auth Recommendation

Use `Firebase Authentication` with `Email Link Authentication` for v1.

Why:

- good fit for consumer iOS apps
- no password reset UX to manage
- easy invite acceptance path
- close match to the current magic-link concept already present in the app

Suggested auth flow:

1. Owner signs in with email link.
2. Owner creates or claims the shared pet space.
3. Owner invites a caregiver by email.
4. Invite creates a pending membership record.
5. Caregiver taps the link, signs in, and joins the same `Care Circle`.

## Firestore Model

Recommended top-level collections:

- `users`
- `careCircles`
- `careInvites`
- `activityEvents`

Recommended shared-content subcollections under each care circle:

- `routines`
- `behaviorSnapshots`
- `weightEntries`
- `vaccines`
- `medicalEntries`
- `medications`
- `symptoms`
- `foodPreferences`
- `memories`
- `sharedMediaAssets`

## Suggested Document Shapes

### `users/{userId}`

```json
{
  "displayName": "Maya",
  "email": "maya@example.com",
  "avatarPath": "users/<userId>/profile.jpg",
  "createdAt": "<server timestamp>",
  "updatedAt": "<server timestamp>"
}
```

### `careCircles/{circleId}`

```json
{
  "createdBy": "<userId>",
  "petName": "Sol",
  "species": "Dog",
  "breed": "Nova Scotia Duck Tolling Retriever",
  "ageDescription": "3 years old",
  "weightDescription": "19.4 kg",
  "favoriteTreat": "Blueberry yogurt drops",
  "bondStatement": "Best energy when play is paired with a quiet recovery block afterward.",
  "energySummary": "Brightest after trail mornings and calmer after early dinners.",
  "petPhotoPath": "careCircles/<circleId>/pet/profile.jpg",
  "bondPhotoPath": "careCircles/<circleId>/pet/bond.jpg",
  "cloudMediaBytesUsed": 0,
  "cloudMediaBytesLimit": 10485760,
  "createdAt": "<server timestamp>",
  "updatedAt": "<server timestamp>"
}
```

### `careCircles/{circleId}/members/{userId}`

```json
{
  "userId": "<userId>",
  "role": "owner",
  "status": "active",
  "invitedBy": "<userId>",
  "createdAt": "<server timestamp>",
  "updatedAt": "<server timestamp>"
}
```

Supported values:

- `role`: `owner`, `caregiver`
- `status`: `pending`, `active`

### `careInvites/{inviteId}`

```json
{
  "circleId": "<circleId>",
  "email": "caregiver@example.com",
  "role": "caregiver",
  "status": "pending",
  "createdBy": "<userId>",
  "expiresAt": "<timestamp>",
  "createdAt": "<server timestamp>",
  "updatedAt": "<server timestamp>"
}
```

### Example shared record: `careCircles/{circleId}/behaviorSnapshots/{snapshotId}`

```json
{
  "weekday": 2,
  "energy": 0.74,
  "calmness": 0.9,
  "appetite": 0.98,
  "sleepHours": 13.0,
  "note": "Settled after slower evening and early dinner.",
  "createdBy": "<userId>",
  "updatedBy": "<userId>",
  "createdAt": "<server timestamp>",
  "updatedAt": "<server timestamp>"
}
```

Apply the same metadata pattern to the other shared documents:

- `createdBy`
- `updatedBy`
- `createdAt`
- `updatedAt`

## Shared Media Model

Shared media should be tracked in:

- `careCircles/{circleId}/sharedMediaAssets/{assetId}`

Example:

```json
{
  "kind": "memoryPhoto",
  "ownerRecordType": "memory",
  "ownerRecordId": "<memoryId>",
  "storagePath": "careCircles/<circleId>/memories/<memoryId>.jpg",
  "byteSize": 284122,
  "syncState": "synced",
  "createdBy": "<userId>",
  "createdAt": "<server timestamp>",
  "updatedAt": "<server timestamp>"
}
```

Suggested sync state values:

- `localOnly`
- `pendingUpload`
- `synced`
- `uploadDeferred`
- `uploadFailed`

## Storage Structure

Recommended Firebase Storage paths:

- `careCircles/<circleId>/pet/profile.jpg`
- `careCircles/<circleId>/pet/bond.jpg`
- `careCircles/<circleId>/vaccines/<vaccineId>.jpg`
- `careCircles/<circleId>/memories/<memoryId>.jpg`

Use Firebase Storage only for the small subset of media that is eligible for Care Circle sharing in V1.

Everything else remains local-only on device.

## V1 Quota Handling

Quota should be enforced per `Care Circle`.

Track on the `careCircles/{circleId}` document:

- `cloudMediaBytesUsed`
- `cloudMediaBytesLimit`

Default:

- `cloudMediaBytesLimit = 10 * 1024 * 1024`

Recommended upload rule:

- compress first
- check remaining quota
- if quota is exceeded, keep local save and mark the item `uploadDeferred`

Do not block:

- creating a memory
- adding a vaccine certificate
- updating the pet profile

Only block the remote shared upload itself.

## Firestore Security Rules Direction

At a high level, rules should allow access only when the authenticated user is an active member of the relevant care circle.

### Helpers

- member can read circle data only if membership status is `active`
- owner can manage members and invites
- caregiver can read and write shared care records

### Recommended access rules

- `users`
  - user can read and update only their own user document
- `careCircles`
  - active members can read
  - owners can update top-level circle metadata
- `members`
  - active members can read member list
  - owners can create, update, and remove members
- `careInvites`
  - owners can create and revoke invites
  - invite acceptance should be handled through controlled client logic or Cloud Functions
- shared subcollections
  - active members can read
  - active members can create
  - creator or owner can update/delete in v1

## Suggested Firebase Storage Rules Direction

Allow read/write only when:

- the user is authenticated
- the file path belongs to a care circle
- the user is an active member of that care circle

This should be checked against Firestore membership state.

## Analytics Plan

Firebase Analytics is a strong fit here because it is no-cost on Firebase pricing and helps answer product questions early.

Recommended events for `AuriTails`:

- `care_circle_sign_in_started`
- `care_circle_sign_in_completed`
- `care_circle_invite_created`
- `care_circle_member_joined`
- `daily_checkin_logged`
- `routine_completed`
- `vaccine_record_added`
- `symptom_logged`
- `memory_shared`
- `vet_pack_exported`
- `media_share_deferred_quota`

Recommended user properties:

- `app_mode`: `demo`, `live`
- `has_care_circle`: `true`, `false`
- `pet_species`
- `circle_role`

Keep analytics free of personally identifying pet-health detail. Use coarse event names and counts, not raw note text.

## Crashlytics Plan

Firebase Crashlytics is also listed as no-cost on Firebase pricing and is a good fit for a production mobile app.

Recommended use:

- install Crashlytics in all builds except maybe local developer-only debug if you want quieter dashboards
- record non-fatal errors around:
  - auth callback failures
  - Firestore decoding errors
  - Storage upload failures
  - quota calculation mismatches
  - invite acceptance issues

Recommended custom keys:

- `app_mode`
- `care_circle_enabled`
- `circle_role`
- `sync_state`
- `firebase_auth_configured`

Do not put sensitive pet notes or medical text into Crashlytics keys/logs.

## Cloud Functions Candidates

You can keep v1 light, but these are the best candidates if needed:

- invite acceptance finalization
- quota recalculation after upload/delete
- activity event generation
- membership cleanup when owner removes a caregiver

These can wait until after the basic client integration if you want to stay simple.

## iOS Integration Order

Recommended implementation order:

1. Add Firebase project and `GoogleService-Info.plist`.
2. Add Firebase SDK packages:
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseStorage`
   - `FirebaseAnalytics`
   - `FirebaseCrashlytics`
3. Configure `FirebaseApp.configure()` in app startup.
4. Replace the Supabase auth shell with Firebase email-link auth.
5. Wire `Care Circle` membership reads/writes to Firestore.
6. Add shared media upload support with the 10 MB quota rule.
7. Add analytics events and Crashlytics custom keys.

## Recommendation

If you want one backend stack that handles:

- authentication
- shared records
- file storage
- analytics
- crash reporting

then Firebase is a very reasonable V1 choice for `AuriTails`.

The biggest tradeoff versus Supabase is that your shared data model becomes document-oriented instead of SQL-oriented.
