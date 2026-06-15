import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/menu_model.dart';
import '../models/transaksi_model.dart';
import 'auth_service.dart';

/// Service untuk komunikasi dengan REST API
class ApiService {
  /// GET - Ambil semua menu
  static Future<List<MenuModel>> getMenu() async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.menu}?size=200'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List content = data['content'] ?? [];
      return content.map((m) => MenuModel.fromJson(m)).toList();
    } else {
      throw Exception('Gagal memuat menu');
    }
  }

  /// GET - Dashboard summary
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.get(
      Uri.parse(ApiConfig.dashboardSummary),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat dashboard');
    }
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

    final response = await http.post(
      Uri.parse(ApiConfig.transaksi),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return TransaksiModel.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Gagal membuat transaksi');
    }
  }

  /// GET - Riwayat transaksi saya
  static Future<List<TransaksiModel>> getMyTransaksi({int page = 0, int size = 50}) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.transaksiMy}?page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List content = data['content'] ?? [];
      return content.map((t) => TransaksiModel.fromJson(t)).toList();
    } else {
      throw Exception('Gagal memuat riwayat');
    }
  }

  /// GET - Semua transaksi (admin only)
  static Future<List<TransaksiModel>> getAllTransaksi({int page = 0, int size = 50}) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.transaksi}?page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List content = data['content'] ?? [];
      return content.map((t) => TransaksiModel.fromJson(t)).toList();
    } else {
      throw Exception('Gagal memuat transaksi');
    }
  }

  /// GET - Detail transaksi
  static Future<TransaksiModel> getTransaksiDetail(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.transaksi}/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return TransaksiModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat detail transaksi');
    }
  }
}
