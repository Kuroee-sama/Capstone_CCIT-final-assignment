class KaryawanModel {
  final int karyawanId;
  final String username;
  final String email;
  final int? umur;
  final String? alamat;
  final String? tglLahir;
  final String? noTelp;
  final String role;

  const KaryawanModel({
    required this.karyawanId,
    required this.username,
    required this.email,
    this.umur,
    this.alamat,
    this.tglLahir,
    this.noTelp,
    required this.role,
  });

  factory KaryawanModel.fromJson(dynamic raw) {
    final json = Map<String, dynamic>.from(raw as Map);
    return KaryawanModel(
      karyawanId: _asInt(json['karyawanId'] ?? json['karyawan_id']),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      umur: _nullableInt(json['umur']),
      alamat: _nullableString(json['alamat']),
      tglLahir: _nullableString(json['tglLahir'] ?? json['tgl_lahir']),
      noTelp: _nullableString(json['noTelp'] ?? json['no_telp']),
      role: (json['role'] ?? 'KARYAWAN').toString().toUpperCase(),
    );
  }

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
