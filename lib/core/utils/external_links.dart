import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../gen/l10n/app_localizations.dart';

Future<bool> openExternalLink(
  BuildContext context,
  String rawUrl, {
  String? fallbackUrl,
  bool preferSelfOnWeb = false,
  bool showError = true,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final openLinkFailed = AppLocalizations.of(context).openLinkFailed;

  var candidate = rawUrl.trim();
  var backup = fallbackUrl?.trim() ?? '';
  final attempted = <String>{};

  while (candidate.isNotEmpty && !attempted.contains(candidate)) {
    attempted.add(candidate);
    final parsed = Uri.tryParse(candidate);
    if (parsed == null) {
      if (backup.isNotEmpty && backup != candidate) {
        candidate = backup;
        backup = '';
        continue;
      }
      break;
    }

    final resolved = parsed.hasScheme ? parsed : Uri.base.resolve(candidate);
    var opened = false;
    if (kIsWeb) {
      final primaryWindow = preferSelfOnWeb ? '_self' : '_blank';
      final secondaryWindow = preferSelfOnWeb ? '_blank' : '_self';
      opened = await launchUrl(
        resolved,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: primaryWindow,
      );
      if (!opened) {
        opened = await launchUrl(
          resolved,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: secondaryWindow,
        );
      }
    } else {
      opened = await launchUrl(resolved, mode: LaunchMode.externalApplication);
    }

    if (opened) return true;
    if (backup.isNotEmpty && backup != candidate) {
      candidate = backup;
      backup = '';
      continue;
    }
    break;
  }

  if (showError && messenger != null) {
    messenger.showSnackBar(SnackBar(content: Text(openLinkFailed)));
  }
  return false;
}
