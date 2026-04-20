/// Advanced Logging Service
///
/// Provides structured logging with multiple levels and output targets.
/// Useful for debugging, analytics, and production monitoring.
library;

import 'package:logger/logger.dart';

enum LogLevel { debug, info, warning, error, critical }

class LoggerService {
  late final Logger _logger;
  final List<LogEntry> _logHistory = [];
  static const int _maxHistorySize = 500;

  LoggerService() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
    );
  }

  /// Log a debug message
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
    _addToHistory(LogLevel.debug, message, error, stackTrace);
  }

  /// Log an info message
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
    _addToHistory(LogLevel.info, message, error, stackTrace);
  }

  /// Log a warning message
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    _addToHistory(LogLevel.warning, message, error, stackTrace);
  }

  /// Log an error
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _addToHistory(LogLevel.error, message, error, stackTrace);
  }

  /// Log a critical error (will crash the app in production)
  void critical(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _addToHistory(LogLevel.critical, message, error, stackTrace);
  }

  /// Add entry to history with size limit
  void _addToHistory(
    LogLevel level,
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    _logHistory.add(
      LogEntry(
        timestamp: DateTime.now(),
        level: level,
        message: message,
        error: error?.toString(),
        stackTrace: stackTrace?.toString(),
      ),
    );

    // Keep history size manageable
    if (_logHistory.length > _maxHistorySize) {
      _logHistory.removeAt(0);
    }
  }

  /// Get log history
  List<LogEntry> getLogHistory({
    LogLevel? filterLevel,
    int limit = 100,
  }) {
    var logs = _logHistory;
    if (filterLevel != null) {
      logs = logs.where((log) => log.level == filterLevel).toList();
    }
    return logs.reversed.take(limit).toList();
  }

  /// Clear log history
  void clearHistory() => _logHistory.clear();

  /// Export logs as string
  String exportLogs() {
    final buffer = StringBuffer();
    for (final log in _logHistory) {
      buffer.writeln(
        '[${log.timestamp}] ${log.level.name.toUpperCase()}: ${log.message}',
      );
      if (log.error != null) {
        buffer.writeln('Error: ${log.error}');
      }
    }
    return buffer.toString();
  }
}

/// Log entry model
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? error;
  final String? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });
}
