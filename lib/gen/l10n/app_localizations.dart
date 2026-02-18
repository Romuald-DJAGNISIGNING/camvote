import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'CamVote'**
  String get appName;

  /// No description provided for @slogan.
  ///
  /// In en, this message translates to:
  /// **'Your Vote. Your Voice. Your Future.'**
  String get slogan;

  /// No description provided for @cameroonName.
  ///
  /// In en, this message translates to:
  /// **'Republic of Cameroon'**
  String get cameroonName;

  /// No description provided for @chooseModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to use CamVote'**
  String get chooseModeTitle;

  /// No description provided for @modePublicTitle.
  ///
  /// In en, this message translates to:
  /// **'Public Access'**
  String get modePublicTitle;

  /// No description provided for @modePublicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View results, election info, and verify registration without logging in.'**
  String get modePublicSubtitle;

  /// No description provided for @modeVoterTitle.
  ///
  /// In en, this message translates to:
  /// **'Voter'**
  String get modeVoterTitle;

  /// No description provided for @modeVoterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register, get verified, vote securely, and access your e-Electoral Card.'**
  String get modeVoterSubtitle;

  /// No description provided for @modeObserverTitle.
  ///
  /// In en, this message translates to:
  /// **'Observer'**
  String get modeObserverTitle;

  /// No description provided for @modeObserverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read-only monitoring: audit logs, fraud flags, transparency tools.'**
  String get modeObserverSubtitle;

  /// No description provided for @modeAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get modeAdminTitle;

  /// No description provided for @modeAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage elections, candidates, monitoring, cleaning, bans, and compliance.'**
  String get modeAdminSubtitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutSub.
  ///
  /// In en, this message translates to:
  /// **'Creator details, Trello progress dashboard, strengths & weaknesses.'**
  String get aboutSub;

  /// No description provided for @publicPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Public Portal'**
  String get publicPortalTitle;

  /// No description provided for @publicPortalHeadline.
  ///
  /// In en, this message translates to:
  /// **'Public information (no login required)'**
  String get publicPortalHeadline;

  /// No description provided for @publicResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results & Statistics'**
  String get publicResultsTitle;

  /// No description provided for @publicResultsSub.
  ///
  /// In en, this message translates to:
  /// **'Live trends, turnout, and final results.'**
  String get publicResultsSub;

  /// No description provided for @publicElectionsInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Election Types & Guidelines'**
  String get publicElectionsInfoTitle;

  /// No description provided for @publicElectionsInfoSub.
  ///
  /// In en, this message translates to:
  /// **'Understand election types and voter guidelines.'**
  String get publicElectionsInfoSub;

  /// No description provided for @verifyRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Registration (Privacy-safe)'**
  String get verifyRegistrationTitle;

  /// No description provided for @verifyRegistrationSub.
  ///
  /// In en, this message translates to:
  /// **'Verify status using reg number + DOB. Identity stays masked.'**
  String get verifyRegistrationSub;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @turnout.
  ///
  /// In en, this message translates to:
  /// **'Turnout'**
  String get turnout;

  /// No description provided for @totalRegistered.
  ///
  /// In en, this message translates to:
  /// **'Total registered'**
  String get totalRegistered;

  /// No description provided for @totalVotesCast.
  ///
  /// In en, this message translates to:
  /// **'Votes cast'**
  String get totalVotesCast;

  /// No description provided for @absentee.
  ///
  /// In en, this message translates to:
  /// **'Absentee'**
  String get absentee;

  /// No description provided for @candidateResults.
  ///
  /// In en, this message translates to:
  /// **'Candidate results'**
  String get candidateResults;

  /// No description provided for @electionsInfoHeadline.
  ///
  /// In en, this message translates to:
  /// **'Election types and guidelines (public)'**
  String get electionsInfoHeadline;

  /// No description provided for @guidelinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Guidelines'**
  String get guidelinesTitle;

  /// No description provided for @guidelineAgeRules.
  ///
  /// In en, this message translates to:
  /// **'Registration: 18+. Voting: 20+. Eligibility is enforced automatically.'**
  String get guidelineAgeRules;

  /// No description provided for @guidelineOnePersonOneVote.
  ///
  /// In en, this message translates to:
  /// **'One person, one vote: duplicate attempts are blocked and audited.'**
  String get guidelineOnePersonOneVote;

  /// No description provided for @guidelineSecrecy.
  ///
  /// In en, this message translates to:
  /// **'Vote secrecy: receipts never reveal the chosen candidate.'**
  String get guidelineSecrecy;

  /// No description provided for @guidelineFraudReporting.
  ///
  /// In en, this message translates to:
  /// **'Fraud reporting: suspicious patterns are flagged for observers and admins.'**
  String get guidelineFraudReporting;

  /// No description provided for @electionTypePresidential.
  ///
  /// In en, this message translates to:
  /// **'Presidential Election'**
  String get electionTypePresidential;

  /// No description provided for @electionTypePresidentialBody.
  ///
  /// In en, this message translates to:
  /// **'Election of the Head of State. Results are monitored live with audit logs and locked after closing.'**
  String get electionTypePresidentialBody;

  /// No description provided for @electionTypeLegislative.
  ///
  /// In en, this message translates to:
  /// **'Legislative Election'**
  String get electionTypeLegislative;

  /// No description provided for @electionTypeLegislativeBody.
  ///
  /// In en, this message translates to:
  /// **'Election of members of parliament. Results available by constituency/region in the dashboard.'**
  String get electionTypeLegislativeBody;

  /// No description provided for @electionTypeMunicipal.
  ///
  /// In en, this message translates to:
  /// **'Municipal Election'**
  String get electionTypeMunicipal;

  /// No description provided for @electionTypeMunicipalBody.
  ///
  /// In en, this message translates to:
  /// **'Election of municipal councilors. Results displayed at commune and regional levels.'**
  String get electionTypeMunicipalBody;

  /// No description provided for @electionTypeRegional.
  ///
  /// In en, this message translates to:
  /// **'Regional Election'**
  String get electionTypeRegional;

  /// No description provided for @electionTypeRegionalBody.
  ///
  /// In en, this message translates to:
  /// **'Regional council elections. Includes turnout and participation statistics.'**
  String get electionTypeRegionalBody;

  /// No description provided for @electionTypeSenatorial.
  ///
  /// In en, this message translates to:
  /// **'Senatorial Election'**
  String get electionTypeSenatorial;

  /// No description provided for @electionTypeSenatorialBody.
  ///
  /// In en, this message translates to:
  /// **'Senate elections. Monitoring and audit view available for authorized roles.'**
  String get electionTypeSenatorialBody;

  /// No description provided for @verifyPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Privacy note: public verification shows only masked identity information and status.'**
  String get verifyPrivacyNote;

  /// No description provided for @verifyFormRegNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration number'**
  String get verifyFormRegNumber;

  /// No description provided for @verifyFormDob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get verifyFormDob;

  /// No description provided for @verifySubmit.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifySubmit;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @authRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in required to continue.'**
  String get authRequired;

  /// No description provided for @invalidRegNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration number must be at least 4 characters'**
  String get invalidRegNumber;

  /// No description provided for @selectDob.
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get selectDob;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// No description provided for @verifyAttemptLimitBody.
  ///
  /// In en, this message translates to:
  /// **'Too many verification attempts. Please wait before trying again.'**
  String get verifyAttemptLimitBody;

  /// No description provided for @cooldown.
  ///
  /// In en, this message translates to:
  /// **'Cooldown'**
  String get cooldown;

  /// No description provided for @verifyResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification result'**
  String get verifyResultTitle;

  /// No description provided for @maskedName.
  ///
  /// In en, this message translates to:
  /// **'Masked name'**
  String get maskedName;

  /// No description provided for @maskedRegNumber.
  ///
  /// In en, this message translates to:
  /// **'Masked reg number'**
  String get maskedRegNumber;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @cardExpiry.
  ///
  /// In en, this message translates to:
  /// **'Card expiry'**
  String get cardExpiry;

  /// No description provided for @verifyStatusNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get verifyStatusNotFound;

  /// No description provided for @verifyStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending verification'**
  String get verifyStatusPending;

  /// No description provided for @verifyStatusRegisteredPreEligible.
  ///
  /// In en, this message translates to:
  /// **'Registered (18-19, not eligible to vote yet)'**
  String get verifyStatusRegisteredPreEligible;

  /// No description provided for @verifyStatusEligible.
  ///
  /// In en, this message translates to:
  /// **'Eligible to vote'**
  String get verifyStatusEligible;

  /// No description provided for @verifyStatusVoted.
  ///
  /// In en, this message translates to:
  /// **'Already voted (current election)'**
  String get verifyStatusVoted;

  /// No description provided for @verifyStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended / under review'**
  String get verifyStatusSuspended;

  /// No description provided for @verifyStatusDeceased.
  ///
  /// In en, this message translates to:
  /// **'Removed (deceased)'**
  String get verifyStatusDeceased;

  /// No description provided for @verifyStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived (retention)'**
  String get verifyStatusArchived;

  /// No description provided for @verifyEligibleToastMessage.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You can now vote in eligible elections.'**
  String get verifyEligibleToastMessage;

  /// No description provided for @voterPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Voter Portal'**
  String get voterPortalTitle;

  /// No description provided for @voterHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get voterHome;

  /// No description provided for @voterElections.
  ///
  /// In en, this message translates to:
  /// **'Elections'**
  String get voterElections;

  /// No description provided for @voterVote.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get voterVote;

  /// No description provided for @voterResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get voterResults;

  /// No description provided for @voterProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get voterProfile;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @adminDashboardIntro.
  ///
  /// In en, this message translates to:
  /// **'Admin web-first dashboard includes election management, monitoring, cleaning, bans, audit and fraud review.'**
  String get adminDashboardIntro;

  /// No description provided for @observerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Observer Dashboard'**
  String get observerDashboard;

  /// No description provided for @observerDashboardIntro.
  ///
  /// In en, this message translates to:
  /// **'Observer read-only portal includes transparency monitoring, audit logs, fraud flags and restricted voter directory.'**
  String get observerDashboardIntro;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @aboutIntro.
  ///
  /// In en, this message translates to:
  /// **'This section will present the creator profile, the project vision, and a Trello-powered progress dashboard (publicly viewable).'**
  String get aboutIntro;

  /// No description provided for @regionAdamawa.
  ///
  /// In en, this message translates to:
  /// **'Adamawa'**
  String get regionAdamawa;

  /// No description provided for @regionCentre.
  ///
  /// In en, this message translates to:
  /// **'Centre'**
  String get regionCentre;

  /// No description provided for @regionEast.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get regionEast;

  /// No description provided for @regionFarNorth.
  ///
  /// In en, this message translates to:
  /// **'Far North'**
  String get regionFarNorth;

  /// No description provided for @regionLittoral.
  ///
  /// In en, this message translates to:
  /// **'Littoral'**
  String get regionLittoral;

  /// No description provided for @regionNorth.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get regionNorth;

  /// No description provided for @regionNorthWest.
  ///
  /// In en, this message translates to:
  /// **'North-West'**
  String get regionNorthWest;

  /// No description provided for @regionWest.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get regionWest;

  /// No description provided for @regionSouth.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get regionSouth;

  /// No description provided for @regionSouthWest.
  ///
  /// In en, this message translates to:
  /// **'South-West'**
  String get regionSouthWest;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Security, elections, and system updates.'**
  String get notificationsSubtitle;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotifications;

  /// No description provided for @audiencePublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get audiencePublic;

  /// No description provided for @audienceVoter.
  ///
  /// In en, this message translates to:
  /// **'Voter'**
  String get audienceVoter;

  /// No description provided for @audienceObserver.
  ///
  /// In en, this message translates to:
  /// **'Observer'**
  String get audienceObserver;

  /// No description provided for @audienceAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get audienceAdmin;

  /// No description provided for @audienceAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get audienceAll;

  /// No description provided for @toastAllRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read.'**
  String get toastAllRead;

  /// No description provided for @notificationElectionSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Election starts soon'**
  String get notificationElectionSoonTitle;

  /// No description provided for @notificationElectionSoonBody.
  ///
  /// In en, this message translates to:
  /// **'A scheduled election will open soon. Get ready to vote securely.'**
  String get notificationElectionSoonBody;

  /// No description provided for @notificationElectionOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Election is now open'**
  String get notificationElectionOpenTitle;

  /// No description provided for @notificationElectionOpenBody.
  ///
  /// In en, this message translates to:
  /// **'Voting is now open. Cast your ballot securely.'**
  String get notificationElectionOpenBody;

  /// No description provided for @notificationElectionClosedTitle.
  ///
  /// In en, this message translates to:
  /// **'Election closed'**
  String get notificationElectionClosedTitle;

  /// No description provided for @notificationElectionClosedBody.
  ///
  /// In en, this message translates to:
  /// **'Voting has closed. Results will be published shortly.'**
  String get notificationElectionClosedBody;

  /// No description provided for @notificationSecurityNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Security notice'**
  String get notificationSecurityNoticeTitle;

  /// No description provided for @notificationSecurityNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'Multiple invalid attempts detected on a device. Monitoring is active.'**
  String get notificationSecurityNoticeBody;

  /// No description provided for @notificationStatusUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Status update'**
  String get notificationStatusUpdateTitle;

  /// No description provided for @notificationStatusUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'You are registered (18-19). You will automatically become eligible at 20.'**
  String get notificationStatusUpdateBody;

  /// No description provided for @summaryTab.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTab;

  /// No description provided for @chartsTab.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get chartsTab;

  /// No description provided for @mapTab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTab;

  /// No description provided for @chartBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Votes by candidate (Bar)'**
  String get chartBarTitle;

  /// No description provided for @chartPieTitle.
  ///
  /// In en, this message translates to:
  /// **'Vote share (Pie)'**
  String get chartPieTitle;

  /// No description provided for @chartLineTitle.
  ///
  /// In en, this message translates to:
  /// **'Turnout trend (Line)'**
  String get chartLineTitle;

  /// No description provided for @chartLineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visualization will be API-driven once results are published.'**
  String get chartLineSubtitle;

  /// No description provided for @votesLabel.
  ///
  /// In en, this message translates to:
  /// **'Votes'**
  String get votesLabel;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Cameroon regions (winner map)'**
  String get mapTitle;

  /// No description provided for @mapTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a region to see the current leading candidate.'**
  String get mapTapHint;

  /// No description provided for @mapLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get mapLegendTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @startupError.
  ///
  /// In en, this message translates to:
  /// **'Startup error'**
  String get startupError;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @genericErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericErrorLabel;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @winnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winnerLabel;

  /// No description provided for @resultsLive.
  ///
  /// In en, this message translates to:
  /// **'LIVE Results'**
  String get resultsLive;

  /// No description provided for @resultsFinal.
  ///
  /// In en, this message translates to:
  /// **'FINAL Results'**
  String get resultsFinal;

  /// No description provided for @publicResultsAwaitingData.
  ///
  /// In en, this message translates to:
  /// **'Awaiting official results publication.'**
  String get publicResultsAwaitingData;

  /// No description provided for @mapOfWinners.
  ///
  /// In en, this message translates to:
  /// **'Map of Regional Winners'**
  String get mapOfWinners;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @cameroon.
  ///
  /// In en, this message translates to:
  /// **'Cameroon'**
  String get cameroon;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Trust. Transparency. Truth.'**
  String get appSlogan;

  /// No description provided for @documentOcrTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Verification (OCR)'**
  String get documentOcrTitle;

  /// No description provided for @documentOcrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload an official document. We\'ll OCR it and match your details.'**
  String get documentOcrSubtitle;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document type'**
  String get documentType;

  /// No description provided for @documentTypeNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get documentTypeNationalId;

  /// No description provided for @documentTypePassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get documentTypePassport;

  /// No description provided for @documentTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other official document'**
  String get documentTypeOther;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @placeOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Place of birth'**
  String get placeOfBirth;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @nationalityAdminReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Nationality will be verified by an admin after document review.'**
  String get nationalityAdminReviewNote;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get pickFromGallery;

  /// No description provided for @captureWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get captureWithCamera;

  /// No description provided for @runOcr.
  ///
  /// In en, this message translates to:
  /// **'Run OCR & Verify'**
  String get runOcr;

  /// No description provided for @ocrProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get ocrProcessing;

  /// No description provided for @ocrExtractedTitle.
  ///
  /// In en, this message translates to:
  /// **'Extracted from document'**
  String get ocrExtractedTitle;

  /// No description provided for @ocrValidationTitle.
  ///
  /// In en, this message translates to:
  /// **'Match result'**
  String get ocrValidationTitle;

  /// No description provided for @ocrVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get ocrVerifiedTitle;

  /// No description provided for @ocrRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get ocrRejectedTitle;

  /// No description provided for @ocrSummaryVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get ocrSummaryVerified;

  /// No description provided for @ocrSummaryVerifiedPendingNationality.
  ///
  /// In en, this message translates to:
  /// **'Verified - Nationality pending admin review'**
  String get ocrSummaryVerifiedPendingNationality;

  /// No description provided for @ocrSummaryNationalityPending.
  ///
  /// In en, this message translates to:
  /// **'Nationality pending admin review'**
  String get ocrSummaryNationalityPending;

  /// No description provided for @ocrIssueNameMismatch.
  ///
  /// In en, this message translates to:
  /// **'Name mismatch'**
  String get ocrIssueNameMismatch;

  /// No description provided for @ocrIssueDobMismatch.
  ///
  /// In en, this message translates to:
  /// **'Date of birth mismatch'**
  String get ocrIssueDobMismatch;

  /// No description provided for @ocrIssuePobMismatch.
  ///
  /// In en, this message translates to:
  /// **'Place of birth mismatch'**
  String get ocrIssuePobMismatch;

  /// No description provided for @ocrIssueForeignDocument.
  ///
  /// In en, this message translates to:
  /// **'Foreign document detected'**
  String get ocrIssueForeignDocument;

  /// No description provided for @ocrVerified.
  ///
  /// In en, this message translates to:
  /// **'Document verified...'**
  String get ocrVerified;

  /// No description provided for @ocrRejected.
  ///
  /// In en, this message translates to:
  /// **'Verification rejected'**
  String get ocrRejected;

  /// No description provided for @ocrFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'OCR failed'**
  String get ocrFailedTitle;

  /// No description provided for @rawOcrText.
  ///
  /// In en, this message translates to:
  /// **'Raw OCR text'**
  String get rawOcrText;

  /// No description provided for @tryAnotherDoc.
  ///
  /// In en, this message translates to:
  /// **'Try another document'**
  String get tryAnotherDoc;

  /// No description provided for @continueNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueNext;

  /// No description provided for @ocrNotSupportedTitle.
  ///
  /// In en, this message translates to:
  /// **'OCR not available here'**
  String get ocrNotSupportedTitle;

  /// No description provided for @ocrNotSupportedMessage.
  ///
  /// In en, this message translates to:
  /// **'Document OCR works on Android/iOS. Use the mobile app for registration.'**
  String get ocrNotSupportedMessage;

  /// No description provided for @foreignDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Document not eligible'**
  String get foreignDocumentTitle;

  /// No description provided for @foreignDocumentBody.
  ///
  /// In en, this message translates to:
  /// **'This document does not appear to be a Cameroonian official document. Registration is limited to Cameroonian citizens.'**
  String get foreignDocumentBody;

  /// No description provided for @underageRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration not allowed'**
  String get underageRegistrationTitle;

  /// No description provided for @underageRegistrationBody.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old to register. Please use the public portal for information and updates.'**
  String get underageRegistrationBody;

  /// No description provided for @userLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userLabel;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'{role} sign in'**
  String loginTitle(Object role);

  /// No description provided for @adminTipReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip review'**
  String get adminTipReviewTitle;

  /// No description provided for @adminTipReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm manual tips (TapTap Send, Remitly, Orange Money Max It QR) and track proof submissions.'**
  String get adminTipReviewSubtitle;

  /// No description provided for @adminTipNoTips.
  ///
  /// In en, this message translates to:
  /// **'No tips found.'**
  String get adminTipNoTips;

  /// No description provided for @adminTipFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminTipFilterAll;

  /// No description provided for @adminTipFilterSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get adminTipFilterSubmitted;

  /// No description provided for @adminTipFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminTipFilterPending;

  /// No description provided for @adminTipFilterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get adminTipFilterSuccess;

  /// No description provided for @adminTipFilterFailed.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get adminTipFilterFailed;

  /// No description provided for @adminTipApproveTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm tip'**
  String get adminTipApproveTitle;

  /// No description provided for @adminTipRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject tip'**
  String get adminTipRejectTitle;

  /// No description provided for @adminTipDecisionNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Decision note'**
  String get adminTipDecisionNoteLabel;

  /// No description provided for @adminTipDecisionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tip status updated.'**
  String get adminTipDecisionSuccess;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @loginHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure access for {role}'**
  String loginHeaderTitle(Object role);

  /// No description provided for @loginHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify identity, continue securely, and protect every action.'**
  String get loginHeaderSubtitle;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email/ID or password.'**
  String get authInvalidCredentials;

  /// No description provided for @invalidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmailAddress;

  /// No description provided for @authAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account was found for this user.'**
  String get authAccountNotFound;

  /// No description provided for @authTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait and try again.'**
  String get authTooManyRequests;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network issue detected. Check your connection and retry.'**
  String get authNetworkError;

  /// No description provided for @authMustChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change temporary password'**
  String get authMustChangePassword;

  /// No description provided for @authMustChangePasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'For transparency and account ownership, set your own password before continuing.'**
  String get authMustChangePasswordHelp;

  /// No description provided for @authUpdatePasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get authUpdatePasswordAction;

  /// No description provided for @authPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get authPasswordUpdated;

  /// No description provided for @loginRequiresVerification.
  ///
  /// In en, this message translates to:
  /// **'Your registration is pending verification. You can sign in once an admin approves your Cameroonian document.'**
  String get loginRequiresVerification;

  /// No description provided for @loginIdentifierLabel.
  ///
  /// In en, this message translates to:
  /// **'Email or registration ID'**
  String get loginIdentifierLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Min {length} characters'**
  String passwordMinLength(Object length);

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access voter, observer, or admin portals'**
  String get signInSubtitle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanent removal with legal retention rules'**
  String get deleteAccountSubtitle;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will send a secure reset link to your account.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSend.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotPasswordSend;

  /// No description provided for @forgotPasswordSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get forgotPasswordSending;

  /// No description provided for @forgotPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent.'**
  String get forgotPasswordSuccess;

  /// No description provided for @forgotPasswordNeedHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get forgotPasswordNeedHelpTitle;

  /// No description provided for @forgotPasswordNeedHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact support for account recovery.'**
  String get forgotPasswordNeedHelpSubtitle;

  /// No description provided for @forgotPasswordHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Account recovery'**
  String get forgotPasswordHeroTitle;

  /// No description provided for @forgotPasswordHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity and regain secure access.'**
  String get forgotPasswordHeroSubtitle;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get biometricLogin;

  /// No description provided for @continueAs.
  ///
  /// In en, this message translates to:
  /// **'Continue as {name}'**
  String continueAs(Object name);

  /// No description provided for @biometricWebNotice.
  ///
  /// In en, this message translates to:
  /// **'Biometric login is available on Android and iOS.'**
  String get biometricWebNotice;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics are not available on this device.'**
  String get biometricNotAvailable;

  /// No description provided for @biometricEnrollRequired.
  ///
  /// In en, this message translates to:
  /// **'No biometrics enrolled. Please enroll Face ID or Fingerprint in your device settings.'**
  String get biometricEnrollRequired;

  /// No description provided for @biometricReasonSignIn.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity to sign in.'**
  String get biometricReasonSignIn;

  /// No description provided for @biometricReasonEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable biometric login for CamVote.'**
  String get biometricReasonEnable;

  /// No description provided for @biometricLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric + liveness login'**
  String get biometricLoginTitle;

  /// No description provided for @biometricLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require device biometrics and liveness for sign in.'**
  String get biometricLoginSubtitle;

  /// No description provided for @biometricEnableRequiresLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in before enabling biometric + liveness login.'**
  String get biometricEnableRequiresLogin;

  /// No description provided for @securityChipBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric gate'**
  String get securityChipBiometric;

  /// No description provided for @securityChipLiveness.
  ///
  /// In en, this message translates to:
  /// **'Liveness checks'**
  String get securityChipLiveness;

  /// No description provided for @securityChipAuditReady.
  ///
  /// In en, this message translates to:
  /// **'Audit ready'**
  String get securityChipAuditReady;

  /// No description provided for @securityChipFraudShield.
  ///
  /// In en, this message translates to:
  /// **'Fraud shield'**
  String get securityChipFraudShield;

  /// No description provided for @rolePortalTitle.
  ///
  /// In en, this message translates to:
  /// **'{role} portal'**
  String rolePortalTitle(Object role);

  /// No description provided for @rolePortalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secured with biometrics and live checks.'**
  String get rolePortalSubtitle;

  /// No description provided for @newVoterRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'New voter registration'**
  String get newVoterRegistrationTitle;

  /// No description provided for @newVoterRegistrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your registration and verification flow.'**
  String get newVoterRegistrationSubtitle;

  /// No description provided for @accountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSectionTitle;

  /// No description provided for @securitySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySectionTitle;

  /// No description provided for @supportSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSectionTitle;

  /// No description provided for @onboardingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get onboardingSectionTitle;

  /// No description provided for @onboardingReplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Revisit onboarding'**
  String get onboardingReplayTitle;

  /// No description provided for @onboardingReplaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replay the CamVote introduction'**
  String get onboardingReplaySubtitle;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportTitle;

  /// No description provided for @helpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We respond fast to voting, security, and fraud issues.'**
  String get helpSupportSubtitle;

  /// No description provided for @helpSupportLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help with access or security issues'**
  String get helpSupportLoginSubtitle;

  /// No description provided for @helpSupportSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help with security or voting issues'**
  String get helpSupportSettingsSubtitle;

  /// No description provided for @helpSupportPublicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report issues or request assistance'**
  String get helpSupportPublicSubtitle;

  /// No description provided for @helpSupportEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get helpSupportEmergencyTitle;

  /// No description provided for @helpSupportEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get helpSupportEmailLabel;

  /// No description provided for @helpSupportHotlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Hotline'**
  String get helpSupportHotlineLabel;

  /// No description provided for @helpSupportRegistrationIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Registration ID (optional)'**
  String get helpSupportRegistrationIdLabel;

  /// No description provided for @helpSupportCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get helpSupportCategoryLabel;

  /// No description provided for @helpSupportMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue'**
  String get helpSupportMessageLabel;

  /// No description provided for @helpSupportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit ticket'**
  String get helpSupportSubmit;

  /// No description provided for @helpSupportSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get helpSupportSubmitting;

  /// No description provided for @helpSupportSubmissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission failed.'**
  String get helpSupportSubmissionFailed;

  /// No description provided for @helpSupportTicketReceived.
  ///
  /// In en, this message translates to:
  /// **'Ticket received. Reference: {ticketId}'**
  String helpSupportTicketReceived(Object ticketId);

  /// No description provided for @helpSupportTicketQueued.
  ///
  /// In en, this message translates to:
  /// **'Ticket queued offline. Reference: {queueId}. It will auto-send when connection returns.'**
  String helpSupportTicketQueued(Object queueId);

  /// No description provided for @offlineQueuedWithReference.
  ///
  /// In en, this message translates to:
  /// **'Action queued offline. Reference: {queueId}. It will auto-sync when connection returns.'**
  String offlineQueuedWithReference(Object queueId);

  /// No description provided for @helpSupportOfflineQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending offline sync'**
  String get helpSupportOfflineQueueTitle;

  /// No description provided for @helpSupportOfflineQueueBodyCount.
  ///
  /// In en, this message translates to:
  /// **'{count} support ticket(s) are queued offline and will auto-send when connection returns.'**
  String helpSupportOfflineQueueBodyCount(Object count);

  /// No description provided for @offlineBannerOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offlineBannerOfflineTitle;

  /// No description provided for @offlineBannerPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync pending'**
  String get offlineBannerPendingTitle;

  /// No description provided for @offlineBannerOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Some actions may be queued and will auto-sync when connection returns.'**
  String get offlineBannerOfflineBody;

  /// No description provided for @offlineBannerOfflineBodyCount.
  ///
  /// In en, this message translates to:
  /// **'{count} action(s) are queued and will auto-sync when connection returns.'**
  String offlineBannerOfflineBodyCount(Object count);

  /// No description provided for @offlineBannerPendingBodyCount.
  ///
  /// In en, this message translates to:
  /// **'{count} action(s) are ready to sync.'**
  String offlineBannerPendingBodyCount(Object count);

  /// No description provided for @offlineBannerSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get offlineBannerSyncNow;

  /// No description provided for @offlineBannerSyncedCount.
  ///
  /// In en, this message translates to:
  /// **'Synced {count} item(s).'**
  String offlineBannerSyncedCount(Object count);

  /// No description provided for @offlineBannerHintAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin: continue triaging support, incidents, tips, and audit notes offline. CamVote syncs those actions automatically when internet returns.'**
  String get offlineBannerHintAdmin;

  /// No description provided for @offlineBannerHintObserver.
  ///
  /// In en, this message translates to:
  /// **'Observer: keep reporting incidents, updating checklist items, and tracking field notes offline. Sync runs automatically once connection is back.'**
  String get offlineBannerHintObserver;

  /// No description provided for @offlineBannerHintVoter.
  ///
  /// In en, this message translates to:
  /// **'Voter: continue registration steps, support tickets, and tip confirmations offline. Queued actions sync automatically when you are online again.'**
  String get offlineBannerHintVoter;

  /// No description provided for @offlineBannerHintPublic.
  ///
  /// In en, this message translates to:
  /// **'Public: you can still read cached results, civic info, and legal guides offline. Fresh updates load automatically after reconnection.'**
  String get offlineBannerHintPublic;

  /// No description provided for @helpSupportAiTitle.
  ///
  /// In en, this message translates to:
  /// **'CamGuide assistant'**
  String get helpSupportAiTitle;

  /// No description provided for @helpSupportAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start naturally: say hi, ask how-to questions, or discuss CamVote and general topics.'**
  String get helpSupportAiSubtitle;

  /// No description provided for @helpSupportAiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Start with hi or ask anything...'**
  String get helpSupportAiInputHint;

  /// No description provided for @helpSupportAiSend.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get helpSupportAiSend;

  /// No description provided for @helpSupportAiThinking.
  ///
  /// In en, this message translates to:
  /// **'CamGuide is thinking...'**
  String get helpSupportAiThinking;

  /// No description provided for @helpSupportAiSourcesLabel.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get helpSupportAiSourcesLabel;

  /// No description provided for @helpSupportAiSuggestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested follow-ups'**
  String get helpSupportAiSuggestionsLabel;

  /// No description provided for @helpSupportFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get helpSupportFaqTitle;

  /// No description provided for @helpSupportFaqRegistration.
  ///
  /// In en, this message translates to:
  /// **'How do I register? Complete OCR + biometrics enrollment.'**
  String get helpSupportFaqRegistration;

  /// No description provided for @helpSupportFaqLiveness.
  ///
  /// In en, this message translates to:
  /// **'Why liveness checks? To prevent automated or replay fraud.'**
  String get helpSupportFaqLiveness;

  /// No description provided for @helpSupportFaqReceipt.
  ///
  /// In en, this message translates to:
  /// **'How do I verify my vote? Use your receipt token.'**
  String get helpSupportFaqReceipt;

  /// No description provided for @supportCategoryRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get supportCategoryRegistration;

  /// No description provided for @supportCategoryVoting.
  ///
  /// In en, this message translates to:
  /// **'Voting'**
  String get supportCategoryVoting;

  /// No description provided for @supportCategoryBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get supportCategoryBiometrics;

  /// No description provided for @supportCategoryFraud.
  ///
  /// In en, this message translates to:
  /// **'Fraud report'**
  String get supportCategoryFraud;

  /// No description provided for @supportCategoryTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get supportCategoryTechnical;

  /// No description provided for @supportCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get supportCategoryOther;

  /// No description provided for @roleGatewayWebHint.
  ///
  /// In en, this message translates to:
  /// **'Web: public, observer, admin'**
  String get roleGatewayWebHint;

  /// No description provided for @roleGatewayMobileHint.
  ///
  /// In en, this message translates to:
  /// **'Mobile: public and voter'**
  String get roleGatewayMobileHint;

  /// No description provided for @roleGatewaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the portal that matches your mission today.'**
  String get roleGatewaySubtitle;

  /// No description provided for @roleGatewayFeatureVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified identity'**
  String get roleGatewayFeatureVerifiedTitle;

  /// No description provided for @roleGatewayFeatureVerifiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Biometrics + liveness'**
  String get roleGatewayFeatureVerifiedSubtitle;

  /// No description provided for @roleGatewayFeatureFraudTitle.
  ///
  /// In en, this message translates to:
  /// **'Fraud defenses'**
  String get roleGatewayFeatureFraudTitle;

  /// No description provided for @roleGatewayFeatureFraudSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Device + AI signals'**
  String get roleGatewayFeatureFraudSubtitle;

  /// No description provided for @roleGatewayFeatureTransparencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Transparent results'**
  String get roleGatewayFeatureTransparencyTitle;

  /// No description provided for @roleGatewayFeatureTransparencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live public dashboards'**
  String get roleGatewayFeatureTransparencySubtitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter CamVote'**
  String get onboardingEnter;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Identity you can trust'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric and liveness checks secure registration, voting, and every sensitive action.'**
  String get onboardingSlide1Subtitle;

  /// No description provided for @onboardingSlide1Highlight1.
  ///
  /// In en, this message translates to:
  /// **'Liveness verification'**
  String get onboardingSlide1Highlight1;

  /// No description provided for @onboardingSlide1Highlight2.
  ///
  /// In en, this message translates to:
  /// **'Privacy-safe receipts'**
  String get onboardingSlide1Highlight2;

  /// No description provided for @onboardingSlide1Highlight3.
  ///
  /// In en, this message translates to:
  /// **'One person, one vote'**
  String get onboardingSlide1Highlight3;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Transparent public results'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Live dashboards show turnout, counts, and verified updates for everyone.'**
  String get onboardingSlide2Subtitle;

  /// No description provided for @onboardingSlide2Highlight1.
  ///
  /// In en, this message translates to:
  /// **'Live results feeds'**
  String get onboardingSlide2Highlight1;

  /// No description provided for @onboardingSlide2Highlight2.
  ///
  /// In en, this message translates to:
  /// **'Regional drilldowns'**
  String get onboardingSlide2Highlight2;

  /// No description provided for @onboardingSlide2Highlight3.
  ///
  /// In en, this message translates to:
  /// **'Observer-ready views'**
  String get onboardingSlide2Highlight3;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Fraud defense at every step'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'AI risk signals, device integrity, and audit logs keep elections safe.'**
  String get onboardingSlide3Subtitle;

  /// No description provided for @onboardingSlide3Highlight1.
  ///
  /// In en, this message translates to:
  /// **'AI risk signals'**
  String get onboardingSlide3Highlight1;

  /// No description provided for @onboardingSlide3Highlight2.
  ///
  /// In en, this message translates to:
  /// **'Device integrity checks'**
  String get onboardingSlide3Highlight2;

  /// No description provided for @onboardingSlide3Highlight3.
  ///
  /// In en, this message translates to:
  /// **'Immutable audit trails'**
  String get onboardingSlide3Highlight3;

  /// No description provided for @chartBarLabel.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get chartBarLabel;

  /// No description provided for @chartPieLabel.
  ///
  /// In en, this message translates to:
  /// **'Pie'**
  String get chartPieLabel;

  /// No description provided for @chartLineLabel.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get chartLineLabel;

  /// No description provided for @winnerVotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Winner votes'**
  String get winnerVotesLabel;

  /// No description provided for @totalVotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total votes'**
  String get totalVotesLabel;

  /// No description provided for @aboutBuilderTitle.
  ///
  /// In en, this message translates to:
  /// **'About the builder'**
  String get aboutBuilderTitle;

  /// No description provided for @aboutBuilderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Meet the vision, mission, and roadmap behind CamVote.'**
  String get aboutBuilderSubtitle;

  /// No description provided for @aboutProfileName.
  ///
  /// In en, this message translates to:
  /// **'DJAGNI SIGNING Romuald'**
  String get aboutProfileName;

  /// No description provided for @aboutProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Computer Science Engineering Undergraduate - Civic-Tech Builder'**
  String get aboutProfileTitle;

  /// No description provided for @aboutProfileTagline.
  ///
  /// In en, this message translates to:
  /// **'Building trustworthy digital elections for Cameroon.'**
  String get aboutProfileTagline;

  /// No description provided for @aboutProfileVision.
  ///
  /// In en, this message translates to:
  /// **'A transparent, secure, and inclusive electoral system that restores trust by making every step verifiable, accessible, and audit-ready.'**
  String get aboutProfileVision;

  /// No description provided for @aboutProfileMission.
  ///
  /// In en, this message translates to:
  /// **'Design systems that protect voter identity, prevent fraud, and publish results quickly without compromising integrity.'**
  String get aboutProfileMission;

  /// No description provided for @aboutProfileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get aboutProfileEmailLabel;

  /// No description provided for @aboutProfileEmailValue.
  ///
  /// In en, this message translates to:
  /// **'romualdsigningd@gmail.com'**
  String get aboutProfileEmailValue;

  /// No description provided for @aboutProfileLinkedInLabel.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get aboutProfileLinkedInLabel;

  /// No description provided for @aboutProfileLinkedInValue.
  ///
  /// In en, this message translates to:
  /// **'https://www.linkedin.com/in/romuald-djagnisigning'**
  String get aboutProfileLinkedInValue;

  /// No description provided for @aboutProfileGitHubLabel.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get aboutProfileGitHubLabel;

  /// No description provided for @aboutProfileGitHubValue.
  ///
  /// In en, this message translates to:
  /// **'https://www.github.com/Romuald-DJAGNISIGNING'**
  String get aboutProfileGitHubValue;

  /// No description provided for @aboutProfilePortfolioLabel.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get aboutProfilePortfolioLabel;

  /// No description provided for @aboutProfilePortfolioValue.
  ///
  /// In en, this message translates to:
  /// **'https://romuald-djagnisigning.dev'**
  String get aboutProfilePortfolioValue;

  /// No description provided for @aboutTagSecureVoting.
  ///
  /// In en, this message translates to:
  /// **'Secure voting'**
  String get aboutTagSecureVoting;

  /// No description provided for @aboutTagBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get aboutTagBiometrics;

  /// No description provided for @aboutTagAuditTrails.
  ///
  /// In en, this message translates to:
  /// **'Audit trails'**
  String get aboutTagAuditTrails;

  /// No description provided for @aboutTagOfflineFirst.
  ///
  /// In en, this message translates to:
  /// **'Offline-first UX'**
  String get aboutTagOfflineFirst;

  /// No description provided for @aboutTagAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get aboutTagAccessibility;

  /// No description provided for @aboutTagLocalization.
  ///
  /// In en, this message translates to:
  /// **'EN/FR localization'**
  String get aboutTagLocalization;

  /// No description provided for @aboutVisionMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Vision & Mission'**
  String get aboutVisionMissionTitle;

  /// No description provided for @aboutVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get aboutVisionTitle;

  /// No description provided for @aboutMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get aboutMissionTitle;

  /// No description provided for @aboutContactSocialTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact & Social'**
  String get aboutContactSocialTitle;

  /// No description provided for @aboutProductFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Focus'**
  String get aboutProductFocusTitle;

  /// No description provided for @aboutTrelloTitle.
  ///
  /// In en, this message translates to:
  /// **'Trello Board Stats'**
  String get aboutTrelloTitle;

  /// No description provided for @aboutConnectTrelloTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Trello'**
  String get aboutConnectTrelloTitle;

  /// No description provided for @aboutConnectTrelloBody.
  ///
  /// In en, this message translates to:
  /// **'Set CAMVOTE_TRELLO_KEY, CAMVOTE_TRELLO_TOKEN, and CAMVOTE_TRELLO_BOARD_ID to show live board stats.'**
  String get aboutConnectTrelloBody;

  /// No description provided for @aboutTrelloLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading Trello data'**
  String get aboutTrelloLoadingTitle;

  /// No description provided for @aboutTrelloLoadingBody.
  ///
  /// In en, this message translates to:
  /// **'Fetching live project stats...'**
  String get aboutTrelloLoadingBody;

  /// No description provided for @aboutTrelloUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Trello unavailable'**
  String get aboutTrelloUnavailableTitle;

  /// No description provided for @aboutTrelloUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch board stats: {error}'**
  String aboutTrelloUnavailableBody(Object error);

  /// No description provided for @aboutTrelloNotConfiguredTitle.
  ///
  /// In en, this message translates to:
  /// **'Trello not configured'**
  String get aboutTrelloNotConfiguredTitle;

  /// No description provided for @aboutTrelloNotConfiguredBody.
  ///
  /// In en, this message translates to:
  /// **'Add Trello credentials to enable live stats.'**
  String get aboutTrelloNotConfiguredBody;

  /// No description provided for @aboutProfileLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading profile'**
  String get aboutProfileLoadingTitle;

  /// No description provided for @aboutProfileLoadingBody.
  ///
  /// In en, this message translates to:
  /// **'Fetching builder profile...'**
  String get aboutProfileLoadingBody;

  /// No description provided for @aboutProfileUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile unavailable'**
  String get aboutProfileUnavailableTitle;

  /// No description provided for @aboutProfileUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile: {error}'**
  String aboutProfileUnavailableBody(Object error);

  /// No description provided for @aboutProfileUnavailableEmpty.
  ///
  /// In en, this message translates to:
  /// **'No profile data'**
  String get aboutProfileUnavailableEmpty;

  /// No description provided for @aboutSkillsHobbiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Skills & hobbies'**
  String get aboutSkillsHobbiesTitle;

  /// No description provided for @aboutHobbyMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get aboutHobbyMusic;

  /// No description provided for @aboutHobbyReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get aboutHobbyReading;

  /// No description provided for @aboutHobbyWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get aboutHobbyWriting;

  /// No description provided for @aboutHobbySinging.
  ///
  /// In en, this message translates to:
  /// **'Singing'**
  String get aboutHobbySinging;

  /// No description provided for @aboutHobbyCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get aboutHobbyCooking;

  /// No description provided for @aboutHobbyCoding.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get aboutHobbyCoding;

  /// No description provided for @aboutHobbySleeping.
  ///
  /// In en, this message translates to:
  /// **'Sleeping'**
  String get aboutHobbySleeping;

  /// No description provided for @legalSourceElecamUrl.
  ///
  /// In en, this message translates to:
  /// **'https://portail.elecam.cm'**
  String get legalSourceElecamUrl;

  /// No description provided for @legalSourceAssnatUrl.
  ///
  /// In en, this message translates to:
  /// **'https://www.assnat.cm'**
  String get legalSourceAssnatUrl;

  /// No description provided for @aboutWhyCamVoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Why CamVote'**
  String get aboutWhyCamVoteTitle;

  /// No description provided for @aboutWhyCamVoteBody.
  ///
  /// In en, this message translates to:
  /// **'CamVote demonstrates how civic tech can reduce irregularities, improve transparency, and return credible results quickly.'**
  String get aboutWhyCamVoteBody;

  /// No description provided for @aboutCopyEmail.
  ///
  /// In en, this message translates to:
  /// **'Copy email'**
  String get aboutCopyEmail;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get passwordConfirmLabel;

  /// No description provided for @registrationAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your secure account'**
  String get registrationAuthTitle;

  /// No description provided for @registrationAuthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your email and password will secure access after approval.'**
  String get registrationAuthSubtitle;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @aboutCopyLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Copy LinkedIn'**
  String get aboutCopyLinkedIn;

  /// No description provided for @aboutCopyGitHub.
  ///
  /// In en, this message translates to:
  /// **'Copy GitHub'**
  String get aboutCopyGitHub;

  /// No description provided for @aboutCopyBoardUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy board URL'**
  String get aboutCopyBoardUrl;

  /// No description provided for @aboutBoardUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Board URL'**
  String get aboutBoardUrlLabel;

  /// No description provided for @aboutLastActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Last activity'**
  String get aboutLastActivityLabel;

  /// No description provided for @aboutTopListsLabel.
  ///
  /// In en, this message translates to:
  /// **'Top lists'**
  String get aboutTopListsLabel;

  /// No description provided for @aboutStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get aboutStatTotal;

  /// No description provided for @aboutStatOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get aboutStatOpen;

  /// No description provided for @aboutStatDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get aboutStatDone;

  /// No description provided for @aboutFooterBuiltBy.
  ///
  /// In en, this message translates to:
  /// **'(c) {year} CamVote - Built by {name}'**
  String aboutFooterBuiltBy(Object name, Object year);

  /// No description provided for @copiedMessage.
  ///
  /// In en, this message translates to:
  /// **'{label} copied'**
  String copiedMessage(Object label);

  /// No description provided for @registrationHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registrationHubTitle;

  /// No description provided for @registrationHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your secure voter enrollment process.'**
  String get registrationHubSubtitle;

  /// No description provided for @deviceAccountPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Account Policy'**
  String get deviceAccountPolicyTitle;

  /// No description provided for @deviceAccountPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'This device currently has {count}/{max} registered accounts.\nMax {max} accounts per device to reduce fraud.'**
  String deviceAccountPolicyBody(Object count, Object max);

  /// No description provided for @biometricEnrollmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric enrollment'**
  String get biometricEnrollmentTitle;

  /// No description provided for @biometricEnrollmentStatusComplete.
  ///
  /// In en, this message translates to:
  /// **'Completed and ready for verification.'**
  String get biometricEnrollmentStatusComplete;

  /// No description provided for @biometricEnrollmentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending completion.'**
  String get biometricEnrollmentStatusPending;

  /// No description provided for @statusComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get statusComplete;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get statusRequired;

  /// No description provided for @statusEnrolled.
  ///
  /// In en, this message translates to:
  /// **'Enrolled'**
  String get statusEnrolled;

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// No description provided for @registrationBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration blocked on this device'**
  String get registrationBlockedTitle;

  /// No description provided for @registrationBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'This device already reached the maximum number of accounts.\nIf this is a mistake, you can request review via support.'**
  String get registrationBlockedBody;

  /// No description provided for @startVoterRegistration.
  ///
  /// In en, this message translates to:
  /// **'Start Voter Registration'**
  String get startVoterRegistration;

  /// No description provided for @backToPublicMode.
  ///
  /// In en, this message translates to:
  /// **'Back to Public Mode'**
  String get backToPublicMode;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {details}'**
  String errorWithDetails(Object details);

  /// No description provided for @registrationDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Voter Registration (Draft)'**
  String get registrationDraftTitle;

  /// No description provided for @registrationDraftHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Voter Registration'**
  String get registrationDraftHeaderTitle;

  /// No description provided for @registrationDraftHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your personal details to begin verification.'**
  String get registrationDraftHeaderSubtitle;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get draftSaved;

  /// No description provided for @draftNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft not saved'**
  String get draftNotSaved;

  /// No description provided for @draftSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can save and resume anytime. Next step: OCR + Liveness.'**
  String get draftSavedSubtitle;

  /// No description provided for @clearDraft.
  ///
  /// In en, this message translates to:
  /// **'Clear draft'**
  String get clearDraft;

  /// No description provided for @regionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get regionLabel;

  /// No description provided for @pickDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Pick date of birth'**
  String get pickDateOfBirth;

  /// No description provided for @dateOfBirthWithValue.
  ///
  /// In en, this message translates to:
  /// **'DOB: {date}'**
  String dateOfBirthWithValue(Object date);

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// No description provided for @registrationReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review registration'**
  String get registrationReviewTitle;

  /// No description provided for @registrationReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your data before submitting.'**
  String get registrationReviewSubtitle;

  /// No description provided for @registrationSectionPersonalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get registrationSectionPersonalDetails;

  /// No description provided for @registrationSectionDocumentVerification.
  ///
  /// In en, this message translates to:
  /// **'Document verification'**
  String get registrationSectionDocumentVerification;

  /// No description provided for @registrationSectionSecurityEnrollment.
  ///
  /// In en, this message translates to:
  /// **'Security enrollment'**
  String get registrationSectionSecurityEnrollment;

  /// No description provided for @summaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryLabel;

  /// No description provided for @nameMatchLabel.
  ///
  /// In en, this message translates to:
  /// **'Name match'**
  String get nameMatchLabel;

  /// No description provided for @dobMatchLabel.
  ///
  /// In en, this message translates to:
  /// **'DOB match'**
  String get dobMatchLabel;

  /// No description provided for @pobMatchLabel.
  ///
  /// In en, this message translates to:
  /// **'POB match'**
  String get pobMatchLabel;

  /// No description provided for @nationalityMatchLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality match'**
  String get nationalityMatchLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @dateOfBirthShort.
  ///
  /// In en, this message translates to:
  /// **'DOB'**
  String get dateOfBirthShort;

  /// No description provided for @placeOfBirthShort.
  ///
  /// In en, this message translates to:
  /// **'POB'**
  String get placeOfBirthShort;

  /// No description provided for @biometricsLabel.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometricsLabel;

  /// No description provided for @livenessLabel.
  ///
  /// In en, this message translates to:
  /// **'Liveness'**
  String get livenessLabel;

  /// No description provided for @registrationConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'I confirm all information is accurate.'**
  String get registrationConsentTitle;

  /// No description provided for @registrationConsentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I consent to the secure processing of my registration data.'**
  String get registrationConsentSubtitle;

  /// No description provided for @registrationSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get registrationSubmitting;

  /// No description provided for @registrationRenewing.
  ///
  /// In en, this message translates to:
  /// **'Renewing electoral registration...'**
  String get registrationRenewing;

  /// No description provided for @registrationSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit registration'**
  String get registrationSubmit;

  /// No description provided for @registrationSubmitBlockedNote.
  ///
  /// In en, this message translates to:
  /// **'Complete document verification and enrollment to submit.'**
  String get registrationSubmitBlockedNote;

  /// No description provided for @registrationSubmissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission failed.'**
  String get registrationSubmissionFailed;

  /// No description provided for @registrationRenewalFailed.
  ///
  /// In en, this message translates to:
  /// **'Renewal failed.'**
  String get registrationRenewalFailed;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @registrationSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration submitted'**
  String get registrationSubmittedTitle;

  /// No description provided for @registrationSubmittedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your application is now in review.'**
  String get registrationSubmittedSubtitle;

  /// No description provided for @registrationSubmittedNote.
  ///
  /// In en, this message translates to:
  /// **'You will be notified once verification is complete. Keep your tracking ID safe for follow-up.'**
  String get registrationSubmittedNote;

  /// No description provided for @trackingIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking ID'**
  String get trackingIdLabel;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageLabel;

  /// No description provided for @goToVoterLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to voter login'**
  String get goToVoterLogin;

  /// No description provided for @continueToLogin.
  ///
  /// In en, this message translates to:
  /// **'Continue to login'**
  String get continueToLogin;

  /// No description provided for @deletedAccountLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Account already exists'**
  String get deletedAccountLoginTitle;

  /// No description provided for @deletedAccountLoginBody.
  ///
  /// In en, this message translates to:
  /// **'This voter record already exists in the registry and cannot be re-registered. Please sign in with biometrics + liveness to continue.'**
  String get deletedAccountLoginBody;

  /// No description provided for @deletedAccountRenewedTitle.
  ///
  /// In en, this message translates to:
  /// **'Record renewed'**
  String get deletedAccountRenewedTitle;

  /// No description provided for @deletedAccountRenewedBody.
  ///
  /// In en, this message translates to:
  /// **'Your previous record exists, but the e-electoral card had expired. We renewed the record. Please sign in to continue.'**
  String get deletedAccountRenewedBody;

  /// No description provided for @backToPublicPortal.
  ///
  /// In en, this message translates to:
  /// **'Back to Public portal'**
  String get backToPublicPortal;

  /// No description provided for @registrationStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get registrationStatusPending;

  /// No description provided for @registrationStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get registrationStatusApproved;

  /// No description provided for @registrationStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get registrationStatusRejected;

  /// No description provided for @biometricEnrollmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secure your identity with biometrics and liveness.'**
  String get biometricEnrollmentSubtitle;

  /// No description provided for @biometricEnrollmentSubtitleWithName.
  ///
  /// In en, this message translates to:
  /// **'Secure {name} with biometrics and liveness.'**
  String biometricEnrollmentSubtitleWithName(Object name);

  /// No description provided for @biometricEnrollmentStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Enroll biometrics'**
  String get biometricEnrollmentStep1Title;

  /// No description provided for @biometricEnrollmentStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'We verify your fingerprint or Face ID using your device.'**
  String get biometricEnrollmentStep1Subtitle;

  /// No description provided for @biometricEnrollmentStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Liveness check'**
  String get biometricEnrollmentStep2Title;

  /// No description provided for @biometricEnrollmentStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm you are present in front of the camera right now.'**
  String get biometricEnrollmentStep2Subtitle;

  /// No description provided for @recheck.
  ///
  /// In en, this message translates to:
  /// **'Recheck'**
  String get recheck;

  /// No description provided for @enrollNow.
  ///
  /// In en, this message translates to:
  /// **'Enroll now'**
  String get enrollNow;

  /// No description provided for @reverifyBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Re-verify biometrics'**
  String get reverifyBiometrics;

  /// No description provided for @runLiveness.
  ///
  /// In en, this message translates to:
  /// **'Run liveness'**
  String get runLiveness;

  /// No description provided for @reverifyLiveness.
  ///
  /// In en, this message translates to:
  /// **'Re-verify liveness'**
  String get reverifyLiveness;

  /// No description provided for @enrollmentCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Enrollment complete'**
  String get enrollmentCompleteTitle;

  /// No description provided for @enrollmentInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Enrollment in progress'**
  String get enrollmentInProgressTitle;

  /// No description provided for @enrollmentCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'You can now finish registration.'**
  String get enrollmentCompleteBody;

  /// No description provided for @enrollmentInProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Complete both steps to continue.'**
  String get enrollmentInProgressBody;

  /// No description provided for @finishEnrollment.
  ///
  /// In en, this message translates to:
  /// **'Finish enrollment'**
  String get finishEnrollment;

  /// No description provided for @biometricPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your biometric data is stored securely on your device and is never saved as raw images.'**
  String get biometricPrivacyNote;

  /// No description provided for @biometricEnrollReason.
  ///
  /// In en, this message translates to:
  /// **'Enroll biometrics for secure voting.'**
  String get biometricEnrollReason;

  /// No description provided for @biometricVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric verification failed.'**
  String get biometricVerificationFailed;

  /// No description provided for @biometricEnrollmentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Biometric enrollment recorded.'**
  String get biometricEnrollmentRecorded;

  /// No description provided for @livenessCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Liveness check failed.'**
  String get livenessCheckFailed;

  /// No description provided for @livenessVerifiedToast.
  ///
  /// In en, this message translates to:
  /// **'Liveness verified.'**
  String get livenessVerifiedToast;

  /// No description provided for @livenessCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Liveness Check'**
  String get livenessCheckTitle;

  /// No description provided for @livenessCameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required.'**
  String get livenessCameraPermissionRequired;

  /// No description provided for @livenessNoCameraAvailable.
  ///
  /// In en, this message translates to:
  /// **'No camera available.'**
  String get livenessNoCameraAvailable;

  /// No description provided for @livenessPreparingCamera.
  ///
  /// In en, this message translates to:
  /// **'Preparing camera...'**
  String get livenessPreparingCamera;

  /// No description provided for @livenessHoldSteady.
  ///
  /// In en, this message translates to:
  /// **'Hold steady for verification.'**
  String get livenessHoldSteady;

  /// No description provided for @livenessStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String livenessStepLabel(Object step, Object total);

  /// No description provided for @livenessVerifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Liveness verified.'**
  String get livenessVerifiedMessage;

  /// No description provided for @livenessPromptHoldSteady.
  ///
  /// In en, this message translates to:
  /// **'Hold steady. Follow the prompt.'**
  String get livenessPromptHoldSteady;

  /// No description provided for @livenessPromptCenterFace.
  ///
  /// In en, this message translates to:
  /// **'Center your face in the frame.'**
  String get livenessPromptCenterFace;

  /// No description provided for @livenessPromptAlignFace.
  ///
  /// In en, this message translates to:
  /// **'Align your face to continue.'**
  String get livenessPromptAlignFace;

  /// No description provided for @livenessStatusNoFace.
  ///
  /// In en, this message translates to:
  /// **'No face detected'**
  String get livenessStatusNoFace;

  /// No description provided for @livenessStatusFaceCentered.
  ///
  /// In en, this message translates to:
  /// **'Face centered'**
  String get livenessStatusFaceCentered;

  /// No description provided for @livenessStatusAdjustPosition.
  ///
  /// In en, this message translates to:
  /// **'Adjust position'**
  String get livenessStatusAdjustPosition;

  /// No description provided for @livenessGoodLight.
  ///
  /// In en, this message translates to:
  /// **'Good light'**
  String get livenessGoodLight;

  /// No description provided for @livenessOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get livenessOpenSettings;

  /// No description provided for @livenessTaskBlinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Blink your eyes'**
  String get livenessTaskBlinkTitle;

  /// No description provided for @livenessTaskBlinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Close both eyes, then open them.'**
  String get livenessTaskBlinkSubtitle;

  /// No description provided for @livenessTaskTurnLeftTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn left'**
  String get livenessTaskTurnLeftTitle;

  /// No description provided for @livenessTaskTurnLeftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gently turn your head to the left.'**
  String get livenessTaskTurnLeftSubtitle;

  /// No description provided for @livenessTaskTurnRightTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn right'**
  String get livenessTaskTurnRightTitle;

  /// No description provided for @livenessTaskTurnRightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gently turn your head to the right.'**
  String get livenessTaskTurnRightSubtitle;

  /// No description provided for @livenessTaskSmileTitle.
  ///
  /// In en, this message translates to:
  /// **'Give a slight smile'**
  String get livenessTaskSmileTitle;

  /// No description provided for @livenessTaskSmileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Relax your face and smile briefly.'**
  String get livenessTaskSmileSubtitle;

  /// No description provided for @voteBiometricsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Biometrics + liveness required for every vote.'**
  String get voteBiometricsSubtitle;

  /// No description provided for @noOpenElections.
  ///
  /// In en, this message translates to:
  /// **'No election is currently open for voting.'**
  String get noOpenElections;

  /// No description provided for @electionScopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Scope: {scope}'**
  String electionScopeLabel(Object scope);

  /// No description provided for @alreadyVotedInElection.
  ///
  /// In en, this message translates to:
  /// **'... You already voted in this election.'**
  String get alreadyVotedInElection;

  /// No description provided for @voteAction.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get voteAction;

  /// No description provided for @deviceBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'This device is temporarily blocked.'**
  String get deviceBlockedMessage;

  /// No description provided for @deviceBlockedUntil.
  ///
  /// In en, this message translates to:
  /// **'Until: {until}'**
  String deviceBlockedUntil(Object until);

  /// No description provided for @electionLockedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'This election is locked on this device.'**
  String get electionLockedOnDevice;

  /// No description provided for @confirmVoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm vote'**
  String get confirmVoteTitle;

  /// No description provided for @confirmVoteBody.
  ///
  /// In en, this message translates to:
  /// **'You are about to vote.\n\nSelected: {candidate} ({party})\n\nYou will be asked to verify with biometrics + liveness.'**
  String confirmVoteBody(Object candidate, Object party);

  /// No description provided for @voteBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity to cast this vote.'**
  String get voteBiometricReason;

  /// No description provided for @voteReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Vote receipt'**
  String get voteReceiptTitle;

  /// No description provided for @voteReceiptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Private verification receipt for your vote.'**
  String get voteReceiptSubtitle;

  /// No description provided for @candidateHashLabel.
  ///
  /// In en, this message translates to:
  /// **'Candidate hash'**
  String get candidateHashLabel;

  /// No description provided for @partyHashLabel.
  ///
  /// In en, this message translates to:
  /// **'Party hash'**
  String get partyHashLabel;

  /// No description provided for @castAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Cast at'**
  String get castAtLabel;

  /// No description provided for @auditTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Audit token'**
  String get auditTokenLabel;

  /// No description provided for @tokenCopied.
  ///
  /// In en, this message translates to:
  /// **'Token copied'**
  String get tokenCopied;

  /// No description provided for @copyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// No description provided for @shareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// No description provided for @printReceiptAction.
  ///
  /// In en, this message translates to:
  /// **'Print receipt'**
  String get printReceiptAction;

  /// No description provided for @receiptSafetyNote.
  ///
  /// In en, this message translates to:
  /// **'Keep this token safe. It lets you verify that your vote was included in the public audit log without revealing your choice.'**
  String get receiptSafetyNote;

  /// No description provided for @receiptShareMessage.
  ///
  /// In en, this message translates to:
  /// **'CamVote receipt token: {token}'**
  String receiptShareMessage(Object token);

  /// No description provided for @receiptBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity to access this receipt.'**
  String get receiptBiometricReason;

  /// No description provided for @receiptPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'CamVote Receipt'**
  String get receiptPdfTitle;

  /// No description provided for @electionLabel.
  ///
  /// In en, this message translates to:
  /// **'Election'**
  String get electionLabel;

  /// No description provided for @receiptPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'This receipt protects vote privacy by hashing the selection.'**
  String get receiptPrivacyNote;

  /// No description provided for @electoralCardTitle.
  ///
  /// In en, this message translates to:
  /// **'e-Electoral Card'**
  String get electoralCardTitle;

  /// No description provided for @electoralCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your verified digital voter identity card.'**
  String get electoralCardSubtitle;

  /// No description provided for @electoralCardIncompleteNote.
  ///
  /// In en, this message translates to:
  /// **'Complete voter registration to generate your e-Electoral card.'**
  String get electoralCardIncompleteNote;

  /// No description provided for @electoralCardLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'CamVote e-Electoral Card'**
  String get electoralCardLockedTitle;

  /// No description provided for @electoralCardLockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock to view your card details.'**
  String get electoralCardLockedSubtitle;

  /// No description provided for @verifyToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Verify to unlock'**
  String get verifyToUnlock;

  /// No description provided for @electoralCardBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock your e-Electoral Card.'**
  String get electoralCardBiometricReason;

  /// No description provided for @electoralCardQrNote.
  ///
  /// In en, this message translates to:
  /// **'This QR token is used to verify registration status without exposing personal details.'**
  String get electoralCardQrNote;

  /// No description provided for @electionsBrowseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse scheduled elections and candidates.'**
  String get electionsBrowseSubtitle;

  /// No description provided for @electionStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get electionStatusUpcoming;

  /// No description provided for @electionStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get electionStatusOpen;

  /// No description provided for @electionStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get electionStatusClosed;

  /// No description provided for @opensLabel.
  ///
  /// In en, this message translates to:
  /// **'Opens'**
  String get opensLabel;

  /// No description provided for @closesLabel.
  ///
  /// In en, this message translates to:
  /// **'Closes'**
  String get closesLabel;

  /// No description provided for @candidatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get candidatesLabel;

  /// No description provided for @voterHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your status, protect your vote, and stay informed.'**
  String get voterHomeSubtitle;

  /// No description provided for @nextElectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Next election'**
  String get nextElectionTitle;

  /// No description provided for @nextElectionCountdown.
  ///
  /// In en, this message translates to:
  /// **'{days} days - {time}'**
  String nextElectionCountdown(Object days, Object time);

  /// No description provided for @nextElectionCountdownLabelDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get nextElectionCountdownLabelDays;

  /// No description provided for @nextElectionCountdownLabelHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get nextElectionCountdownLabelHours;

  /// No description provided for @nextElectionCountdownLabelMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get nextElectionCountdownLabelMinutes;

  /// No description provided for @nextElectionCountdownLabelSeconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get nextElectionCountdownLabelSeconds;

  /// No description provided for @candidatesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Candidates: {count}'**
  String candidatesCountLabel(Object count);

  /// No description provided for @voterResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track results and verify your vote receipts.'**
  String get voterResultsSubtitle;

  /// No description provided for @resultsPublicPortalNote.
  ///
  /// In en, this message translates to:
  /// **'Live results are available in the Public portal charts.\nUse the Voter portal for your personal verification and receipt.'**
  String get resultsPublicPortalNote;

  /// No description provided for @pastElectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Past elections'**
  String get pastElectionsTitle;

  /// No description provided for @noClosedElections.
  ///
  /// In en, this message translates to:
  /// **'No closed election yet.'**
  String get noClosedElections;

  /// No description provided for @yourReceiptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your receipts'**
  String get yourReceiptsTitle;

  /// No description provided for @noReceiptsYet.
  ///
  /// In en, this message translates to:
  /// **'No receipts yet.'**
  String get noReceiptsYet;

  /// No description provided for @auditTokenShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Audit token: {token}'**
  String auditTokenShortLabel(Object token);

  /// No description provided for @voterProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your identity, security, and preferences.'**
  String get voterProfileSubtitle;

  /// No description provided for @signedInVoter.
  ///
  /// In en, this message translates to:
  /// **'Signed in voter'**
  String get signedInVoter;

  /// No description provided for @verificationStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification status'**
  String get verificationStatusTitle;

  /// No description provided for @verificationStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified identity and eligible status.'**
  String get verificationStatusVerified;

  /// No description provided for @verificationStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending verification. Complete OCR + biometrics.'**
  String get verificationStatusPending;

  /// No description provided for @verificationPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get verificationPendingTitle;

  /// No description provided for @verificationPendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are signed in, but voting stays locked until your Cameroonian document is approved.'**
  String get verificationPendingSubtitle;

  /// No description provided for @verificationPendingBody.
  ///
  /// In en, this message translates to:
  /// **'An admin will review your document and registration details. You will be notified when approved.'**
  String get verificationPendingBody;

  /// No description provided for @verificationTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification timeline'**
  String get verificationTimelineTitle;

  /// No description provided for @verificationStepSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration received'**
  String get verificationStepSubmittedTitle;

  /// No description provided for @verificationStepSubmittedBody.
  ///
  /// In en, this message translates to:
  /// **'We have received your registration package.'**
  String get verificationStepSubmittedBody;

  /// No description provided for @verificationStepReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin review in progress'**
  String get verificationStepReviewTitle;

  /// No description provided for @verificationStepReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Your documents are being checked for validity.'**
  String get verificationStepReviewBody;

  /// No description provided for @verificationStepDecisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Decision notification'**
  String get verificationStepDecisionTitle;

  /// No description provided for @verificationStepDecisionBody.
  ///
  /// In en, this message translates to:
  /// **'You will be notified as soon as approval is complete.'**
  String get verificationStepDecisionBody;

  /// No description provided for @verificationPendingPrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Check registration status'**
  String get verificationPendingPrimaryAction;

  /// No description provided for @verificationPendingSecondaryAction.
  ///
  /// In en, this message translates to:
  /// **'Go to public portal'**
  String get verificationPendingSecondaryAction;

  /// No description provided for @verificationPendingSupportAction.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get verificationPendingSupportAction;

  /// No description provided for @verificationPendingSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get verificationPendingSignOut;

  /// No description provided for @electoralCardViewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your digital voter card'**
  String get electoralCardViewSubtitle;

  /// No description provided for @votingCentersTitle.
  ///
  /// In en, this message translates to:
  /// **'Voting centers map'**
  String get votingCentersTitle;

  /// No description provided for @votingCentersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find verified voting centers near you and view details.'**
  String get votingCentersSubtitle;

  /// No description provided for @votingCentersPublicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Locate nearby voting centers and eligibility desks.'**
  String get votingCentersPublicSubtitle;

  /// No description provided for @votingCentersSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a voting center'**
  String get votingCentersSelectTitle;

  /// No description provided for @votingCentersSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a center for physical registration or voting.'**
  String get votingCentersSelectSubtitle;

  /// No description provided for @votingCenterSelectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a center to continue'**
  String get votingCenterSelectPrompt;

  /// No description provided for @votingCenterSelectAction.
  ///
  /// In en, this message translates to:
  /// **'Use this center'**
  String get votingCenterSelectAction;

  /// No description provided for @votingCentersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by city, neighborhood, or center name'**
  String get votingCentersSearchHint;

  /// No description provided for @votingCentersFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get votingCentersFilterAll;

  /// No description provided for @votingCentersFilterCameroon.
  ///
  /// In en, this message translates to:
  /// **'Cameroon'**
  String get votingCentersFilterCameroon;

  /// No description provided for @votingCentersFilterAbroad.
  ///
  /// In en, this message translates to:
  /// **'Abroad'**
  String get votingCentersFilterAbroad;

  /// No description provided for @votingCentersFilterEmbassy.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get votingCentersFilterEmbassy;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @votingCentersMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Cameroon voting centers'**
  String get votingCentersMapTitle;

  /// No description provided for @votingCentersMapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a marker to view a center and select it.'**
  String get votingCentersMapHint;

  /// No description provided for @votingCentersLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'Map legend'**
  String get votingCentersLegendTitle;

  /// No description provided for @votingCentersLegendCenter.
  ///
  /// In en, this message translates to:
  /// **'Voting center'**
  String get votingCentersLegendCenter;

  /// No description provided for @votingCentersLegendAbroad.
  ///
  /// In en, this message translates to:
  /// **'Abroad'**
  String get votingCentersLegendAbroad;

  /// No description provided for @votingCentersLegendEmbassy.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get votingCentersLegendEmbassy;

  /// No description provided for @votingCentersLegendYou.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get votingCentersLegendYou;

  /// No description provided for @votingCentersNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby centers'**
  String get votingCentersNearbyTitle;

  /// No description provided for @votingCentersNearbySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ordered by distance when location is available.'**
  String get votingCentersNearbySubtitle;

  /// No description provided for @votingCentersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No centers available right now. Please refresh or check back soon.'**
  String get votingCentersEmpty;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceKm(Object km);

  /// No description provided for @votingCenterNotSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'No center selected'**
  String get votingCenterNotSelectedTitle;

  /// No description provided for @votingCenterNotSelectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a voting center to complete your registration.'**
  String get votingCenterNotSelectedSubtitle;

  /// No description provided for @votingCenterSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected voting center'**
  String get votingCenterSelectedTitle;

  /// No description provided for @votingCenterLabel.
  ///
  /// In en, this message translates to:
  /// **'Voting center'**
  String get votingCenterLabel;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @biometricsUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Device not compatible'**
  String get biometricsUnavailableTitle;

  /// No description provided for @biometricsUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Biometrics or liveness are unavailable on this device. Use a physical center for registration or voting.'**
  String get biometricsUnavailableBody;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Enable them to find nearby centers.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Allow access to find nearby centers.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied. Update permissions in device settings.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalize your experience and security controls.'**
  String get settingsSubtitle;

  /// No description provided for @themeStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme style'**
  String get themeStyleTitle;

  /// No description provided for @themeStyleClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get themeStyleClassic;

  /// No description provided for @themeStyleCameroon.
  ///
  /// In en, this message translates to:
  /// **'Cameroon'**
  String get themeStyleCameroon;

  /// No description provided for @themeStyleGeek.
  ///
  /// In en, this message translates to:
  /// **'Geek'**
  String get themeStyleGeek;

  /// No description provided for @themeStyleFruity.
  ///
  /// In en, this message translates to:
  /// **'Fruity'**
  String get themeStyleFruity;

  /// No description provided for @themeStylePro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get themeStylePro;

  /// No description provided for @themeStyleMagic.
  ///
  /// In en, this message translates to:
  /// **'Magic'**
  String get themeStyleMagic;

  /// No description provided for @themeStyleFun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get themeStyleFun;

  /// No description provided for @deleteAccountHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and requires verification.'**
  String get deleteAccountHeaderSubtitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. Your access will be removed, while legal retention rules apply to official electoral records.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Type {keyword} to confirm'**
  String deleteAccountConfirmLabel(Object keyword);

  /// No description provided for @deleteKeyword.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteKeyword;

  /// No description provided for @deleteAccountConfirmError.
  ///
  /// In en, this message translates to:
  /// **'Confirmation required.'**
  String get deleteAccountConfirmError;

  /// No description provided for @deleteAccountBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm account deletion.'**
  String get deleteAccountBiometricReason;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deletingAccount;

  /// No description provided for @missingReceiptData.
  ///
  /// In en, this message translates to:
  /// **'Missing receipt data.'**
  String get missingReceiptData;

  /// No description provided for @missingRegistrationData.
  ///
  /// In en, this message translates to:
  /// **'Missing registration data.'**
  String get missingRegistrationData;

  /// No description provided for @missingSubmissionDetails.
  ///
  /// In en, this message translates to:
  /// **'Missing submission details.'**
  String get missingSubmissionDetails;

  /// No description provided for @signedInUser.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedInUser;

  /// No description provided for @adminVoterManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Voter Management'**
  String get adminVoterManagementTitle;

  /// No description provided for @adminVoterManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor registrations, verification, and flags.'**
  String get adminVoterManagementSubtitle;

  /// No description provided for @adminRunListCleaningTooltip.
  ///
  /// In en, this message translates to:
  /// **'Run electoral list cleaning'**
  String get adminRunListCleaningTooltip;

  /// No description provided for @adminListCleaningDone.
  ///
  /// In en, this message translates to:
  /// **'Cleaning done. Suspicious voters suspended.'**
  String get adminListCleaningDone;

  /// No description provided for @voterSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or voter ID...'**
  String get voterSearchHint;

  /// No description provided for @filterRegion.
  ///
  /// In en, this message translates to:
  /// **'Filter region'**
  String get filterRegion;

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter status'**
  String get filterStatus;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @regionFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Region: {region}'**
  String regionFilterLabel(Object region);

  /// No description provided for @statusFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusFilterLabel(Object status);

  /// No description provided for @noVotersMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No voters match your filters.'**
  String get noVotersMatchFilters;

  /// No description provided for @deviceFlaggedLabel.
  ///
  /// In en, this message translates to:
  /// **'Device flagged'**
  String get deviceFlaggedLabel;

  /// No description provided for @biometricDuplicateLabel.
  ///
  /// In en, this message translates to:
  /// **'Biometric duplicate'**
  String get biometricDuplicateLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age {age}'**
  String ageLabel(Object age);

  /// No description provided for @flagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Flags: {signals}'**
  String flagsLabel(Object signals);

  /// No description provided for @voterHasVotedLabel.
  ///
  /// In en, this message translates to:
  /// **'Voted'**
  String get voterHasVotedLabel;

  /// No description provided for @voterNotVotedLabel.
  ///
  /// In en, this message translates to:
  /// **'Not voted'**
  String get voterNotVotedLabel;

  /// No description provided for @chooseRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose region'**
  String get chooseRegionTitle;

  /// No description provided for @chooseStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose status'**
  String get chooseStatusTitle;

  /// No description provided for @riskLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get riskLow;

  /// No description provided for @riskMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get riskMedium;

  /// No description provided for @riskHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get riskHigh;

  /// No description provided for @riskCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get riskCritical;

  /// No description provided for @riskLabel.
  ///
  /// In en, this message translates to:
  /// **'AI {risk}'**
  String riskLabel(Object risk);

  /// No description provided for @statusPendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending verification'**
  String get statusPendingVerification;

  /// No description provided for @statusRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get statusRegistered;

  /// No description provided for @statusPreEligible.
  ///
  /// In en, this message translates to:
  /// **'Pre-eligible (18-19)'**
  String get statusPreEligible;

  /// No description provided for @statusEligible.
  ///
  /// In en, this message translates to:
  /// **'Eligible (20+)'**
  String get statusEligible;

  /// No description provided for @statusVoted.
  ///
  /// In en, this message translates to:
  /// **'Voted'**
  String get statusVoted;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// No description provided for @statusDeceased.
  ///
  /// In en, this message translates to:
  /// **'Deceased'**
  String get statusDeceased;

  /// No description provided for @statusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get statusArchived;

  /// No description provided for @adminDashboardHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor operations, audits, and live election health.'**
  String get adminDashboardHeaderSubtitle;

  /// No description provided for @statRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get statRegistered;

  /// No description provided for @statVoted.
  ///
  /// In en, this message translates to:
  /// **'Voted'**
  String get statVoted;

  /// No description provided for @statActiveElections.
  ///
  /// In en, this message translates to:
  /// **'Active elections'**
  String get statActiveElections;

  /// No description provided for @statSuspiciousFlags.
  ///
  /// In en, this message translates to:
  /// **'Suspicious flags'**
  String get statSuspiciousFlags;

  /// No description provided for @adminActionElections.
  ///
  /// In en, this message translates to:
  /// **'Elections'**
  String get adminActionElections;

  /// No description provided for @adminActionVoters.
  ///
  /// In en, this message translates to:
  /// **'Voters'**
  String get adminActionVoters;

  /// No description provided for @adminObserverAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Observer Access'**
  String get adminObserverAccessTitle;

  /// No description provided for @adminActionAuditLogs.
  ///
  /// In en, this message translates to:
  /// **'Audit Logs'**
  String get adminActionAuditLogs;

  /// No description provided for @adminObserverManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Observer access'**
  String get adminObserverManagementTitle;

  /// No description provided for @adminObserverManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grant or revoke read-only observer access.'**
  String get adminObserverManagementSubtitle;

  /// No description provided for @adminObserverSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search observers by name, email, or UID...'**
  String get adminObserverSearchHint;

  /// No description provided for @adminObserverAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'Grant observer access'**
  String get adminObserverAssignTitle;

  /// No description provided for @adminObserverAssignSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a user email or UID. The user must have signed in at least once.'**
  String get adminObserverAssignSubtitle;

  /// No description provided for @adminObserverIdentifierLabel.
  ///
  /// In en, this message translates to:
  /// **'User email or UID'**
  String get adminObserverIdentifierLabel;

  /// No description provided for @adminObserverGrantAction.
  ///
  /// In en, this message translates to:
  /// **'Grant access'**
  String get adminObserverGrantAction;

  /// No description provided for @adminObserverRevokeAction.
  ///
  /// In en, this message translates to:
  /// **'Revoke access'**
  String get adminObserverRevokeAction;

  /// No description provided for @adminObserverCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create observer account'**
  String get adminObserverCreateTitle;

  /// No description provided for @adminObserverCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provision observer credentials directly. The observer must change this temporary password at first sign-in.'**
  String get adminObserverCreateSubtitle;

  /// No description provided for @adminObserverUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username (optional)'**
  String get adminObserverUsernameLabel;

  /// No description provided for @adminObserverTempPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'Use a temporary password (minimum 8 characters).'**
  String get adminObserverTempPasswordHelp;

  /// No description provided for @adminObserverCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Observer account created.'**
  String get adminObserverCreateSuccess;

  /// No description provided for @adminObserverDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete observer'**
  String get adminObserverDeleteAction;

  /// No description provided for @adminObserverDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this observer account access? The profile will be archived and observer role removed.'**
  String get adminObserverDeleteConfirm;

  /// No description provided for @adminObserverDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Observer account archived.'**
  String get adminObserverDeleteSuccess;

  /// No description provided for @adminObserverMustChangePasswordTag.
  ///
  /// In en, this message translates to:
  /// **'Password reset required'**
  String get adminObserverMustChangePasswordTag;

  /// No description provided for @adminObserverEmpty.
  ///
  /// In en, this message translates to:
  /// **'No observers yet.'**
  String get adminObserverEmpty;

  /// No description provided for @adminObserverRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String adminObserverRoleLabel(Object role);

  /// No description provided for @adminObserverUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String adminObserverUpdatedLabel(Object date);

  /// No description provided for @adminObserverGrantSuccess.
  ///
  /// In en, this message translates to:
  /// **'Observer access granted.'**
  String get adminObserverGrantSuccess;

  /// No description provided for @adminObserverRevokeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Observer access revoked.'**
  String get adminObserverRevokeSuccess;

  /// No description provided for @adminObserverInvalidIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email or UID.'**
  String get adminObserverInvalidIdentifier;

  /// No description provided for @liveResultsPreview.
  ///
  /// In en, this message translates to:
  /// **'Live Results Preview'**
  String get liveResultsPreview;

  /// No description provided for @adminPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin preview'**
  String get adminPreviewLabel;

  /// No description provided for @observerPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Observer view'**
  String get observerPreviewLabel;

  /// No description provided for @noElectionDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No election data available.'**
  String get noElectionDataAvailable;

  /// No description provided for @fraudIntelligenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Fraud intelligence'**
  String get fraudIntelligenceTitle;

  /// No description provided for @fraudAiStatus.
  ///
  /// In en, this message translates to:
  /// **'AI ACTIVE'**
  String get fraudAiStatus;

  /// No description provided for @fraudSignalsFlagged.
  ///
  /// In en, this message translates to:
  /// **'Suspicious signals flagged: {count}'**
  String fraudSignalsFlagged(Object count);

  /// No description provided for @fraudAnomalyRate.
  ///
  /// In en, this message translates to:
  /// **'Estimated anomaly rate: {rate}%'**
  String fraudAnomalyRate(Object rate);

  /// No description provided for @fraudInsightBody.
  ///
  /// In en, this message translates to:
  /// **'Signals combine device anomalies, biometric duplicates, and behavioral mismatches. Review flagged voters in Voters.'**
  String get fraudInsightBody;

  /// No description provided for @fraudFlagsRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Flags: {flags} - Rate: {rate}%'**
  String fraudFlagsRateLabel(Object flags, Object rate);

  /// No description provided for @observerDashboardHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read-only oversight with transparent election data.'**
  String get observerDashboardHeaderSubtitle;

  /// No description provided for @observerReadOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Read-only access'**
  String get observerReadOnlyTitle;

  /// No description provided for @observerTotalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Registered: {registered} - Voted: {voted} - Flags: {flags}'**
  String observerTotalsLabel(Object registered, Object voted, Object flags);

  /// No description provided for @observerOpenAuditLogs.
  ///
  /// In en, this message translates to:
  /// **'Open Audit Logs'**
  String get observerOpenAuditLogs;

  /// No description provided for @observerReportIncidentTitle.
  ///
  /// In en, this message translates to:
  /// **'Report an incident'**
  String get observerReportIncidentTitle;

  /// No description provided for @observerReportIncidentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Submit evidence, photos, and a full incident report.'**
  String get observerReportIncidentSubtitle;

  /// No description provided for @incidentTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Incident title'**
  String get incidentTitleLabel;

  /// No description provided for @incidentCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get incidentCategoryLabel;

  /// No description provided for @incidentSeverityLabel.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get incidentSeverityLabel;

  /// No description provided for @incidentLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get incidentLocationLabel;

  /// No description provided for @incidentDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get incidentDescriptionLabel;

  /// No description provided for @incidentElectionIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Election ID (optional)'**
  String get incidentElectionIdLabel;

  /// No description provided for @incidentDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Incident date & time'**
  String get incidentDateTimeLabel;

  /// No description provided for @incidentEvidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence attachments'**
  String get incidentEvidenceTitle;

  /// No description provided for @incidentAddCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get incidentAddCamera;

  /// No description provided for @incidentAddGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get incidentAddGallery;

  /// No description provided for @incidentEvidenceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No evidence added yet.'**
  String get incidentEvidenceEmpty;

  /// No description provided for @incidentSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Submit incident report'**
  String get incidentSubmitAction;

  /// No description provided for @incidentSubmissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Incident submission failed.'**
  String get incidentSubmissionFailed;

  /// No description provided for @incidentSubmittedBody.
  ///
  /// In en, this message translates to:
  /// **'Incident report submitted. Reference: {id}'**
  String incidentSubmittedBody(Object id);

  /// No description provided for @incidentCategoryFraud.
  ///
  /// In en, this message translates to:
  /// **'Fraud'**
  String get incidentCategoryFraud;

  /// No description provided for @incidentCategoryIntimidation.
  ///
  /// In en, this message translates to:
  /// **'Intimidation'**
  String get incidentCategoryIntimidation;

  /// No description provided for @incidentCategoryViolence.
  ///
  /// In en, this message translates to:
  /// **'Violence'**
  String get incidentCategoryViolence;

  /// No description provided for @incidentCategoryLogistics.
  ///
  /// In en, this message translates to:
  /// **'Logistics'**
  String get incidentCategoryLogistics;

  /// No description provided for @incidentCategoryTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get incidentCategoryTechnical;

  /// No description provided for @incidentCategoryAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get incidentCategoryAccessibility;

  /// No description provided for @incidentCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get incidentCategoryOther;

  /// No description provided for @incidentSeverityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get incidentSeverityLow;

  /// No description provided for @incidentSeverityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get incidentSeverityMedium;

  /// No description provided for @incidentSeverityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get incidentSeverityHigh;

  /// No description provided for @incidentSeverityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get incidentSeverityCritical;

  /// No description provided for @changeAction.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeAction;

  /// No description provided for @adminElectionManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Election Management'**
  String get adminElectionManagementTitle;

  /// No description provided for @adminElectionManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, schedule, and oversee elections.'**
  String get adminElectionManagementSubtitle;

  /// No description provided for @adminCreateElection.
  ///
  /// In en, this message translates to:
  /// **'Create election'**
  String get adminCreateElection;

  /// No description provided for @noElectionsYet.
  ///
  /// In en, this message translates to:
  /// **'No elections yet.'**
  String get noElectionsYet;

  /// No description provided for @electionStatusLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get electionStatusLive;

  /// No description provided for @votesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Votes: {count}'**
  String votesCountLabel(Object count);

  /// No description provided for @addCandidate.
  ///
  /// In en, this message translates to:
  /// **'Add Candidate'**
  String get addCandidate;

  /// No description provided for @electionTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Election title'**
  String get electionTitleLabel;

  /// No description provided for @electionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Election type'**
  String get electionTypeLabel;

  /// No description provided for @electionStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start: {date}'**
  String electionStartLabel(Object date);

  /// No description provided for @electionEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End: {date}'**
  String electionEndLabel(Object date);

  /// No description provided for @electionStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start time: {time}'**
  String electionStartTimeLabel(Object time);

  /// No description provided for @electionEndTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'End time: {time}'**
  String electionEndTimeLabel(Object time);

  /// No description provided for @electionDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Election description'**
  String get electionDescriptionLabel;

  /// No description provided for @electionScopeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get electionScopeFieldLabel;

  /// No description provided for @electionScopeNational.
  ///
  /// In en, this message translates to:
  /// **'National'**
  String get electionScopeNational;

  /// No description provided for @electionScopeRegional.
  ///
  /// In en, this message translates to:
  /// **'Regional'**
  String get electionScopeRegional;

  /// No description provided for @electionScopeMunicipal.
  ///
  /// In en, this message translates to:
  /// **'Municipal'**
  String get electionScopeMunicipal;

  /// No description provided for @electionScopeDiaspora.
  ///
  /// In en, this message translates to:
  /// **'Diaspora'**
  String get electionScopeDiaspora;

  /// No description provided for @electionScopeLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get electionScopeLocal;

  /// No description provided for @electionLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location / constituency'**
  String get electionLocationLabel;

  /// No description provided for @registrationDeadlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration deadline'**
  String get registrationDeadlineTitle;

  /// No description provided for @registrationDeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Registration deadline: {date}'**
  String registrationDeadlineLabel(Object date);

  /// No description provided for @addRegistrationDeadline.
  ///
  /// In en, this message translates to:
  /// **'Add registration deadline'**
  String get addRegistrationDeadline;

  /// No description provided for @campaignStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign start'**
  String get campaignStartTitle;

  /// No description provided for @campaignStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Campaign starts: {date}'**
  String campaignStartLabel(Object date);

  /// No description provided for @addCampaignStart.
  ///
  /// In en, this message translates to:
  /// **'Add campaign start'**
  String get addCampaignStart;

  /// No description provided for @campaignEndTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign end'**
  String get campaignEndTitle;

  /// No description provided for @campaignEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Campaign ends: {date}'**
  String campaignEndLabel(Object date);

  /// No description provided for @addCampaignEnd.
  ///
  /// In en, this message translates to:
  /// **'Add campaign end'**
  String get addCampaignEnd;

  /// No description provided for @resultsPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Results publication'**
  String get resultsPublishTitle;

  /// No description provided for @resultsPublishLabel.
  ///
  /// In en, this message translates to:
  /// **'Results publication: {date}'**
  String resultsPublishLabel(Object date);

  /// No description provided for @addResultsPublish.
  ///
  /// In en, this message translates to:
  /// **'Add results publication'**
  String get addResultsPublish;

  /// No description provided for @runoffOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Runoff opening'**
  String get runoffOpenTitle;

  /// No description provided for @runoffOpenLabel.
  ///
  /// In en, this message translates to:
  /// **'Runoff opens: {date}'**
  String runoffOpenLabel(Object date);

  /// No description provided for @addRunoffOpen.
  ///
  /// In en, this message translates to:
  /// **'Add runoff opening'**
  String get addRunoffOpen;

  /// No description provided for @runoffCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Runoff closing'**
  String get runoffCloseTitle;

  /// No description provided for @runoffCloseLabel.
  ///
  /// In en, this message translates to:
  /// **'Runoff closes: {date}'**
  String runoffCloseLabel(Object date);

  /// No description provided for @addRunoffClose.
  ///
  /// In en, this message translates to:
  /// **'Add runoff closing'**
  String get addRunoffClose;

  /// No description provided for @clearDeadline.
  ///
  /// In en, this message translates to:
  /// **'Clear deadline'**
  String get clearDeadline;

  /// No description provided for @electionBallotTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Ballot type'**
  String get electionBallotTypeLabel;

  /// No description provided for @electionBallotTypeSingle.
  ///
  /// In en, this message translates to:
  /// **'Single choice'**
  String get electionBallotTypeSingle;

  /// No description provided for @electionBallotTypeRanked.
  ///
  /// In en, this message translates to:
  /// **'Ranked choice'**
  String get electionBallotTypeRanked;

  /// No description provided for @electionBallotTypeApproval.
  ///
  /// In en, this message translates to:
  /// **'Approval voting'**
  String get electionBallotTypeApproval;

  /// No description provided for @electionBallotTypeRunoff.
  ///
  /// In en, this message translates to:
  /// **'Runoff'**
  String get electionBallotTypeRunoff;

  /// No description provided for @electionEligibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Eligibility notes'**
  String get electionEligibilityLabel;

  /// No description provided for @electionTimezoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get electionTimezoneLabel;

  /// No description provided for @createAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createAction;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @partyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Party name'**
  String get partyNameLabel;

  /// No description provided for @partyAcronymLabel.
  ///
  /// In en, this message translates to:
  /// **'Party acronym'**
  String get partyAcronymLabel;

  /// No description provided for @candidateSloganLabel.
  ///
  /// In en, this message translates to:
  /// **'Candidate slogan'**
  String get candidateSloganLabel;

  /// No description provided for @candidateBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Candidate bio'**
  String get candidateBioLabel;

  /// No description provided for @candidateWebsiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Campaign website'**
  String get candidateWebsiteLabel;

  /// No description provided for @candidateAvatarUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Avatar photo URL'**
  String get candidateAvatarUrlLabel;

  /// No description provided for @candidateRunningMateLabel.
  ///
  /// In en, this message translates to:
  /// **'Running mate'**
  String get candidateRunningMateLabel;

  /// No description provided for @candidateColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Party color'**
  String get candidateColorLabel;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @approveAction.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveAction;

  /// No description provided for @rejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectAction;

  /// No description provided for @electionTypeParliamentary.
  ///
  /// In en, this message translates to:
  /// **'Parliamentary Election'**
  String get electionTypeParliamentary;

  /// No description provided for @electionTypeReferendum.
  ///
  /// In en, this message translates to:
  /// **'Referendum'**
  String get electionTypeReferendum;

  /// No description provided for @auditLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit Logs'**
  String get auditLogsTitle;

  /// No description provided for @auditLogsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Immutable trails for every action.'**
  String get auditLogsSubtitle;

  /// No description provided for @auditFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get auditFilterAll;

  /// No description provided for @auditShowingAll.
  ///
  /// In en, this message translates to:
  /// **'Showing all events'**
  String get auditShowingAll;

  /// No description provided for @auditFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter: {filter}'**
  String auditFilterLabel(Object filter);

  /// No description provided for @noAuditEvents.
  ///
  /// In en, this message translates to:
  /// **'No audit events.'**
  String get noAuditEvents;

  /// No description provided for @auditEventElectionCreated.
  ///
  /// In en, this message translates to:
  /// **'Election created'**
  String get auditEventElectionCreated;

  /// No description provided for @auditEventCandidateAdded.
  ///
  /// In en, this message translates to:
  /// **'Candidate added'**
  String get auditEventCandidateAdded;

  /// No description provided for @auditEventResultsPublished.
  ///
  /// In en, this message translates to:
  /// **'Results published'**
  String get auditEventResultsPublished;

  /// No description provided for @auditEventListCleaned.
  ///
  /// In en, this message translates to:
  /// **'List cleaned'**
  String get auditEventListCleaned;

  /// No description provided for @auditEventRegistrationApproved.
  ///
  /// In en, this message translates to:
  /// **'Registration approved'**
  String get auditEventRegistrationApproved;

  /// No description provided for @auditEventRegistrationRejected.
  ///
  /// In en, this message translates to:
  /// **'Registration rejected'**
  String get auditEventRegistrationRejected;

  /// No description provided for @auditEventSuspiciousActivity.
  ///
  /// In en, this message translates to:
  /// **'Suspicious activity'**
  String get auditEventSuspiciousActivity;

  /// No description provided for @auditEventDeviceBanned.
  ///
  /// In en, this message translates to:
  /// **'Device banned'**
  String get auditEventDeviceBanned;

  /// No description provided for @auditEventVoteCast.
  ///
  /// In en, this message translates to:
  /// **'Vote cast'**
  String get auditEventVoteCast;

  /// No description provided for @auditEventRoleChanged.
  ///
  /// In en, this message translates to:
  /// **'Role changed'**
  String get auditEventRoleChanged;

  /// No description provided for @legalHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Electoral laws & codes'**
  String get legalHubTitle;

  /// No description provided for @legalHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Official legal texts and civic references.'**
  String get legalHubSubtitle;

  /// No description provided for @legalSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Official sources'**
  String get legalSourcesTitle;

  /// No description provided for @legalSourcesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified sources for Cameroon electoral law.'**
  String get legalSourcesSubtitle;

  /// No description provided for @legalSourceElecamLabel.
  ///
  /// In en, this message translates to:
  /// **'ELECAM portal'**
  String get legalSourceElecamLabel;

  /// No description provided for @legalSourceAssnatLabel.
  ///
  /// In en, this message translates to:
  /// **'National Assembly portal'**
  String get legalSourceAssnatLabel;

  /// No description provided for @legalElectoralCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Electoral Code of Cameroon'**
  String get legalElectoralCodeTitle;

  /// No description provided for @legalDocumentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Key highlights ({language})'**
  String legalDocumentSubtitle(Object language);

  /// No description provided for @legalSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search within the document'**
  String get legalSearchHint;

  /// No description provided for @legalSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matches found. Try a different keyword.'**
  String get legalSearchEmpty;

  /// No description provided for @legalSearchResults.
  ///
  /// In en, this message translates to:
  /// **'{count} result(s)'**
  String legalSearchResults(Object count);

  /// No description provided for @openWebsite.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openWebsite;

  /// No description provided for @openLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the link.'**
  String get openLinkFailed;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @missingDocumentData.
  ///
  /// In en, this message translates to:
  /// **'Missing legal document data.'**
  String get missingDocumentData;

  /// No description provided for @adminToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin tools'**
  String get adminToolsTitle;

  /// No description provided for @adminContentSeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Content studio'**
  String get adminContentSeedTitle;

  /// No description provided for @adminContentSeedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seed civic data, election info, and reference centers.'**
  String get adminContentSeedSubtitle;

  /// No description provided for @adminContentSeedOverwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite existing entries'**
  String get adminContentSeedOverwrite;

  /// No description provided for @adminContentSeedIncludeCenters.
  ///
  /// In en, this message translates to:
  /// **'Seed regional centers (capitals)'**
  String get adminContentSeedIncludeCenters;

  /// No description provided for @adminContentSeedAction.
  ///
  /// In en, this message translates to:
  /// **'Seed Cameroon content'**
  String get adminContentSeedAction;

  /// No description provided for @adminContentSeedRunning.
  ///
  /// In en, this message translates to:
  /// **'Seeding content...'**
  String get adminContentSeedRunning;

  /// No description provided for @adminContentSeedReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Seed report'**
  String get adminContentSeedReportTitle;

  /// No description provided for @adminContentSeedCivicLessons.
  ///
  /// In en, this message translates to:
  /// **'Civic lessons'**
  String get adminContentSeedCivicLessons;

  /// No description provided for @adminContentSeedElectionCalendar.
  ///
  /// In en, this message translates to:
  /// **'Election calendar'**
  String get adminContentSeedElectionCalendar;

  /// No description provided for @adminContentSeedTransparency.
  ///
  /// In en, this message translates to:
  /// **'Transparency updates'**
  String get adminContentSeedTransparency;

  /// No description provided for @adminContentSeedChecklist.
  ///
  /// In en, this message translates to:
  /// **'Observation checklist'**
  String get adminContentSeedChecklist;

  /// No description provided for @adminContentSeedLegalDocs.
  ///
  /// In en, this message translates to:
  /// **'Legal documents'**
  String get adminContentSeedLegalDocs;

  /// No description provided for @adminContentSeedElectionsInfo.
  ///
  /// In en, this message translates to:
  /// **'Elections info'**
  String get adminContentSeedElectionsInfo;

  /// No description provided for @adminContentSeedCenters.
  ///
  /// In en, this message translates to:
  /// **'Voting centers'**
  String get adminContentSeedCenters;

  /// No description provided for @adminContentSeedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Content seeded in Firestore.'**
  String get adminContentSeedSuccess;

  /// No description provided for @adminContentManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Content manager'**
  String get adminContentManageTitle;

  /// No description provided for @adminContentManageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, update, or delete records for civic lessons, calendar, legal texts, transparency, checklist, and public content.'**
  String get adminContentManageSubtitle;

  /// No description provided for @adminContentManageSaved.
  ///
  /// In en, this message translates to:
  /// **'Content saved.'**
  String get adminContentManageSaved;

  /// No description provided for @adminContentManageEmpty.
  ///
  /// In en, this message translates to:
  /// **'No content items in this collection yet.'**
  String get adminContentManageEmpty;

  /// No description provided for @adminContentManageIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Record ID'**
  String get adminContentManageIdLabel;

  /// No description provided for @adminContentManageJsonLabel.
  ///
  /// In en, this message translates to:
  /// **'JSON payload'**
  String get adminContentManageJsonLabel;

  /// No description provided for @adminContentManageDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this content item? This action cannot be undone.'**
  String get adminContentManageDeleteConfirm;

  /// No description provided for @adminContentManageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Content deleted.'**
  String get adminContentManageDeleted;

  /// No description provided for @adminFraudMonitorTitle.
  ///
  /// In en, this message translates to:
  /// **'Fraud monitor'**
  String get adminFraudMonitorTitle;

  /// No description provided for @adminFraudMonitorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI risk signals, anomaly trends, and device flags.'**
  String get adminFraudMonitorSubtitle;

  /// No description provided for @fraudSignalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active fraud signals'**
  String get fraudSignalsTitle;

  /// No description provided for @fraudSignalDeviceAnomaly.
  ///
  /// In en, this message translates to:
  /// **'Device anomaly'**
  String get fraudSignalDeviceAnomaly;

  /// No description provided for @fraudSignalBiometricDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Biometric duplicate'**
  String get fraudSignalBiometricDuplicate;

  /// No description provided for @fraudSignalUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get fraudSignalUnverified;

  /// No description provided for @fraudSignalAgeAnomaly.
  ///
  /// In en, this message translates to:
  /// **'Age anomaly'**
  String get fraudSignalAgeAnomaly;

  /// No description provided for @fraudSignalStatusRisk.
  ///
  /// In en, this message translates to:
  /// **'Status risk'**
  String get fraudSignalStatusRisk;

  /// No description provided for @fraudSignalVoteStateMismatch.
  ///
  /// In en, this message translates to:
  /// **'Vote state mismatch'**
  String get fraudSignalVoteStateMismatch;

  /// No description provided for @fraudSignalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} signals'**
  String fraudSignalCount(Object count);

  /// No description provided for @fraudRiskScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk score'**
  String get fraudRiskScoreTitle;

  /// No description provided for @fraudRiskScoreValue.
  ///
  /// In en, this message translates to:
  /// **'{score}% risk'**
  String fraudRiskScoreValue(Object score);

  /// No description provided for @fraudSignalTotal.
  ///
  /// In en, this message translates to:
  /// **'Signals'**
  String get fraudSignalTotal;

  /// No description provided for @fraudDevicesFlagged.
  ///
  /// In en, this message translates to:
  /// **'Devices flagged'**
  String get fraudDevicesFlagged;

  /// No description provided for @fraudAccountsAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Accounts at risk'**
  String get fraudAccountsAtRisk;

  /// No description provided for @adminSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Device security'**
  String get adminSecurityTitle;

  /// No description provided for @adminSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Device risk status, strikes, and integrity alerts.'**
  String get adminSecuritySubtitle;

  /// No description provided for @securityStrikesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} strikes'**
  String securityStrikesLabel(Object count);

  /// No description provided for @adminIncidentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Incident oversight'**
  String get adminIncidentsTitle;

  /// No description provided for @adminIncidentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor and resolve field incidents and reports.'**
  String get adminIncidentsSubtitle;

  /// No description provided for @incidentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{severity} - {location}'**
  String incidentSubtitle(Object severity, Object location);

  /// No description provided for @filterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterLabel;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @incidentStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get incidentStatusOpen;

  /// No description provided for @incidentStatusInvestigating.
  ///
  /// In en, this message translates to:
  /// **'Investigating'**
  String get incidentStatusInvestigating;

  /// No description provided for @incidentStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get incidentStatusResolved;

  /// No description provided for @adminResultsPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish results'**
  String get adminResultsPublishTitle;

  /// No description provided for @adminResultsPublishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Finalize and publish verified results.'**
  String get adminResultsPublishSubtitle;

  /// No description provided for @adminVotingCentersTitle.
  ///
  /// In en, this message translates to:
  /// **'Voting centers'**
  String get adminVotingCentersTitle;

  /// No description provided for @adminVotingCentersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} centers in the directory.'**
  String adminVotingCentersSubtitle(Object count);

  /// No description provided for @adminVotingCentersImportCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get adminVotingCentersImportCsv;

  /// No description provided for @adminVotingCentersImportHint.
  ///
  /// In en, this message translates to:
  /// **'Paste CSV with columns: name,address,city,region_code,region_name,country,country_code,type,latitude,longitude,status,contact,notes'**
  String get adminVotingCentersImportHint;

  /// No description provided for @adminVotingCentersImportDone.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} centers.'**
  String adminVotingCentersImportDone(Object count);

  /// No description provided for @adminVotingCentersEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit voting center'**
  String get adminVotingCentersEditTitle;

  /// No description provided for @adminVotingCentersCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create voting center'**
  String get adminVotingCentersCreateTitle;

  /// No description provided for @adminVotingCentersDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this voting center? This cannot be undone.'**
  String get adminVotingCentersDeleteConfirm;

  /// No description provided for @centerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Center name'**
  String get centerNameLabel;

  /// No description provided for @centerAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get centerAddressLabel;

  /// No description provided for @centerCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get centerCityLabel;

  /// No description provided for @centerRegionCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Region code'**
  String get centerRegionCodeLabel;

  /// No description provided for @centerRegionNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Region name'**
  String get centerRegionNameLabel;

  /// No description provided for @centerCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get centerCountryLabel;

  /// No description provided for @centerCountryCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Country code'**
  String get centerCountryCodeLabel;

  /// No description provided for @centerLatitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get centerLatitudeLabel;

  /// No description provided for @centerLongitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get centerLongitudeLabel;

  /// No description provided for @centerTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Center type'**
  String get centerTypeLabel;

  /// No description provided for @centerTypeDomestic.
  ///
  /// In en, this message translates to:
  /// **'Domestic'**
  String get centerTypeDomestic;

  /// No description provided for @centerTypeEmbassy.
  ///
  /// In en, this message translates to:
  /// **'Embassy'**
  String get centerTypeEmbassy;

  /// No description provided for @centerTypeConsulate.
  ///
  /// In en, this message translates to:
  /// **'Consulate'**
  String get centerTypeConsulate;

  /// No description provided for @centerTypeDiaspora.
  ///
  /// In en, this message translates to:
  /// **'Diaspora'**
  String get centerTypeDiaspora;

  /// No description provided for @centerTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get centerTypeOther;

  /// No description provided for @centerStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get centerStatusLabel;

  /// No description provided for @centerStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get centerStatusActive;

  /// No description provided for @centerStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get centerStatusInactive;

  /// No description provided for @centerStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get centerStatusPending;

  /// No description provided for @centerContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get centerContactLabel;

  /// No description provided for @centerNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get centerNotesLabel;

  /// No description provided for @resultsPublishSummary.
  ///
  /// In en, this message translates to:
  /// **'{votes} votes - {precincts} precincts reporting'**
  String resultsPublishSummary(Object votes, Object precincts);

  /// No description provided for @publishResultsAction.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishResultsAction;

  /// No description provided for @resultsPublishNotReady.
  ///
  /// In en, this message translates to:
  /// **'Not ready'**
  String get resultsPublishNotReady;

  /// No description provided for @resultsPublishedToast.
  ///
  /// In en, this message translates to:
  /// **'Results published.'**
  String get resultsPublishedToast;

  /// No description provided for @observerToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Observer tools'**
  String get observerToolsTitle;

  /// No description provided for @observerResultsToolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read-only live results and trends.'**
  String get observerResultsToolSubtitle;

  /// No description provided for @observerIncidentTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Incident tracker'**
  String get observerIncidentTrackerTitle;

  /// No description provided for @observerIncidentTrackerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your reported incidents in real time.'**
  String get observerIncidentTrackerSubtitle;

  /// No description provided for @observerTransparencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Transparency feed'**
  String get observerTransparencyTitle;

  /// No description provided for @observerTransparencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Official updates and public accountability notes.'**
  String get observerTransparencySubtitle;

  /// No description provided for @observerChecklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Observation checklist'**
  String get observerChecklistTitle;

  /// No description provided for @observerChecklistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify compliance points and log observations.'**
  String get observerChecklistSubtitle;

  /// No description provided for @publicElectionCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Election calendar'**
  String get publicElectionCalendarTitle;

  /// No description provided for @publicElectionCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming election dates and milestones.'**
  String get publicElectionCalendarSubtitle;

  /// No description provided for @publicCivicEducationTitle.
  ///
  /// In en, this message translates to:
  /// **'Civic education'**
  String get publicCivicEducationTitle;

  /// No description provided for @publicCivicEducationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn voting rights, duties, and procedures.'**
  String get publicCivicEducationSubtitle;

  /// No description provided for @calendarEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{scope} - {location}\n{start} -> {end}'**
  String calendarEntrySubtitle(
    Object scope,
    Object location,
    Object start,
    Object end,
  );

  /// No description provided for @accountArchivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account archived'**
  String get accountArchivedTitle;

  /// No description provided for @accountArchivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is inactive'**
  String get accountArchivedSubtitle;

  /// No description provided for @accountArchivedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account was archived at your request or by an administrator. To restore access, please contact support or sign in to verify your identity.'**
  String get accountArchivedBody;

  /// No description provided for @accountArchivedLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get accountArchivedLoginAction;

  /// No description provided for @accountArchivedPublicAction.
  ///
  /// In en, this message translates to:
  /// **'Continue as public'**
  String get accountArchivedPublicAction;

  /// No description provided for @accountArchivedMessage.
  ///
  /// In en, this message translates to:
  /// **'This account is archived. Please sign in to verify or contact support.'**
  String get accountArchivedMessage;

  /// No description provided for @readMoreAction.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMoreAction;

  /// No description provided for @countdownsTitle.
  ///
  /// In en, this message translates to:
  /// **'Countdowns'**
  String get countdownsTitle;

  /// No description provided for @countdownsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track election moments and personal eligibility timers.'**
  String get countdownsSubtitle;

  /// No description provided for @countdownElectionsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Election countdowns'**
  String get countdownElectionsSectionTitle;

  /// No description provided for @countdownElectionOpensTitle.
  ///
  /// In en, this message translates to:
  /// **'Opens in'**
  String get countdownElectionOpensTitle;

  /// No description provided for @countdownElectionClosesTitle.
  ///
  /// In en, this message translates to:
  /// **'Closes in'**
  String get countdownElectionClosesTitle;

  /// No description provided for @countdownCardExpiryTitle.
  ///
  /// In en, this message translates to:
  /// **'e-Electoral card expiry'**
  String get countdownCardExpiryTitle;

  /// No description provided for @countdownCardExpiryBody.
  ///
  /// In en, this message translates to:
  /// **'Your card expires on {date}.'**
  String countdownCardExpiryBody(Object date);

  /// No description provided for @countdownCardExpiryWarning.
  ///
  /// In en, this message translates to:
  /// **'Renew before expiry to keep your voting status active.'**
  String get countdownCardExpiryWarning;

  /// No description provided for @countdownRenewCardAction.
  ///
  /// In en, this message translates to:
  /// **'Renew card'**
  String get countdownRenewCardAction;

  /// No description provided for @countdownEligibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Eligibility unlock'**
  String get countdownEligibilityTitle;

  /// No description provided for @countdownEligibilityBody.
  ///
  /// In en, this message translates to:
  /// **'You become eligible to vote on {date}.'**
  String countdownEligibilityBody(Object date);

  /// No description provided for @countdownEligibilityCelebrate.
  ///
  /// In en, this message translates to:
  /// **'You\'re now eligible to vote!'**
  String get countdownEligibilityCelebrate;

  /// No description provided for @countdownSuspensionTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspension ends'**
  String get countdownSuspensionTitle;

  /// No description provided for @countdownSuspensionBody.
  ///
  /// In en, this message translates to:
  /// **'Suspension lifts on {date}.'**
  String countdownSuspensionBody(Object date);

  /// No description provided for @countdownNoTimersTitle.
  ///
  /// In en, this message translates to:
  /// **'No active countdowns'**
  String get countdownNoTimersTitle;

  /// No description provided for @countdownNoTimersBody.
  ///
  /// In en, this message translates to:
  /// **'Your next timers will appear here as soon as data is available.'**
  String get countdownNoTimersBody;

  /// No description provided for @countdownExpiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get countdownExpiredLabel;

  /// No description provided for @countdownTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get countdownTodayLabel;

  /// No description provided for @countdownViewAllAction.
  ///
  /// In en, this message translates to:
  /// **'View all countdowns'**
  String get countdownViewAllAction;

  /// No description provided for @voterCountdowns.
  ///
  /// In en, this message translates to:
  /// **'Countdowns'**
  String get voterCountdowns;

  /// No description provided for @voterCountdownsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track election timers and eligibility updates.'**
  String get voterCountdownsSubtitle;

  /// No description provided for @countdownPersonalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal countdowns'**
  String get countdownPersonalSectionTitle;

  /// No description provided for @countdownRegistrationDeadlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration closes in'**
  String get countdownRegistrationDeadlineTitle;

  /// No description provided for @countdownCampaignStartsTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign starts in'**
  String get countdownCampaignStartsTitle;

  /// No description provided for @countdownCampaignEndsTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign ends in'**
  String get countdownCampaignEndsTitle;

  /// No description provided for @countdownResultsPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Results publication in'**
  String get countdownResultsPublishTitle;

  /// No description provided for @countdownRunoffOpensTitle.
  ///
  /// In en, this message translates to:
  /// **'Runoff opens in'**
  String get countdownRunoffOpensTitle;

  /// No description provided for @countdownRunoffClosesTitle.
  ///
  /// In en, this message translates to:
  /// **'Runoff closes in'**
  String get countdownRunoffClosesTitle;

  /// No description provided for @webDownloadAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Get the CAMVOTE mobile app'**
  String get webDownloadAppTitle;

  /// No description provided for @webDownloadAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register, vote, and receive updates faster on your phone.'**
  String get webDownloadAppSubtitle;

  /// No description provided for @webDownloadPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Get it on Google Play'**
  String get webDownloadPlayStore;

  /// No description provided for @webDownloadAppStore.
  ///
  /// In en, this message translates to:
  /// **'Download on the App Store'**
  String get webDownloadAppStore;

  /// No description provided for @webDownloadQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan to download'**
  String get webDownloadQrTitle;

  /// No description provided for @webDownloadLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more about mobile features'**
  String get webDownloadLearnMore;

  /// No description provided for @supportCamVoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Support CamVote'**
  String get supportCamVoteTitle;

  /// No description provided for @supportCamVoteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a tip via TapTap Send, Remitly, or Orange Money Max It'**
  String get supportCamVoteSubtitle;

  /// No description provided for @supportCamVoteContributeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contribute via TapTap Send, Remitly, or Orange Money Max It'**
  String get supportCamVoteContributeSubtitle;

  /// No description provided for @supportCamVoteHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Support CamVote project'**
  String get supportCamVoteHeaderTitle;

  /// No description provided for @supportCamVoteHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a tip via TapTap Send, Remitly, or Orange Money Max It. Tipping is open to everyone and keeps your details private.'**
  String get supportCamVoteHeaderSubtitle;

  /// No description provided for @supportCamVoteImpactTitle.
  ///
  /// In en, this message translates to:
  /// **'How your support is used'**
  String get supportCamVoteImpactTitle;

  /// No description provided for @supportCamVoteImpactIntro.
  ///
  /// In en, this message translates to:
  /// **'Your contribution helps us keep CamVote secure, fast, and available for more citizens.'**
  String get supportCamVoteImpactIntro;

  /// No description provided for @supportCamVoteImpactSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security hardening for biometric, liveness, and anti-fraud systems.'**
  String get supportCamVoteImpactSecurity;

  /// No description provided for @supportCamVoteImpactReliability.
  ///
  /// In en, this message translates to:
  /// **'Better reliability, server uptime, and faster releases across web, Android, and iOS.'**
  String get supportCamVoteImpactReliability;

  /// No description provided for @supportCamVoteImpactCommunity.
  ///
  /// In en, this message translates to:
  /// **'Civic education improvements and wider access for voters and observers.'**
  String get supportCamVoteImpactCommunity;

  /// No description provided for @supportCamVoteImpactTransparency.
  ///
  /// In en, this message translates to:
  /// **'Transparent operations with auditable updates and measurable public impact.'**
  String get supportCamVoteImpactTransparency;

  /// No description provided for @helpSupportLiveHelpDesk.
  ///
  /// In en, this message translates to:
  /// **'Live Help Desk'**
  String get helpSupportLiveHelpDesk;

  /// No description provided for @helpSupportLiveHelpDeskHint.
  ///
  /// In en, this message translates to:
  /// **'Your message will be sent to the Help Desk admin and you will receive updates in notifications.'**
  String get helpSupportLiveHelpDeskHint;

  /// No description provided for @helpSupportChatWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get helpSupportChatWhatsApp;

  /// No description provided for @helpSupportWhatsAppGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello CamVote, I am contacting support via WhatsApp.'**
  String get helpSupportWhatsAppGreeting;

  /// No description provided for @helpSupportWhatsAppOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open WhatsApp right now.'**
  String get helpSupportWhatsAppOpenFailed;

  /// No description provided for @helpSupportFaqObserverHowTo.
  ///
  /// In en, this message translates to:
  /// **'How to become an observer: contact the admin with an official mandate and documents proving observer status (state, party, civil society, NGO, or international body), with recognition by the State of Cameroon. In observer mode, you cannot vote.'**
  String get helpSupportFaqObserverHowTo;

  /// No description provided for @tipChoosePaymentChannel.
  ///
  /// In en, this message translates to:
  /// **'Choose your payment channel'**
  String get tipChoosePaymentChannel;

  /// No description provided for @tipChannelElyonpay.
  ///
  /// In en, this message translates to:
  /// **'TapTap Send'**
  String get tipChannelElyonpay;

  /// No description provided for @tipChannelRemitly.
  ///
  /// In en, this message translates to:
  /// **'Remitly'**
  String get tipChannelRemitly;

  /// No description provided for @tipChannelMaxItQr.
  ///
  /// In en, this message translates to:
  /// **'Orange Money Max It'**
  String get tipChannelMaxItQr;

  /// No description provided for @tipAnonymousTitle.
  ///
  /// In en, this message translates to:
  /// **'Anonymous tip'**
  String get tipAnonymousTitle;

  /// No description provided for @tipAnonymousSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your name is hidden. A thank-you message is still delivered.'**
  String get tipAnonymousSubtitle;

  /// No description provided for @tipNameHiddenLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (hidden)'**
  String get tipNameHiddenLabel;

  /// No description provided for @tipAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get tipAmountLabel;

  /// No description provided for @tipAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get tipAmountInvalid;

  /// No description provided for @tipCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get tipCurrencyLabel;

  /// No description provided for @tipPersonalMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal message'**
  String get tipPersonalMessageLabel;

  /// No description provided for @tipPayWithElyonpay.
  ///
  /// In en, this message translates to:
  /// **'Open TapTap Send'**
  String get tipPayWithElyonpay;

  /// No description provided for @tipPayWithRemitly.
  ///
  /// In en, this message translates to:
  /// **'Open Remitly'**
  String get tipPayWithRemitly;

  /// No description provided for @tipTapTapSendInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'TapTap Send transfer'**
  String get tipTapTapSendInstructionsTitle;

  /// No description provided for @tipTapTapSendInstructionsBody.
  ///
  /// In en, this message translates to:
  /// **'Open TapTap Send, complete your transfer, then submit the reference so our team can confirm your tip.'**
  String get tipTapTapSendInstructionsBody;

  /// No description provided for @tipRemitlyInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Remitly transfer'**
  String get tipRemitlyInstructionsTitle;

  /// No description provided for @tipRemitlyInstructionsBody.
  ///
  /// In en, this message translates to:
  /// **'Open Remitly, sign in if prompted, complete your transfer, then submit the reference so our team can confirm your tip.'**
  String get tipRemitlyInstructionsBody;

  /// No description provided for @tipReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Transfer reference or transaction ID'**
  String get tipReferenceHint;

  /// No description provided for @tipProofNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note for the admin (optional)'**
  String get tipProofNoteLabel;

  /// No description provided for @tipSubmitProof.
  ///
  /// In en, this message translates to:
  /// **'Submit payment reference'**
  String get tipSubmitProof;

  /// No description provided for @tipSubmittedBody.
  ///
  /// In en, this message translates to:
  /// **'Reference received. We will confirm shortly.'**
  String get tipSubmittedBody;

  /// No description provided for @tipPaymentSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Reference submitted'**
  String get tipPaymentSubmitted;

  /// No description provided for @tipReferenceMissing.
  ///
  /// In en, this message translates to:
  /// **'Enter the payment reference first.'**
  String get tipReferenceMissing;

  /// No description provided for @tipReceiptOptionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt screenshots (optional)'**
  String get tipReceiptOptionalTitle;

  /// No description provided for @tipReceiptOptionalBody.
  ///
  /// In en, this message translates to:
  /// **'You can submit without screenshots. If you have a receipt, upload it to help us confirm faster.'**
  String get tipReceiptOptionalBody;

  /// No description provided for @tipReceiptUploadAction.
  ///
  /// In en, this message translates to:
  /// **'Upload receipt'**
  String get tipReceiptUploadAction;

  /// No description provided for @tipReceiptLabel.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get tipReceiptLabel;

  /// No description provided for @tipReceiptUploadedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} receipt(s) uploaded'**
  String tipReceiptUploadedCount(Object count);

  /// No description provided for @tipGenerateMaxItQr.
  ///
  /// In en, this message translates to:
  /// **'Show Orange Money Max It QR'**
  String get tipGenerateMaxItQr;

  /// No description provided for @tipMsisdnLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile money number'**
  String get tipMsisdnLabel;

  /// No description provided for @tipMsisdnHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. +2376XXXXXXXX'**
  String get tipMsisdnHint;

  /// No description provided for @tipMsisdnInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get tipMsisdnInvalid;

  /// No description provided for @tipScanMaxItQr.
  ///
  /// In en, this message translates to:
  /// **'Open your Max It app and scan this Orange Money QR to tip'**
  String get tipScanMaxItQr;

  /// No description provided for @tipPaymentTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment tracking'**
  String get tipPaymentTrackingTitle;

  /// No description provided for @tipReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get tipReferenceLabel;

  /// No description provided for @tipCheckStatus.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get tipCheckStatus;

  /// No description provided for @tipWaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment confirmation.'**
  String get tipWaitingConfirmation;

  /// No description provided for @tipCheckingPayment.
  ///
  /// In en, this message translates to:
  /// **'Checking payment...'**
  String get tipCheckingPayment;

  /// No description provided for @tipPreparingSecurePaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing secure payment'**
  String get tipPreparingSecurePaymentTitle;

  /// No description provided for @tipPreparingSecurePaymentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please wait while CamVote configures your tip flow.'**
  String get tipPreparingSecurePaymentSubtitle;

  /// No description provided for @tipAnonymousSupporterName.
  ///
  /// In en, this message translates to:
  /// **'Anonymous supporter'**
  String get tipAnonymousSupporterName;

  /// No description provided for @tipSupporterFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Supporter'**
  String get tipSupporterFallbackName;

  /// No description provided for @tipNotificationReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip received'**
  String get tipNotificationReceivedTitle;

  /// No description provided for @tipNotificationReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you {name}! Your contribution was received.'**
  String tipNotificationReceivedBody(Object name);

  /// No description provided for @tipNotificationReceivedBodyAmount.
  ///
  /// In en, this message translates to:
  /// **'Thank you {name}! We received your tip of {amount} {currency}.'**
  String tipNotificationReceivedBodyAmount(
    Object name,
    Object amount,
    Object currency,
  );

  /// No description provided for @tipThankYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you {name}!'**
  String tipThankYouTitle(Object name);

  /// No description provided for @tipThankYouBody.
  ///
  /// In en, this message translates to:
  /// **'Your support keeps CamVote growing and improving for everyone.'**
  String get tipThankYouBody;

  /// No description provided for @tipThankYouBodyAmount.
  ///
  /// In en, this message translates to:
  /// **'Thank you {name}. Your tip of {amount} {currency} has been received successfully. Your support helps CamVote grow with transparency and impact.'**
  String tipThankYouBodyAmount(Object name, Object amount, Object currency);

  /// No description provided for @tipSelectedChannel.
  ///
  /// In en, this message translates to:
  /// **'Selected channel'**
  String get tipSelectedChannel;

  /// No description provided for @tipProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider: {provider}'**
  String tipProviderLabel(Object provider);

  /// No description provided for @tipIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Tip ID: {tipId}'**
  String tipIdLabel(Object tipId);

  /// No description provided for @tipAnonymousModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Anonymous mode enabled'**
  String get tipAnonymousModeEnabled;

  /// No description provided for @tipDestinationOrangeMoneyCameroon.
  ///
  /// In en, this message translates to:
  /// **'Orange Money Cameroon destination'**
  String get tipDestinationOrangeMoneyCameroon;

  /// No description provided for @tipRecipientNameNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Recipient name not configured'**
  String get tipRecipientNameNotConfigured;

  /// No description provided for @tipRecipientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient name: {name}'**
  String tipRecipientNameLabel(Object name);

  /// No description provided for @tipRecipientNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient number: {number}'**
  String tipRecipientNumberLabel(Object number);

  /// No description provided for @tipVerifyRecipientNameHint.
  ///
  /// In en, this message translates to:
  /// **'Verify this recipient name inside checkout. If the name does not match, cancel.'**
  String get tipVerifyRecipientNameHint;

  /// No description provided for @tipPhoneHiddenHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number hidden for security: use TapTap Send, Remitly, or the Max It QR flow.'**
  String get tipPhoneHiddenHint;

  /// No description provided for @tipOpenPayment.
  ///
  /// In en, this message translates to:
  /// **'Open payment'**
  String get tipOpenPayment;

  /// No description provided for @tipOpenMaxIt.
  ///
  /// In en, this message translates to:
  /// **'Open Max It'**
  String get tipOpenMaxIt;

  /// No description provided for @tipPaymentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed'**
  String get tipPaymentConfirmed;

  /// No description provided for @tipPaymentAwaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmation'**
  String get tipPaymentAwaitingConfirmation;

  /// No description provided for @tipStatusSummary.
  ///
  /// In en, this message translates to:
  /// **'{amount} {currency} - {provider}'**
  String tipStatusSummary(Object amount, Object currency, Object provider);

  /// No description provided for @adminSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Support'**
  String get adminSupportTitle;

  /// No description provided for @adminSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review support tickets, respond to users, and track ticket status.'**
  String get adminSupportSubtitle;

  /// No description provided for @adminSupportSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email, registration ID, or message'**
  String get adminSupportSearchHint;

  /// No description provided for @adminSupportAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get adminSupportAllStatuses;

  /// No description provided for @adminSupportNoTickets.
  ///
  /// In en, this message translates to:
  /// **'No support tickets found.'**
  String get adminSupportNoTickets;

  /// No description provided for @adminSupportTicketUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ticket updated successfully.'**
  String get adminSupportTicketUpdatedSuccess;

  /// No description provided for @adminSupportRespondToTicket.
  ///
  /// In en, this message translates to:
  /// **'Respond to ticket {ticketId}'**
  String adminSupportRespondToTicket(Object ticketId);

  /// No description provided for @adminSupportNewStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'New status'**
  String get adminSupportNewStatusLabel;

  /// No description provided for @adminSupportResponseMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Response message'**
  String get adminSupportResponseMessageLabel;

  /// No description provided for @adminSupportSendResponse.
  ///
  /// In en, this message translates to:
  /// **'Send response'**
  String get adminSupportSendResponse;

  /// No description provided for @adminSupportRegistrationIdValue.
  ///
  /// In en, this message translates to:
  /// **'Registration ID: {registrationId}'**
  String adminSupportRegistrationIdValue(Object registrationId);

  /// No description provided for @adminSupportUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {date} {time}'**
  String adminSupportUpdatedAt(Object date, Object time);

  /// No description provided for @adminSupportRespondAction.
  ///
  /// In en, this message translates to:
  /// **'Respond'**
  String get adminSupportRespondAction;

  /// No description provided for @adminSupportUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get adminSupportUpdateAction;

  /// No description provided for @adminSupportStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get adminSupportStatusOpen;

  /// No description provided for @adminSupportStatusAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get adminSupportStatusAnswered;

  /// No description provided for @adminSupportStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get adminSupportStatusResolved;

  /// No description provided for @adminSupportStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get adminSupportStatusClosed;

  /// No description provided for @adminSupportStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get adminSupportStatusUnknown;

  /// No description provided for @voteImpactAddedLive.
  ///
  /// In en, this message translates to:
  /// **'Your vote was secured and added live.'**
  String get voteImpactAddedLive;

  /// No description provided for @voteImpactRecorded.
  ///
  /// In en, this message translates to:
  /// **'Your vote was recorded successfully.'**
  String get voteImpactRecorded;

  /// No description provided for @voteImpactPreviousTotal.
  ///
  /// In en, this message translates to:
  /// **'Previous total'**
  String get voteImpactPreviousTotal;

  /// No description provided for @voteImpactYourContribution.
  ///
  /// In en, this message translates to:
  /// **'Your contribution'**
  String get voteImpactYourContribution;

  /// No description provided for @voteImpactNewLiveTotal.
  ///
  /// In en, this message translates to:
  /// **'New live total'**
  String get voteImpactNewLiveTotal;

  /// No description provided for @adminDemographicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Registered voter age distribution'**
  String get adminDemographicsTitle;

  /// No description provided for @adminDemographicsTotalEligible.
  ///
  /// In en, this message translates to:
  /// **'Total eligible voters on list: {total}'**
  String adminDemographicsTotalEligible(Object total);

  /// No description provided for @adminDemographicsYouth.
  ///
  /// In en, this message translates to:
  /// **'Youth'**
  String get adminDemographicsYouth;

  /// No description provided for @adminDemographicsAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get adminDemographicsAdult;

  /// No description provided for @adminDemographicsSenior.
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get adminDemographicsSenior;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
