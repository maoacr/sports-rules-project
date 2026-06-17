import 'package:equatable/equatable.dart';

/// A sport (top-level container, e.g. "Fútbol", "Básquetbol").
///
/// A sport owns a collection of [Law]s (in the case of football: the
/// 17 IFAB Laws of the Game) and a flat list of published state.
class Sport extends Equatable {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;

  /// Number of laws in this sport. Derived by the import script.
  final int lawCount;

  /// Price in cents. `0` = free sport.
  final int price;
  final bool isPublished;

  const Sport({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.lawCount,
    required this.price,
    required this.isPublished,
  });

  @override
  List<Object?> get props =>
      [id, title, description, thumbnailUrl, lawCount, price, isPublished];
}
