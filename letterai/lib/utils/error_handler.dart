// Comprehensive error handling and logging system
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/environment_config.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? className;
  final String? methodName;
  final dynamic error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.className,
    this.methodName,
    this.error,
    this.stackTrace,
    this.metadata,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write('[${level.name.toUpperCase()}] ');
    
    if (className != null) {
      buffer.write('[$className');
      if (methodName != null) {
        buffer.write('.$methodName');
      }
      buffer.write('] ');
    }
    
    buffer.write(message);
    
    if (error != null) {
      buffer.write(' - Error: $error');
    }
    
    if (metadata != null && metadata!.isNotEmpty) {
      buffer.write(' - Metadata: $metadata');
    }
    
    return buffer.toString();
  }
}

class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  final List<LogEntry> _logs = [];
  final int _maxLogs = 1000;

  static Logger get instance => _instance;

  // Core logging method
  void _log(
    LogLevel level,
    String message, {
    String? className,
    String? methodName,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      className: className,
      methodName: methodName,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );

    _logs.add(entry);

    // Keep logs under limit
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    // Output to console in debug mode
    if (EnvironmentConfig.instance.debugMode || kDebugMode) {
      debugPrint(entry.toString());
      
      if (stackTrace != null && level.index >= LogLevel.error.index) {
        debugPrint('Stack trace:\n$stackTrace');
      }
    }

    // Handle critical errors
    if (level == LogLevel.critical) {
      _handleCriticalError(entry);
    }
  }

  // Public logging methods
  void debug(
    String message, {
    String? className,
    String? methodName,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.debug,
      message,
      className: className,
      methodName: methodName,
      metadata: metadata,
    );
  }

  void info(
    String message, {
    String? className,
    String? methodName,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.info,
      message,
      className: className,
      methodName: methodName,
      metadata: metadata,
    );
  }

  void warning(
    String message, {
    String? className,
    String? methodName,
    dynamic error,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.warning,
      message,
      className: className,
      methodName: methodName,
      error: error,
      metadata: metadata,
    );
  }

  void error(
    String message, {
    String? className,
    String? methodName,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.error,
      message,
      className: className,
      methodName: methodName,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  void critical(
    String message, {
    String? className,
    String? methodName,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.critical,
      message,
      className: className,
      methodName: methodName,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  // Get logs for debugging or reporting
  List<LogEntry> getLogs({LogLevel? minLevel}) {
    if (minLevel == null) return List.from(_logs);
    
    return _logs.where((log) => log.level.index >= minLevel.index).toList();
  }

  // Clear logs
  void clearLogs() {
    _logs.clear();
  }

  // Export logs for support
  String exportLogs({LogLevel? minLevel}) {
    final logsToExport = getLogs(minLevel: minLevel);
    return logsToExport.map((log) => log.toString()).join('\n');
  }

  // Handle critical errors
  void _handleCriticalError(LogEntry entry) {
    // In a production app, you might want to:
    // 1. Report to crash analytics
    // 2. Show user-friendly error dialog
    // 3. Attempt automatic recovery
    
    if (kDebugMode) {
      debugPrint('CRITICAL ERROR: ${entry.message}');
      if (entry.error != null) {
        debugPrint('Error details: ${entry.error}');
      }
      if (entry.stackTrace != null) {
        debugPrint('Stack trace:\n${entry.stackTrace}');
      }
    }
  }
}

// Custom exception classes
class LetterAIException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const LetterAIException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('LetterAIException: $message');
    if (code != null) {
      buffer.write(' (Code: $code)');
    }
    if (originalError != null) {
      buffer.write(' - Original: $originalError');
    }
    return buffer.toString();
  }
}

class StorageException extends LetterAIException {
  const StorageException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class AIServiceException extends LetterAIException {
  const AIServiceException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class PDFGenerationException extends LetterAIException {
  const PDFGenerationException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// Error handling utilities
class ErrorHandler {
  static final Logger _logger = Logger.instance;

  static void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    String? className,
    String? methodName,
    bool isCritical = false,
    Map<String, dynamic>? metadata,
  }) {
    final errorMessage = _buildErrorMessage(error, context);
    
    if (isCritical) {
      _logger.critical(
        errorMessage,
        className: className,
        methodName: methodName,
        error: error,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    } else {
      _logger.error(
        errorMessage,
        className: className,
        methodName: methodName,
        error: error,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    }
  }

  static String _buildErrorMessage(dynamic error, String? context) {
    final buffer = StringBuffer();
    
    if (context != null) {
      buffer.write('$context: ');
    }
    
    if (error is LetterAIException) {
      buffer.write(error.message);
      if (error.code != null) {
        buffer.write(' (${error.code})');
      }
    } else if (error is PlatformException) {
      buffer.write('Platform error: ${error.message} (${error.code})');
    } else {
      buffer.write(error.toString());
    }
    
    return buffer.toString();
  }

  static String getUserFriendlyMessage(dynamic error) {
    if (error is StorageException) {
      return 'Unable to save your data. Please try again.';
    } else if (error is AIServiceException) {
      return 'AI service is currently unavailable. Please try again later.';
    } else if (error is PDFGenerationException) {
      return 'Unable to generate PDF. Please try again.';
    } else if (error is PlatformException) {
      switch (error.code) {
        case 'network_error':
          return 'No internet connection. Please check your network and try again.';
        case 'permission_denied':
          return 'Permission required to complete this action.';
        default:
          return 'An unexpected error occurred. Please try again.';
      }
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
}
