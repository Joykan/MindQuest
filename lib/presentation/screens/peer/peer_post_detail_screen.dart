// lib/presentation/screens/peer/peer_post_detail_screen.dart
//
// Detail view for a single peer support post with replies.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/peer_models.dart';
import '../../../../data/services/peer_support_service.dart';

final _service = PeerSupportService();

final repliesProvider =
    FutureProvider.family<List<PeerReply>, String>((ref, postId) async {
  return _service.getReplies(postId);
});

String _formatTimeAgo(DateTime dt) {
  final d = DateTime.now().difference(dt);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays < 7) return '${d.inDays}d ago';
  return '${(d.inDays / 7).floor()}w ago';
}

class PeerPostDetailScreen extends ConsumerWidget {
  final PeerPost post;

  const PeerPostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repliesAsync = ref.watch(repliesProvider(post.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(post.anonHandle),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => _showReportDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Post header
          Row(
            children: [
              Text(post.anonAvatar, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.anonHandle,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    _formatTimeAgo(post.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),

          // Tags & category
          Wrap(
            spacing: 8,
            children: [
              Chip(
                  label: Text(kPeerCategories
                      .firstWhere((c) => c.id == post.category)
                      .emoji)),
              ...post.tags.map((t) => Chip(label: Text('#$t'))),
            ],
          ),
          const SizedBox(height: 12),

          // Hugs
          Row(
            children: [
              IconButton(
                icon: Icon(
                    post.hasHugged ? Icons.favorite : Icons.favorite_border),
                onPressed: () => _toggleHug(context),
              ),
              Text('${post.hugCount} hugs'),
              const SizedBox(width: 16),
              const Icon(Icons.comment_outlined),
              Text('${post.replyCount} replies'),
            ],
          ),
          const Divider(height: 32),

          // Replies section
          Text('Replies', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          repliesAsync.when(
            data: (replies) => replies.isEmpty
                ? const Center(
                    child: Text('No replies yet. Be the first to reply!'))
                : Column(
                    children: replies.map((r) => _ReplyCard(reply: r)).toList(),
                  ),
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error loading replies: $e'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReplySheet(context),
        child: const Icon(Icons.reply),
      ),
    );
  }

  Future<void> _toggleHug(BuildContext context) async {
    if (post.hasHugged) {
      await _service.unHugPost(postId: post.id, userId: 'current_user');
    } else {
      await _service.hugPost(postId: post.id, userId: 'current_user');
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: const Text('Why are you reporting this post?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _showReplySheet(BuildContext context) {
    // Show reply composition sheet
  }
}

class _ReplyCard extends StatelessWidget {
  final PeerReply reply;
  const _ReplyCard({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(reply.anonAvatar, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(reply.anonHandle),
                const Spacer(),
                Text(_formatTimeAgo(reply.createdAt)),
              ],
            ),
            const SizedBox(height: 8),
            Text(reply.content),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                      reply.hasHugged ? Icons.favorite : Icons.favorite_border),
                  onPressed: () {},
                  iconSize: 20,
                ),
                Text('${reply.hugCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
