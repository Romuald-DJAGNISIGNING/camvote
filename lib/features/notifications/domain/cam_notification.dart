import 'dart:convert';

enum CamNotificationType { info, success, warning, alert, election, security }

/// Audience scopes:
/// - public: visible to everyone (even not logged in)
/// - voter/admin/observer: role-based
/// - all: any role
enum CamAudience { public, voter, observer, admin, all }

class CamNotification {
  final String id;
  final CamNotificationType type;
  final CamAudience audience;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  /// Optional deep link route (ex: "/public/results", "/voter/elections")
  final String? route;

  const CamNotification({
    required this.id,
    required this.type,
    required this.audience,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    this.route,
  });

  CamNotification copyWith({
    CamNotificationType? type,
    CamAudience? audience,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? read,
    String? route,
  }) {
    return CamNotification(
      id: id,
      type: type ?? this.type,
      audience: audience ?? this.audience,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
      route: route ?? this.route,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'audience': audience.name,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
        'route': route,
      };

  static CamNotification fromMap(Map<String, dynamic> m) {
    return CamNotification(
      id: (m['id'] ?? '') as String,
      type: CamNotificationType.values.firstWhere(
        (e) => e.name == m['type'],
        orElse: () => CamNotificationType.info,
      ),
      audience: CamAudience.values.firstWhere(
        (e) => e.name == m['audience'],
        orElse: () => CamAudience.public,
      ),
      title: (m['title'] ?? '') as String,
      body: (m['body'] ?? '') as String,
      createdAt: DateTime.tryParse((m['createdAt'] ?? '') as String) ?? DateTime.now(),
      read: (m['read'] ?? false) as bool,
      route: m['route'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());
  static CamNotification fromJson(String s) => fromMap(jsonDecode(s) as Map<String, dynamic>);
}