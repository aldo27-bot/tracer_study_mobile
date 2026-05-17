class AlumniModel {
  final String nama;
  final String nim;
  final String? email;
  final String? no_hp;
  final String prodi;
  final String angkatan;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String tahunLulus;
  final String? alamat;
  final String? image;

  AlumniModel({
    required this.nama,
    required this.nim,
    this.email,
    this.no_hp,
    required this.prodi,
    required this.angkatan,
    this.tempatLahir,
    this.tanggalLahir,
    required this.tahunLulus,
    this.alamat,
    this.image,
  });

  factory AlumniModel.fromJson(Map<String, dynamic>? json) {
  final data = json ?? {};

  return AlumniModel(
    nama: data['nama']?.toString() ?? '',
    nim: data['nim']?.toString() ?? '',
    email: data['email']?.toString(),
    no_hp: data['no_hp']?.toString(),
    prodi: data['prodi']?.toString() ?? '',
    angkatan: data['angkatan']?.toString() ?? '',
    tempatLahir: data['tempat_lahir']?.toString(),
    tanggalLahir: data['tanggal_lahir']?.toString(),
    tahunLulus: data['tahun_lulus']?.toString() ?? '',
    alamat: data['alamat']?.toString(),
    image: data['image']?.toString(),
  );
}
}