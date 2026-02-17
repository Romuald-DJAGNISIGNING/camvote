import 'package:flutter/material.dart';

import 'package:camvote/gen/l10n/app_localizations.dart';
import '../../config/app_config.dart';
import '../../motion/cam_motion.dart';
import '../../utils/external_links.dart';
import '../../utils/mobile_links.dart';
import '../qr/branded_qr_code.dart';
import '../../network/platform_utils.dart'
    if (dart.library.io) '../../network/platform_utils_io.dart';

class AppDownloadCard extends StatelessWidget {
  const AppDownloadCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isWebPlatform || !AppConfig.hasStoreLinks) {
      return const SizedBox.shrink();
    }

    final t = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final playUrl = AppConfig.playStoreUrl.trim();
    final mobileFeaturesUrl = _normalizeStaticWebUrl(
      AppConfig.mobileFeaturesUrl.trim(),
    );
    final appUrl = _decorateAppStoreUrl(
      _resolveIosComingSoonUrl(
        _normalizeStaticWebUrl(AppConfig.appStoreUrl.trim()),
      ),
      languageCode,
    );
    final actions = _resolveActions(playUrl, appUrl);
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }
    final cs = Theme.of(context).colorScheme;

    final showQr = isDesktopWeb && actions.isNotEmpty;
    final showLearnMore = mobileFeaturesUrl.isNotEmpty;
    final learnMoreUrl = showLearnMore
        ? _buildLearnMoreUrl(mobileFeaturesUrl, languageCode, playUrl, appUrl)
        : '';
    final qrUrl = showQr
        ? buildSmartDownloadUrl(
            baseUrl: mobileFeaturesUrl,
            languageCode: languageCode,
            playUrl: playUrl,
            appUrl: appUrl,
            androidDeepLink: AppConfig.androidDeepLink,
            iosDeepLink: AppConfig.iosDeepLink,
            iosLive: AppConfig.iosAppLive,
          )
        : '';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface.withAlpha(250),
              cs.surfaceContainerHighest.withAlpha(120),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF2B705),
                    Color(0xFFD9431F),
                    Color(0xFF1F6FEB),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    t.webDownloadAppTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.webDownloadAppSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.center,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < actions.length; i++)
                          _StoreButton(action: actions[i], primary: i == 0),
                      ],
                    ),
                  ),
                  if (showQr && qrUrl.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.center,
                      child: _QrPanel(url: qrUrl),
                    ),
                  ],
                  if (showLearnMore) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton.icon(
                        onPressed: () => _openExternal(context, learnMoreUrl),
                        icon: const Icon(Icons.info_outline),
                        label: Text(t.webDownloadLearnMore),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_StoreAction> _resolveActions(String playUrl, String appUrl) {
    if (isAndroidWeb) {
      if (playUrl.isNotEmpty) {
        return [_StoreAction.play(playUrl)];
      }
      if (appUrl.isNotEmpty) {
        return [_StoreAction.app(appUrl)];
      }
    }

    if (isIosWeb) {
      if (appUrl.isNotEmpty) {
        return [_StoreAction.app(appUrl)];
      }
      if (playUrl.isNotEmpty) {
        return [_StoreAction.play(playUrl)];
      }
    }

    final actions = <_StoreAction>[];
    if (playUrl.isNotEmpty) {
      actions.add(_StoreAction.play(playUrl));
    }
    if (appUrl.isNotEmpty) {
      actions.add(_StoreAction.app(appUrl));
    }
    return actions;
  }

  String _decorateAppStoreUrl(String url, String languageCode) {
    if (url.isEmpty) return url;
    final uri = Uri.parse(url);
    if (uri.hasScheme) return url;
    final params = Map<String, String>.from(uri.queryParameters);
    if (AppConfig.hasApiBaseUrl) {
      params.putIfAbsent('api', () => AppConfig.apiBaseUrl);
    }
    if (AppConfig.supportEmail.trim().isNotEmpty) {
      params.putIfAbsent('support', () => AppConfig.supportEmail.trim());
    }
    if (languageCode.isNotEmpty) {
      params.putIfAbsent('lang', () => languageCode);
    }
    return uri.replace(queryParameters: params).toString();
  }

  String _buildLearnMoreUrl(
    String baseUrl,
    String languageCode,
    String playUrl,
    String appUrl,
  ) {
    final uri = Uri.parse(baseUrl);
    final params = Map<String, String>.from(uri.queryParameters);
    if (playUrl.isNotEmpty) {
      params['play'] = playUrl;
    }
    if (appUrl.isNotEmpty) {
      params['app'] = appUrl;
    }
    if (languageCode.isNotEmpty) {
      params['lang'] = languageCode;
    }
    if (AppConfig.iosAppLive) {
      params['ios_live'] = '1';
    }
    return uri.replace(queryParameters: params).toString();
  }

  String _resolveIosComingSoonUrl(String configuredUrl) {
    const fallback = '/mobile/app-store/index.html';
    if (!AppConfig.iosAppLive) {
      return fallback;
    }

    final trimmed = configuredUrl.trim();
    if (trimmed.isEmpty) return fallback;

    final uri = Uri.parse(trimmed);
    final path = uri.path.toLowerCase();
    final hasAbsoluteStoreScheme = uri.hasScheme;
    final isComingSoonPath = path.contains('/mobile/app-store');
    if (hasAbsoluteStoreScheme || isComingSoonPath) {
      return _normalizeStaticWebUrl(trimmed);
    }

    return fallback;
  }

  String _normalizeStaticWebUrl(String url) {
    if (url.isEmpty) return url;
    final uri = Uri.parse(url);
    final path = uri.path;
    final hasFileExtension = RegExp(r'\.[A-Za-z0-9]+$').hasMatch(path);
    var normalizedPath = path;

    if (path.endsWith('/')) {
      normalizedPath = '${path}index.html';
    } else if (!hasFileExtension &&
        (path.endsWith('/mobile') || path.endsWith('/app-store'))) {
      normalizedPath = '$path/index.html';
    }

    if (normalizedPath == path) {
      return url;
    }
    return uri.replace(path: normalizedPath).toString();
  }
}

