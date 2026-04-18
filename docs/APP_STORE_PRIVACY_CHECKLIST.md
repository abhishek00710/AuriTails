# AuriTails App Store Privacy Checklist

Last updated: April 18, 2026

This checklist helps prepare `AuriTails` for App Store submission and privacy disclosures.

## Core Documents

- Publish a public Privacy Policy URL
- Publish Terms of Use or usage terms URL
- Add a support URL
- Add a marketing or product website if available

## Permissions Used by the App

Current permission-related features in the app include:

- `Photos`
  selecting owner, pet, memory, and certificate images
- `Camera`
  scanning documents such as vaccine certificates
- `Location`
  nearby pet hospital lookup
- `Notifications`
  local reminders for routines, vaccines, medications, and memories

Check that all purpose strings remain accurate in the app target.

## Data Categories to Review for App Store Privacy

You should review whether the app collects or processes:

- contact info
  such as email for cloud sign-in
- user content
  such as records, notes, photos, and documents
- identifiers
  such as Firebase auth IDs or analytics identifiers
- diagnostics
  such as crash logs and error reports
- usage data
  such as analytics events
- location
  if nearby pet care lookup is used

## Suggested Submission Positioning

Local-only builds:

- emphasize local-first storage
- disclose only what is actually collected in the shipping build

Cloud-enabled builds:

- disclose Firebase Authentication usage
- disclose analytics and crash reporting if enabled
- disclose shared caregiver and cloud-synced pet data behavior

## Firebase-Specific Review

If Firebase is enabled in the shipping app:

- confirm Authentication methods actually used
- confirm Firestore collections match the live feature set
- confirm Storage only accepts intended media
- confirm Analytics events avoid sensitive freeform text
- confirm Crashlytics avoids unnecessary personal data

## Product Transparency

Before launch, make sure the app clearly explains:

- what stays local
- what may sync to cloud
- what shared caregivers can see
- what happens when the app is deleted
- how backups work

## Recommended Final Launch Decisions

Before shipping V1, lock these answers:

- Is real `Care Circle` cloud sharing enabled in V1 or not?
- Is Firebase Analytics enabled in production?
- Is Crashlytics enabled in production?
- Which media types are eligible for cloud sync?
- Is the `10 MB per Care Circle` cloud media rule active in production?

## Final Review Reminder

Do a final legal and App Store review before launch. This checklist is product-prep guidance, not legal advice.
