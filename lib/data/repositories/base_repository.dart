/// Base Repository Interface
///
/// Defines the contract for all repository implementations.
/// Repositories act as the data layer abstraction between
/// business logic and data sources.
library;

abstract class BaseRepository {
  /// Initialize repository resources
  Future<void> initialize();

  /// Dispose of repository resources
  Future<void> dispose();

  /// Check if repository is available (has connection/perms)
  Future<bool> isAvailable();
}

/// Exception wrapper for repository errors
class RepositoryException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  RepositoryException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'RepositoryException: $message';
}
