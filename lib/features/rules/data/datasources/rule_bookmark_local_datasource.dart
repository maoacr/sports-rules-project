import '../../../../core/storage/isar_storage.dart';
import '../../domain/entities/rule_bookmark.dart';

abstract class RuleBookmarkLocalDataSource {
  Future<List<RuleBookmark>> getBookmarks();
  Future<bool> isBookmarked(String ruleId);
  Future<void> saveBookmark(RuleBookmark bookmark);
  Future<void> deleteBookmark(String ruleId);
}

class RuleBookmarkLocalDataSourceImpl implements RuleBookmarkLocalDataSource {
  final IsarStorage _isarStorage;

  RuleBookmarkLocalDataSourceImpl(this._isarStorage);

  @override
  Future<List<RuleBookmark>> getBookmarks() async {
    final cached = await _isarStorage.getAllBookmarks();
    return cached.map(_toEntity).toList();
  }

  @override
  Future<bool> isBookmarked(String ruleId) async {
    return _isarStorage.isBookmarked(ruleId);
  }

  @override
  Future<void> saveBookmark(RuleBookmark bookmark) async {
    final cached = CachedBookmark()
      ..bookmarkId = bookmark.id
      ..ruleId = bookmark.ruleId
      ..chapterId = bookmark.chapterId
      ..sportId = bookmark.sportId
      ..ruleTitle = bookmark.ruleTitle
      ..chapterTitle = bookmark.chapterTitle
      ..sportTitle = bookmark.sportTitle
      ..createdAt = bookmark.createdAt;
    await _isarStorage.saveBookmark(cached);
  }

  @override
  Future<void> deleteBookmark(String ruleId) async {
    await _isarStorage.deleteBookmark(ruleId);
  }

  RuleBookmark _toEntity(CachedBookmark c) {
    return RuleBookmark(
      id: c.bookmarkId,
      ruleId: c.ruleId,
      chapterId: c.chapterId,
      sportId: c.sportId,
      ruleTitle: c.ruleTitle,
      chapterTitle: c.chapterTitle,
      sportTitle: c.sportTitle,
      createdAt: c.createdAt,
    );
  }
}
