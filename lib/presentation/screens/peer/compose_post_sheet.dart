// lib/presentation/screens/peer/compose_post_sheet.dart
//
// Bottom sheet for composing new peer support posts.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/peer_models.dart';
import '../../../../data/services/peer_support_service.dart';

final _service = PeerSupportService();

final selectedCategoryProvider = StateProvider<String>((ref) => 'general');

class ComposePostSheet extends ConsumerStatefulWidget {
  final String userId;
  final AnonymousIdentity identity;

  const ComposePostSheet({
    super.key,
    required this.userId,
    required this.identity,
  });

  @override
  ConsumerState<ComposePostSheet> createState() => _ComposePostSheetState();
}

class _ComposePostSheetState extends ConsumerState<ComposePostSheet> {
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  String _selectedCategory = 'general';
  bool _isLoading = false;
  bool _hasCrisis = false;

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_contentController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      await _service.createPost(
        userId: widget.userId,
        anonHandle: widget.identity.handle,
        anonAvatar: widget.identity.avatar,
        content: _contentController.text.trim(),
        language: 'en',
        category: _selectedCategory,
        tags: tags,
        hasCrisis: _hasCrisis,
        isFlagged: false,
      );

      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(widget.identity.avatar,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(widget.identity.handle,
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: _contentController.text.trim().isEmpty || _isLoading
                    ? null
                    : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Post'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Share what's on your mind...",
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              hintText: "Tags (comma separated)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: kPeerCategories
                .map((c) => ChoiceChip(
                      label: Text('${c.emoji} ${c.labelEn}'),
                      selected: _selectedCategory == c.id,
                      onSelected: (s) =>
                          setState(() => _selectedCategory = c.id),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _hasCrisis,
                onChanged: (v) => setState(() => _hasCrisis = v ?? false),
              ),
              const Text('I need crisis support'),
            ],
          ),
        ],
      ),
    );
  }
}
