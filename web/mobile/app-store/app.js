const DEFAULT_SUPPORT_EMAIL = 'camvoteappassist@gmail.com';
const DEFAULT_PUBLIC_URL = '/#/public';
const DEFAULT_API_BASE = 'https://camvote.romuald-djagnisigning.workers.dev';
const DEFAULT_LAUNCH_DATE = '2026-06-30T23:59:59Z';
const BURST_PARTICLE_COUNT = 12;
const REDIRECT_AFTER_NOTIFY_MS = 2200;
const LOCAL_NOTIFY_EMAIL_KEY = 'camvote_ios_notify_email';

const mailCopy = {
  en: {
    subject: 'CamVote iOS Launch - Notify me',
    body: [
      'Hello CamVote support,',
      '',
      'Please notify me when CamVote is available on the App Store.',
      '',
      'While waiting, I will follow the public results portal.',
      '',
      'Thank you.'
    ]
  },
  fr: {
    subject: 'Sortie iOS CamVote - Prevenez-moi',
    body: [
      'Bonjour equipe CamVote,',
      '',
      'Merci de me prevenir lorsque CamVote sera disponible sur l App Store.',
      '',
      'En attendant, je consulterai le portail public des resultats.',
      '',
      'Merci.'
    ]
  }
};

const copy = {
  en: {
    brandTag: 'Official civic platform',
    pill: 'App Store',
    heroTitle: 'CamVote for iOS is on the way.',
    heroSubtitle: 'The App Store release is under review. We will launch the moment Apple approval is complete.',
    ctaNotify: 'Notify me',
    ctaPlay: 'Get it on Google Play',
    ctaPublic: 'Open Public Portal',
    emailLabel: 'Your email',
    emailPlaceholder: 'you@email.com',
    emailHint: 'We only use it to notify you when the iOS app is live.',
    emailError: 'Please enter a valid email address.',
    notifySuccess: 'Thanks! You are on the list. We will notify you when iOS is live.',
    notifyAlready: 'This email is already on the notification list.',
    notifySending: 'Saving...',
    notifyRedirect: 'Redirecting you to the public portal...',
    notifyError: 'We could not save your request. Please try again.',
    status1Title: 'Submitted',
    status1Body: 'App Store review in progress',
    status2Title: 'Final checks',
    status2Body: 'Security & compliance pass',
    status3Title: 'Launch',
    status3Body: 'Live the moment approval lands',
    countdownTitle: 'Launch countdown',
    countdownWindow: 'Target: Q2 2026',
    countdownDays: 'Days',
    countdownHours: 'Hours',
    countdownMinutes: 'Minutes',
    countdownSeconds: 'Seconds',
    note: 'Want updates? We will publish the App Store link here the second it is live.',
    storeSub: 'Official civic mobile app',
    comingSoon: 'Coming soon on the App Store',
    launchEta: 'We are targeting a release right after review completion.',
    tag1: 'Secure',
    tag2: 'Verified',
    tag3: 'Official',
    footer: 'Official civic participation platform.'
  },
  fr: {
    brandTag: 'Plateforme civique officielle',
    pill: 'App Store',
    heroTitle: 'CamVote iOS arrive bientot.',
    heroSubtitle: 'La sortie App Store est en cours de validation. Nous publierons des que Apple donne son accord.',
    ctaNotify: 'Prevenez-moi',
    ctaPlay: 'Disponible sur Google Play',
    ctaPublic: 'Portail Public',
    emailLabel: 'Votre email',
    emailPlaceholder: 'vous@email.com',
    emailHint: 'Nous utilisons uniquement votre email pour vous prevenir.',
    emailError: 'Veuillez saisir une adresse email valide.',
    notifySuccess: 'Merci ! Votre email est enregistre pour la sortie iOS.',
    notifyAlready: 'Cet email est deja inscrit a la liste de notification.',
    notifySending: 'Enregistrement...',
    notifyRedirect: 'Redirection vers le portail public...',
    notifyError: 'Impossible d enregistrer votre demande. Veuillez reessayer.',
    status1Title: 'Soumis',
    status1Body: 'Revue App Store en cours',
    status2Title: 'Derniers controles',
    status2Body: 'Verification securite et conformite',
    status3Title: 'Lancement',
    status3Body: 'Disponible des validation',
    countdownTitle: 'Compte a rebours',
    countdownWindow: 'Cible : T2 2026',
    countdownDays: 'Jours',
    countdownHours: 'Heures',
    countdownMinutes: 'Minutes',
    countdownSeconds: 'Secondes',
    note: 'Des nouvelles ? Nous publierons le lien App Store ici des sa mise en ligne.',
    storeSub: 'Application civique officielle',
    comingSoon: 'Bientot sur l App Store',
    launchEta: 'Nous visons une sortie juste apres la fin de la revue.',
    tag1: 'Securise',
    tag2: 'Verifie',
    tag3: 'Officiel',
    footer: 'Plateforme officielle de participation civique.'
  }
};

