# Storage policy (Cloudflare R2)

`storage.rules` remains the canonical access model. The Worker now enforces those rules in front of Cloudflare R2 and adds redundancy.

## Access model (mirrors `storage.rules`)
- `public/**` - read: anyone; write: admins only.
- `registration_docs/{uid}/**` - read/write: owner `uid` or admins.
- `incident_attachments/{uid}/**` - read/write: owner `uid` or admins.
- `tip_receipts/{uid}/**` - read/write: owner `uid` or admins.

## How it is enforced
- `POST /v1/storage/upload` takes `{ path, contentBase64, contentType }`, checks the caller's Firebase ID token and role, writes to `R2_PRIMARY`, and best-effort replicates to `R2_BACKUP` if present.
- `GET /v1/storage/file` streams the object. Authorization options:
  - Admins or the owning `uid` via `Authorization: Bearer <idToken>`.
  - Long-lived signed URL (`uid`, `exp`, `sig`) generated at upload time.
- Downloads automatically fall back to the backup bucket if the primary object is unavailable.

## Resilience & backups
- Dual-bucket writes (primary + backup) are built in. Enable Cloudflare cross-region replication (CRR) on both buckets if you need geographic redundancy.
- Keep Firestore as source of truth; schedule Firestore exports to a separate bucket and sync to R2 if you need cold backups (see root README for commands).
- Audit metadata (`ownerUid`, `category`) is stored as R2 custom metadata to aid investigations without exposing object contents.
