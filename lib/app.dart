import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import 'core/l10n/app_locales.dart';
import 'core/routing/app_router.dart';
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
        return MediaQuery(
          data: media.copyWith(textScaler: clampedScaler),
          child: BackSwipe(child: _NotificationToastListener(child: child)),
        );
      },
      routerConfig: router,
    );
  }
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
