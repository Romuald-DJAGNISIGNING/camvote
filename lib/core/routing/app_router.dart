import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../theme/role_theme.dart';
import '../config/app_settings_controller.dart';
import '../widgets/loaders/camvote_pulse_loading.dart';
import 'route_paths.dart';
import 'route_transitions.dart';
import '../motion/route_transitions.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/models/auth_error_codes.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/account_archived_screen.dart';
import '../../features/auth/screens/force_password_change_screen.dart';
import '../../features/auth/screens/voter_web_redirect_screen.dart';

import '../../features/onboarding/screens/role_gateway_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

import '../../features/public_portal/screens/public_home_screen.dart';
import '../../features/public_portal/screens/public_results_screen.dart';
import '../../features/public_portal/screens/public_elections_info_screen.dart';
import '../../features/public_portal/screens/public_verify_registration_screen.dart';
import '../../features/public_portal/screens/public_election_calendar_screen.dart';
import '../../features/public_portal/screens/public_civic_education_screen.dart';
import '../../features/centers/screens/voting_centers_map_screen.dart';
import '../../features/legal/screens/legal_library_screen.dart';
import '../../features/legal/screens/legal_document_screen.dart';
import '../../features/legal/models/legal_document.dart';

import '../../features/voter_portal/screens/voter_shell.dart';
import '../../features/voter_portal/screens/voter_pending_verification_screen.dart';
import '../../features/voter_portal/screens/voter_card_screen.dart';
import '../../features/voter_portal/screens/voter_receipt_screen.dart';
import '../../features/voter_portal/screens/voter_countdowns_screen.dart';
import '../../features/voter_portal/domain/vote_receipt.dart';

import '../../features/dashboards/screens/admin_dashboard_screen.dart';
import '../../features/dashboards/screens/admin_elections_screen.dart';
import '../../features/dashboards/screens/admin_voters_screen.dart';
import '../../features/dashboards/screens/admin_observers_screen.dart';
import '../../features/dashboards/screens/admin_audit_logs_screen.dart';
import '../../features/dashboards/screens/admin_fraud_monitor_screen.dart';
import '../../features/dashboards/screens/admin_security_screen.dart';
import '../../features/dashboards/screens/admin_incidents_overview_screen.dart';
import '../../features/dashboards/screens/admin_results_publish_screen.dart';
import '../../features/dashboards/screens/admin_content_seed_screen.dart';
import '../../features/centers/screens/admin_voting_centers_screen.dart';

import '../../features/dashboards/screens/observer_dashboard_screen.dart';
import '../../features/incidents/screens/observer_incident_report_screen.dart';
import '../../features/dashboards/screens/observer_incident_tracker_screen.dart';
import '../../features/dashboards/screens/observer_transparency_feed_screen.dart';
import '../../features/dashboards/screens/observer_checklist_screen.dart';

import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/account_delete_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/about_me/screens/about_me_screen.dart';
import '../../features/support/screens/admin_support_tickets_screen.dart';
import '../../features/support/screens/help_support_screen.dart';

