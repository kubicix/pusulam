import 'package:flutter/material.dart';

class AppThemes {
  // Tema listesi
  static const List<ThemeOption> themes = [
    ThemeOption(
      name: 'Navigator Blue',
      description: 'Klasik denizcilik teması',
      seedColor: Color(0xFF1E88E5),
      icon: Icons.sailing,
    ),
    ThemeOption(
      name: 'Compass Gold',
      description: 'Premium altın pusula',
      seedColor: Color(0xFFFF8F00),
      icon: Icons.compass_calibration,
    ),
    ThemeOption(
      name: 'Forest Guide',
      description: 'Doğal keşif teması',
      seedColor: Color(0xFF2E7D32),
      icon: Icons.nature,
    ),
    ThemeOption(
      name: 'Midnight Explorer',
      description: 'Gece keşifçisi',
      seedColor: Color(0xFF3F51B5),
      icon: Icons.nights_stay,
    ),
    ThemeOption(
      name: 'Sunset Journey',
      description: 'Günbatımı yolculuğu',
      seedColor: Color(0xFFE64A19),
      icon: Icons.wb_sunny,
    ),
  ];

  // Tema oluşturucu
  static ThemeData createTheme(Color seedColor, Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }
}

class CustomColors {
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient'ler
  static LinearGradient primaryGradient(Color seedColor) {
    return LinearGradient(
      colors: [
        seedColor.withOpacity(0.8),
        seedColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  static LinearGradient cardGradient(Color seedColor) {
    return LinearGradient(
      colors: [
        seedColor.withOpacity(0.05),
        seedColor.withOpacity(0.1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class ThemeOption {
  final String name;
  final String description;
  final Color seedColor;
  final IconData icon;

  const ThemeOption({
    required this.name,
    required this.description,
    required this.seedColor,
    required this.icon,
  });
}
