import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/articles_providers.dart';
import '../domain/comment.dart';

class CommentsSection extends ConsumerStatefulWidget {
  const CommentsSection({
    super.key,
    required this.articleId,
  });

  final String articleId;

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final actions = ref.read(articleActionsProvider);
    if (actions.onAddComment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to comment')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await actions.onAddComment!(widget.articleId, text);
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(articleCommentsProvider(widget.articleId));
    final actions = ref.watch(articleActionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Comments',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 16),
        if (actions.canPerformActions) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isSubmitting ? null : _submitComment,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        commentsAsync.when(
          data: (comments) => comments.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No comments yet'),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _CommentTile(
                      comment: comments[index],
                      onDelete: actions.onDeleteComment,
                      onReport: actions.onReportComment,
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    this.onDelete,
    this.onReport,
  });

  final Comment comment;
  final Future<void> Function(String)? onDelete;
  final Future<void> Function(String)? onReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  comment.userDisplayName,
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                Text(
                  dateFormat.format(comment.timestamp),
                  style: theme.textTheme.bodySmall,
                ),
                if (onDelete != null || onReport != null)
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      if (onReport != null)
                        const PopupMenuItem(
                          value: 'report',
                          child: Text('Report'),
                        ),
                    ],
                    onSelected: (value) async {
                      switch (value) {
                        case 'delete':
                          await onDelete?.call(comment.id);
                          break;
                        case 'report':
                          await onReport?.call(comment.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Comment reported'),
                            ),
                          );
                          break;
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.text),
          ],
        ),
      ),
    );
  }
}
