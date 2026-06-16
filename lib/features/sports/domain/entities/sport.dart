import 'package:equatable/equatable.dart';

/// Sport entity.
class Sport extends Equatable {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int chapterCount;
  final int price; // in cents, 0 = free sport
  final bool isPublished;

  const Sport({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.chapterCount,
    required this.price,
    required this.isPublished,
  });

  @override
  List<Object?> get props => [id, title, description, thumbnailUrl, chapterCount, price, isPublished];
}

/// Chapter entity.
class Chapter extends Equatable {
  final String id;
  final String sportId;
  final String title;
  final int number; // 1-indexed
  final bool isFree;
  final int rulesCount;
  final String sportTitle;

  const Chapter({
    required this.id,
    required this.sportId,
    required this.title,
    required this.number,
    required this.isFree,
    required this.rulesCount,
    required this.sportTitle,
  });

  @override
  List<Object?> get props => [id, sportId, title, number, isFree, rulesCount, sportTitle];
}

/// Rule entity.
class Rule extends Equatable {
  final String id;
  final String chapterId;
  final String sportId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final int order;

  const Rule({
    required this.id,
    required this.chapterId,
    required this.sportId,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.order,
  });

  @override
  List<Object?> get props => [id, chapterId, sportId, title, content, imageUrls, order];
}
