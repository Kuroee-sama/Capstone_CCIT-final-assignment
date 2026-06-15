/// Konfigurasi API untuk koneksi ke Spring Boot backend
class ApiConfig {
  // Gunakan 10.0.2.2 untuk Android Emulator, localhost untuk web/desktop
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String health = '$baseUrl/auth/health';

  // Menu endpoints
  static const String menu = '$baseUrl/menu';

  // Kategori endpoints
  static const String kategori = '$baseUrl/kategori';

  // Transaksi endpoints
  static const String transaksi = '$baseUrl/transaksi';
  static const String transaksiMy = '$baseUrl/transaksi/my';

  // Dashboard endpoints
  static const String dashboardSummary = '$baseUrl/dashboard/summary';
}
