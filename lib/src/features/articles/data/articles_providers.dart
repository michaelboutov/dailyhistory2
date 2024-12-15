import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailyhistor/src/features/authentication/data/firebase_auth_repository.dart';
import '../domain/comment.dart';
import 'firestore_repository.dart';

final articleLikeStateProvider = StreamProvider.autoDispose.family<bool, String>((ref, articleId) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream.value(false);

  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.watchIsArticleLiked(user.uid, articleId);
});

final articleCommentsProvider = StreamProvider.autoDispose.family<List<Comment>, String>((ref, articleId) {
  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.watchArticleComments(articleId);
});

final articleActionsProvider = Provider.autoDispose((ref) {
  final repository = ref.watch(firestoreRepositoryProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;

  return ArticleActions(
    onLikeArticle: user != null
        ? (String articleId) => repository.likeArticle(user.uid, articleId)
        : null,
    onUnlikeArticle: user != null
        ? (String articleId) => repository.unlikeArticle(user.uid, articleId)
        : null,
    onAddComment: user != null
        ? (String articleId, String text) => repository.addComment(
              articleId: articleId,
              userId: user.uid,
              userDisplayName: user.displayName ?? 'Anonymous',
              text: text,
            )
        : null,
    onDeleteComment: user != null
        ? (String commentId) => repository.deleteComment(commentId)
        : null,
    onReportComment: user != null
        ? (String commentId) => repository.reportComment(commentId)
        : null,
  );
});

class ArticleActions {
  ArticleActions({
    this.onLikeArticle,
    this.onUnlikeArticle,
    this.onAddComment,
    this.onDeleteComment,
    this.onReportComment,
  });

  final Future<void> Function(String articleId)? onLikeArticle;
  final Future<void> Function(String articleId)? onUnlikeArticle;
  final Future<Comment> Function(String articleId, String text)? onAddComment;
  final Future<void> Function(String commentId)? onDeleteComment;
  final Future<void> Function(String commentId)? onReportComment;

  bool get canPerformActions =>
      onLikeArticle != null &&
      onUnlikeArticle != null &&
      onAddComment != null &&
      onDeleteComment != null &&
      onReportComment != null;
}
