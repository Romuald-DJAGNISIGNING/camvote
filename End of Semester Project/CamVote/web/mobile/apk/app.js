const RELEASE_API_URL =
  'https://api.github.com/repos/Romuald-DJAGNISIGNING/camvote/releases/latest';
const FALLBACK_PUBLIC_URL = '/#/public';
const AUTO_START_DELAY_MS = 860;
const TRANSFER_REDIRECT_DELAY_MS = 1180;
const FALLBACK_TARGETS = {
  universal:
    'https://github.com/Romuald-DJAGNISIGNING/camvote/releases/latest/download/app-universal-release.apk',
  arm64:
    'https://github.com/Romuald-DJAGNISIGNING/camvote/releases/latest/download/app-arm64-v8a-release.apk',
  armeabi:
    'https://github.com/Romuald-DJAGNISIGNING/camvote/releases/latest/download/app-armeabi-v7a-release.apk',
  x64:
    'https://github.com/Romuald-DJAGNISIGNING/camvote/releases/latest/download/app-x86_64-release.apk'
};

const copy = {
  en: {
    brandTag: 'Official civic platform',
    pill: 'Android transfer',
    heroTitle: 'Preparing your CamVote Android download.',
    heroSubtitle:
      'Stay on this page while CamVote securely sends the installation package to your device.',
    statusReady: 'Secure handoff ready',
    statusMeta: 'Universal APK preferred for most phones',
    statusCopy:
      'We are checking the latest signed Android package and preparing the transfer.',
    statusLoading: 'Locating the latest signed Android release...',
    statusStarting:
      'Transfer started. Android should prompt for the package in a moment.',
    statusComplete:
      'Download triggered. If nothing happens, use the manual download button below.',
    statusFailed:
      'We could not confirm the latest package automatically. Manual fallback links are ready below.',
    ctaPrimary: 'Start CamVote download',
    ctaManual: 'Download manually',
    ctaPublic: 'Open Public Portal',
    downloadNote:
      'If the transfer does not begin automatically, tap the manual download button above.',
    altTitle: 'Other Android builds',
    altUniversal: 'Universal APK',
    altArm64: 'ARM64',
    altArmeabi: 'ARMv7',
    altX64: 'x86_64',
    serverLabel: 'CamVote release server',
    phoneLabel: 'Your Android phone',
    stepLocateTitle: 'Locate the latest signed build',
    stepLocateBody: 'CamVote checks the most recent Android release package.',
    stepTransferTitle: 'Start the transfer',
    stepTransferBody:
      'A secure handoff begins from the release server to your phone.',
    stepInstallTitle: 'Install with confidence',
    stepInstallBody:
      'Open the APK after download and complete the Android install flow.',
    footer: 'Official civic participation platform.'
  },
  fr: {
    brandTag: 'Plateforme civique officielle',
    pill: 'Transfert Android',
    heroTitle: 'Preparation du telechargement Android CamVote.',
    heroSubtitle:
      'Restez sur cette page pendant que CamVote transfere le package d installation vers votre appareil.',
    statusReady: 'Transfert securise pret',
    statusMeta: 'APK universel recommande pour la plupart des telephones',
    statusCopy:
      'Nous verifions la derniere version Android signee et preparons le transfert.',
    statusLoading: 'Recherche de la derniere release Android signee...',
    statusStarting:
      'Transfert lance. Android devrait vous proposer le package dans un instant.',
    statusComplete:
      'Telechargement declenche. Si rien ne se passe, utilisez le bouton manuel ci-dessous.',
    statusFailed:
      'Impossible de confirmer automatiquement le dernier package. Les liens de secours sont disponibles ci-dessous.',
    ctaPrimary: 'Demarrer le telechargement CamVote',
    ctaManual: 'Telecharger manuellement',
    ctaPublic: 'Ouvrir le Portail Public',
    downloadNote:
      'Si le transfert ne demarre pas automatiquement, utilisez le bouton de telechargement manuel ci-dessus.',
    altTitle: 'Autres builds Android',
    altUniversal: 'APK universel',
    altArm64: 'ARM64',
    altArmeabi: 'ARMv7',
    altX64: 'x86_64',
    serverLabel: 'Serveur release CamVote',
    phoneLabel: 'Votre telephone Android',
    stepLocateTitle: 'Trouver la derniere build signee',
    stepLocateBody: 'CamVote verifie le package Android le plus recent.',
    stepTransferTitle: 'Lancer le transfert',
    stepTransferBody:
      'Un transfert securise commence du serveur release vers votre telephone.',
    stepInstallTitle: 'Installer en confiance',
    stepInstallBody:
      'Ouvrez l APK apres telechargement et terminez l installation Android.',
    footer: 'Plateforme officielle de participation civique.'
  }
};

