import '../../../../core/storage/isar_storage.dart';
import '../../domain/entities/sport.dart';

/// Local data source for Isar cached sports data.
abstract class SportLocalDataSource {
  Future<List<Sport>> getCachedSports();
  Future<void> cacheSports(List<Sport> sports);
  Future<List<Chapter>> getCachedChapters(String sportId);
  Future<void> cacheChapters(List<Chapter> chapters);
  Future<List<Rule>> getCachedRules(String chapterId);
  Future<void> cacheRules(List<Rule> rules);
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
      chapterCount: c.chapterCount,
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
      ..chapterCount = s.chapterCount
      ..price = s.price
      ..isPublished = s.isPublished
      ..createdAt = DateTime.now()
    ).toList();
    await _isarStorage.cacheSports(cached);
  }

  @override
  Future<List<Chapter>> getCachedChapters(String sportId) async {
    final cached = await _isarStorage.getCachedChapters(sportId);
    return cached.map((c) => Chapter(
      id: c.chapterId,
      sportId: c.sportId,
      title: c.title,
      number: c.number,
      isFree: c.isFree,
      rulesCount: c.rulesCount,
      sportTitle: c.sportTitle,
    )).toList();
  }

  @override
  Future<void> cacheChapters(List<Chapter> chapters) async {
    final cached = chapters.map((c) => CachedChapter()
      ..chapterId = c.id
      ..sportId = c.sportId
      ..title = c.title
      ..number = c.number
      ..isFree = c.isFree
      ..rulesCount = c.rulesCount
      ..sportTitle = c.sportTitle
    ).toList();
    await _isarStorage.cacheChapters(cached);
  }

  @override
  Future<List<Rule>> getCachedRules(String chapterId) async {
    final cached = await _isarStorage.getCachedRules(chapterId);
    return cached.map((c) => Rule(
      id: c.ruleId,
      chapterId: c.chapterId,
      sportId: c.sportId,
      title: c.title,
      content: c.content,
      imageUrls: c.imageUrls,
      order: c.order,
    )).toList();
  }

  @override
  Future<void> cacheRules(List<Rule> rules) async {
    final cached = rules.map((r) => CachedRule()
      ..ruleId = r.id
      ..chapterId = r.chapterId
      ..sportId = r.sportId
      ..title = r.title
      ..content = r.content
      ..imageUrls = r.imageUrls
      ..order = r.order
      ..createdAt = DateTime.now()
    ).toList();
    await _isarStorage.cacheRules(cached);
  }
}
