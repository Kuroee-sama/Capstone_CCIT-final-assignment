import 'menu_model.dart';

class DetailTransaksiModel {
  final int? detailId;
  final int? transaksiId;
  final int? menuId;
  final MenuModel? menu;
  final String? namaItemValue;
  final String? namaKategoriValue;
  final int jumlah;
  final double harga;
  final double totalHarga;

  DetailTransaksiModel({
    this.detailId,
    this.transaksiId,
    this.menuId,
    this.menu,
    this.namaItemValue,
    this.namaKategoriValue,
    required this.jumlah,
    required this.harga,
    required this.totalHarga,
  });

  factory DetailTransaksiModel.fromJson(Map<String, dynamic> json) {
    return DetailTransaksiModel(
      detailId: json['detailId'] ?? json['detail_id'],
      transaksiId: json['transaksiId'] ?? json['transaksi_id'],
      menuId: json['menuId'] ?? json['menu_id'],
      menu: json['menu'] != null ? MenuModel.fromJson(Map<String, dynamic>.from(json['menu'] as Map)) : null,
      namaItemValue: json['namaItem'] ?? json['nama_item'],
      namaKategoriValue: json['namaKategori'] ?? json['nama_kategori'],
      jumlah: _asInt(json['jumlah']),
      harga: _asDouble(json['harga']),
      totalHarga: _asDouble(json['totalHarga'] ?? json['total_harga']),
    );
  }

  String get namaItem => namaItemValue ?? menu?.namaItem ?? 'Item #$menuId';
  String get namaKategori => namaKategoriValue ?? menu?.kategoriNama ?? '-';

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class TransaksiModel {
  final int transaksiId;
  final int? karyawanId;
  final String? karyawanUsername;
  final DateTime tglTransaksi;
  final double totalAmount;
  final String? metodePembayaran;
  final double? bayar;
  final double? kembalian;
  final List<DetailTransaksiModel>? detailList;

  TransaksiModel({
    required this.transaksiId,
    this.karyawanId,
    this.karyawanUsername,
    required this.tglTransaksi,
    required this.totalAmount,
    this.metodePembayaran,
    this.bayar,
    this.kembalian,
    this.detailList,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    List<DetailTransaksiModel>? details;
    final rawDetails = json['detailList'] ?? json['detail_list'] ?? json['details'] ?? json['detail'];
    if (rawDetails is List) {
      details = rawDetails
          .map((d) => DetailTransaksiModel.fromJson(Map<String, dynamic>.from(d as Map)))
          .toList();
    }

    return TransaksiModel(
      transaksiId: _asInt(json['transaksiId'] ?? json['transaksi_id']),
      karyawanId: _asNullableInt(json['karyawanId'] ?? json['karyawan_id']),
      karyawanUsername: json['karyawanUsername'] ?? json['karyawan_username'] ?? json['username'],
      tglTransaksi: _asDateTime(json['tglTransaksi'] ?? json['tgl_transaksi']),
      totalAmount: _asDouble(json['totalAmount'] ?? json['total_amount']),
      metodePembayaran: json['metodePembayaran'] ?? json['metode_pembayaran'],
      bayar: _asNullableDouble(json['bayar']),
      kembalian: _asNullableDouble(json['kembalian']),
      detailList: details,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _asNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime _asDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    final raw = value.toString();
    return DateTime.tryParse(raw) ?? DateTime.now();
  }
}
