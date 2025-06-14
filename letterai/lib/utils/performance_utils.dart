// Performance optimization utilities
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/error_handler.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  static PerformanceMonitor get instance => _instance;

  final Map<String, DateTime> _startTimes = {};
  final Map<String, List<Duration>> _measurements = {};
  final Logger _logger = Logger();

  // Start timing an operation
  void startTiming(String operationName) {
    _startTimes[operationName] = DateTime.now();
  }

  // End timing and log results
  Duration endTiming(String operationName) {
    final startTime = _startTimes[operationName];
    if (startTime == null) {
      _logger.warning(
        'No start time found for operation: $operationName',
        className: 'PerformanceMonitor',
        methodName: 'endTiming',
      );
      return Duration.zero;
    }

    final duration = DateTime.now().difference(startTime);
    _startTimes.remove(operationName);

    // Store measurement
    _measurements.putIfAbsent(operationName, () => []).add(duration);

    // Log if operation is slow
    if (duration.inMilliseconds > 1000) {
      _logger.warning(
        'Slow operation detected: $operationName took ${duration.inMilliseconds}ms',
        className: 'PerformanceMonitor',
        methodName: 'endTiming',
        metadata: {'duration_ms': duration.inMilliseconds},
      );
    } else if (kDebugMode) {
      _logger.debug(
        'Operation completed: $operationName took ${duration.inMilliseconds}ms',
        className: 'PerformanceMonitor',
        methodName: 'endTiming',
        metadata: {'duration_ms': duration.inMilliseconds},
      );
    }

    return duration;
  }

  // Get performance statistics
  Map<String, Map<String, dynamic>> getStatistics() {
    final stats = <String, Map<String, dynamic>>{};

    for (final entry in _measurements.entries) {
      final durations = entry.value;
      if (durations.isEmpty) continue;

      final totalMs = durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
      final avgMs = totalMs / durations.length;
      final minMs = durations.map((d) => d.inMilliseconds).reduce((a, b) => a < b ? a : b);
      final maxMs = durations.map((d) => d.inMilliseconds).reduce((a, b) => a > b ? a : b);

      stats[entry.key] = {
        'count': durations.length,
        'total_ms': totalMs,
        'average_ms': avgMs.round(),
        'min_ms': minMs,
        'max_ms': maxMs,
      };
    }

    return stats;
  }

  // Clear all measurements
  void clearMeasurements() {
    _measurements.clear();
    _startTimes.clear();
  }
}

// Caching system for improved performance
class CacheManager<T> {
  final Map<String, CacheEntry<T>> _cache = {};
  final Duration _defaultTtl;
  final int _maxSize;

  CacheManager({
    Duration defaultTtl = const Duration(minutes: 15),
    int maxSize = 100,
  })  : _defaultTtl = defaultTtl,
        _maxSize = maxSize;

  void put(String key, T value, {Duration? ttl}) {
    // Remove oldest entries if cache is full
    if (_cache.length >= _maxSize) {
      _removeOldestEntry();
    }

    _cache[key] = CacheEntry(
      value: value,
      timestamp: DateTime.now(),
      ttl: ttl ?? _defaultTtl,
    );
  }

  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check if entry has expired
    if (DateTime.now().difference(entry.timestamp) > entry.ttl) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  bool contains(String key) {
    return get(key) != null;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  void _removeOldestEntry() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.timestamp.isBefore(oldestTime)) {
        oldestTime = entry.value.timestamp;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }

  int get size => _cache.length;
  
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    int expiredCount = 0;
    
    for (final entry in _cache.values) {
      if (now.difference(entry.timestamp) > entry.ttl) {
        expiredCount++;
      }
    }
    
    return {
      'total_entries': _cache.length,
      'expired_entries': expiredCount,
      'max_size': _maxSize,
      'default_ttl_minutes': _defaultTtl.inMinutes,
    };
  }
}

class CacheEntry<T> {
  final T value;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry({
    required this.value,
    required this.timestamp,
    required this.ttl,
  });
}

// Debouncer for reducing frequent API calls
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Throttler for limiting function execution frequency
class Throttler {
  final Duration interval;
  DateTime? _lastExecution;

  Throttler({required this.interval});

  bool canExecute() {
    final now = DateTime.now();
    if (_lastExecution == null || 
        now.difference(_lastExecution!) >= interval) {
      _lastExecution = now;
      return true;
    }
    return false;
  }

  void call(VoidCallback callback) {
    if (canExecute()) {
      callback();
    }
  }
}

// Memory usage monitoring
class MemoryMonitor {
  static final Logger _logger = Logger();

  static Future<void> logMemoryUsage(String context) async {
    if (kDebugMode) {
      try {
        final memoryInfo = await DeviceInfoService.getMemoryInfo();
        _logger.debug(
          'Memory usage at $context',
          className: 'MemoryMonitor',
          methodName: 'logMemoryUsage',
          metadata: memoryInfo,
        );
      } catch (e) {
        _logger.warning(
          'Failed to get memory info',
          className: 'MemoryMonitor',
          methodName: 'logMemoryUsage',
          error: e,
        );
      }
    }
  }

  static void checkMemoryThreshold({double thresholdPercent = 80.0}) async {
    try {
      final memoryInfo = await DeviceInfoService.getMemoryInfo();
      final usedPercent = memoryInfo['memory_used_percent'] as double?;
      
      if (usedPercent != null && usedPercent > thresholdPercent) {
        _logger.warning(
          'High memory usage detected: ${usedPercent.toStringAsFixed(1)}%',
          className: 'MemoryMonitor',
          methodName: 'checkMemoryThreshold',
          metadata: {'threshold': thresholdPercent, 'current': usedPercent},
        );
      }
    } catch (e) {
      _logger.error(
        'Failed to check memory threshold',
        className: 'MemoryMonitor',
        methodName: 'checkMemoryThreshold',
        error: e,
      );
    }
  }
}

// Device info service for performance monitoring
class DeviceInfoService {
  static Future<Map<String, dynamic>> getMemoryInfo() async {
    // This is a simplified implementation
    // In a real app, you'd use device_info_plus package
    return {
      'memory_used_percent': 45.0,
      'available_memory_mb': 1024,
      'total_memory_mb': 2048,
    };
  }

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    return {
      'platform': defaultTargetPlatform.name,
      'is_physical_device': !kIsWeb,
      'debug_mode': kDebugMode,
      'profile_mode': kProfileMode,
      'release_mode': kReleaseMode,
    };
  }
}

// Performance utilities
class PerformanceUtils {
  static final PerformanceMonitor _monitor = PerformanceMonitor.instance;

  // Measure function execution time
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    _monitor.startTiming(operationName);
    try {
      final result = await operation();
      return result;
    } finally {
      _monitor.endTiming(operationName);
    }
  }

  // Measure synchronous function execution time
  static T measureSync<T>(
    String operationName,
    T Function() operation,
  ) {
    _monitor.startTiming(operationName);
    try {
      final result = operation();
      return result;
    } finally {
      _monitor.endTiming(operationName);
    }
  }

  // Batch operations for better performance
  static Future<List<T>> batchProcess<T, R>(
    List<T> items,
    Future<R> Function(T) processor, {
    int batchSize = 10,
    Duration batchDelay = const Duration(milliseconds: 100),
  }) async {
    final results = <T>[];
    
    for (int i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize).toList();
      
      for (final item in batch) {
        await processor(item);
        results.add(item);
      }
      
      // Small delay between batches to prevent blocking UI
      if (i + batchSize < items.length) {
        await Future.delayed(batchDelay);
      }
    }
    
    return results;
  }
}