import '../../features/registration/screens/registration_hub_screen.dart';
import '../../features/registration/screens/voter_registration_draft_screen.dart';
import '../../features/registration/screens/voter_document_ocr_screen.dart';
import '../../features/registration/screens/voter_biometric_enrollment_screen.dart';
import '../../features/registration/domain/registration_identity.dart';
import '../../features/registration/domain/registration_review_payload.dart';
import '../../features/registration/screens/voter_registration_review_screen.dart';
import '../../features/registration/screens/voter_registration_submitted_screen.dart';
import '../../features/registration/models/registration_submission_result.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authControllerProvider);
  final auth = authAsync.asData?.value;
  final authed = auth?.isAuthenticated ?? false;
  final settingsAsync = ref.watch(appSettingsProvider);
  final settings = settingsAsync.asData?.value;
  final isBootstrapping = authAsync.isLoading || settingsAsync.isLoading;
  final hasSeenOnboarding = settings?.hasSeenOnboarding ?? false;

  Widget portalEntry(Widget child) {
    return isBootstrapping ? const _PortalEntryLoadingScreen() : child;
  }

  final initialLocation = _resolveInitialLocation();

  return GoRouter(
    initialLocation: initialLocation,
    debugLogDiagnostics: kDebugMode,
    errorPageBuilder: (context, state) {
      final t = AppLocalizations.of(context);
      final message = state.error?.toString().trim();
      return MaterialPage<void>(
        key: state.pageKey,
        child: _RouterErrorScreen(
          message: (message == null || message.isEmpty)
              ? t.genericErrorLabel
              : message,
        ),
      );
    },
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isWeb = kIsWeb;

      if (isBootstrapping) return null;

      if (!hasSeenOnboarding && loc != RoutePaths.onboarding) {
        return RoutePaths.onboarding;
      }

      if (auth?.errorCode == AuthErrorCodes.accountArchived &&
          loc != RoutePaths.authArchived) {
        return RoutePaths.authArchived;
      }

      final mustChangePassword =
          authed && auth?.user?.mustChangePassword == true;
      final isForcePasswordRoute = loc == RoutePaths.authForcePasswordChange;
      if (mustChangePassword && !isForcePasswordRoute) {
        return RoutePaths.authForcePasswordChange;
      }
      if (!mustChangePassword &&
          isForcePasswordRoute &&
          authed &&
          auth?.user != null) {
        return _homeForRole(auth!.user!.role);
      }

      final isWebPortalRoute = loc == RoutePaths.webPortal;
      final isAdminPortalRoute = loc == RoutePaths.adminPortal;
      final isPortalEntryRoute = isWebPortalRoute || isAdminPortalRoute;

      final isAdminRoute = loc.startsWith(RoutePaths.adminDashboard);
      final isProtectedAdminRoute = isAdminRoute;
      final isObserverRoute = loc.startsWith(RoutePaths.observerDashboard);
      final isVoterWebRedirect = loc == RoutePaths.voterWebRedirect;
      final isVoterRoute =
          loc.startsWith(RoutePaths.voterShell) && !isVoterWebRedirect;
      final isVoterPendingRoute = loc == RoutePaths.voterPending;
      final isRegistrationRoute = loc.startsWith(RoutePaths.register);
      final isAuthRoute =
          loc.startsWith(RoutePaths.authLogin) ||
          loc.startsWith(RoutePaths.authForgot) ||
          loc.startsWith(RoutePaths.authForcePasswordChange);
      final loginRole = state.uri.queryParameters['role'];
      final requestedLoginRole = AppRoleX.fromApi(loginRole);
      final userRole = auth?.user?.role;
      final voterUnverified =
          authed &&
          auth?.user?.role == AppRole.voter &&
          auth?.user?.verified == false;

      if (!isWeb && isPortalEntryRoute) {
        return RoutePaths.gateway;
      }

      if (isWeb &&
          loc.startsWith(RoutePaths.authLogin) &&
          requestedLoginRole == AppRole.voter) {
        return RoutePaths.webPortal;
      }

      if (isWeb &&
          (isVoterWebRedirect || isVoterRoute || isRegistrationRoute)) {
        return RoutePaths.webPortal;
      }

      if (!isWeb && (isAdminRoute || isObserverRoute)) {
        return RoutePaths.gateway;
      }

      if (!authed && isProtectedAdminRoute) {
        return RoutePaths.adminPortal;
      }
      if (!authed && (isObserverRoute || isVoterRoute)) {
        final targetRole = isObserverRoute ? AppRole.observer : AppRole.voter;
        return '${RoutePaths.authLogin}?role=${targetRole.apiValue}';
      }
      if (!authed && isForcePasswordRoute) {
        return '${RoutePaths.authLogin}?role=voter';
      }

      if (isProtectedAdminRoute && userRole != AppRole.admin) {
        return isWeb ? RoutePaths.adminPortal : RoutePaths.gateway;
      }
      if (isObserverRoute &&
          userRole != AppRole.observer &&
          userRole != AppRole.admin) {
        return isWeb ? RoutePaths.webPortal : RoutePaths.gateway;
      }
      if (isVoterRoute && userRole != AppRole.voter) {
        return isWeb ? RoutePaths.webPortal : RoutePaths.gateway;
      }

      if (voterUnverified && isVoterRoute && !isVoterPendingRoute) {
        return RoutePaths.voterPending;
      }
      if (authed &&
          auth?.user?.role == AppRole.voter &&
          auth?.user?.verified == true &&
          isVoterPendingRoute) {
        return RoutePaths.voterShell;
      }

      final user = auth?.user;
      if (authed && isAuthRoute && user != null) {
        final isRoleSwitchLoginRequest =
            loc.startsWith(RoutePaths.authLogin) &&
            requestedLoginRole != null &&
            requestedLoginRole != user.role;
        if (isRoleSwitchLoginRequest) {
          return null;
        }

        if (user.role == AppRole.voter) {
          if (isWeb) {
            return RoutePaths.webPortal;
          }
          if (!user.verified) {
            return RoutePaths.voterPending;
          }
        }
        return _homeForRole(user.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.gateway,
        pageBuilder: (context, state) => RouteTransitions.fadeSlide(
          state: state,
          child: portalEntry(
            kIsWeb
                ? const RoleGatewayScreen(isGeneralWebPortal: true)
                : const RoleGatewayScreen(),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.webPortal,
        pageBuilder: (context, state) => RouteTransitions.fadeSlide(
          state: state,
          child: portalEntry(const RoleGatewayScreen(isGeneralWebPortal: true)),
        ),
      ),
      GoRoute(
        path: RoutePaths.adminPortal,
        pageBuilder: (context, state) => RouteTransitions.fadeSlide(
          state: state,
          child: portalEntry(const RoleGatewayScreen(adminOnly: true)),
        ),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const OnboardingScreen(),
          transition: CamRouteTransition.fadeThrough,
        ),
      ),

      // Auth
      GoRoute(
        path: RoutePaths.authLogin,
        builder: (context, state) {
          final roleParam = state.uri.queryParameters['role'];
          final roleFromParam =
              AppRoleX.fromApi(roleParam) ??
              (kIsWeb ? AppRole.observer : AppRole.voter);
          return LoginScreen(role: roleFromParam);
        },
      ),
      GoRoute(
        path: RoutePaths.authArchived,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AccountArchivedScreen(),
          transition: CamRouteTransition.fadeThrough,
        ),
      ),
      GoRoute(
        path: RoutePaths.authForgot,
        builder: (context, state) {
          final roleParam = state.uri.queryParameters['role'];
          return ForgotPasswordScreen(role: AppRoleX.fromApi(roleParam));
        },
      ),
      GoRoute(
        path: RoutePaths.authForcePasswordChange,
        builder: (context, state) => const ForcePasswordChangeScreen(),
      ),

      // Public
      GoRoute(
        path: RoutePaths.publicHome,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const PublicHomeScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.publicResults,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const PublicResultsScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.publicElectionsInfo,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const PublicElectionsInfoScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.publicElectionCalendar,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const PublicElectionCalendarScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.publicCivicEducation,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const PublicCivicEducationScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.publicVerifyRegistration,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const PublicVerifyRegistrationScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.publicVotingCenters,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: state.extra is VotingCentersMapArgs
              ? VotingCentersMapScreen(
                  selectMode: (state.extra as VotingCentersMapArgs).selectMode,
                  selectedCenter:
                      (state.extra as VotingCentersMapArgs).selectedCenter,
                )
              : const VotingCentersMapScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.legalLibrary,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const LegalLibraryScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.legalDocument,
        pageBuilder: (context, state) {
          final extra = state.extra;
          if (extra is LegalDocument) {
            return CamRouteTransitions.page(
              state: state,
              child: LegalDocumentScreen(document: extra),
              transition: CamRouteTransition.fadeSlide,
            );
          }
          final t = AppLocalizations.of(context);
          return CamRouteTransitions.page(
            state: state,
            child: Scaffold(body: Center(child: Text(t.missingDocumentData))),
            transition: CamRouteTransition.fadeSlide,
          );
        },
      ),

      // Role portals
      GoRoute(
        path: RoutePaths.voterWebRedirect,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const VoterWebRedirectScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.voterShell,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const VoterShell(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.voterPending,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const VoterPendingVerificationScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.voterCard,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const VoterCardScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.voterCountdowns,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const VoterCountdownsScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.voterReceipt,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is VoteReceipt) {
            return VoterReceiptScreen(receipt: extra);
          }
          final t = AppLocalizations.of(context);
          return Scaffold(body: Center(child: Text(t.missingReceiptData)));
        },
      ),
      GoRoute(
        path: RoutePaths.observerDashboard,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const ObserverDashboardScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.observerIncidentTracker,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const ObserverIncidentTrackerScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.observerIncidentReport,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const ObserverIncidentReportScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.observerAudit,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminAuditLogsScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.observerTransparency,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const ObserverTransparencyFeedScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.observerChecklist,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const ObserverChecklistScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.adminDashboard,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminDashboardScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.adminRoleHub,
        pageBuilder: (context, state) => RouteTransitions.fadeSlide(
          state: state,
          child: portalEntry(const RoleGatewayScreen(adminOnly: true)),
        ),
      ),
      GoRoute(
        path: RoutePaths.adminElections,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminElectionsScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.adminVoters,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminVotersScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.adminObservers,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminObserversScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.adminAudit,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminAuditLogsScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.adminFraudMonitor,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminFraudMonitorScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.adminSecurity,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminSecurityScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.adminIncidents,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminIncidentsOverviewScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.adminResultsPublish,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminResultsPublishScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.adminVotingCenters,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminVotingCentersScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.adminContentSeed,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminContentSeedScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.adminSupport,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const AdminSupportTicketsScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      //Registration
      GoRoute(
        path: RoutePaths.register,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const RegistrationHubScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),
      GoRoute(
        path: RoutePaths.registerVoter,
        pageBuilder: (context, state) => CamRouteTransitions.page(
          state: state,
          child: const VoterRegistrationDraftScreen(),
          transition: CamRouteTransition.fadeSlide,
        ),
      ),

      // Common
      GoRoute(
        path: RoutePaths.settings,
        pageBuilder: (context, state) => RouteTransitions.fadeSlide(
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.accountDelete,
        pageBuilder: (context, state) => RouteTransitions.fadeSlide(
          state: state,
          child: const AccountDeleteScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.voterDocumentOcr,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is RegistrationIdentity) {
            return VoterDocumentOcrScreen(expected: extra);
          }
          final t = AppLocalizations.of(context);
          return Scaffold(body: Center(child: Text(t.missingRegistrationData)));
        },
      ),
      GoRoute(
        path: RoutePaths.voterBiometricEnrollment,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is RegistrationReviewPayload) {
            return VoterBiometricEnrollmentScreen(payload: extra);
          }
          return const VoterBiometricEnrollmentScreen();
        },
      ),
      GoRoute(
        path: RoutePaths.voterRegistrationReview,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is RegistrationReviewPayload) {
            return VoterRegistrationReviewScreen(payload: extra);
          }
          final t = AppLocalizations.of(context);
          return Scaffold(body: Center(child: Text(t.missingRegistrationData)));
        },
      ),
      GoRoute(
        path: RoutePaths.voterRegistrationSubmitted,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is RegistrationSubmissionResult) {
            return VoterRegistrationSubmittedScreen(result: extra);
          }
          final t = AppLocalizations.of(context);
          return Scaffold(
            body: Center(child: Text(t.missingSubmissionDetails)),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.notifications,
        pageBuilder: (context, state) => RouteTransitions.fadeSlide(
          state: state,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.about,
        pageBuilder: (context, state) => RouteTransitions.fadeSlide(
          state: state,
          child: const AboutMeScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.helpSupport,
        pageBuilder: (context, state) => RouteTransitions.fadeSlide(
          state: state,
          child: const HelpSupportScreen(),
        ),
      ),
    ],
  );
});

