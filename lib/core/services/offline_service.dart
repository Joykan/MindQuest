// lib/core/services/offline_service.dart
// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Offline-first service using Hive for local storage
/// and connectivity_plus for network detection.
class OfflineService {
  static const String _boxName = 'mindquest_offline';
  static const String _pendingQueueKey = 'pending_queue';
  static const String _cachedMoodsKey = 'cached_moods';
  static const String _cachedProfileKey = 'cached_profile';

  Box? _box;
  StreamSubscription? _connectivitySub;
  bool _isOnline = true;

  // Singleton
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    await _checkConnectivity();
    _listenToConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
  }

  void _listenToConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      final wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;

      // If we just came back online, trigger sync
      if (wasOffline && _isOnline) {
        _onBackOnline();
      }
    });
  }

  void _onBackOnline() {
    // Trigger sync of any pending offline actions
    // This would notify the SyncService to flush its queue
  }

  bool get isOnline => _isOnline;

  // ── Generic cache operations ────────────────────────────

  Future<void> saveData(String key, dynamic value) async {
    await _box?.put(
        key, value is Map || value is List ? jsonEncode(value) : value);
  }

  T? getData<T>(String key) {
    final raw = _box?.get(key);
    if (raw == null) return null;
    if (T == Map || T == List) {
      try {
        return jsonDecode(raw as String) as T;
      } catch (_) {
        return null;
      }
    }
    return raw as T?;
  }

  Future<void> deleteData(String key) async {
    await _box?.delete(key);
  }

  // ── Pending sync queue ──────────────────────────────────

  Future<void> addToPendingQueue(Map<String, dynamic> action) async {
    final existing = _getPendingQueue();
    existing.add(action);
    await _box?.put(_pendingQueueKey, jsonEncode(existing));
  }

  List<Map<String, dynamic>> _getPendingQueue() {
    final raw = _box?.get(_pendingQueueKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw as String) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> getPendingQueue() => _getPendingQueue();

  Future<void> clearPendingQueue() async {
    await _box?.delete(_pendingQueueKey);
  }

  // ── Cached mood logs ────────────────────────────────────

  Future<void> cacheMoodLogs(List<Map<String, dynamic>> logs) async {
    await _box?.put(_cachedMoodsKey, jsonEncode(logs));
  }

  List<Map<String, dynamic>> getCachedMoodLogs() {
    final raw = _box?.get(_cachedMoodsKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw as String) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  // ── Cached profile ──────────────────────────────────────

  Future<void> cacheProfile(Map<String, dynamic> profile) async {
    await _box?.put(_cachedProfileKey, jsonEncode(profile));
  }

  Map<String, dynamic>? getCachedProfile() {
    final raw = _box?.get(_cachedProfileKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Cleanup ─────────────────────────────────────────────

  Future<void> clearAll() async {
    await _box?.clear();
  }

  void dispose() {
    _connectivitySub?.cancel();
    _box?.close();
  }
}
