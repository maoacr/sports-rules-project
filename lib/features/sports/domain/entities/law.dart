import 'package:equatable/equatable.dart';

/// A Law of the Game (e.g. for football, "Law 1 — The Field of Play").
///
/// Laws are the top-level navigable unit within a sport. They carry
/// denormalised metadata (number, isFree, sportTitle) so a single
/// document read is enough to render a list/header.
class Law extends Equatable {
  /// Document id. Convention: `law-NN` (zero-padded), e.g. `law-01`.
  final String id;
  final String sportId;
  final String title;

  /// Short display name for compact contexts (drawer, tab bar).
  /// E.g. "Field", "Ball", "Players".
  final String shortName;

  /// 1-indexed. Sorts the law list.
  final int number;

  /// Per the freemium model: law 1 is always `true` (free preview).
  /// All other laws require sport purchase.
  final bool isFree;

  /// Total number of articles in this law. Derived by the import script.
  final int articlesCount;

  /// Number of IFAB "Decisions" attached to this law. Derived.
  final int decisionsCount;

  /// Denormalised sport title for offline rendering.
  final String sportTitle;

  /// One- or two-line summary shown on the law header. Optional.
  final String summary;

  const Law({
    required this.id,
    required this.sportId,
    required this.title,
    required this.shortName,
    required this.number,
    required this.isFree,
    required this.articlesCount,
    required this.decisionsCount,
    required this.sportTitle,
    this.summary = '',
  });

  @override
  List<Object?> get props => [
        id,
        sportId,
        title,
        shortName,
        number,
        isFree,
        articlesCount,
        decisionsCount,
        sportTitle,
        summary,
      ];
}

/// A single Article within a Law (e.g. "Law 1, Art. 1 — Field surface").
///
/// The Article is the smallest addressable unit of the rulebook. It
/// carries content, cross-references, and a denormalised search text
/// for the global search index.
class Article extends Equatable {
  /// Document id. Convention: `law-NN/art-NN`, e.g. `law-01/art-01`.
  final String id;
  final String lawId;
  final String sportId;

  /// Human-readable number, IFAB style: "1", "2", "3.1", "3.2".
  /// Display-only; ordering is via [order].
  final String number;

  /// Short title, often optional. May be empty when IFAB uses just
  /// a number (e.g. "1. Field surface").
  final String title;

  /// Main body text. May contain markdown. Pilot renders as plain text.
  final String content;

  /// For sub-articles like "3.1", the parent article id (e.g. `law-12/art-03`).
  /// Null for top-level articles.
  final String? parentArticleId;

  /// Cross-references to other articles. Format: `law-NN/art-NN`.
  /// Used to render inline links that jump to the cited article.
  final List<String> crossRefs;

  /// Tags for filtering and "related rules". Examples: ['porteria',
  /// 'tiros-libres']. Lowercased, deduplicated.
  final List<String> tags;

  /// Denormalised full-text for global search. Built by the import
  /// script as `title + content + tags.join(' ')`, lowercased.
  /// Not shown to the user.
  final String searchText;

  /// 1-indexed, sorts articles within a law.
  final int order;

  const Article({
    required this.id,
    required this.lawId,
    required this.sportId,
    required this.number,
    required this.title,
    required this.content,
    required this.crossRefs,
    required this.tags,
    required this.searchText,
    required this.order,
    this.parentArticleId,
  });

  @override
  List<Object?> get props => [
        id,
        lawId,
        sportId,
        number,
        title,
        content,
        parentArticleId,
        crossRefs,
        tags,
        searchText,
        order,
      ];
}
