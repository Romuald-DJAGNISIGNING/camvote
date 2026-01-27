import 'package:flutter/material.dart';

/// Candidate metric used for charts and map summaries.
class CandidateMetric {
  final String id;
  final String name;
  final int votes;
  final Color color;

  const CandidateMetric({
    required this.id,
    required this.name,
    required this.votes,
    required this.color,
  });
}
