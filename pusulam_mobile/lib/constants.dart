class ApiConstants {
  // Base URL - Lokal geliştirme için
  static const String baseUrl = 'http://10.0.2.2:8000';
  
  // API Endpoints
  static const String healthEndpoint = '/api/health';
  static const String generatePlanEndpoint = '/api/generate-plan';
  static const String testEndpoint = '/api/test';
  
  // Tam URL'ler
  static const String healthUrl = baseUrl + healthEndpoint;
  static const String generatePlanUrl = baseUrl + generatePlanEndpoint;
  static const String testUrl = baseUrl + testEndpoint;
  
  // Timeout ayarları
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

class AppConstants {
  // Uygulama bilgileri
  static const String appName = 'Pusulam';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI ile kişiselleştirilmiş planlar oluşturan uygulama';
  
  // Desteklenen temalar
  static const List<String> supportedThemes = [
    'eğitim',
    'sağlık', 
    'sürdürülebilirlik',
    'turizm'
  ];
  
  // Varsayılan değerler
  static const String defaultTheme = 'eğitim';
  static const String defaultDuration = '3 hafta';
  static const String defaultDailyTime = '1 saat';
}

class UIConstants {
  // Renkler
  static const int primaryColorValue = 0xFF1E88E5;
  
  // Padding ve margin değerleri
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;
  
  // Border radius
  static const double defaultBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  
  // Icon boyutları
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 48.0;
  static const double extraLargeIconSize = 100.0;
}
