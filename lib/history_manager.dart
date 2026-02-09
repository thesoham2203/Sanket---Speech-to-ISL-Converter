import 'package:shared_preferences/shared_preferences.dart';

class HistoryManager {
  static const String KEY = 'translation_history';
  static const String KEY_LANG = 'selected_language';
  static const int MAX_HISTORY = 20;

  static Future<void> saveTranslation(String text) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(KEY) ?? [];

    // Don't add duplicates
    if (history.contains(text)) {
      history.remove(text);
    }

    history.insert(0, text);  // Add to beginning
    if (history.length > MAX_HISTORY) history.removeLast();  // Keep only 20

    await prefs.setStringList(KEY, history);
  }

  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(KEY) ?? [];
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY);
  }

  static Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_LANG, lang);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_LANG) ?? 'en';
  }
}

