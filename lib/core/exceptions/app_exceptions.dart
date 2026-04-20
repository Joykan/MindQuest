// ignore_for_file: avoid_shadowing_type_parameters

/// Advanced Error Handling & Custom Exceptions
///
/// Provides comprehensive error handling with custom exception types,
/// error recovery strategies, and user-friendly error messages.
library;

/// Base exception for the application
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final int? errorCode;

  AppException({
    required this.message,
    this.originalError,
    this.stackTrace,
    this.errorCode,
  });

  /// User-friendly error message
  String getUserMessage(String language) {
    return message;
  }

  /// Log-friendly error details
  String getLogMessage() {
    final buffer = StringBuffer();
    buffer.writeln('Exception: $runtimeType');
    buffer.writeln('Message: $message');
    if (errorCode != null) buffer.writeln('Code: $errorCode');
    if (originalError != null) buffer.writeln('Original: $originalError');
    if (stackTrace != null) buffer.writeln('Stack: $stackTrace');
    return buffer.toString();
  }

  @override
  String toString() => message;
}

/// Authentication-related errors
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.errorCode,
  });

  @override
  String getUserMessage(String language) {
    if (message.contains('Invalid credentials')) {
      return language == 'sw'
          ? 'Jina la mtumiaji au neno la siri ni sahihi'
          : 'Invalid username or password';
    }
    if (message.contains('User not found')) {
      return language == 'sw' ? 'Mtumiaji haipo' : 'User not found';
    }
    if (message.contains('Email already exists')) {
      return language == 'sw'
          ? 'Barua pepe imetumika tayari'
          : 'Email already registered';
    }
    return language == 'sw' ? 'Hitilafu ya ushahidi' : 'Authentication error';
  }
}

/// Data-related errors
class DataException extends AppException {
  DataException({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.errorCode,
  });

  @override
  String getUserMessage(String language) {
    if (message.contains('not found')) {
      return language == 'sw' ? 'Data haipo' : 'Data not found';
    }
    if (message.contains('Permission denied')) {
      return language == 'sw'
          ? 'Huna ruhusa ya kufikiri data hii'
          : 'Permission denied';
    }
    return language == 'sw' ? 'Hitilafu ya data' : 'Data error';
  }
}

/// Network-related errors
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.errorCode,
  });

  @override
  String getUserMessage(String language) {
    if (message.contains('No internet')) {
      return language == 'sw'
          ? 'Hakuna muunganisho wa mtandao'
          : 'No internet connection';
    }
    if (message.contains('Timeout')) {
      return language == 'sw'
          ? 'Ombi lilixweka kwa muda mrefu'
          : 'Request timeout';
    }
    if (message.contains('Server error')) {
      return language == 'sw' ? 'Hitilafu ya seva' : 'Server error';
    }
    return language == 'sw' ? 'Hitilafu ya mtandao' : 'Network error';
  }
}

/// Validation-related errors
class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  ValidationException({
    required super.message,
    required this.fieldErrors,
    super.originalError,
    super.stackTrace,
    super.errorCode,
  });

  @override
  String getUserMessage(String language) {
    return language == 'sw'
        ? 'Tafadhali angalia makosa ya uhalali'
        : 'Please check validation errors';
  }

  /// Get specific field error
  String? getFieldError(String fieldName, String language) {
    if (!fieldErrors.containsKey(fieldName)) return null;

    final error = fieldErrors[fieldName]!;
    if (language == 'sw') {
      // Translate error messages if needed
      if (error.contains('required')) return 'Sehemu hii inahitajika';
      if (error.contains('invalid')) return 'Thamani si sahihi';
    }
    return error;
  }
}

/// Business logic-related errors
class BusinessException extends AppException {
  BusinessException({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.errorCode,
  });

  @override
  String getUserMessage(String language) {
    return message;
  }
}

