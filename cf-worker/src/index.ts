export interface Env {
  FIREBASE_PROJECT_ID: string;
  FIREBASE_CLIENT_EMAIL: string;
  FIREBASE_PRIVATE_KEY: string;
  FIREBASE_API_KEY: string;
  ALLOWED_ORIGINS?: string;
  DEVICE_MAX_PER_USER?: string;
  STORAGE_UPLOAD_MAX_BYTES?: string;
  CAMGUIDE_RATE_LIMIT_WINDOW_SECONDS?: string;
  CAMGUIDE_RATE_LIMIT_MAX_REQUESTS?: string;
  SUPPORT_TICKET_RATE_LIMIT_WINDOW_SECONDS?: string;
  SUPPORT_TICKET_RATE_LIMIT_MAX_REQUESTS?: string;
  DEVICE_REGISTER_RATE_LIMIT_WINDOW_SECONDS?: string;
  DEVICE_REGISTER_RATE_LIMIT_MAX_REQUESTS?: string;
  VOTE_NONCE_RATE_LIMIT_WINDOW_SECONDS?: string;
  VOTE_NONCE_RATE_LIMIT_MAX_REQUESTS?: string;
  VOTE_CAST_RATE_LIMIT_WINDOW_SECONDS?: string;
  VOTE_CAST_RATE_LIMIT_MAX_REQUESTS?: string;
  REGISTRATION_RATE_LIMIT_WINDOW_SECONDS?: string;
  REGISTRATION_RATE_LIMIT_MAX_REQUESTS?: string;
  INCIDENT_SUBMIT_RATE_LIMIT_WINDOW_SECONDS?: string;
  INCIDENT_SUBMIT_RATE_LIMIT_MAX_REQUESTS?: string;
  AUTH_RESOLVE_RATE_LIMIT_WINDOW_SECONDS?: string;
  AUTH_RESOLVE_RATE_LIMIT_MAX_REQUESTS?: string;
  AUTH_REFRESH_RATE_LIMIT_WINDOW_SECONDS?: string;
  AUTH_REFRESH_RATE_LIMIT_MAX_REQUESTS?: string;
  TRELLO_KEY?: string;
  TRELLO_TOKEN?: string;
  TRELLO_BOARD_ID?: string;
  // Optional Trello configuration for treating certain lists as "done" (completed)
  // when computing delivery progress.
  // - TRELLO_DONE_LIST_IDS: comma-separated Trello list IDs
  // - TRELLO_DONE_LIST_NAMES: comma-separated Trello list names
  TRELLO_DONE_LIST_IDS?: string;
  TRELLO_DONE_LIST_NAMES?: string;
  TAPTAP_SEND_URL?: string;
  TAPTAP_SEND_DEEP_LINK?: string;
  REMITLY_SEND_URL?: string;
  REMITLY_SEND_DEEP_LINK?: string;
  // Orange Money Max It (QR)
  MAXIT_TIP_QR_URL?: string;
  MAXIT_TIP_DEEP_LINK?: string;
  TIP_QR_WEBHOOK_SECRET?: string;
  TIP_ORANGE_MONEY_NUMBER?: string;
  TIP_ORANGE_MONEY_NAME?: string;
  TIP_ORANGE_MONEY_NUMBER_PUBLIC?: string;
  TIP_RATE_LIMIT_WINDOW_SECONDS?: string;
  TIP_RATE_LIMIT_MAX_REQUESTS?: string;
  TIP_SUSPICIOUS_AMOUNT?: string;
  TIP_MIN_AMOUNT?: string;
  TIP_MAX_AMOUNT?: string;
  SUPPORT_EMAIL_FROM?: string;
  SUPPORT_EMAIL_REPLY_TO?: string;
  MAILCHANNELS_API_KEY?: string;
  // Optional: send support emails through Gmail API when SUPPORT_EMAIL_FROM is a Gmail address.
  // This avoids DMARC bounces that occur when trying to send "From: *@gmail.com" via 3rd parties.
  GMAIL_CLIENT_ID?: string;
  GMAIL_CLIENT_SECRET?: string;
  GMAIL_REFRESH_TOKEN?: string;
  R2_PRIMARY: R2Bucket;
  R2_BACKUP?: R2Bucket;
  STORAGE_SIGNING_SECRET: string;
}

type JsonObject = Record<string, unknown>;
type FirestoreValue =
  | { stringValue: string }
  | { integerValue: string }
  | { booleanValue: boolean }
  | { timestampValue: string }
  | { nullValue: null }
  | { mapValue: { fields: Record<string, FirestoreValue> } }
  | { arrayValue: { values: FirestoreValue[] } };

type FirestoreDoc = {
  name: string;
  fields?: Record<string, FirestoreValue>;
  updateTime?: string;
};

type StorageCategory = 'public' | 'registration_docs' | 'incident_attachments' | 'tip_receipts';
type StoragePath = { key: string; category: StorageCategory; ownerUid?: string };

const TOKEN_SCOPE = 'https://www.googleapis.com/auth/datastore';
const TOKEN_URL = 'https://oauth2.googleapis.com/token';
const MAILCHANNELS_SEND_URL = 'https://api.mailchannels.net/tx/v1/send';
const GMAIL_SEND_URL = 'https://gmail.googleapis.com/gmail/v1/users/me/messages/send';
const textEncoder = new TextEncoder();
const SIGNED_URL_TTL_SECONDS = 60 * 60 * 24 * 365; // 1 year by default

const DEVICE_DEFAULT_MAX_PER_USER = 1;
const STORAGE_DEFAULT_MAX_UPLOAD_BYTES = 10 * 1024 * 1024; // 10 MB
const STORAGE_ALLOWED_CONTENT_TYPES = new Set([
  'application/octet-stream',
  'application/pdf',
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp',
  'image/heic',
  'image/heif',
]);

const CAMGUIDE_DEFAULT_RATE_LIMIT_WINDOW_SECONDS = 60 * 60; // 1 hour
const CAMGUIDE_DEFAULT_RATE_LIMIT_MAX_REQUESTS = 40;
const SUPPORT_TICKET_DEFAULT_RATE_LIMIT_WINDOW_SECONDS = 60 * 60; // 1 hour
const SUPPORT_TICKET_DEFAULT_RATE_LIMIT_MAX_REQUESTS = 8;
const DEVICE_REGISTER_DEFAULT_RATE_LIMIT_WINDOW_SECONDS = 60 * 60; // 1 hour
const DEVICE_REGISTER_DEFAULT_RATE_LIMIT_MAX_REQUESTS = 25;
const VOTE_NONCE_DEFAULT_RATE_LIMIT_WINDOW_SECONDS = 10 * 60; // 10 minutes
const VOTE_NONCE_DEFAULT_RATE_LIMIT_MAX_REQUESTS = 15;
const VOTE_CAST_DEFAULT_RATE_LIMIT_WINDOW_SECONDS = 10 * 60; // 10 minutes
const VOTE_CAST_DEFAULT_RATE_LIMIT_MAX_REQUESTS = 8;
const REGISTRATION_DEFAULT_RATE_LIMIT_WINDOW_SECONDS = 24 * 60 * 60; // 1 day
const REGISTRATION_DEFAULT_RATE_LIMIT_MAX_REQUESTS = 3;
const INCIDENT_SUBMIT_DEFAULT_RATE_LIMIT_WINDOW_SECONDS = 60 * 60; // 1 hour
const INCIDENT_SUBMIT_DEFAULT_RATE_LIMIT_MAX_REQUESTS = 12;
const AUTH_RESOLVE_DEFAULT_RATE_LIMIT_WINDOW_SECONDS = 10 * 60; // 10 minutes
const AUTH_RESOLVE_DEFAULT_RATE_LIMIT_MAX_REQUESTS = 30;
const AUTH_REFRESH_DEFAULT_RATE_LIMIT_WINDOW_SECONDS = 10 * 60; // 10 minutes
const AUTH_REFRESH_DEFAULT_RATE_LIMIT_MAX_REQUESTS = 30;
const INCIDENT_MAX_ATTACHMENTS = 8;

let cachedAccessToken = '';
let cachedAccessTokenExp = 0;
let cachedPrivateKey: CryptoKey | null = null;
let cachedGmailAccessToken = '';
let cachedGmailAccessTokenExp = 0;

class HttpError extends Error {
  status: number;
  code?: string;

  constructor(status: number, message: string, code?: string) {
    super(message);
    this.status = status;
    this.code = code;
  }
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const origin = request.headers.get('Origin') || '*';
    const corsHeaders = buildCorsHeaders(origin, env);

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    try {
      if (request.method === 'POST' && url.pathname === '/auth/refresh') {
        return await handleAuthRefresh(request, env, corsHeaders);
      }

      if (request.method === 'GET' && url.pathname === '/v1/storage/file') {
        return await handleStorageFile(request, env, corsHeaders);
      }

      const tipStatusMatch = url.pathname.match(/^\/v1\/payments\/tips\/([^/]+)\/status$/);
      if (request.method === 'GET' && tipStatusMatch) {
        return await handleTipStatus(request, env, corsHeaders, tipStatusMatch[1]);
      }

      if (request.method === 'GET') {
        switch (url.pathname) {
          case '/v1/auth/resolve-identifier':
            return await handleAuthResolveIdentifier(request, env, corsHeaders);
          case '/v1/public/results':
            return await handlePublicResults(request, env, corsHeaders);
          case '/v1/public/electoral-stats':
            return await handlePublicElectoralStats(request, env, corsHeaders);
          case '/v1/public/elections-info':
            return await handlePublicElectionsInfo(request, env, corsHeaders);
          case '/v1/public/about-profile':
            return await handlePublicAboutProfile(request, env, corsHeaders);
          case '/v1/public/trello-stats':
            return await handlePublicTrelloStats(request, env, corsHeaders);
          case '/v1/legal/documents':
            return await handleLegalDocuments(request, env, corsHeaders);
          case '/v1/centers':
            return await handleCentersList(request, env, corsHeaders);
          case '/v1/admin/tips':
            return await handleAdminTipList(request, env, corsHeaders);
          case '/v1/voter/elections':
            return await handleVoterElections(request, env, corsHeaders);
          case '/v1/user/profile':
            return await handleUserProfile(request, env, corsHeaders);
          case '/v1/notifications':
            return await handleNotificationsList(request, env, corsHeaders);
          case '/v1/tools/fraud-insight':
            return await handleToolsFraudInsight(request, env, corsHeaders);
          case '/v1/tools/device-risks':
            return await handleToolsDeviceRisks(request, env, corsHeaders);
          case '/v1/tools/incidents':
            return await handleToolsIncidents(request, env, corsHeaders);
          case '/v1/tools/observer-incidents':
            return await handleToolsObserverIncidents(request, env, corsHeaders);
          case '/v1/tools/results-publishing':
            return await handleToolsResultsPublishing(request, env, corsHeaders);
          case '/v1/tools/transparency':
            return await handleToolsTransparency(request, env, corsHeaders);
          case '/v1/tools/observation-checklist':
            return await handleToolsObservationChecklist(request, env, corsHeaders);
          case '/v1/tools/election-calendar':
            return await handleToolsElectionCalendar(request, env, corsHeaders);
          case '/v1/tools/civic-lessons':
            return await handleToolsCivicLessons(request, env, corsHeaders);
          case '/v1/admin/elections':
            return await handleAdminListElections(request, env, corsHeaders);
          case '/v1/admin/voters':
            return await handleAdminListVoters(request, env, corsHeaders);
          case '/v1/admin/stats':
            return await handleAdminStats(request, env, corsHeaders);
          case '/v1/admin/audit-events':
            return await handleAdminAuditEvents(request, env, corsHeaders);
          case '/v1/admin/observers':
            return await handleAdminListObservers(request, env, corsHeaders);
          case '/v1/admin/content':
            return await handleAdminContentList(request, env, corsHeaders);
          case '/v1/admin/support/tickets':
            return await handleAdminSupportTickets(request, env, corsHeaders);
          case '/v1/admin/analytics/voter-demographics':
            return await handleAdminVoterDemographics(request, env, corsHeaders);
          default:
            break;
        }
      }

      if (url.pathname === '/health') {
        return jsonResponse({ ok: true }, corsHeaders);
      }

      if (request.method !== 'POST') {
        throw new HttpError(405, 'Method not allowed');
      }

      const tipNotifyMatch = url.pathname.match(/^\/v1\/payments\/tips\/([^/]+)\/notify$/);
      if (tipNotifyMatch) {
        return await handleTipNotify(request, env, corsHeaders, tipNotifyMatch[1]);
      }

      switch (url.pathname) {
        case '/v1/device/register':
          return await handleDeviceRegister(request, env, corsHeaders);
        case '/v1/vote/nonce':
        case '/v1/votes/nonce':
          return await handleVoteNonce(request, env, corsHeaders);
        case '/v1/vote/cast':
        case '/v1/votes/cast':
          return await handleVoteCast(request, env, corsHeaders);
        case '/v1/registration/submit':
          return await handleRegistrationSubmit(request, env, corsHeaders);
        case '/v1/account/delete':
          return await handleAccountDelete(request, env, corsHeaders);
        case '/v1/admin/registration/decide':
          return await handleAdminRegistrationDecide(request, env, corsHeaders);
        case '/v1/user/bootstrap':
          return await handleUserBootstrap(request, env, corsHeaders);
        case '/v1/user/profile/upsert':
          return await handleUserProfileUpsert(request, env, corsHeaders);
        case '/v1/storage/upload':
          return await handleStorageUpload(request, env, corsHeaders, url);
        case '/v1/public/results':
          return await handlePublicResults(request, env, corsHeaders);
        case '/v1/public/elections-info':
          return await handlePublicElectionsInfo(request, env, corsHeaders);
        case '/v1/public/voter-lookup':
          return await handlePublicVoterLookup(request, env, corsHeaders);
        case '/v1/public/notify-ios':
          return await handlePublicNotifyIos(request, env, corsHeaders);
        case '/v1/incidents/submit':
          return await handleIncidentSubmit(request, env, corsHeaders);
        case '/v1/admin/elections':
          return await handleAdminCreateElection(request, env, corsHeaders);
        case '/v1/admin/elections/candidate':
          return await handleAdminAddCandidate(request, env, corsHeaders);
        case '/v1/admin/centers/upsert':
          return await handleAdminCentersUpsert(request, env, corsHeaders);
        case '/v1/admin/centers/delete':
          return await handleAdminCentersDelete(request, env, corsHeaders);
        case '/v1/admin/centers/batch':
          return await handleAdminCentersBatch(request, env, corsHeaders);
        case '/v1/admin/content/seed':
          return await handleAdminContentSeed(request, env, corsHeaders);
        case '/v1/admin/content/upsert':
          return await handleAdminContentUpsert(request, env, corsHeaders);
        case '/v1/admin/content/delete':
          return await handleAdminContentDelete(request, env, corsHeaders);
        case '/v1/admin/voters':
          return await handleAdminListVoters(request, env, corsHeaders);
        case '/v1/admin/observers/assign':
          return await handleAdminObserverAssign(request, env, corsHeaders);
        case '/v1/admin/observers/create':
          return await handleAdminObserverCreate(request, env, corsHeaders);
        case '/v1/admin/observers/delete':
          return await handleAdminObserverDelete(request, env, corsHeaders);
        case '/v1/tools/results/publish':
          return await handleToolsResultsPublish(request, env, corsHeaders);
        case '/v1/tools/observation-checklist/update':
          return await handleToolsObservationChecklistUpdate(request, env, corsHeaders);
        case '/v1/support/ticket':
        case '/v1/support/tickets':
          return await handleSupportTicket(request, env, corsHeaders);
        case '/v1/camguide/chat':
          return await handleCamGuideChat(request, env, corsHeaders);
        case '/v1/notifications/mark-read':
          return await handleNotificationMarkRead(request, env, corsHeaders);
        case '/v1/notifications/mark-all-read':
          return await handleNotificationMarkAllRead(request, env, corsHeaders);
        case '/v1/admin/support/tickets/respond':
          return await handleAdminSupportTicketRespond(request, env, corsHeaders);
        case '/v1/payments/tips/create-session':
        case '/v1/payments/tips/taptap-send-intent':
          return await handleTipTapTapSendIntent(request, env, corsHeaders);
        case '/v1/payments/tips/remitly-intent':
          return await handleTipRemitlyIntent(request, env, corsHeaders);
        case '/v1/payments/tips/taptap-send/submit':
          return await handleTipTapTapSendSubmit(request, env, corsHeaders);
        case '/v1/payments/tips/maxit-qr-intent':
          return await handleTipMaxItQrIntent(request, env, corsHeaders);
        case '/v1/payments/webhooks/tip-qr':
          return await handleTipWebhookTipQr(request, env, corsHeaders);
        case '/v1/admin/tips/decide':
          return await handleAdminTipDecision(request, env, corsHeaders);
        default:
          throw new HttpError(404, 'Not found');
      }
    } catch (error) {
      const err = error as HttpError;
      const status = err.status ?? 500;
      const message = err.message || 'Unexpected error';
      return jsonResponse({ error: { message, code: err.code } }, corsHeaders, status);
    }
  },
};

// Handlers
async function handleDeviceRegister(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  const auth: RateLimitAuth = { uid };
  const windowSeconds = parseIntEnv(
    env.DEVICE_REGISTER_RATE_LIMIT_WINDOW_SECONDS,
    DEVICE_REGISTER_DEFAULT_RATE_LIMIT_WINDOW_SECONDS,
    30,
    24 * 60 * 60,
  );
  const maxRequests = parseIntEnv(
    env.DEVICE_REGISTER_RATE_LIMIT_MAX_REQUESTS,
    DEVICE_REGISTER_DEFAULT_RATE_LIMIT_MAX_REQUESTS,
    1,
    1000,
  );
  await enforceRateLimit({
    request,
    env,
    namespace: 'device_register',
    key: 'register',
    auth,
    windowSeconds,
    maxRequests,
    message: 'Too many device registration attempts. Please wait and try again.',
  });
  const body = await readJson(request);
  const deviceHash = stringField(body, 'deviceHash');
  const publicKey = stringField(body, 'publicKey');

  if (!deviceHash || !publicKey) {
    throw new HttpError(400, 'deviceHash and publicKey are required');
  }

  const now = new Date().toISOString();
  const userDoc = await firestoreGet(env, `users/${uid}`);
  if (userDoc) {
    const existingHash = docString(userDoc, 'deviceHash');
    if (existingHash && existingHash !== deviceHash) {
      await logDeviceRisk(env, {
        uid,
        deviceHash,
        type: 'DEVICE_MISMATCH',
        severity: 'high',
        note: 'Attempted to register a different device hash.',
      });
      throw new HttpError(409, 'Device does not match the registered device.');
    }
    const existingKey = docString(userDoc, 'devicePublicKey');
    if (existingKey && existingKey !== publicKey) {
      await logDeviceRisk(env, {
        uid,
        deviceHash,
        type: 'KEY_MISMATCH',
        severity: 'high',
        note: 'Attempted to register a different device key.',
      });
      throw new HttpError(409, 'Device key mismatch.');
    }
  }

  const deviceDoc = await firestoreGet(env, `device_hashes/${deviceHash}`);
  if (deviceDoc) {
    const boundUid = docString(deviceDoc, 'uid');
    if (boundUid && boundUid !== uid) {
      await logDeviceRisk(env, {
        uid,
        deviceHash,
        type: 'DEVICE_ALREADY_BOUND',
        severity: 'critical',
        note: `Device already bound to ${boundUid}.`,
      });
      throw new HttpError(409, 'Device already registered to another account.');
    }
  }
  const deviceMaxPerUser = parseIntEnv(env.DEVICE_MAX_PER_USER, DEVICE_DEFAULT_MAX_PER_USER, 1, 10);
  if (!deviceDoc) {
    const deviceDocs = await firestoreRunQuery(env, {
      from: [{ collectionId: 'device_hashes' }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'uid' },
          op: 'EQUAL',
          value: { stringValue: uid },
        },
      },
      limit: Math.min(100, deviceMaxPerUser + 1),
    });
    if (deviceDocs.length >= deviceMaxPerUser) {
      await logDeviceRisk(env, {
        uid,
        deviceHash,
        type: 'DEVICE_LIMIT_EXCEEDED',
        severity: 'high',
        note: `Device limit exceeded (max ${deviceMaxPerUser}).`,
      });
      throw new HttpError(409, 'Maximum number of devices reached for this account.');
    }
  }

  const userFields = {
    deviceHash,
    devicePublicKey: publicKey,
    deviceRegisteredAt: now,
    deviceLastSeenAt: now,
  };
  await firestorePatch(env, `users/${uid}`, userFields, Object.keys(userFields));

  if (deviceDoc) {
    await firestorePatch(
      env,
      `device_hashes/${deviceHash}`,
      { uid, publicKey, lastSeenAt: now },
      ['uid', 'publicKey', 'lastSeenAt'],
    );
  } else {
    await firestoreCreate(env, `device_hashes/${deviceHash}`, {
      uid,
      publicKey,
      createdAt: now,
      lastSeenAt: now,
    });
  }

  return jsonResponse({ ok: true }, corsHeaders);
}

async function handleVoteNonce(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  const auth: RateLimitAuth = { uid };
  const body = await readJson(request);
  const electionId = pickString(body, ['electionId', 'election_id']);
  const deviceHash = pickString(body, ['deviceHash', 'device_hash']);

  if (!electionId || !deviceHash) {
    throw new HttpError(400, 'electionId and deviceHash are required');
  }
  const windowSeconds = parseIntEnv(
    env.VOTE_NONCE_RATE_LIMIT_WINDOW_SECONDS,
    VOTE_NONCE_DEFAULT_RATE_LIMIT_WINDOW_SECONDS,
    30,
    24 * 60 * 60,
  );
  const maxRequests = parseIntEnv(
    env.VOTE_NONCE_RATE_LIMIT_MAX_REQUESTS,
    VOTE_NONCE_DEFAULT_RATE_LIMIT_MAX_REQUESTS,
    1,
    500,
  );
  await enforceRateLimit({
    request,
    env,
    namespace: 'vote_nonce',
    key: electionId.toLowerCase(),
    auth,
    windowSeconds,
    maxRequests,
    message: 'Too many nonce requests. Please wait before trying again.',
  });

  const userDoc = await requireUserDoc(env, uid);
  enforceVoterStatus(userDoc);

  const boundHash = docString(userDoc, 'deviceHash');
  const publicKey = docString(userDoc, 'devicePublicKey');
  if (!boundHash || boundHash !== deviceHash) {
    await logDeviceRisk(env, {
      uid,
      deviceHash,
      type: 'DEVICE_HASH_MISMATCH',
      severity: 'high',
      note: 'Device hash mismatch when requesting nonce.',
    });
    throw new HttpError(409, 'Device mismatch.');
  }
  if (!publicKey) {
    throw new HttpError(409, 'Device not registered.');
  }

  const electionDoc = await firestoreGet(env, `elections/${electionId}`);
  if (!electionDoc || !isElectionOpen(electionDoc)) {
    throw new HttpError(409, 'Election is not open.');
  }

  const nonceId = crypto.randomUUID();
  const nonce = crypto.randomUUID().replace(/-/g, '');
  const expiresAt = new Date(Date.now() + 3 * 60 * 1000).toISOString();

  await firestoreCreate(env, `vote_nonces/${nonceId}`, {
    uid,
    electionId,
    deviceHash,
    nonce,
    expiresAt,
    createdAt: new Date().toISOString(),
  });

  return jsonResponse({ nonceId, nonce, expiresAt }, corsHeaders);
}

async function handleVoteCast(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  const auth: RateLimitAuth = { uid };
  const body = await readJson(request);
  const electionId = pickString(body, ['electionId', 'election_id']);
  const candidateId = pickString(body, ['candidateId', 'candidate_id']);
  const deviceHash = pickString(body, ['deviceHash', 'device_hash']);
  const nonceId = pickString(body, ['nonceId', 'nonce_id']);
  const signature = pickString(body, ['signature', 'deviceSignature', 'device_signature']);
  const biometricVerified = booleanField(body, 'biometricVerified');
  const livenessVerified =
    booleanField(body, 'livenessVerified') || booleanField(body, 'livenessPassed');

  if (!electionId || !candidateId || !deviceHash || !nonceId || !signature) {
    throw new HttpError(400, 'Missing required vote fields.');
  }
  if (!biometricVerified || !livenessVerified) {
    throw new HttpError(403, 'Biometrics and liveness are required.');
  }
  const windowSeconds = parseIntEnv(
    env.VOTE_CAST_RATE_LIMIT_WINDOW_SECONDS,
    VOTE_CAST_DEFAULT_RATE_LIMIT_WINDOW_SECONDS,
    30,
    24 * 60 * 60,
  );
  const maxRequests = parseIntEnv(
    env.VOTE_CAST_RATE_LIMIT_MAX_REQUESTS,
    VOTE_CAST_DEFAULT_RATE_LIMIT_MAX_REQUESTS,
    1,
    200,
  );
  await enforceRateLimit({
    request,
    env,
    namespace: 'vote_cast',
    key: electionId.toLowerCase(),
    auth,
    windowSeconds,
    maxRequests,
    message: 'Too many vote attempts. Please wait before trying again.',
  });

  const userDoc = await requireUserDoc(env, uid);
  enforceVoterStatus(userDoc);

  const boundHash = docString(userDoc, 'deviceHash');
  const publicKey = docString(userDoc, 'devicePublicKey');
  if (!boundHash || boundHash !== deviceHash || !publicKey) {
    await logDeviceRisk(env, {
      uid,
      deviceHash,
      type: 'DEVICE_HASH_MISMATCH',
      severity: 'high',
      note: 'Device hash mismatch when casting vote.',
    });
    throw new HttpError(409, 'Device mismatch.');
  }

  const nonceDoc = await firestoreGet(env, `vote_nonces/${nonceId}`);
  if (!nonceDoc) {
    throw new HttpError(409, 'Nonce not found.');
  }
  if (docString(nonceDoc, 'uid') !== uid || docString(nonceDoc, 'electionId') !== electionId) {
    throw new HttpError(409, 'Nonce not valid for this vote.');
  }
  if (docString(nonceDoc, 'deviceHash') !== deviceHash) {
    throw new HttpError(409, 'Nonce device mismatch.');
  }
  const expiresAt = docString(nonceDoc, 'expiresAt');
  if (expiresAt && Date.parse(expiresAt) < Date.now()) {
    throw new HttpError(409, 'Nonce expired.');
  }
  const usedAt = docString(nonceDoc, 'usedAt');
  if (usedAt) {
    throw new HttpError(409, 'Nonce already used.');
  }

  const nonce = docString(nonceDoc, 'nonce') || '';
  const message = buildVoteMessage({
    nonce,
    uid,
    electionId,
    candidateId,
    deviceHash,
  });
  const isValid = await verifySignature(publicKey, message, signature);
  if (!isValid) {
    await logDeviceRisk(env, {
      uid,
      deviceHash,
      type: 'INVALID_SIGNATURE',
      severity: 'critical',
      note: 'Invalid device signature for vote.',
    });
    throw new HttpError(409, 'Invalid vote signature.');
  }

  const electionDoc = await firestoreGet(env, `elections/${electionId}`);
  if (!electionDoc || !isElectionOpen(electionDoc)) {
    throw new HttpError(409, 'Election is not open.');
  }

  const candidateDoc =
    (await firestoreGet(env, `elections/${electionId}/candidates/${candidateId}`)) ||
    (await firestoreGet(env, `candidates/${candidateId}`));
  if (!candidateDoc) {
    throw new HttpError(404, 'Candidate not found.');
  }

  const now = new Date().toISOString();
  const auditToken = await sha256Hex(`${electionId}|${candidateId}|${now}|${crypto.randomUUID()}`);
  const voteDocId = `${electionId}_${uid}`;

  try {
    await firestoreCommit(env, [
      {
        update: {
          name: docName(env, `votes/${voteDocId}`),
          fields: toFirestoreFields({
            uid,
            electionId,
            candidateId,
            deviceHash,
            nonceId,
            signature,
            auditToken,
            createdAt: now,
          }),
        },
        currentDocument: { exists: false },
      },
      {
        update: {
          name: docName(env, `vote_nonces/${nonceId}`),
          fields: toFirestoreFields({ usedAt: now }),
        },
        updateMask: { fieldPaths: ['usedAt'] },
        currentDocument: nonceDoc.updateTime ? { updateTime: nonceDoc.updateTime } : { exists: true },
      },
      {
        update: {
          name: docName(env, `users/${uid}`),
          fields: toFirestoreFields({
            hasVoted: true,
            status: 'voted',
            lastVoteAt: now,
          }),
        },
        updateMask: { fieldPaths: ['hasVoted', 'status', 'lastVoteAt'] },
        currentDocument: { exists: true },
      },
      {
        update: {
          name: docName(env, `audit_events/${crypto.randomUUID()}`),
          fields: toFirestoreFields({
            type: 'vote_cast',
            uid,
            electionId,
            candidateId,
            createdAt: now,
          }),
        },
        currentDocument: { exists: false },
      },
    ]);
  } catch (error) {
    const err = error as HttpError;
    if (err.code === 'ALREADY_EXISTS') {
      throw new HttpError(409, 'You already voted in this election.');
    }
    throw err;
  }

  let tallyAfter: number | null = null;
  try {
    await updateResults(env, electionId, candidateId);
    const resultsDoc = await firestoreGet(env, `results/${electionId}`);
    tallyAfter = resultsDoc ? docInt(resultsDoc, 'totalVotes') : null;
  } catch (error) {
    await logDeviceRisk(env, {
      uid,
      deviceHash,
      type: 'RESULTS_UPDATE_FAILED',
      severity: 'medium',
      note: (error as Error).message || 'Results update failed.',
    });
  }

  const tally =
    tallyAfter === null
      ? null
      : {
          before: Math.max(0, tallyAfter - 1),
          delta: 1,
          after: tallyAfter,
        };

  return jsonResponse({ ok: true, auditToken, tally }, corsHeaders);
}

