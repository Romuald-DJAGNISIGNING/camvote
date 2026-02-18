# Admin seeding helper

This script mirrors the Firestore rules by creating a Firebase Auth user and a `users/{uid}` document with the `admin` role so you can log in immediately after deployment.

## Prerequisites

1. Download a Firebase service account JSON for the `camvote--backend` project (Settings → Service accounts) and save it inside the repo (e.g. `service-account.json`).  
2. Install the script dependencies:
   ```
   cd scripts
   npm install
   ```

## Usage

Run the script with the desired admin credentials:

```
cd scripts
node seed-admin.mjs \
  --email admin@camvote.app \
  --password "CamvoteAdmin!23" \
  --fullName "Romuald DJAGNI SIGNING" \
  --username camvote-admin \
  --serviceAccount ../service-account.json
```

Alternatively, set the `FIREBASE_SERVICE_ACCOUNT` environment variable instead of `--serviceAccount`.

It will:

- Create (or update) the Firebase Auth user with the supplied email/password.  
- Create/merge the Firestore `users/{uid}` document with `role: 'admin'`, `status: 'active'`, `verified: true`.

After running the script, log in on the web app using the seeded credentials.

Keep the service account JSON out of git (already covered by `.gitignore`). Rotate it if it was ever committed.

## Deploy helpers (PowerShell)

From repo root:

```
pwsh scripts/deploy-worker.ps1
pwsh scripts/deploy-web.ps1 -ProjectName camvote
pwsh scripts/deploy-all.ps1 -PagesProject camvote
pwsh scripts/validate-mobile-config.ps1
```

Notes:
- `deploy-web.ps1` builds with `--release` by default.
- `deploy-all.ps1` also deploys Firestore rules/indexes and the Worker.
- `deploy-all.ps1` prefers `GOOGLE_APPLICATION_CREDENTIALS` (or `service-account.json` at repo root) for Firebase auth and avoids deprecated `FIREBASE_TOKEN` when service-account auth is available.
- Web deploy commands pass `--commit-dirty=true` so deployment is not blocked/warned by local uncommitted changes.
- `validate-mobile-config.ps1` checks `lib/firebase_options.dart` against `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.
