// lib/presentation/providers/peer_providers.dart
//
// Riverpod providers for the anonymous Peer Support Forum.
// Wraps PeerSupportService with state management and caching.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/peer_models.dart';
import '../../data/services/peer_support_service.dart';
import '../../data/services/supabase_service.dart';

// ── Re-export SupabaseService provider from main providers ─────────────────────
final supabaseServiceProvider =
    Provider<SupabaseService>((_) => SupabaseService());

// ── Service Provider ──────────────────────────────────────────────────────
final peerSupportServiceProvider = Provider<PeerSupportService>((_) {
  return PeerSupportService();
});

// ── Current User Identity ────────────────────────────────────────────────
final anonIdentityProvider = Provider<AnonymousIdentity?>((ref) {
  // This will be set by auth state when user logs in
  return null;
});

// ── Posts Providers ────────────────────────────────────────────────────────────
final peerPostsProvider =
    FutureProvider.family<List<PeerPost>, String?>((ref, category) async {
  final service = ref.watch(peerSupportServiceProvider);
  final userId = ref.watch(supabaseServiceProvider).currentUserId;
  return service.getPosts(
    category: category,
    currentUserId: userId,
  );
});

final peerPostsByCategoryProvider =
    FutureProvider.family<List<PeerPost>, String>((ref, category) async {
  final service = ref.watch(peerSupportServiceProvider);
  final userId = ref.watch(supabaseServiceProvider).currentUserId;
  return service.getPosts(
    category: category,
    currentUserId: userId,
  );
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Selected post for detail view
final selectedPostProvider = StateProvider<PeerPost?>((ref) => null);

// ── Replies Providers ────────────────────────────────────────────────────────────
final peerRepliesProvider =
    FutureProvider.family<List<PeerReply>, String>((ref, postId) async {
  final service = ref.watch(peerSupportServiceProvider);
  final userId = ref.watch(supabaseServiceProvider).currentUserId;
  return service.getReplies(postId, currentUserId: userId);
});

// ── Post Actions Notifier ─────────────────────────────────────────────────
class PostActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final PeerSupportService _service;
  final Ref _ref;

  PostActionsNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<bool> createPost({
    required String content,
    required String language,
    required String category,
    required List<String> tags,
    required bool hasCrisis,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = _ref.read(supabaseServiceProvider).currentUserId;
      if (userId == null) {
        state = AsyncValue.error('Not logged in', StackTrace.current);
        return false;
      }

      // Get or generate anonymous identity
      final anonId = generateAnonIdentity(userId);

      await _service.createPost(
        userId: userId,
        anonHandle: anonId.handle,
        anonAvatar: anonId.avatar,
        content: content,
        language: language,
        category: category,
        tags: tags,
        hasCrisis: hasCrisis,
        isFlagged: false,
      );

      state = const AsyncValue.data(null);
      // Invalidate posts to refresh
      _ref.invalidate(peerPostsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> hugPost(String postId) async {
    try {
      final userId = _ref.read(supabaseServiceProvider).currentUserId;
      if (userId == null) return;
      await _service.hugPost(postId: postId, userId: userId);
      _ref.invalidate(peerPostsProvider);
    } catch (_) {}
  }

  Future<void> unHugPost(String postId) async {
    try {
      final userId = _ref.read(supabaseServiceProvider).currentUserId;
      if (userId == null) return;
      await _service.unHugPost(postId: postId, userId: userId);
      _ref.invalidate(peerPostsProvider);
    } catch (_) {}
  }

  Future<void> reportPost(String postId, String reason) async {
    try {
      final userId = _ref.read(supabaseServiceProvider).currentUserId;
      if (userId == null) return;
      await _service.reportPost(postId: postId, userId: userId, reason: reason);
      _ref.invalidate(peerPostsProvider);
    } catch (_) {}
  }
}

final postActionsProvider =
    StateNotifierProvider<PostActionsNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(peerSupportServiceProvider);
  return PostActionsNotifier(service, ref);
});

// ── Reply Actions Notifier ───────────────────────────────────────────────
class ReplyActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final PeerSupportService _service;
  final Ref _ref;

  ReplyActionsNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<bool> createReply({
    required String postId,
    required String content,
    required String language,
    required bool hasCrisis,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = _ref.read(supabaseServiceProvider).currentUserId;
      if (userId == null) {
        state = AsyncValue.error('Not logged in', StackTrace.current);
        return false;
      }

      final anonId = generateAnonIdentity(userId);

      await _service.createReply(
        postId: postId,
        userId: userId,
        anonHandle: anonId.handle,
        anonAvatar: anonId.avatar,
        content: content,
        language: language,
        hasCrisis: hasCrisis,
        isFlagged: false,
      );

      state = const AsyncValue.data(null);
      _ref.invalidate(peerRepliesProvider(postId));
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> hugReply(String replyId) async {
    try {
      final userId = _ref.read(supabaseServiceProvider).currentUserId;
      if (userId == null) return;
      await _service.hugReply(replyId: replyId, userId: userId);
    } catch (_) {}
  }

  Future<void> unHugReply(String replyId) async {
    try {
      final userId = _ref.read(supabaseServiceProvider).currentUserId;
      if (userId == null) return;
      await _service.unHugReply(replyId: replyId, userId: userId);
    } catch (_) {}
  }
}

final replyActionsProvider =
    StateNotifierProvider<ReplyActionsNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(peerSupportServiceProvider);
  return ReplyActionsNotifier(service, ref);
});

// ── Real-time Posts Subscription ────────────────────────────���───────────────
final newPostsStreamProvider = StreamProvider<PeerPost>((ref) {
  final service = ref.watch(peerSupportServiceProvider);

  // Create a stream controller to handle the callback
  final controller = StreamController<PeerPost>();

  final channel = service.subscribeToNewPosts((post) {
    controller.add(post);
  });

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
});