async function handleRegistrationSubmit(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  const auth: RateLimitAuth = { uid };
  const payload = (await readJson(request)) as JsonObject;

  const dob = pickString(payload, ['dateOfBirth', 'date_of_birth', 'dob']);
  if (!dob || !isAdult(dob)) {
    throw new HttpError(403, 'Registrant must be at least 18 years old.');
  }
  const windowSeconds = parseIntEnv(
    env.REGISTRATION_RATE_LIMIT_WINDOW_SECONDS,
    REGISTRATION_DEFAULT_RATE_LIMIT_WINDOW_SECONDS,
    60,
    7 * 24 * 60 * 60,
  );
  const maxRequests = parseIntEnv(
    env.REGISTRATION_RATE_LIMIT_MAX_REQUESTS,
    REGISTRATION_DEFAULT_RATE_LIMIT_MAX_REQUESTS,
    1,
    20,
  );
  await enforceRateLimit({
    request,
    env,
    namespace: 'registration_submit',
    key: 'submit',
    auth,
    windowSeconds,
    maxRequests,
    message: 'Too many registration submissions. Please wait and try again.',
  });

  const deviceHash =
    pickString(payload, ['deviceHash', 'device_hash']) ||
    pickString(payload, ['fingerprint', 'deviceFingerprint']);

  const documentNumber = pickString(payload, [
    'documentNumber',
    'document_number',
    'documentIdNumber',
    'document_id_number',
    'nationalIdNumber',
    'national_id_number',
    'registrationNumber',
    'registration_number',
    'idNumber',
    'id_number',
  ]);
  const documentType = pickString(payload, ['documentType', 'document_type']);

  const docHash =
    documentNumber && documentType
      ? await sha256Hex(`${documentType}|${documentNumber}`.toLowerCase().trim())
      : documentNumber
        ? await sha256Hex(documentNumber.toLowerCase().trim())
        : '';

  const existingRegistration = await findExistingRegistration(env, uid);
  if (existingRegistration) {
    return jsonResponse(
      {
        ok: true,
        registrationId: existingRegistration.name.split('/').pop(),
        status: docString(existingRegistration, 'status') || 'pending',
      },
      corsHeaders,
    );
  }

  if (docHash) {
    const duplicate = await findDuplicateRegistration(env, docHash);
    if (duplicate) {
      throw new HttpError(409, 'Registration already exists for this document.');
    }

    const userDuplicate = await findDuplicateUser(env, docHash);
    if (userDuplicate) {
      throw new HttpError(409, 'Document already linked to another account.');
    }
  }

  if (deviceHash) {
    const deviceDoc = await firestoreGet(env, `device_hashes/${deviceHash}`);
    if (deviceDoc) {
      const boundUid = docString(deviceDoc, 'uid');
      if (boundUid && boundUid !== uid) {
        await logDeviceRisk(env, {
          uid,
          deviceHash,
          type: 'DEVICE_ALREADY_BOUND',
          severity: 'high',
          note: 'Registration from device already bound to another account.',
        });
      }
    }
  }

  const registrationId = crypto.randomUUID();
  const now = new Date().toISOString();

  await firestoreCreate(env, `registrations/${registrationId}`, {
    uid,
    status: 'pending',
    createdAt: now,
    deviceHash: deviceHash || null,
    documentNumberHash: docHash || null,
    payload,
  });

  await firestorePatch(
    env,
    `users/${uid}`,
    { registrationStatus: 'pending', registrationId, lastRegistrationAt: now },
    ['registrationStatus', 'registrationId', 'lastRegistrationAt'],
  );

  return jsonResponse({ ok: true, registrationId, status: 'pending' }, corsHeaders);
}

async function handleAccountDelete(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  const now = new Date().toISOString();
  await firestorePatch(
    env,
    `users/${uid}`,
    { status: 'archived', verified: false, deletedAt: now },
    ['status', 'verified', 'deletedAt'],
  );

  return jsonResponse({ ok: true }, corsHeaders);
}

async function handleAdminRegistrationDecide(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  const adminDoc = await ensureUserDoc(env, uid);
  const role = docString(adminDoc, 'role');
  if (role !== 'admin') {
    throw new HttpError(403, 'Admin role required.');
  }

  const body = await readJson(request);
  const registrationId = stringField(body, 'registrationId');
  const decision = stringField(body, 'decision'); // "approved" | "rejected"
  const reason = stringField(body, 'reason');
  const voterId = stringField(body, 'voterId') || crypto.randomUUID();

  if (!registrationId || !decision) {
    throw new HttpError(400, 'registrationId and decision are required');
  }

  const regDoc = await firestoreGet(env, `registrations/${registrationId}`);
  if (!regDoc) {
    throw new HttpError(404, 'Registration not found.');
  }
  const targetUid = docString(regDoc, 'uid');
  if (!targetUid) {
    throw new HttpError(409, 'Registration missing uid.');
  }

  const status = decision === 'approved' ? 'approved' : 'rejected';
  const now = new Date().toISOString();

  await firestorePatch(
    env,
    `registrations/${registrationId}`,
    {
      status,
      decision,
      decisionBy: uid,
      decisionAt: now,
      decisionReason: reason || null,
      voterId: status === 'approved' ? voterId : null,
    },
    ['status', 'decision', 'decisionBy', 'decisionAt', 'decisionReason', 'voterId'],
  );

  if (status === 'approved') {
    // Pull hints from payload if available
  const payload = valueToJs(
    docMapValue(regDoc, 'payload') || { mapValue: { fields: {} } },
  ) as Record<string, unknown>;
    const dob = typeof payload?.dob === 'string' ? payload.dob : (payload?.dateOfBirth as string);
    const regionCode = payload?.regionCode as string | undefined;
    const centerId = payload?.centerId as string | undefined;
    const deviceHash = payload?.deviceHash as string | undefined;
    const cardExpiry = payload?.docExpiry as string | undefined;

    await firestorePatch(
      env,
      `users/${targetUid}`,
      {
        role: 'voter',
        verified: true,
        voterId,
        status: 'eligible',
        dob: dob || null,
        regionCode: regionCode || null,
        centerId: centerId || null,
        cardExpiry: cardExpiry || null,
        documentNumberHash: docString(regDoc, 'documentNumberHash') || null,
        deviceHash: deviceHash || null,
        registeredAt: now,
        updatedAt: now,
      },
      [
        'role',
        'verified',
        'voterId',
        'status',
        'dob',
        'regionCode',
        'centerId',
        'cardExpiry',
        'documentNumberHash',
        'deviceHash',
        'registeredAt',
        'updatedAt',
      ],
    );
  }

  await firestoreCreate(env, `audit_events/${crypto.randomUUID()}`, {
    type: status === 'approved' ? 'registration_approved' : 'registration_rejected',
    registrationId,
    actorUid: uid,
    actorRole: 'admin',
    targetUid,
    reason: reason || null,
    decision,
    createdAt: now,
  });

  return jsonResponse({ ok: true, status }, corsHeaders);
}

async function handleUserBootstrap(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  const body = await readJson(request);
  const email = stringField(body, 'email');
  const fullName = stringField(body, 'fullName') || stringField(body, 'displayName');

  const doc = await ensureUserDoc(env, uid, { email, fullName });
  return jsonResponse(
    {
      ok: true,
      uid,
      role: docString(doc, 'role') || 'public',
      verified: docBool(doc, 'verified') === true,
    },
    corsHeaders,
  );
}

async function handleUserProfile(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  const doc = await ensureUserDoc(env, uid);
  const data = valueToJs({ mapValue: { fields: doc.fields ?? {} } });
  return jsonResponse({ ok: true, uid, data }, corsHeaders);
}

async function handleUserProfileUpsert(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  await ensureUserDoc(env, uid);
  const body = await readJson(request);
  const payload: Record<string, unknown> = {};

  const email = stringField(body, 'email');
  if (email && !email.includes('@')) {
    throw new HttpError(400, 'Invalid email address.');
  }
  if (email) payload.email = email;
  const fullName = stringField(body, 'fullName');
  if (fullName) payload.fullName = fullName;
  const username = stringField(body, 'username');
  if (username) payload.username = username;
  const voterId = stringField(body, 'voterId');
  if (voterId) payload.voterId = voterId;
  const dob = stringField(body, 'dob') || stringField(body, 'dateOfBirth');
  if (dob) payload.dob = dob;
  const cardExpiry = stringField(body, 'cardExpiry') || stringField(body, 'docExpiry');
  if (cardExpiry) payload.cardExpiry = cardExpiry;
  const regionCode = stringField(body, 'regionCode');
  if (regionCode) payload.regionCode = regionCode;
  const regionName = stringField(body, 'regionName');
  if (regionName) payload.regionName = regionName;
  const phone = stringField(body, 'phone');
  if (phone) payload.phone = phone;
  const preferredCenterId = stringField(body, 'preferredCenterId');
  if (preferredCenterId) payload.preferredCenterId = preferredCenterId;
  if (typeof body['mustChangePassword'] === 'boolean') {
    payload.mustChangePassword = body['mustChangePassword'] as boolean;
  }
  const passwordChangedAt = stringField(body, 'passwordChangedAt');
  if (passwordChangedAt) payload.passwordChangedAt = passwordChangedAt;

  if (Object.keys(payload).length === 0) {
    throw new HttpError(400, 'No profile fields supplied.');
  }

  const now = new Date().toISOString();
  payload.updatedAt = now;
  await firestorePatch(env, `users/${uid}`, payload, Object.keys(payload));

  const doc = await firestoreGet(env, `users/${uid}`);
  const data = doc?.fields ? valueToJs({ mapValue: { fields: doc.fields } }) : null;
  return jsonResponse({ ok: true, uid, data }, corsHeaders);
}

async function handlePublicResults(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  if (request.method !== 'GET') {
    throw new HttpError(405, 'Method not allowed');
  }
  const doc = await firestoreGet(env, 'public_content/results');
  const data = doc?.fields ? valueToJs({ mapValue: { fields: doc.fields } }) : null;
  return jsonResponse({ ok: true, data }, corsHeaders);
}

async function handlePublicElectoralStats(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  if (request.method !== 'GET') {
    throw new HttpError(405, 'Method not allowed');
  }

  const users = await firestoreRunQuery(env, {
    from: [{ collectionId: 'users' }],
    limit: 4000,
  });
  const demographics = computeVoterDemographicsFromDocs(users);

  let totalVoted = 0;
  const resultsDoc = await firestoreGet(env, 'public_content/results');
  if (resultsDoc?.fields) {
    const resultsData = valueToJs({ mapValue: { fields: resultsDoc.fields } }) as Record<
      string,
      unknown
    >;
    totalVoted = toSafeInt(resultsData.totalVotesCast);
  }
  if (totalVoted <= 0) {
    const votes = await firestoreRunQuery(env, {
      from: [{ collectionId: 'votes' }],
      limit: 6000,
    });
    totalVoted = votes.length;
  }

  return jsonResponse(
    {
      ok: true,
      totalRegistered: demographics.total,
      totalVoted,
      totalDeceased: demographics.deceased,
      total: demographics.total,
      bands: demographics.bands,
      derived: demographics.derived,
      updatedAt: new Date().toISOString(),
    },
    corsHeaders,
  );
}

async function handlePublicElectionsInfo(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  if (request.method !== 'GET') throw new HttpError(405, 'Method not allowed');
  const url = new URL(request.url);
  const locale = (url.searchParams.get('locale') || 'en').toLowerCase();
  const doc = await firestoreGet(env, 'public_content/elections_info');
  const data = doc?.fields ? valueToJs({ mapValue: { fields: doc.fields } }) : null;
  return jsonResponse({ ok: true, locale, data }, corsHeaders);
}

async function handlePublicVoterLookup(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const body = await readJson(request);
  const regNumber = stringField(body, 'regNumber') || stringField(body, 'registrationNumber');
  const dob = stringField(body, 'dob') || stringField(body, 'dateOfBirth');
  if (!regNumber || !dob) throw new HttpError(400, 'regNumber and dob are required');

  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'users' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'voterId' },
        op: 'EQUAL',
        value: { stringValue: regNumber },
      },
    },
    limit: 1,
  });

  if (docs.length === 0) {
    return jsonResponse(
      {
        ok: true,
        status: 'not_found',
        maskedName: '',
        maskedRegNumber: '',
        cardExpiry: null,
      },
      corsHeaders,
    );
  }

  const user = docs[0];
  const verified = docBool(user, 'verified') === true;
  const fullName = docString(user, 'fullName');
  return jsonResponse(
    {
      ok: true,
      status: verified ? 'eligible' : 'pending_verification',
      maskedName: maskName(fullName),
      maskedRegNumber: maskReg(regNumber),
      cardExpiry: docString(user, 'cardExpiry') || null,
    },
    corsHeaders,
  );
}

async function handlePublicNotifyIos(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const body = await readJson(request);
  const email = stringField(body, 'email').trim().toLowerCase();
  if (!isValidEmail(email)) {
    throw new HttpError(400, 'A valid email address is required.');
  }

  const id = `ios_${(await sha256Hex(email)).slice(0, 32)}`;
  const docPath = `public_waitlist/${id}`;
  const now = new Date().toISOString();
  const payload = {
    id,
    email,
    lang: stringField(body, 'lang') || 'en',
    source: stringField(body, 'source') || 'app-store',
    publicUrl: stringField(body, 'publicUrl') || null,
    userAgent: stringField(body, 'userAgent') || null,
    origin: request.headers.get('Origin') || null,
    ip: request.headers.get('CF-Connecting-IP') || null,
  };
  const existing = await firestoreGet(env, docPath);
  if (existing) {
    await firestorePatch(env, docPath, {
      ...payload,
      status: docString(existing, 'status') || 'new',
      createdAt: docString(existing, 'createdAt') || now,
      updatedAt: now,
      notifyCount: (docInt(existing, 'notifyCount') || 1) + 1,
    });
    return jsonResponse({ ok: true, status: 'already_subscribed', id }, corsHeaders, 200);
  }

  await firestoreCreate(env, docPath, {
    ...payload,
    status: 'new',
    createdAt: now,
    updatedAt: now,
    notifyCount: 1,
  });

  return jsonResponse({ ok: true, status: 'subscribed', id }, corsHeaders, 201);
}

async function handleAuthResolveIdentifier(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const url = new URL(request.url);
  const auth = await maybeAuthWithRole(request, env);
  const identifier = (
    url.searchParams.get('identifier') ||
    url.searchParams.get('id') ||
    ''
  ).trim();
  if (!identifier) {
    throw new HttpError(400, 'identifier is required');
  }
  if (identifier.length > 120) {
    throw new HttpError(400, 'identifier is too long');
  }
  const normalizedIdentifier = identifier.toLowerCase();
  const windowSeconds = parseIntEnv(
    env.AUTH_RESOLVE_RATE_LIMIT_WINDOW_SECONDS,
    AUTH_RESOLVE_DEFAULT_RATE_LIMIT_WINDOW_SECONDS,
    30,
    24 * 60 * 60,
  );
  const maxRequests = parseIntEnv(
    env.AUTH_RESOLVE_RATE_LIMIT_MAX_REQUESTS,
    AUTH_RESOLVE_DEFAULT_RATE_LIMIT_MAX_REQUESTS,
    1,
    500,
  );
  const lookupKeyHash = (await sha256Hex(`resolve_identifier|${normalizedIdentifier}`)).slice(0, 64);
  await enforceRateLimit({
    request,
    env,
    namespace: 'auth_resolve_identifier',
    key: lookupKeyHash,
    auth,
    windowSeconds,
    maxRequests,
    message: 'Too many account lookup requests. Please wait and try again.',
  });
  if (identifier.includes('@')) {
    if (!isValidEmail(normalizedIdentifier)) {
      throw new HttpError(400, 'A valid email address is required.');
    }
    return jsonResponse({ ok: true, email: normalizedIdentifier }, corsHeaders);
  }

  const voterDocs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'users' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'voterId' },
        op: 'EQUAL',
        value: { stringValue: identifier },
      },
    },
    limit: 1,
  });
  if (voterDocs.length > 0) {
    const email = docString(voterDocs[0], 'email');
    if (email) {
      return jsonResponse({ ok: true, email }, corsHeaders);
    }
  }

  const userDocs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'users' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'username' },
        op: 'EQUAL',
        value: { stringValue: identifier },
      },
    },
    limit: 1,
  });
  if (userDocs.length > 0) {
    const email = docString(userDocs[0], 'email');
    if (email) {
      return jsonResponse({ ok: true, email }, corsHeaders);
    }
  }

  throw new HttpError(404, 'Account not found.');
}

