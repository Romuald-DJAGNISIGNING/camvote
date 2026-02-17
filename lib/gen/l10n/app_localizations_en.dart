// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CamVote';

  @override
  String get slogan => 'Your Vote. Your Voice. Your Future.';

  @override
  String get cameroonName => 'Republic of Cameroon';

  @override
  String get chooseModeTitle => 'Choose how you want to use CamVote';

  @override
  String get modePublicTitle => 'Public Access';

  @override
  String get modePublicSubtitle =>
      'View results, election info, and verify registration without logging in.';

  @override
  String get modeVoterTitle => 'Voter';

  @override
  String get modeVoterSubtitle =>
      'Register, get verified, vote securely, and access your e-Electoral Card.';

  @override
  String get modeObserverTitle => 'Observer';

  @override
  String get modeObserverSubtitle =>
      'Read-only monitoring: audit logs, fraud flags, transparency tools.';

  @override
  String get modeAdminTitle => 'Admin';

  @override
  String get modeAdminSubtitle =>
      'Manage elections, candidates, monitoring, cleaning, bans, and compliance.';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get aboutSub =>
      'Creator details, Trello progress dashboard, strengths & weaknesses.';

  @override
  String get publicPortalTitle => 'Public Portal';

  @override
  String get publicPortalHeadline => 'Public information (no login required)';

  @override
  String get publicResultsTitle => 'Results & Statistics';

  @override
  String get publicResultsSub => 'Live trends, turnout, and final results.';

  @override
  String get publicElectionsInfoTitle => 'Election Types & Guidelines';

  @override
  String get publicElectionsInfoSub =>
      'Understand election types and voter guidelines.';

  @override
  String get verifyRegistrationTitle => 'Verify Registration (Privacy-safe)';

  @override
  String get verifyRegistrationSub =>
      'Verify status using reg number + DOB. Identity stays masked.';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get turnout => 'Turnout';

  @override
  String get totalRegistered => 'Total registered';

  @override
  String get totalVotesCast => 'Votes cast';

  @override
  String get absentee => 'Absentee';

  @override
  String get candidateResults => 'Candidate results';

  @override
  String get electionsInfoHeadline => 'Election types and guidelines (public)';

  @override
  String get guidelinesTitle => 'Guidelines';

  @override
  String get guidelineAgeRules =>
      'Registration: 18+. Voting: 20+. Eligibility is enforced automatically.';

  @override
  String get guidelineOnePersonOneVote =>
      'One person, one vote: duplicate attempts are blocked and audited.';

  @override
  String get guidelineSecrecy =>
      'Vote secrecy: receipts never reveal the chosen candidate.';

  @override
  String get guidelineFraudReporting =>
      'Fraud reporting: suspicious patterns are flagged for observers and admins.';

  @override
  String get electionTypePresidential => 'Presidential Election';

  @override
  String get electionTypePresidentialBody =>
      'Election of the Head of State. Results are monitored live with audit logs and locked after closing.';

  @override
  String get electionTypeLegislative => 'Legislative Election';

  @override
  String get electionTypeLegislativeBody =>
      'Election of members of parliament. Results available by constituency/region in the dashboard.';

  @override
  String get electionTypeMunicipal => 'Municipal Election';

  @override
  String get electionTypeMunicipalBody =>
      'Election of municipal councilors. Results displayed at commune and regional levels.';

  @override
  String get electionTypeRegional => 'Regional Election';

  @override
  String get electionTypeRegionalBody =>
      'Regional council elections. Includes turnout and participation statistics.';

  @override
  String get electionTypeSenatorial => 'Senatorial Election';

  @override
  String get electionTypeSenatorialBody =>
      'Senate elections. Monitoring and audit view available for authorized roles.';

  @override
  String get verifyPrivacyNote =>
      'Privacy note: public verification shows only masked identity information and status.';

  @override
  String get verifyFormRegNumber => 'Registration number';

  @override
  String get verifyFormDob => 'Date of birth';

  @override
  String get verifySubmit => 'Verify';

  @override
  String get requiredField => 'This field is required';

  @override
  String get authRequired => 'Sign in required to continue.';

  @override
  String get invalidRegNumber =>
      'Registration number must be at least 4 characters';

  @override
  String get selectDob => 'Please select your date of birth';

  @override
  String get tapToSelect => 'Tap to select';

  @override
  String get verifyAttemptLimitBody =>
      'Too many verification attempts. Please wait before trying again.';

  @override
  String get cooldown => 'Cooldown';

  @override
  String get verifyResultTitle => 'Verification result';

  @override
  String get maskedName => 'Masked name';

  @override
  String get maskedRegNumber => 'Masked reg number';

  @override
  String get status => 'Status';

  @override
  String get cardExpiry => 'Card expiry';

  @override
  String get verifyStatusNotFound => 'Not found';

  @override
  String get verifyStatusPending => 'Pending verification';

  @override
  String get verifyStatusRegisteredPreEligible =>
      'Registered (18-19, not eligible to vote yet)';

  @override
  String get verifyStatusEligible => 'Eligible to vote';

  @override
  String get verifyStatusVoted => 'Already voted (current election)';

  @override
  String get verifyStatusSuspended => 'Suspended / under review';

  @override
  String get verifyStatusDeceased => 'Removed (deceased)';

  @override
  String get verifyStatusArchived => 'Archived (retention)';

  @override
  String get verifyEligibleToastMessage =>
      'Congratulations! You can now vote in eligible elections.';

  @override
  String get voterPortalTitle => 'Voter Portal';

  @override
  String get voterHome => 'Home';

  @override
  String get voterElections => 'Elections';

  @override
  String get voterVote => 'Vote';

  @override
  String get voterResults => 'Results';

  @override
  String get voterProfile => 'Profile';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get adminDashboardIntro =>
      'Admin web-first dashboard includes election management, monitoring, cleaning, bans, audit and fraud review.';

  @override
  String get observerDashboard => 'Observer Dashboard';

  @override
  String get observerDashboardIntro =>
      'Observer read-only portal includes transparency monitoring, audit logs, fraud flags and restricted voter directory.';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get aboutIntro =>
      'This section will present the creator profile, the project vision, and a Trello-powered progress dashboard (publicly viewable).';

  @override
  String get regionAdamawa => 'Adamawa';

  @override
  String get regionCentre => 'Centre';

  @override
  String get regionEast => 'East';

  @override
  String get regionFarNorth => 'Far North';

  @override
  String get regionLittoral => 'Littoral';

  @override
  String get regionNorth => 'North';

  @override
  String get regionNorthWest => 'North-West';

  @override
  String get regionWest => 'West';

  @override
  String get regionSouth => 'South';

  @override
  String get regionSouthWest => 'South-West';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle =>
      'Security, elections, and system updates.';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get clearAll => 'Clear all';

  @override
  String get noNotifications => 'No notifications yet.';

  @override
  String get audiencePublic => 'Public';

  @override
  String get audienceVoter => 'Voter';

  @override
  String get audienceObserver => 'Observer';

  @override
  String get audienceAdmin => 'Admin';

  @override
  String get audienceAll => 'All';

  @override
  String get toastAllRead => 'All notifications marked as read.';

  @override
  String get notificationElectionSoonTitle => 'Election starts soon';

  @override
  String get notificationElectionSoonBody =>
      'A scheduled election will open soon. Get ready to vote securely.';

  @override
  String get notificationElectionOpenTitle => 'Election is now open';

  @override
  String get notificationElectionOpenBody =>
      'Voting is now open. Cast your ballot securely.';

  @override
  String get notificationElectionClosedTitle => 'Election closed';

  @override
  String get notificationElectionClosedBody =>
      'Voting has closed. Results will be published shortly.';

  @override
  String get notificationSecurityNoticeTitle => 'Security notice';

  @override
  String get notificationSecurityNoticeBody =>
      'Multiple invalid attempts detected on a device. Monitoring is active.';

  @override
  String get notificationStatusUpdateTitle => 'Status update';

  @override
  String get notificationStatusUpdateBody =>
      'You are registered (18-19). You will automatically become eligible at 20.';

  @override
  String get summaryTab => 'Summary';

  @override
  String get chartsTab => 'Charts';

  @override
  String get mapTab => 'Map';

  @override
  String get chartBarTitle => 'Votes by candidate (Bar)';

  @override
  String get chartPieTitle => 'Vote share (Pie)';

  @override
  String get chartLineTitle => 'Turnout trend (Line)';

  @override
  String get chartLineSubtitle =>
      'Visualization will be API-driven once results are published.';

  @override
  String get votesLabel => 'Votes';

  @override
  String get mapTitle => 'Cameroon regions (winner map)';

  @override
  String get mapTapHint => 'Tap a region to see the current leading candidate.';

  @override
  String get mapLegendTitle => 'Legend';

  @override
  String get loading => 'Loading...';

  @override
  String get startupError => 'Startup error';

  @override
  String get error => 'Error';

  @override
  String get genericErrorLabel => 'Something went wrong. Please try again.';

  @override
  String get pleaseWait => 'Please wait';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get refresh => 'Refresh';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get importAction => 'Import';

  @override
  String get search => 'Search';

  @override
  String get noData => 'No data available';

  @override
  String get winnerLabel => 'Winner';

  @override
  String get resultsLive => 'LIVE Results';

  @override
  String get resultsFinal => 'FINAL Results';

  @override
  String get publicResultsAwaitingData =>
      'Awaiting official results publication.';

  @override
  String get mapOfWinners => 'Map of Regional Winners';

  @override
  String get unknown => 'Unknown';

  @override
  String get cameroon => 'Cameroon';

  @override
  String get appSlogan => 'Trust. Transparency. Truth.';

  @override
  String get documentOcrTitle => 'Document Verification (OCR)';

  @override
  String get documentOcrSubtitle =>
      'Upload an official document. We\'ll OCR it and match your details.';

  @override
  String get documentType => 'Document type';

  @override
  String get documentTypeNationalId => 'National ID';

  @override
  String get documentTypePassport => 'Passport';

  @override
  String get documentTypeOther => 'Other official document';

  @override
  String get fullName => 'Full name';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get placeOfBirth => 'Place of birth';

  @override
  String get nationality => 'Nationality';

  @override
  String get nationalityAdminReviewNote =>
      'Nationality will be verified by an admin after document review.';

  @override
  String get pickFromGallery => 'Gallery';

  @override
  String get captureWithCamera => 'Camera';

  @override
  String get runOcr => 'Run OCR & Verify';

  @override
  String get ocrProcessing => 'Processing...';

  @override
  String get ocrExtractedTitle => 'Extracted from document';

  @override
  String get ocrValidationTitle => 'Match result';

  @override
  String get ocrVerifiedTitle => 'Verified';

  @override
  String get ocrRejectedTitle => 'Rejected';

  @override
  String get ocrSummaryVerified => 'Verified';

  @override
  String get ocrSummaryVerifiedPendingNationality =>
      'Verified - Nationality pending admin review';

  @override
  String get ocrSummaryNationalityPending => 'Nationality pending admin review';

  @override
  String get ocrIssueNameMismatch => 'Name mismatch';

  @override
  String get ocrIssueDobMismatch => 'Date of birth mismatch';

  @override
  String get ocrIssuePobMismatch => 'Place of birth mismatch';

  @override
  String get ocrIssueForeignDocument => 'Foreign document detected';

  @override
  String get ocrVerified => 'Document verified...';

  @override
  String get ocrRejected => 'Verification rejected';

  @override
  String get ocrFailedTitle => 'OCR failed';

  @override
  String get rawOcrText => 'Raw OCR text';

  @override
  String get tryAnotherDoc => 'Try another document';

  @override
  String get continueNext => 'Continue';

  @override
  String get ocrNotSupportedTitle => 'OCR not available here';

  @override
  String get ocrNotSupportedMessage =>
      'Document OCR works on Android/iOS. Use the mobile app for registration.';

  @override
  String get foreignDocumentTitle => 'Document not eligible';

  @override
  String get foreignDocumentBody =>
      'This document does not appear to be a Cameroonian official document. Registration is limited to Cameroonian citizens.';

  @override
  String get underageRegistrationTitle => 'Registration not allowed';

  @override
  String get underageRegistrationBody =>
      'You must be at least 18 years old to register. Please use the public portal for information and updates.';

  @override
  String get userLabel => 'User';

  @override
  String loginTitle(Object role) {
    return '$role sign in';
  }

  @override
  String get adminTipReviewTitle => 'Tip review';

  @override
  String get adminTipReviewSubtitle =>
      'Confirm manual tips (TapTap Send, Remitly, Orange Money Max It QR) and track proof submissions.';

  @override
  String get adminTipNoTips => 'No tips found.';

  @override
  String get adminTipFilterAll => 'All';

  @override
  String get adminTipFilterSubmitted => 'Submitted';

  @override
  String get adminTipFilterPending => 'Pending';

  @override
  String get adminTipFilterSuccess => 'Confirmed';

  @override
  String get adminTipFilterFailed => 'Rejected';

  @override
  String get adminTipApproveTitle => 'Confirm tip';

  @override
  String get adminTipRejectTitle => 'Reject tip';

  @override
  String get adminTipDecisionNoteLabel => 'Decision note';

  @override
  String get adminTipDecisionSuccess => 'Tip status updated.';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String loginHeaderTitle(Object role) {
    return 'Secure access for $role';
  }

  @override
  String get loginHeaderSubtitle =>
      'Verify identity, continue securely, and protect every action.';

  @override
  String get authInvalidCredentials => 'Invalid email/ID or password.';

  @override
  String get invalidEmailAddress => 'Enter a valid email address.';

  @override
  String get authAccountNotFound => 'No account was found for this user.';

  @override
  String get authTooManyRequests =>
      'Too many attempts. Please wait and try again.';

  @override
  String get authNetworkError =>
      'Network issue detected. Check your connection and retry.';

  @override
  String get authMustChangePassword => 'Change temporary password';

  @override
  String get authMustChangePasswordHelp =>
      'For transparency and account ownership, set your own password before continuing.';

  @override
  String get authUpdatePasswordAction => 'Update password';

  @override
  String get authPasswordUpdated => 'Password updated successfully.';

  @override
  String get loginRequiresVerification =>
      'Your registration is pending verification. You can sign in once an admin approves your Cameroonian document.';

  @override
  String get loginIdentifierLabel => 'Email or registration ID';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String passwordMinLength(Object length) {
    return 'Min $length characters';
  }

  @override
  String get signIn => 'Sign in';

  @override
  String get signInSubtitle => 'Access voter, observer, or admin portals';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountSubtitle =>
      'Permanent removal with legal retention rules';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordSubtitle =>
      'We will send a secure reset link to your account.';

  @override
  String get forgotPasswordSend => 'Send reset link';

  @override
  String get forgotPasswordSending => 'Sending...';

  @override
  String get forgotPasswordSuccess => 'Reset link sent.';

  @override
  String get forgotPasswordNeedHelpTitle => 'Need help?';

  @override
  String get forgotPasswordNeedHelpSubtitle =>
      'Contact support for account recovery.';

  @override
  String get forgotPasswordHeroTitle => 'Account recovery';

  @override
  String get forgotPasswordHeroSubtitle =>
      'Verify your identity and regain secure access.';

  @override
  String get biometricLogin => 'Use biometrics';

  @override
  String continueAs(Object name) {
    return 'Continue as $name';
  }

  @override
  String get biometricWebNotice =>
      'Biometric login is available on Android and iOS.';

  @override
  String get biometricNotAvailable =>
      'Biometrics are not available on this device.';

  @override
  String get biometricEnrollRequired =>
      'No biometrics enrolled. Please enroll Face ID or Fingerprint in your device settings.';

  @override
  String get biometricReasonSignIn => 'Confirm your identity to sign in.';

  @override
  String get biometricReasonEnable => 'Enable biometric login for CamVote.';

  @override
  String get biometricLoginTitle => 'Biometric + liveness login';

  @override
  String get biometricLoginSubtitle =>
      'Require device biometrics and liveness for sign in.';

  @override
  String get biometricEnableRequiresLogin =>
      'Please sign in before enabling biometric + liveness login.';

  @override
  String get securityChipBiometric => 'Biometric gate';

  @override
  String get securityChipLiveness => 'Liveness checks';

  @override
  String get securityChipAuditReady => 'Audit ready';

  @override
  String get securityChipFraudShield => 'Fraud shield';

  @override
  String rolePortalTitle(Object role) {
    return '$role portal';
  }

  @override
  String get rolePortalSubtitle => 'Secured with biometrics and live checks.';

  @override
  String get newVoterRegistrationTitle => 'New voter registration';

  @override
  String get newVoterRegistrationSubtitle =>
      'Start your registration and verification flow.';

  @override
  String get accountSectionTitle => 'Account';

  @override
  String get securitySectionTitle => 'Security';

  @override
  String get supportSectionTitle => 'Support';

  @override
  String get onboardingSectionTitle => 'Onboarding';

  @override
  String get onboardingReplayTitle => 'Revisit onboarding';

  @override
  String get onboardingReplaySubtitle => 'Replay the CamVote introduction';

  @override
  String get helpSupportTitle => 'Help & Support';

  @override
  String get helpSupportSubtitle =>
      'We respond fast to voting, security, and fraud issues.';

  @override
  String get helpSupportLoginSubtitle =>
      'Get help with access or security issues';

  @override
  String get helpSupportSettingsSubtitle =>
      'Get help with security or voting issues';

  @override
  String get helpSupportPublicSubtitle => 'Report issues or request assistance';

  @override
  String get helpSupportEmergencyTitle => 'Emergency contact';

  @override
  String get helpSupportEmailLabel => 'Email';

  @override
  String get helpSupportHotlineLabel => 'Hotline';

  @override
  String get helpSupportRegistrationIdLabel => 'Registration ID (optional)';

  @override
  String get helpSupportCategoryLabel => 'Category';

  @override
  String get helpSupportMessageLabel => 'Describe the issue';

  @override
  String get helpSupportSubmit => 'Submit ticket';

  @override
  String get helpSupportSubmitting => 'Sending...';

  @override
  String get helpSupportSubmissionFailed => 'Submission failed.';

  @override
  String helpSupportTicketReceived(Object ticketId) {
    return 'Ticket received. Reference: $ticketId';
  }

  @override
  String helpSupportTicketQueued(Object queueId) {
    return 'Ticket queued offline. Reference: $queueId. It will auto-send when connection returns.';
  }

  @override
  String offlineQueuedWithReference(Object queueId) {
    return 'Action queued offline. Reference: $queueId. It will auto-sync when connection returns.';
  }

  @override
  String get helpSupportOfflineQueueTitle => 'Pending offline sync';

  @override
  String helpSupportOfflineQueueBodyCount(Object count) {
    return '$count support ticket(s) are queued offline and will auto-send when connection returns.';
  }

  @override
  String get offlineBannerOfflineTitle => 'You\'re offline';

  @override
  String get offlineBannerPendingTitle => 'Sync pending';

  @override
  String get offlineBannerOfflineBody =>
      'Some actions may be queued and will auto-sync when connection returns.';

  @override
  String offlineBannerOfflineBodyCount(Object count) {
    return '$count action(s) are queued and will auto-sync when connection returns.';
  }

  @override
  String offlineBannerPendingBodyCount(Object count) {
    return '$count action(s) are ready to sync.';
  }

  @override
  String get offlineBannerSyncNow => 'Sync now';

  @override
  String offlineBannerSyncedCount(Object count) {
    return 'Synced $count item(s).';
  }

  @override
  String get offlineBannerHintAdmin =>
      'Admin: keep working offline. CamVote will sync when internet returns (support replies, incidents, tip proofs/decisions, audits, notification reads).';

  @override
  String get offlineBannerHintObserver =>
      'Observer: you can still report incidents and update your checklist offline. Evidence uploads and status updates will sync automatically.';

  @override
  String get offlineBannerHintVoter =>
      'Voter: you can browse cached pages offline. Key submissions (registration, support tickets, tip proofs) queue and sync when you are back online.';

  @override
  String get offlineBannerHintPublic =>
      'Public: cached info remains available. New updates load automatically when internet returns.';

  @override
  String get helpSupportAiTitle => 'CamGuide assistant';

  @override
  String get helpSupportAiSubtitle =>
      'Ask about registration, observer rules, vote security, incidents, or Cameroon election context.';

  @override
  String get helpSupportAiInputHint => 'Ask CamGuide a question...';

  @override
  String get helpSupportAiSend => 'Ask';

  @override
  String get helpSupportAiThinking => 'CamGuide is thinking...';

  @override
  String get helpSupportAiSourcesLabel => 'Sources';

  @override
  String get helpSupportAiSuggestionsLabel => 'Suggested follow-ups';

  @override
  String get helpSupportFaqTitle => 'FAQs';

  @override
  String get helpSupportFaqRegistration =>
      'How do I register? Complete OCR + biometrics enrollment.';

  @override
  String get helpSupportFaqLiveness =>
      'Why liveness checks? To prevent automated or replay fraud.';

  @override
  String get helpSupportFaqReceipt =>
      'How do I verify my vote? Use your receipt token.';

  @override
  String get supportCategoryRegistration => 'Registration';

  @override
  String get supportCategoryVoting => 'Voting';

  @override
  String get supportCategoryBiometrics => 'Biometrics';

  @override
  String get supportCategoryFraud => 'Fraud report';

  @override
  String get supportCategoryTechnical => 'Technical';

  @override
  String get supportCategoryOther => 'Other';

  @override
  String get roleGatewayWebHint => 'Web: public, observer, admin';

  @override
  String get roleGatewayMobileHint => 'Mobile: public and voter';

  @override
  String get roleGatewaySubtitle =>
      'Pick the portal that matches your mission today.';

  @override
  String get roleGatewayFeatureVerifiedTitle => 'Verified identity';

  @override
  String get roleGatewayFeatureVerifiedSubtitle => 'Biometrics + liveness';

  @override
  String get roleGatewayFeatureFraudTitle => 'Fraud defenses';

  @override
  String get roleGatewayFeatureFraudSubtitle => 'Device + AI signals';

  @override
  String get roleGatewayFeatureTransparencyTitle => 'Transparent results';

  @override
  String get roleGatewayFeatureTransparencySubtitle => 'Live public dashboards';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingEnter => 'Enter CamVote';

  @override
  String get onboardingSlide1Title => 'Identity you can trust';

  @override
  String get onboardingSlide1Subtitle =>
      'Biometric and liveness checks secure registration, voting, and every sensitive action.';

  @override
  String get onboardingSlide1Highlight1 => 'Liveness verification';

  @override
  String get onboardingSlide1Highlight2 => 'Privacy-safe receipts';

  @override
  String get onboardingSlide1Highlight3 => 'One person, one vote';

  @override
  String get onboardingSlide2Title => 'Transparent public results';

  @override
  String get onboardingSlide2Subtitle =>
      'Live dashboards show turnout, counts, and verified updates for everyone.';

  @override
  String get onboardingSlide2Highlight1 => 'Live results feeds';

  @override
  String get onboardingSlide2Highlight2 => 'Regional drilldowns';

  @override
  String get onboardingSlide2Highlight3 => 'Observer-ready views';

  @override
  String get onboardingSlide3Title => 'Fraud defense at every step';

  @override
  String get onboardingSlide3Subtitle =>
      'AI risk signals, device integrity, and audit logs keep elections safe.';

  @override
  String get onboardingSlide3Highlight1 => 'AI risk signals';

  @override
  String get onboardingSlide3Highlight2 => 'Device integrity checks';

  @override
  String get onboardingSlide3Highlight3 => 'Immutable audit trails';

  @override
  String get chartBarLabel => 'Bar';

  @override
  String get chartPieLabel => 'Pie';

  @override
  String get chartLineLabel => 'Line';

  @override
  String get winnerVotesLabel => 'Winner votes';

  @override
  String get totalVotesLabel => 'Total votes';

  @override
  String get aboutBuilderTitle => 'About the builder';

  @override
  String get aboutBuilderSubtitle =>
      'Meet the vision, mission, and roadmap behind CamVote.';

  @override
  String get aboutProfileName => 'DJAGNI SIGNING Romuald';

  @override
  String get aboutProfileTitle =>
      'Computer Science Engineering Undergraduate - Civic-Tech Builder';

  @override
  String get aboutProfileTagline =>
      'Building trustworthy digital elections for Cameroon.';

  @override
  String get aboutProfileVision =>
      'A transparent, secure, and inclusive electoral system that restores trust by making every step verifiable, accessible, and audit-ready.';

  @override
  String get aboutProfileMission =>
      'Design systems that protect voter identity, prevent fraud, and publish results quickly without compromising integrity.';

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
  String get aboutTagSecureVoting => 'Secure voting';

  @override
  String get aboutTagBiometrics => 'Biometrics';

  @override
  String get aboutTagAuditTrails => 'Audit trails';

  @override
  String get aboutTagOfflineFirst => 'Offline-first UX';

  @override
  String get aboutTagAccessibility => 'Accessibility';

  @override
  String get aboutTagLocalization => 'EN/FR localization';

  @override
  String get aboutVisionMissionTitle => 'Vision & Mission';

  @override
  String get aboutVisionTitle => 'Vision';

  @override
  String get aboutMissionTitle => 'Mission';

  @override
  String get aboutContactSocialTitle => 'Contact & Social';

  @override
  String get aboutProductFocusTitle => 'Product Focus';

  @override
  String get aboutTrelloTitle => 'Trello Board Stats';

  @override
  String get aboutConnectTrelloTitle => 'Connect Trello';

  @override
  String get aboutConnectTrelloBody =>
      'Set CAMVOTE_TRELLO_KEY, CAMVOTE_TRELLO_TOKEN, and CAMVOTE_TRELLO_BOARD_ID to show live board stats.';

  @override
  String get aboutTrelloLoadingTitle => 'Loading Trello data';

  @override
  String get aboutTrelloLoadingBody => 'Fetching live project stats...';

  @override
  String get aboutTrelloUnavailableTitle => 'Trello unavailable';

  @override
  String aboutTrelloUnavailableBody(Object error) {
    return 'Unable to fetch board stats: $error';
  }

  @override
  String get aboutTrelloNotConfiguredTitle => 'Trello not configured';

  @override
  String get aboutTrelloNotConfiguredBody =>
      'Add Trello credentials to enable live stats.';

  @override
  String get aboutProfileLoadingTitle => 'Loading profile';

  @override
  String get aboutProfileLoadingBody => 'Fetching builder profile...';

  @override
  String get aboutProfileUnavailableTitle => 'Profile unavailable';

  @override
  String aboutProfileUnavailableBody(Object error) {
    return 'Unable to load profile: $error';
  }

  @override
  String get aboutProfileUnavailableEmpty => 'No profile data';

  @override
  String get aboutSkillsHobbiesTitle => 'Skills & hobbies';

  @override
  String get aboutHobbyMusic => 'Music';

  @override
  String get aboutHobbyReading => 'Reading';

  @override
  String get aboutHobbyWriting => 'Writing';

  @override
  String get aboutHobbySinging => 'Singing';

  @override
  String get aboutHobbyCooking => 'Cooking';

  @override
  String get aboutHobbyCoding => 'Coding';

  @override
  String get aboutHobbySleeping => 'Sleeping';

  @override
  String get legalSourceElecamUrl => 'https://portail.elecam.cm';

  @override
  String get legalSourceAssnatUrl => 'https://www.assnat.cm';

  @override
  String get aboutWhyCamVoteTitle => 'Why CamVote';

  @override
  String get aboutWhyCamVoteBody =>
      'CamVote demonstrates how civic tech can reduce irregularities, improve transparency, and return credible results quickly.';

  @override
  String get aboutCopyEmail => 'Copy email';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordConfirmLabel => 'Confirm password';

  @override
  String get registrationAuthTitle => 'Create your secure account';

  @override
  String get registrationAuthSubtitle =>
      'Your email and password will secure access after approval.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get aboutCopyLinkedIn => 'Copy LinkedIn';

  @override
  String get aboutCopyGitHub => 'Copy GitHub';

  @override
  String get aboutCopyBoardUrl => 'Copy board URL';

  @override
  String get aboutBoardUrlLabel => 'Board URL';

  @override
  String get aboutLastActivityLabel => 'Last activity';

  @override
  String get aboutTopListsLabel => 'Top lists';

  @override
  String get aboutStatTotal => 'Total';

  @override
  String get aboutStatOpen => 'Open';

  @override
  String get aboutStatDone => 'Done';

  @override
  String aboutFooterBuiltBy(Object name, Object year) {
    return '(c) $year CamVote - Built by $name';
  }

  @override
  String copiedMessage(Object label) {
    return '$label copied';
  }

  @override
  String get registrationHubTitle => 'Registration';

  @override
  String get registrationHubSubtitle =>
      'Start your secure voter enrollment process.';

  @override
  String get deviceAccountPolicyTitle => 'Device Account Policy';

  @override
  String deviceAccountPolicyBody(Object count, Object max) {
    return 'This device currently has $count/$max registered accounts.\nMax $max accounts per device to reduce fraud.';
  }

  @override
  String get biometricEnrollmentTitle => 'Biometric enrollment';

  @override
  String get biometricEnrollmentStatusComplete =>
      'Completed and ready for verification.';

  @override
  String get biometricEnrollmentStatusPending => 'Pending completion.';

  @override
  String get statusComplete => 'Complete';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusRequired => 'Required';

  @override
  String get statusEnrolled => 'Enrolled';

  @override
  String get statusVerified => 'Verified';

  @override
  String get registrationBlockedTitle => 'Registration blocked on this device';

  @override
  String get registrationBlockedBody =>
      'This device already reached the maximum number of accounts.\nIf this is a mistake, you can request review via support.';

  @override
  String get startVoterRegistration => 'Start Voter Registration';

  @override
  String get backToPublicMode => 'Back to Public Mode';

  @override
  String errorWithDetails(Object details) {
    return 'Error: $details';
  }

  @override
  String get registrationDraftTitle => 'Voter Registration (Draft)';

  @override
  String get registrationDraftHeaderTitle => 'Voter Registration';

  @override
  String get registrationDraftHeaderSubtitle =>
      'Complete your personal details to begin verification.';

  @override
  String get draftSaved => 'Draft saved';

  @override
  String get draftNotSaved => 'Draft not saved';

  @override
  String get draftSavedSubtitle =>
      'You can save and resume anytime. Next step: OCR + Liveness.';

  @override
  String get clearDraft => 'Clear draft';

  @override
  String get regionLabel => 'Region';

  @override
  String get pickDateOfBirth => 'Pick date of birth';

  @override
  String dateOfBirthWithValue(Object date) {
    return 'DOB: $date';
  }

  @override
  String get saveDraft => 'Save draft';

  @override
  String get registrationReviewTitle => 'Review registration';

  @override
  String get registrationReviewSubtitle =>
      'Confirm your data before submitting.';

  @override
  String get registrationSectionPersonalDetails => 'Personal details';

  @override
  String get registrationSectionDocumentVerification => 'Document verification';

  @override
  String get registrationSectionSecurityEnrollment => 'Security enrollment';

  @override
  String get summaryLabel => 'Summary';

  @override
  String get nameMatchLabel => 'Name match';

  @override
  String get dobMatchLabel => 'DOB match';

  @override
  String get pobMatchLabel => 'POB match';

  @override
  String get nationalityMatchLabel => 'Nationality match';

  @override
  String get nameLabel => 'Name';

  @override
  String get dateOfBirthShort => 'DOB';

  @override
  String get placeOfBirthShort => 'POB';

  @override
  String get biometricsLabel => 'Biometrics';

  @override
  String get livenessLabel => 'Liveness';

  @override
  String get registrationConsentTitle =>
      'I confirm all information is accurate.';

  @override
  String get registrationConsentSubtitle =>
      'I consent to the secure processing of my registration data.';

  @override
  String get registrationSubmitting => 'Submitting...';

  @override
  String get registrationRenewing => 'Renewing electoral registration...';

  @override
  String get registrationSubmit => 'Submit registration';

  @override
  String get registrationSubmitBlockedNote =>
      'Complete document verification and enrollment to submit.';

  @override
  String get registrationSubmissionFailed => 'Submission failed.';

  @override
  String get registrationRenewalFailed => 'Renewal failed.';

  @override
  String get failed => 'Failed';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get registrationSubmittedTitle => 'Registration submitted';

  @override
  String get registrationSubmittedSubtitle =>
      'Your application is now in review.';

  @override
  String get registrationSubmittedNote =>
      'You will be notified once verification is complete. Keep your tracking ID safe for follow-up.';

  @override
  String get trackingIdLabel => 'Tracking ID';

  @override
  String get messageLabel => 'Message';

  @override
  String get goToVoterLogin => 'Go to voter login';

  @override
  String get continueToLogin => 'Continue to login';

  @override
  String get deletedAccountLoginTitle => 'Account already exists';

  @override
  String get deletedAccountLoginBody =>
      'This voter record already exists in the registry and cannot be re-registered. Please sign in with biometrics + liveness to continue.';

  @override
  String get deletedAccountRenewedTitle => 'Record renewed';

  @override
  String get deletedAccountRenewedBody =>
      'Your previous record exists, but the e-electoral card had expired. We renewed the record. Please sign in to continue.';

  @override
  String get backToPublicPortal => 'Back to Public portal';

  @override
  String get registrationStatusPending => 'Pending';

  @override
  String get registrationStatusApproved => 'Approved';

  @override
  String get registrationStatusRejected => 'Rejected';

  @override
  String get biometricEnrollmentSubtitle =>
      'Secure your identity with biometrics and liveness.';

  @override
  String biometricEnrollmentSubtitleWithName(Object name) {
    return 'Secure $name with biometrics and liveness.';
  }

  @override
  String get biometricEnrollmentStep1Title => 'Step 1: Enroll biometrics';

  @override
  String get biometricEnrollmentStep1Subtitle =>
      'We verify your fingerprint or Face ID using your device.';

  @override
  String get biometricEnrollmentStep2Title => 'Step 2: Liveness check';

  @override
  String get biometricEnrollmentStep2Subtitle =>
      'Confirm you are present in front of the camera right now.';

  @override
  String get recheck => 'Recheck';

  @override
  String get enrollNow => 'Enroll now';

  @override
  String get reverifyBiometrics => 'Re-verify biometrics';

  @override
  String get runLiveness => 'Run liveness';

  @override
  String get reverifyLiveness => 'Re-verify liveness';

  @override
  String get enrollmentCompleteTitle => 'Enrollment complete';

  @override
  String get enrollmentInProgressTitle => 'Enrollment in progress';

  @override
  String get enrollmentCompleteBody => 'You can now finish registration.';

  @override
  String get enrollmentInProgressBody => 'Complete both steps to continue.';

  @override
  String get finishEnrollment => 'Finish enrollment';

  @override
  String get biometricPrivacyNote =>
      'Your biometric data is stored securely on your device and is never saved as raw images.';

  @override
  String get biometricEnrollReason => 'Enroll biometrics for secure voting.';

  @override
  String get biometricVerificationFailed => 'Biometric verification failed.';

  @override
  String get biometricEnrollmentRecorded => 'Biometric enrollment recorded.';

  @override
  String get livenessCheckFailed => 'Liveness check failed.';

  @override
  String get livenessVerifiedToast => 'Liveness verified.';

  @override
  String get livenessCheckTitle => 'Liveness Check';

  @override
  String get livenessCameraPermissionRequired =>
      'Camera permission is required.';

  @override
  String get livenessNoCameraAvailable => 'No camera available.';

  @override
  String get livenessPreparingCamera => 'Preparing camera...';

  @override
  String get livenessHoldSteady => 'Hold steady for verification.';

  @override
  String livenessStepLabel(Object step, Object total) {
    return 'Step $step of $total';
  }

  @override
  String get livenessVerifiedMessage => 'Liveness verified.';

  @override
  String get livenessPromptHoldSteady => 'Hold steady. Follow the prompt.';

  @override
  String get livenessPromptCenterFace => 'Center your face in the frame.';

  @override
  String get livenessPromptAlignFace => 'Align your face to continue.';

  @override
  String get livenessStatusNoFace => 'No face detected';

  @override
  String get livenessStatusFaceCentered => 'Face centered';

  @override
  String get livenessStatusAdjustPosition => 'Adjust position';

  @override
  String get livenessGoodLight => 'Good light';

  @override
  String get livenessOpenSettings => 'Open settings';

  @override
  String get livenessTaskBlinkTitle => 'Blink your eyes';

  @override
  String get livenessTaskBlinkSubtitle => 'Close both eyes, then open them.';

  @override
  String get livenessTaskTurnLeftTitle => 'Turn left';

  @override
  String get livenessTaskTurnLeftSubtitle =>
      'Gently turn your head to the left.';

  @override
  String get livenessTaskTurnRightTitle => 'Turn right';

  @override
  String get livenessTaskTurnRightSubtitle =>
      'Gently turn your head to the right.';

  @override
  String get livenessTaskSmileTitle => 'Give a slight smile';

  @override
  String get livenessTaskSmileSubtitle => 'Relax your face and smile briefly.';

  @override
  String get voteBiometricsSubtitle =>
      'Biometrics + liveness required for every vote.';

  @override
  String get noOpenElections => 'No election is currently open for voting.';

  @override
  String electionScopeLabel(Object scope) {
    return 'Scope: $scope';
  }

  @override
  String get alreadyVotedInElection =>
      '... You already voted in this election.';

  @override
  String get voteAction => 'Vote';

  @override
  String get deviceBlockedMessage => 'This device is temporarily blocked.';

  @override
  String deviceBlockedUntil(Object until) {
    return 'Until: $until';
  }

  @override
  String get electionLockedOnDevice =>
      'This election is locked on this device.';

  @override
  String get confirmVoteTitle => 'Confirm vote';

  @override
  String confirmVoteBody(Object candidate, Object party) {
    return 'You are about to vote.\n\nSelected: $candidate ($party)\n\nYou will be asked to verify with biometrics + liveness.';
  }

  @override
  String get voteBiometricReason => 'Confirm your identity to cast this vote.';

  @override
  String get voteReceiptTitle => 'Vote receipt';

  @override
  String get voteReceiptSubtitle =>
      'Private verification receipt for your vote.';

  @override
  String get candidateHashLabel => 'Candidate hash';

  @override
  String get partyHashLabel => 'Party hash';

  @override
  String get castAtLabel => 'Cast at';

  @override
  String get auditTokenLabel => 'Audit token';

  @override
  String get tokenCopied => 'Token copied';

  @override
  String get copyAction => 'Copy';

  @override
  String get shareAction => 'Share';

  @override
  String get printReceiptAction => 'Print receipt';

  @override
  String get receiptSafetyNote =>
      'Keep this token safe. It lets you verify that your vote was included in the public audit log without revealing your choice.';

  @override
  String receiptShareMessage(Object token) {
    return 'CamVote receipt token: $token';
  }

  @override
  String get receiptBiometricReason =>
      'Confirm your identity to access this receipt.';

  @override
  String get receiptPdfTitle => 'CamVote Receipt';

  @override
  String get electionLabel => 'Election';

  @override
  String get receiptPrivacyNote =>
      'This receipt protects vote privacy by hashing the selection.';

  @override
  String get electoralCardTitle => 'e-Electoral Card';

  @override
  String get electoralCardSubtitle =>
      'Your verified digital voter identity card.';

  @override
  String get electoralCardIncompleteNote =>
      'Complete voter registration to generate your e-Electoral card.';

  @override
  String get electoralCardLockedTitle => 'CamVote e-Electoral Card';

  @override
  String get electoralCardLockedSubtitle => 'Unlock to view your card details.';

  @override
  String get verifyToUnlock => 'Verify to unlock';

  @override
  String get electoralCardBiometricReason => 'Unlock your e-Electoral Card.';

  @override
  String get electoralCardQrNote =>
      'This QR token is used to verify registration status without exposing personal details.';

  @override
  String get electionsBrowseSubtitle =>
      'Browse scheduled elections and candidates.';

  @override
  String get electionStatusUpcoming => 'Upcoming';

  @override
  String get electionStatusOpen => 'Open';

  @override
  String get electionStatusClosed => 'Closed';

  @override
  String get opensLabel => 'Opens';

  @override
  String get closesLabel => 'Closes';

  @override
  String get candidatesLabel => 'Candidates';

  @override
  String get voterHomeSubtitle =>
      'Track your status, protect your vote, and stay informed.';

  @override
  String get nextElectionTitle => 'Next election';

  @override
  String nextElectionCountdown(Object days, Object time) {
    return '$days days - $time';
  }

  @override
  String get nextElectionCountdownLabelDays => 'Days';

  @override
  String get nextElectionCountdownLabelHours => 'Hours';

  @override
  String get nextElectionCountdownLabelMinutes => 'Minutes';

  @override
  String get nextElectionCountdownLabelSeconds => 'Seconds';

  @override
  String candidatesCountLabel(Object count) {
    return 'Candidates: $count';
  }

  @override
  String get voterResultsSubtitle =>
      'Track results and verify your vote receipts.';

  @override
  String get resultsPublicPortalNote =>
      'Live results are available in the Public portal charts.\nUse the Voter portal for your personal verification and receipt.';

  @override
  String get pastElectionsTitle => 'Past elections';

  @override
  String get noClosedElections => 'No closed election yet.';

  @override
  String get yourReceiptsTitle => 'Your receipts';

  @override
  String get noReceiptsYet => 'No receipts yet.';

  @override
  String auditTokenShortLabel(Object token) {
    return 'Audit token: $token';
  }

  @override
  String get voterProfileSubtitle =>
      'Manage your identity, security, and preferences.';

  @override
  String get signedInVoter => 'Signed in voter';

  @override
  String get verificationStatusTitle => 'Verification status';

  @override
  String get verificationStatusVerified =>
      'Verified identity and eligible status.';

  @override
  String get verificationStatusPending =>
      'Pending verification. Complete OCR + biometrics.';

  @override
  String get verificationPendingTitle => 'Verification pending';

  @override
  String get verificationPendingSubtitle =>
      'You are signed in, but voting stays locked until your Cameroonian document is approved.';

  @override
  String get verificationPendingBody =>
      'An admin will review your document and registration details. You will be notified when approved.';

  @override
  String get verificationTimelineTitle => 'Verification timeline';

  @override
  String get verificationStepSubmittedTitle => 'Registration received';

  @override
  String get verificationStepSubmittedBody =>
      'We have received your registration package.';

  @override
  String get verificationStepReviewTitle => 'Admin review in progress';

  @override
  String get verificationStepReviewBody =>
      'Your documents are being checked for validity.';

  @override
  String get verificationStepDecisionTitle => 'Decision notification';

  @override
  String get verificationStepDecisionBody =>
      'You will be notified as soon as approval is complete.';

  @override
  String get verificationPendingPrimaryAction => 'Check registration status';

  @override
  String get verificationPendingSecondaryAction => 'Go to public portal';

  @override
  String get verificationPendingSupportAction => 'Contact support';

  @override
  String get verificationPendingSignOut => 'Sign out';

  @override
  String get electoralCardViewSubtitle => 'View your digital voter card';

  @override
  String get votingCentersTitle => 'Voting centers map';

  @override
  String get votingCentersSubtitle =>
      'Find verified voting centers near you and view details.';

  @override
  String get votingCentersPublicSubtitle =>
      'Locate nearby voting centers and eligibility desks.';

  @override
  String get votingCentersSelectTitle => 'Select a voting center';

  @override
  String get votingCentersSelectSubtitle =>
      'Choose a center for physical registration or voting.';

  @override
  String get votingCenterSelectPrompt => 'Select a center to continue';

  @override
  String get votingCenterSelectAction => 'Use this center';

  @override
  String get votingCentersSearchHint =>
      'Search by city, neighborhood, or center name';

  @override
  String get votingCentersFilterAll => 'All';

  @override
  String get votingCentersFilterCameroon => 'Cameroon';

  @override
  String get votingCentersFilterAbroad => 'Abroad';

  @override
  String get votingCentersFilterEmbassy => 'Missions';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get votingCentersMapTitle => 'Cameroon voting centers';

  @override
  String get votingCentersMapHint =>
      'Tap a marker to view a center and select it.';

  @override
  String get votingCentersLegendTitle => 'Map legend';

  @override
  String get votingCentersLegendCenter => 'Voting center';

  @override
  String get votingCentersLegendAbroad => 'Abroad';

  @override
  String get votingCentersLegendEmbassy => 'Mission';

  @override
  String get votingCentersLegendYou => 'You are here';

  @override
  String get votingCentersNearbyTitle => 'Nearby centers';

  @override
  String get votingCentersNearbySubtitle =>
      'Ordered by distance when location is available.';

  @override
  String get votingCentersEmpty =>
      'No centers available right now. Please refresh or check back soon.';

  @override
  String distanceKm(Object km) {
    return '$km km';
  }

  @override
  String get votingCenterNotSelectedTitle => 'No center selected';

  @override
  String get votingCenterNotSelectedSubtitle =>
      'Pick a voting center to complete your registration.';

  @override
  String get votingCenterSelectedTitle => 'Selected voting center';

  @override
  String get votingCenterLabel => 'Voting center';

  @override
  String get clearSelection => 'Clear selection';

  @override
  String get biometricsUnavailableTitle => 'Device not compatible';

  @override
  String get biometricsUnavailableBody =>
      'Biometrics or liveness are unavailable on this device. Use a physical center for registration or voting.';

  @override
  String get locationServicesDisabled =>
      'Location services are disabled. Enable them to find nearby centers.';

  @override
  String get locationPermissionDenied =>
      'Location permission denied. Allow access to find nearby centers.';

  @override
  String get locationPermissionDeniedForever =>
      'Location permission permanently denied. Update permissions in device settings.';

  @override
  String get settingsSubtitle =>
      'Personalize your experience and security controls.';

  @override
  String get themeStyleTitle => 'Theme style';

  @override
  String get themeStyleClassic => 'Classic';

  @override
  String get themeStyleCameroon => 'Cameroon';

  @override
  String get themeStyleGeek => 'Geek';

  @override
  String get themeStyleFruity => 'Fruity';

  @override
  String get themeStylePro => 'Pro';

  @override
  String get themeStyleMagic => 'Magic';

  @override
  String get themeStyleFun => 'Fun';

  @override
  String get deleteAccountHeaderSubtitle =>
      'This action is permanent and requires verification.';

  @override
  String get deleteAccountBody =>
      'This action is permanent. Your access will be removed, while legal retention rules apply to official electoral records.';

  @override
  String deleteAccountConfirmLabel(Object keyword) {
    return 'Type $keyword to confirm';
  }

  @override
  String get deleteKeyword => 'DELETE';

  @override
  String get deleteAccountConfirmError => 'Confirmation required.';

  @override
  String get deleteAccountBiometricReason => 'Confirm account deletion.';

  @override
  String get deletingAccount => 'Deleting...';

  @override
  String get missingReceiptData => 'Missing receipt data.';

  @override
  String get missingRegistrationData => 'Missing registration data.';

  @override
  String get missingSubmissionDetails => 'Missing submission details.';

  @override
  String get signedInUser => 'Signed in';

  @override
  String get adminVoterManagementTitle => 'Voter Management';

  @override
  String get adminVoterManagementSubtitle =>
      'Monitor registrations, verification, and flags.';

  @override
  String get adminRunListCleaningTooltip => 'Run electoral list cleaning';

  @override
  String get adminListCleaningDone =>
      'Cleaning done. Suspicious voters suspended.';

  @override
  String get voterSearchHint => 'Search by name or voter ID...';

  @override
  String get filterRegion => 'Filter region';

  @override
  String get filterStatus => 'Filter status';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String regionFilterLabel(Object region) {
    return 'Region: $region';
  }

  @override
  String statusFilterLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String get noVotersMatchFilters => 'No voters match your filters.';

  @override
  String get deviceFlaggedLabel => 'Device flagged';

  @override
  String get biometricDuplicateLabel => 'Biometric duplicate';

  @override
  String ageLabel(Object age) {
    return 'Age $age';
  }

  @override
  String flagsLabel(Object signals) {
    return 'Flags: $signals';
  }

  @override
  String get voterHasVotedLabel => 'Voted';

  @override
  String get voterNotVotedLabel => 'Not voted';

  @override
  String get chooseRegionTitle => 'Choose region';

  @override
  String get chooseStatusTitle => 'Choose status';

  @override
  String get riskLow => 'Low';

  @override
  String get riskMedium => 'Medium';

  @override
  String get riskHigh => 'High';

  @override
  String get riskCritical => 'Critical';

  @override
  String riskLabel(Object risk) {
    return 'AI $risk';
  }

  @override
  String get statusPendingVerification => 'Pending verification';

  @override
  String get statusRegistered => 'Registered';

  @override
  String get statusPreEligible => 'Pre-eligible (18-19)';

  @override
  String get statusEligible => 'Eligible (20+)';

  @override
  String get statusVoted => 'Voted';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get statusDeceased => 'Deceased';

  @override
  String get statusArchived => 'Archived';

  @override
  String get adminDashboardHeaderSubtitle =>
      'Monitor operations, audits, and live election health.';

  @override
  String get statRegistered => 'Registered';

  @override
  String get statVoted => 'Voted';

  @override
  String get statActiveElections => 'Active elections';

  @override
  String get statSuspiciousFlags => 'Suspicious flags';

  @override
  String get adminActionElections => 'Elections';

  @override
  String get adminActionVoters => 'Voters';

  @override
  String get adminObserverAccessTitle => 'Observer Access';

  @override
  String get adminActionAuditLogs => 'Audit Logs';

  @override
  String get adminObserverManagementTitle => 'Observer access';

  @override
  String get adminObserverManagementSubtitle =>
      'Grant or revoke read-only observer access.';

  @override
  String get adminObserverSearchHint =>
      'Search observers by name, email, or UID...';

  @override
  String get adminObserverAssignTitle => 'Grant observer access';

  @override
  String get adminObserverAssignSubtitle =>
      'Enter a user email or UID. The user must have signed in at least once.';

  @override
  String get adminObserverIdentifierLabel => 'User email or UID';

  @override
  String get adminObserverGrantAction => 'Grant access';

  @override
  String get adminObserverRevokeAction => 'Revoke access';

  @override
  String get adminObserverCreateTitle => 'Create observer account';

  @override
  String get adminObserverCreateSubtitle =>
      'Provision observer credentials directly. The observer must change this temporary password at first sign-in.';

  @override
  String get adminObserverUsernameLabel => 'Username (optional)';

  @override
  String get adminObserverTempPasswordHelp =>
      'Use a temporary password (minimum 8 characters).';

  @override
  String get adminObserverCreateSuccess => 'Observer account created.';

  @override
  String get adminObserverDeleteAction => 'Delete observer';

  @override
  String get adminObserverDeleteConfirm =>
      'Delete this observer account access? The profile will be archived and observer role removed.';

  @override
  String get adminObserverDeleteSuccess => 'Observer account archived.';

  @override
  String get adminObserverMustChangePasswordTag => 'Password reset required';

  @override
  String get adminObserverEmpty => 'No observers yet.';

  @override
  String adminObserverRoleLabel(Object role) {
    return 'Role: $role';
  }

  @override
  String adminObserverUpdatedLabel(Object date) {
    return 'Updated $date';
  }

  @override
  String get adminObserverGrantSuccess => 'Observer access granted.';

  @override
  String get adminObserverRevokeSuccess => 'Observer access revoked.';

  @override
  String get adminObserverInvalidIdentifier => 'Please enter an email or UID.';

  @override
  String get liveResultsPreview => 'Live Results Preview';

  @override
  String get adminPreviewLabel => 'Admin preview';

  @override
  String get observerPreviewLabel => 'Observer view';

  @override
  String get noElectionDataAvailable => 'No election data available.';

  @override
  String get fraudIntelligenceTitle => 'Fraud intelligence';

  @override
  String get fraudAiStatus => 'AI ACTIVE';

  @override
  String fraudSignalsFlagged(Object count) {
    return 'Suspicious signals flagged: $count';
  }

  @override
  String fraudAnomalyRate(Object rate) {
    return 'Estimated anomaly rate: $rate%';
  }

  @override
  String get fraudInsightBody =>
      'Signals combine device anomalies, biometric duplicates, and behavioral mismatches. Review flagged voters in Voters.';

  @override
  String fraudFlagsRateLabel(Object flags, Object rate) {
    return 'Flags: $flags - Rate: $rate%';
  }

  @override
  String get observerDashboardHeaderSubtitle =>
      'Read-only oversight with transparent election data.';

  @override
  String get observerReadOnlyTitle => 'Read-only access';

  @override
  String observerTotalsLabel(Object registered, Object voted, Object flags) {
    return 'Registered: $registered - Voted: $voted - Flags: $flags';
  }

  @override
  String get observerOpenAuditLogs => 'Open Audit Logs';

  @override
  String get observerReportIncidentTitle => 'Report an incident';

  @override
  String get observerReportIncidentSubtitle =>
      'Submit evidence, photos, and a full incident report.';

  @override
  String get incidentTitleLabel => 'Incident title';

  @override
  String get incidentCategoryLabel => 'Category';

  @override
  String get incidentSeverityLabel => 'Severity';

  @override
  String get incidentLocationLabel => 'Location';

  @override
  String get incidentDescriptionLabel => 'Description';

  @override
  String get incidentElectionIdLabel => 'Election ID (optional)';

  @override
  String get incidentDateTimeLabel => 'Incident date & time';

  @override
  String get incidentEvidenceTitle => 'Evidence attachments';

  @override
  String get incidentAddCamera => 'Camera';

  @override
  String get incidentAddGallery => 'Gallery';

  @override
  String get incidentEvidenceEmpty => 'No evidence added yet.';

  @override
  String get incidentSubmitAction => 'Submit incident report';

  @override
  String get incidentSubmissionFailed => 'Incident submission failed.';

  @override
  String incidentSubmittedBody(Object id) {
    return 'Incident report submitted. Reference: $id';
  }

  @override
  String get incidentCategoryFraud => 'Fraud';

  @override
  String get incidentCategoryIntimidation => 'Intimidation';

  @override
  String get incidentCategoryViolence => 'Violence';

  @override
  String get incidentCategoryLogistics => 'Logistics';

  @override
  String get incidentCategoryTechnical => 'Technical';

  @override
  String get incidentCategoryAccessibility => 'Accessibility';

  @override
  String get incidentCategoryOther => 'Other';

  @override
  String get incidentSeverityLow => 'Low';

  @override
  String get incidentSeverityMedium => 'Medium';

  @override
  String get incidentSeverityHigh => 'High';

  @override
  String get incidentSeverityCritical => 'Critical';

  @override
  String get changeAction => 'Change';

  @override
  String get adminElectionManagementTitle => 'Election Management';

  @override
  String get adminElectionManagementSubtitle =>
      'Create, schedule, and oversee elections.';

  @override
  String get adminCreateElection => 'Create election';

  @override
  String get noElectionsYet => 'No elections yet.';

  @override
  String get electionStatusLive => 'Live';

  @override
  String votesCountLabel(Object count) {
    return 'Votes: $count';
  }

  @override
  String get addCandidate => 'Add Candidate';

  @override
  String get electionTitleLabel => 'Election title';

  @override
  String get electionTypeLabel => 'Election type';

  @override
  String electionStartLabel(Object date) {
    return 'Start: $date';
  }

  @override
  String electionEndLabel(Object date) {
    return 'End: $date';
  }

  @override
  String electionStartTimeLabel(Object time) {
    return 'Start time: $time';
  }

  @override
  String electionEndTimeLabel(Object time) {
    return 'End time: $time';
  }

  @override
  String get electionDescriptionLabel => 'Election description';

  @override
  String get electionScopeFieldLabel => 'Scope';

  @override
  String get electionScopeNational => 'National';

  @override
  String get electionScopeRegional => 'Regional';

  @override
  String get electionScopeMunicipal => 'Municipal';

  @override
  String get electionScopeDiaspora => 'Diaspora';

  @override
  String get electionScopeLocal => 'Local';

  @override
  String get electionLocationLabel => 'Location / constituency';

  @override
  String get registrationDeadlineTitle => 'Registration deadline';

  @override
  String registrationDeadlineLabel(Object date) {
    return 'Registration deadline: $date';
  }

  @override
  String get addRegistrationDeadline => 'Add registration deadline';

  @override
  String get campaignStartTitle => 'Campaign start';

  @override
  String campaignStartLabel(Object date) {
    return 'Campaign starts: $date';
  }

  @override
  String get addCampaignStart => 'Add campaign start';

  @override
  String get campaignEndTitle => 'Campaign end';

  @override
  String campaignEndLabel(Object date) {
    return 'Campaign ends: $date';
  }

  @override
  String get addCampaignEnd => 'Add campaign end';

  @override
  String get resultsPublishTitle => 'Results publication';

  @override
  String resultsPublishLabel(Object date) {
    return 'Results publication: $date';
  }

  @override
  String get addResultsPublish => 'Add results publication';

  @override
  String get runoffOpenTitle => 'Runoff opening';

  @override
  String runoffOpenLabel(Object date) {
    return 'Runoff opens: $date';
  }

  @override
  String get addRunoffOpen => 'Add runoff opening';

  @override
  String get runoffCloseTitle => 'Runoff closing';

  @override
  String runoffCloseLabel(Object date) {
    return 'Runoff closes: $date';
  }

  @override
  String get addRunoffClose => 'Add runoff closing';

  @override
  String get clearDeadline => 'Clear deadline';

  @override
  String get electionBallotTypeLabel => 'Ballot type';

  @override
  String get electionBallotTypeSingle => 'Single choice';

  @override
  String get electionBallotTypeRanked => 'Ranked choice';

  @override
  String get electionBallotTypeApproval => 'Approval voting';

  @override
  String get electionBallotTypeRunoff => 'Runoff';

  @override
  String get electionEligibilityLabel => 'Eligibility notes';

  @override
  String get electionTimezoneLabel => 'Timezone';

  @override
  String get createAction => 'Create';

  @override
  String get editAction => 'Edit';

  @override
  String get partyNameLabel => 'Party name';

  @override
  String get partyAcronymLabel => 'Party acronym';

  @override
  String get candidateSloganLabel => 'Candidate slogan';

  @override
  String get candidateBioLabel => 'Candidate bio';

  @override
  String get candidateWebsiteLabel => 'Campaign website';

  @override
  String get candidateAvatarUrlLabel => 'Avatar photo URL';

  @override
  String get candidateRunningMateLabel => 'Running mate';

  @override
  String get candidateColorLabel => 'Party color';

  @override
  String get addAction => 'Add';

  @override
  String get approveAction => 'Approve';

  @override
  String get rejectAction => 'Reject';

  @override
  String get electionTypeParliamentary => 'Parliamentary Election';

  @override
  String get electionTypeReferendum => 'Referendum';

  @override
  String get auditLogsTitle => 'Audit Logs';

  @override
  String get auditLogsSubtitle => 'Immutable trails for every action.';

  @override
  String get auditFilterAll => 'All';

  @override
  String get auditShowingAll => 'Showing all events';

  @override
  String auditFilterLabel(Object filter) {
    return 'Filter: $filter';
  }

  @override
  String get noAuditEvents => 'No audit events.';

  @override
  String get auditEventElectionCreated => 'Election created';

  @override
  String get auditEventCandidateAdded => 'Candidate added';

  @override
  String get auditEventResultsPublished => 'Results published';

  @override
  String get auditEventListCleaned => 'List cleaned';

  @override
  String get auditEventRegistrationApproved => 'Registration approved';

  @override
  String get auditEventRegistrationRejected => 'Registration rejected';

  @override
  String get auditEventSuspiciousActivity => 'Suspicious activity';

  @override
  String get auditEventDeviceBanned => 'Device banned';

  @override
  String get auditEventVoteCast => 'Vote cast';

  @override
  String get auditEventRoleChanged => 'Role changed';

  @override
  String get legalHubTitle => 'Electoral laws & codes';

  @override
  String get legalHubSubtitle => 'Official legal texts and civic references.';

  @override
  String get legalSourcesTitle => 'Official sources';

  @override
  String get legalSourcesSubtitle =>
      'Verified sources for Cameroon electoral law.';

  @override
  String get legalSourceElecamLabel => 'ELECAM portal';

  @override
  String get legalSourceAssnatLabel => 'National Assembly portal';

  @override
  String get legalElectoralCodeTitle => 'Electoral Code of Cameroon';

  @override
  String legalDocumentSubtitle(Object language) {
    return 'Key highlights ($language)';
  }

  @override
  String get legalSearchHint => 'Search within the document';

  @override
  String get legalSearchEmpty => 'No matches found. Try a different keyword.';

  @override
  String legalSearchResults(Object count) {
    return '$count result(s)';
  }

  @override
  String get openWebsite => 'Open';

  @override
  String get openLinkFailed => 'Unable to open the link.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get missingDocumentData => 'Missing legal document data.';

  @override
  String get adminToolsTitle => 'Admin tools';

  @override
  String get adminContentSeedTitle => 'Content studio';

  @override
  String get adminContentSeedSubtitle =>
      'Seed civic data, election info, and reference centers.';

  @override
  String get adminContentSeedOverwrite => 'Overwrite existing entries';

  @override
  String get adminContentSeedIncludeCenters =>
      'Seed regional centers (capitals)';

  @override
  String get adminContentSeedAction => 'Seed Cameroon content';

  @override
  String get adminContentSeedRunning => 'Seeding content...';

  @override
  String get adminContentSeedReportTitle => 'Seed report';

  @override
  String get adminContentSeedCivicLessons => 'Civic lessons';

  @override
  String get adminContentSeedElectionCalendar => 'Election calendar';

  @override
  String get adminContentSeedTransparency => 'Transparency updates';

  @override
  String get adminContentSeedChecklist => 'Observation checklist';

  @override
  String get adminContentSeedLegalDocs => 'Legal documents';

  @override
  String get adminContentSeedElectionsInfo => 'Elections info';

  @override
  String get adminContentSeedCenters => 'Voting centers';

  @override
  String get adminContentSeedSuccess => 'Content seeded in Firestore.';

  @override
  String get adminContentManageTitle => 'Content manager';

  @override
  String get adminContentManageSubtitle =>
      'Create, update, or delete records for civic lessons, calendar, legal texts, transparency, checklist, and public content.';

  @override
  String get adminContentManageSaved => 'Content saved.';

  @override
  String get adminContentManageEmpty =>
      'No content items in this collection yet.';

  @override
  String get adminContentManageIdLabel => 'Record ID';

  @override
  String get adminContentManageJsonLabel => 'JSON payload';

  @override
  String get adminContentManageDeleteConfirm =>
      'Delete this content item? This action cannot be undone.';

  @override
  String get adminContentManageDeleted => 'Content deleted.';

  @override
  String get adminFraudMonitorTitle => 'Fraud monitor';

  @override
  String get adminFraudMonitorSubtitle =>
      'AI risk signals, anomaly trends, and device flags.';

  @override
  String get fraudSignalsTitle => 'Active fraud signals';

  @override
  String get fraudSignalDeviceAnomaly => 'Device anomaly';

  @override
  String get fraudSignalBiometricDuplicate => 'Biometric duplicate';

  @override
  String get fraudSignalUnverified => 'Unverified';

  @override
  String get fraudSignalAgeAnomaly => 'Age anomaly';

  @override
  String get fraudSignalStatusRisk => 'Status risk';

  @override
  String get fraudSignalVoteStateMismatch => 'Vote state mismatch';

  @override
  String fraudSignalCount(Object count) {
    return '$count signals';
  }

  @override
  String get fraudRiskScoreTitle => 'Risk score';

  @override
  String fraudRiskScoreValue(Object score) {
    return '$score% risk';
  }

  @override
  String get fraudSignalTotal => 'Signals';

  @override
  String get fraudDevicesFlagged => 'Devices flagged';

  @override
  String get fraudAccountsAtRisk => 'Accounts at risk';

  @override
  String get adminSecurityTitle => 'Device security';

  @override
  String get adminSecuritySubtitle =>
      'Device risk status, strikes, and integrity alerts.';

  @override
  String securityStrikesLabel(Object count) {
    return '$count strikes';
  }

  @override
  String get adminIncidentsTitle => 'Incident oversight';

  @override
  String get adminIncidentsSubtitle =>
      'Monitor and resolve field incidents and reports.';

  @override
  String incidentSubtitle(Object severity, Object location) {
    return '$severity - $location';
  }

  @override
  String get filterLabel => 'Filter';

  @override
  String get filterAll => 'All';

  @override
  String get incidentStatusOpen => 'Open';

  @override
  String get incidentStatusInvestigating => 'Investigating';

  @override
  String get incidentStatusResolved => 'Resolved';

  @override
  String get adminResultsPublishTitle => 'Publish results';

  @override
  String get adminResultsPublishSubtitle =>
      'Finalize and publish verified results.';

  @override
  String get adminVotingCentersTitle => 'Voting centers';

  @override
  String adminVotingCentersSubtitle(Object count) {
    return '$count centers in the directory.';
  }

  @override
  String get adminVotingCentersImportCsv => 'Import CSV';

  @override
  String get adminVotingCentersImportHint =>
      'Paste CSV with columns: name,address,city,region_code,region_name,country,country_code,type,latitude,longitude,status,contact,notes';

  @override
  String adminVotingCentersImportDone(Object count) {
    return 'Imported $count centers.';
  }

  @override
  String get adminVotingCentersEditTitle => 'Edit voting center';

  @override
  String get adminVotingCentersCreateTitle => 'Create voting center';

  @override
  String get adminVotingCentersDeleteConfirm =>
      'Delete this voting center? This cannot be undone.';

  @override
  String get centerNameLabel => 'Center name';

  @override
  String get centerAddressLabel => 'Address';

  @override
  String get centerCityLabel => 'City';

  @override
  String get centerRegionCodeLabel => 'Region code';

  @override
  String get centerRegionNameLabel => 'Region name';

  @override
  String get centerCountryLabel => 'Country';

  @override
  String get centerCountryCodeLabel => 'Country code';

  @override
  String get centerLatitudeLabel => 'Latitude';

  @override
  String get centerLongitudeLabel => 'Longitude';

  @override
  String get centerTypeLabel => 'Center type';

  @override
  String get centerTypeDomestic => 'Domestic';

  @override
  String get centerTypeEmbassy => 'Embassy';

  @override
  String get centerTypeConsulate => 'Consulate';

  @override
  String get centerTypeDiaspora => 'Diaspora';

  @override
  String get centerTypeOther => 'Other';

  @override
  String get centerStatusLabel => 'Status';

  @override
  String get centerStatusActive => 'Active';

  @override
  String get centerStatusInactive => 'Inactive';

  @override
  String get centerStatusPending => 'Pending';

  @override
  String get centerContactLabel => 'Contact';

  @override
  String get centerNotesLabel => 'Notes';

  @override
  String resultsPublishSummary(Object votes, Object precincts) {
    return '$votes votes - $precincts precincts reporting';
  }

  @override
  String get publishResultsAction => 'Publish';

  @override
  String get resultsPublishNotReady => 'Not ready';

  @override
  String get resultsPublishedToast => 'Results published.';

  @override
  String get observerToolsTitle => 'Observer tools';

  @override
  String get observerResultsToolSubtitle =>
      'Read-only live results and trends.';

  @override
  String get observerIncidentTrackerTitle => 'Incident tracker';

  @override
  String get observerIncidentTrackerSubtitle =>
      'Track your reported incidents in real time.';

  @override
  String get observerTransparencyTitle => 'Transparency feed';

  @override
  String get observerTransparencySubtitle =>
      'Official updates and public accountability notes.';

  @override
  String get observerChecklistTitle => 'Observation checklist';

  @override
  String get observerChecklistSubtitle =>
      'Verify compliance points and log observations.';

  @override
  String get publicElectionCalendarTitle => 'Election calendar';

  @override
  String get publicElectionCalendarSubtitle =>
      'Upcoming election dates and milestones.';

  @override
  String get publicCivicEducationTitle => 'Civic education';

  @override
  String get publicCivicEducationSubtitle =>
      'Learn voting rights, duties, and procedures.';

  @override
  String calendarEntrySubtitle(
    Object scope,
    Object location,
    Object start,
    Object end,
  ) {
    return '$scope - $location\n$start -> $end';
  }

  @override
  String get accountArchivedTitle => 'Account archived';

  @override
  String get accountArchivedSubtitle => 'Your account is inactive';

  @override
  String get accountArchivedBody =>
      'Your account was archived at your request or by an administrator. To restore access, please contact support or sign in to verify your identity.';

  @override
  String get accountArchivedLoginAction => 'Go to login';

  @override
  String get accountArchivedPublicAction => 'Continue as public';

  @override
  String get accountArchivedMessage =>
      'This account is archived. Please sign in to verify or contact support.';

  @override
  String get readMoreAction => 'Read more';

  @override
  String get countdownsTitle => 'Countdowns';

  @override
  String get countdownsSubtitle =>
      'Track election moments and personal eligibility timers.';

  @override
  String get countdownElectionsSectionTitle => 'Election countdowns';

  @override
  String get countdownElectionOpensTitle => 'Opens in';

  @override
  String get countdownElectionClosesTitle => 'Closes in';

  @override
  String get countdownCardExpiryTitle => 'e-Electoral card expiry';

  @override
  String countdownCardExpiryBody(Object date) {
    return 'Your card expires on $date.';
  }

  @override
  String get countdownCardExpiryWarning =>
      'Renew before expiry to keep your voting status active.';

  @override
  String get countdownRenewCardAction => 'Renew card';

  @override
  String get countdownEligibilityTitle => 'Eligibility unlock';

  @override
  String countdownEligibilityBody(Object date) {
    return 'You become eligible to vote on $date.';
  }

  @override
  String get countdownEligibilityCelebrate => 'You\'re now eligible to vote!';

  @override
  String get countdownSuspensionTitle => 'Suspension ends';

  @override
  String countdownSuspensionBody(Object date) {
    return 'Suspension lifts on $date.';
  }

  @override
  String get countdownNoTimersTitle => 'No active countdowns';

  @override
  String get countdownNoTimersBody =>
      'Your next timers will appear here as soon as data is available.';

  @override
  String get countdownExpiredLabel => 'Expired';

  @override
  String get countdownTodayLabel => 'Today';

  @override
  String get countdownViewAllAction => 'View all countdowns';

  @override
  String get voterCountdowns => 'Countdowns';

  @override
  String get voterCountdownsSubtitle =>
      'Track election timers and eligibility updates.';

  @override
  String get countdownPersonalSectionTitle => 'Personal countdowns';

  @override
  String get countdownRegistrationDeadlineTitle => 'Registration closes in';

  @override
  String get countdownCampaignStartsTitle => 'Campaign starts in';

  @override
  String get countdownCampaignEndsTitle => 'Campaign ends in';

  @override
  String get countdownResultsPublishTitle => 'Results publication in';

  @override
  String get countdownRunoffOpensTitle => 'Runoff opens in';

  @override
  String get countdownRunoffClosesTitle => 'Runoff closes in';

  @override
  String get webDownloadAppTitle => 'Get the CAMVOTE mobile app';

  @override
  String get webDownloadAppSubtitle =>
      'Register, vote, and receive updates faster on your phone.';

  @override
  String get webDownloadPlayStore => 'Get it on Google Play';

  @override
  String get webDownloadAppStore => 'Download on the App Store';

  @override
  String get webDownloadQrTitle => 'Scan to download';

  @override
  String get webDownloadLearnMore => 'Learn more about mobile features';

  @override
  String get supportCamVoteTitle => 'Support CamVote';

  @override
  String get supportCamVoteSubtitle =>
      'Send a tip via TapTap Send, Remitly, or Orange Money Max It';

  @override
  String get supportCamVoteContributeSubtitle =>
      'Contribute via TapTap Send, Remitly, or Orange Money Max It';

  @override
  String get supportCamVoteHeaderTitle => 'Support CamVote project';

  @override
  String get supportCamVoteHeaderSubtitle =>
      'Send a tip via TapTap Send, Remitly, or Orange Money Max It. Tipping is open to everyone and keeps your details private.';

  @override
  String get supportCamVoteImpactTitle => 'How your support is used';

  @override
  String get supportCamVoteImpactIntro =>
      'Your contribution helps us keep CamVote secure, fast, and available for more citizens.';

  @override
  String get supportCamVoteImpactSecurity =>
      'Security hardening for biometric, liveness, and anti-fraud systems.';

  @override
  String get supportCamVoteImpactReliability =>
      'Better reliability, server uptime, and faster releases across web, Android, and iOS.';

  @override
  String get supportCamVoteImpactCommunity =>
      'Civic education improvements and wider access for voters and observers.';

  @override
  String get supportCamVoteImpactTransparency =>
      'Transparent operations with auditable updates and measurable public impact.';

  @override
  String get helpSupportLiveHelpDesk => 'Live Help Desk';

  @override
  String get helpSupportLiveHelpDeskHint =>
      'Your message will be sent to the Help Desk admin and you will receive updates in notifications.';

  @override
  String get helpSupportChatWhatsApp => 'Chat on WhatsApp';

  @override
  String get helpSupportWhatsAppGreeting =>
      'Hello CamVote, I am contacting support via WhatsApp.';

  @override
  String get helpSupportWhatsAppOpenFailed =>
      'Unable to open WhatsApp right now.';

  @override
  String get helpSupportFaqObserverHowTo =>
      'How to become an observer: contact the admin with an official mandate and documents proving observer status (state, party, civil society, NGO, or international body), with recognition by the State of Cameroon. In observer mode, you cannot vote.';

  @override
  String get tipChoosePaymentChannel => 'Choose your payment channel';

  @override
  String get tipChannelElyonpay => 'TapTap Send';

  @override
  String get tipChannelRemitly => 'Remitly';

  @override
  String get tipChannelMaxItQr => 'Orange Money Max It';

  @override
  String get tipAnonymousTitle => 'Anonymous tip';

  @override
  String get tipAnonymousSubtitle =>
      'Your name is hidden. A thank-you message is still delivered.';

  @override
  String get tipNameHiddenLabel => 'Name (hidden)';

  @override
  String get tipAmountLabel => 'Amount';

  @override
  String get tipAmountInvalid => 'Enter a valid amount.';

  @override
  String get tipCurrencyLabel => 'Currency';

  @override
  String get tipPersonalMessageLabel => 'Personal message';

  @override
  String get tipPayWithElyonpay => 'Open TapTap Send';

  @override
  String get tipPayWithRemitly => 'Open Remitly';

  @override
  String get tipTapTapSendInstructionsTitle => 'TapTap Send transfer';

  @override
  String get tipTapTapSendInstructionsBody =>
      'Open TapTap Send, complete your transfer, then submit the reference so our team can confirm your tip.';

  @override
  String get tipRemitlyInstructionsTitle => 'Remitly transfer';

  @override
  String get tipRemitlyInstructionsBody =>
      'Open Remitly, sign in if prompted, complete your transfer, then submit the reference so our team can confirm your tip.';

  @override
  String get tipReferenceHint => 'Transfer reference or transaction ID';

  @override
  String get tipProofNoteLabel => 'Note for the admin (optional)';

  @override
  String get tipSubmitProof => 'Submit payment reference';

  @override
  String get tipSubmittedBody => 'Reference received. We will confirm shortly.';

  @override
  String get tipPaymentSubmitted => 'Reference submitted';

  @override
  String get tipReferenceMissing => 'Enter the payment reference first.';

  @override
  String get tipReceiptOptionalTitle => 'Receipt screenshots (optional)';

  @override
  String get tipReceiptOptionalBody =>
      'You can submit without screenshots. If you have a receipt, upload it to help us confirm faster.';

  @override
  String get tipReceiptUploadAction => 'Upload receipt';

  @override
  String get tipReceiptLabel => 'Receipt';

  @override
  String tipReceiptUploadedCount(Object count) {
    return '$count receipt(s) uploaded';
  }

  @override
  String get tipGenerateMaxItQr => 'Show Max It QR';

  @override
  String get tipMsisdnLabel => 'Mobile money number';

  @override
  String get tipMsisdnHint => 'e.g. +2376XXXXXXXX';

  @override
  String get tipMsisdnInvalid => 'Enter a valid phone number.';

  @override
  String get tipScanMaxItQr => 'Open Max It and scan this QR to tip';

  @override
  String get tipPaymentTrackingTitle => 'Payment tracking';

  @override
  String get tipReferenceLabel => 'Reference';

  @override
  String get tipCheckStatus => 'Check status';

  @override
  String get tipWaitingConfirmation => 'Waiting for payment confirmation.';

  @override
  String get tipCheckingPayment => 'Checking payment...';

  @override
  String get tipPreparingSecurePaymentTitle => 'Preparing secure payment';

  @override
  String get tipPreparingSecurePaymentSubtitle =>
      'Please wait while CamVote configures your tip flow.';

  @override
  String get tipAnonymousSupporterName => 'Anonymous supporter';

  @override
  String get tipSupporterFallbackName => 'Supporter';

  @override
  String get tipNotificationReceivedTitle => 'Tip received';

  @override
  String tipNotificationReceivedBody(Object name) {
    return 'Thank you $name! Your contribution was received.';
  }

  @override
  String tipNotificationReceivedBodyAmount(
    Object name,
    Object amount,
    Object currency,
  ) {
    return 'Thank you $name! We received your tip of $amount $currency.';
  }

  @override
  String tipThankYouTitle(Object name) {
    return 'Thank you $name!';
  }

  @override
  String get tipThankYouBody =>
      'Your support keeps CamVote growing and improving for everyone.';

  @override
  String tipThankYouBodyAmount(Object name, Object amount, Object currency) {
    return 'Thank you $name. Your tip of $amount $currency has been received successfully. Your support helps CamVote grow with transparency and impact.';
  }

  @override
  String get tipSelectedChannel => 'Selected channel';

  @override
  String tipProviderLabel(Object provider) {
    return 'Provider: $provider';
  }

  @override
  String tipIdLabel(Object tipId) {
    return 'Tip ID: $tipId';
  }

  @override
  String get tipAnonymousModeEnabled => 'Anonymous mode enabled';

  @override
  String get tipDestinationOrangeMoneyCameroon =>
      'Orange Money Cameroon destination';

  @override
  String get tipRecipientNameNotConfigured => 'Recipient name not configured';

  @override
  String tipRecipientNameLabel(Object name) {
    return 'Recipient name: $name';
  }

  @override
  String tipRecipientNumberLabel(Object number) {
    return 'Recipient number: $number';
  }

  @override
  String get tipVerifyRecipientNameHint =>
      'Verify this recipient name inside checkout. If the name does not match, cancel.';

  @override
  String get tipPhoneHiddenHint =>
      'Phone number hidden for security: use TapTap Send, Remitly, or the Max It QR flow.';

  @override
  String get tipOpenPayment => 'Open payment';

  @override
  String get tipOpenMaxIt => 'Open Max It';

  @override
  String get tipPaymentConfirmed => 'Payment confirmed';

  @override
  String get tipPaymentAwaitingConfirmation => 'Awaiting confirmation';

  @override
  String tipStatusSummary(Object amount, Object currency, Object provider) {
    return '$amount $currency - $provider';
  }

  @override
  String get adminSupportTitle => 'Admin Support';

  @override
  String get adminSupportSubtitle =>
      'Review support tickets, respond to users, and track ticket status.';

  @override
  String get adminSupportSearchHint =>
      'Search by name, email, registration ID, or message';

  @override
  String get adminSupportAllStatuses => 'All statuses';

  @override
  String get adminSupportNoTickets => 'No support tickets found.';

  @override
  String get adminSupportTicketUpdatedSuccess => 'Ticket updated successfully.';

  @override
  String adminSupportRespondToTicket(Object ticketId) {
    return 'Respond to ticket $ticketId';
  }

  @override
  String get adminSupportNewStatusLabel => 'New status';

  @override
  String get adminSupportResponseMessageLabel => 'Response message';

  @override
  String get adminSupportSendResponse => 'Send response';

  @override
  String adminSupportRegistrationIdValue(Object registrationId) {
    return 'Registration ID: $registrationId';
  }

  @override
  String adminSupportUpdatedAt(Object date, Object time) {
    return 'Updated $date $time';
  }

  @override
  String get adminSupportRespondAction => 'Respond';

  @override
  String get adminSupportUpdateAction => 'Update';

  @override
  String get adminSupportStatusOpen => 'Open';

  @override
  String get adminSupportStatusAnswered => 'Answered';

  @override
  String get adminSupportStatusResolved => 'Resolved';

  @override
  String get adminSupportStatusClosed => 'Closed';

  @override
  String get adminSupportStatusUnknown => 'Unknown';

  @override
  String get voteImpactAddedLive => 'Your vote was secured and added live.';

  @override
  String get voteImpactRecorded => 'Your vote was recorded successfully.';

  @override
  String get voteImpactPreviousTotal => 'Previous total';

  @override
  String get voteImpactYourContribution => 'Your contribution';

  @override
  String get voteImpactNewLiveTotal => 'New live total';

  @override
  String get adminDemographicsTitle => 'Registered voter age distribution';

  @override
  String adminDemographicsTotalEligible(Object total) {
    return 'Total eligible voters on list: $total';
  }

  @override
  String get adminDemographicsYouth => 'Youth';

  @override
  String get adminDemographicsAdult => 'Adult';

  @override
  String get adminDemographicsSenior => 'Senior';
}
