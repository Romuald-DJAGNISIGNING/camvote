import fs from 'node:fs';
import path from 'node:path';
import admin from 'firebase-admin';
import minimist from 'minimist';

const argv = minimist(process.argv.slice(2), {
  string: ['baseUrl', 'ticketEmail', 'serviceAccount'],
  boolean: ['keepUsers'],
  default: {
    baseUrl: '',
    ticketEmail: '',
    keepUsers: false,
  },
});

function readEnvValue(filePath, key) {
  try {
    const raw = fs.readFileSync(filePath, 'utf8');
    const lines = raw.split(/\r?\n/);
    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#')) continue;
      const idx = trimmed.indexOf('=');
      if (idx === -1) continue;
      const k = trimmed.slice(0, idx).trim();
      if (k !== key) continue;
      return trimmed.slice(idx + 1).trim();
    }
  } catch {
    // ignore
  }
  return '';
}

function safeJsonParse(value, fallback) {
  try {
    return JSON.parse(value);
  } catch {
    return fallback;
  }
}

async function fetchJson(url, init) {
  const res = await fetch(url, init);
  const text = await res.text();
  const payload = safeJsonParse(text, null);
  if (!res.ok) {
    const msg = payload?.error?.message || payload?.error || text || `HTTP ${res.status}`;
    throw new Error(`${init?.method || 'GET'} ${url} failed: ${msg}`);
  }
  return payload;
}

async function sleep(ms) {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

const repoRoot = path.resolve(process.cwd());
const serviceAccountPath =
  argv.serviceAccount ||
  process.env.FIREBASE_SERVICE_ACCOUNT ||
  path.resolve(repoRoot, 'service-account.json');

if (!fs.existsSync(serviceAccountPath)) {
  throw new Error(
    `Firebase service account not found at ${serviceAccountPath}. ` +
      'Provide the path via --serviceAccount or FIREBASE_SERVICE_ACCOUNT.'
  );
}

const googleServicesPath = path.resolve(repoRoot, 'android', 'app', 'google-services.json');
if (!fs.existsSync(googleServicesPath)) {
  throw new Error(`Missing ${googleServicesPath}.`);
}
const googleServices = safeJsonParse(fs.readFileSync(googleServicesPath, 'utf8'), {});
const apiKey = googleServices?.client?.[0]?.api_key?.[0]?.current_key || '';
if (!apiKey) {
  throw new Error('Unable to read Firebase apiKey from android/app/google-services.json.');
}

const envBaseUrl =
  process.env.CAMVOTE_API_BASE_URL ||
  readEnvValue(path.resolve(repoRoot, '.env'), 'CAMVOTE_API_BASE_URL') ||
  'https://camvote.romuald-djagnisigning.workers.dev';
const baseUrl = (argv.baseUrl || envBaseUrl).trim().replace(/\/+$/, '');

const serviceAccount = safeJsonParse(fs.readFileSync(serviceAccountPath, 'utf8'), null);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const auth = admin.auth();
const firestore = admin.firestore();

const suffix = `${Date.now()}`;
const password = `TmpPass!${Math.floor(Math.random() * 100000)}`;
const userEmail = `tmp.user.${suffix}@example.com`;
const adminEmail = `tmp.admin.${suffix}@example.com`;
const ticketEmail = (argv.ticketEmail || userEmail).trim().toLowerCase();

async function createUserWithDoc({ email, role, fullName, username }) {
  const user = await auth.createUser({
    email,
    password,
    displayName: fullName,
  });
  await firestore.doc(`users/${user.uid}`).set(
    {
      email,
      role,
      fullName,
      username,
      status: 'active',
      verified: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
  return user;
}

async function signIn(email) {
  const url = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${encodeURIComponent(
    apiKey
  )}`;
  const payload = await fetchJson(url, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({
      email,
      password,
      returnSecureToken: true,
    }),
  });
  return payload.idToken;
}

let createdUserUid = '';
let createdAdminUid = '';

try {
  const user = await createUserWithDoc({
    email: userEmail,
    role: 'public',
    fullName: `Tmp User ${suffix}`,
    username: `tmp-user-${suffix}`,
  });
  createdUserUid = user.uid;

  const adminUser = await createUserWithDoc({
    email: adminEmail,
    role: 'admin',
    fullName: `Tmp Admin ${suffix}`,
    username: `tmp-admin-${suffix}`,
  });
  createdAdminUid = adminUser.uid;

  const userToken = await signIn(userEmail);
  const adminToken = await signIn(adminEmail);

  const ticket = await fetchJson(`${baseUrl}/v1/support/tickets`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${userToken}`,
    },
    body: JSON.stringify({
      name: `Tmp User ${suffix}`,
      email: ticketEmail,
      message: `E2E ticket ${suffix}`,
    }),
  });

  const delayMs = Number(process.env.CAMVOTE_E2E_PRE_RESPOND_DELAY_MS || 5000);
  if (delayMs > 0) await sleep(delayMs);

  const reply = await fetchJson(`${baseUrl}/v1/admin/support/tickets/respond`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${adminToken}`,
    },
    body: JSON.stringify({
      ticketId: ticket.ticketId,
      status: 'answered',
      responseMessage: `Reply from admin at ${new Date().toISOString()}`,
    }),
  });

  console.log(
    JSON.stringify(
      {
        ok: true,
        baseUrl,
        ticketId: ticket.ticketId,
        inAppSent: reply.inAppSent,
        emailSent: reply.emailSent,
        ticketEmail,
      },
      null,
      2
    )
  );
} finally {
  if (!argv.keepUsers) {
    const tasks = [];
    if (createdUserUid) {
      tasks.push(auth.deleteUser(createdUserUid).catch(() => {}));
      tasks.push(firestore.doc(`users/${createdUserUid}`).delete().catch(() => {}));
    }
    if (createdAdminUid) {
      tasks.push(auth.deleteUser(createdAdminUid).catch(() => {}));
      tasks.push(firestore.doc(`users/${createdAdminUid}`).delete().catch(() => {}));
    }
    await Promise.all(tasks);
  }
}

