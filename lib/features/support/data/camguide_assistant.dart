import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../../core/theme/role_theme.dart';
import '../models/camguide_chat.dart';

class CamGuideAssistant {
  static const double _minimumIntentScore = 1.15;

  CamGuideReply reply({
    required String question,
    required Locale locale,
    required AppRole role,
    String? lastIntentId,
  }) {
    final isFrench = locale.languageCode.toLowerCase().startsWith('fr');
    final normalizedQuestion = _normalize(question);
    final questionTokens = _tokenize(normalizedQuestion);

    if (questionTokens.isEmpty) {
      return _introReply(locale: locale, role: role);
    }

    final quickReply = _quickReply(
      normalizedQuestion: normalizedQuestion,
      questionTokens: questionTokens,
      role: role,
      isFrench: isFrench,
      locale: locale,
    );
    if (quickReply != null) {
      return quickReply;
    }

    final followUpReply = _followUpReply(
      normalizedQuestion: normalizedQuestion,
      questionTokens: questionTokens,
      role: role,
      isFrench: isFrench,
      locale: locale,
      lastIntentId: lastIntentId,
    );
    if (followUpReply != null) {
      return followUpReply;
    }

    CamGuideIntent? bestIntent;
    double bestScore = 0;
    CamGuideIntent? secondIntent;
    double secondScore = 0;
    for (final intent in _intents) {
      final score = _scoreIntent(
        intent: intent,
        normalizedQuestion: normalizedQuestion,
        questionTokens: questionTokens,
      );
      if (score > bestScore) {
        secondIntent = bestIntent;
        secondScore = bestScore;
        bestScore = score;
        bestIntent = intent;
      } else if (score > secondScore) {
        secondScore = score;
        secondIntent = intent;
      }
    }

    if (bestIntent == null || bestScore < _minimumIntentScore) {
      return _fallbackReply(
        locale: locale,
        role: role,
      );
    }

    final answer = isFrench ? bestIntent.answerFr : bestIntent.answerEn;
    final followUps = <String>[
      ...(isFrench ? bestIntent.followUpsFr : bestIntent.followUpsEn),
      if (secondIntent != null)
        ...(isFrench ? secondIntent.followUpsFr : secondIntent.followUpsEn),
      ...starterPrompts(locale, role),
    ];
    return CamGuideReply(
      answer: answer,
      followUps: _dedupePreserveOrder(followUps).take(5).toList(),
      sourceHints: bestIntent.sourceHints,
      confidence: min(0.99, max(0.35, bestScore / 4.4)),
      intentId: bestIntent.id,
    );
  }

  List<String> starterPrompts(Locale locale, AppRole role) {
    final isFrench = locale.languageCode.toLowerCase().startsWith('fr');
    final common = isFrench
        ? <String>[
            'Comment verifier mon inscription ?',
            'Comment devenir observateur ?',
            'Que faire si je soupconne une fraude ?',
            'Le vote est-il prive ?',
            'Le mode hors ligne synchronise quoi exactement ?',
            'Comment contacter le help desk en direct ?',
          ]
        : <String>[
            'How do I verify my registration?',
            'How can I become an observer?',
            'What should I do if I suspect fraud?',
            'Is my vote private?',
            'What is synced in offline mode?',
            'How do I reach live help desk?',
          ];

    return switch (role) {
      AppRole.admin =>
        isFrench
            ? <String>[
                ...common,
                'Comment traiter les tickets support rapidement ?',
                'Comment verifier les notifications admin ?',
              ]
            : <String>[
                ...common,
                'How do I handle support tickets quickly?',
                'How do I review admin alerts?',
              ],
      AppRole.observer =>
        isFrench
            ? <String>[
                ...common,
                'Comment soumettre un incident avec preuves ?',
                'Observer peut-il voter ?',
              ]
            : <String>[
                ...common,
                'How do I report an incident with evidence?',
                'Can observer accounts vote?',
              ],
      AppRole.voter =>
        isFrench
            ? <String>[
                ...common,
                'Comment recuperer mon recu de vote ?',
                'Pourquoi ma verification prend du temps ?',
                'Ou voir les stats publiques par tranche d age ?',
              ]
            : <String>[
                ...common,
                'How do I get my vote receipt?',
                'Why is my verification taking longer?',
                'Where can I see public age-band stats?',
              ],
      AppRole.public => common,
    };
  }

  CamGuideReply _introReply({required Locale locale, required AppRole role}) {
    final isFrench = locale.languageCode.toLowerCase().startsWith('fr');
    final roleHint = _roleIntroHint(role: role, isFrench: isFrench);
    return CamGuideReply(
      answer: isFrench
          ? 'Bonjour. Je suis CamGuide.\n$roleHint\nComment puis-je vous aider aujourd\'hui ?'
          : 'Hi. I am CamGuide.\n$roleHint\nHow can I help you today?',
      followUps: starterPrompts(locale, role),
      sourceHints: const <String>[
        'ELECAM official channels',
        'Constitutional Council publications',
        'CamVote legal library and civic guides',
      ],
      confidence: 0.3,
    );
  }

