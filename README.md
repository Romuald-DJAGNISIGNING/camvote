# CamVote — Secure Digital Electoral System

“Your Vote. Your Voice. Secure.” — CamVote delivers a cross-platform (Android, iOS, Web) civic-tech experience for transparent, fraud-resistant elections in Cameroon.

## At a Glance
- Flutter client (Android, iOS, Web) with biometric checks, voter dashboards, incident reporting, and public results views.
- Backend: Cloudflare Worker API + Firebase Auth + Firestore.
- Storage: Cloudflare R2 gateway that enforces the existing `storage.rules`, issues signed URLs, writes to a primary bucket, and mirrors uploads to an optional backup bucket with automatic read failover.
- Backups: Firestore export plan plus R2 cross-region/dual-bucket replication.

## Platforms & Tech
[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white&style=for-the-badge)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white&style=for-the-badge)](https://dart.dev/)
[![Android](https://img.shields.io/badge/Android-3DDC84?logo=android&logoColor=white&style=for-the-badge)](https://developer.android.com/)
[![iOS](https://img.shields.io/badge/iOS-000000?logo=apple&logoColor=white&style=for-the-badge)](https://developer.apple.com/)
[![Web](https://img.shields.io/badge/Web-HTML5-E34F26?logo=html5&logoColor=white&style=for-the-badge)](https://developer.mozilla.org/en-US/docs/Web)

## Architecture
- **Client apps**: Flutter UI, Riverpod state, Clean Architecture layers.
- **Identity**: Firebase Auth (ID tokens feed the Worker).
- **Data**: Firestore (rules + indexes in `firestore.rules` / `firestore.indexes.json`).
- **API**: Cloudflare Worker (`cf-worker/`) talking to Firestore and applying business rules.
- **Role control**: Admins can grant/revoke observer access (Worker + admin UI).
- **Storage**: Cloudflare R2 via the Worker. `storage.rules` stays canonical:
  - `public/**` — public read; admin-only write.
  - `registration_docs/{uid}/**` — owner or admin read/write.
  - `incident_attachments/{uid}/**` — owner or admin read/write.
- **Resilience**: uploads go to `R2_PRIMARY` and best-effort replicate to `R2_BACKUP`; downloads fall back to the backup bucket. Enable CRR in Cloudflare for geographic redundancy.

## Getting Started (local)
1. Prereqs: Flutter SDK (Dart >= 3.10), Node 18+ for the Worker, Firebase project for Auth/Firestore, Cloudflare account with R2 enabled.
2. Install Flutter deps:
   ```bash
   flutter pub get
   ```
3. Copy env file and set values:
   ```bash
   cp .env.example .env
   # set CAMVOTE_API_BASE_URL to your Worker URL
   ```
4. Run the app:
   ```bash
   flutter run --dart-define=CAMVOTE_API_BASE_URL=https://camvote.romuald-djagnisigning.workers.dev
   ```
   (Override `CAMVOTE_API_BASE_URL` in `.env` or via `--dart-define` for other environments.)

## Storage & Backups (Cloudflare)
- The Worker enforces `storage.rules` in front of R2 and returns signed download URLs.
- Quick setup (see `cf-worker/README.md` for details):
  ```bash
  cd cf-worker
  npm install
  wrangler r2 bucket create camvote-primary
  wrangler r2 bucket create camvote-backup   # optional but recommended
  wrangler secret put STORAGE_SIGNING_SECRET   # random 32+ chars
  # add Firebase secrets: FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY, FIREBASE_API_KEY
  wrangler deploy
  ```
- Firestore backups (run from your workstation/CI where `gcloud` is configured):
  ```bash
  gcloud firestore export gs://<gcs-backup-bucket>/camvote-backups/$(date +%Y%m%d)
  # optionally sync that export into R2 backup storage using your preferred tool (e.g., rclone -> R2)
  ```
- For resiliency, enable Cross-Region Replication on both R2 buckets. The Worker already mirrors writes and reads from the backup if the primary object is missing.

## Deploy Pipeline
1. **Firestore rules & indexes** (keeps billing-free Firestore tier):
   ```bash
   firebase deploy --only "firestore:rules,firestore:indexes" --force
   ```
2. **Cloudflare Worker API**:
   ```bash
   cd cf-worker
   npm install
   npx wrangler deploy
   ```
3. **Optional Web build**:
   ```bash
   flutter build web --release --no-wasm-dry-run   # outputs to build/web
   # host via Cloudflare Pages or Pages + R2 for assets
   ```
   **Cloudflare Pages (recommended, free):**
   - Set build command: `flutter build web --release --no-wasm-dry-run`
   - Output directory: `build/web`
   - Project name: `camvote`
   - This repo ships `web/_redirects` and `web/_headers` for SPA routing and caching.
   - Routes like `/public`, `/admin`, `/observer` will work after deploy.
   - Static mobile pages are served from `/mobile/` and `/mobile/app-store/index.html`.
4. **Helper**: `pwsh scripts/deploy-all.ps1` (skips web with `-SkipWebBuild`).

## Release Preflight
Run this before any production push/deploy:
```bash
flutter analyze
flutter test
cd cf-worker && npm ci && npm run lint
```
- Confirm no secrets are staged:
  ```bash
  git ls-files | grep -E '(^\.env$|^service-account\.json$|wrangler-account\.json|firebase-tools\.json)'
  ```
- If the command returns anything, remove/rotate credentials before pushing.

## Web Portal Links
- General portal: `https://camvote.pages.dev/portal`
- Admin portal home: `https://camvote.pages.dev/backoffice`
- Optional aliases:
  - `https://camvote.pages.dev/general` -> `/portal`
  - `https://camvote.pages.dev/admin-home` -> `/backoffice`

## Build & Test Checklist
- Android:
  ```bash
  flutter build apk --release --dart-define=CAMVOTE_API_BASE_URL=https://your-worker.workers.dev
  ```
- iOS (requires Xcode signing):
  ```bash
  flutter build ipa --release --dart-define=CAMVOTE_API_BASE_URL=https://your-worker.workers.dev
  ```
- Web:
  ```bash
  flutter build web --no-wasm-dry-run --dart-define=CAMVOTE_API_BASE_URL=https://your-worker.workers.dev
  ```
- After manual testing, capture clean screenshots (phone + tablet) and drop them in `assets/screenshots/` or `web/mobile/media/` for README / store listings. Keep sensitive data out of screenshots.

## Environment Keys (client)
- `CAMVOTE_API_BASE_URL`, `CAMVOTE_TRELLO_KEY`, `CAMVOTE_TRELLO_TOKEN`, `CAMVOTE_TRELLO_BOARD_ID`
- Support + map settings: `CAMVOTE_SUPPORT_EMAIL`, `CAMVOTE_SUPPORT_HOTLINE`, `CAMVOTE_MAP_TILE_URL`, `CAMVOTE_MAP_TILE_KEY`
- Store links: `CAMVOTE_PLAY_STORE_URL`, `CAMVOTE_APP_STORE_URL`, `CAMVOTE_MOBILE_FEATURES_URL`, `CAMVOTE_IOS_APP_LIVE`
  - Keep `CAMVOTE_IOS_APP_LIVE=false` while iOS is pending review so App Store buttons open the local `/mobile/app-store` coming-soon page.
  - Set `CAMVOTE_IOS_APP_LIVE=true` only when your real `CAMVOTE_APP_STORE_URL` is live.

## Data & Assets
- Map sources and licensing: `assets/maps/README.md`
- Offline map datasets (not bundled): `data/maps/README.md`
- Worker storage policy: `cf-worker/STORAGE_POLICY.md`

## Security / Git hygiene
- Secrets are ignored via `.gitignore` (`.env`, service accounts, wrangler state, keystores, store JSON/plist). Google service files already tracked in this working tree—rotate credentials if you don’t intend to keep them in git.
- Never commit real production keys. Use the sample `.env.example` and wrangler secrets instead.

## Academic Context
Originally developed for university coursework (Mobile Application + Software Design/Modeling) and now expanded toward a production-ready civic-tech stack.