async function handleAuthRefresh(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const body = await readJson(request);
  const refreshToken = pickString(body, ['refresh_token', 'refreshToken']).trim();
  if (!refreshToken) {
    throw new HttpError(400, 'refresh_token is required.');
  }
  if (refreshToken.length > 2048) {
    throw new HttpError(400, 'refresh_token is invalid.');
  }
  const auth = await maybeAuthWithRole(request, env);
  const windowSeconds = parseIntEnv(
    env.AUTH_REFRESH_RATE_LIMIT_WINDOW_SECONDS,
    AUTH_REFRESH_DEFAULT_RATE_LIMIT_WINDOW_SECONDS,
    30,
    24 * 60 * 60,
  );
  const maxRequests = parseIntEnv(
    env.AUTH_REFRESH_RATE_LIMIT_MAX_REQUESTS,
    AUTH_REFRESH_DEFAULT_RATE_LIMIT_MAX_REQUESTS,
    1,
    500,
  );
  const refreshKeyHash = (await sha256Hex(`auth_refresh|${refreshToken}`)).slice(0, 64);
  await enforceRateLimit({
    request,
    env,
    namespace: 'auth_refresh',
    key: refreshKeyHash,
    auth,
    windowSeconds,
    maxRequests,
    message: 'Too many refresh attempts. Please wait before trying again.',
  });

  const apiKey = (env.FIREBASE_API_KEY || '').trim();
  if (!apiKey) {
    throw new HttpError(500, 'Firebase API key is not configured.');
  }

  const response = await fetch(
    `https://securetoken.googleapis.com/v1/token?key=${encodeURIComponent(apiKey)}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        refresh_token: refreshToken,
      }).toString(),
    },
  );

  if (!response.ok) {
    let errorCode = '';
    try {
      const errorBody = (await response.json()) as {
        error?: { message?: string };
      };
      errorCode = `${errorBody.error?.message ?? ''}`.trim().toUpperCase();
    } catch {
      // Ignore non-JSON error bodies.
    }

    if (
      errorCode === 'INVALID_REFRESH_TOKEN' ||
      errorCode === 'TOKEN_EXPIRED' ||
      errorCode === 'USER_DISABLED' ||
      errorCode === 'USER_NOT_FOUND'
    ) {
      throw new HttpError(401, 'Invalid refresh token.');
    }

    throw new HttpError(502, 'Unable to refresh session.');
  }

  const result = (await response.json()) as Record<string, unknown>;
  const accessToken = `${result.id_token ?? ''}`.trim();
  const newRefreshToken = `${result.refresh_token ?? ''}`.trim() || refreshToken;
  const expiresIn = Number(`${result.expires_in ?? ''}`);
  const expiresAt =
    Number.isFinite(expiresIn) && expiresIn > 0
      ? new Date(Date.now() + expiresIn * 1000).toISOString()
      : null;

  if (!accessToken) {
    throw new HttpError(502, 'Refresh response missing id_token.');
  }

  return jsonResponse(
    {
      access_token: accessToken,
      refresh_token: newRefreshToken,
      expires_at: expiresAt,
    },
    corsHeaders,
  );
}

async function handlePublicAboutProfile(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  if (request.method !== 'GET') throw new HttpError(405, 'Method not allowed');
  const doc = await firestoreGet(env, 'about/profile');
  const data = doc?.fields ? valueToJs({ mapValue: { fields: doc.fields } }) : null;
  return jsonResponse({ ok: true, data }, corsHeaders);
}

async function handlePublicTrelloStats(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  if (request.method !== 'GET') throw new HttpError(405, 'Method not allowed');
  const responseHeaders = new Headers(corsHeaders);
  responseHeaders.set('Cache-Control', 'no-store, max-age=0');
  responseHeaders.set('Pragma', 'no-cache');
  responseHeaders.set('Expires', '0');
  const key = (env.TRELLO_KEY || '').trim();
  const token = (env.TRELLO_TOKEN || '').trim();
  const boardId = (env.TRELLO_BOARD_ID || '').trim();

  if (!key || !boardId) {
    return jsonResponse(
      { ok: true, configured: false, stats: null },
      responseHeaders,
    );
  }

  try {
    const parseCsv = (raw: string | undefined): string[] => {
      if (!raw) return [];
      return raw
        .split(',')
        .map((v) => v.trim())
        .filter(Boolean);
    };

    const normalizeListName = (value: string): string => {
      return value
        .trim()
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/[^a-z0-9]+/g, ' ')
        .trim();
    };

    const isDoneListName = (value: string): boolean => {
      const normalized = normalizeListName(value);
      if (!normalized) return false;
      // Avoid obvious negations.
      if (normalized.includes('not done') || normalized.includes('pas termine')) {
        return false;
      }
      // English + French heuristics (extendable via env overrides).
      const keywords = [
        'done',
        'complete',
        'completed',
        'finish',
        'finished',
        'shipped',
        'released',
        'delivered',
        'merged',
        'termine',
        'terminee',
        'fini',
        'fait',
        'faite',
        'livre',
        'livree',
        'resolu',
        'cloture',
        'cloturee',
      ];
      for (const word of keywords) {
        if (normalized === word) return true;
        if (normalized.startsWith(`${word} `)) return true;
        if (normalized.endsWith(` ${word}`)) return true;
        if (normalized.includes(` ${word} `)) return true;
      }
      return false;
    };

    const auth = new URLSearchParams({ key });
    if (token) {
      auth.set('token', token);
    }
    const authQuery = auth.toString();
    const baseUrl = 'https://api.trello.com/1';

    const boardRes = await fetch(
      `${baseUrl}/boards/${encodeURIComponent(
        boardId,
      )}?${authQuery}&fields=name,shortUrl,dateLastActivity`,
    );
    if (!boardRes.ok) {
      throw new HttpError(502, 'Unable to reach Trello board.');
    }
    const board = (await boardRes.json()) as Record<string, unknown>;

    const listsRes = await fetch(
      `${baseUrl}/boards/${encodeURIComponent(
        boardId,
      )}/lists?${authQuery}&fields=id,name,closed`,
    );
    if (!listsRes.ok) {
      throw new HttpError(502, 'Unable to load Trello lists.');
    }
    const listsRaw = (await listsRes.json()) as Array<Record<string, unknown>>;
    const activeLists = listsRaw.filter((l) => l.closed !== true);

    const cardsRes = await fetch(
      `${baseUrl}/boards/${encodeURIComponent(
        boardId,
      )}/cards?${authQuery}&fields=idList,closed&filter=all`,
    );
    if (!cardsRes.ok) {
      throw new HttpError(502, 'Unable to load Trello cards.');
    }
    const cards = (await cardsRes.json()) as Array<Record<string, unknown>>;

    const doneListIds = new Set<string>();
    const doneListIdOverrides = parseCsv(env.TRELLO_DONE_LIST_IDS);
    const doneListNameOverrides = parseCsv(env.TRELLO_DONE_LIST_NAMES);
    if (doneListIdOverrides.length > 0) {
      for (const id of doneListIdOverrides) {
        doneListIds.add(id);
      }
    } else if (doneListNameOverrides.length > 0) {
      const wantedNames = new Set(doneListNameOverrides.map(normalizeListName));
      for (const list of activeLists) {
        const listId = `${list.id ?? ''}`.trim();
        if (!listId) continue;
        const listName = `${list.name ?? ''}`;
        if (wantedNames.has(normalizeListName(listName))) {
          doneListIds.add(listId);
        }
      }
    } else {
      for (const list of activeLists) {
        const listId = `${list.id ?? ''}`.trim();
        if (!listId) continue;
        const listName = `${list.name ?? ''}`;
        if (isDoneListName(listName)) {
          doneListIds.add(listId);
        }
      }
    }

    let totalCards = 0;
    let openCards = 0;
    let doneCards = 0;
    const lists = activeLists
      .map((list) => {
        const listId = `${list.id ?? ''}`;
        const listName = `${list.name ?? 'List'}`.trim() || 'List';
        const isDone = doneListIds.has(listId);
        const listCards = cards.filter((c) => `${c.idList ?? ''}` === listId);
        const total = listCards.length;
        const done = isDone
          ? total
          : listCards.filter((c) => c.closed === true).length;
        const open = Math.max(total - done, 0);
        totalCards += total;
        openCards += open;
        doneCards += done;
        return {
          name: listName,
          totalCards: total,
          openCards: open,
        };
      })
      .sort((a, b) => b.totalCards - a.totalCards);

    return jsonResponse(
      {
        ok: true,
        configured: true,
        stats: {
          boardName: `${board.name ?? 'Trello board'}`.trim() || 'Trello board',
          boardUrl: `${board.shortUrl ?? ''}`.trim(),
          lastActivityAt: `${board.dateLastActivity ?? ''}`.trim() || null,
          totalCards,
          openCards,
          doneCards: Math.max(doneCards, 0),
          lists,
        },
      },
      responseHeaders,
    );
  } catch (error) {
    const message = (error as Error).message || 'Trello unavailable.';
    throw new HttpError(502, message);
  }
}

async function handleLegalDocuments(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  if (request.method !== 'GET') throw new HttpError(405, 'Method not allowed');
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'legal_documents' }],
    orderBy: [{ field: { fieldPath: 'order' }, direction: 'ASCENDING' }],
    limit: 200,
  });
  const documents = docs.map((doc) => ({
    id: doc.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
  }));
  return jsonResponse({ ok: true, documents }, corsHeaders);
}

async function handleCentersList(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  if (request.method !== 'GET') throw new HttpError(405, 'Method not allowed');
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'centers' }],
    orderBy: [{ field: { fieldPath: 'name' }, direction: 'ASCENDING' }],
    limit: 500,
  });
  const centers = docs.map((doc) => ({
    id: doc.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
  }));
  return jsonResponse({ ok: true, centers }, corsHeaders);
}

async function handleVoterElections(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { role } = await requireAuthWithRole(request, env);
  if (role !== 'voter' && role !== 'observer' && role !== 'admin') {
    throw new HttpError(403, 'Voter role required.');
  }
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'elections' }],
    orderBy: [{ field: { fieldPath: 'startAt' }, direction: 'DESCENDING' }],
    limit: 100,
  });
  const elections = await Promise.all(
    docs.map(async (doc) => {
      const id = doc.name.split('/').pop() || '';
      const candidates = await firestoreRunQuery(
        env,
        { from: [{ collectionId: 'candidates' }] },
        doc.name,
      );
      return {
        id,
        data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
        candidates: candidates.map((c) => ({
          id: c.name.split('/').pop(),
          data: valueToJs({ mapValue: { fields: c.fields ?? {} } }),
        })),
      };
    }),
  );
  return jsonResponse({ ok: true, elections }, corsHeaders);
}

async function handleAdminListElections(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'elections' }],
    orderBy: [{ field: { fieldPath: 'startAt' }, direction: 'DESCENDING' }],
    limit: 100,
  });
  const elections = await Promise.all(
    docs.map(async (doc) => {
      const id = doc.name.split('/').pop() || '';
      const candidates = await firestoreRunQuery(
        env,
        {
          from: [{ collectionId: 'candidates' }],
        },
        doc.name,
      );
      return {
        id,
        data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
        candidates: candidates.map((c) => ({
          id: c.name.split('/').pop(),
          data: valueToJs({ mapValue: { fields: c.fields ?? {} } }),
        })),
      };
    }),
  );
  return jsonResponse({ ok: true, elections }, corsHeaders);
}

async function handleAdminCreateElection(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAdmin(request, env);
  const body = await readJson(request);
  const title = sanitizePlainText(stringField(body, 'title'), 160);
  if (!title) {
    throw new HttpError(400, 'title is required');
  }
  const startAt = stringField(body, 'startAt').trim();
  const endAt = stringField(body, 'endAt').trim();
  if (!startAt || !endAt) {
    throw new HttpError(400, 'startAt and endAt are required');
  }
  const startTs = Date.parse(startAt);
  const endTs = Date.parse(endAt);
  if (Number.isNaN(startTs) || Number.isNaN(endTs)) {
    throw new HttpError(400, 'startAt and endAt must be valid ISO dates');
  }
  if (endTs <= startTs) {
    throw new HttpError(400, 'endAt must be after startAt');
  }
  const registrationDeadline = stringField(body, 'registrationDeadline').trim();
  if (registrationDeadline) {
    const deadlineTs = Date.parse(registrationDeadline);
    if (Number.isNaN(deadlineTs)) {
      throw new HttpError(400, 'registrationDeadline must be a valid ISO date');
    }
    if (deadlineTs > startTs) {
      throw new HttpError(400, 'registrationDeadline must be on or before startAt');
    }
  }
  const statusRaw = stringField(body, 'status').trim().toLowerCase();
  const status = statusRaw || 'draft';
  if (!['draft', 'scheduled', 'open', 'closed', 'archived'].includes(status)) {
    throw new HttpError(400, 'status must be one of draft, scheduled, open, closed, archived');
  }
  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const payload: Record<string, unknown> = {
    title,
    type: sanitizePlainText(stringField(body, 'type'), 80).toLowerCase() || 'presidential',
    startAt,
    endAt,
    status,
    registrationDeadline: registrationDeadline || null,
    description: sanitizePlainText(stringField(body, 'description'), 4000),
    scope: sanitizePlainText(stringField(body, 'scope'), 120),
    location: sanitizePlainText(stringField(body, 'location'), 160),
    timezone: sanitizePlainText(stringField(body, 'timezone'), 60),
    ballotType: sanitizePlainText(stringField(body, 'ballotType'), 60),
    eligibility: sanitizePlainText(stringField(body, 'eligibility'), 500),
    createdAt: now,
    createdBy: uid,
    updatedAt: now,
  };
  await firestoreCreate(env, `elections/${id}`, payload);
  return jsonResponse(
    { ok: true, id, election: payload },
    corsHeaders,
    201,
  );
}

async function handleAdminAddCandidate(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const electionId = pickString(body, ['electionId', 'election_id']);
  const candidateId = stringField(body, 'id') || crypto.randomUUID();
  if (!electionId) throw new HttpError(400, 'electionId is required');
  const payload: Record<string, unknown> = {
    id: candidateId,
    fullName: stringField(body, 'fullName'),
    partyName: stringField(body, 'partyName'),
    partyAcronym: stringField(body, 'partyAcronym'),
    partyColor: stringField(body, 'partyColor'),
    slogan: stringField(body, 'slogan'),
    bio: stringField(body, 'bio'),
    campaignUrl: stringField(body, 'campaignUrl'),
    avatarUrl: stringField(body, 'avatarUrl'),
    runningMate: stringField(body, 'runningMate'),
    updatedAt: new Date().toISOString(),
  };
  await firestoreCreate(env, `elections/${electionId}/candidates/${candidateId}`, payload);
  return jsonResponse({ ok: true, id: candidateId }, corsHeaders, 201);
}

async function handleAdminListVoters(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const url = new URL(request.url);
  const region = url.searchParams.get('region');
  const status = url.searchParams.get('status');
  const filters: JsonObject[] = [
    {
      fieldFilter: {
        field: { fieldPath: 'role' },
        op: 'EQUAL',
        value: { stringValue: 'voter' },
      },
    },
  ];

  if (region) {
    filters.push({
      fieldFilter: {
        field: { fieldPath: 'regionCode' },
        op: 'EQUAL',
        value: { stringValue: region },
      },
    });
  }
  if (status) {
    filters.push({
      fieldFilter: {
        field: { fieldPath: 'status' },
        op: 'EQUAL',
        value: { stringValue: status },
      },
    });
  }

  const query: JsonObject = {
    from: [{ collectionId: 'users' }],
    limit: 100,
    orderBy: [{ field: { fieldPath: 'createdAt' }, direction: 'DESCENDING' }],
    where:
      filters.length === 1
        ? filters[0]
        : {
            compositeFilter: {
              op: 'AND',
              filters,
            },
          },
  };
  const docs = await firestoreRunQuery(env, query);
  const voters = docs.map((d) => ({
    id: d.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: d.fields ?? {} } }),
  }));
  return jsonResponse({ ok: true, voters }, corsHeaders);
}

async function handleAdminListObservers(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const url = new URL(request.url);
  const q = (url.searchParams.get('q') || '').toLowerCase().trim();
  const query: JsonObject = {
    from: [{ collectionId: 'users' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'role' },
        op: 'EQUAL',
        value: { stringValue: 'observer' },
      },
    },
    limit: 200,
    orderBy: [{ field: { fieldPath: 'createdAt' }, direction: 'DESCENDING' }],
  };
  const docs = await firestoreRunQuery(env, query);
  let observers = docs.map((d) => ({
    id: d.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: d.fields ?? {} } }),
  }));
  if (q) {
    observers = observers.filter((o) => {
      const data = (o.data ?? {}) as Record<string, unknown>;
      const name = `${data.fullName ?? ''}`.toLowerCase();
      const email = `${data.email ?? ''}`.toLowerCase();
      const uid = `${data.uid ?? o.id ?? ''}`.toLowerCase();
      return name.includes(q) || email.includes(q) || uid.includes(q);
    });
  }
  return jsonResponse({ ok: true, observers }, corsHeaders);
}

async function handleAdminObserverAssign(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid: adminUid } = await requireAdmin(request, env);
  const body = await readJson(request);
  const identifier = stringField(body, 'identifier');
  const role = (stringField(body, 'role') || 'observer').toLowerCase();

  if (!identifier) {
    throw new HttpError(400, 'identifier is required');
  }
  if (!['observer', 'public'].includes(role)) {
    throw new HttpError(400, 'role must be observer or public');
  }

  const userDoc = await findUserByIdentifier(env, identifier);
  if (!userDoc) {
    throw new HttpError(404, 'User not found. Ask the user to sign in once.');
  }
  const targetUid = docString(userDoc, 'uid') || userDoc.name.split('/').pop();
  if (!targetUid) {
    throw new HttpError(409, 'User record missing uid.');
  }

  const currentRole = (docString(userDoc, 'role') || 'public').toLowerCase();
  if (currentRole === 'admin' && role !== 'admin') {
    throw new HttpError(403, 'Cannot change role for an admin user.');
  }

  const now = new Date().toISOString();
  await firestorePatch(
    env,
    `users/${targetUid}`,
    {
      role,
      updatedAt: now,
      roleUpdatedAt: now,
    },
    ['role', 'updatedAt', 'roleUpdatedAt'],
  );

  await firestoreCreate(env, `audit_events/${crypto.randomUUID()}`, {
    type: 'role_changed',
    actorUid: adminUid,
    actorRole: 'admin',
    targetUid,
    previousRole: currentRole,
    targetRole: role,
    createdAt: now,
    message: `Role changed to ${role} for ${targetUid}`,
  });

  const updated = await firestoreGet(env, `users/${targetUid}`);
  return jsonResponse(
    {
      ok: true,
      uid: targetUid,
      role,
      user: valueToJs({ mapValue: { fields: updated?.fields ?? {} } }),
    },
    corsHeaders,
  );
}

async function handleAdminObserverCreate(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid: adminUid } = await requireAdmin(request, env);
  const body = await readJson(request);
  const email = stringField(body, 'email').trim().toLowerCase();
  const password = stringField(body, 'password');
  const fullName = stringField(body, 'fullName').trim();
  const username = stringField(body, 'username').trim();

  if (!isValidEmail(email)) {
    throw new HttpError(400, 'A valid email is required.');
  }
  if (password.length < 8) {
    throw new HttpError(400, 'Temporary password must be at least 8 characters.');
  }

  let targetUid = '';
  let createdInAuth = false;
  try {
    const account = await firebaseCreateUserAccount(env, email, password);
    targetUid = account.localId;
    createdInAuth = true;
  } catch (error) {
    const err = error as HttpError;
    if (err.code !== 'EMAIL_EXISTS') {
      throw err;
    }
    const existing = await findUserByIdentifier(env, email);
    if (!existing) {
      throw new HttpError(
        409,
        'Email already exists in Firebase Auth but has no linked profile. Ask the user to sign in once.',
      );
    }
    targetUid = docString(existing, 'uid') || existing.name.split('/').pop() || '';
  }

  if (!targetUid) {
    throw new HttpError(500, 'Failed to create observer account.');
  }

  const now = new Date().toISOString();
  const existingUserDoc = await firestoreGet(env, `users/${targetUid}`);
  const payload: JsonObject = {
    uid: targetUid,
    email,
    fullName,
    role: 'observer',
    status: 'observer',
    verified: true,
    mustChangePassword: true,
    observerCreatedBy: adminUid,
    observerCreatedAt: now,
    observerTemporaryPasswordIssuedAt: now,
    updatedAt: now,
  };
  if (username) {
    payload.username = username;
  }

  if (existingUserDoc) {
    await firestorePatch(env, `users/${targetUid}`, payload, Object.keys(payload));
  } else {
    await firestoreCreate(env, `users/${targetUid}`, {
      ...payload,
      createdAt: now,
    });
  }

  await firestoreCreate(env, `audit_events/${crypto.randomUUID()}`, {
    type: 'observer_created',
    actorUid: adminUid,
    actorRole: 'admin',
    targetUid,
    targetRole: 'observer',
    createdAt: now,
    message: `Observer account provisioned for ${email}`,
  });

  const fresh = await firestoreGet(env, `users/${targetUid}`);
  return jsonResponse(
    {
      ok: true,
      uid: targetUid,
      createdInAuth,
      user: valueToJs({ mapValue: { fields: fresh?.fields ?? {} } }),
    },
    corsHeaders,
    existingUserDoc ? 200 : 201,
  );
}

async function handleAdminObserverDelete(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid: adminUid } = await requireAdmin(request, env);
  const body = await readJson(request);
  const identifier = stringField(body, 'identifier');
  if (!identifier) {
    throw new HttpError(400, 'identifier is required');
  }

  const userDoc = await findUserByIdentifier(env, identifier);
  if (!userDoc) {
    throw new HttpError(404, 'Observer not found.');
  }
  const targetUid = docString(userDoc, 'uid') || userDoc.name.split('/').pop();
  if (!targetUid) {
    throw new HttpError(409, 'User record missing uid.');
  }
  const currentRole = (docString(userDoc, 'role') || 'public').toLowerCase();
  if (currentRole === 'admin') {
    throw new HttpError(403, 'Cannot delete an admin account.');
  }

  const now = new Date().toISOString();
  await firestorePatch(
    env,
    `users/${targetUid}`,
    {
      role: 'public',
      status: 'archived',
      deletedAt: now,
      mustChangePassword: false,
      updatedAt: now,
    },
    ['role', 'status', 'deletedAt', 'mustChangePassword', 'updatedAt'],
  );

  await firestoreCreate(env, `audit_events/${crypto.randomUUID()}`, {
    type: 'observer_deleted',
    actorUid: adminUid,
    actorRole: 'admin',
    targetUid,
    previousRole: currentRole,
    targetRole: 'public',
    createdAt: now,
    message: `Observer archived: ${targetUid}`,
  });

  return jsonResponse({ ok: true, uid: targetUid }, corsHeaders);
}

async function handleAdminStats(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const verifiedVoters = await firestoreRunQuery(env, {
    from: [{ collectionId: 'users' }],
    where: {
      compositeFilter: {
        op: 'AND',
        filters: [
          {
            fieldFilter: {
              field: { fieldPath: 'verified' },
              op: 'EQUAL',
              value: { booleanValue: true },
            },
          },
          {
            fieldFilter: {
              field: { fieldPath: 'role' },
              op: 'EQUAL',
              value: { stringValue: 'voter' },
            },
          },
        ],
      },
    },
  });
  const adminUsers = await firestoreRunQuery(env, {
    from: [{ collectionId: 'users' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'role' },
        op: 'EQUAL',
        value: { stringValue: 'admin' },
      },
    },
  });
  const observerUsers = await firestoreRunQuery(env, {
    from: [{ collectionId: 'users' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'role' },
        op: 'EQUAL',
        value: { stringValue: 'observer' },
      },
    },
  });
  const votes = await firestoreRunQuery(env, {
    from: [{ collectionId: 'votes' }],
  });
  const deviceFlags = await firestoreRunQuery(env, {
    from: [{ collectionId: 'device_risks' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'status' },
        op: 'EQUAL',
        value: { stringValue: 'flagged' },
      },
    },
  });
  const elections = await firestoreRunQuery(env, {
    from: [{ collectionId: 'elections' }],
  });
  const now = Date.now();
  let active = 0;
  for (const doc of elections) {
    const endAt = docString(doc, 'endAt') || docString(doc, 'closesAt');
    if (!endAt || Date.parse(endAt) > now) {
      active += 1;
    }
  }
  return jsonResponse(
    {
      ok: true,
      totalRegistered: verifiedVoters.length,
      totalRegisteredVoters: verifiedVoters.length,
      totalVoted: votes.length,
      suspiciousFlags: deviceFlags.length,
      activeElections: active,
      adminCount: adminUsers.length,
      observerCount: observerUsers.length,
      staffTotal: adminUsers.length + observerUsers.length,
    },
    corsHeaders,
  );
}

async function handleAdminVoterDemographics(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);

  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'users' }],
    limit: 2000,
  });
  const demographics = computeVoterDemographicsFromDocs(docs);

  return jsonResponse(
    {
      ok: true,
      total: demographics.total,
      bands: demographics.bands,
      derived: demographics.derived,
    },
    corsHeaders,
  );
}

async function handleAdminAuditEvents(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const url = new URL(request.url);
  const type = url.searchParams.get('type');
  const query: JsonObject = {
    from: [{ collectionId: 'audit_events' }],
    orderBy: [{ field: { fieldPath: 'createdAt' }, direction: 'DESCENDING' }],
    limit: 200,
  };
  if (type) {
    query.where = {
      fieldFilter: {
        field: { fieldPath: 'type' },
        op: 'EQUAL',
        value: { stringValue: type },
      },
    };
  }
  const docs = await firestoreRunQuery(env, query);
  const events = docs.map((d) => ({
    id: d.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: d.fields ?? {} } }),
  }));
  return jsonResponse({ ok: true, events }, corsHeaders);
}

async function handleAdminCentersUpsert(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = stringField(body, 'id');
  const now = new Date().toISOString();
  const name = stringField(body, 'name').trim();
  const address = stringField(body, 'address').trim();
  const payload = buildCenterPayload(body, now);

  if (!name || !address) {
    throw new HttpError(400, 'name and address are required');
  }

  if (id) {
    await firestorePatch(env, `centers/${id}`, payload, Object.keys(payload));
    return jsonResponse({ ok: true, id }, corsHeaders);
  }

  const newId = crypto.randomUUID();
  await firestoreCreate(env, `centers/${newId}`, { ...payload, createdAt: now });
  return jsonResponse({ ok: true, id: newId }, corsHeaders, 201);
}

async function handleAdminCentersDelete(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const id = stringField(body, 'id');
  if (!id) {
    throw new HttpError(400, 'id is required');
  }
  await firestoreCommit(env, [{ delete: docName(env, `centers/${id}`) }]);
  return jsonResponse({ ok: true }, corsHeaders);
}

async function handleAdminCentersBatch(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const centers = objectArrayField(body, 'centers');
  const now = new Date().toISOString();
  let count = 0;

  for (const center of centers) {
    const id = stringField(center, 'id');
    const name = stringField(center, 'name').trim();
    const address = stringField(center, 'address').trim();
    if (!name || !address) continue;
    const payload = buildCenterPayload(center, now);
    if (id) {
      await firestorePatch(env, `centers/${id}`, payload, Object.keys(payload));
      count += 1;
      continue;
    }
    const newId = crypto.randomUUID();
    await firestoreCreate(env, `centers/${newId}`, { ...payload, createdAt: now });
    count += 1;
  }

  return jsonResponse({ ok: true, count }, corsHeaders);
}

async function handleAdminContentSeed(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const overwrite = booleanField(body, 'overwrite');
  const purgeBeforeSeed = booleanField(body, 'purgeBeforeSeed');
  const includeCenters = booleanField(body, 'includeCenters');
  const now = new Date().toISOString();

  const civicLessons = objectArrayField(body, 'civicLessons');
  const electionCalendar = objectArrayField(body, 'electionCalendar');
  const transparencyUpdates = objectArrayField(body, 'transparencyUpdates');
  const observationChecklist = objectArrayField(body, 'observationChecklist');
  const legalDocuments = objectArrayField(body, 'legalDocuments');
  const votingCenters = includeCenters ? objectArrayField(body, 'votingCenters') : [];
  const electionsInfo = body['electionsInfo'];
  const electionsInfoDoc =
    typeof electionsInfo === 'object' && electionsInfo !== null && !Array.isArray(electionsInfo)
      ? (electionsInfo as JsonObject)
      : null;

  let purged = 0;
  if (purgeBeforeSeed) {
    purged += await purgeCollection(env, 'civic_lessons');
    purged += await purgeCollection(env, 'election_calendar');
    purged += await purgeCollection(env, 'transparency_updates');
    purged += await purgeCollection(env, 'observation_checklist');
    purged += await purgeCollection(env, 'legal_documents');
    purged += await purgeCollection(env, 'public_content');
    if (includeCenters) {
      purged += await purgeCollection(env, 'centers');
    }
  }

  const civicCount = await seedCollection(
    env,
    'civic_lessons',
    civicLessons,
    overwrite,
    now,
  );
  const calendarCount = await seedCollection(
    env,
    'election_calendar',
    electionCalendar,
    overwrite,
    now,
  );
  const transparencyCount = await seedCollection(
    env,
    'transparency_updates',
    transparencyUpdates,
    overwrite,
    now,
  );
  const checklistCount = await seedCollection(
    env,
    'observation_checklist',
    observationChecklist,
    overwrite,
    now,
  );
  const legalDocsCount = await seedCollection(
    env,
    'legal_documents',
    legalDocuments,
    overwrite,
    now,
  );
  const centersCount = includeCenters
    ? await seedCollection(env, 'centers', votingCenters, overwrite, now)
    : 0;
  const electionsInfoSet = electionsInfoDoc
    ? await seedDocument(env, 'public_content', 'elections_info', electionsInfoDoc, overwrite, now)
    : false;

  return jsonResponse(
    {
      ok: true,
      civicLessons: civicCount,
      electionCalendar: calendarCount,
      transparencyUpdates: transparencyCount,
      observationChecklist: checklistCount,
      votingCenters: centersCount,
      legalDocuments: legalDocsCount,
      electionsInfo: electionsInfoSet,
      purged,
    },
    corsHeaders,
  );
}

const ADMIN_CONTENT_COLLECTIONS = new Set([
  'civic_lessons',
  'election_calendar',
  'transparency_updates',
  'observation_checklist',
  'legal_documents',
  'centers',
  'public_content',
]);

function ensureAdminContentCollection(value: string): string {
  const collection = value.trim();
  if (!ADMIN_CONTENT_COLLECTIONS.has(collection)) {
    throw new HttpError(400, 'Unsupported content collection.');
  }
  return collection;
}

async function handleAdminContentList(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const url = new URL(request.url);
  const collection = ensureAdminContentCollection(
    url.searchParams.get('collection') || '',
  );
  const locale = (url.searchParams.get('locale') || '').trim().toLowerCase();

  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: collection }],
    limit: 300,
  });

  let items = docs.map((doc) => ({
    id: doc.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
  }));

  if (locale) {
    items = items.filter((item) => {
      const data = (item.data ?? {}) as Record<string, unknown>;
      const itemLocale = `${data.locale ?? ''}`.trim().toLowerCase();
      return itemLocale === locale;
    });
  }

  return jsonResponse({ ok: true, collection, items }, corsHeaders);
}

async function handleAdminContentUpsert(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const collection = ensureAdminContentCollection(stringField(body, 'collection'));
  const bodyData =
    typeof body.data === 'object' && body.data !== null && !Array.isArray(body.data)
      ? (body.data as JsonObject)
      : null;
  const id = (stringField(body, 'id') || stringField(bodyData ?? {}, 'id')).trim();
  if (!id) {
    throw new HttpError(400, 'id is required');
  }
  if (!bodyData) {
    throw new HttpError(400, 'data map is required');
  }

  const now = new Date().toISOString();
  const path = `${collection}/${id}`;
  const existing = await firestoreGet(env, path);
  const payload: JsonObject = { ...bodyData, updatedAt: now };
  delete (payload as Record<string, unknown>).id;

  if (existing) {
    await firestorePatch(env, path, payload, Object.keys(payload));
  } else {
    await firestoreCreate(env, path, { ...payload, createdAt: now });
  }

  const fresh = await firestoreGet(env, path);
  return jsonResponse(
    {
      ok: true,
      collection,
      id,
      created: !existing,
      item: valueToJs({ mapValue: { fields: fresh?.fields ?? {} } }),
    },
    corsHeaders,
    existing ? 200 : 201,
  );
}

async function handleAdminContentDelete(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const collection = ensureAdminContentCollection(stringField(body, 'collection'));
  const id = stringField(body, 'id').trim();
  if (!id) {
    throw new HttpError(400, 'id is required');
  }
  await firestoreCommit(env, [{ delete: docName(env, `${collection}/${id}`) }]);
  return jsonResponse({ ok: true, collection, id }, corsHeaders);
}

async function handleToolsFraudInsight(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const doc = await firestoreGet(env, 'fraud_insights/latest');
  const data = doc?.fields ? valueToJs({ mapValue: { fields: doc.fields } }) : null;
  return jsonResponse({ ok: true, data }, corsHeaders);
}

async function handleToolsDeviceRisks(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'device_risks' }],
    orderBy: [{ field: { fieldPath: 'createdAt' }, direction: 'DESCENDING' }],
    limit: 200,
  });
  const risks = docs.map((doc) => ({
    id: doc.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
  }));
  return jsonResponse({ ok: true, risks }, corsHeaders);
}

async function handleToolsIncidents(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  try {
    const url = new URL(request.url);
    const status = (url.searchParams.get('status') || '').trim();
    const query: JsonObject = {
      from: [{ collectionId: 'incidents' }],
      limit: 200,
    };
    if (status) {
      query.where = {
        fieldFilter: {
          field: { fieldPath: 'status' },
          op: 'EQUAL',
          value: { stringValue: status },
        },
      };
    }
    const docs = await firestoreRunQuery(env, query);
    const incidents = docs
      .map((doc) => ({
        id: doc.name.split('/').pop(),
        data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
      }))
      .sort((a, b) => {
        const aDate = parseDateValue((a.data as Record<string, unknown>)['createdAt'] ?? '');
        const bDate = parseDateValue((b.data as Record<string, unknown>)['createdAt'] ?? '');
        return (bDate ?? 0) - (aDate ?? 0);
      });
    return jsonResponse({ ok: true, incidents }, corsHeaders);
  } catch (error) {
    const message = (error as Error).message || 'Failed to load incidents.';
    throw new HttpError(500, message);
  }
}

async function handleToolsObserverIncidents(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid, role } = await requireAuthWithRole(request, env);
  if (role !== 'observer' && role !== 'admin') {
    throw new HttpError(403, 'Observer role required.');
  }
  try {
    const url = new URL(request.url);
    const status = (url.searchParams.get('status') || '').trim();
    const filters: JsonObject[] = [
      {
        fieldFilter: {
          field: { fieldPath: 'reportedBy' },
          op: 'EQUAL',
          value: { stringValue: uid },
        },
      },
    ];
    if (status) {
      filters.push({
        fieldFilter: {
          field: { fieldPath: 'status' },
          op: 'EQUAL',
          value: { stringValue: status },
        },
      });
    }
    const query: JsonObject = {
      from: [{ collectionId: 'incidents' }],
      limit: 200,
      where:
        filters.length === 1
          ? filters[0]
          : { compositeFilter: { op: 'AND', filters } },
    };
    const docs = await firestoreRunQuery(env, query);
    const incidents = docs
      .map((doc) => ({
        id: doc.name.split('/').pop(),
        data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
      }))
      .sort((a, b) => {
        const aDate = parseDateValue((a.data as Record<string, unknown>)['createdAt'] ?? '');
        const bDate = parseDateValue((b.data as Record<string, unknown>)['createdAt'] ?? '');
        return (bDate ?? 0) - (aDate ?? 0);
      });
    return jsonResponse({ ok: true, incidents }, corsHeaders);
  } catch (error) {
    const message = (error as Error).message || 'Failed to load incidents.';
    throw new HttpError(500, message);
  }
}

async function handleToolsResultsPublishing(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'elections' }],
    orderBy: [{ field: { fieldPath: 'endAt' }, direction: 'DESCENDING' }],
    limit: 100,
  });
  const now = Date.now();
  const results = [];

  for (const doc of docs) {
    const id = doc.name.split('/').pop() || '';
    const data = (valueToJs({ mapValue: { fields: doc.fields ?? {} } }) || {}) as Record<
      string,
      unknown
    >;
    const endValue = data['endAt'] ?? data['closesAt'];
    const endAt = parseDateValue(endValue);
    const resultDoc = await firestoreGet(env, `results/${id}`);
    const counts = resultDoc ? docMap(resultDoc, 'counts') : {};
    const totalVotes = Object.values(counts).reduce((sum, value) => sum + Number(value || 0), 0);
    const lastPublishedAt =
      (resultDoc && (docString(resultDoc, 'publishedAt') || docString(resultDoc, 'lastPublishedAt'))) ||
      '';
    results.push({
      electionId: id,
      electionTitle: (data['title'] as string) || '',
      readyToPublish: endAt !== null && endAt < now,
      totalVotes,
      precinctsReporting: resultDoc ? docInt(resultDoc, 'precinctsReporting') ?? 0 : 0,
      lastPublishedAt: lastPublishedAt || null,
    });
  }

  return jsonResponse({ ok: true, results }, corsHeaders);
}

async function handleToolsResultsPublish(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const body = await readJson(request);
  const electionId = pickString(body, ['electionId', 'id']);
  if (!electionId) {
    throw new HttpError(400, 'electionId is required');
  }
  const now = new Date().toISOString();
  await firestorePatch(
    env,
    `results/${electionId}`,
    { published: true, publishedAt: now, updatedAt: now },
    ['published', 'publishedAt', 'updatedAt'],
  );
  return jsonResponse({ ok: true }, corsHeaders);
}

async function handleToolsTransparency(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const url = new URL(request.url);
  const locale = (url.searchParams.get('locale') || '').toLowerCase();
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'transparency_updates' }],
    orderBy: [{ field: { fieldPath: 'publishedAt' }, direction: 'DESCENDING' }],
    limit: 200,
  });
  const updatesRaw = docs.map((doc) => ({
    id: doc.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
  }));
  const filtered =
    locale
      ? updatesRaw.filter((u) => {
          const data = u.data as Record<string, unknown>;
          return (data['locale'] as string | undefined)?.toLowerCase() === locale;
        })
      : updatesRaw;
  const updates = filtered.length > 0 ? filtered : updatesRaw;
  return jsonResponse({ ok: true, updates }, corsHeaders);
}

async function handleToolsObservationChecklist(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const url = new URL(request.url);
  const locale = (url.searchParams.get('locale') || '').toLowerCase();
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'observation_checklist' }],
    orderBy: [{ field: { fieldPath: 'order' }, direction: 'ASCENDING' }],
    limit: 200,
  });
  const itemsRaw = docs.map((doc) => ({
    id: doc.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
  }));
  const filtered =
    locale
      ? itemsRaw.filter((i) => {
          const data = i.data as Record<string, unknown>;
          return (data['locale'] as string | undefined)?.toLowerCase() === locale;
        })
      : itemsRaw;
  const items = filtered.length > 0 ? filtered : itemsRaw;
  return jsonResponse({ ok: true, items }, corsHeaders);
}

async function handleToolsObservationChecklistUpdate(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const auth = await requireAuthWithRole(request, env);
  if (auth.role !== 'observer' && auth.role !== 'admin') {
    throw new HttpError(403, 'Observer role required.');
  }
  const body = await readJson(request);
  const itemId = stringField(body, 'itemId') || stringField(body, 'id');
  const completedValue = body['completed'];
  if (!itemId) {
    throw new HttpError(400, 'itemId is required');
  }
  if (typeof completedValue !== 'boolean') {
    throw new HttpError(400, 'completed must be a boolean');
  }
  const completed = completedValue;
  const now = new Date().toISOString();

  const existing = await firestoreGet(env, `observation_checklist/${itemId}`);
  const data =
    existing?.fields ? (valueToJs({ mapValue: { fields: existing.fields } }) as Record<string, unknown>) : {};
  const current = Array.isArray(data['completedBy'])
    ? (data['completedBy'] as unknown[]).map((e) => e?.toString() ?? '').filter((e) => e)
    : [];
  const next = new Set(current);
  if (completed) {
    next.add(auth.uid);
  } else {
    next.delete(auth.uid);
  }
  await firestorePatch(
    env,
    `observation_checklist/${itemId}`,
    { completed, completedBy: Array.from(next), updatedAt: now },
    ['completed', 'completedBy', 'updatedAt'],
  );
  return jsonResponse({ ok: true }, corsHeaders);
}

async function handleToolsElectionCalendar(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const url = new URL(request.url);
  const locale = (url.searchParams.get('locale') || '').toLowerCase();
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'election_calendar' }],
    orderBy: [{ field: { fieldPath: 'startAt' }, direction: 'ASCENDING' }],
    limit: 200,
  });
  const calendarRaw = docs.map((doc) => ({
    id: doc.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
  }));
  const filtered =
    locale
      ? calendarRaw.filter((c) => {
          const data = c.data as Record<string, unknown>;
          return (data['locale'] as string | undefined)?.toLowerCase() === locale;
        })
      : calendarRaw;
  if (filtered.length > 0) {
    return jsonResponse({ ok: true, calendar: filtered }, corsHeaders);
  }
  if (calendarRaw.length > 0) {
    return jsonResponse({ ok: true, calendar: calendarRaw }, corsHeaders);
  }

  const elections = await firestoreRunQuery(env, {
    from: [{ collectionId: 'elections' }],
    orderBy: [{ field: { fieldPath: 'startAt' }, direction: 'ASCENDING' }],
    limit: 100,
  });
  const calendar = elections.map((doc) => ({
    id: doc.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
  }));
  return jsonResponse({ ok: true, calendar }, corsHeaders);
}

async function handleToolsCivicLessons(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const url = new URL(request.url);
  const locale = (url.searchParams.get('locale') || '').toLowerCase();
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'civic_lessons' }],
    orderBy: [{ field: { fieldPath: 'title' }, direction: 'ASCENDING' }],
    limit: 200,
  });
  const lessonsRaw = docs.map((doc) => ({
    id: doc.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
  }));
  const filtered =
    locale
      ? lessonsRaw.filter((l) => {
          const data = l.data as Record<string, unknown>;
          return (data['locale'] as string | undefined)?.toLowerCase() === locale;
        })
      : lessonsRaw;
  const lessons = filtered.length > 0 ? filtered : lessonsRaw;
  return jsonResponse({ ok: true, lessons }, corsHeaders);
}

async function handleIncidentSubmit(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid, role } = await requireAuthWithRole(request, env);
  const auth: RateLimitAuth = { uid, role };
  if (role !== 'observer' && role !== 'voter' && role !== 'admin') {
    throw new HttpError(403, 'Authenticated role required.');
  }
  const windowSeconds = parseIntEnv(
    env.INCIDENT_SUBMIT_RATE_LIMIT_WINDOW_SECONDS,
    INCIDENT_SUBMIT_DEFAULT_RATE_LIMIT_WINDOW_SECONDS,
    30,
    24 * 60 * 60,
  );
  const maxRequests = parseIntEnv(
    env.INCIDENT_SUBMIT_RATE_LIMIT_MAX_REQUESTS,
    INCIDENT_SUBMIT_DEFAULT_RATE_LIMIT_MAX_REQUESTS,
    1,
    200,
  );
  await enforceRateLimit({
    request,
    env,
    namespace: 'incident_submit',
    key: 'submit',
    auth,
    windowSeconds,
    maxRequests,
    message: 'Too many incident reports. Please wait and try again.',
  });

  const body = await readJson(request);
  const title = sanitizePlainText(stringField(body, 'title'), 160);
  const description = sanitizePlainText(stringField(body, 'description'), 4000);
  const location = sanitizePlainText(stringField(body, 'location'), 200);
  const occurredAt = stringField(body, 'occurredAt').trim();
  const category = sanitizePlainText(stringField(body, 'category').toLowerCase(), 40);
  const severity = sanitizePlainText(stringField(body, 'severity').toLowerCase(), 20);
  const electionId = sanitizePlainText(stringField(body, 'electionId'), 120);

  if (!title) throw new HttpError(400, 'title is required');
  if (!description) throw new HttpError(400, 'description is required');
  if (!location) throw new HttpError(400, 'location is required');
  if (!occurredAt) throw new HttpError(400, 'occurredAt is required');
  const occurredTs = Date.parse(occurredAt);
  if (Number.isNaN(occurredTs)) {
    throw new HttpError(400, 'occurredAt must be a valid ISO date');
  }
  const nowTs = Date.now();
  if (occurredTs > nowTs + 24 * 60 * 60 * 1000) {
    throw new HttpError(400, 'occurredAt cannot be in the future');
  }
  if (occurredTs < nowTs - 730 * 24 * 60 * 60 * 1000) {
    throw new HttpError(400, 'occurredAt is too old');
  }
  if (
    ![
      'fraud',
      'intimidation',
      'violence',
      'logistics',
      'technical',
      'accessibility',
      'other',
    ].includes(category)
  ) {
    throw new HttpError(400, 'Unsupported incident category.');
  }
  if (!['low', 'medium', 'high', 'critical'].includes(severity)) {
    throw new HttpError(400, 'Unsupported incident severity.');
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const attachmentsInput = body['attachments'];
  const attachments = Array.isArray(attachmentsInput)
    ? attachmentsInput
        .map((item) => sanitizePlainText(`${item ?? ''}`, 2048))
        .filter((value) => value.length > 0)
        .slice(0, INCIDENT_MAX_ATTACHMENTS)
    : [];
  if (Array.isArray(attachmentsInput) && attachmentsInput.length > INCIDENT_MAX_ATTACHMENTS) {
    throw new HttpError(400, `Maximum ${INCIDENT_MAX_ATTACHMENTS} attachments are allowed.`);
  }

  await firestoreCreate(env, `incidents/${id}`, {
    id,
    reportedBy: uid,
    title,
    description,
    location,
    occurredAt: new Date(occurredTs).toISOString(),
    category,
    severity,
    electionId: electionId || null,
    attachments,
    status: 'submitted',
    createdAt: now,
  });

  return jsonResponse({ ok: true, reportId: id, status: 'submitted' }, corsHeaders, 201);
}

async function handleSupportTicket(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const auth = await maybeAuthWithRole(request, env);
  const uid = auth?.uid || '';
  const role = auth?.role || 'public';
  const body = await readJson(request);
  const name = sanitizePlainText(
    pickString(body, ['name', 'fullName', 'displayName']),
    120,
  );
  const email = pickString(body, ['email', 'senderEmail']).trim().toLowerCase();
  const message = sanitizePlainText(
    pickString(body, ['message', 'details', 'description']),
    4000,
  );
  const registrationId = sanitizePlainText(stringField(body, 'registrationId'), 120);
  const category = sanitizePlainText(
    pickString(body, ['category', 'subject', 'topic']).toLowerCase(),
    80,
  );

  if (!name) {
    throw new HttpError(400, 'name is required');
  }
  if (!email || !isValidEmail(email)) {
    throw new HttpError(400, 'A valid email is required');
  }
  if (!message) {
    throw new HttpError(400, 'message is required');
  }
  const windowSeconds = parseIntEnv(
    env.SUPPORT_TICKET_RATE_LIMIT_WINDOW_SECONDS,
    SUPPORT_TICKET_DEFAULT_RATE_LIMIT_WINDOW_SECONDS,
    30,
    24 * 60 * 60,
  );
  const maxRequests = parseIntEnv(
    env.SUPPORT_TICKET_RATE_LIMIT_MAX_REQUESTS,
    SUPPORT_TICKET_DEFAULT_RATE_LIMIT_MAX_REQUESTS,
    1,
    100,
  );
  await enforceRateLimit({
    request,
    env,
    namespace: 'support_ticket',
    key: 'submit',
    auth,
    windowSeconds,
    maxRequests,
    message: 'Too many support requests. Please wait and try again.',
  });

  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  await firestoreCreate(env, `support_tickets/${id}`, {
    id,
    userId: uid || null,
    role,
    name,
    email,
    registrationId,
    category: category || 'other',
    message,
    status: 'open',
    createdAt: now,
    updatedAt: now,
  });

  if (uid) {
    try {
      await createUserNotification(
        env,
        {
          id: `support_ticket_received_${id}`,
          userId: uid,
          audience: roleToAudience(role),
          category: roleToAudience(role),
          type: 'support',
          title: 'Support ticket received',
          body: `Your ticket ${id} was submitted successfully. Our team will reply soon.`,
          route: `/support?ticketId=${encodeURIComponent(id)}`,
          read: false,
          createdAt: now,
          updatedAt: now,
          source: 'support_ticket',
          sourceId: id,
        },
        true,
      );
    } catch (error) {
      console.error(
        'Support ticket user notification failed',
        (error as Error).message || error,
      );
    }
  }

  try {
    await notifyAdmins(
      env,
      {
        idPrefix: `support_ticket_new_${id}`,
        category: 'support',
        title: 'New help desk ticket',
        body: `New ${role} ticket from ${name}.`,
        route: `/admin/support?ticketId=${encodeURIComponent(id)}`,
        source: 'support_ticket',
        sourceId: id,
      },
      now,
    );
  } catch (error) {
    console.error(
      'Support ticket admin notification failed',
      (error as Error).message || error,
    );
  }

  return jsonResponse({ ok: true, ticketId: id, status: 'received' }, corsHeaders, 201);
}

type CamGuideWebSnippet = {
  title: string;
  excerpt: string;
  url: string;
  source: string;
};

async function handleCamGuideChat(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const auth = await maybeAuthWithRole(request, env);
  const body = await readJson(request);
  const question = pickString(body, ['question', 'message', 'q']).trim();
  if (!question) {
    throw new HttpError(400, 'question is required');
  }
  if (question.length > 1000) {
    throw new HttpError(400, 'question is too long');
  }
  const windowSeconds = parseIntEnv(
    env.CAMGUIDE_RATE_LIMIT_WINDOW_SECONDS,
    CAMGUIDE_DEFAULT_RATE_LIMIT_WINDOW_SECONDS,
    30,
    24 * 60 * 60,
  );
  const maxRequests = parseIntEnv(
    env.CAMGUIDE_RATE_LIMIT_MAX_REQUESTS,
    CAMGUIDE_DEFAULT_RATE_LIMIT_MAX_REQUESTS,
    1,
    300,
  );
  await enforceRateLimit({
    request,
    env,
    namespace: 'camguide_chat',
    key: 'ask',
    auth,
    windowSeconds,
    maxRequests,
    message: 'Too many CamGuide requests. Please wait before trying again.',
  });

  const locale = pickString(body, ['locale', 'lang']).trim().toLowerCase();
  const isFrench = locale.startsWith('fr');
  const role = pickString(body, ['role']).trim().toLowerCase();

  const liveContext = await fetchCamGuideLiveContext(question);
  const answer = buildCamGuideHumanAnswer({
    question,
    role,
    isFrench,
    snippets: liveContext.snippets,
  });
  const followUps = buildCamGuideFollowUps({
    question,
    isFrench,
    hasLiveContext: liveContext.snippets.length > 0,
  });
  const confidence =
    liveContext.snippets.length > 0
      ? Math.min(0.95, 0.62 + liveContext.snippets.length * 0.1)
      : 0.36;

  return jsonResponse(
    {
      ok: true,
      answer,
      followUps,
      sourceHints: liveContext.sources,
      confidence,
      intentId: liveContext.snippets.length > 0 ? 'web_live_assist' : 'general_conversation',
    },
    corsHeaders,
  );
}

async function fetchCamGuideLiveContext(
  question: string,
): Promise<{ snippets: CamGuideWebSnippet[]; sources: string[] }> {
  const snippets: CamGuideWebSnippet[] = [];
  const sourceSet = new Set<string>();

  const pushSnippet = (input: CamGuideWebSnippet): void => {
    if (snippets.length >= 3) return;
    if (!input.excerpt.trim()) return;
    const exists = snippets.some((item) => item.excerpt === input.excerpt);
    if (exists) return;
    snippets.push(input);
    if (input.url.trim()) {
      sourceSet.add(input.url.trim());
    } else if (input.source.trim()) {
      sourceSet.add(input.source.trim());
    }
  };

  try {
    const searchUrl = new URL('https://api.duckduckgo.com/');
    searchUrl.searchParams.set('q', question);
    searchUrl.searchParams.set('format', 'json');
    searchUrl.searchParams.set('no_html', '1');
    searchUrl.searchParams.set('no_redirect', '1');
    searchUrl.searchParams.set('skip_disambig', '1');

    const response = await fetch(searchUrl.toString(), {
      headers: { Accept: 'application/json' },
    });
    if (response.ok) {
      const payload = (await response.json()) as Record<string, unknown>;
      const abstractText = camGuideTrim(camGuideString(payload['AbstractText']));
      const abstractUrl = camGuideString(payload['AbstractURL']);
      const abstractSource =
        camGuideString(payload['AbstractSource']) || camGuideHostLabel(abstractUrl, 'DuckDuckGo');
      const heading = camGuideTrim(camGuideString(payload['Heading']), 80) || 'Overview';
      if (abstractText) {
        pushSnippet({
          title: heading,
          excerpt: abstractText,
          url: abstractUrl,
          source: abstractSource,
        });
      }

      const definition = camGuideTrim(camGuideString(payload['Definition']));
      if (definition) {
        const definitionUrl = camGuideString(payload['DefinitionURL']);
        pushSnippet({
          title: 'Definition',
          excerpt: definition,
          url: definitionUrl,
          source:
            camGuideString(payload['DefinitionSource']) ||
            camGuideHostLabel(definitionUrl, 'DuckDuckGo'),
        });
      }

      const directAnswer = camGuideTrim(camGuideString(payload['Answer']));
      if (directAnswer) {
        pushSnippet({
          title: 'Direct answer',
          excerpt: directAnswer,
          url: '',
          source: 'DuckDuckGo',
        });
      }

      const related = extractCamGuideRelatedSnippets(payload['RelatedTopics']);
      for (const item of related) {
        pushSnippet(item);
      }
    }
  } catch (error) {
    console.error('CamGuide live lookup failed', (error as Error).message);
  }

  return { snippets, sources: Array.from(sourceSet).slice(0, 5) };
}

function extractCamGuideRelatedSnippets(raw: unknown): CamGuideWebSnippet[] {
  const out: CamGuideWebSnippet[] = [];

  const visit = (value: unknown): void => {
    if (!Array.isArray(value)) return;
    for (const item of value) {
      if (out.length >= 8) return;
      const record = camGuideRecord(item);
      if (!record) continue;

      const text = camGuideString(record['Text']);
      const url = camGuideString(record['FirstURL']);
      if (text) {
        const split = text.split(' - ');
        const title = camGuideTrim(split[0] || 'Related topic', 80);
        const excerptRaw = split.length > 1 ? split.slice(1).join(' - ') : text;
        const excerpt = camGuideTrim(excerptRaw);
        if (excerpt) {
          out.push({
            title,
            excerpt,
            url,
            source: camGuideHostLabel(url, 'DuckDuckGo'),
          });
        }
      }

      if (Array.isArray(record['Topics'])) {
        visit(record['Topics']);
      }
    }
  };

  visit(raw);
  return out;
}

function buildCamGuideHumanAnswer(params: {
  question: string;
  role: string;
  isFrench: boolean;
  snippets: CamGuideWebSnippet[];
}): string {
  const roleLabel = camGuideRoleLabel(params.role, params.isFrench);
  const lines: string[] = [];

  if (params.isFrench) {
    lines.push(`Bonne question. Je vous reponds comme un conseiller ${roleLabel}.`);
    if (params.snippets.length > 0) {
      lines.push('Je viens de verifier des sources en ligne en temps reel.');
      lines.push('Voici le plus utile:');
      params.snippets.forEach((snippet, index) => {
        lines.push(`${index + 1}. ${snippet.excerpt}`);
      });
      lines.push(
        'Si vous voulez, je peux approfondir un point, comparer les sources, ou vous faire un plan d action.',
      );
    } else {
      const fallbackSteps = buildCamGuidePracticalFallback({
        question: params.question,
        isFrench: true,
      });
      lines.push(
        `Je n ai pas pu recuperer de contexte web en direct pour "${params.question}".`,
      );
      lines.push('Voici un plan pratique a executer tout de suite:');
      fallbackSteps.forEach((step, index) => {
        lines.push(`${index + 1}. ${step}`);
      });
      lines.push('Partagez votre ecran exact et je vous donne une version personnalisee.');
    }
  } else {
    lines.push(`Great question. I will answer as a ${roleLabel} advisor.`);
    if (params.snippets.length > 0) {
      lines.push('I just checked live online sources.');
      lines.push('Here is the most useful summary:');
      params.snippets.forEach((snippet, index) => {
        lines.push(`${index + 1}. ${snippet.excerpt}`);
      });
      lines.push(
        'If you want, I can go deeper, compare sources, or turn this into a practical action plan.',
      );
    } else {
      const fallbackSteps = buildCamGuidePracticalFallback({
        question: params.question,
        isFrench: false,
      });
      lines.push(`I could not fetch reliable live web context for "${params.question}" just now.`);
      lines.push('Here is a practical plan you can apply immediately:');
      fallbackSteps.forEach((step, index) => {
        lines.push(`${index + 1}. ${step}`);
      });
      lines.push('Share your exact screen or blocker and I will tailor this precisely.');
    }
  }

  return lines.join('\n');
}

function buildCamGuideFollowUps(params: {
  question: string;
  isFrench: boolean;
  hasLiveContext: boolean;
}): string[] {
  if (params.isFrench) {
    return params.hasLiveContext
      ? [
          'Peux-tu citer les sources officielles avec les liens ?',
          'Donne-moi un plan etape par etape.',
          'Explique-le en version simple en 5 points.',
          'Quels risques ou limites dois-je verifier ?',
        ]
      : buildCamGuideNoLiveFollowUps(params.question, true);
  }

  return params.hasLiveContext
    ? [
        'Can you cite official sources with links?',
        'Give me a step-by-step plan.',
        'Explain this in plain language in 5 points.',
        'What risks or limitations should I verify?',
      ]
    : buildCamGuideNoLiveFollowUps(params.question, false);
}

function buildCamGuidePracticalFallback(params: {
  question: string;
  isFrench: boolean;
}): string[] {
  const question = params.question.toLowerCase();
  const hasAny = (tokens: string[]): boolean => tokens.some((token) => question.includes(token));

  if (
    hasAny([
      'register',
      'registration',
      'inscription',
      'verify',
      'verification',
      'electoral card',
      'voter card',
    ])
  ) {
    return params.isFrench
      ? [
          'Ouvrez Inscription et remplissez vos donnees d identite exactement comme sur votre document.',
          'Utilisez la verification OCR/biometrique si proposee puis verifiez chaque champ avant envoi.',
          'Suivez le statut dans Verification d inscription et conservez votre numero de reference.',
          'Si le statut bloque, soumettez un ticket Support avec votre identifiant et la capture d erreur.',
        ]
      : [
          'Open Registration and enter identity details exactly as they appear on your official document.',
          'Use OCR/biometric verification when available, then review every field before submitting.',
          'Track status in Registration Verification and keep your reference ID.',
          'If status is blocked, submit a Support ticket with your registration ID and screenshot.',
        ];
  }

  if (hasAny(['vote', 'voting', 'ballot', 'receipt', 'recu'])) {
    return params.isFrench
      ? [
          'Verifiez d abord votre eligibilite et la fenetre de vote dans Tableau de bord.',
          'Confirmez votre identite, puis validez votre choix de vote une seule fois.',
          'Recuperez votre recu de vote securise et sauvegardez-le localement.',
          'En cas de souci technique, signalez-le immediatement via Support ou Incident.',
        ]
      : [
          'First confirm eligibility and the active voting window in your dashboard.',
          'Verify your identity, then submit your ballot once.',
          'Open your secure vote receipt and keep a local copy.',
          'If anything fails, report it immediately via Support or Incident report.',
        ];
  }

  if (hasAny(['support', 'ticket', 'help desk', 'incident', 'fraud'])) {
    return params.isFrench
      ? [
          'Choisissez Support pour creer un ticket avec email valide et description precise.',
          'Ajoutez identifiant d inscription, horodatage, appareil, et captures utiles.',
          'Pour fraude/incident, utilisez le formulaire Incident avec categorie et niveau de severite.',
          'Surveillez les notifications pour la reponse admin et le statut de resolution.',
        ]
      : [
          'Use Support to open a ticket with a valid email and clear problem statement.',
          'Include registration ID, timestamp, device details, and useful screenshots.',
          'For fraud/incidents, use Incident report with category and severity.',
          'Watch notifications for admin responses and resolution status.',
        ];
  }

  if (hasAny(['tip', 'taptap', 'remitly', 'maxit', 'orange money'])) {
    return params.isFrench
      ? [
          'Dans Support CamVote, choisissez TapTap Send, Remitly, ou Orange Money Max It.',
          'Verifiez toujours le nom du destinataire avant paiement et gardez la reference.',
          'Pour Max It, ouvrez l app et scannez le QR affiche dans CamVote.',
          'Soumettez la preuve si demandee puis suivez le statut jusqu a confirmation.',
        ]
      : [
          'In Support CamVote, choose TapTap Send, Remitly, or Orange Money Max It.',
          'Always verify recipient name before payment and keep your transaction reference.',
          'For Max It, open the app and scan the QR shown in CamVote.',
          'Submit proof when requested and track status until confirmed.',
        ];
  }

  return params.isFrench
    ? [
        'Definissez votre objectif exact en une phrase.',
        'Partagez votre role (public, electeur, observateur, admin) et la page courante.',
        'Precisez le message d erreur ou le blocage concret.',
        'Je vous renverrai un plan court avec les prochaines actions prioritaires.',
      ]
    : [
        'State your exact goal in one sentence.',
        'Share your role (public, voter, observer, admin) and current page.',
        'Provide the exact error or blocker you see.',
        'I will return a short prioritized action plan.',
      ];
}

function buildCamGuideNoLiveFollowUps(question: string, isFrench: boolean): string[] {
  const normalized = question.toLowerCase();
  const hasAny = (tokens: string[]): boolean => tokens.some((token) => normalized.includes(token));

  if (hasAny(['register', 'registration', 'inscription', 'verify', 'verification'])) {
    return isFrench
      ? [
          'Peux-tu me donner la checklist complete d inscription ?',
          'Quels documents dois-je preparer exactement ?',
          'Comment accelerer la verification si elle reste en attente ?',
        ]
      : [
          'Can you give me the full registration checklist?',
          'Which exact documents should I prepare?',
          'How do I speed up verification if it stays pending?',
        ];
  }

  if (hasAny(['tip', 'taptap', 'remitly', 'maxit', 'orange money'])) {
    return isFrench
      ? [
          'Quel canal est le plus simple entre TapTap, Remitly et Max It ?',
          'Comment verifier le destinataire avant paiement ?',
          'Comment suivre la confirmation de mon tip ?',
        ]
      : [
          'Which channel is simplest for me: TapTap, Remitly, or Max It?',
          'How do I verify the recipient before paying?',
          'How do I track my tip confirmation?',
        ];
  }

  return isFrench
    ? [
        'Voici mon contexte exact...',
        'Peux-tu me poser 3 questions pour mieux cadrer ?',
        'Donne-moi une check-list pratique.',
      ]
    : [
        'Here is my exact context...',
        'Ask me 3 clarifying questions first.',
        'Give me a practical checklist.',
      ];
}

function camGuideRoleLabel(role: string, isFrench: boolean): string {
  switch (role) {
    case 'admin':
      return isFrench ? 'admin' : 'admin';
    case 'observer':
      return isFrench ? 'observateur' : 'observer';
    case 'voter':
      return isFrench ? 'electeur' : 'voter';
    default:
      return isFrench ? 'public' : 'public';
  }
}

function camGuideString(value: unknown): string {
  if (typeof value === 'string') return value.trim();
  if (typeof value === 'number' || typeof value === 'boolean') {
    return `${value}`.trim();
  }
  return '';
}

function camGuideTrim(value: string, maxChars = 240): string {
  const normalized = value
    .replace(/\s+/g, ' ')
    .replace(/[“”]/g, '"')
    .replace(/[‘’]/g, "'")
    .replace(/[–—]/g, '-')
    .replace(/…/g, '...')
    .replace(/[^\x09\x0A\x0D\x20-\x7E]/g, '')
    .trim();
  if (normalized.length <= maxChars) return normalized;
  return `${normalized.slice(0, maxChars - 3).trimEnd()}...`;
}

function camGuideHostLabel(url: string, fallback: string): string {
  const raw = url.trim();
  if (!raw) return fallback;
  try {
    return new URL(raw).host.replace(/^www\./, '') || fallback;
  } catch {
    return fallback;
  }
}

function camGuideRecord(value: unknown): Record<string, unknown> | null {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return null;
  }
  return value as Record<string, unknown>;
}

async function handleNotificationsList(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid, role } = await requireAuthWithRole(request, env);
  const url = new URL(request.url);
  const sinceRaw = (url.searchParams.get('since') || '').trim();
  const sinceMs = parseDateValue(sinceRaw);

  const notifications: JsonObject[] = [];
  const roleAudience = roleToAudience(role);
  const allowedCategories = allowedNotificationCategoriesForRole(roleAudience);

  const userNotificationDocs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'user_notifications' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'userId' },
        op: 'EQUAL',
        value: { stringValue: uid },
      },
    },
    limit: 250,
  });

  for (const doc of userNotificationDocs) {
    const data = (valueToJs({ mapValue: { fields: doc.fields ?? {} } }) || {}) as Record<
      string,
      unknown
    >;
    const id = `${(data['id'] as string | undefined) || doc.name.split('/').pop() || ''}`.trim();
    if (!id) continue;

    const createdAt = `${(data['createdAt'] as string | undefined) || ''}`.trim() || new Date().toISOString();
    const createdAtMs = parseDateValue(createdAt);
    if (sinceMs !== null && createdAtMs !== null && createdAtMs <= sinceMs) {
      continue;
    }

    notifications.push({
      id,
      type: normalizeNotificationType(data['type']),
      audience: normalizeNotificationAudience(data['audience'], roleAudience),
      category: normalizeNotificationCategory(data['category'], data['type'], data['audience']),
      title: `${(data['title'] as string | undefined) || 'Notification'}`.trim(),
      body: `${(data['body'] as string | undefined) || ''}`.trim(),
      createdAt,
      read: data['read'] === true,
      route: `${(data['route'] as string | undefined) || ''}`.trim() || null,
    });
  }

  // Derived support updates ensure users still receive live feedback
  // when a ticket is answered or closed (even if support responds manually).
  const supportDocs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'support_tickets' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'userId' },
        op: 'EQUAL',
        value: { stringValue: uid },
      },
    },
    limit: 200,
  });

  for (const doc of supportDocs) {
    const data = (valueToJs({ mapValue: { fields: doc.fields ?? {} } }) || {}) as Record<
      string,
      unknown
    >;
    const ticketId = `${(data['id'] as string | undefined) || doc.name.split('/').pop() || ''}`.trim();
    if (!ticketId) continue;

    const status = `${(data['status'] as string | undefined) || ''}`.trim().toLowerCase();
    const responseMessage = `${(data['responseMessage'] as string | undefined) || ''}`.trim();
    const hasSupportUpdate = status === 'answered' || status === 'resolved' || status === 'closed' || responseMessage.length > 0;
    if (!hasSupportUpdate) continue;

    const eventAt =
      `${(data['respondedAt'] as string | undefined) || (data['updatedAt'] as string | undefined) || (data['createdAt'] as string | undefined) || ''}`.trim() ||
      new Date().toISOString();
    const eventAtMs = parseDateValue(eventAt);
    if (sinceMs !== null && eventAtMs !== null && eventAtMs <= sinceMs) {
      continue;
    }

    const sourceMarker = `${status || 'update'}_${eventAt}`;
    const message =
      responseMessage ||
      `Your support ticket ${ticketId} has been updated to "${status || 'updated'}".`;
    const title =
      status === 'resolved'
        ? 'Support ticket resolved'
        : status === 'closed'
        ? 'Support ticket closed'
        : 'Support response received';

    notifications.push({
      id: `support_ticket_status_${ticketId}_${sourceMarker}`,
      type: status === 'resolved' || status === 'closed' ? 'success' : 'info',
      audience: roleAudience,
      category: roleAudience === 'admin' ? 'support' : roleAudience,
      title,
      body: message,
      createdAt: eventAt,
      read: false,
      route: `/support?ticketId=${encodeURIComponent(ticketId)}`,
    });
  }

  const byId = new Map<string, JsonObject>();
  for (const item of notifications) {
    const id = `${item['id'] ?? ''}`.trim();
    if (!id) continue;
    byId.set(id, item);
  }

  const sorted = [...byId.values()].sort((a, b) => {
    const aDate = parseDateValue(a['createdAt']) ?? 0;
    const bDate = parseDateValue(b['createdAt']) ?? 0;
    return bDate - aDate;
  });

  const filtered = sorted.filter((item) => {
    const category = normalizeNotificationCategory(
      item['category'],
      item['type'],
      item['audience'],
    );
    return allowedCategories.has(category);
  });

  return jsonResponse({ ok: true, notifications: filtered }, corsHeaders);
}

async function handleNotificationMarkRead(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  const body = await readJson(request);
  const notificationId = pickString(body, ['notificationId', 'id']).trim();
  if (!notificationId) {
    throw new HttpError(400, 'notificationId is required');
  }

  const doc = await firestoreGet(env, `user_notifications/${notificationId}`);
  if (!doc) {
    return jsonResponse({ ok: true, updated: false }, corsHeaders);
  }

  const ownerUid = docString(doc, 'userId');
  if (ownerUid !== uid) {
    throw new HttpError(403, 'Not authorized to update this notification.');
  }

  const now = new Date().toISOString();
  await firestorePatch(
    env,
    `user_notifications/${notificationId}`,
    { read: true, readAt: now, updatedAt: now },
    ['read', 'readAt', 'updatedAt'],
  );
  return jsonResponse({ ok: true, updated: true }, corsHeaders);
}

async function handleNotificationMarkAllRead(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'user_notifications' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'userId' },
        op: 'EQUAL',
        value: { stringValue: uid },
      },
    },
    limit: 400,
  });

  const now = new Date().toISOString();
  let updated = 0;
  for (const doc of docs) {
    if (docBool(doc, 'read') === true) continue;
    const id = doc.name.split('/').pop() || '';
    if (!id) continue;
    await firestorePatch(
      env,
      `user_notifications/${id}`,
      { read: true, readAt: now, updatedAt: now },
      ['read', 'readAt', 'updatedAt'],
    );
    updated += 1;
  }

  return jsonResponse({ ok: true, updated }, corsHeaders);
}

async function handleAdminSupportTickets(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const url = new URL(request.url);
  const statusFilter = (url.searchParams.get('status') || '').trim().toLowerCase();
  const query = (url.searchParams.get('query') || '').trim().toLowerCase();

  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'support_tickets' }],
    limit: 250,
  });

  let tickets = docs
    .map((doc) => ({
      id: doc.name.split('/').pop(),
      data: valueToJs({ mapValue: { fields: doc.fields ?? {} } }),
    }))
    .filter((entry) => !!entry.id);

  if (statusFilter) {
    tickets = tickets.filter((entry) => {
      const data = entry.data as Record<string, unknown>;
      return `${(data['status'] as string | undefined) || ''}`.trim().toLowerCase() === statusFilter;
    });
  }

  if (query) {
    tickets = tickets.filter((entry) => {
      const data = entry.data as Record<string, unknown>;
      const haystack = [
        data['name'],
        data['email'],
        data['registrationId'],
        data['message'],
        data['category'],
      ]
        .map((v) => `${v ?? ''}`.toLowerCase())
        .join(' ');
      return haystack.includes(query);
    });
  }

  tickets.sort((a, b) => {
    const aDate = parseDateValue((a.data as Record<string, unknown>)['updatedAt'] ?? '') ?? 0;
    const bDate = parseDateValue((b.data as Record<string, unknown>)['updatedAt'] ?? '') ?? 0;
    return bDate - aDate;
  });

  return jsonResponse({ ok: true, tickets }, corsHeaders);
}

async function handleAdminSupportTicketRespond(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const admin = await requireAdmin(request, env);
  const body = await readJson(request);
  const ticketId = pickString(body, ['ticketId', 'id']).trim();
  const responseMessage = pickString(body, [
    'responseMessage',
    'message',
    'response',
  ]).trim();
  const status = stringField(body, 'status').trim().toLowerCase() || 'answered';
  if (!ticketId) {
    throw new HttpError(400, 'ticketId is required');
  }
  if (!responseMessage) {
    throw new HttpError(400, 'responseMessage is required');
  }

  const ticketDoc = await firestoreGet(env, `support_tickets/${ticketId}`);
  if (!ticketDoc) {
    throw new HttpError(404, 'Support ticket not found.');
  }

  const recipientEmail = docString(ticketDoc, 'email').trim().toLowerCase();
  let userId = docString(ticketDoc, 'userId').trim();
  if (!userId && isValidEmail(recipientEmail)) {
    const linkedUserDoc = await findUserByIdentifier(env, recipientEmail);
    if (linkedUserDoc) {
      userId =
        (
          docString(linkedUserDoc, 'uid') ||
          linkedUserDoc.name.split('/').pop() ||
          ''
        ).trim();
    }
  }

  const now = new Date().toISOString();
  const ticketPatch: JsonObject = {
    status,
    responseMessage,
    respondedAt: now,
    respondedBy: admin.uid,
    updatedAt: now,
  };
  const ticketPatchFields = [
    'status',
    'responseMessage',
    'respondedAt',
    'respondedBy',
    'updatedAt',
  ];
  if (userId) {
    ticketPatch.userId = userId;
    ticketPatchFields.push('userId');
  }
  await firestorePatch(
    env,
    `support_tickets/${ticketId}`,
    ticketPatch,
    ticketPatchFields,
  );

  let inAppSent = false;
  if (userId) {
    await createUserNotification(
      env,
      {
        id: `support_ticket_status_${ticketId}_${status}_${now}`,
        userId,
        audience: roleToAudience(docString(ticketDoc, 'role') || 'public'),
        category: roleToAudience(docString(ticketDoc, 'role') || 'public'),
        type: status === 'resolved' || status === 'closed' ? 'success' : 'info',
        title:
          status === 'resolved'
            ? 'Support ticket resolved'
            : status === 'closed'
            ? 'Support ticket closed'
            : 'Support response received',
        body: responseMessage,
        route: `/support?ticketId=${encodeURIComponent(ticketId)}`,
        read: false,
        createdAt: now,
        updatedAt: now,
        source: 'support_response',
        sourceId: ticketId,
      },
      true,
    );
    inAppSent = true;
  }

  const emailSent = await trySendSupportResponseEmail(env, {
    to: recipientEmail,
    ticketId,
    status,
    responseMessage,
  });

  return jsonResponse(
    { ok: true, ticketId, status, inAppSent, emailSent },
    corsHeaders,
  );
}

async function handleAdminTipList(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  await requireAdmin(request, env);
  const url = new URL(request.url);
  const status = (url.searchParams.get('status') || '').trim().toLowerCase();
  const provider = (url.searchParams.get('provider') || '').trim().toLowerCase();

  const filters: JsonObject[] = [];
  if (status) {
    filters.push({
      fieldFilter: {
        field: { fieldPath: 'status' },
        op: 'EQUAL',
        value: { stringValue: status },
      },
    });
  }
  if (provider) {
    filters.push({
      fieldFilter: {
        field: { fieldPath: 'provider' },
        op: 'EQUAL',
        value: { stringValue: provider },
      },
    });
  }

  const query: JsonObject = {
    from: [{ collectionId: 'tips' }],
    limit: 100,
    orderBy: [{ field: { fieldPath: 'createdAt' }, direction: 'DESCENDING' }],
    ...(filters.length
      ? {
          where:
            filters.length === 1
              ? filters[0]
              : {
                  compositeFilter: {
                    op: 'AND',
                    filters,
                  },
                },
        }
      : {}),
  };

  const docs = await firestoreRunQuery(env, query);
  const tips = docs.map((d) => ({
    id: d.name.split('/').pop(),
    data: valueToJs({ mapValue: { fields: d.fields ?? {} } }),
  }));
  return jsonResponse({ ok: true, tips }, corsHeaders);
}

async function handleAdminTipDecision(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const admin = await requireAdmin(request, env);
  const body = await readJson(request);
  const tipId = pickString(body, ['tipId', 'id']).trim();
  const decisionRaw = pickString(body, ['decision', 'status']).trim().toLowerCase();
  const note = pickString(body, ['note', 'message']).trim();

  if (!tipId) {
    throw new HttpError(400, 'tipId is required.');
  }

  const decision =
    decisionRaw === 'success' || decisionRaw === 'approved'
      ? 'success'
      : decisionRaw === 'failed' || decisionRaw === 'rejected'
      ? 'failed'
      : '';

  if (!decision) {
    throw new HttpError(400, 'decision must be success or failed.');
  }

  const tipDoc = await firestoreGet(env, `tips/${tipId}`);
  if (!tipDoc) {
    throw new HttpError(404, 'Tip not found.');
  }

  const now = new Date().toISOString();
  await firestorePatch(
    env,
    `tips/${tipId}`,
    {
      status: decision,
      decidedBy: admin.uid,
      decidedAt: now,
      decisionNote: note || null,
      updatedAt: now,
    },
    ['status', 'decidedBy', 'decidedAt', 'decisionNote', 'updatedAt'],
  );

  await firestoreCreate(env, `tip_events/${crypto.randomUUID()}`, {
    tipId,
    provider: docString(tipDoc, 'provider') || 'taptap_send',
    status: decision,
    note: note || null,
    decidedBy: admin.uid,
    createdAt: now,
  });

  if (decision === 'success') {
    const userId = docString(tipDoc, 'userId');
    const userRole = docString(tipDoc, 'userRole') || 'public';
    const amount = Number(docInt(tipDoc, 'amount') || 0);
    const currency = docString(tipDoc, 'currency') || 'XAF';
    const anonymous = docBool(tipDoc, 'anonymous') === true;
    const senderName = anonymous
      ? 'Anonymous supporter'
      : docString(tipDoc, 'senderName') || 'Supporter';

    if (userId) {
      await createUserNotification(
        env,
        {
          id: `tip_success_${tipId}`,
          userId,
          audience: roleToAudience(userRole),
          category: roleToAudience(userRole),
          type: 'tip',
          title: 'Tip received',
          body: buildTipThankYouMessage(senderName, amount, currency, {
            anonymous,
          }),
          route: `/support/tip?tipId=${encodeURIComponent(tipId)}`,
          read: false,
          createdAt: now,
          updatedAt: now,
          source: 'tip',
          sourceId: tipId,
        },
        true,
      );
    }

    await notifyAdmins(
      env,
      {
        idPrefix: `tip_confirmed_${tipId}`,
        category: 'tip',
        title: 'Tip confirmed',
        body: `${formatTipAmount(amount, currency)} confirmed by admin.`,
        route: `/support/tip?tipId=${encodeURIComponent(tipId)}`,
        source: 'tip',
        sourceId: tipId,
      },
      now,
    );
  }

  return jsonResponse({ ok: true, tipId, status: decision }, corsHeaders);
}

async function handleTipTapTapSendIntent(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const body = await readJson(request);
  const auth = await maybeAuthWithRole(request, env);
  const payload = parseTipIntentPayload(body, env);
  await enforceTipIntentRateLimit({
    request,
    env,
    auth,
    provider: 'taptap_send',
    amount: payload.amount,
    currency: payload.currency,
  });

  const tipId = crypto.randomUUID();
  const now = new Date().toISOString();
  const orangeMoneyNumber = (env.TIP_ORANGE_MONEY_NUMBER || '').trim();
  const orangeMoneyOwnerName = (env.TIP_ORANGE_MONEY_NAME || '').trim();
  const exposeOrangeMoneyNumber = shouldExposeOrangeMoneyNumber(env);
  const maskedOrangeMoneyNumber = maskPhoneNumber(orangeMoneyNumber);
  const checkoutRecipientNumber = orangeMoneyNumber || maskedOrangeMoneyNumber;
  const checkoutUrl = buildTapTapCheckoutUrl(
    (env.TAPTAP_SEND_URL || '').trim(),
    {
      tipId,
      amount: payload.amount,
      currency: payload.currency,
      recipientName: orangeMoneyOwnerName,
      // Always use the real number for the checkout flow (user initiated),
      // even when we keep it masked in UI responses.
      recipientNumber: checkoutRecipientNumber,
    },
  );
  const deepLink = buildTapTapDeepLink(
    (env.TAPTAP_SEND_DEEP_LINK || '').trim(),
    {
      tipId,
      amount: payload.amount,
      currency: payload.currency,
      recipientName: orangeMoneyOwnerName,
      recipientNumber: orangeMoneyNumber,
    },
  );

  await firestoreCreate(env, `tips/${tipId}`, {
    id: tipId,
    provider: 'taptap_send',
    status: 'pending',
    amount: payload.amount,
    currency: payload.currency,
    senderName: payload.senderName,
    senderEmail: payload.senderEmail || null,
    anonymous: payload.anonymous,
    userId: auth?.uid || null,
    userRole: auth?.role || 'public',
    source: payload.source,
    note: payload.note || null,
    checkoutUrl: checkoutUrl || null,
    checkoutDeepLink: deepLink || null,
    tipRecipientName: orangeMoneyOwnerName || null,
    tipRecipientNumberMasked: maskedOrangeMoneyNumber || null,
    createdAt: now,
    updatedAt: now,
  });

  return jsonResponse(
    {
      ok: true,
      tipId,
      status: 'pending',
      provider: 'taptap_send',
      amount: payload.amount,
      currency: payload.currency,
      checkoutUrl: checkoutUrl || null,
      deepLink: deepLink || null,
      orangeMoney: {
        number: exposeOrangeMoneyNumber
          ? orangeMoneyNumber
          : null,
        maskedNumber: maskedOrangeMoneyNumber || null,
        ownerName: orangeMoneyOwnerName,
      },
    },
    corsHeaders,
    201,
  );
}

async function handleTipRemitlyIntent(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const body = await readJson(request);
  const auth = await maybeAuthWithRole(request, env);
  const payload = parseTipIntentPayload(body, env);
  await enforceTipIntentRateLimit({
    request,
    env,
    auth,
    provider: 'remitly',
    amount: payload.amount,
    currency: payload.currency,
  });

  const tipId = crypto.randomUUID();
  const now = new Date().toISOString();
  const orangeMoneyNumber = (env.TIP_ORANGE_MONEY_NUMBER || '').trim();
  const orangeMoneyOwnerName = (env.TIP_ORANGE_MONEY_NAME || '').trim();
  const exposeOrangeMoneyNumber = shouldExposeOrangeMoneyNumber(env);
  const maskedOrangeMoneyNumber = maskPhoneNumber(orangeMoneyNumber);
  const checkoutRecipientNumber = orangeMoneyNumber || maskedOrangeMoneyNumber;
  const checkoutUrl = buildRemitlyCheckoutUrl(
    (env.REMITLY_SEND_URL || '').trim(),
    {
      tipId,
      amount: payload.amount,
      currency: payload.currency,
      recipientName: orangeMoneyOwnerName,
      // Always use the real number for the checkout flow (user initiated),
      // even when we keep it masked in UI responses.
      recipientNumber: checkoutRecipientNumber,
    },
  );
  const deepLink = buildRemitlyDeepLink(
    (env.REMITLY_SEND_DEEP_LINK || '').trim(),
    {
      tipId,
      amount: payload.amount,
      currency: payload.currency,
      recipientName: orangeMoneyOwnerName,
      recipientNumber: orangeMoneyNumber,
    },
  );

  await firestoreCreate(env, `tips/${tipId}`, {
    id: tipId,
    provider: 'remitly',
    status: 'pending',
    amount: payload.amount,
    currency: payload.currency,
    senderName: payload.senderName,
    senderEmail: payload.senderEmail || null,
    anonymous: payload.anonymous,
    userId: auth?.uid || null,
    userRole: auth?.role || 'public',
    source: payload.source,
    note: payload.note || null,
    checkoutUrl: checkoutUrl || null,
    checkoutDeepLink: deepLink || null,
    tipRecipientName: orangeMoneyOwnerName || null,
    tipRecipientNumberMasked: maskedOrangeMoneyNumber || null,
    createdAt: now,
    updatedAt: now,
  });

  return jsonResponse(
    {
      ok: true,
      tipId,
      status: 'pending',
      provider: 'remitly',
      amount: payload.amount,
      currency: payload.currency,
      checkoutUrl: checkoutUrl || null,
      deepLink: deepLink || null,
      orangeMoney: {
        number: exposeOrangeMoneyNumber
          ? orangeMoneyNumber
          : null,
        maskedNumber: maskedOrangeMoneyNumber || null,
        ownerName: orangeMoneyOwnerName,
      },
    },
    corsHeaders,
    201,
  );
}

async function handleTipTapTapSendSubmit(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const body = await readJson(request);
  const auth = await maybeAuthWithRole(request, env);
  const tipId = pickString(body, ['tipId', 'id']).trim();
  const reference = normalizeTipReference(
    pickString(body, ['reference', 'txRef', 'transactionId']),
  );
  const note = sanitizeTipNote(pickString(body, ['note', 'message']));
  const attachments = normalizeTipAttachments(arrayStringField(body, 'attachments'));

  if (!tipId) {
    throw new HttpError(400, 'tipId is required.');
  }
  if (!reference) {
    throw new HttpError(400, 'reference is required.');
  }

  const tipDoc = await firestoreGet(env, `tips/${tipId}`);
  if (!tipDoc) {
    throw new HttpError(404, 'Tip not found.');
  }

  const existingReference = normalizeTipReference(
    docString(tipDoc, 'providerReference'),
  );
  if (existingReference && existingReference !== reference) {
    throw new HttpError(
      409,
      'Tip already has a different reference. Contact support if this is incorrect.',
    );
  }

  const duplicateReferenceTipId = await findTipIdByProviderReference(env, reference);
  if (duplicateReferenceTipId && duplicateReferenceTipId !== tipId) {
    const now = new Date().toISOString();
    await firestoreCreate(env, `tip_events/${crypto.randomUUID()}`, {
      tipId,
      action: 'duplicate_reference',
      reference,
      conflictingTipId: duplicateReferenceTipId,
      submittedBy: auth?.uid || null,
      createdAt: now,
    });
    throw new HttpError(409, 'Reference already used by another tip.');
  }

  const now = new Date().toISOString();
  await firestorePatch(
    env,
    `tips/${tipId}`,
    {
      status: 'submitted',
      providerReference: reference,
      submitNote: note || null,
      receiptUrls: attachments.length ? attachments : null,
      submittedBy: auth?.uid || null,
      submittedAt: now,
      updatedAt: now,
    },
    [
      'status',
      'providerReference',
      'submitNote',
      'receiptUrls',
      'submittedBy',
      'submittedAt',
      'updatedAt',
    ],
  );

  await firestoreCreate(env, `tip_events/${crypto.randomUUID()}`, {
    tipId,
    provider: docString(tipDoc, 'provider') || 'taptap_send',
    status: 'submitted',
    reference,
    note: note || null,
    receiptUrls: attachments,
    submittedBy: auth?.uid || null,
    createdAt: now,
  });

  const amount = Number(docInt(tipDoc, 'amount') || 0);
  const currency = docString(tipDoc, 'currency') || 'XAF';
  const provider = docString(tipDoc, 'provider') || 'taptap_send';
  const senderName = docBool(tipDoc, 'anonymous') === true
    ? 'Anonymous supporter'
    : docString(tipDoc, 'senderName') || 'Supporter';

  await notifyAdmins(
    env,
    {
      idPrefix: `tip_submitted_${tipId}`,
      category: 'tip',
      title: 'Tip payment submitted',
      body: `${formatTipAmount(amount, currency)} via ${provider.toUpperCase()} from ${senderName}. Reference: ${reference}${
        attachments.length ? ' (receipt uploaded)' : ''
      }`,
      route: `/support/tip?tipId=${encodeURIComponent(tipId)}`,
      source: 'tip',
      sourceId: tipId,
    },
    now,
  );

  return jsonResponse({ ok: true, tipId, status: 'submitted' }, corsHeaders);
}

async function handleTipMaxItQrIntent(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const body = await readJson(request);
  const auth = await maybeAuthWithRole(request, env);
  const payload = parseTipIntentPayload(body, env);
  await enforceTipIntentRateLimit({
    request,
    env,
    auth,
    provider: 'maxit_qr',
    amount: payload.amount,
    currency: payload.currency,
  });

  const qrUrl = (env.MAXIT_TIP_QR_URL || '').trim();
  const deepLink = (env.MAXIT_TIP_DEEP_LINK || '').trim();
  // Max It QR tipping uses an in-app asset QR fallback. If these env vars are
  // not configured, we still create the tip session and return null fields so
  // the client can render the embedded QR image.

  const tipId = crypto.randomUUID();
  const now = new Date().toISOString();
  await firestoreCreate(env, `tips/${tipId}`, {
    id: tipId,
    provider: 'maxit_qr',
    status: 'pending',
    amount: payload.amount,
    currency: payload.currency,
    senderName: payload.senderName,
    senderEmail: payload.senderEmail || null,
    anonymous: payload.anonymous,
    userId: auth?.uid || null,
    userRole: auth?.role || 'public',
    source: payload.source,
    note: payload.note || null,
    maxItQrUrl: qrUrl || null,
    maxItDeepLink: deepLink || null,
    createdAt: now,
    updatedAt: now,
  });
  const exposeOrangeMoneyNumber = shouldExposeOrangeMoneyNumber(env);

  return jsonResponse(
    {
      ok: true,
      tipId,
      status: 'pending',
      provider: 'maxit_qr',
      qrUrl: qrUrl || null,
      deepLink: deepLink || null,
      orangeMoney: {
        number: exposeOrangeMoneyNumber
          ? (env.TIP_ORANGE_MONEY_NUMBER || '').trim()
          : null,
        ownerName: (env.TIP_ORANGE_MONEY_NAME || '').trim(),
      },
    },
    corsHeaders,
    201,
  );
}

async function handleTipStatus(
  request: Request,
  env: Env,
  corsHeaders: Headers,
  tipId: string,
): Promise<Response> {
  void request;
  const normalizedTipId = tipId.trim();
  if (!normalizedTipId) {
    throw new HttpError(400, 'tipId is required');
  }

  const tipDoc = await firestoreGet(env, `tips/${normalizedTipId}`);
  if (!tipDoc) {
    throw new HttpError(404, 'Tip not found.');
  }

    const provider = docString(tipDoc, 'provider') || 'taptap_send';
    const rawStatus = docString(tipDoc, 'status');
    let status =
      rawStatus.trim().toLowerCase() === 'submitted'
        ? 'submitted'
        : normalizeTipStatus(rawStatus);
    const amount = Number(docInt(tipDoc, 'amount') || 0);
    const currency = docString(tipDoc, 'currency') || 'XAF';
    const anonymous = docBool(tipDoc, 'anonymous') === true;
  const senderName = anonymous
    ? 'Anonymous supporter'
    : docString(tipDoc, 'senderName') || 'Supporter';
  const receiptUrls = docArrayString(tipDoc, 'receiptUrls');

    return jsonResponse(
      {
        ok: true,
        tipId: normalizedTipId,
        provider,
        status,
        amount,
        currency,
        senderName,
      anonymous,
      senderEmail: docString(tipDoc, 'senderEmail') || null,
      receiptUrls,
      updatedAt: docString(tipDoc, 'updatedAt') || null,
      thankYouMessage:
        status === 'success'
          ? buildTipThankYouMessage(senderName, amount, currency, { anonymous })
          : null,
    },
    corsHeaders,
  );
}

async function handleTipNotify(
  request: Request,
  env: Env,
  corsHeaders: Headers,
  tipId: string,
): Promise<Response> {
  const body = await readJson(request);
  const normalizedTipId = tipId.trim();
  if (!normalizedTipId) {
    throw new HttpError(400, 'tipId is required');
  }

  const tipDoc = await firestoreGet(env, `tips/${normalizedTipId}`);
  if (!tipDoc) {
    throw new HttpError(404, 'Tip not found.');
  }

  const status = normalizeTipStatus(docString(tipDoc, 'status'));
  if (status !== 'success') {
    throw new HttpError(409, 'Tip is not marked as successful yet.');
  }

  const userId = docString(tipDoc, 'userId');
  const userRole = docString(tipDoc, 'userRole') || 'public';
  const anonymous = docBool(tipDoc, 'anonymous') === true;
  const senderName = anonymous
    ? 'Anonymous supporter'
    : docString(tipDoc, 'senderName') || 'Supporter';
  const senderEmail = docString(tipDoc, 'senderEmail');
  const amount = Number(docInt(tipDoc, 'amount') || 0);
  const currency = docString(tipDoc, 'currency') || 'XAF';
  const inApp = body['inApp'] !== false;
  const email = body['email'] !== false;
  const now = new Date().toISOString();
  const message = buildTipThankYouMessage(senderName, amount, currency, {
    anonymous,
  });

  if (inApp && userId) {
    await createUserNotification(
      env,
      {
        id: `tip_success_${normalizedTipId}`,
        userId,
        audience: roleToAudience(userRole),
        category: roleToAudience(userRole),
        type: 'tip',
        title: 'Tip received',
        body: message,
        route: `/support/tip?tipId=${encodeURIComponent(normalizedTipId)}`,
        read: false,
        createdAt: now,
        updatedAt: now,
        source: 'tip',
        sourceId: normalizedTipId,
      },
      true,
    );
  }

  const inAppSent = inApp && !!userId;
  const emailQueued = email && senderEmail.trim().length > 0;
  const deliveryHint =
    !inAppSent && !emailQueued
      ? 'Thank-you is shown in app after payment confirmation for anonymous/public tippers.'
      : null;

  await firestoreCreate(env, `tip_events/${crypto.randomUUID()}`, {
    tipId: normalizedTipId,
    action: 'notify',
    inAppSent,
    emailQueued,
    anonymous,
    createdAt: now,
  });

  return jsonResponse(
    {
      ok: true,
      tipId: normalizedTipId,
      inAppSent,
      emailQueued,
      anonymous,
      deliveryHint,
      message,
    },
    corsHeaders,
  );
}

async function handleTipWebhookTipQr(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { raw: rawBody, body } = await readJsonWithRaw(request);
  const providedSignature = (request.headers.get('x-tip-qr-signature') || '').trim();
  const secret = (env.TIP_QR_WEBHOOK_SECRET || '').trim();
  if (secret) {
    if (!providedSignature) {
      throw new HttpError(401, 'Missing tip webhook signature.');
    }
    const expectedHmac = await hmacSha256Hex(secret, rawBody);
    const normalizedSignature = providedSignature.replace(/^sha256=/i, '').trim().toLowerCase();
    if (!/^[a-f0-9]{64}$/.test(normalizedSignature)) {
      throw new HttpError(401, 'Invalid tip webhook signature.');
    }
    const hmacMatch = constantTimeEqual(
      normalizedSignature,
      expectedHmac.toLowerCase(),
    );
    if (!hmacMatch) {
      throw new HttpError(401, 'Invalid tip webhook signature.');
    }
  }

  const tipId = stringField(body, 'tipId').trim();
  if (!tipId) {
    throw new HttpError(400, 'tipId is required');
  }

  const payloadHash = await sha256Hex(rawBody.trim() || JSON.stringify(body));
  const webhookEventId = normalizeTipWebhookEventId(body, tipId, payloadHash);
  const statusRaw = stringField(body, 'status').trim().toLowerCase();
  const normalizedStatus = normalizeTipStatus(statusRaw);
  const now = new Date().toISOString();
  const anonymous = booleanField(body, 'anonymous');
  const senderNameInput = stringField(body, 'senderName').trim();
  const senderName = anonymous
    ? 'Anonymous supporter'
    : senderNameInput || 'Supporter';
  const senderEmail = stringField(body, 'senderEmail').trim().toLowerCase();

  if (webhookEventId) {
    const webhookEventPath = `tip_webhook_events/${webhookEventId}`;
    const existingWebhookEvent = await firestoreGet(env, webhookEventPath);
    if (existingWebhookEvent) {
      return jsonResponse(
        { ok: true, tipId, duplicate: true, eventId: webhookEventId },
        corsHeaders,
      );
    }
    try {
      await firestoreCreate(env, webhookEventPath, {
        id: webhookEventId,
        tipId,
        status: 'processing',
        provider: 'maxit_qr',
        providerStatus: statusRaw || null,
        normalizedStatus,
        payloadHash,
        signaturePresent: providedSignature.length > 0,
        receivedAt: now,
        updatedAt: now,
      });
    } catch (error) {
      if (error instanceof HttpError && error.status === 409) {
        return jsonResponse(
          { ok: true, tipId, duplicate: true, eventId: webhookEventId },
          corsHeaders,
        );
      }
      throw error;
    }
  }

  const existing = await firestoreGet(env, `tips/${tipId}`);
  if (!existing) {
    await firestoreCreate(env, `tips/${tipId}`, {
      id: tipId,
      provider: 'maxit_qr',
      status: normalizedStatus,
      amount: Math.max(0, Math.trunc(numberField(body, 'amount'))),
      currency: stringField(body, 'currency').trim().toUpperCase() || 'XAF',
      senderName,
      senderEmail: senderEmail || null,
      anonymous,
      providerStatus: statusRaw || null,
      providerReference: stringField(body, 'reference').trim() || null,
      createdAt: now,
      updatedAt: now,
    });
  } else {
    await firestorePatch(
      env,
      `tips/${tipId}`,
      {
        status: normalizedStatus,
        providerStatus: statusRaw || null,
        providerReference: stringField(body, 'reference').trim() || null,
        updatedAt: now,
      },
      ['status', 'providerStatus', 'providerReference', 'updatedAt'],
    );
  }

  await firestoreCreate(env, `tip_events/${crypto.randomUUID()}`, {
    tipId,
    provider: 'maxit_qr',
    status: normalizedStatus,
    payload: body,
    createdAt: now,
  });

  if (normalizedStatus === 'success') {
    const fresh = await firestoreGet(env, `tips/${tipId}`);
    if (fresh) {
      const userId = docString(fresh, 'userId');
      const userRole = docString(fresh, 'userRole') || 'public';
      const amount = Number(docInt(fresh, 'amount') || 0);
      const currency = docString(fresh, 'currency') || 'XAF';
      const anonymous = docBool(fresh, 'anonymous') === true;
      const senderName = anonymous
        ? 'Anonymous supporter'
        : docString(fresh, 'senderName') || 'Supporter';
      if (userId) {
        await createUserNotification(
          env,
          {
            id: `tip_success_${tipId}`,
            userId,
            audience: roleToAudience(userRole),
            category: roleToAudience(userRole),
            type: 'tip',
            title: 'Tip received',
            body: buildTipThankYouMessage(senderName, amount, currency, {
              anonymous,
            }),
            route: `/support/tip?tipId=${encodeURIComponent(tipId)}`,
            read: false,
            createdAt: now,
            updatedAt: now,
            source: 'tip',
            sourceId: tipId,
          },
          true,
        );
      }
      await notifyAdmins(
        env,
        {
          idPrefix: `tip_received_${tipId}`,
          category: 'tip',
          title: 'New tip confirmed',
          body: `${formatTipAmount(amount, currency)} received via Orange Money Max It (QR).`,
          route: `/support/tip?tipId=${encodeURIComponent(tipId)}`,
          source: 'tip',
          sourceId: tipId,
        },
        now,
      );
    }
  }

  if (webhookEventId) {
    await firestorePatch(
      env,
      `tip_webhook_events/${webhookEventId}`,
      {
        status: 'processed',
        providerStatus: statusRaw || null,
        normalizedStatus,
        updatedAt: now,
      },
      ['status', 'providerStatus', 'normalizedStatus', 'updatedAt'],
    );
  }

  return jsonResponse({ ok: true, tipId, eventId: webhookEventId || null }, corsHeaders);
}

async function handleStorageUpload(
  request: Request,
  env: Env,
  corsHeaders: Headers,
  url: URL,
): Promise<Response> {
  const { uid, role } = await requireAuthWithRole(request, env);
  const body = await readJson(request);
  const pathRaw = stringField(body, 'path').replace(/^\/+/, '');
  const contentBase64 = stringField(body, 'contentBase64');
  const contentTypeInput = stringField(body, 'contentType') || 'application/octet-stream';
  const contentType = contentTypeInput.split(';')[0]?.trim().toLowerCase() || 'application/octet-stream';

  if (!pathRaw) {
    throw new HttpError(400, 'path is required');
  }
  if (!contentBase64) {
    throw new HttpError(400, 'contentBase64 is required');
  }

  const maxBytes = parseIntEnv(
    env.STORAGE_UPLOAD_MAX_BYTES,
    STORAGE_DEFAULT_MAX_UPLOAD_BYTES,
    64 * 1024,
    50 * 1024 * 1024,
  );
  const estimatedBytes = base64ByteLength(contentBase64);
  if (estimatedBytes > maxBytes) {
    throw new HttpError(413, 'Upload is too large.');
  }
  if (!STORAGE_ALLOWED_CONTENT_TYPES.has(contentType)) {
    throw new HttpError(400, 'Unsupported content type.');
  }

  const storagePath = parseStoragePath(pathRaw);
  enforceStorageWrite(storagePath, uid, role);

  const bytes = base64ToBytes(contentBase64);
  await putObjectWithMetadata(env.R2_PRIMARY, storagePath.key, bytes, contentType, {
    ownerUid: storagePath.ownerUid || uid,
    category: storagePath.category,
    uploadedBy: uid,
  });

  await replicateToBackup(env, storagePath, bytes, contentType);

  const downloadUrl = await buildStorageSignedUrl(
    env,
    url,
    storagePath,
    storagePath.category === 'public' ? undefined : uid,
  );

  return jsonResponse({ ok: true, path: storagePath.key, downloadUrl }, corsHeaders);
}

async function handleStorageFile(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const url = new URL(request.url);
  const pathParam = url.searchParams.get('path') || '';
  if (!pathParam) {
    throw new HttpError(400, 'path is required');
  }

  const storagePath = parseStoragePath(pathParam);
  const authUser = await maybeAuthWithRole(request, env);
  const now = Math.floor(Date.now() / 1000);
  let authorized = storagePath.category === 'public';

  if (!authorized && authUser) {
    if (authUser.role === 'admin' || storagePath.ownerUid === authUser.uid) {
      authorized = true;
    }
  }

  if (!authorized) {
    const sig = url.searchParams.get('sig') || '';
    const uid = url.searchParams.get('uid') || '';
    const exp = Number(url.searchParams.get('exp') || '0');
    if (sig && uid && exp > now) {
      const valid = await verifyStorageSignature(env, storagePath, uid, exp, sig);
      if (valid && (!storagePath.ownerUid || storagePath.ownerUid === uid)) {
        authorized = true;
      }
    }
  }

  if (!authorized) {
    throw new HttpError(403, 'Not authorized to read object.');
  }

  const object = await getObjectWithFailover(env, storagePath.key);
  if (!object) {
    throw new HttpError(404, 'File not found.');
  }

  const headers = new Headers(corsHeaders);
  const meta = object.httpMetadata || {};
  if (meta.contentType) headers.set('Content-Type', meta.contentType);
  if (meta.contentDisposition) headers.set('Content-Disposition', meta.contentDisposition);
  headers.set(
    'Cache-Control',
    storagePath.category === 'public' ? 'public, max-age=86400' : 'private, max-age=3600',
  );

  return new Response(object.body, { status: 200, headers });
}

function buildVoteMessage({
  nonce,
  uid,
  electionId,
  candidateId,
  deviceHash,
}: {
  nonce: string;
  uid: string;
  electionId: string;
  candidateId: string;
  deviceHash: string;
}): string {
  return `${nonce}|${uid}|${electionId}|${candidateId}|${deviceHash}`;
}

function buildCorsHeaders(origin: string, env: Env): Headers {
  const headers = new Headers();
  const allowed = (env.ALLOWED_ORIGINS || '*').split(',').map((item) => item.trim());
  const allowAnyOrigin = allowed.includes('*');
  const allowOrigin = allowAnyOrigin
    ? origin === '*' ? '*' : origin
    : allowed.includes(origin)
      ? origin
      : allowed[0] || '*';
  headers.set('Access-Control-Allow-Origin', allowOrigin);
  headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  headers.set(
    'Access-Control-Allow-Headers',
    'Authorization, Content-Type, X-Tip-QR-Signature',
  );
  headers.set('Access-Control-Max-Age', '86400');
  headers.set('Vary', 'Origin');
  headers.set('X-Content-Type-Options', 'nosniff');
  headers.set('Referrer-Policy', 'no-referrer');
  return headers;
}

function jsonResponse(body: JsonObject, headers: Headers, status = 200): Response {
  const merged = new Headers(headers);
  merged.set('Content-Type', 'application/json');
  return new Response(JSON.stringify(body), { status, headers: merged });
}

async function readJson(request: Request): Promise<JsonObject> {
  const parsed = await readJsonWithRaw(request);
  return parsed.body;
}

async function readJsonWithRaw(
  request: Request,
): Promise<{ raw: string; body: JsonObject }> {
  const raw = await request.text();
  const body = parseJsonBodyFromText(
    raw,
    request.headers.get('Content-Type') || '',
  );
  return { raw, body };
}

function parseJsonBodyFromText(raw: string, contentTypeRaw: string): JsonObject {
  if (!raw.trim()) {
    return {};
  }

  try {
    return JSON.parse(raw) as JsonObject;
  } catch {
    const contentType = contentTypeRaw.toLowerCase();
    if (contentType.includes('application/x-www-form-urlencoded')) {
      const params = new URLSearchParams(raw);
      const parsed: JsonObject = {};
      for (const [key, value] of params.entries()) {
        parsed[key] = value;
      }
      return parsed;
    }
    throw new HttpError(400, 'Invalid JSON body.');
  }
}

async function requireAuth(request: Request, env: Env): Promise<{ uid: string }> {
  const auth = request.headers.get('Authorization') || '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : auth;
  if (!token) {
    throw new HttpError(401, 'Missing Authorization token.');
  }
  const user = await firebaseLookup(env, token);
  if (!user) {
    throw new HttpError(401, 'Invalid authentication token.');
  }
  return { uid: user.localId };
}

async function requireAuthWithRole(
  request: Request,
  env: Env,
): Promise<{ uid: string; role: string }> {
  const { uid } = await requireAuth(request, env);
  const role = await getUserRole(env, uid);
  return { uid, role };
}

async function requireAdmin(
  request: Request,
  env: Env,
): Promise<{ uid: string; role: string }> {
  const user = await requireAuthWithRole(request, env);
  if (user.role != 'admin') {
    throw new HttpError(403, 'Admin role required.');
  }
  return user;
}

async function maybeAuthWithRole(
  request: Request,
  env: Env,
): Promise<{ uid: string; role: string } | null> {
  const authHeader = request.headers.get('Authorization') || '';
  if (!authHeader) return null;
  try {
    return await requireAuthWithRole(request, env);
  } catch {
    return null;
  }
}

async function getUserRole(env: Env, uid: string): Promise<string> {
  const doc = await ensureUserDoc(env, uid);
  return docString(doc, 'role') || 'public';
}

async function firebaseLookup(env: Env, idToken: string): Promise<{ localId: string } | null> {
  const response = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${env.FIREBASE_API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ idToken }),
    },
  );
  if (!response.ok) {
    return null;
  }
  const data = (await response.json()) as { users?: Array<{ localId: string }> };
  return data.users?.[0] ?? null;
}

async function firebaseCreateUserAccount(
  env: Env,
  email: string,
  password: string,
): Promise<{ localId: string }> {
  const response = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${env.FIREBASE_API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email,
        password,
        returnSecureToken: false,
      }),
    },
  );

  if (!response.ok) {
    let code = 'AUTH_CREATE_FAILED';
    let message = 'Unable to create observer account.';
    try {
      const data = (await response.json()) as {
        error?: { message?: string };
      };
      const apiMessage = `${data.error?.message ?? ''}`.trim().toUpperCase();
      if (apiMessage) {
        code = apiMessage;
      }
      if (apiMessage.includes('EMAIL_EXISTS')) {
        throw new HttpError(409, 'Email already exists.', 'EMAIL_EXISTS');
      }
      if (apiMessage.includes('WEAK_PASSWORD')) {
        throw new HttpError(
          400,
          'Temporary password is too weak.',
          'WEAK_PASSWORD',
        );
      }
    } catch (error) {
      if (error instanceof HttpError) {
        throw error;
      }
      // Ignore parse errors and use fallback response below.
    }
    throw new HttpError(502, message, code);
  }

  const data = (await response.json()) as { localId?: string };
  const localId = `${data.localId ?? ''}`.trim();
  if (!localId) {
    throw new HttpError(502, 'Firebase did not return a user id.');
  }
  return { localId };
}

async function ensureUserDoc(
  env: Env,
  uid: string,
  opts?: { email?: string; fullName?: string },
): Promise<FirestoreDoc> {
  const existing = await firestoreGet(env, `users/${uid}`);
  if (existing) {
    return existing;
  }
  const now = new Date().toISOString();
  await firestoreCreate(env, `users/${uid}`, {
    uid,
    email: opts?.email || null,
    fullName: opts?.fullName || '',
    role: 'public',
    verified: false,
    status: 'public',
    createdAt: now,
    updatedAt: now,
  });
  const fresh = await firestoreGet(env, `users/${uid}`);
  if (!fresh) {
    throw new HttpError(500, 'Failed to bootstrap user profile.');
  }
  return fresh;
}

async function requireUserDoc(env: Env, uid: string): Promise<FirestoreDoc> {
  return ensureUserDoc(env, uid);
}

async function findUserByIdentifier(
  env: Env,
  identifier: string,
): Promise<FirestoreDoc | null> {
  const trimmed = identifier.trim();
  if (!trimmed) return null;
  if (trimmed.includes('@')) {
    const docs = await firestoreRunQuery(env, {
      from: [{ collectionId: 'users' }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'email' },
          op: 'EQUAL',
          value: { stringValue: trimmed },
        },
      },
      limit: 1,
    });
    return docs[0] ?? null;
  }
  const byUid = await firestoreGet(env, `users/${trimmed}`);
  if (byUid) return byUid;
  const byUsername = await firestoreRunQuery(env, {
    from: [{ collectionId: 'users' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'username' },
        op: 'EQUAL',
        value: { stringValue: trimmed },
      },
    },
    limit: 1,
  });
  return byUsername[0] ?? null;
}

function enforceVoterStatus(userDoc: FirestoreDoc): void {
  const role = docString(userDoc, 'role');
  if (role && role !== 'voter') {
    throw new HttpError(403, 'User is not allowed to vote.');
  }
  const verified = docBool(userDoc, 'verified');
  if (verified === false) {
    throw new HttpError(403, 'User not verified.');
  }
  const status = docString(userDoc, 'status');
  if (status && ['archived', 'suspended', 'deceased', 'banned'].includes(status)) {
    throw new HttpError(403, 'User status does not allow voting.');
  }
  const cardExpiry = docString(userDoc, 'cardExpiry');
  if (cardExpiry && Date.parse(cardExpiry) < Date.now()) {
    throw new HttpError(403, 'Electoral card expired.');
  }
}

function isElectionOpen(doc: FirestoreDoc): boolean {
  const status = docString(doc, 'status');
  if (status) {
    if (['open', 'live', 'active'].includes(status)) {
      return true;
    }
    if (['closed', 'archived', 'draft'].includes(status)) {
      return false;
    }
  }
  const opensAt = docString(doc, 'opensAt');
  const closesAt = docString(doc, 'closesAt');
  const now = Date.now();
  if (opensAt && closesAt) {
    return now >= Date.parse(opensAt) && now <= Date.parse(closesAt);
  }
  return false;
}

function parseStoragePath(path: string): StoragePath {
  const cleaned = path.replace(/^\/+/, '').replace(/\\/g, '/');
  const parts = cleaned.split('/').filter(Boolean);
  if (parts.length < 2) {
    throw new HttpError(400, 'Invalid storage path.');
  }

  const category = parts[0];
  if (
    category !== 'public' &&
    category !== 'registration_docs' &&
    category !== 'incident_attachments' &&
    category !== 'tip_receipts'
  ) {
    throw new HttpError(400, 'Unsupported storage category.');
  }

  if (category === 'public') {
    return { key: cleaned, category: 'public' };
  }

  if (parts.length < 3) {
    throw new HttpError(400, `${category} objects must include uid and filename.`);
  }

  return { key: cleaned, category: category as StorageCategory, ownerUid: parts[1] };
}

function enforceStorageWrite(path: StoragePath, uid: string, role: string): void {
  if (path.category === 'public') {
    if (role !== 'admin') {
      throw new HttpError(403, 'Admin role required to write public storage.');
    }
    return;
  }

  if (role === 'admin') return;
  if (path.ownerUid !== uid) {
    throw new HttpError(403, 'You can only write to your own storage scope.');
  }
}

async function verifyStorageSignature(
  env: Env,
  path: StoragePath,
  uid: string,
  exp: number,
  sig: string,
): Promise<boolean> {
  if (exp <= Math.floor(Date.now() / 1000)) return false;
  const payload = storageSignaturePayload(path, uid, exp);
  const expected = await hmacSha256Hex(env.STORAGE_SIGNING_SECRET, payload);
  return constantTimeEqual(expected, sig);
}

async function buildStorageSignedUrl(
  env: Env,
  baseUrl: URL,
  path: StoragePath,
  uid?: string,
  ttlSeconds = SIGNED_URL_TTL_SECONDS,
): Promise<string> {
  const exp = Math.floor(Date.now() / 1000) + ttlSeconds;
  const subjectUid = path.category === 'public' ? 'public' : uid || path.ownerUid || 'owner';
  const payload = storageSignaturePayload(path, subjectUid, exp);
  const sig = await hmacSha256Hex(env.STORAGE_SIGNING_SECRET, payload);
  const params = new URLSearchParams({
    path: path.key,
    exp: exp.toString(10),
    sig,
  });
  if (path.category !== 'public') {
    params.set('uid', subjectUid);
  }
  return `${baseUrl.origin}/v1/storage/file?${params.toString()}`;
}

function storageSignaturePayload(path: StoragePath, uid: string, exp: number): string {
  return `${path.key}|${uid}|${exp}`;
}

async function getObjectWithFailover(env: Env, key: string): Promise<R2ObjectBody | null> {
  const primary = await env.R2_PRIMARY.get(key);
  if (primary) return primary;
  if (env.R2_BACKUP) {
    const fallback = await env.R2_BACKUP.get(key);
    if (fallback) return fallback;
  }
  return null;
}

async function replicateToBackup(
  env: Env,
  path: StoragePath,
  bytes: Uint8Array,
  contentType: string,
): Promise<void> {
  if (!env.R2_BACKUP) return;
  try {
    await putObjectWithMetadata(env.R2_BACKUP, path.key, bytes, contentType, {
      ownerUid: path.ownerUid || '',
      category: path.category,
      replicatedFrom: 'primary',
    });
  } catch (error) {
    console.error('Backup replication failed', (error as Error).message);
  }
}

async function putObjectWithMetadata(
  bucket: R2Bucket,
  key: string,
  bytes: Uint8Array,
  contentType: string,
  meta: Record<string, string>,
): Promise<void> {
  await bucket.put(key, bytes, {
    httpMetadata: { contentType },
    customMetadata: meta,
  });
}

async function verifySignature(
  publicKeyBase64: string,
  message: string,
  signatureBase64: string,
): Promise<boolean> {
  const keyBytes = base64ToBytes(publicKeyBase64);
  const signatureBytes = base64ToBytes(signatureBase64);

  const key = await crypto.subtle.importKey(
    'raw',
    keyBytes,
    { name: 'ECDSA', namedCurve: 'P-256' },
    false,
    ['verify'],
  );

  const payload = textEncoder.encode(message);
  const verifyWith = (sig: Uint8Array) =>
    crypto.subtle.verify({ name: 'ECDSA', hash: 'SHA-256' }, key, sig, payload);

  if (signatureBytes.length === 64) {
    if (await verifyWith(signatureBytes)) return true;
    return verifyWith(rawSigToDer(signatureBytes));
  }

  if (await verifyWith(signatureBytes)) return true;
  const raw = derSigToRaw(signatureBytes);
  if (raw) {
    return verifyWith(raw);
  }
  return false;
}

function rawSigToDer(raw: Uint8Array): Uint8Array {
  const r = raw.slice(0, 32);
  const s = raw.slice(32);
  const rEnc = derEncodeInt(r);
  const sEnc = derEncodeInt(s);
  const length = rEnc.length + sEnc.length;
  return Uint8Array.from([0x30, length, ...rEnc, ...sEnc]);
}

function derEncodeInt(bytes: Uint8Array): number[] {
  let trimmed = trimLeadingZeros(bytes);
  if (trimmed.length === 0) {
    trimmed = new Uint8Array([0]);
  }
  if (trimmed[0] & 0x80) {
    trimmed = Uint8Array.from([0x00, ...trimmed]);
  }
  return [0x02, trimmed.length, ...Array.from(trimmed)];
}

function trimLeadingZeros(bytes: Uint8Array): Uint8Array {
  let start = 0;
  while (start < bytes.length && bytes[start] === 0) {
    start += 1;
  }
  return bytes.slice(start);
}

function derSigToRaw(der: Uint8Array): Uint8Array | null {
  if (der.length < 8 || der[0] !== 0x30) return null;
  let offset = 1;
  let length = der[offset++];
  if (length & 0x80) {
    const count = length & 0x7f;
    length = 0;
    for (let i = 0; i < count; i += 1) {
      length = (length << 8) | der[offset++];
    }
  }
  if (der[offset++] !== 0x02) return null;
  let rLen = der[offset++];
  let r = der.slice(offset, offset + rLen);
  offset += rLen;
  if (der[offset++] !== 0x02) return null;
  let sLen = der[offset++];
  let s = der.slice(offset, offset + sLen);

  if (r.length > 32 && r[0] === 0) r = r.slice(1);
  if (s.length > 32 && s[0] === 0) s = s.slice(1);
  if (r.length > 32 || s.length > 32) return null;

  const out = new Uint8Array(64);
  out.set(r, 32 - r.length);
  out.set(s, 64 - s.length);
  return out;
}

async function updateResults(env: Env, electionId: string, candidateId: string): Promise<void> {
  for (let attempt = 0; attempt < 3; attempt += 1) {
    const doc = await firestoreGet(env, `results/${electionId}`);
    const now = new Date().toISOString();
    if (!doc) {
      await firestoreCreate(env, `results/${electionId}`, {
        electionId,
        totalVotes: 1,
        candidateCounts: { [candidateId]: 1 },
        updatedAt: now,
      });
      return;
    }

    const counts = docMap(doc, 'candidateCounts');
    const current = Number(counts[candidateId] || 0);
    const totalVotes = Number(docInt(doc, 'totalVotes') || 0) + 1;
    counts[candidateId] = current + 1;

    try {
      await firestoreCommit(env, [
        {
          update: {
            name: docName(env, `results/${electionId}`),
            fields: toFirestoreFields({
              totalVotes,
              candidateCounts: counts,
              updatedAt: now,
            }),
          },
          updateMask: { fieldPaths: ['totalVotes', 'candidateCounts', 'updatedAt'] },
          currentDocument: doc.updateTime ? { updateTime: doc.updateTime } : { exists: true },
        },
      ]);
      return;
    } catch (error) {
      const err = error as HttpError;
      if (err.code !== 'FAILED_PRECONDITION') {
        throw err;
      }
    }
  }

  throw new Error('Results update retry exhausted.');
}

async function findExistingRegistration(env: Env, uid: string): Promise<FirestoreDoc | null> {
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'registrations' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'uid' },
        op: 'EQUAL',
        value: { stringValue: uid },
      },
    },
    limit: 1,
  });

  if (docs.length === 0) {
    return null;
  }

  const status = docString(docs[0], 'status');
  if (status && status !== 'rejected') {
    return docs[0];
  }
  return null;
}

async function findDuplicateRegistration(env: Env, docHash: string): Promise<FirestoreDoc | null> {
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'registrations' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'documentNumberHash' },
        op: 'EQUAL',
        value: { stringValue: docHash },
      },
    },
    limit: 1,
  });
  if (docs.length === 0) {
    return null;
  }
  const status = docString(docs[0], 'status');
  if (status && status !== 'rejected') {
    return docs[0];
  }
  return null;
}

async function findDuplicateUser(env: Env, docHash: string): Promise<FirestoreDoc | null> {
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'users' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'documentNumberHash' },
        op: 'EQUAL',
        value: { stringValue: docHash },
      },
    },
    limit: 1,
  });
  return docs[0] ?? null;
}

async function logDeviceRisk(
  env: Env,
  data: { uid: string; deviceHash: string; type: string; severity: string; note: string },
): Promise<void> {
  await firestoreCreate(env, `device_risks/${crypto.randomUUID()}`, {
    ...data,
    createdAt: new Date().toISOString(),
  });
}

function roleToAudience(role: string): string {
  const normalized = role.trim().toLowerCase();
  if (normalized === 'admin') return 'admin';
  if (normalized === 'observer') return 'observer';
  if (normalized === 'voter') return 'voter';
  return 'public';
}

function normalizeNotificationType(value: unknown): string {
  const normalized = `${value ?? ''}`.trim().toLowerCase();
  if (normalized === 'success') return 'success';
  if (normalized === 'warning') return 'warning';
  if (normalized === 'alert') return 'alert';
  if (normalized === 'election') return 'election';
  if (normalized === 'security') return 'security';
  if (normalized === 'support') return 'info';
  if (normalized === 'tip') return 'success';
  return 'info';
}

function normalizeNotificationAudience(value: unknown, fallback: string): string {
  const normalized = `${value ?? ''}`.trim().toLowerCase();
  if (['public', 'voter', 'observer', 'admin', 'all'].includes(normalized)) {
    return normalized;
  }
  return fallback;
}

function normalizeNotificationCategory(
  categoryValue: unknown,
  typeValue: unknown,
  audienceValue: unknown,
): string {
  const normalized = `${categoryValue ?? ''}`.trim().toLowerCase();
  if (['public', 'voter', 'observer', 'admin', 'support', 'tip'].includes(normalized)) {
    return normalized;
  }

  const rawType = `${typeValue ?? ''}`.trim().toLowerCase();
  if (rawType === 'support') return 'support';
  if (rawType === 'tip') return 'tip';

  const type = normalizeNotificationType(typeValue);
  if (type === 'election' || type === 'security') {
    return 'public';
  }

  const audience = normalizeNotificationAudience(audienceValue, 'public');
  if (audience === 'all') return 'public';
  if (audience === 'admin' || audience === 'observer' || audience === 'voter') {
    return audience;
  }
  return 'public';
}

function allowedNotificationCategoriesForRole(roleAudience: string): Set<string> {
  const role = roleToAudience(roleAudience);
  if (role === 'admin') {
    return new Set(['admin', 'support', 'tip']);
  }
  if (role === 'voter') {
    return new Set(['voter', 'public']);
  }
  if (role === 'observer') {
    return new Set(['observer', 'public']);
  }
  return new Set(['public', 'observer']);
}

function computeVoterDemographicsFromDocs(
  docs: FirestoreDoc[],
): {
  total: number;
  deceased: number;
  bands: Array<{ key: string; label: string; count: number; percent: number }>;
  derived: {
    youth: { count: number; percent: number };
    adult: { count: number; percent: number };
    senior: { count: number; percent: number };
  };
} {
  const bands = [
    { key: '18_24', min: 18, max: 24, count: 0 },
    { key: '25_34', min: 25, max: 34, count: 0 },
    { key: '35_44', min: 35, max: 44, count: 0 },
    { key: '45_59', min: 45, max: 59, count: 0 },
    { key: '60_plus', min: 60, max: 200, count: 0 },
  ];

  let total = 0;
  let deceased = 0;

  for (const doc of docs) {
    const role = (docString(doc, 'role') || 'voter').trim().toLowerCase();
    if (role !== 'voter') continue;
    if (docBool(doc, 'verified') !== true) continue;

    const status = (docString(doc, 'status') || '').trim().toLowerCase();
    if (status === 'deceased') {
      deceased += 1;
    }
    if (status && ['archived', 'suspended', 'deceased', 'banned'].includes(status)) {
      continue;
    }

    const dob = docString(doc, 'dob') || docString(doc, 'dateOfBirth');
    const age = computeAgeFromIso(dob);
    if (age === null || age < 18) continue;

    total += 1;
    for (const band of bands) {
      if (age >= band.min && age <= band.max) {
        band.count += 1;
        break;
      }
    }
  }

  const toPercent = (count: number): number => {
    if (total <= 0) return 0;
    return Math.round((count / total) * 10000) / 100;
  };

  const bandPayload = bands.map((band) => ({
    key: band.key,
    label: band.key === '60_plus' ? '60+' : `${band.min}-${band.max}`,
    count: band.count,
    percent: toPercent(band.count),
  }));

  const youthCount = bands[0].count + bands[1].count;
  const adultCount = bands[2].count + bands[3].count;
  const seniorCount = bands[4].count;

  return {
    total,
    deceased,
    bands: bandPayload,
    derived: {
      youth: { count: youthCount, percent: toPercent(youthCount) },
      adult: { count: adultCount, percent: toPercent(adultCount) },
      senior: { count: seniorCount, percent: toPercent(seniorCount) },
    },
  };
}

const TIP_DEFAULT_MIN_AMOUNT = 100;
const TIP_DEFAULT_MAX_AMOUNT = 5_000_000;
const TIP_DEFAULT_SUSPICIOUS_AMOUNT = 250_000;
const TIP_DEFAULT_RATE_LIMIT_WINDOW_SECONDS = 15 * 60;
const TIP_DEFAULT_RATE_LIMIT_MAX_REQUESTS = 10;
const TIP_MAX_MESSAGE_LENGTH = 280;
const TIP_MAX_SOURCE_LENGTH = 64;
const TIP_MAX_NAME_LENGTH = 80;
const TIP_MAX_REFERENCE_LENGTH = 120;
const TIP_MAX_ATTACHMENTS = 5;
const TIP_ALLOWED_CURRENCIES = new Set(['XAF', 'USD', 'EUR']);

type TipIntentPayload = {
  amount: number;
  currency: string;
  anonymous: boolean;
  senderName: string;
  senderEmail: string;
  note: string;
  source: string;
};

function parseTipIntentPayload(body: JsonObject, env: Env): TipIntentPayload {
  const amount = sanitizeTipAmount(
    Math.trunc(numberField(body, 'amount') || numberField(body, 'value')),
    env,
  );
  const currency = normalizeTipCurrency(stringField(body, 'currency'));
  const anonymous = booleanField(body, 'anonymous');
  const senderNameInput = sanitizePlainText(
    pickString(body, ['senderName', 'name']),
    TIP_MAX_NAME_LENGTH,
  );
  const senderName = anonymous
    ? 'Anonymous supporter'
    : senderNameInput || 'Supporter';
  const senderEmail = pickString(body, ['senderEmail', 'email']).trim().toLowerCase();
  if (senderEmail && !isValidEmail(senderEmail)) {
    throw new HttpError(400, 'senderEmail is invalid.');
  }

  return {
    amount,
    currency,
    anonymous,
    senderName,
    senderEmail,
    note: sanitizeTipNote(pickString(body, ['message', 'note'])),
    source: normalizeTipSource(stringField(body, 'source')),
  };
}

function sanitizeTipAmount(value: number, env: Env): number {
  if (!Number.isFinite(value)) {
    throw new HttpError(400, 'amount must be a valid number.');
  }
  const minAmount = parseIntEnv(
    env.TIP_MIN_AMOUNT,
    TIP_DEFAULT_MIN_AMOUNT,
    1,
    100_000_000,
  );
  const maxAmount = parseIntEnv(
    env.TIP_MAX_AMOUNT,
    Math.max(minAmount, TIP_DEFAULT_MAX_AMOUNT),
    minAmount,
    2_000_000_000,
  );
  const normalized = Math.trunc(value);
  if (normalized < minAmount || normalized > maxAmount) {
    throw new HttpError(
      400,
      `amount must be between ${minAmount} and ${maxAmount}.`,
    );
  }
  return normalized;
}

function normalizeTipCurrency(value: string): string {
  const normalized = value.trim().toUpperCase() || 'XAF';
  if (!TIP_ALLOWED_CURRENCIES.has(normalized)) {
    throw new HttpError(400, 'Unsupported tip currency.');
  }
  return normalized;
}

function normalizeTipSource(value: string): string {
  const cleaned = sanitizePlainText(value, TIP_MAX_SOURCE_LENGTH).toLowerCase();
  if (!cleaned) return 'camvote_app';
  const normalized = cleaned
    .replace(/[^a-z0-9_-]+/g, '_')
    .replace(/_+/g, '_')
    .replace(/^_+|_+$/g, '');
  return normalized || 'camvote_app';
}

function sanitizeTipNote(value: string): string {
  return sanitizePlainText(value, TIP_MAX_MESSAGE_LENGTH);
}

function normalizeTipReference(value: string): string {
  return sanitizePlainText(value, TIP_MAX_REFERENCE_LENGTH).toUpperCase();
}

function normalizeTipAttachments(values: string[]): string[] {
  const normalized: string[] = [];
  const seen = new Set<string>();

  for (const value of values) {
    const trimmed = value.trim();
    if (!trimmed) continue;
    if (trimmed.length > 2048) {
      throw new HttpError(400, 'Attachment URL is too long.');
    }
    let parsed: URL;
    try {
      parsed = new URL(trimmed);
    } catch {
      throw new HttpError(400, 'Attachment URL is invalid.');
    }
    const protocol = parsed.protocol.toLowerCase();
    const isLocalhost = parsed.hostname === 'localhost' || parsed.hostname === '127.0.0.1';
    if (protocol !== 'https:' && !(protocol === 'http:' && isLocalhost)) {
      throw new HttpError(400, 'Attachment URL must use HTTPS.');
    }
    const key = parsed.toString();
    if (seen.has(key)) continue;
    seen.add(key);
    normalized.push(key);
    if (normalized.length > TIP_MAX_ATTACHMENTS) {
      throw new HttpError(
        400,
        `Maximum ${TIP_MAX_ATTACHMENTS} attachments are allowed.`,
      );
    }
  }

  return normalized;
}

function sanitizePlainText(value: string, maxLength: number): string {
  const stripped = value
    .replace(/[\u0000-\u001f\u007f]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  if (stripped.length <= maxLength) return stripped;
  return stripped.slice(0, maxLength).trim();
}

function parseIntEnv(
  raw: string | undefined,
  fallback: number,
  minValue: number,
  maxValue: number,
): number {
  const parsed = Number(`${raw ?? ''}`.trim());
  if (!Number.isFinite(parsed)) return fallback;
  const normalized = Math.trunc(parsed);
  return Math.min(maxValue, Math.max(minValue, normalized));
}

type RateLimitAuth = { uid: string; role?: string } | null;

function resolveRateLimitRequesterSeed(request: Request, auth: RateLimitAuth): string {
  if (auth?.uid) {
    return `uid:${auth.uid}`;
  }
  const cfIp = (request.headers.get('CF-Connecting-IP') || '').trim();
  if (cfIp) {
    return `ip:${cfIp}`;
  }
  const forwarded = (request.headers.get('X-Forwarded-For') || '')
    .split(',')[0]
    ?.trim();
  if (forwarded) {
    return `ip:${forwarded}`;
  }
  const userAgent = sanitizePlainText(request.headers.get('User-Agent') || '', 160);
  if (userAgent) {
    return `ua:${userAgent}`;
  }
  return 'anonymous';
}

async function enforceRateLimit(params: {
  request: Request;
  env: Env;
  namespace: string;
  key: string;
  auth: RateLimitAuth;
  windowSeconds: number;
  maxRequests: number;
  message: string;
}): Promise<void> {
  const { request, env, namespace, key, auth, windowSeconds, maxRequests, message } = params;
  const requesterSeed = resolveRateLimitRequesterSeed(request, auth);
  const requesterHash = (await sha256Hex(`${namespace}|${key}|${requesterSeed}`)).slice(0, 48);
  const docId = `${namespace}_${requesterHash}`;
  const nowEpoch = Math.floor(Date.now() / 1000);
  const nowIso = new Date().toISOString();
  const path = `rate_limits/${docId}`;

  const existing = await firestoreGet(env, path);
  const existingWindowEnd = existing ? docInt(existing, 'windowEnd') : null;
  const existingWindowStart = existing ? docInt(existing, 'windowStart') : null;
  const existingCount = existing ? Number(docInt(existing, 'count') || 0) : 0;
  const inWindow =
    existingWindowStart !== null &&
    existingWindowEnd !== null &&
    nowEpoch >= existingWindowStart &&
    nowEpoch <= existingWindowEnd;

  const count = inWindow ? existingCount + 1 : 1;
  const windowStart = inWindow ? existingWindowStart! : nowEpoch;
  const windowEnd = inWindow ? existingWindowEnd! : nowEpoch + windowSeconds;

  const payload = {
    namespace,
    key,
    requesterHash,
    requesterType: auth?.uid ? 'auth_user' : 'anonymous',
    count,
    windowStart,
    windowEnd,
    lastAttemptAt: nowIso,
    updatedAt: nowIso,
    ...(existing ? {} : { createdAt: nowIso }),
  };
  if (existing) {
    await firestorePatch(env, path, payload, Object.keys(payload));
  } else {
    await firestoreCreate(env, path, payload);
  }

  if (count > maxRequests) {
    throw new HttpError(429, message);
  }
}

async function enforceTipIntentRateLimit(params: {
  request: Request;
  env: Env;
  auth: { uid: string; role: string } | null;
  provider: string;
  amount: number;
  currency: string;
}): Promise<void> {
  const { request, env, auth, provider, amount, currency } = params;
  const windowSeconds = parseIntEnv(
    env.TIP_RATE_LIMIT_WINDOW_SECONDS,
    TIP_DEFAULT_RATE_LIMIT_WINDOW_SECONDS,
    30,
    24 * 60 * 60,
  );
  const maxRequests = parseIntEnv(
    env.TIP_RATE_LIMIT_MAX_REQUESTS,
    TIP_DEFAULT_RATE_LIMIT_MAX_REQUESTS,
    1,
    200,
  );
  const suspiciousAmount = parseIntEnv(
    env.TIP_SUSPICIOUS_AMOUNT,
    TIP_DEFAULT_SUSPICIOUS_AMOUNT,
    1,
    2_000_000_000,
  );

  const requesterSeed = resolveTipRequesterSeed(request, auth);
  const requesterHash = (await sha256Hex(`${provider}|${requesterSeed}`)).slice(
    0,
    48,
  );
  const docId = `${provider}_${requesterHash}`;
  const nowEpoch = Math.floor(Date.now() / 1000);
  const nowIso = new Date().toISOString();
  const limitPath = `tip_rate_limits/${docId}`;
  const existing = await firestoreGet(env, limitPath);
  const existingWindowEnd = existing ? docInt(existing, 'windowEnd') : null;
  const existingWindowStart = existing ? docInt(existing, 'windowStart') : null;
  const existingCount = existing ? Number(docInt(existing, 'count') || 0) : 0;
  const inExistingWindow =
    existingWindowStart !== null &&
    existingWindowEnd !== null &&
    nowEpoch >= existingWindowStart &&
    nowEpoch <= existingWindowEnd;

  const count = inExistingWindow ? existingCount + 1 : 1;
  const windowStart = inExistingWindow ? existingWindowStart! : nowEpoch;
  const windowEnd = inExistingWindow
    ? existingWindowEnd!
    : nowEpoch + windowSeconds;

  const payload = {
    provider,
    requesterHash,
    requesterType: auth?.uid ? 'auth_user' : 'anonymous',
    count,
    windowStart,
    windowEnd,
    lastAmount: amount,
    lastCurrency: currency,
    lastAttemptAt: nowIso,
    updatedAt: nowIso,
    ...(existing ? {} : { createdAt: nowIso }),
  };
  if (existing) {
    await firestorePatch(env, limitPath, payload, Object.keys(payload));
  } else {
    await firestoreCreate(env, limitPath, payload);
  }

  if (count > maxRequests) {
    await firestoreCreate(env, `tip_events/${crypto.randomUUID()}`, {
      action: 'rate_limited',
      provider,
      requesterHash,
      count,
      maxRequests,
      windowSeconds,
      amount,
      currency,
      createdAt: nowIso,
    });
    throw new HttpError(429, 'Too many tip requests. Please wait and try again.');
  }

  if (amount >= suspiciousAmount) {
    await firestoreCreate(env, `tip_events/${crypto.randomUUID()}`, {
      action: 'suspicious_amount',
      provider,
      requesterHash,
      amount,
      currency,
      threshold: suspiciousAmount,
      createdAt: nowIso,
    });
  }
}

function resolveTipRequesterSeed(
  request: Request,
  auth: { uid: string; role: string } | null,
): string {
  if (auth?.uid) {
    return `uid:${auth.uid}`;
  }
  const cfIp = (request.headers.get('CF-Connecting-IP') || '').trim();
  if (cfIp) {
    return `ip:${cfIp}`;
  }
  const forwarded = (request.headers.get('X-Forwarded-For') || '')
    .split(',')[0]
    ?.trim();
  if (forwarded) {
    return `ip:${forwarded}`;
  }
  const userAgent = sanitizePlainText(
    request.headers.get('User-Agent') || '',
    160,
  );
  if (userAgent) {
    return `ua:${userAgent}`;
  }
  return 'anonymous';
}

async function findTipIdByProviderReference(
  env: Env,
  reference: string,
): Promise<string> {
  const docs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'tips' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'providerReference' },
        op: 'EQUAL',
        value: { stringValue: reference },
      },
    },
    limit: 1,
  });
  const tip = docs[0];
  return tip ? tip.name.split('/').pop() || '' : '';
}

function normalizeTipStatus(statusRaw: string): string {
  const normalized = statusRaw.trim().toLowerCase();
  if (
    normalized === 'success' ||
    normalized === 'successful' ||
    normalized === 'completed' ||
    normalized === 'settled' ||
    normalized === 'accepted' ||
    normalized === 'delivered'
  ) {
    return 'success';
  }
  if (
    normalized === 'failed' ||
    normalized === 'cancelled' ||
    normalized === 'canceled' ||
    normalized === 'rejected' ||
    normalized === 'error'
  ) {
    return 'failed';
  }
  return 'pending';
}

function normalizeTipWebhookEventId(
  body: JsonObject,
  tipId: string,
  payloadHash: string,
): string {
  const explicitEventId = sanitizePlainText(
    pickString(body, ['eventId', 'event_id', 'webhookEventId', 'id']),
    120,
  ).toLowerCase();
  if (explicitEventId) {
    return explicitEventId;
  }

  const reference = normalizeTipReference(
    pickString(body, ['reference', 'providerReference', 'txRef', 'transactionId']),
  ).toLowerCase();
  if (reference) {
    return `tip_${tipId.trim().toLowerCase()}_${reference}`;
  }

  return `tip_${tipId.trim().toLowerCase()}_${payloadHash.slice(0, 24)}`;
}

function toSafeInt(value: unknown): number {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return Math.trunc(value);
  }
  const parsed = Number(`${value ?? ''}`.trim());
  return Number.isFinite(parsed) ? Math.trunc(parsed) : 0;
}

function formatTipAmount(amount: number, currency: string): string {
  const normalizedAmount = Number.isFinite(amount) ? Math.max(0, amount) : 0;
  const normalizedCurrency = currency.trim().toUpperCase() || 'XAF';
  try {
    const formatter = new Intl.NumberFormat('en', {
      style: 'currency',
      currency: normalizedCurrency,
      maximumFractionDigits: normalizedCurrency === 'XAF' ? 0 : 2,
    });
    return formatter.format(normalizedAmount);
  } catch {
    const rounded =
      normalizedCurrency === 'XAF'
        ? Math.trunc(normalizedAmount)
        : Number(normalizedAmount.toFixed(2));
    return `${rounded.toLocaleString()} ${normalizedCurrency}`;
  }
}

function buildTipThankYouMessage(
  senderName: string,
  amount: number,
  currency: string,
  options: { anonymous?: boolean } = {},
): string {
  const anonymous = options.anonymous === true;
  const name = senderName.trim();
  const supporterName = anonymous || !name ? 'Supporter' : name;
  const money = formatTipAmount(amount, currency);
  const intro = anonymous
    ? 'Thank you for your anonymous support!'
    : `Thank you ${supporterName}!`;
  return `${intro} We received your tip of ${money}. Your support keeps CamVote secure, transparent, and improving every day.`;
}

async function createUserNotification(
  env: Env,
  payload: JsonObject,
  overwrite = false,
): Promise<void> {
  const normalizedPayload: JsonObject = {
    ...payload,
    type: normalizeNotificationType(payload['type']),
    audience: normalizeNotificationAudience(payload['audience'], 'public'),
    category: normalizeNotificationCategory(
      payload['category'],
      payload['type'],
      payload['audience'],
    ),
  };
  const id = stringField(normalizedPayload, 'id').trim();
  const userId = stringField(normalizedPayload, 'userId').trim();
  if (!id || !userId) return;

  const path = `user_notifications/${id}`;
  const existing = await firestoreGet(env, path);
  if (existing && !overwrite) return;

  if (existing) {
    await firestorePatch(env, path, normalizedPayload, Object.keys(normalizedPayload));
  } else {
    await firestoreCreate(env, path, normalizedPayload);
  }
}

async function notifyAdmins(
  env: Env,
  payload: {
    idPrefix: string;
    title: string;
    body: string;
    category?: string;
    type?: string;
    route?: string;
    source?: string;
    sourceId?: string;
  },
  now = new Date().toISOString(),
): Promise<void> {
  const adminDocs = await firestoreRunQuery(env, {
    from: [{ collectionId: 'users' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'role' },
        op: 'EQUAL',
        value: { stringValue: 'admin' },
      },
    },
    limit: 250,
  });
  if (adminDocs.length === 0) return;

  const category = normalizeNotificationCategory(
    payload.category,
    payload.type || payload.category || 'info',
    'admin',
  );
  const type =
    payload.type?.trim().toLowerCase() ||
    (category === 'tip' ? 'tip' : category === 'support' ? 'support' : 'info');

  for (const adminDoc of adminDocs) {
    const userId =
      docString(adminDoc, 'uid') || docString(adminDoc, 'id') || adminDoc.name.split('/').pop() || '';
    if (!userId) continue;
    await createUserNotification(
      env,
      {
        id: `${payload.idPrefix}_${userId}`,
        userId,
        audience: 'admin',
        category,
        type,
        title: payload.title,
        body: payload.body,
        route: payload.route || null,
        read: false,
        createdAt: now,
        updatedAt: now,
        source: payload.source || 'admin_event',
        sourceId: payload.sourceId || null,
      },
      true,
    );
  }
}

type SupportResponseEmailPayload = {
  to: string;
  ticketId: string;
  status: string;
  responseMessage: string;
};

type SupportEmailContent = {
  subject: string;
  plainText: string;
  htmlText: string;
};

function buildSupportResponseEmailContent(payload: SupportResponseEmailPayload): SupportEmailContent {
  const statusLabel = payload.status.trim().toLowerCase() || 'answered';
  const subject = `CamVote support update - ticket ${payload.ticketId}`;
  const plainText = [
    `Hello,`,
    ``,
    `Your CamVote support ticket (${payload.ticketId}) has a new update.`,
    `Status: ${statusLabel}`,
    ``,
    `${payload.responseMessage.trim()}`,
    ``,
    `If you need more help, reply to this email or open CamVote support.`,
    ``,
    `CamVote Help Desk`,
  ].join('\n');
  const htmlText = `<div style="font-family:Arial,sans-serif;line-height:1.5;color:#1f2937;">
  <p>Hello,</p>
  <p>Your CamVote support ticket <strong>${escapeHtml(
    payload.ticketId,
  )}</strong> has a new update.</p>
  <p><strong>Status:</strong> ${escapeHtml(statusLabel)}</p>
  <blockquote style="margin:12px 0;padding:10px 12px;border-left:3px solid #16a34a;background:#f8fafc;">
    ${escapeHtml(payload.responseMessage.trim()).replace(/\n/g, '<br/>')}
  </blockquote>
  <p>If you need more help, reply to this email or open CamVote support.</p>
  <p style="margin-top:18px;">CamVote Help Desk</p>
</div>`;

  return { subject, plainText, htmlText };
}

function isGmailSenderAddress(value: string): boolean {
  const normalized = value.trim().toLowerCase();
  return normalized.endsWith('@gmail.com') || normalized.endsWith('@googlemail.com');
}

function hasGmailSupportEmailConfig(env: Env): boolean {
  const clientId = (env.GMAIL_CLIENT_ID || '').trim();
  const clientSecret = (env.GMAIL_CLIENT_SECRET || '').trim();
  const refreshToken = (env.GMAIL_REFRESH_TOKEN || '').trim();
  return clientId.length > 0 && clientSecret.length > 0 && refreshToken.length > 0;
}

async function trySendSupportResponseEmail(env: Env, payload: SupportResponseEmailPayload): Promise<boolean> {
  const recipient = payload.to.trim().toLowerCase();
  if (!isValidEmail(recipient)) return false;

  const from = (env.SUPPORT_EMAIL_FROM || '').trim().toLowerCase();
  const replyTo = (env.SUPPORT_EMAIL_REPLY_TO || '').trim().toLowerCase();
  if (!isValidEmail(from)) return false;

  if (isGmailSenderAddress(from)) {
    if (hasGmailSupportEmailConfig(env)) {
      const ok = await trySendSupportResponseEmailViaGmail(
        env,
        { ...payload, to: recipient },
        from,
        replyTo,
      );
      console.log(`Support email provider=gmail_api ticket=${payload.ticketId} ok=${ok}`);
      return ok;
    }

    console.error(
      'Support email uses a Gmail FROM address but Gmail API secrets are missing. ' +
        'MailChannels delivery to Gmail recipients will likely bounce due to DMARC. ' +
        'Set GMAIL_CLIENT_ID/GMAIL_CLIENT_SECRET/GMAIL_REFRESH_TOKEN or use a non-Gmail SUPPORT_EMAIL_FROM.',
    );
  }

  const ok = await trySendSupportResponseEmailViaMailChannels(
    env,
    { ...payload, to: recipient },
    from,
    replyTo,
  );
  console.log(`Support email provider=mailchannels ticket=${payload.ticketId} ok=${ok}`);
  return ok;
}

async function trySendSupportResponseEmailViaMailChannels(
  env: Env,
  payload: SupportResponseEmailPayload,
  from: string,
  replyTo: string,
): Promise<boolean> {
  const mailchannelsApiKey = (env.MAILCHANNELS_API_KEY || '').trim();
  if (!mailchannelsApiKey) {
    console.error(
      'Support email send proceeding without MAILCHANNELS_API_KEY. ' +
        'If MailChannels requires auth for your account, configure MAILCHANNELS_API_KEY.',
    );
  }

  const { subject, plainText, htmlText } = buildSupportResponseEmailContent(payload);

  const requestBody: JsonObject = {
    personalizations: [{ to: [{ email: payload.to.trim().toLowerCase() }] }],
    from: { email: from, name: 'CamVote Help Desk' },
    subject,
    content: [{ type: 'text/plain', value: plainText }],
  };
  if (replyTo && isValidEmail(replyTo)) {
    requestBody.reply_to = { email: replyTo };
  }
  requestBody.content = [
    { type: 'text/plain', value: plainText },
    { type: 'text/html', value: htmlText },
  ];

  try {
    const headers: Record<string, string> = { 'content-type': 'application/json' };
    if (mailchannelsApiKey) {
      headers['x-api-key'] = mailchannelsApiKey;
    }
    const response = await fetch(MAILCHANNELS_SEND_URL, {
      method: 'POST',
      headers,
      body: JSON.stringify(requestBody),
    });
    if (!response.ok) {
      const details = await response.text();
      if (response.status === 401) {
        console.error(
          `Support email send failed ${response.status}. ` +
            `Check MAILCHANNELS_API_KEY and sender authorization for ${from}. ` +
            `Response: ${details}`,
        );
      } else {
        console.error('Support email send failed', response.status, details);
      }
      return false;
    }
    return true;
  } catch (error) {
    console.error('Support email send exception', (error as Error).message);
    return false;
  }
}

async function getGmailAccessToken(env: Env): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedGmailAccessToken && cachedGmailAccessTokenExp - 60 > now) {
    return cachedGmailAccessToken;
  }

  const clientId = (env.GMAIL_CLIENT_ID || '').trim();
  const clientSecret = (env.GMAIL_CLIENT_SECRET || '').trim();
  const refreshToken = (env.GMAIL_REFRESH_TOKEN || '').trim();
  if (!clientId || !clientSecret || !refreshToken) {
    return '';
  }

  try {
    const response = await fetch(TOKEN_URL, {
      method: 'POST',
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        client_id: clientId,
        client_secret: clientSecret,
        refresh_token: refreshToken,
        grant_type: 'refresh_token',
      }).toString(),
    });
    if (!response.ok) {
      console.error('Gmail token refresh failed', response.status, await response.text());
      return '';
    }

    const data = (await response.json()) as { access_token?: string; expires_in?: number };
    const accessToken = `${data.access_token || ''}`.trim();
    if (!accessToken) return '';

    cachedGmailAccessToken = accessToken;
    cachedGmailAccessTokenExp = now + (data.expires_in || 3600);
    return cachedGmailAccessToken;
  } catch (error) {
    console.error('Gmail token refresh exception', (error as Error).message);
    return '';
  }
}

function base64EncodeUtf8(input: string): string {
  const bytes = textEncoder.encode(input);
  let binary = '';
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary);
}

function wrapBase64Lines(input: string, width = 76): string {
  const value = input.replace(/\r?\n/g, '');
  const lines: string[] = [];
  for (let i = 0; i < value.length; i += width) {
    lines.push(value.slice(i, i + width));
  }
  return lines.join('\r\n');
}

async function trySendSupportResponseEmailViaGmail(
  env: Env,
  payload: SupportResponseEmailPayload,
  from: string,
  replyTo: string,
): Promise<boolean> {
  const accessToken = await getGmailAccessToken(env);
  if (!accessToken) {
    console.error('Gmail support email send skipped: missing/invalid Gmail OAuth configuration.');
    return false;
  }

  const { subject, plainText, htmlText } = buildSupportResponseEmailContent(payload);
  const boundary = `camvote_${crypto.randomUUID().replace(/-/g, '')}`;

  const headerLines: string[] = [
    `To: ${payload.to.trim().toLowerCase()}`,
    `From: CamVote Help Desk <${from}>`,
    `Subject: ${subject}`,
    `MIME-Version: 1.0`,
    `Content-Type: multipart/alternative; boundary="${boundary}"`,
  ];
  if (replyTo && isValidEmail(replyTo)) {
    headerLines.splice(2, 0, `Reply-To: ${replyTo}`);
  }

  const mime = [
    ...headerLines,
    '',
    `--${boundary}`,
    'Content-Type: text/plain; charset="UTF-8"',
    'Content-Transfer-Encoding: base64',
    '',
    wrapBase64Lines(base64EncodeUtf8(plainText)),
    '',
    `--${boundary}`,
    'Content-Type: text/html; charset="UTF-8"',
    'Content-Transfer-Encoding: base64',
    '',
    wrapBase64Lines(base64EncodeUtf8(htmlText)),
    '',
    `--${boundary}--`,
    '',
  ].join('\r\n');

  try {
    const response = await fetch(GMAIL_SEND_URL, {
      method: 'POST',
      headers: {
        authorization: `Bearer ${accessToken}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({ raw: base64UrlEncode(mime) }),
    });

    if (!response.ok) {
      console.error('Gmail support email send failed', response.status, await response.text());
      return false;
    }

    return true;
  } catch (error) {
    console.error('Gmail support email send exception', (error as Error).message);
    return false;
  }
}

