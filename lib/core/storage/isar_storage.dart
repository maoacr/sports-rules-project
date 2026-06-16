import 'package:isar/isar.dart';

part 'isar_storage.g.dart';

/// Isar collection for cached Sport documents.
@collection
class CachedSport {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String sportId;

  late String title;
  late String description;
  late String thumbnailUrl;
  late int chapterCount;
  late int price; // in cents, 0 = free sport
  late bool isPublished;
  late DateTime createdAt;
}

/// Isar collection for cached Chapter documents.
@collection
class CachedChapter {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String chapterId;

  @Index()
  late String sportId; // denormalized for queries

  late String title;
  late int number; // 1-indexed
  late bool isFree; // true only for chapter 1
  late int rulesCount;
  late String sportTitle; // denormalized
}

/// Isar collection for cached Rule documents.
@collection
class CachedRule {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String ruleId;

  @Index()
  late String chapterId;

  @Index()
  late String sportId; // denormalized

  late String title;
  late String content; // markdown
  late List<String> imageUrls;
  late int order;
  late DateTime createdAt;
}

/// Static helpers for Isar operations.
class IsarStorage {
  final Isar _isar;

  IsarStorage(this._isar);

  Isar get db => _isar;

  // Sport operations
  Future<void> cacheSport(CachedSport sport) async {
    await _isar.writeTxn(() async {
      await _isar.cachedSports.put(sport);
    });
  }

  Future<void> cacheSports(List<CachedSport> sports) async {
    await _isar.writeTxn(() async {
      await _isar.cachedSports.putAll(sports);
    });
  }

  Future<CachedSport?> getCachedSport(String sportId) async {
    return _isar.cachedSports.where().sportIdEqualTo(sportId).findFirst();
  }

  Future<List<CachedSport>> getAllCachedSports() async {
    return _isar.cachedSports.where().findAll();
  }

  Future<void> deleteCachedSport(String sportId) async {
    await _isar.writeTxn(() async {
      await _isar.cachedSports.where().sportIdEqualTo(sportId).deleteAll();
    });
  }

  // Chapter operations
  Future<void> cacheChapter(CachedChapter chapter) async {
    await _isar.writeTxn(() async {
      await _isar.cachedChapters.put(chapter);
    });
  }

  Future<void> cacheChapters(List<CachedChapter> chapters) async {
    await _isar.writeTxn(() async {
      await _isar.cachedChapters.putAll(chapters);
    });
  }

  Future<List<CachedChapter>> getCachedChapters(String sportId) async {
    return _isar.cachedChapters.where().sportIdEqualTo(sportId).findAll();
  }

  Future<CachedChapter?> getCachedChapter(String chapterId) async {
    return _isar.cachedChapters.where().chapterIdEqualTo(chapterId).findFirst();
  }

  Future<void> deleteCachedChapters(String sportId) async {
    await _isar.writeTxn(() async {
      await _isar.cachedChapters.where().sportIdEqualTo(sportId).deleteAll();
    });
  }

  // Rule operations
  Future<void> cacheRule(CachedRule rule) async {
    await _isar.writeTxn(() async {
      await _isar.cachedRules.put(rule);
    });
  }

  Future<void> cacheRules(List<CachedRule> rules) async {
    await _isar.writeTxn(() async {
      await _isar.cachedRules.putAll(rules);
    });
  }

  Future<List<CachedRule>> getCachedRules(String chapterId) async {
    return _isar.cachedRules
        .where()
        .chapterIdEqualTo(chapterId)
        .sortByOrder()
        .findAll();
  }

  Future<CachedRule?> getCachedRule(String ruleId) async {
    return _isar.cachedRules.where().ruleIdEqualTo(ruleId).findFirst();
  }

  Future<void> deleteCachedRules(String chapterId) async {
    await _isar.writeTxn(() async {
      await _isar.cachedRules.where().chapterIdEqualTo(chapterId).deleteAll();
    });
  }

  // Bulk operations
  Future<void> clearAllCache() async {
    await _isar.writeTxn(() async {
      await _isar.cachedSports.clear();
      await _isar.cachedChapters.clear();
      await _isar.cachedRules.clear();
    });
  }

  Future<void> clearSportCache(String sportId) async {
    await _isar.writeTxn(() async {
      await _isar.cachedSports.where().sportIdEqualTo(sportId).deleteAll();
      await _isar.cachedChapters.where().sportIdEqualTo(sportId).deleteAll();
      // Note: rules are cleared by chapter, not sportId directly
    });
  }
}
