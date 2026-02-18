import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import 'core/l10n/app_locales.dart';
import 'core/branding/brand_logo.dart';
import 'core/branding/brand_palette.dart';
import 'core/offline/offline_sync_providers.dart';
import 'core/offline/offline_sync_banner.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_paths.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_style.dart';
import 'core/theme/role_theme.dart';
import 'core/config/app_settings_controller.dart';
import 'core/widgets/feedback/cam_toast.dart';
import 'core/widgets/navigation/back_swipe.dart';
import 'core/web/tab_close_guard.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/notifications/domain/cam_notification.dart';
import 'features/notifications/providers/notifications_providers.dart';
import 'features/notifications/widgets/notification_bell.dart';

const _defaultAppSettings = AppSettingsState(
  themeMode: ThemeMode.system,
  themeStyle: AppThemeStyle.classic,
  locale: Locale('en'),
  hasSeenOnboarding: false,
);

class CamVoteApp extends ConsumerWidget {
  const CamVoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(offlineSyncBootstrapProvider);
    final settingsAsync = ref.watch(appSettingsProvider);
    final settings = settingsAsync.asData?.value ?? _defaultAppSettings;
    final auth = ref.watch(authControllerProvider).asData?.value;
    final router = ref.watch(appRouterProvider);
    final role = ref.watch(currentRoleProvider);
    if (kIsWeb) {
      final shouldWarnOnClose =
          auth?.isAuthenticated == true &&
          (auth?.user?.role == AppRole.admin ||
              auth?.user?.role == AppRole.observer);
      setTabCloseWarningEnabled(shouldWarnOnClose);
    }
    final theme = AppTheme.build(
      role: role,
      mode: settings.themeMode,
      style: settings.themeStyle,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: settings.themeMode,
      locale: AppLocales.resolve(settings.locale),
      localeResolutionCallback: AppLocales.resolveFromPlatform,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final clampedScaler = media.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.05,
        );
        final appChild = BackSwipe(
          child: _NotificationToastListener(child: child),
        );
        final routedChild = kIsWeb ? _WebActionDock(child: appChild) : appChild;
        return MediaQuery(
          data: media.copyWith(textScaler: clampedScaler),
          child: GlobalOfflineSyncBanner(
            child: _GlobalCamGuideLauncher(child: routedChild),
          ),
        );
      },
      routerConfig: router,
    );
  }
}

