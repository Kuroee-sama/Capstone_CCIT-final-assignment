class KaryawanInfo {
  final int karyawanId;
  final String username;
  final String email;
  final int? umur;
  final String? alamat;
  final String? noTelp;
  final String role;

  KaryawanInfo({
    required this.karyawanId,
    required this.username,
    required this.email,
    this.umur,
    this.alamat,
    this.noTelp,
    required this.role,
  });

  factory KaryawanInfo.fromJson(Map<String, dynamic> json) {
    return KaryawanInfo(
      karyawanId: json['karyawanId'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      umur: json['umur'],
      alamat: json['alamat'],
      noTelp: json['noTelp'],
      role: json['role'] ?? 'KARYAWAN',
    );
  }

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
}

class AuthResponse {
  final String token;
  final String tokenType;
  final String message;
  final KaryawanInfo? karyawan;

  AuthResponse({
    required this.token,
    required this.tokenType,
    required this.message,
    this.karyawan,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      message: json['message'] ?? '',
      karyawan: json['karyawan'] != null
          ? KaryawanInfo.fromJson(json['karyawan'])
          : null,
    );
  }
}
