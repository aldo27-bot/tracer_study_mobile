class LowonganModel {
  final int id;
  final String posisi;
  final String namaPerusahaan;
  final String lokasi;
  final String gaji;
  final String deskripsi;
  final String batasLamaran;
  final String kontak;
  final String linkLamaran;

  // TAMBAHAN
  final String fotoUrl;

  LowonganModel({
    required this.id,
    required this.posisi,
    required this.namaPerusahaan,
    required this.lokasi,
    required this.gaji,
    required this.deskripsi,
    required this.batasLamaran,
    required this.kontak,
    required this.linkLamaran,

    // TAMBAHAN
    required this.fotoUrl,
  });

  factory LowonganModel.fromJson(Map<String, dynamic> json) {
    return LowonganModel(
      id: json['id'] ?? 0,
      posisi: json['posisi'] ?? '',
      namaPerusahaan: json['nama_perusahaan'] ?? '',
      lokasi: json['lokasi'] ?? '',
      gaji: json['gaji'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      batasLamaran: json['batas_lamaran'] ?? '',
      kontak: json['kontak'] ?? '',
      linkLamaran: json['link_lamaran'] ?? '',

      // TAMBAHAN
      fotoUrl: json['foto_url'] ?? '',
    );
  }
}