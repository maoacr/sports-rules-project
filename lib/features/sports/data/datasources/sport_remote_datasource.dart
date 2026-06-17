import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/decision.dart';
import '../../domain/entities/law.dart';
import '../../domain/entities/sport.dart';

/// Remote data source for Firestore sports content.
///
/// Collection layout (v2 — IFAB-style, hierarchical):
///   sports/{sportId}
///   sports/{sportId}/laws/{lawId}
///   sports/{sportId}/laws/{lawId}/articles/{articleId}
///   sports/{sportId}/laws/{lawId}/decisions/{decisionId}
abstract class SportRemoteDataSource {
  // -- Sports -------------------------------------------------------------
  Future<List<Sport>> getSports();

  // -- Laws (top-level navigable unit within a sport) ---------------------
  Future<List<Law>> getLaws(String sportId);
  Future<Law> getLaw(String sportId, String lawId);

  // -- Articles (smallest addressable rule unit) --------------------------
  Future<List<Article>> getArticles(String lawId);
  Future<Article> getArticle(String sportId, String lawId, String articleId);

  // -- Decisions (IFAB clarifications attached to a law) ------------------
  Future<List<Decision>> getDecisions(String lawId);

  // -- Search -------------------------------------------------------------
  /// Prefix-match search across the sport's [Article.searchText] field.
  /// Returns up to [limit] articles, ordered by `order`.
  Future<List<Article>> searchArticles(
    String sportId,
    String query, {
    int limit = 50,
  });
}

class SportRemoteDataSourceImpl implements SportRemoteDataSource {
  final FirebaseFirestore _firestore;

  SportRemoteDataSourceImpl(this._firestore);

  // -- Sports -------------------------------------------------------------

  @override
  Future<List<Sport>> getSports() async {
    final snapshot = await _firestore
        .collection('sports')
        .where('isPublished', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Sport(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        thumbnailUrl: data['thumbnailUrl'] ?? '',
        lawCount: data['lawCount'] ?? data['chapterCount'] ?? 0,
        price: data['price'] ?? 0,
        isPublished: data['isPublished'] ?? false,
      );
    }).toList();
  }

  // -- Laws ---------------------------------------------------------------

  @override
  Future<List<Law>> getLaws(String sportId) async {
    final snapshot = await _firestore
        .collection('sports')
        .doc(sportId)
        .collection('laws')
        .orderBy('number')
        .get();
    return snapshot.docs.map(_lawFromDoc).toList();
  }

  @override
  Future<Law> getLaw(String sportId, String lawId) async {
    final doc = await _firestore
        .collection('sports')
        .doc(sportId)
        .collection('laws')
        .doc(lawId)
        .get();
    if (!doc.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Law $lawId not found in sport $sportId',
      );
    }
    return _lawFromDoc(doc);
  }

  Law _lawFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final sportId = doc.reference.parent.parent!.id;
    return Law(
      id: doc.id,
      sportId: sportId,
      title: data['title'] ?? '',
      shortName: data['shortName'] ?? data['title'] ?? '',
      number: data['number'] ?? 0,
      isFree: data['isFree'] ?? false,
      articlesCount: data['articlesCount'] ?? 0,
      decisionsCount: data['decisionsCount'] ?? 0,
      sportTitle: data['sportTitle'] ?? '',
      summary: data['summary'] ?? '',
    );
  }

  // -- Articles -----------------------------------------------------------

  @override
  Future<List<Article>> getArticles(String lawId) async {
    final snapshot = await _firestore
        .collectionGroup('articles')
        .where('lawId', isEqualTo: lawId)
        .orderBy('order')
        .get();
    return snapshot.docs.map(_articleFromDoc).toList();
  }

  @override
  Future<Article> getArticle(
    String sportId,
    String lawId,
    String articleId,
  ) async {
    final doc = await _firestore
        .collection('sports')
        .doc(sportId)
        .collection('laws')
        .doc(lawId)
        .collection('articles')
        .doc(articleId)
        .get();
    if (!doc.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Article $articleId not found in law $lawId of sport $sportId',
      );
    }
    return _articleFromDoc(doc);
  }

  Article _articleFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Article(
      id: doc.id,
      lawId: data['lawId'] ?? '',
      sportId: data['sportId'] ?? '',
      number: data['number'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      parentArticleId: data['parentArticleId'],
      crossRefs: List<String>.from(data['crossRefs'] ?? const []),
      tags: List<String>.from(data['tags'] ?? const []),
      searchText: data['searchText'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  // -- Decisions ----------------------------------------------------------

  @override
  Future<List<Decision>> getDecisions(String lawId) async {
    final snapshot = await _firestore
        .collectionGroup('decisions')
        .where('lawId', isEqualTo: lawId)
        .orderBy('order')
        .get();
    return snapshot.docs.map(_decisionFromDoc).toList();
  }

  Decision _decisionFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Decision(
      id: doc.id,
      lawId: data['lawId'] ?? '',
      sportId: data['sportId'] ?? '',
      relatedArticleId: data['relatedArticleId'],
      number: data['number'] ?? '',
      title: data['title'] ?? '',
      text: data['text'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  // -- Search -------------------------------------------------------------

  @override
  Future<List<Article>> searchArticles(
    String sportId,
    String query, {
    int limit = 50,
  }) async {
    final normalised = query.trim().toLowerCase();
    if (normalised.isEmpty) return const [];
    // Prefix-range match on the denormalised `searchText` field.
    // The import script lowercases this field per article. The
    // `searchText` field is intentionally a single string (not a
    // list of tokens) so range queries are cheap; the trade-off is
    // that multi-word AND searches need the client to AND multiple
    // range queries together (deferred to the bloc layer).
    return _firestore
        .collectionGroup('articles')
        .where('sportId', isEqualTo: sportId)
        .where('searchText', isGreaterThanOrEqualTo: normalised)
        .where('searchText', isLessThan: '$normalised\uf8ff')
        .orderBy('searchText')
        .limit(limit)
        .get()
        .then((snap) => snap.docs.map(_articleFromDoc).toList());
  }
}
