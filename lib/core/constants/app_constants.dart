/// Application-wide constants for CamVote
/// Based on Cameroon Electoral Code (Law No. 2012/001 and amendments)
class AppConstants {
  // App Info
  static const String appName = 'CamVote';
  static const String appSlogan = 'Your Voice. Verified. Counted.';
  static const String appVersion = '1.0.0';
  
  // Legal Age Requirements (Cameroon Electoral Code)
  // Law No. 2012/001: Article 9 - Voting age is 20 years
  static const int minimumRegistrationAge = 18; // Can register at 18
  static const int minimumVotingAge = 20; // Can only vote at 20
  static const int minimumPresidentialCandidateAge = 35;
  static const int minimumLegislativeCandidateAge = 23;
  static const int minimumMunicipalCandidateAge = 25;
  
  // Biometric Settings
  static const int maxBiometricAttempts = 3;
  static const int biometricTimeout = 30; // seconds
  
  // Voting Rules
  static const int maxVotesPerElection = 1;
  static const int voteConfirmationTimeout = 60; // seconds
  
  // Election Types (Based on Cameroon Constitution)
  static const List<String> electionTypes = [
    'Presidential', // Every 7 years
    'Legislative', // Every 5 years (National Assembly)
    'Municipal', // Every 5 years (City Councils)
    'Senatorial', // Every 5 years (Senate)
    'Regional Council', // Regional representatives
  ];
  
  // Document Types (Accepted by ELECAM)
  static const List<String> acceptedDocuments = [
    'National ID Card (CNI)', // Carte Nationale d\'Identité
    'Passport',
    'Birth Certificate',
    'ID Receipt', // Temporary document
  ];
  
  // Cameroon Regions (10 regions)
  static const List<String> cameroonRegions = [
    'Adamawa',
    'Centre',
    'East',
    'Far North',
    'Littoral',
    'North',
    'Northwest',
    'South',
    'Southwest',
    'West',
  ];
  
  // API Endpoints (Mock for now - will be replaced with real backend)
  static const String baseApiUrl = 'http://localhost:8000/api/v1';
  static const String voterRegistrationEndpoint = '/voters/register';
  static const String electionListEndpoint = '/elections';
  static const String voteSubmissionEndpoint = '/votes/submit';
  static const String resultsEndpoint = '/results';
  static const String auditLogEndpoint = '/audit';
  
  // Storage Keys
  static const String keyUserToken = 'user_token';
  static const String keyVoterId = 'voter_id';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyLanguage = 'language';
  static const String keyElectoralCard = 'electoral_card';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int cniLength = 9; // Cameroon National ID length
  static const String phoneRegex = r'^(6|2)\d{8}$'; // Cameroon phone format
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  // Electoral List Cleaning (Law requirement)
  static const int listCleaningIntervalMonths = 12; // Annual cleaning
  static const int deathNotificationDays = 30; // Must report within 30 days
}