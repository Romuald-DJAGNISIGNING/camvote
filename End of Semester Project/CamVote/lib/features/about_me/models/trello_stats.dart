import 'package:flutter/foundation.dart';

@immutable
class TrelloListStat {
  final String name;
  final int totalCards;
  final int openCards;

  const TrelloListStat({
    required this.name,
    required this.totalCards,
    required this.openCards,
  });

  int get doneCards {
    final value = totalCards - openCards;
    if (value < 0) return 0;
    if (value > totalCards) return totalCards;
    return value;
  }

  int get completionPercent {
    if (totalCards <= 0) return 0;
    final percent = ((doneCards / totalCards) * 100).round();
    if (percent < 0) return 0;
    if (percent > 100) return 100;
    return percent;
  }

  double get completionRatio => completionPercent / 100;
}

@immutable
class TrelloStats {
  final String boardName;
  final String boardUrl;
  final DateTime? lastActivityAt;
  final int totalCards;
  final int openCards;
  final int doneCards;
  final int? completionPercent;
  final List<TrelloListStat> lists;

  const TrelloStats({
    required this.boardName,
    required this.boardUrl,
    required this.lastActivityAt,
    required this.totalCards,
    required this.openCards,
    required this.doneCards,
    this.completionPercent,
    required this.lists,
  });

  int get completedTasks => doneCards < 0 ? 0 : doneCards;

  int get remainingTasks => openCards < 0 ? 0 : openCards;

  int get resolvedCompletionPercent {
    final explicit = completionPercent;
    if (explicit != null) {
      if (explicit < 0) return 0;
      if (explicit > 100) return 100;
      return explicit;
    }
    if (totalCards <= 0) return 0;
    final percent = ((completedTasks / totalCards) * 100).round();
    if (percent < 0) return 0;
    if (percent > 100) return 100;
    return percent;
  }

  double get completionRatio => resolvedCompletionPercent / 100;
}
