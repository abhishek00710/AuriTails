# AuriTails

AuriTails is a SwiftUI iOS app concept for pet owners that brings care, routines, memories, and AI-guided pet insights into one cinematic product.

## What it includes

- A glass-inspired dashboard for the owner and pet bond
- A wellness passport for vaccines, food habits, and medical history
- A weekly routines planner with re-scheduling
- A memories studio with slideshow-style storytelling
- A profile studio for editing owner and pet details, plus photos
- A launch screen and animated opening splash for a polished first-run feel

## Why it feels different

Most pet apps focus on one job: reminders, records, cameras, or galleries. AuriTails is designed around the relationship itself, so health, habits, and emotional memories live together in one place.

## Tech Stack

- Swift 5
- SwiftUI
- Xcode project app target with unit and UI test targets
- `PhotosPicker` for temporary profile photo selection

## Project Structure

```text
AuriTails/
  App/
  Models/
  Services/
  ViewModels/
  Views/
AuriTailsTests/
AuriTailsUITests/
```

## Run Locally

1. Open [AuriTails.xcodeproj](/Users/abhishekgangdeb/Documents/GIT/AuriTails/AuriTails.xcodeproj) in Xcode.
2. Select the `AuriTails` scheme.
3. Run on an iPhone simulator or device.

Example build command:

```bash
xcodebuild -project AuriTails.xcodeproj -scheme AuriTails -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/AuriTailsDerivedData CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='' build
```

## Current Notes

- Profile details update live in-app.
- Chosen owner and pet photos are currently session-based and not yet persisted across relaunch.
- The app includes temporary portrait artwork so the UI feels complete before custom photos are added.

## GitHub Prep

Before pushing, review:

- [LICENSE](/Users/abhishekgangdeb/Documents/GIT/AuriTails/LICENSE)
- [CONTRIBUTING.md](/Users/abhishekgangdeb/Documents/GIT/AuriTails/CONTRIBUTING.md)
- [docs/GITHUB_SETUP.md](/Users/abhishekgangdeb/Documents/GIT/AuriTails/docs/GITHUB_SETUP.md)

## Launch Policy Docs

Before public release, review and finalize:

- [docs/PRIVACY_POLICY.md](/Users/abhishekgangdeb/Documents/GIT/AuriTails/docs/PRIVACY_POLICY.md)
- [docs/TERMS_OF_USE.md](/Users/abhishekgangdeb/Documents/GIT/AuriTails/docs/TERMS_OF_USE.md)
- [docs/APP_STORE_PRIVACY_CHECKLIST.md](/Users/abhishekgangdeb/Documents/GIT/AuriTails/docs/APP_STORE_PRIVACY_CHECKLIST.md)

## License

This repository is licensed under the MIT License. See [LICENSE](/Users/abhishekgangdeb/Documents/GIT/AuriTails/LICENSE).