  CamGuideReply _fallbackReply({
    required Locale locale,
    required AppRole role,
  }) {
    final isFrench = locale.languageCode.toLowerCase().startsWith('fr');
    final body = isFrench
        ? 'Je peux vous aider. Est-ce une question sur CamVote, ou un sujet general ?\n\nSi c\'est sur CamVote: dites moi votre role (electeur/observateur/admin) et l\'ecran ou vous etes.\nSi c\'est general: dites moi votre objectif et votre contexte, et je vous propose une demarche claire.\n\nSi vous preferez, choisissez un theme: inscription, verification, vote, observateur, resultats, notifications, support, hors ligne.'
        : 'I can help. Is this about CamVote, or a general question?\n\nIf it\'s CamVote: tell me your role (voter/observer/admin) and which screen you are on.\nIf it\'s general: tell me your goal and context, and I\'ll propose a clear approach.\n\nIf you prefer, pick a topic: registration, verification, voting, observer, results, notifications, support, offline mode.';
    return CamGuideReply(
      answer: body,
      followUps: starterPrompts(locale, role),
      sourceHints: const <String>[
        'ELECAM official channels',
        'Constitutional Council publications',
        'CamVote legal library and civic guides',
      ],
      confidence: 0.22,
    );
  }

  String _roleIntroHint({required AppRole role, required bool isFrench}) {
    return switch (role) {
      AppRole.admin => isFrench
          ? 'Vous etes dans le portail Admin. Je peux vous aider a gerer les elections, les electeurs, les observateurs, les incidents, le support, les tips, l audit et la securite.'
          : 'You are in the Admin portal. I can help you manage elections, voters, observers, incidents, support, tips, audits, and security.',
      AppRole.observer => isFrench
          ? 'Vous etes en mode Observateur (lecture seule). Je peux vous aider a signaler des incidents, suivre vos rapports, et utiliser les outils de transparence. Un observateur ne peut pas voter.'
          : 'You are in Observer mode (read-only). I can help you report incidents, track your reports, and use transparency tools. Observers cannot vote.',
      AppRole.voter => isFrench
          ? 'Vous etes en mode Electeur. Je peux vous aider pour l inscription, la verification, le vote securise et les recus.'
          : 'You are in Voter mode. I can help with registration, verification, secure voting, and receipts.',
      AppRole.public => isFrench
          ? 'Vous etes dans le portail Public. Je peux vous aider a explorer les resultats, les centres de vote, l education civique et la verification d inscription.'
          : 'You are in the Public portal. I can help you explore results, voting centers, civic education, and registration verification.',
    };
  }

  CamGuideReply? _followUpReply({
    required String normalizedQuestion,
    required Set<String> questionTokens,
    required AppRole role,
    required bool isFrench,
    required Locale locale,
    required String? lastIntentId,
  }) {
    final normalizedLast = lastIntentId?.trim() ?? '';
    if (normalizedLast.isEmpty) return null;

    final looksLikeFollowUp =
        normalizedQuestion.contains('tell me more') ||
        normalizedQuestion.contains('more details') ||
        normalizedQuestion.contains('explain') ||
        normalizedQuestion.contains('details') ||
        normalizedQuestion.contains('continue') ||
        normalizedQuestion.contains('why') ||
        normalizedQuestion.contains('encore') ||
        normalizedQuestion.contains('plus') ||
        (questionTokens.length <= 3 &&
            _containsAny(questionTokens, const <String>{
              'more',
              'details',
              'detail',
              'explain',
              'why',
              'again',
              'continue',
              'plus',
              'encore',
              'pourquoi',
              'expliquer',
            }));
    if (!looksLikeFollowUp) return null;

    CamGuideIntent? intent;
    for (final item in _intents) {
      if (item.id == normalizedLast) {
        intent = item;
        break;
      }
    }
    if (intent == null) return null;

    final details = isFrench ? intent.detailsFr : intent.detailsEn;
    final answer = details.trim().isNotEmpty
        ? details
        : (isFrench
            ? 'Bien sur. Sur quelle partie voulez vous plus de details (etapes, documents, securite, ou probleme precis) ?'
            : 'Sure. Which part do you want more detail on (steps, documents, security, or a specific problem)?');

    final followUps = <String>[
      ...(isFrench ? intent.followUpsFr : intent.followUpsEn),
      ...starterPrompts(locale, role),
    ];
    return CamGuideReply(
      answer: answer,
      followUps: _dedupePreserveOrder(followUps).take(5).toList(),
      sourceHints: intent.sourceHints,
      confidence: 0.82,
      intentId: intent.id,
    );
  }