let currentLang = 'en';

function applyLanguage(lang) {
  const data = copy[lang] || copy.en;
  currentLang = lang;
  document.documentElement.lang = lang;
  document.querySelectorAll('[data-i18n]').forEach((el) => {
    const key = el.dataset.i18n;
    if (data[key]) {
      el.textContent = data[key];
    }
  });
  document.querySelectorAll('.lang-btn').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.lang === lang);
  });
  document.querySelectorAll('[data-i18n-placeholder]').forEach((el) => {
    const key = el.dataset.i18nPlaceholder;
    if (data[key]) {
      el.setAttribute('placeholder', data[key]);
    }
  });
  updateLaunchWindowLabel();
}

function initLang() {
  const params = new URLSearchParams(window.location.search);
  const requested = params.get('lang');
  const fallback = (navigator.language || 'en').toLowerCase().startsWith('fr') ? 'fr' : 'en';
  const lang = requested || fallback;
  applyLanguage(lang);
}

function setLinks() {
  const params = new URLSearchParams(window.location.search);
  const play = params.get('play');
  const publicUrl = resolvePublicUrl();
  const playCta = document.getElementById('playCta');
  const publicCta = document.getElementById('publicCta');
  if (playCta) {
    if (play) {
      playCta.href = resolveUrl(play);
      playCta.style.display = 'inline-flex';
    } else {
      playCta.style.display = 'none';
    }
  }
  if (publicCta) {
    publicCta.href = publicUrl;
    publicCta.addEventListener('click', (event) => {
      event.preventDefault();
      window.location.href = publicUrl;
    });
  }
}

function resolvePublicUrl() {
  const params = new URLSearchParams(window.location.search);
  return resolveUrl(params.get('public') || DEFAULT_PUBLIC_URL);
}

function resolveUrl(url) {
  if (!url) return '';
  if (/^[a-z][a-z0-9+.-]*:/i.test(url)) {
    return url;
  }
  if (window.location.protocol === 'file:') {
    if (url.startsWith('/')) {
      return `.${url}`;
    }
    return url;
  }
  const base = window.location.origin.replace(/\/$/, '');
  if (url.startsWith('/')) return `${base}${url}`;
  return `${base}/${url}`;
}

function resolveApiBase() {
  const params = new URLSearchParams(window.location.search);
  const api = params.get('api');
  if (api) return resolveUrl(api);
  return DEFAULT_API_BASE;
}

function setNotifyStatus(statusEl, type, message) {
  if (!statusEl) return;
  statusEl.textContent = message || '';
  statusEl.classList.remove('success', 'error');
  if (type) statusEl.classList.add(type);
}

function ensureBurstParticles(container) {
  if (!container) return;
  if (container.children.length) return;
  for (let i = 0; i < BURST_PARTICLE_COUNT; i += 1) {
    const dot = document.createElement('span');
    const angle = (360 / BURST_PARTICLE_COUNT) * i;
    dot.style.setProperty('--burst-angle', `${angle}deg`);
    container.appendChild(dot);
  }
}

function triggerBurst(container) {
  if (!container) return;
  ensureBurstParticles(container);
  container.classList.remove('active');
  void container.offsetWidth;
  container.classList.add('active');
}

function resolveLaunchDate() {
  const params = new URLSearchParams(window.location.search);
  const fromQuery = params.get('eta');
  if (fromQuery) {
    const parsed = new Date(fromQuery);
    if (!Number.isNaN(parsed.getTime())) {
      return parsed;
    }
  }
  return new Date(DEFAULT_LAUNCH_DATE);
}

function updateLaunchWindowLabel() {
  const label = document.querySelector('#launchClock .launch-clock-head strong');
  if (!label) return;
  const target = resolveLaunchDate();
  const locale = currentLang === 'fr' ? 'fr-FR' : 'en-US';
  const formatted = new Intl.DateTimeFormat(locale, {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  }).format(target);
  label.textContent = currentLang === 'fr' ? `Cible : ${formatted}` : `Target: ${formatted}`;
}

function initCountdown() {
  const daysEl = document.getElementById('countDays');
  const hoursEl = document.getElementById('countHours');
  const minutesEl = document.getElementById('countMinutes');
  const secondsEl = document.getElementById('countSeconds');
  if (!daysEl || !hoursEl || !minutesEl || !secondsEl) return;

  const target = resolveLaunchDate();
  const update = () => {
    const now = Date.now();
    const diff = Math.max(0, target.getTime() - now);
    const days = Math.floor(diff / 86400000);
    const hours = Math.floor((diff % 86400000) / 3600000);
    const minutes = Math.floor((diff % 3600000) / 60000);
    const seconds = Math.floor((diff % 60000) / 1000);
    daysEl.textContent = String(days);
    hoursEl.textContent = String(hours).padStart(2, '0');
    minutesEl.textContent = String(minutes).padStart(2, '0');
    secondsEl.textContent = String(seconds).padStart(2, '0');
  };

  update();
  window.setInterval(update, 1000);
}

