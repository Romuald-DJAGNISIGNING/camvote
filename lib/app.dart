import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import 'core/l10n/app_locales.dart';
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
      locale: settings.locale,
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
        return MediaQuery(
          data: media.copyWith(textScaler: clampedScaler),
          child: kIsWeb ? _WebActionDock(child: appChild) : appChild,
        );
      },
      routerConfig: router,
    );
  }
}

class _WebActionDock extends ConsumerWidget {
  const _WebActionDock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final route = _routeContextOrDefault(context);
      if (_hideDockOnRoute(route.path)) {
        return child;
      }

      final t = Localizations.of<AppLocalizations>(context, AppLocalizations);
      if (t == null) return child;

      final auth = ref.watch(authControllerProvider).asData?.value;
      final isAdminAuthed =
          auth?.isAuthenticated == true && auth?.user?.role == AppRole.admin;
      final isAdminContext =
          route.entry == 'admin' ||
          route.path.startsWith(RoutePaths.adminDashboard) ||
          route.path == RoutePaths.adminPortal;
      final showBell = route.path != RoutePaths.notifications;

      return Stack(
        fit: StackFit.expand,
        children: [
          child,
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(230),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withAlpha(90),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showBell)
                        NotificationBell(
                          onOpen: () {
                            context.push(RoutePaths.notifications);
                          },
                        ),
                      IconButton(
                        tooltip: t.settings,
                        onPressed: () {
                          final entry = isAdminContext ? 'admin' : 'general';
                          context.push('${RoutePaths.settings}?entry=$entry');
                        },
                        icon: const Icon(Icons.settings_outlined),
                      ),
                      if (isAdminAuthed &&
                          !route.path.startsWith(RoutePaths.adminDashboard))
                        IconButton(
                          tooltip: t.modeAdminTitle,
                          onPressed: () =>
                              context.go(RoutePaths.adminDashboard),
                          icon: const Icon(Icons.admin_panel_settings_outlined),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } catch (_) {
      return child;
    }
  }

  bool _hideDockOnRoute(String path) {
    return path == RoutePaths.onboarding ||
        path.startsWith(RoutePaths.authLogin) ||
        path.startsWith(RoutePaths.authForgot) ||
        path.startsWith(RoutePaths.authArchived) ||
        path.startsWith(RoutePaths.authForcePasswordChange);
  }

  _RouteContext _routeContextOrDefault(BuildContext context) {
    try {
      final state = GoRouterState.of(context);
      return _RouteContext(
        path: state.matchedLocation,
        entry: state.uri.queryParameters['entry'],
      );
    } catch (_) {
      return const _RouteContext(path: RoutePaths.gateway, entry: null);
    }
  }
}

class _RouteContext {
  const _RouteContext({required this.path, required this.entry});

  final String path;
  final String? entry;
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
    ref.listen<List<CamNotification>>(filteredNotificationsProvider, (
      prev,
      next,
    ) {
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
    });

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
