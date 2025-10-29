import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight helper to persist and query last-updated timestamps for keys.
///
/// Keys are namespaced internally; you can pass any string (e.g., 'device_info').
class LastUpdatedStore {
  LastUpdatedStore._();

  static const String _prefix = 'last_updated:';

  /// Returns the stored timestamp for [key] or null if not set.
  static Future<DateTime?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt('$_prefix$key');
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  /// Sets the timestamp for [key] to [time] (UTC).
  static Future<void> set(String key, DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix$key', time.toUtc().millisecondsSinceEpoch);
  }

  /// Convenience: sets the timestamp for [key] to now (UTC).
  static Future<void> setNow(String key) => set(key, DateTime.now().toUtc());

  /// Returns the age (now - stored) for [key], or null if not set.
  static Future<Duration?> age(String key, {DateTime? now}) async {
    final stored = await get(key);
    if (stored == null) return null;
    final current = (now ?? DateTime.now()).toUtc();
    return current.difference(stored);
    }

  /// Returns true if the stored timestamp is older than [maxAge], or missing.
  static Future<bool> isStale(String key, Duration maxAge, {DateTime? now}) async {
    final a = await age(key, now: now);
    if (a == null) return true;
    return a > maxAge;
  }
}