function escapeHtml(value: string): string {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function shouldExposeOrangeMoneyNumber(env: Env): boolean {
  const value = `${env.TIP_ORANGE_MONEY_NUMBER_PUBLIC ?? ''}`.trim().toLowerCase();
  return value === '1' || value === 'true' || value === 'yes' || value === 'on';
}

type TapTapCheckoutOptions = {
  tipId: string;
  amount: number;
  currency: string;
  recipientName: string;
  recipientNumber: string;
};

function buildTapTapCheckoutUrl(baseUrl: string, options: TapTapCheckoutOptions): string {
  const fallback = 'https://www.taptapsend.com/';
  const raw = baseUrl.trim() || fallback;
  try {
    const url = new URL(raw);
    const params = new URLSearchParams(url.search);
    params.set('utm_source', 'camvote');
    params.set('utm_medium', 'tip');
    params.set('camvote_tip_id', options.tipId);
    if (options.amount > 0) params.set('amount', `${options.amount}`);
    if (options.currency.trim()) params.set('currency', options.currency.trim().toUpperCase());
    if (options.recipientName.trim()) params.set('recipient_name', options.recipientName.trim());
    if (options.recipientNumber.trim()) params.set('recipient_number', options.recipientNumber.trim());
    params.set('recipient_country', 'CM');
    params.set('recipient_network', 'orange_money');
    url.search = params.toString();
    return url.toString();
  } catch {
    return fallback;
  }
}

function buildTapTapDeepLink(baseDeepLink: string, options: TapTapCheckoutOptions): string {
  const raw = baseDeepLink.trim() || 'taptapsend://send';
  try {
    const url = new URL(raw);
    const params = new URLSearchParams(url.search);
    params.set('tip_id', options.tipId);
    if (options.amount > 0) params.set('amount', `${options.amount}`);
    if (options.currency.trim()) params.set('currency', options.currency.trim().toUpperCase());
    if (options.recipientName.trim()) params.set('recipient_name', options.recipientName.trim());
    if (options.recipientNumber.trim()) params.set('recipient_number', options.recipientNumber.trim());
    url.search = params.toString();
    return url.toString();
  } catch {
    return raw;
  }
}

function buildRemitlyCheckoutUrl(baseUrl: string, options: TapTapCheckoutOptions): string {
  const fallback = 'https://www.remitly.com/';
  const raw = baseUrl.trim() || fallback;
  try {
    const url = new URL(raw);
    const params = new URLSearchParams(url.search);
    params.set('utm_source', 'camvote');
    params.set('utm_medium', 'tip');
    params.set('camvote_tip_id', options.tipId);
    if (options.amount > 0) params.set('amount', `${options.amount}`);
    if (options.currency.trim()) params.set('currency', options.currency.trim().toUpperCase());
    if (options.recipientName.trim()) params.set('recipient_name', options.recipientName.trim());
    if (options.recipientNumber.trim()) params.set('recipient_number', options.recipientNumber.trim());
    params.set('recipient_country', 'CM');
    params.set('recipient_network', 'orange_money');
    url.search = params.toString();
    return url.toString();
  } catch {
    return fallback;
  }
}

function buildRemitlyDeepLink(baseDeepLink: string, options: TapTapCheckoutOptions): string {
  const raw = baseDeepLink.trim() || 'remitly://send';
  try {
    const url = new URL(raw);
    const params = new URLSearchParams(url.search);
    params.set('tip_id', options.tipId);
    if (options.amount > 0) params.set('amount', `${options.amount}`);
    if (options.currency.trim()) params.set('currency', options.currency.trim().toUpperCase());
    if (options.recipientName.trim()) params.set('recipient_name', options.recipientName.trim());
    if (options.recipientNumber.trim()) params.set('recipient_number', options.recipientNumber.trim());
    url.search = params.toString();
    return url.toString();
  } catch {
    return raw;
  }
}

function stringField(body: JsonObject, key: string): string {
  const value = body[key];
  if (typeof value === 'string') return value;
  if (typeof value === 'number' || typeof value === 'boolean') return `${value}`;
  return '';
}

function isValidEmail(value: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

function booleanField(body: JsonObject, key: string): boolean {
  const value = body[key];
  if (value === true) return true;
  if (value === false) return false;
  if (typeof value === 'number') return value === 1;
  if (typeof value === 'string') {
    const normalized = value.trim().toLowerCase();
    return normalized === '1' || normalized === 'true' || normalized === 'yes' || normalized === 'on';
  }
  return false;
}

function numberField(body: JsonObject, key: string): number {
  const value = body[key];
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}

function arrayStringField(body: JsonObject, key: string): string[] {
  const value = body[key];
  if (Array.isArray(value)) {
    return value.map((item) => `${item ?? ''}`.trim()).filter(Boolean);
  }
  if (value && typeof value === 'object' && 'arrayValue' in (value as Record<string, unknown>)) {
    const arrayValue = (value as { arrayValue?: { values?: FirestoreValue[] } }).arrayValue;
    const values = arrayValue?.values ?? [];
    return values
      .map((item) => (item && 'stringValue' in item ? `${item.stringValue ?? ''}`.trim() : ''))
      .filter(Boolean);
  }
  if (typeof value === 'string' && value.trim()) {
    return [value.trim()];
  }
  return [];
}

function pickString(body: JsonObject, keys: string[]): string {
  for (const key of keys) {
    if (typeof body[key] === 'string' && body[key]) {
      return body[key] as string;
    }
  }
  return '';
}

function objectArrayField(body: JsonObject, key: string): JsonObject[] {
  const value = body[key];
  if (!Array.isArray(value)) return [];
  return value.filter(
    (item): item is JsonObject =>
      typeof item === 'object' && item !== null && !Array.isArray(item),
  );
}

function buildCenterPayload(body: JsonObject, now: string): JsonObject {
  const regionCode = pickString(body, ['region_code', 'regionCode']).trim();
  const regionName = pickString(body, ['region_name', 'regionName']).trim();
  const countryCode = pickString(body, ['country_code', 'countryCode']).trim();
  return {
    name: stringField(body, 'name').trim(),
    address: stringField(body, 'address').trim(),
    region_code: regionCode,
    region_name: regionName,
    city: stringField(body, 'city').trim(),
    country: stringField(body, 'country').trim(),
    country_code: countryCode ? countryCode.toUpperCase() : '',
    type: stringField(body, 'type').trim(),
    latitude: numberField(body, 'latitude'),
    longitude: numberField(body, 'longitude'),
    status: stringField(body, 'status').trim(),
    contact: stringField(body, 'contact').trim(),
    notes: stringField(body, 'notes').trim(),
    updatedAt: now,
  };
}

function docString(doc: FirestoreDoc, key: string): string {
  const value = doc.fields?.[key] as { stringValue?: string; timestampValue?: string } | undefined;
  return value?.stringValue || value?.timestampValue || '';
}

function docMapValue(doc: FirestoreDoc, key: string): FirestoreValue | undefined {
  return doc.fields?.[key];
}

function docBool(doc: FirestoreDoc, key: string): boolean | null {
  const value = doc.fields?.[key] as { booleanValue?: boolean } | undefined;
  return value?.booleanValue ?? null;
}

function docArrayString(doc: FirestoreDoc, key: string): string[] {
  const value =
    doc.fields?.[key] as { arrayValue?: { values?: FirestoreValue[] } } | undefined;
  const values = value?.arrayValue?.values ?? [];
  const out: string[] = [];
  for (const item of values) {
    if (item && 'stringValue' in item) {
      const str = item.stringValue.trim();
      if (str) out.push(str);
    }
  }
  return out;
}

function docInt(doc: FirestoreDoc, key: string): number | null {
  const value = doc.fields?.[key] as { integerValue?: string } | undefined;
  return value?.integerValue ? Number(value.integerValue) : null;
}

function docMap(doc: FirestoreDoc, key: string): Record<string, number> {
  const value = doc.fields?.[key] as { mapValue?: { fields?: Record<string, FirestoreValue> } } | undefined;
  const fields = value?.mapValue?.fields || {};
  const result: Record<string, number> = {};
  for (const [fieldKey, fieldValue] of Object.entries(fields)) {
    result[fieldKey] = Number(valueToJs(fieldValue) || 0);
  }
  return result;
}

function parseDateValue(value: unknown): number | null {
  if (value === null || value === undefined) return null;
  if (typeof value === 'number' && Number.isFinite(value)) return value;
  const parsed = Date.parse(value.toString());
  return Number.isNaN(parsed) ? null : parsed;
}

function computeAgeFromIso(dateString: string): number | null {
  const parsed = Date.parse(dateString);
  if (Number.isNaN(parsed)) return null;
  const dob = new Date(parsed);
  const now = new Date();
  let age = now.getUTCFullYear() - dob.getUTCFullYear();
  const monthDelta = now.getUTCMonth() - dob.getUTCMonth();
  if (monthDelta < 0 || (monthDelta === 0 && now.getUTCDate() < dob.getUTCDate())) {
    age -= 1;
  }
  return age;
}

function isAdult(dateString: string): boolean {
  const date = Date.parse(dateString);
  if (Number.isNaN(date)) {
    return false;
  }
  const age = Date.now() - date;
  const eighteenYears = 18 * 365.25 * 24 * 60 * 60 * 1000;
  return age >= eighteenYears;
}

function maskName(name: string): string {
  if (!name) return '';
  const parts = name.split(' ').filter((p) => p.trim().length > 0);
  return parts.map((p) => `${p[0]}***`).join(' ');
}

function maskReg(reg: string): string {
  if (reg.length <= 4) return '****';
  const start = reg.slice(0, 2);
  const end = reg.slice(-2);
  return `${start}****${end}`;
}

function maskPhoneNumber(value: string): string {
  const trimmed = value.trim();
  if (!trimmed) return '';
  const digits = trimmed.replace(/\D/g, '');
  if (!digits) return '';
  const keepStart = digits.length >= 3 ? 3 : 1;
  const keepEnd = digits.length >= 2 ? 2 : 1;
  const hiddenCount = Math.max(0, digits.length - keepStart - keepEnd);
  const prefix = trimmed.startsWith('+') ? '+' : '';
  const start = digits.slice(0, keepStart);
  const end = digits.slice(digits.length - keepEnd);
  const stars = hiddenCount > 0 ? '*'.repeat(hiddenCount) : '';
  return `${prefix}${start}${stars}${end}`;
}

async function sha256Hex(input: string): Promise<string> {
  const data = textEncoder.encode(input);
  const hash = await crypto.subtle.digest('SHA-256', data);
  return bufferToHex(hash);
}

async function hmacSha256Hex(secret: string, input: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    'raw',
    textEncoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const sig = await crypto.subtle.sign('HMAC', key, textEncoder.encode(input));
  return bufferToHex(sig);
}

function bufferToHex(buffer: ArrayBuffer): string {
  return Array.from(new Uint8Array(buffer))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

function constantTimeEqual(a: string, b: string): boolean {
  if (a === b) return true;
  const aBytes = textEncoder.encode(a);
  const bBytes = textEncoder.encode(b);
  const maxLen = Math.max(aBytes.length, bBytes.length);
  if (maxLen === 0) return true;

  let diff = aBytes.length ^ bBytes.length;
  for (let i = 0; i < maxLen; i += 1) {
    const aValue = i < aBytes.length ? aBytes[i] : 0;
    const bValue = i < bBytes.length ? bBytes[i] : 0;
    diff |= aValue ^ bValue;
  }
  return diff === 0;
}

function base64ToBytes(value: string): Uint8Array {
  const binary = atob(value);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i += 1) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

function base64ByteLength(input: string): number {
  const trimmed = input.trim().replace(/\s+/g, '');
  if (!trimmed) return 0;
  const padding = trimmed.endsWith('==') ? 2 : trimmed.endsWith('=') ? 1 : 0;
  return Math.max(0, Math.floor((trimmed.length * 3) / 4) - padding);
}

function base64UrlEncode(input: string | ArrayBuffer): string {
  const bytes = typeof input === 'string' ? textEncoder.encode(input) : new Uint8Array(input);
  let binary = '';
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function toFirestoreFields(data: JsonObject): Record<string, FirestoreValue> {
  const fields: Record<string, FirestoreValue> = {};
  for (const [key, value] of Object.entries(data)) {
    if (value === undefined) {
      continue;
    }
    fields[key] = toFirestoreValue(value);
  }
  return fields;
}

function toFirestoreValue(value: unknown): FirestoreValue {
  if (value === null) {
    return { nullValue: null };
  }
  if (typeof value === 'string') {
    return { stringValue: value };
  }
  if (typeof value === 'number' && Number.isFinite(value)) {
    return { integerValue: Math.trunc(value).toString() };
  }
  if (typeof value === 'boolean') {
    return { booleanValue: value };
  }
  if (value instanceof Date) {
    return { timestampValue: value.toISOString() };
  }
  if (Array.isArray(value)) {
    return {
      arrayValue: {
        values: value.map((item) => toFirestoreValue(item)),
      },
    };
  }
  if (typeof value === 'object') {
    return {
      mapValue: {
        fields: toFirestoreFields(value as JsonObject),
      },
    };
  }
  return { stringValue: String(value) };
}

function valueToJs(value: FirestoreValue): unknown {
  if ('stringValue' in value) return value.stringValue;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('booleanValue' in value) return value.booleanValue;
  if ('timestampValue' in value) return value.timestampValue;
  if ('nullValue' in value) return null;
  if ('mapValue' in value) {
    const result: Record<string, unknown> = {};
    const fields = value.mapValue.fields || {};
    for (const [key, fieldValue] of Object.entries(fields)) {
      result[key] = valueToJs(fieldValue);
    }
    return result;
  }
  if ('arrayValue' in value) {
    const values = value.arrayValue.values ?? [];
    return values.map((item) => valueToJs(item));
  }
  return null;
}

async function firestoreGet(env: Env, path: string): Promise<FirestoreDoc | null> {
  const response = await firestoreFetch(env, `${firestoreBase(env)}/${path}`, 'GET');
  if (response === null) {
    return null;
  }
  return response as FirestoreDoc;
}

async function firestoreCreate(env: Env, path: string, data: JsonObject): Promise<void> {
  await firestoreFetch(
    env,
    `${firestoreBase(env)}/${path}?currentDocument.exists=false`,
    'PATCH',
    { fields: toFirestoreFields(data) },
  );
}

async function firestorePatch(
  env: Env,
  path: string,
  data: JsonObject,
  fieldPaths?: string[],
): Promise<void> {
  const url = new URL(`${firestoreBase(env)}/${path}`);
  if (fieldPaths && fieldPaths.length > 0) {
    for (const field of fieldPaths) {
      url.searchParams.append('updateMask.fieldPaths', field);
    }
  }
  await firestoreFetch(env, url.toString(), 'PATCH', { fields: toFirestoreFields(data) });
}

async function firestoreRunQuery(
  env: Env,
  structuredQuery: JsonObject,
  parent?: string,
): Promise<FirestoreDoc[]> {
  const response = await firestoreFetch(
    env,
    `${firestoreBase(env)}:runQuery`,
    'POST',
    parent ? { parent, structuredQuery } : { structuredQuery },
  );
  if (!Array.isArray(response)) {
    return [];
  }
  return response
    .map((item) => item.document as FirestoreDoc | undefined)
    .filter((doc): doc is FirestoreDoc => Boolean(doc));
}

async function firestoreCommit(env: Env, writes: JsonObject[]): Promise<void> {
  await firestoreFetch(env, `${firestoreBase(env)}:commit`, 'POST', { writes });
}

async function purgeCollection(env: Env, collection: string): Promise<number> {
  let deleted = 0;
  for (;;) {
    const docs = await firestoreRunQuery(env, {
      from: [{ collectionId: collection }],
      limit: 200,
    });
    if (docs.length === 0) {
      break;
    }
    const writes = docs.map((doc) => ({ delete: doc.name }));
    await firestoreCommit(env, writes);
    deleted += docs.length;
    if (docs.length < 200) {
      break;
    }
  }
  return deleted;
}

async function seedCollection(
  env: Env,
  collection: string,
  items: JsonObject[],
  overwrite: boolean,
  now: string,
): Promise<number> {
  let count = 0;
  for (const item of items) {
    const id = stringField(item, 'id');
    if (!id) continue;
    const path = `${collection}/${id}`;
    const existing = await firestoreGet(env, path);
    if (existing && !overwrite) continue;
    const data = { ...item } as JsonObject;
    delete (data as Record<string, unknown>)['id'];
    data.updatedAt = now;
    if (existing) {
      await firestorePatch(env, path, data, Object.keys(data));
    } else {
      await firestoreCreate(env, path, data);
    }
    count += 1;
  }
  return count;
}

async function seedDocument(
  env: Env,
  collection: string,
  id: string,
  data: JsonObject,
  overwrite: boolean,
  now: string,
): Promise<boolean> {
  const path = `${collection}/${id}`;
  const existing = await firestoreGet(env, path);
  if (existing && !overwrite) {
    return false;
  }
  const payload = { ...data, updatedAt: now } as JsonObject;
  if (existing) {
    await firestorePatch(env, path, payload, Object.keys(payload));
  } else {
    await firestoreCreate(env, path, payload);
  }
  return true;
}

async function firestoreFetch(
  env: Env,
  url: string,
  method: string,
  body?: JsonObject,
): Promise<unknown> {
  const token = await getAccessToken(env);
  const response = await fetch(url, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    let errorCode = 'UNKNOWN';
    let message = 'Firestore request failed.';
    try {
      const data = (await response.json()) as { error?: { status?: string; message?: string } };
      if (data.error?.status) errorCode = data.error.status;
      if (data.error?.message) message = data.error.message;
    } catch {
      // ignore JSON parse errors
    }
    throw new HttpError(response.status, message, errorCode);
  }

  if (response.status === 204) {
    return null;
  }

  return response.json();
}

function firestoreBase(env: Env): string {
  return `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents`;
}

function docName(env: Env, path: string): string {
  return `projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/${path}`;
}

async function getAccessToken(env: Env): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedAccessToken && cachedAccessTokenExp - 60 > now) {
    return cachedAccessToken;
  }

  const iat = now;
  const exp = now + 3600;
  const header = { alg: 'RS256', typ: 'JWT' };
  const claims = {
    iss: env.FIREBASE_CLIENT_EMAIL,
    scope: TOKEN_SCOPE,
    aud: TOKEN_URL,
    iat,
    exp,
  };

  const unsigned = `${base64UrlEncode(JSON.stringify(header))}.${base64UrlEncode(
    JSON.stringify(claims),
  )}`;
  const signature = await signJwt(unsigned, env);
  const assertion = `${unsigned}.${signature}`;

  const response = await fetch(TOKEN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }).toString(),
  });

  if (!response.ok) {
    throw new HttpError(500, 'Unable to obtain access token.');
  }

  const data = (await response.json()) as { access_token: string; expires_in: number };
  cachedAccessToken = data.access_token;
  cachedAccessTokenExp = now + (data.expires_in || 3600);
  return cachedAccessToken;
}

async function signJwt(unsigned: string, env: Env): Promise<string> {
  if (!cachedPrivateKey) {
    const pem = env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n');
    const keyData = pemToArrayBuffer(pem);
    cachedPrivateKey = await crypto.subtle.importKey(
      'pkcs8',
      keyData,
      { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
      false,
      ['sign'],
    );
  }

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cachedPrivateKey,
    textEncoder.encode(unsigned),
  );
  return base64UrlEncode(signature);
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const lines = pem.replace(/-----BEGIN PRIVATE KEY-----|-----END PRIVATE KEY-----/g, '');
  const base64 = lines.replace(/\s+/g, '');
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i += 1) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