async function sendNotifyRequest(email, lang, publicUrl) {
  const apiBase = resolveApiBase();
  if (!apiBase) {
    return { ok: false, status: 'no_api' };
  }
  const payload = {
    email,
    lang,
    publicUrl,
    source: 'app-store',
    userAgent: navigator.userAgent || ''
  };
  const body = JSON.stringify(payload);
  const url = `${apiBase.replace(/\/$/, '')}/v1/public/notify-ios`;
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body,
      keepalive: true
    });
    let data = {};
    try {
      data = await response.json();
    } catch {
      data = {};
    }
    if (!response.ok) {
      return { ok: false, status: 'request_failed', data };
    }
    const status = typeof data.status === 'string' ? data.status : 'subscribed';
    return { ok: true, status, data };
  } catch {
    return { ok: false, status: 'network_error' };
  }
}

function buildMailto(email, lang, userEmail) {
  const template = mailCopy[lang] || mailCopy.en;
  const subject = encodeURIComponent(template.subject);
  const bodyLines = [...template.body];
  if (userEmail) {
    bodyLines.push('');
    bodyLines.push(`User email: ${userEmail}`);
  }
  const body = encodeURIComponent(bodyLines.join('\n'));
  return `mailto:${email}?subject=${subject}&body=${body}`;
}

function saveNotifyEmail(email) {
  if (!email) return;
  try {
    localStorage.setItem(LOCAL_NOTIFY_EMAIL_KEY, email);
  } catch {
    // ignore
  }
}

function restoreNotifyEmail() {
  try {
    return localStorage.getItem(LOCAL_NOTIFY_EMAIL_KEY) || '';
  } catch {
    return '';
  }
}

function initNotify() {
  const notifyCta = document.getElementById('notifyCta');
  const emailInput = document.getElementById('notifyEmail');
  const form = document.querySelector('.notify-form');
  const status = document.getElementById('notifyStatus');
  const burst = document.getElementById('notifyBurst');
  if (!notifyCta) return;
  ensureBurstParticles(burst);
  const rememberedEmail = restoreNotifyEmail();
  if (emailInput && rememberedEmail && !emailInput.value) {
    emailInput.value = rememberedEmail;
  }

  let redirectTimerId = null;
  const setBusy = (busy, messages) => {
    notifyCta.classList.toggle('loading', busy);
    notifyCta.setAttribute('aria-disabled', busy ? 'true' : 'false');
    notifyCta.textContent = busy ? messages.notifySending : messages.ctaNotify;
  };

  const clearError = () => {
    if (form) form.classList.remove('invalid');
    setNotifyStatus(status, '', '');
  };
  if (emailInput) {
    emailInput.addEventListener('input', clearError);
  }
  notifyCta.addEventListener('click', async (event) => {
    event.preventDefault();
    if (notifyCta.getAttribute('aria-disabled') === 'true') return;

    const params = new URLSearchParams(window.location.search);
    const support = params.get('support') || notifyCta.dataset.support || DEFAULT_SUPPORT_EMAIL;
    const publicUrl = resolvePublicUrl();
    const emailValue = emailInput ? emailInput.value.trim() : '';
    const lang = currentLang || 'en';
    const messages = copy[lang] || copy.en;

    if (emailInput) {
      const valid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailValue);
      if (!valid) {
        if (form) form.classList.add('invalid');
        emailInput.focus();
        return;
      }
    }
    if (form) form.classList.remove('invalid');
    setNotifyStatus(status, '', '');
    setBusy(true, messages);

    if (redirectTimerId) {
      window.clearTimeout(redirectTimerId);
      redirectTimerId = null;
    }

    const result = await sendNotifyRequest(emailValue, lang, publicUrl);
    setBusy(false, messages);

    if (result.ok) {
      saveNotifyEmail(emailValue);
      triggerBurst(burst);
      const successMessage = result.status === 'already_subscribed'
        ? messages.notifyAlready
        : messages.notifySuccess;
      setNotifyStatus(status, 'success', `${successMessage} ${messages.notifyRedirect}`);
      redirectTimerId = window.setTimeout(() => {
        window.location.href = publicUrl;
      }, REDIRECT_AFTER_NOTIFY_MS);
      return;
    }

    setNotifyStatus(status, 'error', messages.notifyError);
    const mailto = buildMailto(support, lang, emailValue);
    window.open(mailto, '_blank', 'noopener,noreferrer');
  });
}

function initReveal() {
  const revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          revealObserver.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.2 }
  );
  document.querySelectorAll('.reveal').forEach((el) => revealObserver.observe(el));
}

document.querySelectorAll('.lang-btn').forEach((btn) => {
  btn.addEventListener('click', () => applyLanguage(btn.dataset.lang));
});

initLang();
setLinks();
initNotify();
initReveal();
initCountdown();
