import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/article.dart';
import '../domain/comment.dart';

class FirestoreRepository {
  FirestoreRepository({required this.firestore});
  final FirebaseFirestore firestore;

  // Articles
  Future<void> createArticle(Article article) async {
    await firestore.collection('articles').doc(article.id).set(article.toMap());
  }

  Future<void> likeArticle(String userId, String articleId) async {
    final userRef = firestore.collection('users').doc(userId);
    final articleRef = firestore.collection('articles').doc(articleId);

    await firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      final articleDoc = await transaction.get(articleRef);

      if (!articleDoc.exists) {
        throw Exception('Article does not exist');
      }

      // Create user document if it doesn't exist
      if (!userDoc.exists) {
        transaction.set(userRef, {
          'likedArticleIds': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final likedArticles = List<String>.from(
          userDoc.exists ? (userDoc.data()?['likedArticleIds'] ?? []) : []);
      
      if (!likedArticles.contains(articleId)) {
        likedArticles.add(articleId);
        transaction.set(userRef, {'likedArticleIds': likedArticles}, SetOptions(merge: true));
        transaction.update(articleRef, {
          'likeCount': FieldValue.increment(1),
        });
      }
    });
  }

  Future<void> unlikeArticle(String userId, String articleId) async {
    final userRef = firestore.collection('users').doc(userId);
    final articleRef = firestore.collection('articles').doc(articleId);

    await firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      final articleDoc = await transaction.get(articleRef);

      if (!articleDoc.exists) {
        throw Exception('Article does not exist');
      }

      // If user doc doesn't exist, nothing to unlike
      if (!userDoc.exists) return;

      final likedArticles = List<String>.from(userDoc.data()?['likedArticleIds'] ?? []);
      
      if (likedArticles.contains(articleId)) {
        likedArticles.remove(articleId);
        transaction.set(userRef, {'likedArticleIds': likedArticles}, SetOptions(merge: true));
        transaction.update(articleRef, {
          'likeCount': FieldValue.increment(-1),
        });
      }
    });
  }

  Stream<bool> watchIsArticleLiked(String userId, String articleId) {
    return firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final likedArticles = List<String>.from(snapshot.data()?['likedArticleIds'] ?? []);
      return likedArticles.contains(articleId);
    });
  }

  // Comments
  Future<Comment> addComment({
    required String articleId,
    required String userId,
    required String userDisplayName,
    required String text,
  }) async {
    final commentRef = firestore.collection('comments').doc();
    final comment = Comment(
      id: commentRef.id,
      articleId: articleId,
      userId: userId,
      userDisplayName: userDisplayName,
      text: text,
      timestamp: DateTime.now(),
    );

    await commentRef.set(comment.toMap());
    return comment;
  }

  Stream<List<Comment>> watchArticleComments(String articleId) {
    return firestore
        .collection('comments')
        .where('articleId', isEqualTo: articleId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteComment(String commentId) async {
    await firestore.collection('comments').doc(commentId).delete();
  }

  Future<void> reportComment(String commentId) async {
    await firestore.collection('comments').doc(commentId).update({
      'reportCount': FieldValue.increment(1),
    });
  }
}

final firestoreRepositoryProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(firestore: FirebaseFirestore.instance);
});
