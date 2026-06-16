import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/menu_model.dart';
import '../models/kategori_model.dart';
import '../models/transaksi_model.dart';
import '../models/picked_image_file.dart';
import 'auth_service.dart';

/// Service untuk komunikasi dengan REST API
class ApiService {
  /// GET - Ambil semua menu
  static Future<List<MenuModel>> getMenu() async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.get(
          Uri.parse('${ApiConfig.menu}?size=200'),
          headers: headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List content = data is Map<String, dynamic>
          ? data['content'] ?? []
          : data is List
              ? data
              : [];
      return content.map((m) => MenuModel.fromJson(m)).toList();
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal memuat menu'));
  }

  /// GET - Dashboard summary
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.get(
          Uri.parse(ApiConfig.dashboardSummary),
          headers: headers,
        ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal memuat dashboard'));
  }

  /// POST - Buat transaksi baru
  static Future<TransaksiModel> createTransaksi({
    required List<Map<String, dynamic>> items,
    String metodePembayaran = 'CASH',
    double? bayar,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    final body = {
      'items': items,
      'metodePembayaran': metodePembayaran,
    };
    if (bayar != null) body['bayar'] = bayar;

    final response = await _send(() => http.post(
          Uri.parse(ApiConfig.transaksi),
          headers: headers,
          body: jsonEncode(body),
        ));

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return TransaksiModel.fromJson(data);
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal membuat transaksi'));
  }

  /// GET - Riwayat transaksi saya
  static Future<List<TransaksiModel>> getMyTransaksi({int page = 0, int size = 50}) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.get(
          Uri.parse('${ApiConfig.transaksiMy}?page=$page&size=$size'),
          headers: headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List content = data is Map<String, dynamic>
          ? data['content'] ?? []
          : data is List
              ? data
              : [];
      return content.map((t) => TransaksiModel.fromJson(t)).toList();
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal memuat riwayat'));
  }

  /// GET - Semua transaksi (admin only)
  static Future<List<TransaksiModel>> getAllTransaksi({int page = 0, int size = 50}) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.get(
          Uri.parse('${ApiConfig.transaksi}?page=$page&size=$size'),
          headers: headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List content = data is Map<String, dynamic>
          ? data['content'] ?? []
          : data is List
              ? data
              : [];
      return content.map((t) => TransaksiModel.fromJson(t)).toList();
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal memuat transaksi'));
  }

  /// GET - Header transaksi
  static Future<TransaksiModel> getTransaksiDetail(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.get(
          Uri.parse('${ApiConfig.transaksi}/$id'),
          headers: headers,
        ));

    if (response.statusCode == 200) {
      return TransaksiModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal memuat detail transaksi'));
  }

  /// GET - Item detail transaksi.
  /// Endpoint ini dipisah agar Flutter mendapat format detail seperti halaman CI4.
  static Future<List<DetailTransaksiModel>> getTransaksiDetails(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.get(
          Uri.parse('${ApiConfig.transaksi}/$id/detail'),
          headers: headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List content = data is List
          ? data
          : data is Map<String, dynamic>
              ? data['content'] ?? []
              : [];
      return content.map((d) => DetailTransaksiModel.fromJson(Map<String, dynamic>.from(d as Map))).toList();
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal memuat item transaksi'));
  }

  /// GET - Ambil semua kategori
  static Future<List<KategoriModel>> getKategori() async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.get(
          Uri.parse(ApiConfig.kategori),
          headers: headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List content = data is List
          ? data
          : data is Map<String, dynamic>
              ? data['content'] ?? []
              : [];
      return content.map((k) => KategoriModel.fromJson(k)).toList();
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal memuat kategori'));
  }

  /// POST - Tambah kategori baru (admin only)
  static Future<KategoriModel> createKategori({
    required String namaKategori,
    String? deskripsi,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.post(
          Uri.parse(ApiConfig.kategori),
          headers: headers,
          body: jsonEncode({
            'namaKategori': namaKategori,
            'kDescription': deskripsi,
          }),
        ));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return KategoriModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal menambah kategori'));
  }

  /// PUT - Edit kategori (admin only)
  static Future<KategoriModel> updateKategori({
    required int kategoriId,
    required String namaKategori,
    String? deskripsi,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.put(
          Uri.parse('${ApiConfig.kategori}/$kategoriId'),
          headers: headers,
          body: jsonEncode({
            'namaKategori': namaKategori,
            'kDescription': deskripsi,
          }),
        ));

    if (response.statusCode == 200) {
      return KategoriModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal mengubah kategori'));
  }

  /// DELETE - Hapus kategori (admin only)
  static Future<void> deleteKategori(int kategoriId) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.delete(
          Uri.parse('${ApiConfig.kategori}/$kategoriId'),
          headers: headers,
        ));

    if (response.statusCode == 204 || response.statusCode == 200) return;

    throw Exception(_extractErrorMessage(response.body, 'Gagal menghapus kategori'));
  }

  /// POST - Tambah menu baru (admin only)
  static Future<MenuModel> createMenu({
    required String namaItem,
    required double harga,
    required int stok,
    required int kategoriId,
    String? deskripsi,
    String? gambar,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.post(
          Uri.parse(ApiConfig.menu),
          headers: headers,
          body: jsonEncode({
            'namaItem': namaItem,
            'harga': harga,
            'stok': stok,
            'mDescription': deskripsi,
            'gambar': gambar,
            'kategoriId': kategoriId,
          }),
        ));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return MenuModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal menambah menu'));
  }

  /// POST multipart - Tambah menu dengan file gambar seperti form CI4.
  static Future<MenuModel> createMenuWithImage({
    required String namaItem,
    required double harga,
    required int stok,
    required int kategoriId,
    String? deskripsi,
    PickedImageFile? image,
  }) async {
    if (image == null) {
      return createMenu(
        namaItem: namaItem,
        harga: harga,
        stok: stok,
        kategoriId: kategoriId,
        deskripsi: deskripsi,
      );
    }

    final response = await _sendMultipart(
      method: 'POST',
      url: ApiConfig.menu,
      fields: {
        'namaItem': namaItem,
        'harga': harga.toString(),
        'stok': stok.toString(),
        'kategoriId': kategoriId.toString(),
        'mDescription': deskripsi ?? '',
      },
      image: image,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return MenuModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal menambah menu'));
  }

  /// PUT - Edit menu (admin only)
  static Future<MenuModel> updateMenu({
    required int menuId,
    required String namaItem,
    required double harga,
    required int stok,
    required int kategoriId,
    String? deskripsi,
    String? gambar,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.put(
          Uri.parse('${ApiConfig.menu}/$menuId'),
          headers: headers,
          body: jsonEncode({
            'namaItem': namaItem,
            'harga': harga,
            'stok': stok,
            'mDescription': deskripsi,
            'gambar': gambar,
            'kategoriId': kategoriId,
          }),
        ));

    if (response.statusCode == 200) {
      return MenuModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal mengubah menu'));
  }

  /// PUT multipart - Edit menu dengan opsi mengganti gambar.
  static Future<MenuModel> updateMenuWithImage({
    required int menuId,
    required String namaItem,
    required double harga,
    required int stok,
    required int kategoriId,
    String? deskripsi,
    PickedImageFile? image,
  }) async {
    if (image == null) {
      return updateMenu(
        menuId: menuId,
        namaItem: namaItem,
        harga: harga,
        stok: stok,
        kategoriId: kategoriId,
        deskripsi: deskripsi,
      );
    }

    final response = await _sendMultipart(
      method: 'POST',
      url: '${ApiConfig.menu}/$menuId',
      fields: {
        'namaItem': namaItem,
        'harga': harga.toString(),
        'stok': stok.toString(),
        'kategoriId': kategoriId.toString(),
        'mDescription': deskripsi ?? '',
      },
      image: image,
    );

    if (response.statusCode == 200) {
      return MenuModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal mengubah menu'));
  }

  /// DELETE - Hapus menu (admin only)
  static Future<void> deleteMenu(int menuId) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.delete(
          Uri.parse('${ApiConfig.menu}/$menuId'),
          headers: headers,
        ));

    if (response.statusCode == 204 || response.statusCode == 200) return;

    throw Exception(_extractErrorMessage(response.body, 'Gagal menghapus menu'));
  }

  /// GET - Pendapatan bulanan (admin only)
  static Future<List<Map<String, dynamic>>> getMonthlyIncome() async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.get(
          Uri.parse(ApiConfig.dashboardMonthlyIncome),
          headers: headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      if (data is Map<String, dynamic> && data['content'] is List) {
        return (data['content'] as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      return <Map<String, dynamic>>[];
    }

    throw Exception(_extractErrorMessage(response.body, 'Gagal memuat pendapatan bulanan'));
  }

  /// DELETE - Hapus transaksi (admin only)
  static Future<void> deleteTransaksi(int transaksiId) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await _send(() => http.delete(
          Uri.parse('${ApiConfig.transaksi}/$transaksiId'),
          headers: headers,
        ));

    if (response.statusCode == 204 || response.statusCode == 200) return;

    throw Exception(_extractErrorMessage(response.body, 'Gagal menghapus transaksi'));
  }

  static Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(ApiConfig.requestTimeout);
    } on TimeoutException {
      throw Exception('Koneksi ke backend timeout. Pastikan Spring Boot berjalan di ${ApiConfig.baseUrl}.');
    } on FormatException {
      throw Exception('Response backend bukan JSON yang valid. Periksa log Spring Boot.');
    } on http.ClientException catch (e) {
      final message = e.message.toLowerCase().contains('failed to fetch')
          ? 'Tidak bisa menghubungi backend di ${ApiConfig.baseUrl}. Untuk Flutter Web gunakan localhost, bukan 10.0.2.2. Jalankan Spring Boot di port 8080 lalu coba lagi.'
          : 'Tidak bisa menghubungi backend di ${ApiConfig.baseUrl}. Detail: ${e.message}';
      throw Exception(message);
    }
  }

  static Future<http.Response> _sendMultipart({
    required String method,
    required String url,
    required Map<String, String> fields,
    required PickedImageFile image,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final request = http.MultipartRequest(method, Uri.parse(url));
      request.headers.addAll(headers);
      request.headers.remove('Content-Type');
      request.fields.addAll(fields);
      request.files.add(http.MultipartFile.fromBytes(
        'gambar',
        image.bytes,
        filename: image.name,
      ));

      final streamed = await request.send().timeout(ApiConfig.requestTimeout);
      return await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw Exception('Upload gambar timeout. Pastikan Spring Boot berjalan di ${ApiConfig.baseUrl}.');
    } on http.ClientException catch (e) {
      throw Exception('Tidak bisa mengunggah gambar ke ${ApiConfig.baseUrl}. Detail: ${e.message}');
    }
  }

  static String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'] ?? decoded['message'];
        if (error is String && error.isNotEmpty) return error;
      }
    } catch (_) {
      // Ignore non-JSON error body.
    }
    return fallback;
  }
}