String _homeForRole(AppRole role) {
  return switch (role) {
    AppRole.voter => kIsWeb ? RoutePaths.webPortal : RoutePaths.voterShell,
    AppRole.observer =>
      kIsWeb ? RoutePaths.observerDashboard : RoutePaths.gateway,
    AppRole.admin => kIsWeb ? RoutePaths.adminDashboard : RoutePaths.gateway,
    _ => RoutePaths.publicHome,
  };
}

String _resolveInitialLocation() {
  if (!kIsWeb) return RoutePaths.gateway;

  final base = Uri.base;
  String? candidate;

  final fragment = base.fragment;
  if (fragment.isNotEmpty) {
    candidate = fragment.startsWith('/') ? fragment : '/$fragment';
  } else if (base.path.isNotEmpty && base.path != '/') {
    candidate = base.path;
    if (base.hasQuery) {
      candidate = '$candidate?${base.query}';
    }
  }

  if (candidate == null || candidate.isEmpty) {
    return RoutePaths.gateway;
  }

  return candidate;
}

class _PortalEntryLoadingScreen extends StatelessWidget {
  const _PortalEntryLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return CamVoteLoadingScreen(title: t.loading, subtitle: t.slogan);
  }
}

class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    t.genericErrorLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go(
                      kIsWeb ? RoutePaths.webPortal : RoutePaths.gateway,
                    ),
                    child: Text(t.publicPortalTitle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