class _GlobalCamGuideLauncher extends ConsumerWidget {
  const _GlobalCamGuideLauncher({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final auth = ref.watch(authControllerProvider).asData?.value;
    return ValueListenableBuilder<RouteInformation>(
      valueListenable: router.routeInformationProvider,
      builder: (context, routeInformation, _) {
        final routeFromRouter = _routeContextFromUri(routeInformation.uri);
        final routeFromBrowser = _routeContextFromUri(Uri.base);
        final route = _mergeRouteContext(routeFromRouter, routeFromBrowser);
        // On some mobile browsers, `Uri.base` can lag behind router state after
        // navigation (especially around onboarding redirects). Only trust the
        // merged route context so action overlays do not disappear until refresh.
        final hideForOnboarding = _isOnboardingOverlayContext(route);
        if (hideForOnboarding || _hideLauncherOnRoute(route.path)) {
          return child;
        }

        final t = AppLocalizations.of(context);
        final entry = _resolveActionEntryForRoute(route: route, auth: auth);
        final target = _routeWithEntry(RoutePaths.camGuide, entry);
        final viewport = MediaQuery.of(context).size;
        final dockMetrics = kIsWeb
            ? _WebDockMetrics.fromWidth(viewport.width)
            : null;
        final metrics = _CamGuideLauncherMetrics.fromViewport(
          viewport: viewport,
          webDockMetrics: dockMetrics,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            Positioned(
              right: metrics.right,
              left: metrics.left,
              bottom: metrics.bottom,
              child: SafeArea(
                minimum: metrics.safeAreaInsets,
                child: Align(
                  alignment: metrics.alignment,
                  child: Semantics(
                    button: true,
                    label: t.helpSupportAiTitle,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => router.push(target),
                        borderRadius: BorderRadius.circular(999),
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: BrandPalette.heroGradient,
                            border: Border.all(
                              color: Colors.white.withAlpha(120),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: BrandPalette.ember.withAlpha(75),
                                blurRadius: 24,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: metrics.padding,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DecoratedBox(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: CamVoteLogo(size: metrics.logoSize),
                                  ),
                                ),
                                if (!metrics.compact) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    'CamGuide',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _hideLauncherOnRoute(String path) {
    final normalized = path.isEmpty ? RoutePaths.gateway : path;
    return normalized.startsWith(RoutePaths.onboarding) ||
        normalized.startsWith(RoutePaths.authLogin) ||
        normalized.startsWith(RoutePaths.authForgot) ||
        normalized.startsWith(RoutePaths.authArchived) ||
        normalized.startsWith(RoutePaths.authForcePasswordChange) ||
        normalized.startsWith(RoutePaths.helpSupport) ||
        normalized.startsWith(RoutePaths.camGuide);
  }
}

class _WebActionDock extends ConsumerWidget {
  const _WebActionDock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final auth = ref.watch(authControllerProvider).asData?.value;
    return ValueListenableBuilder<RouteInformation>(
      valueListenable: router.routeInformationProvider,
      builder: (context, routeInformation, _) {
        final routeFromRouter = _routeContextFromUri(routeInformation.uri);
        final routeFromBrowser = _routeContextFromUri(Uri.base);
        final route = _mergeRouteContext(routeFromRouter, routeFromBrowser);
        // See _GlobalCamGuideLauncher: keep overlays stable on mobile browsers.
        final hideForOnboarding = _isOnboardingOverlayContext(route);
        if (hideForOnboarding || _hideDockOnRoute(route.path)) {
          return child;
        }

        final actionEntry = _resolveActionEntryForRoute(
          route: route,
          auth: auth,
        );
        final isAdminAuthed =
            auth?.isAuthenticated == true && auth?.user?.role == AppRole.admin;
        final showAdminShortcut =
            isAdminAuthed && !route.path.startsWith(RoutePaths.adminDashboard);
        final showBell = route.path != RoutePaths.notifications;
        final needsTopClearance = _needsTopClearance(route.path);
        final dockMetrics = _WebDockMetrics.fromWidth(
          MediaQuery.of(context).size.width,
        );
        final iconButtonStyle = dockMetrics.compact
            ? IconButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                iconSize: 19,
                minimumSize: const Size(34, 34),
                padding: const EdgeInsets.all(7),
              )
            : null;
        final dock = SafeArea(
          minimum: dockMetrics.safeAreaInsets,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withAlpha(180),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withAlpha(90),
              ),
            ),
            child: Padding(
              padding: dockMetrics.innerPadding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBell)
                    NotificationBell(
                      showTooltip: false,
                      compact: dockMetrics.compact,
                      onOpen: () {
                        router.push(
                          _routeWithEntry(
                            RoutePaths.notifications,
                            actionEntry,
                          ),
                        );
                      },
                    ),
                  IconButton(
                    style: iconButtonStyle,
                    onPressed: () {
                      router.push(
                        _routeWithEntry(RoutePaths.settings, actionEntry),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined),
                  ),
                  if (showAdminShortcut)
                    IconButton(
                      style: iconButtonStyle,
                      onPressed: () => router.go(RoutePaths.adminDashboard),
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                    ),
                ],
              ),
            ),
          ),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: needsTopClearance ? dockMetrics.contentTopInset : 0,
              ),
              child: child,
            ),
            Positioned(top: 0, right: 0, child: dock),
          ],
        );
      },
    );
  }

  bool _hideDockOnRoute(String path) {
    final normalized = path.isEmpty ? RoutePaths.gateway : path;
    return normalized.startsWith(RoutePaths.onboarding) ||
        normalized.startsWith(RoutePaths.camGuide) ||
        normalized.startsWith(RoutePaths.authForgot) ||
        normalized.startsWith(RoutePaths.authArchived) ||
        normalized.startsWith(RoutePaths.authForcePasswordChange);
  }

  bool _needsTopClearance(String path) {
    final normalized = path.isEmpty ? RoutePaths.gateway : path;
    return normalized == RoutePaths.webPortal ||
        normalized == RoutePaths.adminPortal ||
        normalized == RoutePaths.publicHome ||
        normalized.startsWith(RoutePaths.authLogin);
  }
}

