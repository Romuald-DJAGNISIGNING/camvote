#!/usr/bin/env node
/* eslint-disable no-console */
import { execSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

function fail(message) {
  throw new Error(message);
}

function warn(message) {
  console.warn(`WARN: ${message}`);
}

function info(message) {
  console.log(message);
}

function readFileIfExists(filePath) {
  try {
    return fs.readFileSync(filePath);
  } catch {
    return null;
  }
}

function readTextIfExists(filePath) {
  const buf = readFileIfExists(filePath);
  return buf ? buf.toString('utf8') : null;
}

function findFirstExistingFile(filePaths) {
  for (const filePath of filePaths) {
    if (!filePath) continue;
    try {
      if (fs.existsSync(filePath)) return filePath;
    } catch {
      // ignore
    }
  }
  return null;
}

function base64OfFile(filePath) {
  const buf = readFileIfExists(filePath);
  if (!buf) fail(`Missing file: ${filePath}`);
  return buf.toString('base64');
}

function parseGitHubRepoFromOrigin() {
  const url = execSync('git remote get-url origin', { encoding: 'utf8' }).trim();
  // Supported:
  // - https://github.com/OWNER/REPO.git
  // - git@github.com:OWNER/REPO.git
  const httpsMatch = url.match(/^https:\/\/github\.com\/([^/]+)\/([^/]+?)(?:\.git)?$/i);
  if (httpsMatch) return { owner: httpsMatch[1], repo: httpsMatch[2] };

  const sshMatch = url.match(/^git@github\.com:([^/]+)\/([^/]+?)(?:\.git)?$/i);
  if (sshMatch) return { owner: sshMatch[1], repo: sshMatch[2] };

  fail(`Unsupported origin url format: ${url}`);
}

function parseAndroidApiKeyFromGoogleServices(jsonText) {
  const parsed = JSON.parse(jsonText);
  const clients = Array.isArray(parsed?.client) ? parsed.client : [];
  const match = clients.find((client) => {
    const pkg = client?.client_info?.android_client_info?.package_name;
    return typeof pkg === 'string' && pkg.trim() === 'com.camvote.app';
  });
  const keys = Array.isArray(match?.api_key) ? match.api_key : [];
  const key = keys.map((e) => e?.current_key).find((v) => typeof v === 'string' && v.trim().length > 0);
  if (!key) fail('Unable to extract Android Firebase API key from android/app/google-services.json');
  return key.trim();
}

function parseIosApiKeyFromPlist(plistText) {
  const match = plistText.match(/<key>\s*API_KEY\s*<\/key>\s*<string>\s*([^<]+)\s*<\/string>/is);
  if (!match) fail('Unable to extract iOS Firebase API key from ios/Runner/GoogleService-Info.plist');
  return match[1].trim();
}

function parseKeyProperties(text) {
  const out = {};
  for (const rawLine of text.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;
    const idx = line.indexOf('=');
    if (idx <= 0) continue;
    const k = line.slice(0, idx).trim();
    const v = line.slice(idx + 1).trim();
    if (k) out[k] = v;
  }
  return out;
}

async function ghApi({ method, url, token, body }) {
  const headers = {
    'accept': 'application/vnd.github+json',
    'content-type': 'application/json',
    'user-agent': 'camvote-secrets-bootstrap',
    'x-github-api-version': '2022-11-28',
    'authorization': `Bearer ${token}`,
  };
  const response = await fetch(url, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await response.text();
  if (!response.ok) {
    if (
      response.status === 403 &&
      /\/actions\/secrets\/public-key$/i.test(url) &&
      text.includes('Resource not accessible by personal access token')
    ) {
      throw new Error(
        'GitHub rejected this PAT for Actions Secrets.\n' +
          '- If you created a fine-grained PAT: enable Repository permissions -> Secrets: Read and write, and ensure it has access to this repo.\n' +
          "- If you created a classic PAT: ensure it has the 'repo' scope.\n",
      );
    }
    // Never include request bodies (they may contain secrets). Response bodies are safe to show.
    throw new Error(`GitHub API ${method} ${url} failed (${response.status}): ${text}`);
  }
  return text ? JSON.parse(text) : null;
}

async function main() {
  const pat =
    process.env.CAMVOTE_GITHUB_PAT?.trim() ||
    process.env.GITHUB_PAT?.trim() ||
    process.env.GH_PAT?.trim() ||
    '';
  if (!pat) {
    fail(
      'Missing PAT. Set CAMVOTE_GITHUB_PAT (recommended) in your shell environment, then re-run.\n' +
        'Example (PowerShell):\n' +
        '  $env:CAMVOTE_GITHUB_PAT=\"<your_pat>\"; node scripts/bootstrap-actions-secrets.mjs',
    );
  }

  let sodium;
  try {
    sodium = (await import('tweetsodium')).default;
  } catch {
    fail(
      'Missing dependency "tweetsodium". Install it (without saving) and retry:\n' +
        '  cd scripts && npm.cmd i tweetsodium --no-save',
    );
  }

  const { owner, repo } = parseGitHubRepoFromOrigin();
  info(`Target repo: ${owner}/${repo}`);

  const projectRoot = execSync('git rev-parse --show-toplevel', { encoding: 'utf8' }).trim();
  if (!projectRoot) fail('Unable to resolve git repo root.');

  // Source files (ignored by git, but present locally).
  const googleServicesPath = path.join(projectRoot, 'android', 'app', 'google-services.json');
  const iosPlistPath = path.join(projectRoot, 'ios', 'Runner', 'GoogleService-Info.plist');
  const keyPropsPath = path.join(projectRoot, 'android', 'key.properties');
  const keystorePath = path.join(projectRoot, 'android', 'app', 'upload-keystore.jks');

  const googleServicesText = readTextIfExists(googleServicesPath);
  const iosPlistText = readTextIfExists(iosPlistPath);
  const keyPropsText = readTextIfExists(keyPropsPath);

  if (!googleServicesText) fail(`Missing ${googleServicesPath}`);
  if (!iosPlistText) fail(`Missing ${iosPlistPath}`);
  if (!keyPropsText) fail(`Missing ${keyPropsPath}`);
  if (!readFileIfExists(keystorePath)) fail(`Missing ${keystorePath}`);

  const androidApiKey = parseAndroidApiKeyFromGoogleServices(googleServicesText);
  const iosApiKey = parseIosApiKeyFromPlist(iosPlistText);
  const keyProps = parseKeyProperties(keyPropsText);

  const storePassword = `${keyProps.storePassword || ''}`.trim();
  const keyAlias = `${keyProps.keyAlias || ''}`.trim();
  const keyPassword = `${keyProps.keyPassword || ''}`.trim();
  if (!storePassword || !keyAlias || !keyPassword) {
    fail('android/key.properties is missing storePassword, keyAlias, or keyPassword.');
  }

  const webApiKey = (process.env.CAMVOTE_FIREBASE_WEB_API_KEY || '').trim() || androidApiKey;
  if (!process.env.CAMVOTE_FIREBASE_WEB_API_KEY) {
    warn('CAMVOTE_FIREBASE_WEB_API_KEY not found in env; using Android API key as fallback.');
  }

  // Get repo public key for Actions secrets encryption.
  const publicKey = await ghApi({
    method: 'GET',
    url: `https://api.github.com/repos/${owner}/${repo}/actions/secrets/public-key`,
    token: pat,
  });
  const keyId = publicKey?.key_id;
  const key = publicKey?.key;
  if (!keyId || !key) {
    fail('Failed to read repo Actions public key.');
  }

  function encryptSecret(value) {
    const messageBytes = Buffer.from(value);
    const keyBytes = Buffer.from(key, 'base64');
    const encryptedBytes = sodium.seal(messageBytes, keyBytes);
    return Buffer.from(encryptedBytes).toString('base64');
  }

  const secrets = new Map();

  // Shared Firebase API keys used by CI/web builds.
  secrets.set('CAMVOTE_FIREBASE_WEB_API_KEY', webApiKey);
  secrets.set('CAMVOTE_FIREBASE_ANDROID_API_KEY', androidApiKey);
  secrets.set('CAMVOTE_FIREBASE_IOS_API_KEY', iosApiKey);

  // Android release signing + config.
  secrets.set('ANDROID_UPLOAD_KEYSTORE_BASE64', base64OfFile(keystorePath));
  secrets.set('ANDROID_KEYSTORE_PASSWORD', storePassword);
  secrets.set('ANDROID_KEY_ALIAS', keyAlias);
  secrets.set('ANDROID_KEY_PASSWORD', keyPassword);
  secrets.set('ANDROID_GOOGLE_SERVICES_JSON_BASE64', Buffer.from(googleServicesText, 'utf8').toString('base64'));

  // iOS firebase native config (required for TestFlight workflow when plist isn't committed).
  secrets.set('IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64', Buffer.from(iosPlistText, 'utf8').toString('base64'));

  // Optional: iOS TestFlight signing + App Store Connect API key.
  //
  // Place your Apple assets under tmp/ios-signing (gitignored) OR provide explicit paths:
  // - tmp/ios-signing/dist.p12
  // - tmp/ios-signing/profile.mobileprovision
  // - tmp/ios-signing/AuthKey_<KEY_ID>.p8
  const iosSigningDir = path.join(projectRoot, 'tmp', 'ios-signing');
  const p12Path =
    (process.env.IOS_DISTRIBUTION_CERTIFICATE_P12_PATH || '').trim() ||
    findFirstExistingFile([
      path.join(iosSigningDir, 'dist.p12'),
      path.join(iosSigningDir, 'camvote-dist.p12'),
      path.join(iosSigningDir, 'ios_distribution.p12'),
      path.join(iosSigningDir, 'certificate.p12'),
    ]);
  const mobileprovisionPath =
    (process.env.IOS_PROVISIONING_PROFILE_PATH || '').trim() ||
    findFirstExistingFile([
      path.join(iosSigningDir, 'profile.mobileprovision'),
      path.join(iosSigningDir, 'camvote.mobileprovision'),
      path.join(iosSigningDir, 'provisioning.mobileprovision'),
    ]);
  const p8Path =
    (process.env.APP_STORE_CONNECT_API_PRIVATE_KEY_PATH || '').trim() ||
    findFirstExistingFile([
      path.join(iosSigningDir, 'appstore.p8'),
      path.join(iosSigningDir, 'AuthKey.p8'),
    ]);

  // If a standard AuthKey_<KEYID>.p8 file exists, prefer it and infer KEY_ID from filename.
  let inferredKeyId = '';
  try {
    if (fs.existsSync(iosSigningDir)) {
      const p8Candidates = fs
        .readdirSync(iosSigningDir, { withFileTypes: true })
        .filter((e) => e.isFile() && /^AuthKey_[A-Za-z0-9]+\.p8$/i.test(e.name))
        .map((e) => path.join(iosSigningDir, e.name))
        .sort();
      if (p8Candidates.length > 0) {
        const chosen = p8Candidates[0];
        inferredKeyId = path.basename(chosen).replace(/^AuthKey_([A-Za-z0-9]+)\.p8$/i, '$1');
        if (!p8Path) {
          // Only adopt this file path if the caller didn't override.
          // (If overridden, still use inferredKeyId when possible.)
          // eslint-disable-next-line no-unused-vars
          // (We can't reassign const p8Path; handle below.)
        }
      }
    }
  } catch {
    // ignore
  }

  const appStoreKeyId = (process.env.APP_STORE_CONNECT_KEY_ID || '').trim() || inferredKeyId;
  const appStoreIssuerId = (process.env.APP_STORE_CONNECT_ISSUER_ID || '').trim();
  const appleTeamId = (process.env.APPLE_TEAM_ID || '').trim();
  const p12Password = (process.env.IOS_DISTRIBUTION_CERTIFICATE_PASSWORD || '').trim();

  const effectiveP8Path =
    p8Path ||
    (inferredKeyId
      ? findFirstExistingFile([path.join(iosSigningDir, `AuthKey_${inferredKeyId}.p8`)])
      : null);

  const wantTestFlightSecrets = Boolean(
    p12Path ||
      mobileprovisionPath ||
      effectiveP8Path ||
      appleTeamId ||
      appStoreIssuerId ||
      appStoreKeyId ||
      p12Password,
  );

  if (wantTestFlightSecrets) {
    const missing = [];
    if (!p12Path) missing.push('IOS_DISTRIBUTION_CERTIFICATE_P12_PATH (or tmp/ios-signing/dist.p12)');
    if (!mobileprovisionPath) missing.push('IOS_PROVISIONING_PROFILE_PATH (or tmp/ios-signing/profile.mobileprovision)');
    if (!p12Password) missing.push('IOS_DISTRIBUTION_CERTIFICATE_PASSWORD');
    if (!appleTeamId) missing.push('APPLE_TEAM_ID');
    if (!appStoreIssuerId) missing.push('APP_STORE_CONNECT_ISSUER_ID');
    if (!appStoreKeyId) missing.push('APP_STORE_CONNECT_KEY_ID (or AuthKey_<KEY_ID>.p8 filename)');
    if (!effectiveP8Path) missing.push('APP_STORE_CONNECT_API_PRIVATE_KEY_PATH (or tmp/ios-signing/AuthKey_<KEY_ID>.p8)');

    if (missing.length > 0) {
      warn('iOS TestFlight secrets requested but some inputs are missing:');
      for (const item of missing) warn(`- ${item}`);
      warn('Skipping TestFlight secrets. Re-run after providing the missing inputs.');
    } else {
      secrets.set('IOS_DISTRIBUTION_CERTIFICATE_P12_BASE64', base64OfFile(p12Path));
      secrets.set('IOS_DISTRIBUTION_CERTIFICATE_PASSWORD', p12Password);
      secrets.set('IOS_PROVISIONING_PROFILE_BASE64', base64OfFile(mobileprovisionPath));
      secrets.set('APPLE_TEAM_ID', appleTeamId);
      secrets.set('APP_STORE_CONNECT_ISSUER_ID', appStoreIssuerId);
      secrets.set('APP_STORE_CONNECT_KEY_ID', appStoreKeyId);
      secrets.set('APP_STORE_CONNECT_API_PRIVATE_KEY_BASE64', base64OfFile(effectiveP8Path));
    }
  }

  info(`Preparing to upsert ${secrets.size} GitHub Actions secrets...`);

  for (const [name, value] of secrets.entries()) {
    const encrypted = encryptSecret(value);
    await ghApi({
      method: 'PUT',
      url: `https://api.github.com/repos/${owner}/${repo}/actions/secrets/${encodeURIComponent(name)}`,
      token: pat,
      body: { encrypted_value: encrypted, key_id: keyId },
    });
    info(`- set ${name} (len=${value.length})`);
  }

  info('Done.');
  info('Remaining manual secrets (not auto-discoverable from this repo unless you provide local files/env vars):');
  info('- PLAY_STORE_SERVICE_ACCOUNT_JSON (if you want Play upload from CI)');
  info('- iOS TestFlight: IOS_DISTRIBUTION_CERTIFICATE_P12_BASE64, IOS_DISTRIBUTION_CERTIFICATE_PASSWORD, IOS_PROVISIONING_PROFILE_BASE64');
  info('- App Store Connect: APPLE_TEAM_ID, APP_STORE_CONNECT_ISSUER_ID, APP_STORE_CONNECT_KEY_ID, APP_STORE_CONNECT_API_PRIVATE_KEY (or *_BASE64)');
}

main().catch((err) => {
  console.error(err?.stack || String(err));
  process.exitCode = 1;
});