  CamGuideReply? _quickReply({
    required String normalizedQuestion,
    required Set<String> questionTokens,
    required AppRole role,
    required bool isFrench,
    required Locale locale,
  }) {
    const camVoteTokens = <String>{
      'camvote',
      'onboarding',
      'portal',
      'login',
      'password',
      'register',
      'registration',
      'verify',
      'verification',
      'vote',
      'receipt',
      'observer',
      'admin',
      'dashboard',
      'ticket',
      'support',
      'notifications',
      'settings',
      'qr',
      'taptap',
      'remitly',
      'maxit',
      'orange',
      'money',
    };
    final isLikelyChitChat =
        normalizedQuestion.length <= 28 &&
        questionTokens.length <= 4 &&
        questionTokens.intersection(camVoteTokens).isEmpty;
    if (_containsAny(questionTokens, const <String>{
      'hello',
      'hi',
      'bonjour',
      'salut',
      'hey',
    })) {
      return CamGuideReply(
        answer: isFrench
            ? 'Salut. Je suis CamGuide.\nComment ca va aujourd\'hui ?\nDites moi ce que vous voulez faire (inscription, vote, observateur, resultats, notifications, support, tips) et je vous guide pas a pas.'
            : 'Hi. I am CamGuide.\nHow are you today?\nTell me what you want to do (registration, voting, observer, results, notifications, support, tips) and I will guide you step by step.',
        followUps: starterPrompts(locale, role),
        sourceHints: const <String>['CamVote guide'],
        confidence: 0.9,
      );
    }
    if (normalizedQuestion.contains('how are you') ||
        normalizedQuestion.contains('how r u') ||
        normalizedQuestion.contains('ca va') ||
        normalizedQuestion.contains('comment ca va')) {
      return CamGuideReply(
        answer: isFrench
            ? 'Merci, je vais bien.\nEt vous ?\nDites moi ce que vous voulez faire dans CamVote et je vous guide etape par etape.'
            : 'Thanks for asking, I am doing well.\nHow about you?\nTell me what you want to do in CamVote and I will guide you step by step.',
        followUps: starterPrompts(locale, role),
        sourceHints: const <String>['CamVote help', 'CamVote guide'],
        confidence: 0.92,
      );
    }
    if (_containsAny(questionTokens, const <String>{
      'fine',
      'good',
      'great',
      'bien',
      'nickel',
      'super',
    }) &&
        isLikelyChitChat) {
      return CamGuideReply(
        answer: isFrench
            ? 'Parfait.\nSur quoi voulez vous avancer maintenant ?'
            : 'Great.\nWhat would you like to do next?',
        followUps: starterPrompts(locale, role),
        sourceHints: const <String>['CamVote guide'],
        confidence: 0.72,
      );
    }
    if (_containsAny(questionTokens, const <String>{
      'bad',
      'sad',
      'angry',
      'upset',
      'tired',
      'frustrated',
    }) &&
        isLikelyChitChat) {
      return CamGuideReply(
        answer: isFrench
            ? 'Je comprends.\nOn va regler ca calmement. Dites moi:\n1) votre role (electeur/observateur/admin)\n2) l ecran\n3) ce que vous voyez comme message'
            : 'I understand.\nLet us fix it calmly. Tell me:\n1) your role (voter/observer/admin)\n2) the screen\n3) the message you see',
        followUps: starterPrompts(locale, role),
        sourceHints: const <String>['CamVote troubleshooting flow'],
        confidence: 0.78,
      );
    }
    if (normalizedQuestion.contains('what can you do') ||
        normalizedQuestion.contains('what can u do') ||
        normalizedQuestion.contains('help me') ||
        normalizedQuestion.contains('que peux tu faire') ||
        normalizedQuestion.contains('tu peux faire quoi') ||
        normalizedQuestion.contains('aide moi')) {
      return CamGuideReply(
        answer: isFrench
            ? 'Je peux vous guider sur CamVote (inscription, verification, vote, observateur, incidents, resultats, notifications, hors ligne, support, tips).\nVous pouvez aussi me poser une question generale: je vous reponds ou je vous propose une demarche claire.'
            : 'I can guide you in CamVote (registration, verification, voting, observer rules, incidents, results, notifications, offline, support, tips).\nYou can also ask a general question: I will answer or propose a clear step-by-step approach.',
        followUps: starterPrompts(locale, role),
        sourceHints: const <String>['CamVote guide'],
        confidence: 0.9,
      );
    }
    if (normalizedQuestion.contains('bye') ||
        normalizedQuestion.contains('goodbye') ||
        normalizedQuestion.contains('see you') ||
        normalizedQuestion.contains('au revoir') ||
        normalizedQuestion.contains('a bientot') ||
        normalizedQuestion.contains('a plus')) {
      return CamGuideReply(
        answer: isFrench
            ? 'A bientot. Si vous avez besoin, revenez ici et dites moi ce que vous essayez de faire.'
            : 'See you soon. If you need help, come back and tell me what you are trying to do.',
        followUps: starterPrompts(locale, role),
        sourceHints: const <String>['CamVote guide'],
        confidence: 0.9,
      );
    }
    if (_containsAny(questionTokens, const <String>{
      'thanks',
      'thank',
      'merci',
    })) {
      return CamGuideReply(
        answer: isFrench
            ? 'Avec plaisir.\nDites moi ce que vous voulez faire ensuite, et je vous guide pas a pas.'
            : 'You are welcome.\nTell me what you want to do next, and I can guide you step by step.',
        followUps: starterPrompts(locale, role),
        sourceHints: const <String>[
          'CamVote help and support',
          'CamVote legal library',
        ],
        confidence: 0.95,
      );
    }
    if (_containsAny(questionTokens, const <String>{
      'stuck',
      'bloque',
      'blocked',
      'urgent',
      'help',
      'aide',
    })) {
      return CamGuideReply(
        answer: isFrench
            ? 'Je comprends.\nRestons calmes et procedons etape par etape. Dites moi:\n1) l ecran\n2) le bouton clique\n3) le message affiche'
            : 'I understand.\nLet us solve it step by step. Tell me:\n1) the screen\n2) the button you clicked\n3) the message shown',
        followUps: starterPrompts(locale, role),
        sourceHints: const <String>[
          'CamVote troubleshooting flow',
          'CamVote support workflow',
        ],
        confidence: 0.9,
      );
    }
    if (_containsAny(questionTokens, const <String>{
      'ok',
      'okay',
      'cool',
      'great',
      'nice',
      'daccord',
      'parfait',
    })) {
      return CamGuideReply(
        answer: isFrench
            ? 'Parfait. Quelle est la prochaine etape pour vous ?'
            : 'Great. What is the next step for you?',
        followUps: starterPrompts(locale, role),
        sourceHints: const <String>['CamVote guide'],
        confidence: 0.75,
      );
    }
    if (_containsAny(questionTokens, const <String>{
          'who',
          'what',
          'qui',
          'quoi',
        }) &&
        normalizedQuestion.contains('camguide')) {
      return _introReply(locale: locale, role: role);
    }
    return null;
  }

