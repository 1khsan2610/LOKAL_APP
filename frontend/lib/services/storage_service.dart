import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String operations
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Boolean operations
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Integer operations
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Double operations
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // JSON operations
  Future<void> setJson(String key, dynamic value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  dynamic getJson(String key) {
    final value = _prefs.getString(key);
    if (value != null) {
      return jsonDecode(value);
    }
    return null;
  }

  // List operations
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // Delete operations
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  // Check key exists
  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }

  // App Preferences
  Future<void> setFirstTimeLaunch(bool value) async {
    await setBool('first_time_launch', value);
  }

  bool getFirstTimeLaunch() {
    return getBool('first_time_launch') ?? true;
  }

  Future<void> setThemeMode(String mode) async {
    await setString('theme_mode', mode);
  }

  String getThemeMode() {
    return getString('theme_mode') ?? 'light';
  }

  Future<void> setLanguage(String language) async {
    await setString('language', language);
  }

  String getLanguage() {
    return getString('language') ?? 'id';
  }

  // User preferences
  Future<void> setUserPreferences(Map<String, dynamic> preferences) async {
    await setJson('user_preferences', preferences);
  }

  Map<String, dynamic>? getUserPreferences() {
    final json = getJson('user_preferences');
    return json != null ? Map<String, dynamic>.from(json) : null;
  }

  // Notification preferences
  Future<void> setNotificationEnabled(bool enabled) async {
    await setBool('notification_enabled', enabled);
  }

  bool getNotificationEnabled() {
    return getBool('notification_enabled') ?? true;
  }

  Future<void> setOrderNotificationEnabled(bool enabled) async {
    await setBool('order_notification_enabled', enabled);
  }

  bool getOrderNotificationEnabled() {
    return getBool('order_notification_enabled') ?? true;
  }

  Future<void> setPromoNotificationEnabled(bool enabled) async {
    await setBool('promo_notification_enabled', enabled);
  }

  bool getPromoNotificationEnabled() {
    return getBool('promo_notification_enabled') ?? true;
  }

  // Last sync times
  Future<void> setLastSyncTime(String key, DateTime time) async {
    await setString('last_sync_$key', time.toIso8601String());
  }

  DateTime? getLastSyncTime(String key) {
    final value = getString('last_sync_$key');
    return value != null ? DateTime.tryParse(value) : null;
  }

  // Cache operations
  Future<void> setCacheData(String key, dynamic data, {Duration? expiry}) async {
    final Map<String, dynamic> cacheData = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'expiry': expiry?.inSeconds ?? 86400, // Default 24 hours
    };
    await setJson(key, cacheData);
  }

  dynamic getCacheData(String key) {
    final cacheData = getJson(key);
    if (cacheData != null && cacheData is Map<String, dynamic>) {
      final timestamp =
          DateTime.tryParse(cacheData['timestamp'] ?? '') ?? DateTime.now();
      final expiry = cacheData['expiry'] ?? 86400;
      final now = DateTime.now();

      if (now.difference(timestamp).inSeconds < expiry) {
        return cacheData['data'];
      } else {
        delete(key);
        return null;
      }
    }
    return null;
  }

  // Recent searches
  Future<void> addRecentSearch(String query) async {
    final List<String> recents = getStringList('recent_searches') ?? [];
    recents.remove(query);
    recents.insert(0, query);
    if (recents.length > 10) {
      recents.removeLast();
    }
    await setStringList('recent_searches', recents);
  }

  List<String> getRecentSearches() {
    return getStringList('recent_searches') ?? [];
  }

  Future<void> clearRecentSearches() async {
    await delete('recent_searches');
  }
}