class _WebDockMetrics {
  const _WebDockMetrics({
    required this.compact,
    required this.contentTopInset,
    required this.safeAreaInsets,
    required this.innerPadding,
    required this.estimatedOuterHeight,
  });

  final bool compact;
  final double contentTopInset;
  final EdgeInsets safeAreaInsets;
  final EdgeInsets innerPadding;
  final double estimatedOuterHeight;

  factory _WebDockMetrics.fromWidth(double width) {
    if (width < 760) {
      return const _WebDockMetrics(
        compact: true,
        contentTopInset: 54,
        safeAreaInsets: EdgeInsets.fromLTRB(8, 8, 8, 10),
        innerPadding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        estimatedOuterHeight: 58,
      );
    }
    if (width < 1280) {
      return const _WebDockMetrics(
        compact: true,
        contentTopInset: 50,
        safeAreaInsets: EdgeInsets.fromLTRB(8, 8, 8, 8),
        innerPadding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        estimatedOuterHeight: 56,
      );
    }
    return const _WebDockMetrics(
      compact: false,
      contentTopInset: 0,
      safeAreaInsets: EdgeInsets.fromLTRB(8, 8, 8, 8),
      innerPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      estimatedOuterHeight: 58,
    );
  }
}

class _CamGuideLauncherMetrics {
  const _CamGuideLauncherMetrics({
    required this.compact,
    required this.alignment,
    required this.safeAreaInsets,
    required this.padding,
    required this.logoSize,
    required this.left,
    required this.right,
    required this.bottom,
  });

  final bool compact;
  final Alignment alignment;
  final EdgeInsets safeAreaInsets;
  final EdgeInsets padding;
  final double logoSize;
  final double? left;
  final double? right;
  final double bottom;

  factory _CamGuideLauncherMetrics.fromViewport({
    required Size viewport,
    _WebDockMetrics? webDockMetrics,
  }) {
    final width = viewport.width;
    if (kIsWeb) {
      final compact = width < 940;
      final dockMetrics = webDockMetrics ?? _WebDockMetrics.fromWidth(width);
      final moveToLeft =
          width < 620 ||
          _isVerticalSpaceTight(viewport: viewport, dockMetrics: dockMetrics);
      return _CamGuideLauncherMetrics(
        compact: compact,
        alignment: moveToLeft ? Alignment.bottomLeft : Alignment.bottomRight,
        safeAreaInsets: moveToLeft
            ? const EdgeInsets.fromLTRB(10, 8, 8, 10)
            : const EdgeInsets.fromLTRB(8, 8, 10, 10),
        padding: compact
            ? const EdgeInsets.all(8)
            : const EdgeInsets.fromLTRB(8, 6, 14, 6),
        logoSize: compact ? 24 : 26,
        left: moveToLeft ? 0 : null,
        right: moveToLeft ? null : 0,
        bottom: 0,
      );
    }
    final compact = width < 420;
    return _CamGuideLauncherMetrics(
      compact: compact,
      alignment: Alignment.bottomLeft,
      safeAreaInsets: const EdgeInsets.fromLTRB(10, 8, 8, 10),
      padding: compact
          ? const EdgeInsets.all(8)
          : const EdgeInsets.fromLTRB(8, 6, 14, 6),
      logoSize: compact ? 24 : 26,
      left: 0,
      right: null,
      bottom: 0,
    );
  }

  static bool _isVerticalSpaceTight({
    required Size viewport,
    required _WebDockMetrics dockMetrics,
  }) {
    const launcherHeight = 52.0;
    const minGap = 24.0;
    final availableGap =
        viewport.height - dockMetrics.estimatedOuterHeight - launcherHeight;
    return availableGap < minGap;
  }
}

String _routeWithEntry(String path, String entry) {
  final separator = path.contains('?') ? '&' : '?';
  return '$path${separator}entry=$entry';
}

