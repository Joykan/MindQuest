/// Sync Service for Real-Time Data Synchronization
///
/// Handles offline-first synchronization, queue management,
/// and conflict resolution between local and remote data.
library;

import 'dart:async';
import '../services/logger_service.dart';

class SyncEvent {
  final String id;
  final String entityType; // 'mood', 'user', 'badge', etc.
  final String action; // 'create', 'update', 'delete'
  final Map<String, dynamic> data;
  final DateTime timestamp;
  bool synced;

  SyncEvent({
    required this.id,
    required this.entityType,
    required this.action,
    required this.data,
    required this.timestamp,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'entityType': entityType,
        'action': action,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'synced': synced,
      };
}

class SyncStatus {
  final bool isOnline;
  final int pendingSyncCount;
  final DateTime? lastSyncTime;
  final Duration? lastSyncDuration;
  final String? lastError;

  SyncStatus({
    required this.isOnline,
    required this.pendingSyncCount,
    this.lastSyncTime,
    this.lastSyncDuration,
    this.lastError,
  });
}

class SyncService {
  final dynamic supabaseService;
  final LoggerService logger;

  final List<SyncEvent> _syncQueue = [];
  late StreamController<SyncStatus> _statusController;
  Timer? _syncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Duration? _lastSyncDuration;
  String? _lastError;
  final bool _isOnline = true;

  SyncService({
    required this.supabaseService,
    required this.logger,
  }) {
    _statusController = StreamController<SyncStatus>.broadcast();
    _initializeSyncListener();
  }

  /// Stream of sync status changes
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// Get current sync status
  SyncStatus getStatus() {
    return SyncStatus(
      isOnline: _isOnline,
      pendingSyncCount: _syncQueue.length,
      lastSyncTime: _lastSyncTime,
      lastSyncDuration: _lastSyncDuration,
      lastError: _lastError,
    );
  }

  /// Queue an event for sync
  void queueEvent(
    String entityType,
    String action, {
    required Map<String, dynamic> data,
  }) {
    final event = SyncEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      entityType: entityType,
      action: action,
      data: data,
      timestamp: DateTime.now(),
    );

    _syncQueue.add(event);
    logger.info('Event queued: $entityType:$action');
    _updateStatus();

    // If online, attempt immediate sync
    if (_isOnline) {
      _attemptSync();
    }
  }

  /// Force sync now
  Future<void> syncNow() async {
    if (_isSyncing) {
      logger.info('Sync already in progress');
      return;
    }

    await _attemptSync();
  }

  /// Get pending sync queue
  List<SyncEvent> getPendingEvents() {
    return List.from(_syncQueue.where((e) => !e.synced));
  }

  /// Clear sync queue (use with caution)
  void clearQueue() {
    _syncQueue.clear();
    _updateStatus();
    logger.warning('Sync queue cleared');
  }

  /// Pause syncing (e.g., during heavy operations)
  void pauseSync() {
    _syncTimer?.cancel();
    logger.info('Sync paused');
  }

  /// Resume syncing
  void resumeSync() {
    _initializeSyncListener();
    logger.info('Sync resumed');
  }

  // ─────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────

  void _initializeSyncListener() {
    // Sync every 30 seconds if online and events are pending
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_isOnline && _syncQueue.isNotEmpty && !_isSyncing) {
        await _attemptSync();
      }
    });

    logger.info('Sync listener initialized');
  }

  Future<void> _attemptSync() async {
    if (_isSyncing || _syncQueue.isEmpty) return;

    _isSyncing = true;
    final startTime = DateTime.now();

    try {
      logger.info('Starting sync of ${_syncQueue.length} pending events');

      final unsyncedEvents = _syncQueue.where((e) => !e.synced).toList();

      for (final event in unsyncedEvents) {
        try {
          await _syncEvent(event);
          event.synced = true;
          logger.debug(
            'Synced: ${event.entityType}:${event.action} (${event.id})',
          );
        } catch (e, st) {
          logger.error('Failed to sync event ${event.id}', e, st);
          _lastError = e.toString();
          break; // Stop on first failure to maintain order
        }
      }

      // Remove synced events from queue
      _syncQueue.removeWhere((e) => e.synced);

      _lastSyncTime = DateTime.now();
      _lastSyncDuration = DateTime.now().difference(startTime);
      _lastError = null;

      logger.info(
        'Sync completed in ${_lastSyncDuration?.inMilliseconds}ms. '
        'Queue size: ${_syncQueue.length}',
      );
    } catch (e, st) {
      logger.error('Sync operation failed', e, st);
      _lastError = e.toString();
    } finally {
      _isSyncing = false;
      _updateStatus();
    }
  }

  Future<void> _syncEvent(SyncEvent event) async {
    // Mock sync - replace with actual implementation
    await Future.delayed(const Duration(milliseconds: 500));

    if (event.data.isEmpty) {
      throw Exception('Invalid event data');
    }
  }

  void _updateStatus() {
    _statusController.add(getStatus());
  }

  void dispose() {
    _syncTimer?.cancel();
    _statusController.close();
  }
}
