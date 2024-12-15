import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/article_repository.dart';
import '../domain/article.dart';

final currentArticleProvider = FutureProvider.autoDispose<Article?>((ref) async {
  final repository = ref.watch(articleRepositoryProvider);
  return repository.getArticleByDate(DateTime.now());
});

final articleListProvider = StateNotifierProvider<ArticleListNotifier, AsyncValue<List<Article>>>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return ArticleListNotifier(repository);
});

class ArticleListNotifier extends StateNotifier<AsyncValue<List<Article>>> {
  ArticleListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadInitialArticles();
  }

  final ArticleRepository _repository;
  DateTime? _lastLoadedDate;
  static const int _pageSize = 10;
  bool _hasMore = true;

  Future<void> loadInitialArticles() async {
    state = const AsyncValue.loading();
    await loadMoreArticles();
  }

  Future<void> loadMoreArticles() async {
    if (!_hasMore) return;

    try {
      final startDate = _lastLoadedDate ?? DateTime.now();
      final articles = await _repository.getArticles(
        startDate: startDate,
        limit: _pageSize,
      );

      if (articles.length < _pageSize) {
        _hasMore = false;
      }

      if (articles.isNotEmpty) {
        _lastLoadedDate = articles.last.date;
        state = AsyncValue.data([
          if (state.value != null) ...state.value!,
          ...articles,
        ]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final likedArticlesProvider = StreamProvider.autoDispose<List<Article>>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  // TODO: Get userId from auth provider
  const userId = 'dummy-user-id';
  return repository.watchLikedArticles(userId);
});
