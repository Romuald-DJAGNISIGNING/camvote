import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import 'core/l10n/app_locales.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/role_theme.dart';
import 'core/config/app_settings_controller.dart';
import 'core/widgets/feedback/cam_toast.dart';

import 'core/widgets/loaders/cameroon_election_loader.dart';
import 'core/branding/brand_backdrop.dart';
import 'core/branding/brand_logo.dart';
import 'features/notifications/domain/cam_notification.dart';
import 'features/notifications/providers/notifications_providers.dart';


class CamVoteApp extends ConsumerWidget {
  const CamVoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final router = ref.watch(appRouterProvider);
    final role = ref.watch(currentRoleProvider);

    return settingsAsync.when(
      loading: () => const _BootstrapSplash(),
      error: (e, _) => MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocales.supported,
        home: Builder(
          builder: (context) {
            final t = AppLocalizations.of(context);
            return Scaffold(
              body: Center(child: Text('${t.startupError}: $e')),
            );
          },
        ),
      ),
      data: (settings) {
        final theme = AppTheme.build(
          role: role,
          mode: settings.themeMode,
          style: settings.themeStyle,
        );

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'CamVote',
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
              maxScaleFactor: 1.15,
            );
            return MediaQuery(
              data: media.copyWith(textScaler: clampedScaler),
              child: _NotificationToastListener(child: child),
            );
          },
          routerConfig: router,
        );
      },
    );
  }
}

class _BootstrapSplash extends StatelessWidget {
  const _BootstrapSplash();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocales.supported,
      home: Builder(
        builder: (context) {
          final t = AppLocalizations.of(context);
          return Scaffold(
            body: BrandBackdrop(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.92, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, tValue, child) {
                    return Transform.scale(
                      scale: tValue,
                      child: Opacity(
                        opacity: tValue,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CamVoteLogo(showText: true, size: 72),
                      const SizedBox(height: 16),
                      Text(
                        t.slogan,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      const CamElectionLoader(size: 60),
                      const SizedBox(height: 10),
                      Text(t.loading),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationToastListener extends ConsumerStatefulWidget {
  final Widget? child;

  const _NotificationToastListener({required this.child});

  @override
  ConsumerState<_NotificationToastListener> createState() => _NotificationToastListenerState();
}

class _NotificationToastListenerState extends ConsumerState<_NotificationToastListener> {
  final Set<String> _seenIds = {};
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<List<CamNotification>>(filteredNotificationsProvider, (prev, next) {
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
