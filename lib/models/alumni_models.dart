class AlumniModel {
  final String nama;
  final String nim;
  final String? email;
  final String prodi;
  final String angkatan;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String tahunLulus;
  final String? alamat;

  AlumniModel({
    required this.nama,
    required this.nim,
    this.email,
    required this.prodi,
    required this.angkatan,
    this.tempatLahir,
    this.tanggalLahir,
    required this.tahunLulus,
    this.alamat,
  });

  factory AlumniModel.fromJson(Map<String, dynamic> json) {
    return AlumniModel(
      nama: json['nama']?.toString() ?? '',
      nim: json['nim']?.toString() ?? '',
      email: json['email']?.toString(),
      prodi: json['prodi']?.toString() ?? '',
      angkatan: json['angkatan']?.toString() ?? '',
      tempatLahir: json['tempat_lahir']?.toString(),
      tanggalLahir: json['tanggal_lahir']?.toString(),
      tahunLulus: json['tahun_lulus']?.toString() ?? '',
      alamat: json['alamat']?.toString(),
    );
  }
}