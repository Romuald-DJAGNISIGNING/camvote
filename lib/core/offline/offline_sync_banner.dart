import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../routing/route_paths.dart';
import '../theme/role_theme.dart';
import '../widgets/feedback/cam_toast.dart';
import 'offline_status_providers.dart';
import 'offline_sync_providers.dart';

class GlobalOfflineSyncBanner extends ConsumerStatefulWidget {
  const GlobalOfflineSyncBanner({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<GlobalOfflineSyncBanner> createState() =>
      _GlobalOfflineSyncBannerState();
}

class _GlobalOfflineSyncBannerState extends ConsumerState<GlobalOfflineSyncBanner> {
  bool _hiddenForSession = false;
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    if (_hiddenForSession) return widget.child;

    final t = AppLocalizations.of(context);
    final offline = ref.watch(isOfflineProvider);
    final role = ref.watch(currentRoleProvider);
    final pendingCount =
        ref.watch(pendingOfflineQueueTotalProvider).asData?.value ?? 0;

    final shouldShow = offline || pendingCount > 0;
    if (!shouldShow) return widget.child;

    // Never overlay the onboarding UI.
    final routePath = _safeRoutePath(context);
    if (routePath.startsWith(RoutePaths.onboarding)) {
      return widget.child;
    }

    final title = offline ? t.offlineBannerOfflineTitle : t.offlineBannerPendingTitle;
    final body = offline
        ? (pendingCount > 0
            ? t.offlineBannerOfflineBodyCount(pendingCount)
            : t.offlineBannerOfflineBody)
        : t.offlineBannerPendingBodyCount(pendingCount);
    final hint = offline ? _hintForRole(t, role) : '';

    final banner = SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Material(
          elevation: 8,
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withAlpha(230),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withAlpha(120),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(35),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    offline ? Icons.cloud_off_outlined : Icons.cloud_sync_outlined,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(body, style: Theme.of(context).textTheme.bodySmall),
                        if (hint.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            hint,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                        if (!offline && pendingCount > 0) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              onPressed: _syncing ? null : () => _syncNow(context),
                              icon: _syncing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.sync),
                              label: Text(t.offlineBannerSyncNow),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: t.close,
                    onPressed: () => setState(() => _hiddenForSession = true),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(bottom: 0, left: 0, right: 0, child: Center(child: banner)),
      ],
    );
  }

  String _safeRoutePath(BuildContext context) {
    try {
      final uri = GoRouterState.of(context).uri;
      return uri.path.isEmpty ? RoutePaths.gateway : uri.path;
    } catch (_) {
      return Uri.base.path;
    }
  }

  Future<void> _syncNow(BuildContext context) async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      final flushed = await ref
          .read(offlineSyncServiceProvider)
          .flushPending(maxItems: 20);
      if (!context.mounted) return;
      final t = AppLocalizations.of(context);
      CamToast.show(
        context,
        message: t.offlineBannerSyncedCount(flushed),
        type: flushed > 0 ? CamToastType.success : CamToastType.info,
      );
      ref.invalidate(pendingOfflineQueueTotalProvider);
    } catch (e) {
      if (!context.mounted) return;
      CamToast.show(context, message: e.toString(), type: CamToastType.error);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  String _hintForRole(AppLocalizations t, AppRole role) {
    return switch (role) {
      AppRole.admin => t.offlineBannerHintAdmin,
      AppRole.observer => t.offlineBannerHintObserver,
      AppRole.voter => t.offlineBannerHintVoter,
      AppRole.public => t.offlineBannerHintPublic,
    };
  }
}
