import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import admin from 'firebase-admin';
import minimist from 'minimist';

const argv = minimist(process.argv.slice(2), {
  string: ['serviceAccount', 'dartFile'],
  boolean: ['purge', 'includeCenters'],
  default: {
    purge: true,
    includeCenters: true,
    dartFile: path.resolve(
      process.cwd(),
      '../lib/features/dashboards/data/admin_content_seed_service.dart',
    ),
  },
});

const serviceAccountPath =
  argv.serviceAccount ||
  process.env.FIREBASE_SERVICE_ACCOUNT ||
  path.resolve(process.cwd(), '../service-account.json');

if (!fs.existsSync(serviceAccountPath)) {
  throw new Error(
    `Firebase service account not found at ${serviceAccountPath}. ` +
      'Provide the path via --serviceAccount or FIREBASE_SERVICE_ACCOUNT.',
  );
}

const dartFilePath = path.resolve(argv.dartFile);
if (!fs.existsSync(dartFilePath)) {
  throw new Error(`Seed source not found: ${dartFilePath}`);
}

const dartSource = fs.readFileSync(dartFilePath, 'utf8');

admin.initializeApp({
  credential: admin.credential.cert(
    JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8')),
  ),
});

const firestore = admin.firestore();

function unescapeDartString(raw) {
  return raw
    .replace(/\\\\/g, '\\')
    .replace(/\\n/g, '\n')
    .replace(/\\r/g, '\r')
    .replace(/\\t/g, '\t')
    .replace(/\\'/g, "'")
    .replace(/\\"/g, '"');
}

function extractFunctionBody(fnName) {
  const re = new RegExp(`\\b${fnName}\\s*\\(\\)\\s*\\{`);
  const match = dartSource.match(re);
  if (!match || match.index == null) {
    throw new Error(`Could not find ${fnName} in Dart seed file.`);
  }
  const slice = dartSource.slice(match.index);
  const braceStart = slice.indexOf('{');
  if (braceStart === -1) {
    throw new Error(`Could not parse ${fnName} body.`);
  }
  let depth = 0;
  for (let i = braceStart; i < slice.length; i += 1) {
    const ch = slice[i];
    if (ch === '{') depth += 1;
    if (ch === '}') {
      depth -= 1;
      if (depth === 0) {
        return slice.slice(braceStart + 1, i);
      }
    }
  }
  throw new Error(`Unclosed body for ${fnName}.`);
}

function extractStringList(fnName) {
  const body = extractFunctionBody(fnName);
  const listMatch = body.match(/return\s+\[([\s\S]*?)\]\s*\.join\([\s\S]*?\);/m);
  if (!listMatch) {
    throw new Error(`Could not parse ${fnName} list in Dart seed file.`);
  }
  const listBody = listMatch[1];
  const strings = [];
  const strRe = /'((?:\\\\'|[^'])*)'/g;
  let m;
  while ((m = strRe.exec(listBody)) !== null) {
    strings.push(unescapeDartString(m[1]));
  }
  return strings.join('\n');
}

function extractListLiteral(fnName) {
  const body = extractFunctionBody(fnName);
  const listMatch = body.match(/return\s+\[([\s\S]*?)\];/m);
  if (!listMatch) {
    throw new Error(`Could not parse ${fnName} list in Dart seed file.`);
  }
  return `[${listMatch[1]}]`;
}

function extractMapLiteral(fnName) {
  const body = extractFunctionBody(fnName);
  const mapMatch = body.match(/return\s+\{([\s\S]*?)\};/m);
  if (!mapMatch) {
    throw new Error(`Could not parse ${fnName} map in Dart seed file.`);
  }
  return `{${mapMatch[1]}}`;
}

function parseLiteral(literal, context = {}) {
  return vm.runInNewContext(`(${literal})`, { ...context }, { timeout: 1000 });
}

function replaceAll(haystack, needle, replacement) {
  return haystack.split(needle).join(replacement);
}

function buildSeedPayload() {
  const nowIso = new Date().toISOString();

  const legalHighlightsEn = extractStringList('_legalHighlightsEn');
  const legalHighlightsFr = extractStringList('_legalHighlightsFr');
  const constitutionEn = extractStringList('_constitutionHighlightsEn');
  const constitutionFr = extractStringList('_constitutionHighlightsFr');
  const registrationEn = extractStringList('_registrationGuideEn');
  const registrationFr = extractStringList('_registrationGuideFr');

  let civicLessons = extractListLiteral('_civicLessons');
  let transparency = extractListLiteral('_transparencyUpdates');
  let checklist = extractListLiteral('_observationChecklist');
  let legalDocs = extractListLiteral('_legalDocuments');
  let calendar = extractListLiteral('_electionCalendar');
  let electionsInfo = extractMapLiteral('_electionsInfo');

  const year = new Date().getFullYear().toString();
  const start = new Date(Number(year), 0, 1).toISOString();
  const end = new Date(Number(year), 7, 31).toISOString();

  calendar = replaceAll(calendar, '${year}', year);
  calendar = replaceAll(calendar, 'start.toIso8601String()', JSON.stringify(start));
  calendar = replaceAll(calendar, 'end.toIso8601String()', JSON.stringify(end));

  transparency = replaceAll(
    transparency,
    'publishedAt',
    JSON.stringify(nowIso),
  );

  legalDocs = replaceAll(
    legalDocs,
    '_legalHighlightsEn()',
    JSON.stringify(legalHighlightsEn),
  );
  legalDocs = replaceAll(
    legalDocs,
    '_legalHighlightsFr()',
    JSON.stringify(legalHighlightsFr),
  );
  legalDocs = replaceAll(
    legalDocs,
    '_constitutionHighlightsEn()',
    JSON.stringify(constitutionEn),
  );
  legalDocs = replaceAll(
    legalDocs,
    '_constitutionHighlightsFr()',
    JSON.stringify(constitutionFr),
  );
  legalDocs = replaceAll(
    legalDocs,
    '_registrationGuideEn()',
    JSON.stringify(registrationEn),
  );
  legalDocs = replaceAll(
    legalDocs,
    '_registrationGuideFr()',
    JSON.stringify(registrationFr),
  );

  electionsInfo = replaceAll(
    electionsInfo,
    'DateTime.now().toIso8601String()',
    JSON.stringify(nowIso),
  );

  let centers = [];
  if (argv.includeCenters) {
    const noteMatch = dartSource.match(
      /const note\\s*=\\s*'([\\s\\S]*?)';/m,
    );
    const noteValue = noteMatch ? unescapeDartString(noteMatch[1]) : '';
    let centersLiteral = extractListLiteral('_votingCenters');
    centers = parseLiteral(centersLiteral, { note: noteValue });
  }

  return {
    civicLessons: parseLiteral(civicLessons),
    electionCalendar: parseLiteral(calendar),
    transparencyUpdates: parseLiteral(transparency),
    observationChecklist: parseLiteral(checklist),
    legalDocuments: parseLiteral(legalDocs),
    electionsInfo: parseLiteral(electionsInfo),
    votingCenters: centers,
  };
}

async function purgeCollection(collection) {
  const snap = await firestore.collection(collection).get();
  if (snap.empty) return 0;
  const batch = firestore.batch();
  snap.docs.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();
  return snap.size;
}

async function seedCollection(collection, items) {
  if (!Array.isArray(items)) return 0;
  let count = 0;
  const batch = firestore.batch();
  items.forEach((item) => {
    const id = (item.id || '').toString().trim();
    if (!id) return;
    const ref = firestore.collection(collection).doc(id);
    batch.set(
      ref,
      {
        ...item,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    count += 1;
  });
  if (count > 0) {
    await batch.commit();
  }
  return count;
}

async function seedDoc(collection, docId, data) {
  const ref = firestore.collection(collection).doc(docId);
  await ref.set(
    {
      ...data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  return true;
}

async function main() {
  const payload = buildSeedPayload();

  if (argv.purge) {
    await purgeCollection('civic_lessons');
    await purgeCollection('election_calendar');
    await purgeCollection('transparency_updates');
    await purgeCollection('observation_checklist');
    await purgeCollection('legal_documents');
    if (argv.includeCenters) {
      await purgeCollection('centers');
    }
  }

  const civic = await seedCollection('civic_lessons', payload.civicLessons);
  const calendar = await seedCollection('election_calendar', payload.electionCalendar);
  const transparency = await seedCollection(
    'transparency_updates',
    payload.transparencyUpdates,
  );
  const checklist = await seedCollection(
    'observation_checklist',
    payload.observationChecklist,
  );
  const legal = await seedCollection('legal_documents', payload.legalDocuments);
  const centers = argv.includeCenters
    ? await seedCollection('centers', payload.votingCenters)
    : 0;
  await seedDoc('public_content', 'elections_info', payload.electionsInfo);

  console.log('Seed complete:', {
    civic,
    calendar,
    transparency,
    checklist,
    legal,
    centers,
  });
}

main().catch((error) => {
  console.error('Seed failed:', error);
  process.exit(1);
});
