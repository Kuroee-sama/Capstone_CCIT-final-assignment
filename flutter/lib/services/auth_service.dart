import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/auth_model.dart';

/// Service untuk autentikasi dan session management
class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_info';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  /// Login dan simpan token
  static Future<AuthResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Simpan token dan user info ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, authResponse.token);
      if (authResponse.karyawan != null) {
        await prefs.setString(_roleKey, authResponse.karyawan!.role);
        await prefs.setInt(_userIdKey, authResponse.karyawan!.karyawanId);
        await prefs.setString(_usernameKey, authResponse.karyawan!.username);
        await prefs.setString(_userKey, jsonEncode(data['karyawan']));
      }

      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Login gagal');
    }
  }

  /// Register karyawan baru
  static Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    int? umur,
    String? alamat,
    String? noTelp,
  }) async {
    final body = {
      'username': username,
      'email': email,
      'password': password,
    };
    if (umur != null) body['umur'] = umur.toString();
    if (alamat != null) body['alamat'] = alamat;
    if (noTelp != null) body['noTelp'] = noTelp;

    final response = await http.post(
      Uri.parse(ApiConfig.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Simpan token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, authResponse.token);
      if (authResponse.karyawan != null) {
        await prefs.setString(_roleKey, authResponse.karyawan!.role);
        await prefs.setInt(_userIdKey, authResponse.karyawan!.karyawanId);
        await prefs.setString(_usernameKey, authResponse.karyawan!.username);
        await prefs.setString(_userKey, jsonEncode(data['karyawan']));
      }

      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Registrasi gagal');
    }
  }

  /// Logout dan hapus token
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
  }

  /// Cek apakah sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  /// Ambil token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Ambil role
  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey) ?? 'KARYAWAN';
  }

  /// Cek apakah admin
  static Future<bool> isAdmin() async {
    final role = await getRole();
    return role.toUpperCase() == 'ADMIN';
  }

  /// Ambil username
  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? '';
  }

  /// Ambil user ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  /// Buat header dengan Authorization token
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
