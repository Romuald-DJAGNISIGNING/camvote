import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:camvote/gen/l10n/app_localizations.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/branding/brand_logo.dart';
import '../../../core/config/app_config.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/network/platform_utils.dart'
    if (dart.library.io) '../../../core/network/platform_utils_io.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/external_links.dart';
import '../../../core/utils/mobile_links.dart';
import '../../../core/widgets/marketing/app_download_card.dart';

class VoterWebRedirectScreen extends ConsumerStatefulWidget {
  const VoterWebRedirectScreen({super.key});

  @override
  ConsumerState<VoterWebRedirectScreen> createState() =>
      _VoterWebRedirectScreenState();
}

class _VoterWebRedirectScreenState
    extends ConsumerState<VoterWebRedirectScreen> {
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRedirect());
    }
  }

  void _maybeRedirect() {
    if (_attempted) return;
    _attempted = true;
    if (!isMobileWeb) return;
    final url = _smartDownloadUrl();
    if (url.isEmpty) return;
    openWebRedirect(url);
  }

  String _smartDownloadUrl() {
    final lang = Localizations.localeOf(context).languageCode;
    final featuresUrl = _normalizeStaticWebUrl(
      AppConfig.mobileFeaturesUrl.trim(),
    );
    final play = AppConfig.playStoreUrl.trim();
    final app = _resolveIosComingSoonUrl(
      _normalizeStaticWebUrl(AppConfig.appStoreUrl.trim()),
    );
    return buildSmartDownloadUrl(
      baseUrl: featuresUrl,
      languageCode: lang,
      playUrl: play,
      appUrl: app,
      androidDeepLink: AppConfig.androidDeepLink,
      iosDeepLink: AppConfig.iosDeepLink,
      iosLive: AppConfig.iosAppLive,
    );
  }

  Future<void> _openUrl(String url) async {
    await openExternalLink(context, url);
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final playUrl = AppConfig.playStoreUrl.trim();
    final appUrl = _resolveIosComingSoonUrl(
      _normalizeStaticWebUrl(AppConfig.appStoreUrl.trim()),
    );
    final showPlay = playUrl.isNotEmpty && (!isIosWeb);
    final showApp = appUrl.isNotEmpty && (!isAndroidWeb);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CamVoteLogo(size: 26),
            const SizedBox(width: 8),
            Text(t.modeVoterTitle),
          ],
        ),
      ),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 12),
              BrandHeader(
                title: t.webDownloadAppTitle,
                subtitle: t.webDownloadAppSubtitle,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.modeVoterSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          if (showPlay)
                            FilledButton.icon(
                              onPressed: () => _openUrl(playUrl),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(t.webDownloadPlayStore),
                            ),
                          if (showApp)
                            FilledButton.tonalIcon(
                              onPressed: () => _openUrl(appUrl),
                              icon: const Icon(Icons.apple),
                              label: Text(t.webDownloadAppStore),
                            ),
                          if (isMobileWeb)
                            OutlinedButton(
                              onPressed: () => _openUrl(_smartDownloadUrl()),
                              child: Text(t.webDownloadLearnMore),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isDesktopWeb) ...[
                const SizedBox(height: 12),
                const AppDownloadCard(),
              ],
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => context.go(RoutePaths.publicHome),
                icon: const Icon(Icons.public),
                label: Text(t.publicPortalTitle),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
