# Supabase iOS Auth Setup

This document describes the current live Supabase auth setup for the iOS app.

The app now contains:

- `SupabaseConfiguration`
- `AuthSessionController`
- `CareCircleAuthView`

These now provide the real magic-link entry point while preserving the local-first app flow when configuration is missing.

## Current State

Right now:

- the auth UI is present in `Care Circle`
- configuration is read from app settings keys
- if keys are missing, auth stays dormant
- when keys are present, the app uses the official `supabase-swift` client for magic-link auth
- local app behavior remains unchanged

This is intentional for V1 preparation.

## Required App Config Keys

Add these keys to the app configuration when you are ready to turn on live auth:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`
- `SUPABASE_REDIRECT_URL`

Example:

- `SUPABASE_URL = https://your-project.supabase.co`
- `SUPABASE_PUBLISHABLE_KEY = your-publishable-anon-key`
- `SUPABASE_REDIRECT_URL = auritails://auth/callback`

## Recommended Live Integration Path

1. Add the official `supabase-swift` package.
2. Configure `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, and `SUPABASE_REDIRECT_URL`.
3. Add the same redirect URL in Supabase Auth settings.
4. Use the signed-in user to start reading and writing `Care Circle` memberships.

## Official Reference

Supabase's official Swift auth flow uses:

- `SupabaseClient`
- `auth.authStateChanges`
- `auth.signInWithOTP(email:redirectTo:)`
- `auth.handle(url)`
- magic-link login flow

Reference:

- [Build a User Management App with Swift and SwiftUI](https://supabase.com/docs/guides/getting-started/tutorials/with-swift)

## Suggested Live Swap

The live controller now:

- creates a Supabase client from `SupabaseConfiguration`
- sends real magic-link auth requests
- listens for auth state changes
- updates the UI phase when the session changes
- still exposes a DEBUG-only simulate-signed-in action for development convenience

## Important Product Rule

Even after live auth is enabled:

- local pet data stays local-first
- cloud auth enables shared Care Circle features
- media upload limits should still follow `V1_MEDIA_SYNC_POLICY.md`