/// API-related errors
class ApiException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  ApiException({
    required super.message,
    this.statusCode,
    this.responseData,
    super.originalError,
    super.stackTrace,
    super.errorCode,
  });

  @override
  String getUserMessage(String language) {
    switch (statusCode) {
      case 400:
        return language == 'sw' ? 'Ombi mbaya' : 'Bad request';
      case 401:
        return language == 'sw' ? 'Silizidthibiti' : 'Unauthorized';
      case 403:
        return language == 'sw' ? 'Ruhusa imekataliwa' : 'Forbidden';
      case 404:
        return language == 'sw' ? 'Haipo' : 'Not found';
      case 429:
        return language == 'sw'
            ? 'Maombi mengi. Tafadhali jaribu baadaye'
            : 'Too many requests. Try again later';
      case 500:
      case 502:
      case 503:
        return language == 'sw'
            ? 'Hitilafu ya seva. Tafadhali jaribu baadaye'
            : 'Server error. Please try again later';
      default:
        return language == 'sw' ? 'Hitilafu ya API' : 'API error';
    }
  }

  /// Check if error is retryable
  bool isRetryable() {
    return statusCode != null &&
        (statusCode! >= 500 || statusCode == 429 || statusCode == 408);
  }

  /// Get retry delay in seconds
  int getRetryDelaySeconds(int attemptNumber) {
    // Exponential backoff: 1s, 2s, 4s, 8s, 16s
    return (1 << attemptNumber).clamp(1, 60);
  }
}

/// Crisis-related errors
class CrisisException extends AppException {
  final String crisisKeyword;
  final String detectedLanguage;
  final List<String> emergencyContacts;

  CrisisException({
    required super.message,
    required this.crisisKeyword,
    required this.detectedLanguage,
    required this.emergencyContacts,
    super.originalError,
    super.stackTrace,
  }) : super(
          errorCode: 999, // Special code for crisis
        );

  @override
  String getUserMessage(String language) {
    return language == 'sw'
        ? 'Matatizo ya kuzuia: jaribu kutumia simu ya haraka'
        : 'Crisis detected: Please call emergency services';
  }
}

/// Error recovery strategies
abstract class ErrorRecoveryStrategy {
  /// Attempt to recover from error
  Future<T> recover<T>();

  /// Check if recovery is possible
  bool canRecover();
}

/// Retry recovery strategy
class RetryRecoveryStrategy<T> extends ErrorRecoveryStrategy {
  final Future<T> Function() operation;
  final int maxAttempts;
  final Duration delayBetweenRetries;
  final bool Function(dynamic)? shouldRetry;

  RetryRecoveryStrategy({
    required this.operation,
    this.maxAttempts = 3,
    this.delayBetweenRetries = const Duration(seconds: 1),
    this.shouldRetry,
  });

  @override
  Future<T> recover<T>() async {
    int attempt = 0;
    dynamic lastError;

    while (attempt < maxAttempts) {
      try {
        final result = await operation();
        return result as T;
      } catch (e) {
        lastError = e;
        attempt++;

        // Check if should retry
        if (shouldRetry != null && !shouldRetry!(e)) {
          break;
        }

        if (attempt < maxAttempts) {
          await Future.delayed(delayBetweenRetries);
        }
      }
    }

    throw lastError;
  }

  @override
  bool canRecover() => maxAttempts > 1;
}

/// Fallback recovery strategy
class FallbackRecoveryStrategy<T> extends ErrorRecoveryStrategy {
  final Future<T> Function() primaryOperation;
  final Future<T> Function() fallbackOperation;

  FallbackRecoveryStrategy({
    required this.primaryOperation,
    required this.fallbackOperation,
  });

  @override
  Future<T> recover<T>() async {
    try {
      final result = await primaryOperation();
      return result as T;
    } catch (e) {
      final result = await fallbackOperation();
      return result as T;
    }
  }

  @override
  bool canRecover() => true;
}

/// Error handler utility
class ErrorHandler {
  /// Convert exception from external sources to app exceptions
  static AppException handleException(
    dynamic error,
    StackTrace? stackTrace, {
    String? fallbackMessage,
  }) {
    if (error is AppException) {
      return error;
    }

    final message = error is Exception
        ? error.toString()
        : fallbackMessage ?? 'Unknown error occurred';

    // Map common exceptions
    if (error is FormatException) {
      return ValidationException(
        message: 'Invalid data format',
        fieldErrors: {'data': 'Invalid format'},
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error.toString().contains('No internet')) {
      return NetworkException(
        message: 'No internet connection',
        originalError: error,
        stackTrace: stackTrace,
        errorCode: 0,
      );
    }

    // Default to generic business exception
    return BusinessException(
      message: message,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
