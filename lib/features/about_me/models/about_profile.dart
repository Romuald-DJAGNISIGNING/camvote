import 'package:flutter/foundation.dart';

@immutable
class AboutProfile {
  final String name;
  final String title;
  final String tagline;
  final String vision;
  final String mission;
  final String email;
  final String linkedin;
  final String github;
  final String portfolio;
  final List<String> focusTags;
  final List<String> hobbies;

  const AboutProfile({
    required this.name,
    required this.title,
    required this.tagline,
    required this.vision,
    required this.mission,
    required this.email,
    required this.linkedin,
    required this.github,
    required this.portfolio,
    required this.focusTags,
    required this.hobbies,
  });

  factory AboutProfile.fromJson(Map<String, dynamic> json) {
    return AboutProfile(
      name: (json['name'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      tagline: (json['tagline'] as String?) ?? '',
      vision: (json['vision'] as String?) ?? '',
      mission: (json['mission'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      linkedin: (json['linkedin'] as String?) ?? '',
      github: (json['github'] as String?) ?? '',
      portfolio: (json['portfolio'] as String?) ?? '',
      focusTags: (json['focus_tags'] as List? ?? [])
          .whereType<String>()
          .toList(),
      hobbies: (json['hobbies'] as List? ?? []).whereType<String>().toList(),
    );
  }
}
