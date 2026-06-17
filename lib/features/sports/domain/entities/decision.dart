import 'package:equatable/equatable.dart';

/// An IFAB "Decision" attached to a Law.
///
/// Decisions are the official clarifications and interpretations that
/// IFAB publishes at the end of each law. They are NOT articles
/// themselves — they have no number, no cross-refs, no tags — but
/// they belong to a law (and optionally to a specific article).
class Decision extends Equatable {
  final String id;
  final String lawId;
  final String sportId;

  /// Optional pointer to the article this decision clarifies.
  /// Null when the decision is a general law-level note.
  final String? relatedArticleId;

  /// 1-indexed display number within the law. E.g. "1", "2", "3".
  final String number;

  /// Short title, often the first few words. Optional.
  final String title;

  /// The decision/clarification text. Plain text.
  final String text;

  /// Sort order within the law.
  final int order;

  const Decision({
    required this.id,
    required this.lawId,
    required this.sportId,
    required this.number,
    required this.title,
    required this.text,
    required this.order,
    this.relatedArticleId,
  });

  @override
  List<Object?> get props => [
        id,
        lawId,
        sportId,
        relatedArticleId,
        number,
        title,
        text,
        order,
      ];
}
