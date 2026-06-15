class KategoriModel {
  final int kategoriId;
  final String namaKategori;
  final String? kDescription;

  KategoriModel({
    required this.kategoriId,
    required this.namaKategori,
    this.kDescription,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      kategoriId: json['kategoriId'] ?? json['kategori_id'] ?? 0,
      namaKategori: json['namaKategori'] ?? json['nama_kategori'] ?? '',
      kDescription: json['kDescription'] ?? json['k_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'namaKategori': namaKategori,
      'kDescription': kDescription,
    };
  }
}
