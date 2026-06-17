// Local data source for Isar-cached sports content.
//
// NOTE on naming: the Isar `@collection` classes (CachedChapter,
// CachedRule) are kept under their legacy names to avoid regenerating
// the committed `isar_storage.g.dart` schema, which is fragile with
// the current build_runner / frontend_server_client pinning. They map
// to the new domain entities [Law] and [Article] respectively. When
// the Isar schema needs new fields (notably `crossRefs`, `tags`,
// `searchText`), regenerate the .g.dart and add them. The mapping
// in this file currently drops those new fields when reading from
// cache — full offline fidelity is a follow-up.

import '../../../../core/storage/isar_storage.dart';
import '../../domain/entities/law.dart';
import '../../domain/entities/sport.dart';

/// Local data source for Isar cached sports data.
abstract class SportLocalDataSource {
  Future<List<Sport>> getCachedSports();
  Future<void> cacheSports(List<Sport> sports);

  Future<List<Law>> getCachedLaws(String sportId);
  Future<void> cacheLaws(List<Law> laws);

  Future<List<Article>> getCachedArticles(String lawId);
  Future<void> cacheArticles(List<Article> articles);
}

class SportLocalDataSourceImpl implements SportLocalDataSource {
  final IsarStorage _isarStorage;

  SportLocalDataSourceImpl(this._isarStorage);

  @override
  Future<List<Sport>> getCachedSports() async {
    final cached = await _isarStorage.getAllCachedSports();
    return cached.map((c) => Sport(
          id: c.sportId,
          title: c.title,
          description: c.description,
          thumbnailUrl: c.thumbnailUrl,
          lawCount: c.chapterCount, // legacy field name in cache
          price: c.price,
          isPublished: c.isPublished,
        )).toList();
  }

  @override
  Future<void> cacheSports(List<Sport> sports) async {
    final cached = sports.map((s) => CachedSport()
      ..sportId = s.id
      ..title = s.title
      ..description = s.description
      ..thumbnailUrl = s.thumbnailUrl
      ..chapterCount = s.lawCount // legacy column
      ..price = s.price
      ..isPublished = s.isPublished
      ..createdAt = DateTime.now()
    ).toList();
    await _isarStorage.cacheSports(cached);
  }

  @override
  Future<List<Law>> getCachedLaws(String sportId) async {
    final cached = await _isarStorage.getCachedChapters(sportId);
    return cached.map((c) => Law(
          id: c.chapterId, // legacy column
          sportId: c.sportId,
          title: c.title,
          shortName: c.title, // no shortName in cache; fall back to title
          number: c.number,
          isFree: c.isFree,
          articlesCount: c.rulesCount, // legacy column
          decisionsCount: 0, // not cached yet
          sportTitle: c.sportTitle,
          summary: '',
        )).toList();
  }

  @override
  Future<void> cacheLaws(List<Law> laws) async {
    final cached = laws.map((l) => CachedChapter() // legacy class
      ..chapterId = l.id
      ..sportId = l.sportId
      ..title = l.title
      ..number = l.number
      ..isFree = l.isFree
      ..rulesCount = l.articlesCount // legacy column
      ..sportTitle = l.sportTitle
    ).toList();
    await _isarStorage.cacheChapters(cached);
  }

  @override
  Future<List<Article>> getCachedArticles(String lawId) async {
    final cached = await _isarStorage.getCachedRules(lawId);
    return cached.map((c) => Article(
          id: c.ruleId, // legacy column
          lawId: c.chapterId, // legacy column
          sportId: c.sportId,
          number: '', // not cached
          title: c.title,
          content: c.content,
          parentArticleId: null,
          crossRefs: const [],
          tags: const [],
          searchText: c.content.toLowerCase(),
          order: c.order,
        )).toList();
  }

  @override
  Future<void> cacheArticles(List<Article> articles) async {
    final cached = articles.map((a) => CachedRule() // legacy class
      ..ruleId = a.id
      ..chapterId = a.lawId // legacy column
      ..sportId = a.sportId
      ..title = a.title
      ..content = a.content
      ..imageUrls = const []
      ..order = a.order
      ..createdAt = DateTime.now()
    ).toList();
    await _isarStorage.cacheRules(cached);
  }
}
