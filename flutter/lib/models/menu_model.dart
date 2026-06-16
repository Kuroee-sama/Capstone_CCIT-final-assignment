import 'kategori_model.dart';

class MenuModel {
  final int menuId;
  final String namaItem;
  final double harga;
  final String? mDescription;
  final String? gambar;
  final int stok;
  final KategoriModel? kategori;
  final int? kategoriId;

  MenuModel({
    required this.menuId,
    required this.namaItem,
    required this.harga,
    this.mDescription,
    this.gambar,
    required this.stok,
    this.kategori,
    this.kategoriId,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      menuId: json['menuId'] ?? json['menu_id'] ?? 0,
      namaItem: json['namaItem'] ?? json['nama_item'] ?? '',
      harga: _asDouble(json['harga']),
      mDescription: json['mDescription'] ?? json['m_description'],
      gambar: json['gambar'],
      stok: _asInt(json['stok']),
      kategori: json['kategori'] != null
          ? KategoriModel.fromJson(json['kategori'])
          : null,
      kategoriId: json['kategoriId'] ?? json['kategori_id'],
    );
  }

  String get kategoriNama =>
      kategori?.namaKategori ?? 'Tanpa Kategori';

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
