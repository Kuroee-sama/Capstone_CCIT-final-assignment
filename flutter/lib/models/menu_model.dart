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
      harga: (json['harga'] is int)
          ? (json['harga'] as int).toDouble()
          : (json['harga'] ?? 0).toDouble(),
      mDescription: json['mDescription'] ?? json['m_description'],
      gambar: json['gambar'],
      stok: json['stok'] ?? 0,
      kategori: json['kategori'] != null
          ? KategoriModel.fromJson(json['kategori'])
          : null,
      kategoriId: json['kategoriId'] ?? json['kategori_id'],
    );
  }

  String get kategoriNama =>
      kategori?.namaKategori ?? 'Tanpa Kategori';
}
