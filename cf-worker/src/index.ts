export interface Env {
  FIREBASE_PROJECT_ID: string;
  FIREBASE_CLIENT_EMAIL: string;
  FIREBASE_PRIVATE_KEY: string;
  FIREBASE_API_KEY: string;
  ALLOWED_ORIGINS?: string;
  TRELLO_KEY?: string;
  TRELLO_TOKEN?: string;
  TRELLO_BOARD_ID?: string;
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

type StorageCategory = 'public' | 'registration_docs' | 'incident_attachments';
type StoragePath = { key: string; category: StorageCategory; ownerUid?: string };

const TOKEN_SCOPE = 'https://www.googleapis.com/auth/datastore';
const TOKEN_URL = 'https://oauth2.googleapis.com/token';
const textEncoder = new TextEncoder();
const SIGNED_URL_TTL_SECONDS = 60 * 60 * 24 * 365; // 1 year by default

let cachedAccessToken = '';
let cachedAccessTokenExp = 0;
let cachedPrivateKey: CryptoKey | null = null;

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
      if (request.method === 'GET' && url.pathname === '/v1/storage/file') {
        return await handleStorageFile(request, env, corsHeaders);
      }

      if (request.method === 'GET') {
        switch (url.pathname) {
          case '/v1/auth/resolve-identifier':
            return await handleAuthResolveIdentifier(request, env, corsHeaders);
          case '/v1/public/results':
            return await handlePublicResults(request, env, corsHeaders);
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

      switch (url.pathname) {
        case '/v1/device/register':
          return await handleDeviceRegister(request, env, corsHeaders);
        case '/v1/vote/nonce':
          return await handleVoteNonce(request, env, corsHeaders);
        case '/v1/vote/cast':
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
          return await handleSupportTicket(request, env, corsHeaders);
        case '/v1/notifications/mark-read':
          return await handleNotificationMarkRead(request, env, corsHeaders);
        case '/v1/notifications/mark-all-read':
          return await handleNotificationMarkAllRead(request, env, corsHeaders);
        case '/v1/admin/support/tickets/respond':
          return await handleAdminSupportTicketRespond(request, env, corsHeaders);
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
  const body = await readJson(request);
  const electionId = stringField(body, 'electionId');
  const deviceHash = stringField(body, 'deviceHash');

  if (!electionId || !deviceHash) {
    throw new HttpError(400, 'electionId and deviceHash are required');
  }

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
  const body = await readJson(request);
  const electionId = stringField(body, 'electionId');
  const candidateId = stringField(body, 'candidateId');
  const deviceHash = stringField(body, 'deviceHash');
  const nonceId = stringField(body, 'nonceId');
  const signature = stringField(body, 'signature');
  const biometricVerified = booleanField(body, 'biometricVerified');
  const livenessVerified = booleanField(body, 'livenessVerified');

  if (!electionId || !candidateId || !deviceHash || !nonceId || !signature) {
    throw new HttpError(400, 'Missing required vote fields.');
  }
  if (!biometricVerified || !livenessVerified) {
    throw new HttpError(403, 'Biometrics and liveness are required.');
  }

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

  try {
    await updateResults(env, electionId, candidateId);
  } catch (error) {
    await logDeviceRisk(env, {
      uid,
      deviceHash,
      type: 'RESULTS_UPDATE_FAILED',
      severity: 'medium',
      note: (error as Error).message || 'Results update failed.',
    });
  }

  return jsonResponse({ ok: true, auditToken }, corsHeaders);
}

async function handleRegistrationSubmit(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  const payload = (await readJson(request)) as JsonObject;

  const dob = pickString(payload, ['dateOfBirth', 'date_of_birth', 'dob']);
  if (!dob || !isAdult(dob)) {
    throw new HttpError(403, 'Registrant must be at least 18 years old.');
  }

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
  const identifier = (url.searchParams.get('identifier') || '').trim();
  if (!identifier) {
    throw new HttpError(400, 'identifier is required');
  }
  if (identifier.includes('@')) {
    return jsonResponse({ ok: true, email: identifier }, corsHeaders);
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
  const key = (env.TRELLO_KEY || '').trim();
  const token = (env.TRELLO_TOKEN || '').trim();
  const boardId = (env.TRELLO_BOARD_ID || '').trim();

  if (!key || !boardId) {
    return jsonResponse(
      { ok: true, configured: false, stats: null },
      corsHeaders,
    );
  }

  try {
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
      )}/cards?${authQuery}&fields=idList,closed`,
    );
    if (!cardsRes.ok) {
      throw new HttpError(502, 'Unable to load Trello cards.');
    }
    const cards = (await cardsRes.json()) as Array<Record<string, unknown>>;

    let totalCards = 0;
    let openCards = 0;
    const lists = activeLists
      .map((list) => {
        const listId = `${list.id ?? ''}`;
        const listName = `${list.name ?? 'List'}`.trim() || 'List';
        const listCards = cards.filter((c) => `${c.idList ?? ''}` === listId);
        const total = listCards.length;
        const open = listCards.filter((c) => c.closed !== true).length;
        totalCards += total;
        openCards += open;
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
          doneCards: Math.max(totalCards - openCards, 0),
          lists,
        },
      },
      corsHeaders,
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
  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const payload: Record<string, unknown> = {
    title: stringField(body, 'title'),
    type: stringField(body, 'type') || 'presidential',
    startAt: stringField(body, 'startAt'),
    endAt: stringField(body, 'endAt'),
    status: stringField(body, 'status') || 'draft',
    registrationDeadline: stringField(body, 'registrationDeadline'),
    description: stringField(body, 'description'),
    scope: stringField(body, 'scope'),
    location: stringField(body, 'location'),
    timezone: stringField(body, 'timezone'),
    ballotType: stringField(body, 'ballotType'),
    eligibility: stringField(body, 'eligibility'),
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
  const electionId = stringField(body, 'electionId');
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
  const query: JsonObject = {
    from: [{ collectionId: 'users' }],
    limit: 100,
    orderBy: [{ field: { fieldPath: 'createdAt' }, direction: 'DESCENDING' }],
  };
  if (region) {
    query.where = {
      fieldFilter: {
        field: { fieldPath: 'regionCode' },
        op: 'EQUAL',
        value: { stringValue: region },
      },
    };
  }
  if (status) {
    const base = query.where as JsonObject | undefined;
    const filters = base
      ? { compositeFilter: { op: 'AND', filters: [base, { fieldFilter: { field: { fieldPath: 'status' }, op: 'EQUAL', value: { stringValue: status } } }] } }
      : { fieldFilter: { field: { fieldPath: 'status' }, op: 'EQUAL', value: { stringValue: status } } };
    query.where = filters;
  }
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
  const verifiedUsers = await firestoreRunQuery(env, {
    from: [{ collectionId: 'users' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'verified' },
        op: 'EQUAL',
        value: { booleanValue: true },
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
      totalRegistered: verifiedUsers.length,
      totalVoted: votes.length,
      suspiciousFlags: deviceFlags.length,
      activeElections: active,
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
    orderBy: [{ field: { fieldPath: 'lastSeen' }, direction: 'DESCENDING' }],
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
  const electionId = stringField(body, 'electionId');
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
  if (role !== 'observer' && role !== 'voter' && role !== 'admin') {
    throw new HttpError(403, 'Authenticated role required.');
  }
  const body = await readJson(request);
  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const attachments = body['attachments'];

  await firestoreCreate(env, `incidents/${id}`, {
    id,
    reportedBy: uid,
    title: stringField(body, 'title'),
    description: stringField(body, 'description'),
    location: stringField(body, 'location'),
    occurredAt: stringField(body, 'occurredAt'),
    category: stringField(body, 'category'),
    severity: stringField(body, 'severity'),
    electionId: stringField(body, 'electionId') || null,
    attachments: Array.isArray(attachments) ? attachments : [],
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
  const { uid, role } = await requireAuthWithRole(request, env);
  const body = await readJson(request);
  const name = stringField(body, 'name').trim();
  const email = stringField(body, 'email').trim().toLowerCase();
  const message = stringField(body, 'message').trim();

  if (!name) {
    throw new HttpError(400, 'name is required');
  }
  if (!email || !isValidEmail(email)) {
    throw new HttpError(400, 'A valid email is required');
  }
  if (!message) {
    throw new HttpError(400, 'message is required');
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  await firestoreCreate(env, `support_tickets/${id}`, {
    id,
    userId: uid,
    role,
    name,
    email,
    registrationId: stringField(body, 'registrationId').trim(),
    category: stringField(body, 'category').trim() || 'other',
    message,
    status: 'open',
    createdAt: now,
    updatedAt: now,
  });

  await createUserNotification(
    env,
    {
      id: `support_ticket_received_${id}`,
      userId: uid,
      audience: roleToAudience(role),
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

  return jsonResponse({ ok: true, ticketId: id, status: 'received' }, corsHeaders, 201);
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

  return jsonResponse({ ok: true, notifications: sorted }, corsHeaders);
}

async function handleNotificationMarkRead(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const { uid } = await requireAuth(request, env);
  const body = await readJson(request);
  const notificationId = stringField(body, 'notificationId').trim();
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
  const ticketId = stringField(body, 'ticketId').trim();
  const responseMessage = stringField(body, 'responseMessage').trim();
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

  const userId = docString(ticketDoc, 'userId');
  if (!userId) {
    throw new HttpError(409, 'Support ticket is missing userId.');
  }

  const now = new Date().toISOString();
  await firestorePatch(
    env,
    `support_tickets/${ticketId}`,
    {
      status,
      responseMessage,
      respondedAt: now,
      respondedBy: admin.uid,
      updatedAt: now,
    },
    ['status', 'responseMessage', 'respondedAt', 'respondedBy', 'updatedAt'],
  );

  await createUserNotification(
    env,
    {
      id: `support_ticket_status_${ticketId}_${status}_${now}`,
      userId,
      audience: roleToAudience(docString(ticketDoc, 'role') || 'public'),
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

  return jsonResponse({ ok: true, ticketId, status }, corsHeaders);
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
  const contentType = stringField(body, 'contentType') || 'application/octet-stream';

  if (!pathRaw) {
    throw new HttpError(400, 'path is required');
  }
  if (!contentBase64) {
    throw new HttpError(400, 'contentBase64 is required');
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
  const allowOrigin = allowed.includes('*') || allowed.includes(origin) ? origin : allowed[0] || '*';
  headers.set('Access-Control-Allow-Origin', allowOrigin);
  headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  headers.set('Access-Control-Allow-Headers', 'Authorization, Content-Type');
  headers.set('Access-Control-Max-Age', '86400');
  headers.set('Vary', 'Origin');
  return headers;
}

function jsonResponse(body: JsonObject, headers: Headers, status = 200): Response {
  const merged = new Headers(headers);
  merged.set('Content-Type', 'application/json');
  return new Response(JSON.stringify(body), { status, headers: merged });
}

async function readJson(request: Request): Promise<JsonObject> {
  try {
    return (await request.json()) as JsonObject;
  } catch {
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
  if (category !== 'public' && category !== 'registration_docs' && category !== 'incident_attachments') {
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
  return expected === sig;
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
  return 'info';
}

function normalizeNotificationAudience(value: unknown, fallback: string): string {
  const normalized = `${value ?? ''}`.trim().toLowerCase();
  if (['public', 'voter', 'observer', 'admin', 'all'].includes(normalized)) {
    return normalized;
  }
  return fallback;
}

async function createUserNotification(
  env: Env,
  payload: JsonObject,
  overwrite = false,
): Promise<void> {
  const id = stringField(payload, 'id').trim();
  const userId = stringField(payload, 'userId').trim();
  if (!id || !userId) return;

  const path = `user_notifications/${id}`;
  const existing = await firestoreGet(env, path);
  if (existing && !overwrite) return;

  if (existing) {
    await firestorePatch(env, path, payload, Object.keys(payload));
  } else {
    await firestoreCreate(env, path, payload);
  }
}

function stringField(body: JsonObject, key: string): string {
  const value = body[key];
  return typeof value === 'string' ? value : '';
}

function isValidEmail(value: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

function booleanField(body: JsonObject, key: string): boolean {
  const value = body[key];
  return value === true;
}

function numberField(body: JsonObject, key: string): number {
  const value = body[key];
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
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

function base64ToBytes(value: string): Uint8Array {
  const binary = atob(value);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i += 1) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
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
