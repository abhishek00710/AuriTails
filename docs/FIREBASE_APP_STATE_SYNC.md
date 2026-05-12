# Firebase App State Sync

`AuriTails` keeps the app local-first, but signed-in users can now store a metadata-only app state backup in Firestore so their records can come back after reinstall.

## Firestore Path

The current app writes one account-scoped document:

```text
users/{uid}/appState/current
```

The document stores a Base64-encoded JSON payload of `PersistedAppState` plus lightweight counts and timestamps.

## What Syncs In V1

Synced:

- owner profile text
- pet profile text and pet status
- routines
- behavior check-ins
- weight entries
- vaccines metadata
- medications
- symptoms
- medical history
- food notes
- memories metadata
- Care Circle local snapshot state
- notification preferences

Not synced yet:

- owner photo
- pet photo
- bond photo
- memory images
- vaccine certificates

Those media fields are stripped before upload so Firestore stays small and predictable. Media should use Firebase Storage later with the existing `10 MB per Care Circle` policy.

## Security Rules

Add this rule shape in Firebase Console under `Firestore Database > Rules`:

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/appState/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

If your project already has rules, merge this block into the existing `match /databases/{database}/documents` body instead of replacing everything.

## Restore Behavior

On real Firebase sign-in:

- If the local install is fresh/empty and cloud data exists, AuriTails restores the Firestore backup into local storage.
- If local data already exists, AuriTails keeps local data and future edits update the cloud backup.
- If cloud data does not exist, AuriTails creates the first cloud backup from local data.

Debug simulated sign-in does not sync because it has no real Firebase `uid`.
