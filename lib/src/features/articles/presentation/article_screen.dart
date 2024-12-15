import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/articles_providers.dart';
import '../domain/article.dart';
import 'articles_providers.dart';
import 'comments_section.dart';
import '../data/upload_article.dart';

class ArticleScreen extends ConsumerWidget {
  const ArticleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(currentArticleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              try {
                await uploadBeerHistoryArticle(ref);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Beer history article uploaded successfully!'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error uploading article: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Navigate to liked articles
            },
          ),
        ],
      ),
      body: articleAsync.when(
        data: (article) => article != null
            ? _ArticleView(article: article)
            : const Center(child: Text('No article for today')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _ArticleView extends ConsumerWidget {
  const _ArticleView({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM d, yyyy');
    final isLikedAsync = ref.watch(articleLikeStateProvider(article.id));
    final actions = ref.watch(articleActionsProvider);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          dateFormat.format(article.date),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          article.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (article.imageUrl != null) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              article.imageUrl!,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          article.content,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            isLikedAsync.when(
              data: (isLiked) => IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
                onPressed: actions.canPerformActions
                    ? () async {
                        if (isLiked) {
                          await actions.onUnlikeArticle?.call(article.id);
                        } else {
                          await actions.onLikeArticle?.call(article.id);
                        }
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please sign in to like articles'),
                          ),
                        );
                      },
              ),
              loading: () => const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => const Icon(Icons.favorite_border),
            ),
            Text(
              '${article.likeCount}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.comment_outlined),
              onPressed: () {
                // TODO: Show comments
              },
            ),
          ],
        ),
        CommentsSection(articleId: article.id),
      ],
    );
  }
}