String _resolveActionEntryForRoute({
  required _RouteContext route,
  required AuthState? auth,
}) {
  if (route.entry == 'admin' || route.entry == 'general') {
    return route.entry!;
  }
  if (route.path == RoutePaths.adminPortal ||
      route.path.startsWith(RoutePaths.adminDashboard)) {
    return 'admin';
  }
  if (route.path.startsWith(RoutePaths.authLogin) && route.role == 'admin') {
    return 'admin';
  }
  if (auth?.isAuthenticated == true && auth?.user?.role == AppRole.admin) {
    return 'admin';
  }
  return 'general';
}

_RouteContext _routeContextFromUri(Uri uri) {
  final fragment = uri.fragment;
  if (fragment.isNotEmpty) {
    final normalized = fragment.startsWith('/') ? fragment : '/$fragment';
    final parsed = Uri.tryParse(normalized);
    if (parsed != null) {
      return _RouteContext(
        path: parsed.path.isEmpty ? RoutePaths.gateway : parsed.path,
        entry: parsed.queryParameters['entry'],
        role: parsed.queryParameters['role'],
        revisit: parsed.queryParameters['revisit'],
      );
    }
  }

  return _RouteContext(
    path: uri.path.isEmpty ? RoutePaths.gateway : uri.path,
    entry: uri.queryParameters['entry'],
    role: uri.queryParameters['role'],
    revisit: uri.queryParameters['revisit'],
  );
}

_RouteContext _mergeRouteContext(
  _RouteContext routeFromRouter,
  _RouteContext routeFromBrowser,
) {
  final routerPath = routeFromRouter.path.isEmpty
      ? RoutePaths.gateway
      : routeFromRouter.path;
  final browserPath = routeFromBrowser.path.isEmpty
      ? RoutePaths.gateway
      : routeFromBrowser.path;
  // Prefer router state whenever available; browser URLs can become stale on
  // some mobile WebViews/Safari sessions.
  final path = routerPath != RoutePaths.gateway ? routerPath : browserPath;
  final entry = routeFromRouter.entry ?? routeFromBrowser.entry;
  final role = routeFromRouter.role ?? routeFromBrowser.role;
  final revisit = routeFromRouter.revisit ?? routeFromBrowser.revisit;
  return _RouteContext(path: path, entry: entry, role: role, revisit: revisit);
}

bool _isOnboardingOverlayContext(_RouteContext route) {
  final normalized = route.path.isEmpty ? RoutePaths.gateway : route.path;
  return normalized == RoutePaths.onboarding ||
      normalized.startsWith('${RoutePaths.onboarding}/');
}

class _RouteContext {
  const _RouteContext({
    required this.path,
    required this.entry,
    required this.role,
    required this.revisit,
  });

  final String path;
  final String? entry;
  final String? role;
  final String? revisit;
}

class _NotificationToastListener extends ConsumerStatefulWidget {
  final Widget? child;

  const _NotificationToastListener({required this.child});

  @override
  ConsumerState<_NotificationToastListener> createState() =>
      _NotificationToastListenerState();
}

class _NotificationToastListenerState
    extends ConsumerState<_NotificationToastListener> {
  final Set<String> _seenIds = {};
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<List<CamNotification>>(
      filteredNotificationsProvider,
      (prev, next) {
        if (!mounted) return;

        if (!_ready) {
          _seenIds.addAll(next.map((n) => n.id));
          _ready = true;
          return;
        }

        final newItems = next.where((n) => !_seenIds.contains(n.id)).toList();
        if (newItems.isEmpty) return;

        for (final item in newItems) {
          final message = item.title.isNotEmpty ? item.title : item.body;
          CamToast.show(
            context,
            message: message,
            type: _toastTypeForNotification(item.type),
          );
          _seenIds.add(item.id);
        }
      },
      onError: (error, stackTrace) {
        // Never block app rendering if notifications cache/network fails.
      },
    );

    return widget.child ?? const SizedBox.shrink();
  }
}

CamToastType _toastTypeForNotification(CamNotificationType type) {
  return switch (type) {
    CamNotificationType.info => CamToastType.info,
    CamNotificationType.success => CamToastType.success,
    CamNotificationType.warning => CamToastType.warning,
    CamNotificationType.alert => CamToastType.error,
    CamNotificationType.election => CamToastType.info,
    CamNotificationType.security => CamToastType.warning,
  };
}