  double _scoreIntent({
    required CamGuideIntent intent,
    required String normalizedQuestion,
    required Set<String> questionTokens,
  }) {
    var score = 0.0;
    for (final keyword in intent.keywords) {
      final normalizedKeyword = _normalize(keyword);
      if (normalizedKeyword.isEmpty) continue;
      if (normalizedQuestion.contains(normalizedKeyword)) {
        score += normalizedKeyword.contains(' ') ? 1.4 : 1.0;
      }
      final keywordTokens = _tokenize(normalizedKeyword);
      if (keywordTokens.isEmpty) continue;
      final overlap = keywordTokens.intersection(questionTokens).length;
      if (overlap > 0) {
        score += overlap / keywordTokens.length;
      }
    }
    return score;
  }

  String _normalize(String raw) {
    final lower = _removeAccents(raw.toLowerCase().trim());
    if (lower.isEmpty) return '';
    return lower
        .replaceAll(RegExp(r'[^a-z0-9 ]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _containsAny(Set<String> haystack, Set<String> needles) {
    for (final value in needles) {
      if (haystack.contains(value)) return true;
    }
    return false;
  }

  Iterable<String> _dedupePreserveOrder(List<String> values) sync* {
    final seen = <String>{};
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || seen.contains(trimmed)) continue;
      seen.add(trimmed);
      yield trimmed;
    }
  }

  String _removeAccents(String input) {
    return input
        .replaceAll(RegExp(r'[\u00E0\u00E1\u00E2\u00E3\u00E4\u00E5]'), 'a')
        .replaceAll(RegExp(r'[\u00E8\u00E9\u00EA\u00EB]'), 'e')
        .replaceAll(RegExp(r'[\u00EC\u00ED\u00EE\u00EF]'), 'i')
        .replaceAll(RegExp(r'[\u00F2\u00F3\u00F4\u00F5\u00F6]'), 'o')
        .replaceAll(RegExp(r'[\u00F9\u00FA\u00FB\u00FC]'), 'u')
        .replaceAll('\u00FD', 'y')
        .replaceAll('\u00FF', 'y')
        .replaceAll('\u00E6', 'ae')
        .replaceAll('\u0153', 'oe')
        .replaceAll('\u00F1', 'n')
        .replaceAll('\u00E7', 'c')
        .replaceAll('\u00DF', 'ss');
  }

  Set<String> _tokenize(String raw) {
    return raw
        .split(' ')
        .map((part) => part.trim())
        .where((part) => part.length >= 2)
        .toSet();
  }
}

