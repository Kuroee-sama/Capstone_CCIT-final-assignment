import 'package:flutter/foundation.dart';

/// Central API configuration for Flutter.
///
/// Default targets:
/// - Flutter Web/Desktop/iOS: http://localhost:8080/api
/// - Android Emulator: http://10.0.2.2:8080/api
///
/// You may override at run time:
/// flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
class ApiConfig {
  static const String _overrideBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const Duration requestTimeout = Duration(seconds: 15);

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(_overrideBaseUrl);
    }

    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      return 'http://$host:8080/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }

    return 'http://localhost:8080/api';
  }

  static String get assetBaseUrl => baseUrl.endsWith('/api')
      ? baseUrl.substring(0, baseUrl.length - 4)
      : baseUrl.replaceFirst(RegExp(r'/api$'), '');

  static String _normalizeBaseUrl(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static String? menuImageUrl(String? gambar) {
    final raw = gambar?.trim();
    if (raw == null || raw.isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    if (raw.startsWith('/uploads/')) {
      return '$assetBaseUrl$raw';
    }

    if (raw.startsWith('uploads/')) {
      return '$assetBaseUrl/$raw';
    }

    return '$assetBaseUrl/uploads/menu/$raw';
  }

  // Auth endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get health => '$baseUrl/auth/health';

  // Menu endpoints
  static String get menu => '$baseUrl/menu';

  // Kategori endpoints
  static String get kategori => '$baseUrl/kategori';

  // Karyawan endpoints
  static String get karyawan => '$baseUrl/karyawan';

  // Transaksi endpoints
  static String get transaksi => '$baseUrl/transaksi';
  static String get transaksiMy => '$baseUrl/transaksi/my';
  static String get transaksiRiwayat => '$baseUrl/transaksi/riwayat';

  // Dashboard endpoints
  static String get dashboardSummary => '$baseUrl/dashboard/summary';
  static String get dashboardMonthlyIncome => '$baseUrl/dashboard/monthly-income';
}
