# GitHub Setup

Use this checklist before publishing the repository.

## Recommended Checklist

1. Review the project name, bundle identifier, and signing team.
2. Confirm the license matches how you want to share the code.
3. Replace temporary placeholder photos or keep them intentionally for demo purposes.
4. Verify the app runs in Xcode on your machine.
5. Remove any personal files or generated noise that should not be versioned.

## Suggested Push Flow

```bash
cd /Users/abhishekgangdeb/Documents/GIT/AuriTails
git init
git add .
git commit -m "Initial commit for AuriTails"
git branch -M main
git remote add origin <your-github-repo-url>
git push -u origin main
```

## Good First Repo Settings

- Add a repository description and topics
- Enable issues and discussions if you want feedback
- Add screenshots to the GitHub README later
- Protect `main` if multiple people will collaborate

## Recommended Future Additions

- Persistent local storage for profile and app data
- App screenshots and demo GIFs for the README
- A release checklist for TestFlight or App Store submission
