import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_themes.dart';

class ThemeProvider extends ChangeNotifier {
  Color _seedColor = const Color(0xFF1E88E5); // Varsayılan Navigator Blue
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = false;

  Color get seedColor => _seedColor;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  // Tema oluşturma
  ThemeData get lightTheme => AppThemes.createTheme(_seedColor, Brightness.light);
  ThemeData get darkTheme => AppThemes.createTheme(_seedColor, Brightness.dark);

  // Mevcut temayı al
  ThemeOption get currentThemeOption {
    return AppThemes.themes.firstWhere(
      (theme) => theme.seedColor.value == _seedColor.value,
      orElse: () => AppThemes.themes.first,
    );
  }

  ThemeProvider() {
    _loadThemeSettings();
  }

  // Seed color değiştir
  Future<void> setSeedColor(Color color) async {
    if (_seedColor.value == color.value) return;
    
    _seedColor = color;
    notifyListeners();
    await _saveThemeSettings();
  }

  // Theme mode değiştir
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    await _saveThemeSettings();
  }

  // Dark mode toggle
  Future<void> toggleDarkMode() async {
    final newMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  // System theme'e dön
  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  // Ayarları yükle
  Future<void> _loadThemeSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Seed color
      final colorValue = prefs.getInt('theme_seed_color');
      if (colorValue != null) {
        _seedColor = Color(colorValue);
      }
      
      // Theme mode
      final themeModeIndex = prefs.getInt('theme_mode');
      if (themeModeIndex != null) {
        _themeMode = ThemeMode.values[themeModeIndex];
      }
    } catch (e) {
      debugPrint('Tema ayarları yüklenirken hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ayarları kaydet
  Future<void> _saveThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_seed_color', _seedColor.value);
      await prefs.setInt('theme_mode', _themeMode.index);
    } catch (e) {
      debugPrint('Tema ayarları kaydedilirken hata: $e');
    }
  }

  // Tema reset
  Future<void> resetToDefault() async {
    _seedColor = const Color(0xFF1E88E5);
    _themeMode = ThemeMode.system;
    notifyListeners();
    await _saveThemeSettings();
  }

  // Tema bilgilerini al
  Map<String, dynamic> getThemeInfo() {
    return {
      'currentTheme': currentThemeOption.name,
      'seedColor': '#${_seedColor.value.toRadixString(16).padLeft(8, '0')}',
      'themeMode': _themeMode.toString(),
      'isDark': _themeMode == ThemeMode.dark,
      'isSystem': _themeMode == ThemeMode.system,
    };
  }
}
