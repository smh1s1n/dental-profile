import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton Service for persistent offline caching, local queue storage,
/// appointments, and settings.
class StorageService {
  StorageService._internal();

  static StorageService? _instance;
  static SharedPreferences? _prefs;

  /// Thread-safe singleton accessor
  static StorageService get instance {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  /// Initialize underlying SharedPreferences instance
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Generic String
  Future<bool> setString(String key, String value) async {
    await init();
    return await _prefs!.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  // JSON Objects
  Future<bool> setJson(String key, Map<String, dynamic> json) async {
    return await setString(key, jsonEncode(json));
  }

  Map<String, dynamic>? getJson(String key) {
    final str = getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // JSON Lists
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> list) async {
    return await setString(key, jsonEncode(list));
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    final str = getString(key);
    if (str == null) return null;
    try {
      final decoded = jsonDecode(str) as List;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return null;
    }
  }

  // Clear specific key
  Future<bool> remove(String key) async {
    await init();
    return await _prefs!.remove(key);
  }
}
