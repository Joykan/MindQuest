// lib/data/services/peer_support_service.dart
//
// Supabase data layer for the anonymous Peer Support Forum.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/peer_models.dart';

class PeerSupportService {
  static final PeerSupportService _i = PeerSupportService._();
  factory PeerSupportService() => _i;
  PeerSupportService._();

  SupabaseClient get _db => Supabase.instance.client;

  // ── Posts ─────────────────────────────────────────────────────────────────

  Future<List<PeerPost>> getPosts({
    String? category,
    int limit = 25,
    int offset = 0,
    String? currentUserId,
  }) async {
    try {
      var query = _db
          .from('peer_posts')
          .select('*, peer_hugs(user_id)')
          .eq('is_approved', true)
          .eq('is_flagged', false);

// Apply category filter BEFORE range() - filters must come before range
      if (category != null) query = query.eq('category', category);

      final result = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (result as List).map((row) {
        final post = PeerPost.fromJson(row as Map<String, dynamic>);
        if (currentUserId != null) {
          final hugs = row['peer_hugs'] as List? ?? [];
          post.hasHugged = hugs.any((h) => h['user_id'] == currentUserId);
        }
        return post;
      }).toList();
    } catch (_) {
      return _seedPosts();
    }
  }

  Future<PeerPost> createPost({
    required String userId,
    required String anonHandle,
    required String anonAvatar,
    required String content,
    required String language,
    required String category,
    required List<String> tags,
    required bool hasCrisis,
    required bool isFlagged,
  }) async {
    try {
      final row = await _db
          .from('peer_posts')
          .insert({
            'user_id': userId,
            'anon_handle': anonHandle,
            'anon_avatar': anonAvatar,
            'content': content,
            'language': language,
            'category': category,
            'tags': tags,
            'has_crisis': hasCrisis,
            'is_flagged': isFlagged,
            'is_approved': !isFlagged && !hasCrisis,
            'hug_count': 0,
            'reply_count': 0,
          })
          .select()
          .single();
      return PeerPost.fromJson(row);
    } catch (_) {
      // Offline fallback — return local post
      return PeerPost(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        anonHandle: anonHandle,
        anonAvatar: anonAvatar,
        content: content,
        language: language,
        category: category,
        tags: tags,
        hasCrisis: hasCrisis,
        isFlagged: isFlagged,
        isApproved: !isFlagged && !hasCrisis,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> reportPost({
    required String postId,
    required String userId,
    required String reason,
  }) async {
    try {
      await _db.from('peer_reports').upsert({
        'post_id': postId,
        'reporter_id': userId,
        'reason': reason,
      });
      await _db
          .from('peer_posts')
          .update({'is_flagged': true}).eq('id', postId);
    } catch (_) {}
  }

  // ── Hugs (upvotes) ────────────────────────────────────────────────────────

  Future<void> hugPost({required String postId, required String userId}) async {
    try {
      await _db
          .from('peer_hugs')
          .upsert({'post_id': postId, 'user_id': userId});
      await _db.rpc('increment_peer_hugs', params: {'p_post_id': postId});
    } catch (_) {}
  }

  Future<void> unHugPost(
      {required String postId, required String userId}) async {
    try {
      await _db
          .from('peer_hugs')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      await _db.rpc('decrement_peer_hugs', params: {'p_post_id': postId});
    } catch (_) {}
  }

  // ── Replies ───────────────────────────────────────────────────────────────

  Future<List<PeerReply>> getReplies(
    String postId, {
    String? currentUserId,
  }) async {
    try {
      final data = await _db
          .from('peer_replies')
          .select('*, peer_reply_hugs(user_id)')
          .eq('post_id', postId)
          .eq('is_approved', true)
          .order('created_at');

      return (data as List).map((row) {
        final reply = PeerReply.fromJson(row as Map<String, dynamic>);
        if (currentUserId != null) {
          final hugs = row['peer_reply_hugs'] as List? ?? [];
          reply.hasHugged = hugs.any((h) => h['user_id'] == currentUserId);
        }
        return reply;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<PeerReply> createReply({
    required String postId,
    required String userId,
    required String anonHandle,
    required String anonAvatar,
    required String content,
    required String language,
    required bool hasCrisis,
    required bool isFlagged,
  }) async {
    try {
      final row = await _db
          .from('peer_replies')
          .insert({
            'post_id': postId,
            'user_id': userId,
            'anon_handle': anonHandle,
            'anon_avatar': anonAvatar,
            'content': content,
            'language': language,
            'has_crisis': hasCrisis,
            'is_flagged': isFlagged,
            'is_approved': !isFlagged && !hasCrisis,
            'hug_count': 0,
          })
          .select()
          .single();

      await _db
          .rpc('increment_peer_reply_count', params: {'p_post_id': postId});
      return PeerReply.fromJson(row);
    } catch (_) {
      return PeerReply(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        postId: postId,
        userId: userId,
        anonHandle: anonHandle,
        anonAvatar: anonAvatar,
        content: content,
        language: language,
        isApproved: !isFlagged,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> hugReply(
      {required String replyId, required String userId}) async {
    try {
      await _db
          .from('peer_reply_hugs')
          .upsert({'reply_id': replyId, 'user_id': userId});
      await _db
          .rpc('increment_peer_reply_hugs', params: {'p_reply_id': replyId});
    } catch (_) {}
  }

  Future<void> unHugReply(
      {required String replyId, required String userId}) async {
    try {
      await _db
          .from('peer_reply_hugs')
          .delete()
          .eq('reply_id', replyId)
          .eq('user_id', userId);
      await _db
          .rpc('decrement_peer_reply_hugs', params: {'p_reply_id': replyId});
    } catch (_) {}
  }

// ── Real-time ─────────────────────────────────────────────────────────────

  RealtimeChannel subscribeToNewPosts(void Function(PeerPost) onNew) {
    return _db
        .channel('peer_posts_live')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'peer_posts',
          callback: (payload) {
            try {
              final record = payload.newRecord;
              // Only notify for approved posts
              if (record['is_approved'] == true) {
                onNew(PeerPost.fromJson(record));
              }
            } catch (_) {}
          },
        )
        .subscribe();
  }

  // ── Seed data (offline / empty DB fallback) ───────────────────────────────

  List<PeerPost> _seedPosts() => [
        PeerPost(
          id: 'seed_1',
          userId: 'anon',
          anonHandle: 'Brave Lion',
          anonAvatar: '🦁',
          content:
              "I failed my KCSE mock and my parents don't know yet. The guilt is eating me "
              'alive. Has anyone been through this?',
          language: 'en',
          category: 'school',
          tags: ['KCSE', 'family', 'guilt'],
          hugCount: 14,
          replyCount: 6,
          isApproved: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        PeerPost(
          id: 'seed_2',
          userId: 'anon',
          anonHandle: 'Gentle Crane',
          anonAvatar: '🦅',
          content:
              'Nimefika siku 7 bila kulala vizuri. Kila usiku mawazo yanakuja kama mafuriko. '
              'Naweza kupumzika vipi?',
          language: 'sw',
          category: 'anxiety',
          tags: ['usingizi', 'wasiwasi'],
          hugCount: 9,
          replyCount: 4,
          isApproved: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 7)),
        ),
        PeerPost(
          id: 'seed_3',
          userId: 'anon',
          anonHandle: 'Hopeful Dolphin',
          anonAvatar: '🐬',
          content:
              "Small win: I finally told my mum I've been struggling with anxiety. "
              "She didn't fully understand but she hugged me. That was enough for today. 💙",
          language: 'en',
          category: 'celebration',
          tags: ['family', 'progress'],
          hugCount: 31,
          replyCount: 12,
          isApproved: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 11)),
        ),
        PeerPost(
          id: 'seed_4',
          userId: 'anon',
          anonHandle: 'Calm Elephant',
          anonAvatar: '🐘',
          content:
              "When the pressure to hustle gets too heavy, I take a 10-minute walk without "
              "my phone. It sounds basic but it genuinely resets me. What's your go-to coping tip?",
          language: 'en',
          category: 'coping',
          tags: ['hustle', 'stress', 'tips'],
          hugCount: 22,
          replyCount: 8,
          isApproved: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        PeerPost(
          id: 'seed_5',
          userId: 'anon',
          anonHandle: 'Quiet Owl',
          anonAvatar: '🦉',
          content:
              'Familia yangu inategemea mimi sana kiuchumi na sina hata miaka 23. '
              'Ninajisikia mzigo lakini pia ninawapenda. Ni hali ngumu sana.',
          language: 'sw',
          category: 'family',
          tags: ['pesa', 'mzigo', 'familia'],
          hugCount: 17,
          replyCount: 5,
          isApproved: true,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
}
