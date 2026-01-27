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

  int get doneCards => totalCards - openCards;
}

@immutable
class TrelloStats {
  final String boardName;
  final String boardUrl;
  final DateTime? lastActivityAt;
  final int totalCards;
  final int openCards;
  final int doneCards;
  final List<TrelloListStat> lists;

  const TrelloStats({
    required this.boardName,
    required this.boardUrl,
    required this.lastActivityAt,
    required this.totalCards,
    required this.openCards,
    required this.doneCards,
    required this.lists,
  });
}
