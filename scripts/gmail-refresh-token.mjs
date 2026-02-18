import http from 'node:http';
import crypto from 'node:crypto';
import minimist from 'minimist';

const argv = minimist(process.argv.slice(2), {
  string: ['clientId', 'clientSecret', 'port'],
  default: {
    port: '53682',
  },
});

const clientId = (argv.clientId || process.env.GMAIL_CLIENT_ID || '').trim();
const clientSecret = (argv.clientSecret || process.env.GMAIL_CLIENT_SECRET || '').trim();
const port = Number(argv.port || 53682);

if (!clientId) {
  throw new Error(
    'Missing client id. Pass --clientId or set env GMAIL_CLIENT_ID.',
  );
}
if (!clientSecret) {
  throw new Error(
    'Missing client secret. Pass --clientSecret or set env GMAIL_CLIENT_SECRET.',
  );
}
if (!Number.isFinite(port) || port < 1 || port > 65535) {
  throw new Error('Invalid port. Pass --port (1-65535).');
}

const redirectUri = `http://localhost:${port}/oauth2callback`;
const scope = 'https://www.googleapis.com/auth/gmail.send';
const state = crypto.randomUUID();

const authUrl = new URL('https://accounts.google.com/o/oauth2/v2/auth');
authUrl.searchParams.set('client_id', clientId);
authUrl.searchParams.set('redirect_uri', redirectUri);
authUrl.searchParams.set('response_type', 'code');
authUrl.searchParams.set('scope', scope);
authUrl.searchParams.set('access_type', 'offline');
authUrl.searchParams.set('prompt', 'consent');
authUrl.searchParams.set('include_granted_scopes', 'true');
authUrl.searchParams.set('state', state);

console.log('');
console.log('1) Open this URL in a browser (sign in as camvoteappassist@gmail.com):');
console.log(authUrl.toString());
console.log('');
console.log(`2) After allowing access, Google will redirect to: ${redirectUri}`);
console.log('   Keep this terminal open until it prints the refresh token.');
console.log('');

const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url || '/', redirectUri);
    if (url.pathname !== '/oauth2callback') {
      res.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' });
      res.end('Not found');
      return;
    }

    const error = (url.searchParams.get('error') || '').trim();
    if (error) {
      res.writeHead(400, { 'content-type': 'text/plain; charset=utf-8' });
      res.end(`OAuth error: ${error}`);
      console.error('OAuth error:', error);
      server.close();
      return;
    }

    const code = (url.searchParams.get('code') || '').trim();
    const receivedState = (url.searchParams.get('state') || '').trim();
    if (!code) {
      res.writeHead(400, { 'content-type': 'text/plain; charset=utf-8' });
      res.end('Missing code');
      server.close();
      return;
    }
    if (!receivedState || receivedState !== state) {
      res.writeHead(400, { 'content-type': 'text/plain; charset=utf-8' });
      res.end('State mismatch');
      console.error('State mismatch');
      server.close();
      return;
    }

    const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        code,
        client_id: clientId,
        client_secret: clientSecret,
        redirect_uri: redirectUri,
        grant_type: 'authorization_code',
      }).toString(),
    });

    const raw = await tokenRes.text();
    let payload = null;
    try {
      payload = JSON.parse(raw);
    } catch {
      payload = null;
    }

    if (!tokenRes.ok) {
      res.writeHead(500, { 'content-type': 'text/plain; charset=utf-8' });
      res.end('Token exchange failed. Check the terminal output.');
      console.error('Token exchange failed:', tokenRes.status, raw);
      server.close();
      return;
    }

    const refreshToken = `${payload?.refresh_token || ''}`.trim();
    if (!refreshToken) {
      res.writeHead(200, { 'content-type': 'text/plain; charset=utf-8' });
      res.end(
        'No refresh token returned. This usually means Google did not issue an offline token.\n' +
          'Try again with a new OAuth client or revoke the app access in Google Account -> Security.',
      );
      console.error(
        'No refresh token returned. Payload:',
        JSON.stringify(payload, null, 2),
      );
      server.close();
      return;
    }

    res.writeHead(200, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('OK. You can close this tab and return to the terminal.');
    console.log('');
    console.log('Refresh token (save this securely):');
    console.log(refreshToken);
    console.log('');
    server.close();
  } catch (err) {
    res.writeHead(500, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('Unexpected error. Check the terminal output.');
    console.error('Unexpected error:', err?.message || err);
    server.close();
  }
});

server.listen(port, '127.0.0.1', () => {
  console.log(`Listening on http://127.0.0.1:${port} ...`);
});

