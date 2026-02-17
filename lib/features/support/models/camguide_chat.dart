import 'package:flutter/foundation.dart';

@immutable
class CamGuideReply {
  const CamGuideReply({
    required this.answer,
    required this.followUps,
    required this.sourceHints,
    required this.confidence,
    this.intentId = '',
  });

  final String answer;
  final List<String> followUps;
  final List<String> sourceHints;
  final double confidence;
  final String intentId;
}

@immutable
class CamGuideIntent {
  const CamGuideIntent({
    required this.id,
    required this.keywords,
    required this.answerEn,
    required this.answerFr,
    this.detailsEn = '',
    this.detailsFr = '',
    this.followUpsEn = const <String>[],
    this.followUpsFr = const <String>[],
    this.sourceHints = const <String>[],
  });

  final String id;
  final List<String> keywords;
  final String answerEn;
  final String answerFr;
  final String detailsEn;
  final String detailsFr;
  final List<String> followUpsEn;
  final List<String> followUpsFr;
  final List<String> sourceHints;
}
