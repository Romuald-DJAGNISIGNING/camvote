import fs from 'node:fs';
import path from 'node:path';
import admin from 'firebase-admin';
import minimist from 'minimist';

const argv = minimist(process.argv.slice(2), {
  string: ['serviceAccount', 'emailMarker', 'userMarker'],
  boolean: ['apply'],
  default: {
    apply: false,
    serviceAccount: path.resolve(process.cwd(), '../service-account.json'),
    emailMarker: '',
    userMarker: '',
  },
});

const serviceAccountPath =
  argv.serviceAccount ||
  process.env.FIREBASE_SERVICE_ACCOUNT ||
  path.resolve(process.cwd(), '../service-account.json');

if (!fs.existsSync(serviceAccountPath)) {
  throw new Error(
    `Firebase service account not found at ${serviceAccountPath}. ` +
      'Provide --serviceAccount or FIREBASE_SERVICE_ACCOUNT.',
  );
}

const defaultEmailMarkers = [
  'camvoteadmin.inspect+',
  'camvoteadmin.e2e+',
  'camvoteappassist+e2e',
];
const defaultUserMarkers = ['camvoteadmin.inspect', 'camvoteadmin.e2e'];

function toMarkerList(value) {
  if (Array.isArray(value)) {
    return value
      .flatMap((item) => `${item}`.split(','))
      .map((item) => item.trim().toLowerCase())
      .filter(Boolean);
  }
  return `${value || ''}`
    .split(',')
    .map((item) => item.trim().toLowerCase())
    .filter(Boolean);
}

const customEmailMarkers = toMarkerList(argv.emailMarker);
const customUserMarkers = toMarkerList(argv.userMarker);

const emailMarkers = [...new Set([...defaultEmailMarkers, ...customEmailMarkers])];
const userMarkers = [...new Set([...defaultUserMarkers, ...customUserMarkers])];

admin.initializeApp({
  credential: admin.credential.cert(
    JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8')),
  ),
});

const auth = admin.auth();
const firestore = admin.firestore();

function asString(value) {
  return `${value ?? ''}`.trim();
}

function lower(value) {
  return asString(value).toLowerCase();
}

function matchesEmailMarker(email) {
  const normalized = lower(email);
  if (!normalized) return false;
  return emailMarkers.some((marker) => normalized.includes(marker));
}

function matchesUserMarker(username) {
  const normalized = lower(username);
  if (!normalized) return false;
  return userMarkers.some((marker) => normalized.includes(marker));
}

function shouldMatchUserDoc(data) {
  return (
    matchesEmailMarker(data.email) ||
    matchesUserMarker(data.username) ||
    matchesUserMarker(data.fullName)
  );
}

function addDocDelete(store, collection, ref, reason) {
  if (!store[collection]) {
    store[collection] = new Map();
  }
  const id = ref.id;
  if (!store[collection].has(id)) {
    store[collection].set(id, { ref, reasons: new Set() });
  }
  store[collection].get(id).reasons.add(reason);
}

async function scanCollection(collectionName, visit, pageSize = 400) {
  let query = firestore
    .collection(collectionName)
    .orderBy(admin.firestore.FieldPath.documentId())
    .limit(pageSize);

  let scanned = 0;
  while (true) {
    const snap = await query.get();
    if (snap.empty) break;
    for (const doc of snap.docs) {
      scanned += 1;
      await visit(doc);
    }
    const last = snap.docs[snap.docs.length - 1];
    query = firestore
      .collection(collectionName)
      .orderBy(admin.firestore.FieldPath.documentId())
      .startAfter(last.id)
      .limit(pageSize);
  }
  return scanned;
}

async function deleteDocRefs(refs) {
  const chunkSize = 400;
  for (let i = 0; i < refs.length; i += chunkSize) {
    const batch = firestore.batch();
    refs.slice(i, i + chunkSize).forEach((ref) => batch.delete(ref));
    await batch.commit();
  }
}

async function deleteAuthUsers(uids) {
  const chunkSize = 100;
  for (let i = 0; i < uids.length; i += chunkSize) {
    const chunk = uids.slice(i, i + chunkSize);
    await auth.deleteUsers(chunk);
  }
}

async function listAuthSmokeUsers() {
  const result = new Map();
  let pageToken;
  do {
    const page = await auth.listUsers(1000, pageToken);
    for (const user of page.users) {
      if (matchesEmailMarker(user.email)) {
        result.set(user.uid, {
          uid: user.uid,
          email: user.email || '',
          reason: 'auth-email-marker',
        });
      }
    }
    pageToken = page.pageToken;
  } while (pageToken);
  return result;
}

