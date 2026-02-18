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

## Smoke/E2E data cleanup

Use this helper to remove known smoke/e2e records from Firebase Auth and Firestore.
It targets users/emails that match these markers by default:

- `camvoteadmin.inspect+`
- `camvoteadmin.e2e+`
- `camvoteappassist+e2e`

Dry run (no deletion):

```
cd scripts
node cleanup-smoke-data.mjs --serviceAccount ../service-account.json
```

Apply deletion:

```
cd scripts
node cleanup-smoke-data.mjs --serviceAccount ../service-account.json --apply
```

Optional extra markers:

```
node cleanup-smoke-data.mjs \
  --serviceAccount ../service-account.json \
  --emailMarker "qa+e2e@camvote.app,bot+smoke@camvote.app" \
  --userMarker "camvoteadmin.qa"
```

## Deploy helpers (PowerShell)

From repo root:

```
pwsh scripts/deploy-worker.ps1
pwsh scripts/deploy-web.ps1 -ProjectName camvote
pwsh scripts/deploy-all.ps1 -PagesProject camvote
pwsh scripts/validate-mobile-config.ps1
pwsh scripts/release-android.ps1
```

Notes:
- `deploy-web.ps1` builds with `--release` by default.
- `deploy-all.ps1` also deploys Firestore rules/indexes and the Worker.
- `deploy-all.ps1` requires `GOOGLE_APPLICATION_CREDENTIALS` (or `service-account.json` at repo root) for Firebase auth.
- `FIREBASE_TOKEN` is deprecated and intentionally ignored by deploy scripts.
- `deploy-worker.ps1`, `deploy-web.ps1`, and `deploy-all.ps1` require `CLOUDFLARE_API_TOKEN` (optionally `CLOUDFLARE_ACCOUNT_ID`).
- Deploy scripts now require a clean git worktree by default; pass `-AllowDirty` only when intentional.
- `deploy-web.ps1` and `deploy-all.ps1` run Flutter analyze/test by default; pass `-SkipQualityChecks` if needed.
- `validate-mobile-config.ps1` checks `lib/firebase_options.dart` against `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.
- `release-android.ps1` builds signed Android release artifacts (`.aab` + split `.apk`) and writes SHA-256 checksums to `build/mobile-android-sha256.txt`.

Recommended secure session before deploy:

```
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\secure\camvote-service-account.json"
$env:CLOUDFLARE_API_TOKEN="<cloudflare-token>"
$env:CLOUDFLARE_ACCOUNT_ID="<cloudflare-account-id>"   # optional
pwsh scripts/deploy-all.ps1 -PagesProject camvote
```

## Gmail support sender (optional)

If you want support replies to be sent from `camvoteappassist@gmail.com` and actually deliver to Gmail inboxes,
use Gmail OAuth (MailChannels will bounce `From: *@gmail.com` due to DMARC).

1. In Google Cloud Console (same project as Firebase), enable Gmail API.
2. Create an OAuth Client (Web app) with redirect URI `http://localhost:53682/oauth2callback`.
3. Run the helper to obtain a refresh token:

```
cd scripts
node gmail-refresh-token.mjs --clientId "<client-id>" --clientSecret "<client-secret>"
```

Then set Worker secrets:

```
cd cf-worker
npx wrangler secret put GMAIL_CLIENT_ID
npx wrangler secret put GMAIL_CLIENT_SECRET
npx wrangler secret put GMAIL_REFRESH_TOKEN
npx wrangler deploy
```

## Android release script arguments

```
pwsh scripts/release-android.ps1 `
  -ApiBaseUrl https://camvote.romuald-djagnisigning.workers.dev `
  -SkipPubGet `
  -SkipValidation `
  -SkipApk `
  -SkipAab
```

Use flags only when needed:
- `-SkipPubGet`: skip `flutter pub get`
- `-SkipValidation`: skip `dart run tools/validate_firebase_mobile_config.dart`
- `-SkipApk`: build only App Bundle
- `-SkipAab`: build only APKs
