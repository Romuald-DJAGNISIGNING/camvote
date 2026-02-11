class RoutePaths {
  static const gateway = '/';
  static const webPortal = '/portal';
  static const adminPortal = '/backoffice';
  static const onboarding = '/onboarding';

  // Auth
  static const authLogin = '/auth/login';
  static const authForgot = '/auth/forgot';
  static const authArchived = '/auth/archived';
  static const authForcePasswordChange = '/auth/force-password-change';

  // Public
  static const publicHome = '/public';
  static const publicResults = '/public/results';
  static const publicElectionsInfo = '/public/elections-info';
  static const publicVerifyRegistration = '/public/verify-registration';
  static const publicVotingCenters = '/public/voting-centers';
  static const publicElectionCalendar = '/public/calendar';
  static const publicCivicEducation = '/public/civic-education';
  static const legalLibrary = '/legal';
  static const legalDocument = '/legal/document';

  // Registration
  static const register = '/register';
  static const registerVoter = '/register/voter';
  static const voterDocumentOcr = '/register/voter/document-ocr';
  static const voterBiometricEnrollment = '/register/voter/biometrics';
  static const voterRegistrationReview = '/register/voter/review';
  static const voterRegistrationSubmitted = '/register/voter/submitted';

  // Voter / Observer / Admin
  static const voterShell = '/voter';
  static const voterWebRedirect = '/voter/mobile';
  static const voterPending = '/voter/pending';
  static const voterCard = '/voter/card';
  static const voterReceipt = '/voter/receipt';
  static const voterCountdowns = '/voter/countdowns';

  static const observerDashboard = '/observer';
  static const observerAudit = '/observer/audit';
  static const observerIncidentReport = '/observer/incidents/report';
  static const observerIncidentTracker = '/observer/incidents';
  static const observerTransparency = '/observer/transparency';
  static const observerChecklist = '/observer/checklist';

  static const adminDashboard = '/admin';
  static const adminRoleHub = '/admin/roles';
  static const adminElections = '/admin/elections';
  static const adminVoters = '/admin/voters';
  static const adminObservers = '/admin/observers';
  static const adminAudit = '/admin/audit';
  static const adminFraudMonitor = '/admin/fraud';
  static const adminSecurity = '/admin/security';
  static const adminIncidents = '/admin/incidents';
  static const adminResultsPublish = '/admin/results';
  static const adminVotingCenters = '/admin/voting-centers';
  static const adminContentSeed = '/admin/content-seed';
  static const adminSupport = '/admin/support';

  // Common
  static const settings = '/settings';
  static const accountDelete = '/settings/delete-account';
  static const about = '/about';
  static const notifications = '/notifications';
  static const helpSupport = '/support';
}