async function main() {
  const deletionPlan = {};
  const scanStats = {};

  const authSmokeUsers = await listAuthSmokeUsers();
  const targetUserIds = new Set(authSmokeUsers.keys());

  scanStats.users = await scanCollection('users', async (doc) => {
    const data = doc.data() || {};
    if (targetUserIds.has(doc.id) || shouldMatchUserDoc(data)) {
      targetUserIds.add(doc.id);
      addDocDelete(deletionPlan, 'users', doc.ref, 'user-smoke-profile');
    }
  });

  const ticketIds = new Set();
  scanStats.support_tickets = await scanCollection('support_tickets', async (doc) => {
    const data = doc.data() || {};
    const email = lower(data.email);
    const userId = lower(data.userId);
    if (matchesEmailMarker(email) || (userId && targetUserIds.has(userId))) {
      ticketIds.add(doc.id);
      addDocDelete(deletionPlan, 'support_tickets', doc.ref, 'ticket-smoke-owner');
    }
  });

  const tipIds = new Set();
  scanStats.tips = await scanCollection('tips', async (doc) => {
    const data = doc.data() || {};
    const senderEmail = lower(data.senderEmail);
    const userId = lower(data.userId);
    if (matchesEmailMarker(senderEmail) || (userId && targetUserIds.has(userId))) {
      tipIds.add(doc.id);
      addDocDelete(deletionPlan, 'tips', doc.ref, 'tip-smoke-owner');
    }
  });

  scanStats.tip_events = await scanCollection('tip_events', async (doc) => {
    const data = doc.data() || {};
    const tipId = asString(data.tipId);
    if (tipId && tipIds.has(tipId)) {
      addDocDelete(deletionPlan, 'tip_events', doc.ref, 'tip-event-linked');
    }
  });

  scanStats.user_notifications = await scanCollection(
    'user_notifications',
    async (doc) => {
      const data = doc.data() || {};
      const userId = lower(data.userId);
      const source = lower(data.source);
      const sourceId = asString(data.sourceId);
      if (userId && targetUserIds.has(userId)) {
        addDocDelete(
          deletionPlan,
          'user_notifications',
          doc.ref,
          'notification-user-match',
        );
        return;
      }
      if (source === 'support_ticket' && sourceId && ticketIds.has(sourceId)) {
        addDocDelete(
          deletionPlan,
          'user_notifications',
          doc.ref,
          'notification-ticket-match',
        );
        return;
      }
      if (source === 'tip' && sourceId && tipIds.has(sourceId)) {
        addDocDelete(
          deletionPlan,
          'user_notifications',
          doc.ref,
          'notification-tip-match',
        );
      }
    },
  );

  scanStats.incidents = await scanCollection('incidents', async (doc) => {
    const data = doc.data() || {};
    const reportedBy = lower(data.reportedBy);
    if (reportedBy && targetUserIds.has(reportedBy)) {
      addDocDelete(deletionPlan, 'incidents', doc.ref, 'incident-user-match');
    }
  });

  scanStats.registrations = await scanCollection('registrations', async (doc) => {
    const data = doc.data() || {};
    const uid = lower(data.uid);
    if (uid && targetUserIds.has(uid)) {
      addDocDelete(deletionPlan, 'registrations', doc.ref, 'registration-user-match');
    }
  });

  scanStats.votes = await scanCollection('votes', async (doc) => {
    const data = doc.data() || {};
    const uid = lower(data.uid);
    if (uid && targetUserIds.has(uid)) {
      addDocDelete(deletionPlan, 'votes', doc.ref, 'vote-user-match');
    }
  });

  scanStats.device_risks = await scanCollection('device_risks', async (doc) => {
    const data = doc.data() || {};
    const uid = lower(data.uid);
    if (uid && targetUserIds.has(uid)) {
      addDocDelete(deletionPlan, 'device_risks', doc.ref, 'risk-user-match');
    }
  });

  const summary = {
    apply: argv.apply,
    emailMarkers,
    userMarkers,
    targetUsers: [...targetUserIds],
    authUsersToDelete: [...authSmokeUsers.values()],
    scanned: scanStats,
    deleteCounts: Object.fromEntries(
      Object.entries(deletionPlan).map(([collection, docs]) => [
        collection,
        docs.size,
      ]),
    ),
  };

  console.log('Cleanup summary:', JSON.stringify(summary, null, 2));

  if (!argv.apply) {
    console.log(
      '\nDry run only. Re-run with --apply to delete the matched Firestore/Auth records.',
    );
    return;
  }

  const orderedCollections = [
    'tip_events',
    'user_notifications',
    'support_tickets',
    'tips',
    'incidents',
    'votes',
    'registrations',
    'device_risks',
    'users',
  ];

  for (const collection of orderedCollections) {
    const docs = deletionPlan[collection];
    if (!docs || docs.size === 0) continue;
    await deleteDocRefs([...docs.values()].map((entry) => entry.ref));
    console.log(`Deleted ${docs.size} document(s) from ${collection}.`);
  }

  const authUidsToDelete = [...new Set([...authSmokeUsers.keys()])];
  if (authUidsToDelete.length > 0) {
    await deleteAuthUsers(authUidsToDelete);
    console.log(`Deleted ${authUidsToDelete.length} Firebase Auth user(s).`);
  } else {
    console.log('No Firebase Auth users matched.');
  }
}

main().catch((error) => {
  console.error('Cleanup failed:', error);
  process.exit(1);
});
