# Firebase iOS Setup Plan

This document describes the recommended Firebase setup for `AuriTails`.

## Official References

- Firebase pricing: https://firebase.google.com/pricing
- Analytics for iOS: https://firebase.google.com/docs/analytics/get-started?platform=ios
- Crashlytics for Apple platforms: https://firebase.google.com/docs/crashlytics/ios/get-started
- Firestore Security Rules: https://firebase.google.com/docs/firestore/security/get-started

## What Firebase Gives AuriTails

- `Firebase Auth`
  for email-link sign-in and caregiver account identity
- `Cloud Firestore`
  for shared `Care Circle` data
- `Firebase Storage`
  for shared photos and vaccine certificates
- `Firebase Analytics`
  for product usage insights
- `Firebase Crashlytics`
  for crash and non-fatal error monitoring

## Pricing Notes

As of April 7, 2026, Firebase's official pricing page shows:

- `Analytics`: no-cost
- `Crashlytics`: no-cost
- `Authentication`: no-cost up to 50K MAUs for non-phone providers
- `Cloud Firestore`: Spark includes no-cost usage limits including stored data, reads, writes, deletes, and egress
- `Cloud Storage`: Spark includes no-cost storage and transfer limits, though this is still the likely scaling bottleneck for shared media

For `AuriTails`, this means Firebase is a practical V1 option if we keep the current media-sharing discipline.

## Recommended SDKs

Install these Swift Package Manager products from:

- `https://github.com/firebase/firebase-ios-sdk.git`

Recommended packages:

- `FirebaseAuth`
- `FirebaseFirestore`
- `FirebaseStorage`
- `FirebaseAnalytics`
- `FirebaseCrashlytics`

## App Startup

The app-side Firebase auth controller now assumes this startup shape:

```swift
import FirebaseCore

FirebaseApp.configure()
```

Use the standard `GoogleService-Info.plist` that Firebase gives you for the iOS app.

The current app scaffold also expects:

- `FIREBASE_EMAIL_LINK_URL`

in the app's Info settings for Firebase email-link auth.

## Auth Direction

Use Firebase email-link auth for Care Circle cloud sign-in.

This keeps the user-facing experience similar:

- enter email
- receive sign-in link
- return to app
- join or open Care Circle

## Firestore Direction

Use Firestore as the shared source of truth for:

- circle membership
- invites
- shared pet profile
- routines
- behavior snapshots
- weights
- vaccines
- medical records
- medications
- symptoms
- food notes
- shared memories metadata

Local Core Data remains the on-device cache and local-first layer.

## Storage Direction

Only upload V1-eligible shared assets:

- pet photo
- bond photo
- selected memory photos
- vaccine certificates

All assets continue to save locally first.

## Analytics Direction

Log key product events only.

Recommended event families:

- onboarding and app mode
- care circle adoption
- routine and check-in engagement
- wellness record additions
- vet pack usage
- media sharing outcomes

Do not log sensitive freeform note text.

## Crashlytics Direction

Use Crashlytics for:

- startup crashes
- auth callback issues
- Firestore decoding failures
- Storage upload failures
- non-fatal sync issues

Recommended non-fatal capture areas:

- invite handling
- quota checks
- record mapping failures
- corrupted cloud payloads

## Migration Recommendation

The current migration direction is:

1. keep current local-first app behavior intact
2. replace only the cloud-sharing/auth layer with Firebase
3. keep the same product rules from `V1_MEDIA_SYNC_POLICY.md`

## Recommendation

For `AuriTails` V1, Firebase is attractive because:

- it can cover backend + analytics + crash reporting together
- the free tier is reasonable for early launch
- it fits the app's local-first plus selective-cloud design

The main ongoing caution remains shared media usage, not analytics or crash reporting.