let currentLang = 'en';
let autoStarted = false;

function dict() {
  return copy[currentLang] || copy.en;
}

function applyLanguage(lang) {
  currentLang = copy[lang] ? lang : 'en';
  document.documentElement.lang = currentLang;
  const data = dict();
  document.querySelectorAll('[data-i18n]').forEach((el) => {
    const key = el.dataset.i18n;
    if (data[key]) {
      el.textContent = data[key];
    }
  });
  document.querySelectorAll('.lang-btn').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.lang === currentLang);
  });
}

function initLang() {
  const params = new URLSearchParams(window.location.search);
  const requested = params.get('lang');
  const fallback =
    (navigator.language || 'en').toLowerCase().startsWith('fr') ? 'fr' : 'en';
  applyLanguage(requested || fallback);
}

function resolveUrl(url) {
  if (!url) return '';
  if (/^[a-z][a-z0-9+.-]*:/i.test(url)) return url;
  if (window.location.protocol === 'file:') {
    if (url.startsWith('/mobile/')) {
      return url.replace('/mobile/', '../');
    }
    if (url.startsWith('/')) {
      return `.${url}`;
    }
    return url;
  }
  return new URL(url, `${window.location.origin}/`).toString();
}

function resolvePublicUrl() {
  const params = new URLSearchParams(window.location.search);
  return resolveUrl(params.get('public') || FALLBACK_PUBLIC_URL);
}

function updateProgress(percent) {
  const fill = document.getElementById('progressFill');
  if (fill) {
    fill.style.width = `${Math.max(12, Math.min(percent, 100))}%`;
  }
}

function updateStatus(key, chipState = '') {
  const statusCopy = document.getElementById('statusCopy');
  const statusChip = document.getElementById('statusChip');
  const data = dict();
  if (statusCopy && data[key]) {
    statusCopy.textContent = data[key];
  }
  if (statusChip) {
    statusChip.classList.remove('is-active', 'is-complete');
    if (chipState) {
      statusChip.classList.add(chipState);
    }
  }
}

function setStepState(stepId, state) {
  const el = document.getElementById(stepId);
  if (!el) return;
  el.classList.remove('step-active', 'step-complete');
  if (state) {
    el.classList.add(state);
  }
}

async function fetchLatestTargets() {
  const response = await fetch(RELEASE_API_URL, {
    headers: { Accept: 'application/vnd.github+json' }
  });
  if (!response.ok) {
    throw new Error(`GitHub latest release lookup failed: ${response.status}`);
  }
  const payload = await response.json();
  const assets = Array.isArray(payload.assets) ? payload.assets : [];
  const named = (name) => assets.find((asset) => asset && asset.name === name);
  return {
    main:
      named('app-universal-release.apk')?.url ||
      named('app-arm64-v8a-release.apk')?.url ||
      FALLBACK_TARGETS.universal,
    universal:
      named('app-universal-release.apk')?.url || FALLBACK_TARGETS.universal,
    arm64: named('app-arm64-v8a-release.apk')?.url || FALLBACK_TARGETS.arm64,
    armeabi:
      named('app-armeabi-v7a-release.apk')?.url || FALLBACK_TARGETS.armeabi,
    x64: named('app-x86_64-release.apk')?.url || FALLBACK_TARGETS.x64
  };
}

function resolveTargetsFromQuery() {
  const params = new URLSearchParams(window.location.search);
  const target = params.get('target') || params.get('apk');
  return {
    main: target || '',
    universal: params.get('apk_universal') || '',
    arm64: params.get('apk_arm64') || '',
    armeabi: params.get('apk_armeabi') || params.get('apk_v7a') || '',
    x64: params.get('apk_x64') || ''
  };
}

