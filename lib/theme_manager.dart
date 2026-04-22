import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const String KEY_THEME = 'theme_mode';
  static const String KEY_ACCENT = 'accent_color';

  ThemeMode _themeMode = ThemeMode.light;
  Color _accentColor = Colors.orange;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;

  ThemeManager() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(KEY_THEME) ?? 'light';
    final accentColorValue = prefs.getInt(KEY_ACCENT) ?? Colors.orange.toARGB32();

    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString() == 'ThemeMode.$themeModeString',
      orElse: () => ThemeMode.light,
    );
    _accentColor = Color(accentColorValue);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_THEME, mode.toString().split('.').last);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(KEY_ACCENT, color.toARGB32());
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: _getMaterialColor(_accentColor),
      primaryColor: _accentColor,
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: AppBarTheme(
        backgroundColor: _accentColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: _getMaterialColor(_accentColor),
      primaryColor: _accentColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  MaterialColor _getMaterialColor(Color color) {
    final int red = color.r.toInt();
    final int green = color.g.toInt();
    final int blue = color.b.toInt();

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(color.toARGB32(), shades);
  }
}

