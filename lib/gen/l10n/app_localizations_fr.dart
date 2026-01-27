// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'CamVote';

  @override
  String get slogan => 'Votre vote. Votre voix. Votre avenir.';

  @override
  String get cameroonName => 'République du Cameroun';

  @override
  String get chooseModeTitle => 'Choisissez comment utiliser CamVote';

  @override
  String get modePublicTitle => 'Accès Public';

  @override
  String get modePublicSubtitle =>
      'Voir les résultats, infos électorales et vérifier une inscription sans connexion.';

  @override
  String get modeVoterTitle => 'Électeur';

  @override
  String get modeVoterSubtitle =>
      'S’inscrire, se faire vérifier, voter en toute sécurité et accéder à la carte électorale numérique.';

  @override
  String get modeObserverTitle => 'Observateur';

  @override
  String get modeObserverSubtitle =>
      'Suivi en lecture seule : journaux d’audit, alertes fraude et outils de transparence.';

  @override
  String get modeAdminTitle => 'Administrateur';

  @override
  String get modeAdminSubtitle =>
      'Gérer élections, candidats, suivi, nettoyage, sanctions et conformité.';

  @override
  String get settings => 'Paramètres';

  @override
  String get about => 'À propos';

  @override
  String get aboutSub => 'Créateur, tableau Trello, forces & faiblesses.';

  @override
  String get publicPortalTitle => 'Portail Public';

  @override
  String get publicPortalHeadline => 'Informations publiques (sans connexion)';

  @override
  String get publicResultsTitle => 'Résultats & Statistiques';

  @override
  String get publicResultsSub =>
      'Tendances en direct, participation et résultats finaux.';

  @override
  String get publicElectionsInfoTitle => 'Types d’élections & Guides';

  @override
  String get publicElectionsInfoSub =>
      'Comprendre les types d’élections et les règles.';

  @override
  String get verifyRegistrationTitle =>
      'Vérifier l’inscription (confidentialité)';

  @override
  String get verifyRegistrationSub =>
      'Vérifier via numéro + date de naissance. Identité masquée.';

  @override
  String get lastUpdated => 'Dernière mise à jour';

  @override
  String get turnout => 'Participation';

  @override
  String get totalRegistered => 'Total inscrits';

  @override
  String get totalVotesCast => 'Votes exprimés';

  @override
  String get absentee => 'Abstention';

  @override
  String get candidateResults => 'Résultats des candidats';

  @override
  String get electionsInfoHeadline =>
      'Types d’élections et directives (public)';

  @override
  String get guidelinesTitle => 'Directives';

  @override
  String get guidelineAgeRules =>
      'Inscription : 18+. Vote : 21+. L’éligibilité est appliquée automatiquement.';

  @override
  String get guidelineOnePersonOneVote =>
      'Un citoyen, un vote : les tentatives en double sont bloquées et auditées.';

  @override
  String get guidelineSecrecy =>
      'Secret du vote : les reçus ne révèlent jamais le candidat choisi.';

  @override
  String get guidelineFraudReporting =>
      'Signalement fraude : comportements suspects signalés aux observateurs et admins.';

  @override
  String get electionTypePresidential => 'Élection présidentielle';

  @override
  String get electionTypePresidentialBody =>
      'Élection du Chef de l’État. Suivi en direct avec journaux d’audit et verrouillage après clôture.';

  @override
  String get electionTypeLegislative => 'Élection législative';

  @override
  String get electionTypeLegislativeBody =>
      'Élection des députés. Résultats par circonscription/région dans le tableau.';

  @override
  String get electionTypeMunicipal => 'Élection municipale';

  @override
  String get electionTypeMunicipalBody =>
      'Élection des conseillers municipaux. Résultats par commune et région.';

  @override
  String get electionTypeRegional => 'Élection régionale';

  @override
  String get electionTypeRegionalBody =>
      'Conseils régionaux. Statistiques de participation et taux de vote.';

  @override
  String get electionTypeSenatorial => 'Élection sénatoriale';

  @override
  String get electionTypeSenatorialBody =>
      'Élections du Sénat. Suivi et audit accessibles aux rôles autorisés.';

  @override
  String get verifyPrivacyNote =>
      'Note confidentialité : la vérification publique affiche uniquement une identité masquée et le statut.';

  @override
  String get verifyFormRegNumber => 'Numéro d’inscription';

  @override
  String get verifyFormDob => 'Date de naissance';

  @override
  String get verifySubmit => 'Vérifier';

  @override
  String get requiredField => 'Champ obligatoire';

  @override
  String get invalidRegNumber =>
      'Le numéro doit contenir au moins 4 caractères';

  @override
  String get selectDob => 'Veuillez choisir votre date de naissance';

  @override
  String get tapToSelect => 'Appuyez pour choisir';

  @override
  String get verifyAttemptLimitBody =>
      'Trop de tentatives. Veuillez patienter avant de réessayer.';

  @override
  String get cooldown => 'Délai';

  @override
  String get verifyResultTitle => 'Résultat de la vérification';

  @override
  String get maskedName => 'Nom masqué';

  @override
  String get maskedRegNumber => 'Numéro masqué';

  @override
  String get status => 'Statut';

  @override
  String get cardExpiry => 'Expiration de la carte';

  @override
  String get verifyStatusNotFound => 'Introuvable';

  @override
  String get verifyStatusPending => 'Vérification en attente';

  @override
  String get verifyStatusRegisteredPreEligible =>
      'Inscrit (18–20, pas encore éligible au vote)';

  @override
  String get verifyStatusEligible => 'Éligible au vote';

  @override
  String get verifyStatusVoted => 'A déjà voté (élection en cours)';

  @override
  String get verifyStatusSuspended => 'Suspendu / en examen';

  @override
  String get verifyStatusDeceased => 'Retiré (décès)';

  @override
  String get verifyStatusArchived => 'Archivé (rétention)';

  @override
  String get verifyEligibleToastMessage =>
      'Félicitations ! Vous pouvez maintenant voter aux élections éligibles. 🎉';

  @override
  String get voterPortalTitle => 'Espace Électeur';

  @override
  String get voterHome => 'Accueil';

  @override
  String get voterElections => 'Élections';

  @override
  String get voterVote => 'Voter';

  @override
  String get voterResults => 'Résultats';

  @override
  String get voterProfile => 'Profil';

  @override
  String get adminDashboard => 'Tableau Admin';

  @override
  String get adminDashboardIntro =>
      'Le tableau web admin inclut gestion des élections, suivi, nettoyage, sanctions, audit et revue fraude.';

  @override
  String get observerDashboard => 'Tableau Observateur';

  @override
  String get observerDashboardIntro =>
      'Le portail observateur (lecture seule) inclut suivi, journaux d’audit, alertes fraude et annuaire restreint.';

  @override
  String get appearance => 'Apparence';

  @override
  String get language => 'Langue';

  @override
  String get system => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get aboutIntro =>
      'Cette section présentera le créateur, la vision du projet et un tableau de progression Trello (visible publiquement).';

  @override
  String get regionAdamawa => 'Adamaoua';

  @override
  String get regionCentre => 'Centre';

  @override
  String get regionEast => 'Est';

  @override
  String get regionFarNorth => 'Extrême-Nord';

  @override
  String get regionLittoral => 'Littoral';

  @override
  String get regionNorth => 'Nord';

  @override
  String get regionNorthWest => 'Nord-Ouest';

  @override
  String get regionWest => 'Ouest';

  @override
  String get regionSouth => 'Sud';

  @override
  String get regionSouthWest => 'Sud-Ouest';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get noNotifications => 'Aucune notification pour le moment.';

  @override
  String get audiencePublic => 'Public';

  @override
  String get audienceVoter => 'Électeur';

  @override
  String get audienceObserver => 'Observateur';

  @override
  String get audienceAdmin => 'Administrateur';

  @override
  String get audienceAll => 'Tous';

  @override
  String get toastAllRead =>
      'Toutes les notifications sont marquées comme lues.';

  @override
  String get notificationElectionSoonTitle => 'L\'élection commence bientôt';

  @override
  String get notificationElectionSoonBody =>
      'Une élection programmée ouvrira bientôt. Préparez-vous à voter en toute sécurité.';

  @override
  String get notificationElectionOpenTitle => 'L\'élection est ouverte';

  @override
  String get notificationElectionOpenBody =>
      'Le vote est ouvert. Votez en toute sécurité.';

  @override
  String get notificationElectionClosedTitle => 'Élection clôturée';

  @override
  String get notificationElectionClosedBody =>
      'Le vote est terminé. Les résultats seront publiés bientôt.';

  @override
  String get notificationSecurityNoticeTitle => 'Alerte de sécurité';

  @override
  String get notificationSecurityNoticeBody =>
      'Plusieurs tentatives invalides détectées sur un appareil. La surveillance est active.';

  @override
  String get notificationStatusUpdateTitle => 'Mise à jour du statut';

  @override
  String get notificationStatusUpdateBody =>
      'Vous êtes inscrit (18-20). Vous deviendrez automatiquement éligible à 21 ans.';

  @override
  String get summaryTab => 'Résumé';

  @override
  String get chartsTab => 'Graphiques';

  @override
  String get mapTab => 'Carte';

  @override
  String get chartBarTitle => 'Votes par candidat (Barres)';

  @override
  String get chartPieTitle => 'Part des votes (Camembert)';

  @override
  String get chartLineTitle => 'Tendance de participation (Courbe)';

  @override
  String get chartLineSubtitle =>
      'Visualisation pilotée par l’API une fois les résultats publiés.';

  @override
  String get votesLabel => 'Votes';

  @override
  String get mapTitle => 'Carte des régions (vainqueur par région)';

  @override
  String get mapTapHint =>
      'Appuyez sur une région pour voir le candidat en tête.';

  @override
  String get mapLegendTitle => 'Légende';

  @override
  String get loading => 'Chargement…';

  @override
  String get startupError => 'Erreur de démarrage';

  @override
  String get error => 'Erreur';

  @override
  String get pleaseWait => 'Veuillez patienter';

  @override
  String get retry => 'Réessayer';

  @override
  String get close => 'Fermer';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get refresh => 'Actualiser';

  @override
  String get search => 'Rechercher';

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get winnerLabel => 'Vainqueur';

  @override
  String get resultsLive => 'Résultats EN DIRECT';

  @override
  String get resultsFinal => 'Résultats FINAUX';

  @override
  String get mapOfWinners => 'Carte des vainqueurs par région)';

  @override
  String get unknown => 'Inconnu';

  @override
  String get cameroon => 'Cameroun';

  @override
  String get appSlogan => 'Confiance. Transparence. Vérité.';

  @override
  String get documentOcrTitle => 'Vérification de document (OCR)';

  @override
  String get documentOcrSubtitle =>
      'Téléversez un document officiel. Nous le lirons et vérifierons vos informations.';

  @override
  String get documentType => 'Type de document';

  @override
  String get documentTypeNationalId => 'Carte nationale d\'identité';

  @override
  String get documentTypePassport => 'Passeport';

  @override
  String get documentTypeOther => 'Autre document officiel';

  @override
  String get fullName => 'Nom complet';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get placeOfBirth => 'Lieu de naissance';

  @override
  String get nationality => 'Nationalité';

  @override
  String get pickFromGallery => 'Galerie';

  @override
  String get captureWithCamera => 'Caméra';

  @override
  String get runOcr => 'Lancer l\'OCR et vérifier';

  @override
  String get ocrProcessing => 'Traitement…';

  @override
  String get ocrExtractedTitle => 'Extrait du document';

  @override
  String get ocrValidationTitle => 'Résultat de la vérification';

  @override
  String get ocrVerifiedTitle => 'Vérifié';

  @override
  String get ocrRejectedTitle => 'Rejeté';

  @override
  String get ocrVerified => 'Document vérifié ✅';

  @override
  String get ocrRejected => 'Vérification rejetée';

  @override
  String get ocrFailedTitle => 'OCR échoué';

  @override
  String get rawOcrText => 'Texte OCR brut';

  @override
  String get tryAnotherDoc => 'Essayer un autre document';

  @override
  String get continueNext => 'Continuer';

  @override
  String get ocrNotSupportedTitle => 'OCR indisponible ici';

  @override
  String get ocrNotSupportedMessage =>
      'L\'OCR fonctionne sur Android/iOS. Utilisez l\'application mobile pour l\'inscription.';

  @override
  String get userLabel => 'Utilisateur';

  @override
  String loginTitle(Object role) {
    return 'Connexion $role';
  }

  @override
  String loginHeaderTitle(Object role) {
    return 'Accès sécurisé pour $role';
  }

  @override
  String get loginHeaderSubtitle =>
      'Vérifiez l\'identité, continuez en sécurité, et protégez chaque action.';

  @override
  String get loginIdentifierLabel => 'Email ou numéro d\'inscription';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String passwordMinLength(Object length) {
    return 'Min $length caractères';
  }

  @override
  String get signIn => 'Se connecter';

  @override
  String get signInSubtitle =>
      'Accéder aux portails électeur, observateur ou admin';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountSubtitle =>
      'Suppression définitive avec conservation légale';

  @override
  String get signingIn => 'Connexion…';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get forgotPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get forgotPasswordSubtitle =>
      'Nous enverrons un lien sécurisé à votre compte.';

  @override
  String get forgotPasswordSend => 'Envoyer le lien';

  @override
  String get forgotPasswordSending => 'Envoi…';

  @override
  String get forgotPasswordSuccess => 'Lien de réinitialisation envoyé.';

  @override
  String get forgotPasswordNeedHelpTitle => 'Besoin d\'aide ?';

  @override
  String get forgotPasswordNeedHelpSubtitle =>
      'Contactez l\'assistance pour récupérer votre compte.';

  @override
  String get forgotPasswordHeroTitle => 'Récupération de compte';

  @override
  String get forgotPasswordHeroSubtitle =>
      'Vérifiez votre identité et reprenez l\'accès sécurisé.';

  @override
  String get biometricLogin => 'Utiliser la biométrie';

  @override
  String continueAs(Object name) {
    return 'Continuer en tant que $name';
  }

  @override
  String get biometricWebNotice =>
      'La connexion biométrique est disponible sur Android et iOS.';

  @override
  String get biometricNotAvailable =>
      'La biométrie n\'est pas disponible sur cet appareil.';

  @override
  String get biometricReasonSignIn =>
      'Confirmez votre identité pour vous connecter.';

  @override
  String get biometricReasonEnable =>
      'Activer la connexion biométrique pour CamVote.';

  @override
  String get biometricLoginTitle => 'Connexion biométrique + liveness';

  @override
  String get biometricLoginSubtitle =>
      'Exiger biométrie et liveness pour la connexion.';

  @override
  String get securityChipBiometric => 'Verrou biométrique';

  @override
  String get securityChipLiveness => 'Vérifications liveness';

  @override
  String get securityChipAuditReady => 'Audit prêt';

  @override
  String get securityChipFraudShield => 'Bouclier anti-fraude';

  @override
  String rolePortalTitle(Object role) {
    return 'Portail $role';
  }

  @override
  String get rolePortalSubtitle =>
      'Sécurisé par biométrie et contrôles en direct.';

  @override
  String get newVoterRegistrationTitle => 'Nouvelle inscription électeur';

  @override
  String get newVoterRegistrationSubtitle =>
      'Démarrez votre inscription et vérification.';

  @override
  String get accountSectionTitle => 'Compte';

  @override
  String get securitySectionTitle => 'Sécurité';

  @override
  String get supportSectionTitle => 'Assistance';

  @override
  String get onboardingSectionTitle => 'Onboarding';

  @override
  String get onboardingReplayTitle => 'Revoir l\'onboarding';

  @override
  String get onboardingReplaySubtitle => 'Rejouer l\'introduction CamVote';

  @override
  String get helpSupportTitle => 'Aide & Assistance';

  @override
  String get helpSupportSubtitle =>
      'Réponse rapide pour vote, sécurité et fraude.';

  @override
  String get helpSupportLoginSubtitle => 'Aide pour accès ou sécurité';

  @override
  String get helpSupportSettingsSubtitle => 'Aide pour sécurité ou vote';

  @override
  String get helpSupportPublicSubtitle =>
      'Signaler un problème ou demander de l\'aide';

  @override
  String get helpSupportEmergencyTitle => 'Contact d\'urgence';

  @override
  String get helpSupportEmailLabel => 'Email';

  @override
  String get helpSupportHotlineLabel => 'Hotline';

  @override
  String get helpSupportRegistrationIdLabel =>
      'Numéro d\'inscription (optionnel)';

  @override
  String get helpSupportCategoryLabel => 'Catégorie';

  @override
  String get helpSupportMessageLabel => 'Décrivez le problème';

  @override
  String get helpSupportSubmit => 'Soumettre un ticket';

  @override
  String get helpSupportSubmitting => 'Envoi…';

  @override
  String get helpSupportSubmissionFailed => 'Échec de l\'envoi.';

  @override
  String helpSupportTicketReceived(Object ticketId) {
    return 'Ticket reçu. Référence : $ticketId';
  }

  @override
  String get helpSupportFaqTitle => 'FAQ';

  @override
  String get helpSupportFaqRegistration =>
      'Comment s\'inscrire ? Complétez OCR + biométrie.';

  @override
  String get helpSupportFaqLiveness =>
      'Pourquoi le liveness ? Pour éviter la fraude automatisée.';

  @override
  String get helpSupportFaqReceipt =>
      'Comment vérifier mon vote ? Utilisez le reçu.';

  @override
  String get supportCategoryRegistration => 'Inscription';

  @override
  String get supportCategoryVoting => 'Vote';

  @override
  String get supportCategoryBiometrics => 'Biométrie';

  @override
  String get supportCategoryFraud => 'Signalement fraude';

  @override
  String get supportCategoryTechnical => 'Technique';

  @override
  String get supportCategoryOther => 'Autre';

  @override
  String get roleGatewayWebHint => 'Web : public, observateur, admin';

  @override
  String get roleGatewayMobileHint => 'Mobile : public et électeur';

  @override
  String get roleGatewaySubtitle =>
      'Choisissez le portail qui correspond à votre mission aujourd\'hui.';

  @override
  String get roleGatewayFeatureVerifiedTitle => 'Identité vérifiée';

  @override
  String get roleGatewayFeatureVerifiedSubtitle => 'Biométrie + liveness';

  @override
  String get roleGatewayFeatureFraudTitle => 'Défenses anti-fraude';

  @override
  String get roleGatewayFeatureFraudSubtitle => 'Signaux appareil + IA';

  @override
  String get roleGatewayFeatureTransparencyTitle => 'Résultats transparents';

  @override
  String get roleGatewayFeatureTransparencySubtitle =>
      'Tableaux publics en direct';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingEnter => 'Entrer dans CamVote';

  @override
  String get onboardingSlide1Title => 'Identité fiable';

  @override
  String get onboardingSlide1Subtitle =>
      'Les contrôles biométriques et liveness sécurisent l\'inscription et le vote.';

  @override
  String get onboardingSlide1Highlight1 => 'Vérification liveness';

  @override
  String get onboardingSlide1Highlight2 => 'Reçus respectueux de la vie privée';

  @override
  String get onboardingSlide1Highlight3 => 'Une personne, un vote';

  @override
  String get onboardingSlide2Title => 'Résultats publics transparents';

  @override
  String get onboardingSlide2Subtitle =>
      'Tableaux en direct pour participation, comptes et mises à jour.';

  @override
  String get onboardingSlide2Highlight1 => 'Flux de résultats en direct';

  @override
  String get onboardingSlide2Highlight2 => 'Analyses régionales';

  @override
  String get onboardingSlide2Highlight3 => 'Vues pour observateurs';

  @override
  String get onboardingSlide3Title => 'Défense anti-fraude à chaque étape';

  @override
  String get onboardingSlide3Subtitle =>
      'Signaux IA, intégrité appareil et audits sécurisent les élections.';

  @override
  String get onboardingSlide3Highlight1 => 'Signaux de risque IA';

  @override
  String get onboardingSlide3Highlight2 => 'Contrôles d\'intégrité';

  @override
  String get onboardingSlide3Highlight3 => 'Pistes d\'audit immuables';

  @override
  String get chartBarLabel => 'Barres';

  @override
  String get chartPieLabel => 'Camembert';

  @override
  String get chartLineLabel => 'Courbe';

  @override
  String get winnerVotesLabel => 'Votes du vainqueur';

  @override
  String get totalVotesLabel => 'Total des votes';

  @override
  String get aboutBuilderTitle => 'À propos du créateur';

  @override
  String get aboutBuilderSubtitle =>
      'Découvrez la vision, la mission et la feuille de route CamVote.';

  @override
  String get aboutProfileName => 'DJAGNI SIGNING Romuald';

  @override
  String get aboutProfileTitle =>
      'Étudiant en ingénierie informatique • Bâtisseur civic-tech';

  @override
  String get aboutProfileTagline =>
      'Construire des élections numériques fiables pour le Cameroun.';

  @override
  String get aboutProfileVision =>
      'Un système électoral transparent, sûr et inclusif qui restaure la confiance en rendant chaque étape vérifiable, accessible et prête à l’audit.';

  @override
  String get aboutProfileMission =>
      'Concevoir des systèmes qui protègent l’identité des électeurs, empêchent la fraude et publient des résultats rapidement sans compromettre l’intégrité.';

  @override
  String get aboutProfileEmailLabel => 'Email';

  @override
  String get aboutProfileEmailValue => 'romualdsigningd@gmail.com';

  @override
  String get aboutProfileLinkedInLabel => 'LinkedIn';

  @override
  String get aboutProfileLinkedInValue =>
      'https://www.linkedin.com/in/romuald-djagnisigning';

  @override
  String get aboutProfileGitHubLabel => 'GitHub';

  @override
  String get aboutProfileGitHubValue =>
      'https://www.github.com/Romuald-DJAGNISIGNING';

  @override
  String get aboutProfilePortfolioLabel => 'Portfolio';

  @override
  String get aboutProfilePortfolioValue => 'https://romuald-djagnisigning.dev';

  @override
  String get aboutTagSecureVoting => 'Vote sécurisé';

  @override
  String get aboutTagBiometrics => 'Biométrie';

  @override
  String get aboutTagAuditTrails => 'Pistes d’audit';

  @override
  String get aboutTagOfflineFirst => 'UX hors ligne d’abord';

  @override
  String get aboutTagAccessibility => 'Accessibilité';

  @override
  String get aboutTagLocalization => 'Localisation EN/FR';

  @override
  String get aboutVisionMissionTitle => 'Vision et mission';

  @override
  String get aboutVisionTitle => 'Vision';

  @override
  String get aboutMissionTitle => 'Mission';

  @override
  String get aboutContactSocialTitle => 'Contact et réseaux';

  @override
  String get aboutProductFocusTitle => 'Axes produit';

  @override
  String get aboutTrelloTitle => 'Statistiques du tableau Trello';

  @override
  String get aboutConnectTrelloTitle => 'Connecter Trello';

  @override
  String get aboutConnectTrelloBody =>
      'Définissez CAMVOTE_TRELLO_KEY, CAMVOTE_TRELLO_TOKEN et CAMVOTE_TRELLO_BOARD_ID pour afficher les stats.';

  @override
  String get aboutTrelloLoadingTitle => 'Chargement Trello';

  @override
  String get aboutTrelloLoadingBody => 'Récupération des statistiques…';

  @override
  String get aboutTrelloUnavailableTitle => 'Trello indisponible';

  @override
  String aboutTrelloUnavailableBody(Object error) {
    return 'Impossible de récupérer les stats : $error';
  }

  @override
  String get aboutTrelloNotConfiguredTitle => 'Trello non configuré';

  @override
  String get aboutTrelloNotConfiguredBody =>
      'Ajoutez les identifiants Trello pour activer les statistiques.';

  @override
  String get aboutWhyCamVoteTitle => 'Pourquoi CamVote';

  @override
  String get aboutWhyCamVoteBody =>
      'CamVote montre comment la civic-tech peut réduire les irrégularités, améliorer la transparence et publier des résultats crédibles rapidement.';

  @override
  String get aboutCopyEmail => 'Copier l\'email';

  @override
  String get aboutCopyLinkedIn => 'Copier LinkedIn';

  @override
  String get aboutCopyGitHub => 'Copier GitHub';

  @override
  String get aboutCopyBoardUrl => 'Copier l\'URL du tableau';

  @override
  String get aboutBoardUrlLabel => 'URL du tableau';

  @override
  String get aboutLastActivityLabel => 'Dernière activité';

  @override
  String get aboutTopListsLabel => 'Listes principales';

  @override
  String get aboutStatTotal => 'Total';

  @override
  String get aboutStatOpen => 'Ouvert';

  @override
  String get aboutStatDone => 'Terminé';

  @override
  String aboutFooterBuiltBy(Object name, Object year) {
    return '© $year CamVote • Construit par $name';
  }

  @override
  String copiedMessage(Object label) {
    return '$label copié';
  }

  @override
  String get registrationHubTitle => 'Inscription';

  @override
  String get registrationHubSubtitle =>
      'Commencez votre processus d’inscription sécurisée des électeurs.';

  @override
  String get deviceAccountPolicyTitle => 'Politique de compte appareil';

  @override
  String deviceAccountPolicyBody(Object count, Object max) {
    return 'Cet appareil a actuellement $count/$max comptes enregistrés.\nMaximum $max comptes par appareil pour réduire la fraude.';
  }

  @override
  String get biometricEnrollmentTitle => 'Enrôlement biométrique';

  @override
  String get biometricEnrollmentStatusComplete =>
      'Terminé et prêt pour la vérification.';

  @override
  String get biometricEnrollmentStatusPending => 'En attente de finalisation.';

  @override
  String get statusComplete => 'Terminé';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusCompleted => 'Terminé';

  @override
  String get statusRequired => 'Requis';

  @override
  String get statusEnrolled => 'Enrôlé';

  @override
  String get statusVerified => 'Vérifié';

  @override
  String get registrationBlockedTitle => 'Inscription bloquée sur cet appareil';

  @override
  String get registrationBlockedBody =>
      'Cet appareil a déjà atteint le nombre maximum de comptes.\nSi c’est une erreur, vous pourrez demander une vérification via le support.';

  @override
  String get startVoterRegistration => 'Démarrer l’inscription électeur';

  @override
  String get backToPublicMode => 'Retour au mode public';

  @override
  String errorWithDetails(Object details) {
    return 'Erreur : $details';
  }

  @override
  String get registrationDraftTitle => 'Inscription électeur (brouillon)';

  @override
  String get registrationDraftHeaderTitle => 'Inscription électeur';

  @override
  String get registrationDraftHeaderSubtitle =>
      'Complétez vos informations personnelles pour commencer la vérification.';

  @override
  String get draftSaved => 'Brouillon enregistré';

  @override
  String get draftNotSaved => 'Brouillon non enregistré';

  @override
  String get draftSavedSubtitle =>
      'Vous pouvez enregistrer et reprendre à tout moment. Prochaine étape : OCR + vivacité.';

  @override
  String get clearDraft => 'Effacer le brouillon';

  @override
  String get regionLabel => 'Région';

  @override
  String get pickDateOfBirth => 'Choisir la date de naissance';

  @override
  String dateOfBirthWithValue(Object date) {
    return 'Date de naissance : $date';
  }

  @override
  String get saveDraft => 'Enregistrer le brouillon';

  @override
  String get registrationReviewTitle => 'Revoir l’inscription';

  @override
  String get registrationReviewSubtitle =>
      'Confirmez vos données avant l’envoi.';

  @override
  String get registrationSectionPersonalDetails => 'Détails personnels';

  @override
  String get registrationSectionDocumentVerification =>
      'Vérification du document';

  @override
  String get registrationSectionSecurityEnrollment => 'Enrôlement sécurité';

  @override
  String get summaryLabel => 'Résumé';

  @override
  String get nameMatchLabel => 'Concordance du nom';

  @override
  String get dobMatchLabel => 'Concordance DDN';

  @override
  String get pobMatchLabel => 'Concordance LDN';

  @override
  String get nationalityMatchLabel => 'Concordance nationalité';

  @override
  String get nameLabel => 'Nom';

  @override
  String get dateOfBirthShort => 'DDN';

  @override
  String get placeOfBirthShort => 'LDN';

  @override
  String get biometricsLabel => 'Biométrie';

  @override
  String get livenessLabel => 'Vivacité';

  @override
  String get registrationConsentTitle =>
      'Je confirme que toutes les informations sont exactes.';

  @override
  String get registrationConsentSubtitle =>
      'Je consens au traitement sécurisé de mes données d’inscription.';

  @override
  String get registrationSubmitting => 'Envoi...';

  @override
  String get registrationRenewing =>
      'Renouvellement de l’inscription électorale...';

  @override
  String get registrationSubmit => 'Soumettre l’inscription';

  @override
  String get registrationSubmitBlockedNote =>
      'Terminez la vérification du document et l’enrôlement pour soumettre.';

  @override
  String get registrationSubmissionFailed => 'Échec de l’envoi.';

  @override
  String get registrationRenewalFailed => 'Échec du renouvellement.';

  @override
  String get failed => 'Échec';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get registrationSubmittedTitle => 'Inscription envoyée';

  @override
  String get registrationSubmittedSubtitle =>
      'Votre demande est en cours d’examen.';

  @override
  String get registrationSubmittedNote =>
      'Vous serez notifié une fois la vérification terminée. Conservez votre ID de suivi.';

  @override
  String get trackingIdLabel => 'ID de suivi';

  @override
  String get messageLabel => 'Message';

  @override
  String get goToVoterLogin => 'Aller à la connexion électeur';

  @override
  String get continueToLogin => 'Continuer vers la connexion';

  @override
  String get deletedAccountLoginTitle => 'Compte déjà existant';

  @override
  String get deletedAccountLoginBody =>
      'Ce dossier électeur existe déjà dans le registre et ne peut pas être réinscrit. Veuillez vous connecter avec biométrie + vivacité pour continuer.';

  @override
  String get deletedAccountRenewedTitle => 'Dossier renouvelé';

  @override
  String get deletedAccountRenewedBody =>
      'Votre dossier existe déjà, mais la carte e-électorale avait expiré. Nous l\'avons renouvelée. Veuillez vous connecter pour continuer.';

  @override
  String get backToPublicPortal => 'Retour au portail public';

  @override
  String get registrationStatusPending => 'En attente';

  @override
  String get registrationStatusApproved => 'Approuvée';

  @override
  String get registrationStatusRejected => 'Rejetée';

  @override
  String get biometricEnrollmentSubtitle =>
      'Sécurisez votre identité avec biométrie et vivacité.';

  @override
  String biometricEnrollmentSubtitleWithName(Object name) {
    return 'Sécurisez $name avec biométrie et vivacité.';
  }

  @override
  String get biometricEnrollmentStep1Title => 'Étape 1 : enrôler la biométrie';

  @override
  String get biometricEnrollmentStep1Subtitle =>
      'Nous vérifions votre empreinte ou Face ID via votre appareil.';

  @override
  String get biometricEnrollmentStep2Title => 'Étape 2 : contrôle de vivacité';

  @override
  String get biometricEnrollmentStep2Subtitle =>
      'Confirmez que vous êtes bien devant la caméra.';

  @override
  String get recheck => 'Revérifier';

  @override
  String get enrollNow => 'Enrôler maintenant';

  @override
  String get runLiveness => 'Lancer la vivacité';

  @override
  String get enrollmentCompleteTitle => 'Enrôlement terminé';

  @override
  String get enrollmentInProgressTitle => 'Enrôlement en cours';

  @override
  String get enrollmentCompleteBody =>
      'Vous pouvez maintenant terminer l’inscription.';

  @override
  String get enrollmentInProgressBody =>
      'Terminez les deux étapes pour continuer.';

  @override
  String get finishEnrollment => 'Terminer l’enrôlement';

  @override
  String get biometricPrivacyNote =>
      'Vos données biométriques sont stockées de manière sécurisée sur l’appareil et ne sont jamais sauvegardées en images brutes.';

  @override
  String get biometricEnrollReason =>
      'Enrôler la biométrie pour un vote sécurisé.';

  @override
  String get biometricVerificationFailed =>
      'La vérification biométrique a échoué.';

  @override
  String get biometricEnrollmentRecorded =>
      'Enrôlement biométrique enregistré.';

  @override
  String get livenessCheckFailed => 'Le contrôle de vivacité a échoué.';

  @override
  String get livenessVerifiedToast => 'Vivacité vérifiée.';

  @override
  String get livenessCheckTitle => 'Contrôle de vivacité';

  @override
  String get livenessCameraPermissionRequired =>
      'L’autorisation caméra est requise.';

  @override
  String get livenessNoCameraAvailable => 'Aucune caméra disponible.';

  @override
  String get livenessPreparingCamera => 'Préparation de la caméra...';

  @override
  String get livenessHoldSteady => 'Restez immobile pour la vérification.';

  @override
  String livenessStepLabel(Object step, Object total) {
    return 'Étape $step sur $total';
  }

  @override
  String get livenessVerifiedMessage => 'Vivacité vérifiée.';

  @override
  String get livenessPromptHoldSteady =>
      'Restez immobile. Suivez l’instruction.';

  @override
  String get livenessPromptCenterFace => 'Centrez votre visage dans le cadre.';

  @override
  String get livenessPromptAlignFace => 'Alignez votre visage pour continuer.';

  @override
  String get livenessStatusNoFace => 'Aucun visage détecté';

  @override
  String get livenessStatusFaceCentered => 'Visage centré';

  @override
  String get livenessStatusAdjustPosition => 'Ajustez la position';

  @override
  String get livenessGoodLight => 'Bonne lumière';

  @override
  String get livenessOpenSettings => 'Ouvrir les paramètres';

  @override
  String get livenessTaskBlinkTitle => 'Clignez des yeux';

  @override
  String get livenessTaskBlinkSubtitle =>
      'Fermez les deux yeux, puis ouvrez-les.';

  @override
  String get livenessTaskTurnLeftTitle => 'Tournez à gauche';

  @override
  String get livenessTaskTurnLeftSubtitle =>
      'Tournez doucement la tête vers la gauche.';

  @override
  String get livenessTaskTurnRightTitle => 'Tournez à droite';

  @override
  String get livenessTaskTurnRightSubtitle =>
      'Tournez doucement la tête vers la droite.';

  @override
  String get livenessTaskSmileTitle => 'Faites un léger sourire';

  @override
  String get livenessTaskSmileSubtitle =>
      'Détendez votre visage et souriez brièvement.';

  @override
  String get voteBiometricsSubtitle =>
      'Biométrie + vivacité requises pour chaque vote.';

  @override
  String get noOpenElections =>
      'Aucune élection n’est actuellement ouverte au vote.';

  @override
  String electionScopeLabel(Object scope) {
    return 'Portée : $scope';
  }

  @override
  String get alreadyVotedInElection =>
      '✅ Vous avez déjà voté dans cette élection.';

  @override
  String get voteAction => 'Voter';

  @override
  String get deviceBlockedMessage => 'Cet appareil est temporairement bloqué.';

  @override
  String deviceBlockedUntil(Object until) {
    return 'Jusqu’au : $until';
  }

  @override
  String get electionLockedOnDevice =>
      'Cette élection est verrouillée sur cet appareil.';

  @override
  String get confirmVoteTitle => 'Confirmer le vote';

  @override
  String confirmVoteBody(Object candidate, Object party) {
    return 'Vous êtes sur le point de voter.\n\nSélection : $candidate ($party)\n\nVous devrez vérifier avec biométrie + vivacité.';
  }

  @override
  String get voteBiometricReason => 'Confirmez votre identité pour voter.';

  @override
  String get voteReceiptTitle => 'Reçu de vote';

  @override
  String get voteReceiptSubtitle =>
      'Reçu de vérification privée pour votre vote.';

  @override
  String get candidateHashLabel => 'Hash candidat';

  @override
  String get partyHashLabel => 'Hash parti';

  @override
  String get castAtLabel => 'Émis le';

  @override
  String get auditTokenLabel => 'Jeton d’audit';

  @override
  String get tokenCopied => 'Jeton copié';

  @override
  String get copyAction => 'Copier';

  @override
  String get shareAction => 'Partager';

  @override
  String get printReceiptAction => 'Imprimer le reçu';

  @override
  String get receiptSafetyNote =>
      'Conservez ce jeton en sécurité. Il vous permet de vérifier que votre vote a été inclus dans le journal d’audit public sans révéler votre choix.';

  @override
  String receiptShareMessage(Object token) {
    return 'Jeton de reçu CamVote : $token';
  }

  @override
  String get receiptBiometricReason =>
      'Confirmez votre identité pour accéder à ce reçu.';

  @override
  String get receiptPdfTitle => 'Reçu CamVote';

  @override
  String get electionLabel => 'Élection';

  @override
  String get receiptPrivacyNote =>
      'Ce reçu protège la confidentialité du vote en hachant le choix.';

  @override
  String get electoralCardTitle => 'Carte e-Électorale';

  @override
  String get electoralCardSubtitle =>
      'Votre carte d’identité électorale numérique vérifiée.';

  @override
  String get electoralCardIncompleteNote =>
      'Terminez l’inscription électeur pour générer votre carte e-Électorale.';

  @override
  String get electoralCardLockedTitle => 'Carte e-Électorale CamVote';

  @override
  String get electoralCardLockedSubtitle =>
      'Déverrouillez pour voir les détails de votre carte.';

  @override
  String get verifyToUnlock => 'Vérifier pour déverrouiller';

  @override
  String get electoralCardBiometricReason =>
      'Déverrouiller votre carte e-Électorale.';

  @override
  String get electoralCardQrNote =>
      'Ce jeton QR permet de vérifier le statut d’inscription sans exposer vos données personnelles.';

  @override
  String get electionsBrowseSubtitle =>
      'Parcourez les élections programmées et les candidats.';

  @override
  String get electionStatusUpcoming => 'À venir';

  @override
  String get electionStatusOpen => 'Ouverte';

  @override
  String get electionStatusClosed => 'Clôturée';

  @override
  String get opensLabel => 'Ouverture';

  @override
  String get closesLabel => 'Clôture';

  @override
  String get candidatesLabel => 'Candidats';

  @override
  String get voterHomeSubtitle =>
      'Suivez votre statut, protégez votre vote et restez informé.';

  @override
  String get nextElectionTitle => 'Prochaine élection';

  @override
  String nextElectionCountdown(Object days, Object time) {
    return '$days jours • $time';
  }

  @override
  String get nextElectionCountdownLabelDays => 'Jours';

  @override
  String get nextElectionCountdownLabelHours => 'Heures';

  @override
  String get nextElectionCountdownLabelMinutes => 'Minutes';

  @override
  String get nextElectionCountdownLabelSeconds => 'Secondes';

  @override
  String candidatesCountLabel(Object count) {
    return 'Candidats : $count';
  }

  @override
  String get voterResultsSubtitle =>
      'Suivez les résultats et vérifiez vos reçus de vote.';

  @override
  String get resultsPublicPortalNote =>
      'Les résultats en direct sont disponibles dans les graphiques du portail public.\nVous y recevrez aussi votre vérification personnelle plus tard.';

  @override
  String get pastElectionsTitle => 'Élections passées';

  @override
  String get noClosedElections => 'Aucune élection clôturée pour l’instant.';

  @override
  String get yourReceiptsTitle => 'Vos reçus';

  @override
  String get noReceiptsYet => 'Aucun reçu pour le moment.';

  @override
  String auditTokenShortLabel(Object token) {
    return 'Jeton d’audit : $token';
  }

  @override
  String get voterProfileSubtitle =>
      'Gérez votre identité, votre sécurité et vos préférences.';

  @override
  String get signedInVoter => 'Électeur connecté';

  @override
  String get verificationStatusTitle => 'Statut de vérification';

  @override
  String get verificationStatusVerified =>
      'Identité vérifiée et statut éligible.';

  @override
  String get verificationStatusPending =>
      'Vérification en attente. Complétez l’OCR + biométrie.';

  @override
  String get electoralCardViewSubtitle =>
      'Voir votre carte d’électeur numérique';

  @override
  String get votingCentersTitle => 'Carte des centres de vote';

  @override
  String get votingCentersSubtitle =>
      'Trouvez les centres de vote vérifiés près de vous.';

  @override
  String get votingCentersPublicSubtitle =>
      'Localisez les centres de vote et guichets d’éligibilité.';

  @override
  String get votingCentersSelectTitle => 'Sélectionner un centre de vote';

  @override
  String get votingCentersSelectSubtitle =>
      'Choisissez un centre pour l’inscription ou le vote en personne.';

  @override
  String get votingCenterSelectPrompt =>
      'Sélectionnez un centre pour continuer';

  @override
  String get votingCenterSelectAction => 'Utiliser ce centre';

  @override
  String get votingCentersSearchHint =>
      'Rechercher par ville, quartier ou nom du centre';

  @override
  String get useMyLocation => 'Utiliser ma position';

  @override
  String get votingCentersMapTitle => 'Centres de vote au Cameroun';

  @override
  String get votingCentersMapHint =>
      'Touchez un marqueur pour voir un centre et le sélectionner.';

  @override
  String get votingCentersLegendTitle => 'Légende de la carte';

  @override
  String get votingCentersLegendCenter => 'Centre de vote';

  @override
  String get votingCentersLegendYou => 'Vous êtes ici';

  @override
  String get votingCentersNearbyTitle => 'Centres proches';

  @override
  String get votingCentersNearbySubtitle =>
      'Classés par distance si la position est disponible.';

  @override
  String get votingCentersEmpty =>
      'Aucun centre disponible. Veuillez réessayer plus tard.';

  @override
  String distanceKm(Object km) {
    return '$km km';
  }

  @override
  String get votingCenterNotSelectedTitle => 'Aucun centre sélectionné';

  @override
  String get votingCenterNotSelectedSubtitle =>
      'Choisissez un centre pour finaliser l’inscription.';

  @override
  String get votingCenterSelectedTitle => 'Centre de vote sélectionné';

  @override
  String get votingCenterLabel => 'Centre de vote';

  @override
  String get clearSelection => 'Effacer la sélection';

  @override
  String get biometricsUnavailableTitle => 'Appareil non compatible';

  @override
  String get biometricsUnavailableBody =>
      'La biométrie ou la vivacité n’est pas disponible sur cet appareil. Utilisez un centre physique pour l’inscription ou le vote.';

  @override
  String get locationServicesDisabled =>
      'Les services de localisation sont désactivés. Activez-les pour trouver les centres proches.';

  @override
  String get locationPermissionDenied =>
      'Autorisation de localisation refusée. Autorisez l’accès pour trouver les centres proches.';

  @override
  String get locationPermissionDeniedForever =>
      'Autorisation de localisation refusée définitivement. Mettez à jour les permissions dans les paramètres.';

  @override
  String get settingsSubtitle =>
      'Personnalisez votre expérience et vos contrôles de sécurité.';

  @override
  String get themeStyleTitle => 'Style de thème';

  @override
  String get themeStyleClassic => 'Classique';

  @override
  String get themeStyleCameroon => 'Cameroun';

  @override
  String get themeStyleGeek => 'Geek';

  @override
  String get themeStyleFruity => 'Fruité';

  @override
  String get themeStylePro => 'Pro';

  @override
  String get deleteAccountHeaderSubtitle =>
      'Cette action est définitive et nécessite une vérification.';

  @override
  String get deleteAccountBody =>
      'Cette action est définitive. Votre accès sera supprimé, tandis que les règles de rétention légale s’appliquent aux dossiers électoraux officiels.';

  @override
  String deleteAccountConfirmLabel(Object keyword) {
    return 'Saisissez $keyword pour confirmer';
  }

  @override
  String get deleteKeyword => 'SUPPRIMER';

  @override
  String get deleteAccountConfirmError => 'Confirmation requise.';

  @override
  String get deleteAccountBiometricReason =>
      'Confirmer la suppression du compte.';

  @override
  String get deletingAccount => 'Suppression...';

  @override
  String get missingReceiptData => 'Données de reçu manquantes.';

  @override
  String get missingRegistrationData => 'Données d’inscription manquantes.';

  @override
  String get missingSubmissionDetails => 'Détails de soumission manquants.';

  @override
  String get signedInUser => 'Connecté';

  @override
  String get adminVoterManagementTitle => 'Gestion des électeurs';

  @override
  String get adminVoterManagementSubtitle =>
      'Suivez inscriptions, vérifications et alertes.';

  @override
  String get adminRunListCleaningTooltip => 'Lancer le nettoyage des listes';

  @override
  String get adminListCleaningDone =>
      'Nettoyage terminé. Électeurs suspects suspendus.';

  @override
  String get voterSearchHint => 'Rechercher par nom ou ID électeur…';

  @override
  String get filterRegion => 'Filtrer par région';

  @override
  String get filterStatus => 'Filtrer par statut';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String regionFilterLabel(Object region) {
    return 'Région : $region';
  }

  @override
  String statusFilterLabel(Object status) {
    return 'Statut : $status';
  }

  @override
  String get noVotersMatchFilters =>
      'Aucun électeur ne correspond à vos filtres.';

  @override
  String get deviceFlaggedLabel => 'Appareil signalé';

  @override
  String get biometricDuplicateLabel => 'Doublon biométrique';

  @override
  String ageLabel(Object age) {
    return 'Âge $age';
  }

  @override
  String flagsLabel(Object signals) {
    return '⚠ $signals';
  }

  @override
  String get voterHasVotedLabel => 'A voté';

  @override
  String get voterNotVotedLabel => 'N’a pas voté';

  @override
  String get chooseRegionTitle => 'Choisir une région';

  @override
  String get chooseStatusTitle => 'Choisir un statut';

  @override
  String get riskLow => 'Faible';

  @override
  String get riskMedium => 'Moyen';

  @override
  String get riskHigh => 'Élevé';

  @override
  String get riskCritical => 'Critique';

  @override
  String riskLabel(Object risk) {
    return 'IA $risk';
  }

  @override
  String get statusPendingVerification => 'Vérification en attente';

  @override
  String get statusRegistered => 'Inscrit';

  @override
  String get statusPreEligible => 'Pré‑éligible (18–20)';

  @override
  String get statusEligible => 'Éligible (21+)';

  @override
  String get statusVoted => 'A voté';

  @override
  String get statusSuspended => 'Suspendu';

  @override
  String get statusDeceased => 'Décédé';

  @override
  String get statusArchived => 'Archivé';

  @override
  String get adminDashboardHeaderSubtitle =>
      'Surveillez opérations, audits et santé électorale en direct.';

  @override
  String get statRegistered => 'Inscrits';

  @override
  String get statVoted => 'Ayant voté';

  @override
  String get statActiveElections => 'Élections actives';

  @override
  String get statSuspiciousFlags => 'Alertes suspectes';

  @override
  String get adminActionElections => 'Élections';

  @override
  String get adminActionVoters => 'Électeurs';

  @override
  String get adminActionAuditLogs => 'Journaux d’audit';

  @override
  String get liveResultsPreview => 'Aperçu des résultats en direct';

  @override
  String get adminPreviewLabel => 'Aperçu admin';

  @override
  String get observerPreviewLabel => 'Vue observateur';

  @override
  String get noElectionDataAvailable => 'Aucune donnée d’élection disponible.';

  @override
  String get fraudIntelligenceTitle => 'Intelligence fraude';

  @override
  String get fraudAiStatus => 'IA ACTIVE';

  @override
  String fraudSignalsFlagged(Object count) {
    return 'Signaux suspects détectés : $count';
  }

  @override
  String fraudAnomalyRate(Object rate) {
    return 'Taux d’anomalie estimé : $rate%';
  }

  @override
  String get fraudInsightBody =>
      'Les signaux combinent anomalies d’appareil, doublons biométriques et écarts comportementaux. Examinez les électeurs signalés.';

  @override
  String fraudFlagsRateLabel(Object flags, Object rate) {
    return 'Alertes : $flags • Taux : $rate%';
  }

  @override
  String get observerDashboardHeaderSubtitle =>
      'Surveillance en lecture seule avec données électorales transparentes.';

  @override
  String get observerReadOnlyTitle => 'Accès en lecture seule';

  @override
  String observerTotalsLabel(Object registered, Object voted, Object flags) {
    return 'Inscrits : $registered • Voté : $voted • Alertes : $flags';
  }

  @override
  String get observerOpenAuditLogs => 'Ouvrir les journaux d’audit';

  @override
  String get observerReportIncidentTitle => 'Signaler un incident';

  @override
  String get observerReportIncidentSubtitle =>
      'Soumettre des preuves, photos et un rapport complet.';

  @override
  String get incidentTitleLabel => 'Titre de l’incident';

  @override
  String get incidentCategoryLabel => 'Catégorie';

  @override
  String get incidentSeverityLabel => 'Gravité';

  @override
  String get incidentLocationLabel => 'Lieu';

  @override
  String get incidentDescriptionLabel => 'Description';

  @override
  String get incidentElectionIdLabel => 'ID de l’élection (optionnel)';

  @override
  String get incidentDateTimeLabel => 'Date et heure de l’incident';

  @override
  String get incidentEvidenceTitle => 'Pièces jointes';

  @override
  String get incidentAddCamera => 'Caméra';

  @override
  String get incidentAddGallery => 'Galerie';

  @override
  String get incidentEvidenceEmpty => 'Aucune preuve ajoutée pour l’instant.';

  @override
  String get incidentSubmitAction => 'Soumettre le rapport';

  @override
  String get incidentSubmissionFailed => 'Échec de l’envoi du rapport.';

  @override
  String incidentSubmittedBody(Object id) {
    return 'Rapport envoyé. Référence : $id';
  }

  @override
  String get incidentCategoryFraud => 'Fraude';

  @override
  String get incidentCategoryIntimidation => 'Intimidation';

  @override
  String get incidentCategoryViolence => 'Violence';

  @override
  String get incidentCategoryLogistics => 'Logistique';

  @override
  String get incidentCategoryTechnical => 'Technique';

  @override
  String get incidentCategoryAccessibility => 'Accessibilité';

  @override
  String get incidentCategoryOther => 'Autre';

  @override
  String get incidentSeverityLow => 'Faible';

  @override
  String get incidentSeverityMedium => 'Moyenne';

  @override
  String get incidentSeverityHigh => 'Élevée';

  @override
  String get incidentSeverityCritical => 'Critique';

  @override
  String get changeAction => 'Modifier';

  @override
  String get adminElectionManagementTitle => 'Gestion des élections';

  @override
  String get adminElectionManagementSubtitle =>
      'Créer, planifier et superviser les élections.';

  @override
  String get adminCreateElection => 'Créer une élection';

  @override
  String get noElectionsYet => 'Aucune élection pour l’instant.';

  @override
  String get electionStatusLive => 'En direct';

  @override
  String votesCountLabel(Object count) {
    return 'Votes : $count';
  }

  @override
  String get addCandidate => 'Ajouter un candidat';

  @override
  String get electionTitleLabel => 'Titre de l’élection';

  @override
  String get electionTypeLabel => 'Type d’élection';

  @override
  String electionStartLabel(Object date) {
    return 'Début : $date';
  }

  @override
  String electionEndLabel(Object date) {
    return 'Fin : $date';
  }

  @override
  String electionStartTimeLabel(Object time) {
    return 'Heure d’ouverture : $time';
  }

  @override
  String electionEndTimeLabel(Object time) {
    return 'Heure de clôture : $time';
  }

  @override
  String get electionDescriptionLabel => 'Description de l’élection';

  @override
  String get electionScopeFieldLabel => 'Portée';

  @override
  String get electionScopeNational => 'Nationale';

  @override
  String get electionScopeRegional => 'Régionale';

  @override
  String get electionScopeMunicipal => 'Municipale';

  @override
  String get electionScopeDiaspora => 'Diaspora';

  @override
  String get electionScopeLocal => 'Locale';

  @override
  String get electionLocationLabel => 'Lieu / circonscription';

  @override
  String get registrationDeadlineTitle => 'Date limite d’inscription';

  @override
  String registrationDeadlineLabel(Object date) {
    return 'Date limite d’inscription : $date';
  }

  @override
  String get addRegistrationDeadline => 'Ajouter une date limite';

  @override
  String get clearDeadline => 'Effacer la date limite';

  @override
  String get electionBallotTypeLabel => 'Type de bulletin';

  @override
  String get electionBallotTypeSingle => 'Choix unique';

  @override
  String get electionBallotTypeRanked => 'Choix classé';

  @override
  String get electionBallotTypeApproval => 'Vote par approbation';

  @override
  String get electionBallotTypeRunoff => 'Second tour';

  @override
  String get electionEligibilityLabel => 'Critères d’éligibilité';

  @override
  String get electionTimezoneLabel => 'Fuseau horaire';

  @override
  String get createAction => 'Créer';

  @override
  String get partyNameLabel => 'Nom du parti';

  @override
  String get partyAcronymLabel => 'Sigle du parti';

  @override
  String get candidateSloganLabel => 'Slogan du candidat';

  @override
  String get candidateBioLabel => 'Bio du candidat';

  @override
  String get candidateWebsiteLabel => 'Site de campagne';

  @override
  String get candidateAvatarUrlLabel => 'URL de photo';

  @override
  String get candidateRunningMateLabel => 'Colistier';

  @override
  String get candidateColorLabel => 'Couleur du parti';

  @override
  String get addAction => 'Ajouter';

  @override
  String get electionTypeParliamentary => 'Élection parlementaire';

  @override
  String get electionTypeReferendum => 'Référendum';

  @override
  String get auditLogsTitle => 'Journaux d’audit';

  @override
  String get auditLogsSubtitle => 'Traçabilité immuable de chaque action.';

  @override
  String get auditFilterAll => 'Tous';

  @override
  String get auditShowingAll => 'Tous les événements';

  @override
  String auditFilterLabel(Object filter) {
    return 'Filtre : $filter';
  }

  @override
  String get noAuditEvents => 'Aucun événement d’audit.';

  @override
  String get auditEventElectionCreated => 'Élection créée';

  @override
  String get auditEventCandidateAdded => 'Candidat ajouté';

  @override
  String get auditEventResultsPublished => 'Résultats publiés';

  @override
  String get auditEventListCleaned => 'Liste nettoyée';

  @override
  String get auditEventRegistrationRejected => 'Inscription rejetée';

  @override
  String get auditEventSuspiciousActivity => 'Activité suspecte';

  @override
  String get auditEventDeviceBanned => 'Appareil banni';

  @override
  String get auditEventVoteCast => 'Vote enregistré';

  @override
  String get legalHubTitle => 'Textes et codes électoraux';

  @override
  String get legalHubSubtitle => 'Textes officiels et références civiques.';

  @override
  String get legalSourcesTitle => 'Sources officielles';

  @override
  String get legalSourcesSubtitle =>
      'Sources vérifiées pour le droit électoral camerounais.';

  @override
  String get legalSourceElecamLabel => 'Portail ELECAM';

  @override
  String get legalSourceAssnatLabel => 'Portail de l’Assemblée nationale';

  @override
  String get legalElectoralCodeTitle => 'Code électoral du Cameroun';

  @override
  String legalDocumentSubtitle(Object language) {
    return 'Texte officiel ($language)';
  }

  @override
  String get legalSearchHint => 'Rechercher dans le document';

  @override
  String get legalSearchEmpty => 'Aucun résultat. Essayez un autre mot-clé.';

  @override
  String legalSearchResults(Object count) {
    return '$count résultat(s)';
  }

  @override
  String get openWebsite => 'Ouvrir';

  @override
  String get openLinkFailed => 'Impossible d’ouvrir le lien.';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get missingDocumentData => 'Données du document juridique manquantes.';

  @override
  String get adminToolsTitle => 'Outils administrateur';

  @override
  String get adminFraudMonitorTitle => 'Surveillance fraude';

  @override
  String get adminFraudMonitorSubtitle =>
      'Signaux IA, anomalies et appareils signalés.';

  @override
  String get fraudSignalsTitle => 'Signaux de fraude actifs';

  @override
  String fraudSignalCount(Object count) {
    return '$count signal(s)';
  }

  @override
  String get fraudRiskScoreTitle => 'Score de risque';

  @override
  String fraudRiskScoreValue(Object score) {
    return '$score% de risque';
  }

  @override
  String get fraudSignalTotal => 'Signaux';

  @override
  String get fraudDevicesFlagged => 'Appareils signalés';

  @override
  String get fraudAccountsAtRisk => 'Comptes à risque';

  @override
  String get adminSecurityTitle => 'Sécurité des appareils';

  @override
  String get adminSecuritySubtitle =>
      'Risque appareil, sanctions et alertes d’intégrité.';

  @override
  String securityStrikesLabel(Object count) {
    return '$count sanctions';
  }

  @override
  String get adminIncidentsTitle => 'Supervision des incidents';

  @override
  String get adminIncidentsSubtitle =>
      'Suivi et résolution des incidents terrain.';

  @override
  String incidentSubtitle(Object severity, Object location) {
    return '$severity • $location';
  }

  @override
  String get filterLabel => 'Filtre';

  @override
  String get filterAll => 'Tous';

  @override
  String get incidentStatusOpen => 'Ouvert';

  @override
  String get incidentStatusInvestigating => 'En enquête';

  @override
  String get incidentStatusResolved => 'Résolu';

  @override
  String get adminResultsPublishTitle => 'Publier les résultats';

  @override
  String get adminResultsPublishSubtitle =>
      'Valider et publier les résultats vérifiés.';

  @override
  String resultsPublishSummary(Object votes, Object precincts) {
    return '$votes votes • $precincts bureaux remontés';
  }

  @override
  String get publishResultsAction => 'Publier';

  @override
  String get resultsPublishNotReady => 'Non prêt';

  @override
  String get resultsPublishedToast => 'Résultats publiés.';

  @override
  String get observerToolsTitle => 'Outils observateur';

  @override
  String get observerResultsToolSubtitle =>
      'Résultats en direct en lecture seule.';

  @override
  String get observerIncidentTrackerTitle => 'Suivi des incidents';

  @override
  String get observerIncidentTrackerSubtitle =>
      'Suivez vos incidents signalés.';

  @override
  String get observerTransparencyTitle => 'Fil de transparence';

  @override
  String get observerTransparencySubtitle =>
      'Mises à jour officielles et transparence publique.';

  @override
  String get observerChecklistTitle => 'Checklist d’observation';

  @override
  String get observerChecklistSubtitle =>
      'Vérifiez la conformité et consignez vos observations.';

  @override
  String get publicElectionCalendarTitle => 'Calendrier électoral';

  @override
  String get publicElectionCalendarSubtitle =>
      'Dates et jalons des élections à venir.';

  @override
  String get publicCivicEducationTitle => 'Éducation civique';

  @override
  String get publicCivicEducationSubtitle =>
      'Droits, devoirs et procédures de vote.';

  @override
  String calendarEntrySubtitle(
    Object scope,
    Object location,
    Object start,
    Object end,
  ) {
    return '$scope • $location\n$start → $end';
  }

  @override
  String get readMoreAction => 'Lire plus';
}
