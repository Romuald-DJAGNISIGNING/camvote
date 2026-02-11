import fs from 'node:fs';
import path from 'node:path';
import admin from 'firebase-admin';
import minimist from 'minimist';

const argv = minimist(process.argv.slice(2), {
  string: ['email', 'password', 'fullName', 'phone', 'username', 'serviceAccount'],
  default: {
    email: 'admin@camvote.app',
    password: 'CamvoteAdmin!23',
    fullName: 'CamVote Default Admin',
    username: 'camvote-admin',
  },
});

const serviceAccountPath =
  argv.serviceAccount ||
  process.env.FIREBASE_SERVICE_ACCOUNT ||
  path.resolve(process.cwd(), 'service-account.json');

if (!fs.existsSync(serviceAccountPath)) {
  throw new Error(
    `Firebase service account not found at ${serviceAccountPath}. ` +
      'Provide the path via --serviceAccount or FIREBASE_SERVICE_ACCOUNT.'
  );
}

const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const firestore = admin.firestore();
const auth = admin.auth();

async function upsertAdmin() {
  const { email, fullName, password, phone, username } = argv;
  console.log('Seeding default admin user:', email);

  let firebaseUser;
  try {
    firebaseUser = await auth.getUserByEmail(email);
    console.log('Existing Firebase Auth user found, updating metadata.');
    await auth.updateUser(firebaseUser.uid, {
      displayName: fullName,
      phoneNumber: phone || undefined,
    });
  } catch (error) {
    console.log('Creating Firebase Auth user for admin.');
    firebaseUser = await auth.createUser({
      email,
      password,
      displayName: fullName,
      phoneNumber: phone || undefined,
    });
  }

  const userDoc = firestore.doc(`users/${firebaseUser.uid}`);
  await userDoc.set(
    {
      email,
      role: 'admin',
      fullName,
      username,
      status: 'active',
      verified: true,
      voterId: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  console.log('Admin seed complete. Login with the seeded email/password.');
}

upsertAdmin()
  .catch((error) => {
    console.error('Failed to seed admin user:', error);
    process.exit(1);
  })
  .finally(() => process.exit(0));
