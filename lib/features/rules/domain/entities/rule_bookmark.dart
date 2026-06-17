import 'package:equatable/equatable.dart';

class RuleBookmark extends Equatable {
  final String id;
  final String ruleId;
  final String chapterId;
  final String sportId;
  final String ruleTitle;
  final String chapterTitle;
  final String sportTitle;
  final DateTime createdAt;

  const RuleBookmark({
    required this.id,
    required this.ruleId,
    required this.chapterId,
    required this.sportId,
    required this.ruleTitle,
    required this.chapterTitle,
    required this.sportTitle,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, ruleId, chapterId, sportId, ruleTitle, chapterTitle, sportTitle, createdAt];
}
