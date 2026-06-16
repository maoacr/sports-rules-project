import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sport.dart';

/// Remote data source for Firestore sports data.
abstract class SportRemoteDataSource {
  Future<List<Sport>> getSports();
  Future<List<Chapter>> getChapters(String sportId);
  Future<List<Rule>> getRules(String chapterId);
  Future<Rule> getRule(String sportId, String chapterId, String ruleId);
}

class SportRemoteDataSourceImpl implements SportRemoteDataSource {
  final FirebaseFirestore _firestore;

  SportRemoteDataSourceImpl(this._firestore);

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
        chapterCount: data['chapterCount'] ?? 0,
        price: data['price'] ?? 0,
        isPublished: data['isPublished'] ?? false,
      );
    }).toList();
  }

  @override
  Future<List<Chapter>> getChapters(String sportId) async {
    final snapshot = await _firestore
        .collection('sports/$sportId/chapters')
        .orderBy('number')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Chapter(
        id: doc.id,
        sportId: sportId,
        title: data['title'] ?? '',
        number: data['number'] ?? 0,
        isFree: data['isFree'] ?? false,
        rulesCount: data['rulesCount'] ?? 0,
        sportTitle: data['sportTitle'] ?? '',
      );
    }).toList();
  }

  @override
  Future<List<Rule>> getRules(String chapterId) async {
    final snapshot = await _firestore
        .collection('chapters/$chapterId/rules')
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Rule(
        id: doc.id,
        chapterId: chapterId,
        sportId: data['sportId'] ?? '',
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        imageUrls: List<String>.from(data['imageUrls'] ?? []),
        order: data['order'] ?? 0,
      );
    }).toList();
  }

  @override
  Future<Rule> getRule(String sportId, String chapterId, String ruleId) async {
    final doc = await _firestore
        .collection('sports')
        .doc(sportId)
        .collection('chapters')
        .doc(chapterId)
        .collection('rules')
        .doc(ruleId)
        .get();

    if (!doc.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Rule $ruleId not found in chapter $chapterId of sport $sportId',
      );
    }

    final data = doc.data() ?? const <String, dynamic>{};
    return Rule(
      id: doc.id,
      chapterId: chapterId,
      sportId: sportId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? const []),
      order: data['order'] ?? 0,
    );
  }
}
