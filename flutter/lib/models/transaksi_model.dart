import 'menu_model.dart';

class DetailTransaksiModel {
  final int? detailId;
  final int? transaksiId;
  final int? menuId;
  final MenuModel? menu;
  final int jumlah;
  final double harga;
  final double totalHarga;

  DetailTransaksiModel({
    this.detailId,
    this.transaksiId,
    this.menuId,
    this.menu,
    required this.jumlah,
    required this.harga,
    required this.totalHarga,
  });

  factory DetailTransaksiModel.fromJson(Map<String, dynamic> json) {
    return DetailTransaksiModel(
      detailId: json['detailId'] ?? json['detail_id'],
      transaksiId: json['transaksiId'] ?? json['transaksi_id'],
      menuId: json['menuId'] ?? json['menu_id'],
      menu: json['menu'] != null ? MenuModel.fromJson(json['menu']) : null,
      jumlah: json['jumlah'] ?? 0,
      harga: (json['harga'] ?? 0).toDouble(),
      totalHarga: (json['totalHarga'] ?? json['total_harga'] ?? 0).toDouble(),
    );
  }

  String get namaItem => menu?.namaItem ?? 'Item #$menuId';
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
    if (json['detailList'] != null) {
      details = (json['detailList'] as List)
          .map((d) => DetailTransaksiModel.fromJson(d))
          .toList();
    }

    return TransaksiModel(
      transaksiId: json['transaksiId'] ?? json['transaksi_id'] ?? 0,
      karyawanId: json['karyawanId'] ?? json['karyawan_id'],
      karyawanUsername: json['karyawanUsername'] ?? json['karyawan_username'],
      tglTransaksi: json['tglTransaksi'] != null
          ? DateTime.parse(json['tglTransaksi'])
          : DateTime.now(),
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0).toDouble(),
      metodePembayaran: json['metodePembayaran'] ?? json['metode_pembayaran'],
      bayar: json['bayar'] != null ? (json['bayar']).toDouble() : null,
      kembalian: json['kembalian'] != null ? (json['kembalian']).toDouble() : null,
      detailList: details,
    );
  }
}