const _intents = <CamGuideIntent>[
  CamGuideIntent(
    id: 'registration_steps',
    keywords: <String>[
      'register',
      'registration',
      'how to register',
      'inscription',
      's inscrire',
      'inscrire',
      'documents',
      'national id',
      'piece',
      'document',
    ],
    answerEn:
        'To register, open Voter Registration, fill your identity details, complete document verification, biometric enrollment, and liveness check, then submit. Keep your registration ID and receipt. If you are offline, submission can queue and sync when connectivity is restored.',
    answerFr:
        'Pour vous inscrire, ouvrez Inscription Electeur, renseignez vos informations, faites la verification du document, la biometrie et la preuve de presence, puis soumettez. Conservez votre identifiant et votre recu. Hors ligne, certaines soumissions peuvent etre mises en file puis synchronisees.',
    detailsEn:
        'Step-by-step:\n'
        '1) Open Registration.\n'
        '2) Enter identity details exactly as on your document.\n'
        '3) Scan/verify the document (OCR) and fix any mismatches.\n'
        '4) Complete biometrics and liveness checks.\n'
        '5) Select a voting center if requested.\n'
        '6) Review, then submit.\n\n'
        'After submitting, keep your Registration ID and receipt. If you are offline, the submission may be queued and will auto-sync when connection returns.',
    detailsFr:
        'Etapes:\n'
        '1) Ouvrez Inscription.\n'
        '2) Saisissez vos informations exactement comme sur la piece.\n'
        '3) Scannez/verifiez le document (OCR) et corrigez les ecarts.\n'
        '4) Terminez la biometrie et la preuve de presence.\n'
        '5) Choisissez un centre de vote si demande.\n'
        '6) Verifiez, puis soumettez.\n\n'
        'Apres soumission, gardez votre identifiant et votre recu. Hors ligne, la soumission peut etre mise en file et se synchroniser automatiquement.',
    followUpsEn: <String>[
      'How do I verify my registration status?',
      'What if my document is rejected?',
      'What information is mandatory?',
    ],
    followUpsFr: <String>[
      'Comment verifier mon statut ?',
      'Que faire si mon document est rejete ?',
      'Quelles informations sont obligatoires ?',
    ],
    sourceHints: <String>['CamVote registration flow', 'ELECAM procedures'],
  ),
  CamGuideIntent(
    id: 'observer_requirements',
    keywords: <String>[
      'observer',
      'how to become observer',
      'accreditation',
      'mandate',
      'observateur',
      'devenir observateur',
      'accreditation observateur',
      'observer requirements',
      'observer documents',
    ],
    answerEn:
        'Observer access requires an official mandate and accreditation by the competent electoral authority in Cameroon. Typical supporting documents include mission mandate, legal identity documents, and sponsoring organization proof. The sponsoring body can be state institutions, political parties, civil society, NGOs, or international missions recognized by Cameroon authorities. Observer mode is read-only and cannot cast votes.',
    answerFr:
        'L acces observateur exige un mandat officiel et une accreditation par l autorite electorale competente au Cameroun. Les pieces habituelles sont le mandat de mission, une preuve d identite legale et la preuve de l organisme mandataire. L organisme peut etre une institution d etat, un parti, la societe civile, une ONG ou une mission internationale reconnue par les autorites camerounaises. Le mode observateur est en lecture seule et ne permet pas de voter.',
    detailsEn:
        'Practical steps:\n'
        '1) Contact the Admin/Help Desk to request observer access.\n'
        '2) Provide mandate/accreditation documents (and identity proof).\n'
        '3) Wait for review and approval.\n\n'
        'Important: Observer mode is read-only for oversight. It cannot vote.',
    detailsFr:
        'Etapes pratiques:\n'
        '1) Contactez l Admin / Help Desk pour demander l acces observateur.\n'
        '2) Fournissez les pieces de mandat/accreditation (et la preuve d identite).\n'
        '3) Attendez l examen et l approbation.\n\n'
        'Important: le mode Observateur est en lecture seule pour le controle. Il ne permet pas de voter.',
    followUpsEn: <String>[
      'Where do I submit observer documents?',
      'Can observer accounts be revoked?',
      'Can an observer switch to voter mode?',
    ],
    followUpsFr: <String>[
      'Ou soumettre les documents observateur ?',
      'Le compte observateur peut-il etre retire ?',
      'Un observateur peut-il basculer en mode electeur ?',
    ],
    sourceHints: <String>[
      'ELECAM accreditation channels',
      'CamVote observer policy',
    ],
  ),
  CamGuideIntent(
    id: 'vote_security',
    keywords: <String>[
      'private vote',
      'secure vote',
      'biometric',
      'liveness',
      'vote safety',
      'securite vote',
      'vote prive',
      'biometrie',
      'receipt',
      'recu',
    ],
    answerEn:
        'CamVote uses biometric confirmation, liveness checks, and signed audit artifacts for sensitive actions. Public dashboards show aggregated results, not private ballot identity. Never share your credentials or device unlock secrets. After successful vote finalization you can access a receipt for verification.',
    answerFr:
        'CamVote utilise la confirmation biometrque, la preuve de presence et des traces signees pour les actions sensibles. Les tableaux publics montrent des resultats agreges, pas l identite du bulletin. Ne partagez jamais vos identifiants ni vos secrets de deverrouillage. Apres validation du vote, un recu permet de verifier la trace.',
    detailsEn:
        'Security checklist:\n'
        '- Use your own trusted device and keep it updated.\n'
        '- Do not share passwords, reset codes, or device unlock secrets.\n'
        '- Complete biometrics + liveness only inside the official app.\n'
        '- After voting, keep your receipt/audit token for verification.\n\n'
        'Privacy note: Public pages show aggregates; they do not expose your private choice.',
    detailsFr:
        'Checklist securite:\n'
        '- Utilisez un appareil de confiance et a jour.\n'
        '- Ne partagez jamais mot de passe, codes, ni secrets de deverrouillage.\n'
        '- Faites biometrie + preuve de presence uniquement dans l app officielle.\n'
        '- Apres vote, gardez le recu / token d audit pour verifier.\n\n'
        'Confidentialite: les pages publiques affichent des agregrats, pas votre choix.',
    followUpsEn: <String>[
      'How do I report suspicious activity?',
      'Where can I see my vote receipt?',
    ],
    followUpsFr: <String>[
      'Comment signaler une activite suspecte ?',
      'Ou voir mon recu de vote ?',
    ],
    sourceHints: <String>['CamVote security policy', 'CamVote audit flow'],
  ),
  CamGuideIntent(
    id: 'fraud_report',
    keywords: <String>[
      'fraud',
      'report incident',
      'suspicious',
      'signaler fraude',
      'incident',
      'abus',
      'evidence',
      'proof',
      'preuve',
    ],
    answerEn:
        'Use the Incident Report flow with precise time, location, and evidence files when available. Add factual details only. Admin and observer tools can then investigate, classify, and track resolution updates. If you are offline, incident submission is queued and auto-synced when connectivity returns.',
    answerFr:
        'Utilisez le signalement d incident avec heure, lieu et pieces justificatives quand possible. Ajoutez des faits precis. Les outils admin et observateur permettent ensuite d enqueter, classifier et suivre la resolution. Hors ligne, le signalement peut etre mis en file et synchronise automatiquement au retour de la connexion.',
    detailsEn:
        'Best evidence:\n'
        '- Exact time and location.\n'
        '- What happened (facts only, avoid assumptions).\n'
        '- Photos/videos/screenshots if safe and legal.\n'
        '- Names/IDs only if you are authorized to collect them.\n\n'
        'If you are offline, submit anyway: the report will be queued and synced automatically.',
    detailsFr:
        'Bonnes preuves:\n'
        '- Heure et lieu exacts.\n'
        '- Ce qui s est passe (faits uniquement, sans suppositions).\n'
        '- Photos/videos/captures si c est possible et legal.\n'
        '- Noms/identifiants seulement si vous etes autorise.\n\n'
        'Hors ligne, soumettez quand meme: le rapport sera mis en file et synchronise automatiquement.',
    followUpsEn: <String>[
      'Can I submit without attachments?',
      'How do I track my incident status?',
    ],
    followUpsFr: <String>[
      'Puis-je soumettre sans piece jointe ?',
      'Comment suivre mon signalement ?',
    ],
    sourceHints: <String>['CamVote incident workflow'],
  ),
  CamGuideIntent(
    id: 'electoral_context',
    keywords: <String>[
      'cameroon election',
      'elecam',
      'constitutional council',
      'electoral law',
      'cameroun election',
      'code electoral',
      'institution electorale',
    ],
    answerEn:
        'For Cameroon electoral context, rely on official institutions: ELECAM for electoral operations and the Constitutional Council for constitutional election matters. In CamVote, use the Legal Library and Civic Education sections for structured summaries and official-source links. Always confirm dates and legal updates through official publications.',
    answerFr:
        'Pour le contexte electoral camerounais, fiez-vous aux institutions officielles: ELECAM pour les operations electorales et le Conseil Constitutionnel pour les matieres constitutionnelles. Dans CamVote, utilisez la Bibliotheque Juridique et la section Education Civique pour des resumes structures et des liens officiels. Verifiez toujours les dates et mises a jour juridiques a partir des publications officielles.',
    detailsEn:
        'Safe approach:\n'
        '1) Start with official notices (ELECAM + Constitutional Council).\n'
        '2) Use CamVote Legal Library and Civic Education for structured guidance.\n'
        '3) Double-check dates, eligibility rules, and procedures against official publications.\n\n'
        'If you tell me what you are trying to confirm, I can point you to the right section inside CamVote.',
    detailsFr:
        'Approche sure:\n'
        '1) Commencez par les avis officiels (ELECAM + Conseil Constitutionnel).\n'
        '2) Utilisez la Bibliotheque Juridique et l Education Civique dans CamVote.\n'
        '3) Verifiez dates, eligibilite et procedures via les publications officielles.\n\n'
        'Dites moi ce que vous voulez confirmer, et je vous dirige vers la bonne section CamVote.',
    followUpsEn: <String>[
      'Where is the legal library in CamVote?',
      'How do I verify public election updates?',
    ],
    followUpsFr: <String>[
      'Ou se trouve la bibliotheque juridique ?',
      'Comment verifier les mises a jour publiques ?',
    ],
    sourceHints: <String>[
      'ELECAM official channels',
      'Constitutional Council publications',
    ],
  ),
  CamGuideIntent(
    id: 'offline_sync',
    keywords: <String>[
      'offline',
      'no internet',
      'sync pending',
      'hors ligne',
      'synchronisation',
      'connexion',
      'queued',
      'pending',
    ],
    answerEn:
        'CamVote supports offline fallback for previously loaded data and queued submission sync for selected actions. This includes support tickets, admin support responses, incident reports, selected tip flows, observer checklist updates, center management actions, and notification read-sync actions. Once internet returns, pending queue items are retried automatically.',
    answerFr:
        'CamVote prend en charge un mode hors ligne avec donnees deja chargees et une synchronisation differree pour certaines actions. Cela inclut les tickets support, les reponses support admin, les signalements d incident, certains flux de pourboire, les mises a jour de checklist observateur, la gestion des centres et la synchronisation de lecture des notifications. Au retour d internet, la file est rejouee automatiquement.',
    detailsEn:
        'Offline in CamVote means two things:\n'
        '- Cached reads: some previously loaded pages can still open.\n'
        '- Queued writes: some actions are saved locally and replayed when internet returns.\n\n'
        'Tip: If you see “sync pending”, keep the app open for a moment after you regain connection, or use the Sync button.',
    detailsFr:
        'Hors ligne dans CamVote = 2 choses:\n'
        '- Lectures en cache: certaines pages deja chargees peuvent s ouvrir.\n'
        '- Actions en file: certaines actions sont enregistrees localement puis rejouees quand internet revient.\n\n'
        'Astuce: si vous voyez “sync pending”, laissez l app ouverte un moment apres le retour de connexion, ou utilisez le bouton Synchroniser.',
    followUpsEn: <String>[
      'How do I check pending offline submissions?',
      'Does offline mode keep my data safe?',
    ],
    followUpsFr: <String>[
      'Comment voir les soumissions en attente ?',
      'Le mode hors ligne protege-t-il mes donnees ?',
    ],
    sourceHints: <String>['CamVote offline sync policy'],
  ),
  CamGuideIntent(
    id: 'support_response',
    keywords: <String>[
      'support response',
      'ticket answer',
      'help desk',
      'support delay',
      'assistance',
      'delai ticket',
    ],
    answerEn:
        'Use Help and Support to submit a ticket with a valid email. You receive visual confirmation and in-app updates. Admin responses appear in your notifications and can also be sent to your email when configured.',
    answerFr:
        'Utilisez Aide et Support pour soumettre un ticket avec un email valide. Vous recevez une confirmation visuelle et des mises a jour dans l application. Les reponses admin apparaissent dans vos notifications et peuvent aussi etre envoyees par email si configure.',
    detailsEn:
        'For the best support response:\n'
        '1) Include a valid email.\n'
        '2) Describe the issue with steps to reproduce.\n'
        '3) Add screenshots only if they do not expose private data.\n'
        '4) Keep the tracking/reference ID.\n\n'
        'You will get in-app notifications. Email replies are sent when email delivery is configured.',
    detailsFr:
        'Pour une meilleure reponse support:\n'
        '1) Mettez un email valide.\n'
        '2) Decrivez le probleme avec les etapes.\n'
        '3) Ajoutez des captures seulement si elles n exposent pas de donnees privees.\n'
        '4) Gardez la reference.\n\n'
        'Vous aurez des notifications dans l app. L email est envoye si la livraison est configuree.',
    followUpsEn: <String>[
      'Can I chat with live help desk?',
      'Can I contact support on WhatsApp?',
    ],
    followUpsFr: <String>[
      'Puis-je discuter avec le help desk ?',
      'Puis-je contacter WhatsApp ?',
    ],
    sourceHints: <String>['CamVote support workflow'],
  ),
  CamGuideIntent(
    id: 'tip_support',
    keywords: <String>[
      'tip',
      'donation',
      'support project',
      'taptap',
      'remitly',
      'maxit',
      'max it',
      'maxit qr',
      'max it qr',
      'orange money maxit',
      'orange money max it',
      'orange money',
      'pourboire',
      'soutenir',
      'financer',
    ],
    answerEn:
        'Use Support CamVote to choose a payment channel (TapTap Send, Remitly, or Orange Money Max It QR), verify the recipient name before sending, and submit an optional/manual confirmation. Anonymous tipping is supported. CamVote sends a warm thank-you in-app, and by email when available.',
    answerFr:
        'Utilisez Soutenir CamVote pour choisir un canal de paiement (TapTap Send, Remitly ou le QR Orange Money Max It), verifier le nom du destinataire avant envoi, puis soumettre une confirmation optionnelle/manuelle. Le pourboire anonyme est pris en charge. CamVote envoie un message de remerciement chaleureux dans l application, et par email quand disponible.',
    detailsEn:
        'Tip flow (safe):\n'
        '1) Pick a channel (TapTap Send / Remitly / Orange Money Max It QR).\n'
        '2) For Max It QR: open the Max It app and scan the QR shown in CamVote.\n'
        '3) Confirm the recipient name before sending.\n'
        '4) Send the amount.\n'
        '5) Back in CamVote, submit a confirmation (screenshot optional).\n\n'
        'Anonymous tipping: You can tip without sharing a name. If you provide an email, you can receive a thank-you email too.',
    detailsFr:
        'Flux de tip (sur):\n'
        '1) Choisissez un canal (TapTap Send / Remitly / QR Orange Money Max It).\n'
        '2) Pour le QR Max It: ouvrez l application Max It et scannez le QR affiche dans CamVote.\n'
        '3) Verifiez le nom du destinataire avant d envoyer.\n'
        '4) Envoyez le montant.\n'
        '5) Dans CamVote, soumettez une confirmation (capture optionnelle).\n\n'
        'Tip anonyme: vous pouvez envoyer sans nom. Si vous fournissez un email, vous pouvez recevoir un remerciement par email.',
    followUpsEn: <String>[
      'How do I verify the recipient details?',
      'Can I tip anonymously?',
      'What if I do not upload a receipt screenshot?',
    ],
    followUpsFr: <String>[
      'Comment verifier les details du destinataire ?',
      'Puis-je envoyer un pourboire anonymement ?',
      'Que faire si je n envoie pas de capture de recu ?',
    ],
    sourceHints: <String>['CamVote support tip flow'],
  ),
  CamGuideIntent(
    id: 'helpdesk_whatsapp',
    keywords: <String>[
      'help desk',
      'live help',
      'chat support',
      'whatsapp',
      'hotline',
      'support admin chat',
      'aide en direct',
      'assistance whatsapp',
      'hotline camvote',
    ],
    answerEn:
        'In Help and Support, you can use two support options: Live Help Desk (admin ticket workflow) and WhatsApp Hotline redirect. Live Help Desk is best for traceable issue follow-up, while WhatsApp is best for quick first contact.',
    answerFr:
        'Dans Aide et Support, vous disposez de deux options: Help Desk en direct (workflow ticket admin) et redirection Hotline WhatsApp. Le Help Desk est meilleur pour un suivi tracable, WhatsApp pour un premier contact rapide.',
    followUpsEn: <String>[
      'How do I submit a complete support ticket?',
      'Will I receive notification when admin answers?',
    ],
    followUpsFr: <String>[
      'Comment soumettre un ticket support complet ?',
      'Vais-je recevoir une notification quand admin repond ?',
    ],
    sourceHints: <String>[
      'CamVote support workflow',
      'WhatsApp hotline config',
    ],
  ),
  CamGuideIntent(
    id: 'public_stats_demographics',
    keywords: <String>[
      'electoral stats',
      'public stats',
      'age range',
      'age band',
      'youth',
      'adult',
      'senior',
      'deceased',
      'total registered',
      'stats publique',
      'tranche age',
      'decedes',
    ],
    answerEn:
        'CamVote public pages can expose electoral-list metrics such as total registered, total voted, deceased records, and age-band distribution (18-24, 25-34, 35-44, 45-59, 60+), including youth/adult/senior summaries when data is available.',
    answerFr:
        'Les pages publiques CamVote peuvent afficher les metriques de la liste electorale comme total inscrits, total votants, decedes, et la repartition par tranches d age (18-24, 25-34, 35-44, 45-59, 60+), avec resumes jeunesse/adulte/senior quand les donnees sont disponibles.',
    detailsEn:
        'Where to look:\n'
        '- Public portal: Results & Statistics.\n'
        '- Some dashboards may show age bands and summaries (youth/adult/senior) when the dataset is available.\n\n'
        'If you tell me what portal you are in (public/voter/admin), I can point you to the exact screen.',
    detailsFr:
        'Ou regarder:\n'
        '- Portail public: Resultats & Statistiques.\n'
        '- Certains tableaux affichent les tranches d age et les resumes (jeunesse/adulte/senior) si les donnees sont disponibles.\n\n'
        'Dites moi votre portail (public/electeur/admin) et je vous indique l ecran exact.',
    followUpsEn: <String>[
      'Where can I open public electoral stats?',
      'How often are the stats refreshed?',
    ],
    followUpsFr: <String>[
      'Ou ouvrir les stats electorales publiques ?',
      'A quelle frequence les stats sont mises a jour ?',
    ],
    sourceHints: <String>[
      'CamVote public portal',
      'CamVote admin analytics pipeline',
    ],
  ),
  CamGuideIntent(
    id: 'theme_and_subtheme',
    keywords: <String>[
      'dark mode',
      'light mode',
      'system mode',
      'theme',
      'subtheme',
      'appearance',
      'theme web',
      'mode sombre',
      'mode clair',
      'mode systeme',
    ],
    answerEn:
        'Use Settings to switch Light, Dark, or System mode and apply subthemes. CamVote keeps your preference and should apply changes instantly across web routes and role portals.',
    answerFr:
        'Utilisez Parametres pour basculer entre mode Clair, Sombre ou Systeme et appliquer les sous-themes. CamVote conserve votre preference et doit appliquer le changement instantanement sur les routes web et les portails de role.',
    detailsEn:
        'If a theme does not apply instantly:\n'
        '1) Open Settings again and re-select the mode/subtheme.\n'
        '2) Make sure you are not in a restricted onboarding route.\n'
        '3) On web, try a normal refresh once (Ctrl+R), not a hard refresh.\n\n'
        'If it still fails, tell me your device + browser and which subtheme you selected.',
    detailsFr:
        'Si un theme ne s applique pas tout de suite:\n'
        '1) Retournez dans Parametres et re-selectionnez mode/sous-theme.\n'
        '2) Verifiez que vous n etes pas dans une route d onboarding.\n'
        '3) Sur web, faites un refresh normal une fois (Ctrl+R), pas un hard refresh.\n\n'
        'Si ca persiste, dites moi appareil + navigateur et le sous-theme choisi.',
    followUpsEn: <String>[
      'Why is my theme not applying immediately?',
      'How do I reset theme preferences?',
    ],
    followUpsFr: <String>[
      'Pourquoi mon theme ne s applique pas immediatement ?',
      'Comment reinitialiser les preferences de theme ?',
    ],
    sourceHints: <String>['CamVote settings and theme controller'],
  ),
  CamGuideIntent(
    id: 'notification_help',
    keywords: <String>[
      'notification',
      'bell',
      'alerts',
      'settings gear',
      'cloche',
      'notifications',
      'parametres',
    ],
    answerEn:
        'The notification bell is role-aware: admin sees admin channels, voter sees voter and public, observer sees observer and public, and public portal sees public updates. If no items exist, an explicit empty state is shown instead of infinite loading.',
    answerFr:
        'La cloche de notification est geree par role: admin voit les canaux admin, electeur voit electeur et public, observateur voit observateur et public, et le portail public affiche les mises a jour publiques. Si aucune donnee n existe, un etat vide explicite est affiche au lieu d un chargement infini.',
    detailsEn:
        'Tips:\n'
        '- Open Notifications from the bell icon.\n'
        '- If you see loading too long, check connectivity and try again.\n'
        '- Use “mark all read” when you want a clean inbox.\n\n'
        'Role filtering is intentional so you only see what is relevant.',
    detailsFr:
        'Astuces:\n'
        '- Ouvrez Notifications via l icone cloche.\n'
        '- Si ca charge trop, verifiez la connexion puis reessayez.\n'
        '- Utilisez “tout marquer lu” pour nettoyer.\n\n'
        'Le filtrage par role est volontaire.',
    followUpsEn: <String>[
      'Why is a notification not visible for my role?',
      'How do I mark all notifications as read?',
    ],
    followUpsFr: <String>[
      'Pourquoi une notification n est pas visible pour mon role ?',
      'Comment marquer toutes les notifications comme lues ?',
    ],
    sourceHints: <String>['CamVote notifications policy'],
  ),
  CamGuideIntent(
    id: 'account_access',
    keywords: <String>[
      'login',
      'cannot sign in',
      'forgot password',
      'password reset',
      'compte',
      'mot de passe',
      'connexion',
    ],
    answerEn:
        'If sign-in fails, confirm email and role first, then use Forgot Password to reset securely. For archived/deleted accounts, follow the dedicated account recovery guidance in the auth flow. Never share one-time links or reset codes.',
    answerFr:
        'Si la connexion echoue, verifiez d abord email et role, puis utilisez Mot de passe oublie pour une reinitialisation securisee. Pour les comptes archives/supprimes, suivez le flux dedie de recuperation. Ne partagez jamais les liens temporaires ni les codes de reinitialisation.',
    detailsEn:
        'Troubleshooting sign-in:\n'
        '1) Verify you are in the correct role portal.\n'
        '2) Check email spelling (no extra spaces).\n'
        '3) Use Forgot Password and complete the reset.\n'
        '4) If the account is archived, follow the Archived Account flow.\n\n'
        'Security: never share reset codes or one-time links.',
    detailsFr:
        'Depannage connexion:\n'
        '1) Verifiez que vous etes dans le bon portail de role.\n'
        '2) Verifiez l email (pas d espaces).\n'
        '3) Utilisez Mot de passe oublie.\n'
        '4) Si le compte est archive, suivez le flux Compte archive.\n\n'
        'Securite: ne partagez jamais codes ni liens temporaires.',
    followUpsEn: <String>[
      'Where is Forgot Password?',
      'What if my account is archived?',
    ],
    followUpsFr: <String>[
      'Ou se trouve Mot de passe oublie ?',
      'Que faire si mon compte est archive ?',
    ],
    sourceHints: <String>['CamVote auth flow'],
  ),
];
