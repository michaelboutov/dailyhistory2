import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/authentication/data/firebase_auth_repository.dart';
import 'beer_history_article.dart';

Future<void> uploadBeerHistoryArticle(WidgetRef ref) async {
  final firestore = FirebaseFirestore.instance;
  final user = ref.read(authRepositoryProvider).currentUser;
  
  if (user == null) {
    throw Exception('Must be signed in to upload articles');
  }
  
  try {
    await firestore.collection('articles').doc(beerHistoryArticle.id).set({
      ...beerHistoryArticle.toMap(),
      'authorId': user.uid,
      'authorName': user.displayName ?? 'Anonymous',
    });
    print('Beer history article uploaded successfully!');
  } catch (e) {
    print('Error uploading article: $e');
    rethrow;
  }
}
