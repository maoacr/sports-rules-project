import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around SharedPreferences for simple key-value storage.
/// Used for onboarding flags, user preferences, and simple state.
class SharedPreferencesStorage {
  final SharedPreferences _prefs;

  SharedPreferencesStorage(this._prefs);

  // Keys
  static const String _keyOnboardingSeen = 'onboarding_seen';
  static const String _keyLastSportsRefresh = 'last_sports_refresh';
  static const String _keyUserId = 'user_id';
  static const String _keyPurchasedSports = 'purchased_sports';

  // Onboarding
  bool get hasSeenOnboarding => _prefs.getBool(_keyOnboardingSeen) ?? false;

  Future<void> setOnboardingSeen(bool value) async {
    await _prefs.setBool(_keyOnboardingSeen, value);
  }

  // Last refresh timestamp
  DateTime? get lastSportsRefresh {
    final millis = _prefs.getInt(_keyLastSportsRefresh);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  Future<void> setLastSportsRefresh(DateTime dateTime) async {
    await _prefs.setInt(_keyLastSportsRefresh, dateTime.millisecondsSinceEpoch);
  }

  // User ID (cached for quick access)
  String? get cachedUserId => _prefs.getString(_keyUserId);

  Future<void> setCachedUserId(String? uid) async {
    if (uid == null) {
      await _prefs.remove(_keyUserId);
    } else {
      await _prefs.setString(_keyUserId, uid);
    }
  }

  // Purchased sports (local cache, source of truth is Firestore)
  List<String> get purchasedSports =>
      _prefs.getStringList(_keyPurchasedSports) ?? [];

  Future<void> setPurchasedSports(List<String> sportIds) async {
    await _prefs.setStringList(_keyPurchasedSports, sportIds);
  }

  Future<void> addPurchasedSport(String sportId) async {
    final current = purchasedSports;
    if (!current.contains(sportId)) {
      await setPurchasedSports([...current, sportId]);
    }
  }

  bool isSportPurchased(String sportId) => purchasedSports.contains(sportId);

  // Generic getters/setters
  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  int? getInt(String key) => _prefs.getInt(key);

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
