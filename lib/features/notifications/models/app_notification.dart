import 'package:camvote/gen/l10n/app_localizations.dart';

enum AppNotificationType {
  election,
  system,
  security,
  status,
}

enum AppNotificationTemplate {
  electionSoon,
  electionOpen,
  electionClosed,
  securityNotice,
  statusUpdate,
}

class AppNotificationText {
  const AppNotificationText._();

  static String title(AppNotificationTemplate template, AppLocalizations t) {
    return switch (template) {
      AppNotificationTemplate.electionSoon => t.notificationElectionSoonTitle,
      AppNotificationTemplate.electionOpen => t.notificationElectionOpenTitle,
      AppNotificationTemplate.electionClosed => t.notificationElectionClosedTitle,
      AppNotificationTemplate.securityNotice => t.notificationSecurityNoticeTitle,
      AppNotificationTemplate.statusUpdate => t.notificationStatusUpdateTitle,
    };
  }

  static String body(AppNotificationTemplate template, AppLocalizations t) {
    return switch (template) {
      AppNotificationTemplate.electionSoon => t.notificationElectionSoonBody,
      AppNotificationTemplate.electionOpen => t.notificationElectionOpenBody,
      AppNotificationTemplate.electionClosed => t.notificationElectionClosedBody,
      AppNotificationTemplate.securityNotice => t.notificationSecurityNoticeBody,
      AppNotificationTemplate.statusUpdate => t.notificationStatusUpdateBody,
    };
  }
}

class AppNotificationItem {
  final String id;
  final DateTime createdAt;
  final AppNotificationType type;
  final AppNotificationTemplate template;
  final bool isRead;

  /// Roles that can see this item. Empty => everyone (including public).
  final List<String> visibleToRoles;

  const AppNotificationItem({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.template,
    required this.isRead,
    required this.visibleToRoles,
  });

  AppNotificationItem copyWith({bool? isRead}) {
    return AppNotificationItem(
      id: id,
      createdAt: createdAt,
      type: type,
      template: template,
      isRead: isRead ?? this.isRead,
      visibleToRoles: visibleToRoles,
    );
  }
}
