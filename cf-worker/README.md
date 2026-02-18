# CAMVOTE Cloudflare Worker

Lightweight API layer for CAMVOTE. It validates Firebase ID tokens, writes to Firestore, and now fronts Cloudflare R2 for all file storage while mirroring the access rules defined in `../storage.rules`.

## What it does
- Authenticates users via Firebase ID tokens.
- Persists registrations, voting, and audit data to Firestore.
- Enforces `storage.rules` on Cloudflare R2:
  - `public/**` - public read, admin-only write.
  - `registration_docs/{uid}/**` and `incident_attachments/{uid}/**` - owner or admin read/write.
- Writes to a primary R2 bucket and best-effort replicates each upload to an optional backup bucket; downloads fall back to the backup if the primary object is missing.
- Issues long-lived signed download URLs (HMAC) that admins or the owning user can read without exposing bucket credentials.

## Prerequisites
- Node.js 18+ and npm
- Cloudflare account with R2 enabled
- Wrangler (`npm install -g wrangler` or use `npx wrangler ...`)

## One-time Cloudflare setup
```bash
cd cf-worker
npm install

# Buckets (rename if you change wrangler.toml)
wrangler r2 bucket create camvote-primary
wrangler r2 bucket create camvote-backup   # optional but recommended

# Required secrets (per environment)
wrangler secret put FIREBASE_PROJECT_ID
wrangler secret put FIREBASE_CLIENT_EMAIL
wrangler secret put FIREBASE_PRIVATE_KEY    # copy/paste with \\n for newlines
wrangler secret put FIREBASE_API_KEY
wrangler secret put STORAGE_SIGNING_SECRET  # generate a random 32+ char string
wrangler secret put MAILCHANNELS_API_KEY    # required for support response emails
# Optional Trello proxy secrets (for About dashboard without exposing tokens in web builds)
wrangler secret put TRELLO_KEY
wrangler secret put TRELLO_TOKEN
# Board id can be set in wrangler.toml [vars] as TRELLO_BOARD_ID
```

`wrangler.toml` already binds `R2_PRIMARY` and `R2_BACKUP`; adjust the bucket names there if you pick different names.

## Environment / vars
- `ALLOWED_ORIGINS` (var) - comma-separated origins, default `*`.
- `R2_PRIMARY`, `R2_BACKUP` (bindings) - primary bucket required; backup optional.
- Secrets above are required for production deploys.
- Support reply emails are sent through MailChannels authenticated API calls:
  - `MAILCHANNELS_API_KEY` must be set as a Worker secret.
  - `SUPPORT_EMAIL_FROM`/`SUPPORT_EMAIL_REPLY_TO` should be mailboxes on your own sender domain.
- Optional hardening knobs (vars):
  - `STORAGE_UPLOAD_MAX_BYTES` (default `10485760`) and strict content-type allowlist for uploads.
  - `DEVICE_MAX_PER_USER` (default `1`) for account-level device cap.
  - `DEVICE_REGISTER_RATE_LIMIT_*`, `VOTE_NONCE_RATE_LIMIT_*`, `VOTE_CAST_RATE_LIMIT_*`,
    `REGISTRATION_RATE_LIMIT_*`, `SUPPORT_TICKET_RATE_LIMIT_*`, `CAMGUIDE_RATE_LIMIT_*`
    where each pair is `*_WINDOW_SECONDS` + `*_MAX_REQUESTS`.
  - Tip webhook signatures must be HMAC-SHA256 in `X-Tip-QR-Signature` (raw secret header values are rejected).

## Local dev
```bash
npx wrangler dev
```
Preview buckets are auto-provisioned; you still need the secrets locally.

## Deploy
```bash
npx wrangler deploy
```

## API surface (high level)
- `POST /auth/refresh` (refresh token exchange via Firebase Secure Token API)
- `POST /v1/registration/submit`, `/v1/device/register`, `/v1/vote/nonce`, `/v1/vote/cast`, `/v1/account/delete`, `/v1/admin/registration/decide`, `/v1/user/bootstrap`
- Admin role control: `GET /v1/admin/observers`, `POST /v1/admin/observers/assign`, `POST /v1/admin/observers/create`, `POST /v1/admin/observers/delete`
- Admin content management: `GET /v1/admin/content`, `POST /v1/admin/content/upsert`, `POST /v1/admin/content/delete`, `POST /v1/admin/content/seed`
  - `POST /v1/admin/content/seed` accepts `overwrite` and `purgeBeforeSeed` to fully replace old test/smoke records before seeding curated content.
- Public waitlist: `POST /v1/public/notify-ios` (stores iOS launch requests in Firestore)
- Trello proxy (public): `GET /v1/public/trello-stats`
- Storage:
  - `POST /v1/storage/upload` - JSON `{ path, contentBase64, contentType }` -> `{ downloadUrl }`
  - `GET /v1/storage/file?path=...&uid=...&exp=...&sig=...` - streams the object; also accepts `Authorization: Bearer <idToken>` for owner/admin access.

## Notes on backups / resilience
- Every upload is written to `R2_PRIMARY` and mirrored to `R2_BACKUP` if bound. Reads fall back to the backup automatically.
- For additional resilience, enable Cross-Region Replication (CRR) on the buckets in the Cloudflare dashboard.
- Firestore remains the system of record; export/backup guidance lives in the root README.

