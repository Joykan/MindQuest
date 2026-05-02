// lib/presentation/screens/peer/peer_support_screen.dart
//
// Main screen for the anonymous Peer Support Forum.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/peer_models.dart';
import '../../../../data/services/peer_support_service.dart';

final _service = PeerSupportService();

// State providers
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);
final postsProvider = FutureProvider<List<PeerPost>>((ref) async {
  final category = ref.watch(selectedCategoryFilterProvider);
  return _service.getPosts(category: category);
});

class PeerSupportScreen extends ConsumerWidget {
  const PeerSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);
    // Watch to trigger rebuild when filter changes
    ref.watch(selectedCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peer Support'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: postsAsync.when(
        data: (posts) => posts.isEmpty
            ? const Center(
                child: Text('No posts yet. Be the first to share!'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, index) => _PostCard(post: posts[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 8),
              Text('Error: $e'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(postsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComposeSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('All Categories'),
            onTap: () {
              ref.read(selectedCategoryFilterProvider.notifier).state = null;
              Navigator.pop(context);
            },
          ),
          ...kPeerCategories.map((c) => ListTile(
                leading: Text(c.emoji),
                title: Text(c.labelEn),
                onTap: () {
                  ref.read(selectedCategoryFilterProvider.notifier).state =
                      c.id;
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  void _showComposeSheet(BuildContext context) {
    // Show compose post bottom sheet
  }
}

class _PostCard extends StatelessWidget {
  final PeerPost post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(post.anonAvatar, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.anonHandle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _formatTimeAgo(post.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    kPeerCategories
                        .firstWhere((c) => c.id == post.category)
                        .emoji,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: post.tags
                    .map((t) => Chip(
                          label: Text('#$t'),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.hasHugged ? Icons.favorite : Icons.favorite_border,
                    color: post.hasHugged ? Colors.red : null,
                  ),
                  onPressed: () {},
                ),
                Text('${post.hugCount}'),
                const SizedBox(width: 16),
                const Icon(Icons.comment_outlined, size: 20),
                const SizedBox(width: 4),
                Text('${post.replyCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${(d.inDays / 7).floor()}w ago';
  }
}