function buildAltLinks(targets) {
  const wrap = document.getElementById('altLinks');
  if (!wrap) return;
  wrap.innerHTML = '';
  const data = dict();
  [
    ['universal', data.altUniversal],
    ['arm64', data.altArm64],
    ['armeabi', data.altArmeabi],
    ['x64', data.altX64]
  ].forEach(([key, label]) => {
    const url = resolveUrl(targets[key]);
    if (!url) return;
    const link = document.createElement('a');
    link.className = 'alt-link';
    link.href = url;
    link.rel = 'noopener';
    link.textContent = label;
    wrap.appendChild(link);
  });
}

function wirePrimaryActions(mainTarget) {
  const primary = document.getElementById('startDownload');
  const manual = document.getElementById('manualDownload');
  const publicPortal = document.getElementById('publicPortal');
  const publicUrl = resolvePublicUrl();
  if (primary) {
    primary.href = mainTarget;
    primary.onclick = (event) => {
      event.preventDefault();
      startDownloadFlow(mainTarget);
    };
  }
  if (manual) {
    manual.href = mainTarget;
    manual.onclick = (event) => {
      event.preventDefault();
      triggerDownload(mainTarget);
    };
  }
  if (publicPortal) {
    publicPortal.href = publicUrl;
  }
}

function triggerDownload(target) {
  const resolved = resolveUrl(target);
  if (!resolved) return;
  updateStatus('statusComplete', 'is-complete');
  setStepState('stepLocate', 'step-complete');
  setStepState('stepTransfer', 'step-complete');
  setStepState('stepInstall', 'step-active');
  updateProgress(100);
  window.setTimeout(() => {
    window.location.href = resolved;
  }, 120);
}

function startDownloadFlow(target) {
  if (!target || autoStarted) return;
  autoStarted = true;
  updateStatus('statusStarting', 'is-active');
  setStepState('stepLocate', 'step-complete');
  setStepState('stepTransfer', 'step-active');
  updateProgress(68);
  window.setTimeout(() => {
    setStepState('stepTransfer', 'step-complete');
    setStepState('stepInstall', 'step-active');
    updateProgress(92);
  }, TRANSFER_REDIRECT_DELAY_MS - 220);
  window.setTimeout(() => {
    triggerDownload(target);
  }, TRANSFER_REDIRECT_DELAY_MS);
}

async function hydrateDownloadTargets() {
  updateStatus('statusLoading', 'is-active');
  updateProgress(28);
  setStepState('stepLocate', 'step-active');
  const explicit = resolveTargetsFromQuery();
  const hasExplicitTarget = Object.values(explicit).some(
    (value) => `${value}`.trim().length > 0
  );
  let targets = explicit;
  let usedFallback = false;

  if (!hasExplicitTarget) {
    try {
      targets = await fetchLatestTargets();
    } catch (_) {
      targets = {
        main: FALLBACK_TARGETS.universal,
        universal: FALLBACK_TARGETS.universal,
        arm64: FALLBACK_TARGETS.arm64,
        armeabi: FALLBACK_TARGETS.armeabi,
        x64: FALLBACK_TARGETS.x64
      };
      usedFallback = true;
      updateStatus('statusFailed');
    }
  }

  const mainTarget = resolveUrl(
    targets.main ||
      targets.universal ||
      targets.arm64 ||
      FALLBACK_TARGETS.universal
  );
  buildAltLinks({
    universal: targets.universal || FALLBACK_TARGETS.universal,
    arm64: targets.arm64 || FALLBACK_TARGETS.arm64,
    armeabi: targets.armeabi || FALLBACK_TARGETS.armeabi,
    x64: targets.x64 || FALLBACK_TARGETS.x64
  });
  wirePrimaryActions(mainTarget);
  updateProgress(48);
  if (mainTarget && !usedFallback) {
    updateStatus('statusCopy');
  }

  const params = new URLSearchParams(window.location.search);
  if (params.get('auto') === '1' && mainTarget) {
    window.setTimeout(() => {
      startDownloadFlow(mainTarget);
    }, AUTO_START_DELAY_MS);
  }
}

window.addEventListener('DOMContentLoaded', () => {
  initLang();
  hydrateDownloadTargets();
  document.querySelectorAll('.lang-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      applyLanguage(btn.dataset.lang);
      hydrateDownloadTargets();
    });
  });
});