enum _StoreKind { play, app }

class _StoreAction {
  const _StoreAction({
    required this.url,
    required this.labelBuilder,
    required this.icon,
    required this.kind,
  });

  final String url;
  final String Function(AppLocalizations t) labelBuilder;
  final IconData icon;
  final _StoreKind kind;

  factory _StoreAction.play(String url) => _StoreAction(
    url: url,
    labelBuilder: (t) => t.webDownloadPlayStore,
    icon: Icons.play_arrow_rounded,
    kind: _StoreKind.play,
  );

  factory _StoreAction.app(String url) => _StoreAction(
    url: url,
    labelBuilder: (t) => t.webDownloadAppStore,
    icon: Icons.apple,
    kind: _StoreKind.app,
  );
}

class _StoreButton extends StatefulWidget {
  const _StoreButton({required this.action, required this.primary});

  final _StoreAction action;
  final bool primary;

  @override
  State<_StoreButton> createState() => _StoreButtonState();
}

class _StoreButtonState extends State<_StoreButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final label = widget.action.labelBuilder(t);
    final cs = Theme.of(context).colorScheme;
    final isAppStore = widget.action.kind == _StoreKind.app;
    final bg = isAppStore ? Colors.black : cs.surface;
    final fg = isAppStore ? Colors.white : cs.onSurface;
    final border = isAppStore ? Colors.black : cs.outlineVariant;
    final shadow = <BoxShadow>[
      if (widget.primary || _hovered)
        BoxShadow(
          color: Colors.black.withAlpha(_hovered ? 52 : 28),
          blurRadius: _hovered ? 16 : 12,
          offset: Offset(0, _hovered ? 10 : 8),
        ),
    ];

    void handleTap() => _openExternal(context, widget.action.url);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: CamMotion.fast,
        curve: CamMotion.emphasized,
        scale: _hovered ? 1.03 : 1,
        child: InkWell(
          onTap: handleTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: CamMotion.fast,
            curve: CamMotion.emphasized,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
              boxShadow: shadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.action.icon, color: fg, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QrPanel extends StatelessWidget {
  const _QrPanel({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerHighest.withAlpha(90),
            cs.surface.withAlpha(70),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(132)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            t.webDownloadQrTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _QrTile(url: url),
        ],
      ),
    );
  }
}

class _QrTile extends StatefulWidget {
  const _QrTile({required this.url});

  final String url;

  @override
  State<_QrTile> createState() => _QrTileState();
}

class _QrTileState extends State<_QrTile> with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1750),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
    if (disableAnimations == true && _scanController.isAnimating) {
      _scanController.stop();
    } else if (disableAnimations != true && !_scanController.isAnimating) {
      _scanController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations;

    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        final value = _scanController.value;
        final pulse = 1 - (value - 0.5).abs() * 2;

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.surface.withAlpha(242),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withAlpha(128)),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withAlpha((28 + (pulse * 42)).round()),
                blurRadius: 10 + (pulse * 10),
                spreadRadius: pulse * 0.5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  child!,
                  if (disableAnimations != true)
                    Positioned(
                      left: 6,
                      right: 6,
                      top: 8 + (104 * value),
                      child: IgnorePointer(
                        child: Container(
                          height: 2.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0x00FFFFFF),
                                Color(0xFF7FE2FF),
                                Color(0x00FFFFFF),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withAlpha(90),
                                blurRadius: 10,
                                spreadRadius: 0.4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      child: BrandedQrCode(
        data: widget.url,
        size: 120,
        logoScale: 0.16,
        animatedFrame: true,
      ),
    );
  }
}

Future<void> _openExternal(BuildContext context, String url) async {
  final ok = await openExternalLink(context, url, showError: false);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).openLinkFailed)),
    );
  }
}
