import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/article.dart';

class ArticleRepository {
  ArticleRepository({required this.firestore});
  final FirebaseFirestore firestore;

  static const String _collection = 'articles';

  Future<List<Article>> getArticles({
    required DateTime startDate,
    required int limit,
  }) async {
    final query = firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(startDate))
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Article.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<Article?> getArticleByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = firestore
        .collection(_collection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1);

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return null;
    return Article.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
  }

  Stream<List<Article>> watchLikedArticles(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('likedArticles')
        .snapshots()
        .asyncMap((snapshot) async {
      final articleIds = snapshot.docs.map((doc) => doc.id).toList();
      if (articleIds.isEmpty) return [];

      final articlesQuery = await firestore
          .collection(_collection)
          .where(FieldPath.documentId, whereIn: articleIds)
          .get();

      return articlesQuery.docs
          .map((doc) => Article.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(firestore: FirebaseFirestore.instance);
});
