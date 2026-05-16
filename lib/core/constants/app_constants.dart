class AppConstants {
  // API
  static const String baseUrl = 'http://localhost:8000';
  static const String apiBaseUrl = '$baseUrl/api';
  
  // Endpoints
  static const String downloadsEndpoint = '$apiBaseUrl/downloads';
  static const String libraryEndpoint = '$apiBaseUrl/library';
  static const String favoritesEndpoint = '$apiBaseUrl/favorites';
  static const String historyEndpoint = '$apiBaseUrl/history';
  
  // Storage keys
  static const String downloadDirKey = 'download_dir';
  static const String themeKey = 'theme_mode';
  
  // Default values
  static const String defaultDownloadDir = '/storage/emulated/0/Download/LNCrawler';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}