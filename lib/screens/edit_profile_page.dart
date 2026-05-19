import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:projectsemester4/models/alumni_models.dart';
import 'package:projectsemester4/services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  final AlumniModel alumni;

  const EditProfilePage({super.key, required this.alumni});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController namaC;
  late TextEditingController prodiC;
  late TextEditingController angkatanC;
  late TextEditingController tahunLulusC;
  late TextEditingController tempatLahirC;
  late TextEditingController tanggalLahirC;
  late TextEditingController alamatC;

  File? selectedImage;

  bool isLoading = false;
  bool removeImage = false;

  // =========================
  // VALIDATION REGEX
  // =========================
  final RegExp nameRegex = RegExp(r"^[a-zA-Z\s]+$");
  final RegExp numberRegex = RegExp(r"^[0-9]+$");
  final RegExp addressRegex = RegExp(r"^[a-zA-Z0-9\s,.\-/]+$");

  // =========================
  // EXTRA VALIDATION RANGE
  // =========================
  final int minYear = 1990;
  final int maxYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();

    namaC = TextEditingController(text: widget.alumni.nama);
    prodiC = TextEditingController(text: widget.alumni.prodi);
    angkatanC = TextEditingController(text: widget.alumni.angkatan.toString());

    tahunLulusC = TextEditingController(
      text: widget.alumni.tahunLulus.toString(),
    );

    tempatLahirC = TextEditingController(text: widget.alumni.tempatLahir ?? "");
    tanggalLahirC = TextEditingController(
      text: widget.alumni.tanggalLahir ?? "",
    );
    alamatC = TextEditingController(text: widget.alumni.alamat ?? "");

    selectedImage = null;
  }

  @override
  void dispose() {
    namaC.dispose();
    prodiC.dispose();
    angkatanC.dispose();
    tahunLulusC.dispose();
    tempatLahirC.dispose();
    tanggalLahirC.dispose();
    alamatC.dispose();
    super.dispose();
  }

  // =========================
  // Data picker
  // =========================
  Widget buildDatePicker() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: tanggalLahirC,
        readOnly: true,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.date_range, color: Color(0xFF0F2D3F)),
          labelText: "Tanggal Lahir",
          border: InputBorder.none,
        ),
        onTap: () async {
          FocusScope.of(context).unfocus();

          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );

          if (picked != null) {
            final formatted =
                "${picked.year}-"
                "${picked.month.toString().padLeft(2, '0')}-"
                "${picked.day.toString().padLeft(2, '0')}";

            setState(() {
              tanggalLahirC.text = formatted;
            });
          }
        },
      ),
    );
  }

  // =========================
  // PICK IMAGE
  // =========================
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  // =========================
  // DELETE PROFILE IMAGE
  // =========================
  void deleteImage() {
    setState(() {
      selectedImage = null;
      removeImage = true;
    });
  }

  // =========================
  // SAVE PROFILE
  // =========================
  Future<void> saveProfile() async {
    // =========================
    // TERIMA INPUT
    // =========================
    namaC.text = namaC.text.trim();
    prodiC.text = prodiC.text.trim();
    alamatC.text = alamatC.text.trim();
    tempatLahirC.text = tempatLahirC.text.trim();
    tanggalLahirC.text = tanggalLahirC.text.trim();

    // =========================
    // CHECK EMPTY
    // =========================
    if (namaC.text.isEmpty ||
        prodiC.text.isEmpty ||
        angkatanC.text.isEmpty ||
        tahunLulusC.text.isEmpty ||
        alamatC.text.isEmpty ||
        tempatLahirC.text.isEmpty ||
        tanggalLahirC.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua data wajib diisi")));
      return;
    }

    // =========================
    // LENGTH VALIDATION
    // =========================
    if (namaC.text.length < 2 || namaC.text.length > 50) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nama harus 2-50 karakter")));
      return;
    }

    if (prodiC.text.length < 2 || prodiC.text.length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prodi harus 2-100 karakter")),
      );
      return;
    }

    if (alamatC.text.length < 5 || alamatC.text.length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alamat harus 5-200 karakter")),
      );
      return;
    }

    if (tempatLahirC.text.length < 2 || tempatLahirC.text.length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tempat lahir harus 2-100 karakter")),
      );
      return;
    }

    // =========================
    // FORMAT VALIDATION
    // =========================
    if (!nameRegex.hasMatch(namaC.text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nama hanya boleh huruf")));
      return;
    }

    if (!nameRegex.hasMatch(prodiC.text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Prodi hanya boleh huruf")));
      return;
    }

    if (!numberRegex.hasMatch(angkatanC.text) ||
        !numberRegex.hasMatch(tahunLulusC.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Angkatan & Tahun Lulus harus angka")),
      );
      return;
    }

    if (!addressRegex.hasMatch(alamatC.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alamat mengandung karakter tidak valid")),
      );
      return;
    }

    // =========================
    // SAFE PARSE
    // =========================
    final angkatan = int.tryParse(angkatanC.text);
    final tahunLulus = int.tryParse(tahunLulusC.text);

    if (angkatan == null || tahunLulus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Angkatan & Tahun Lulus harus valid angka"),
        ),
      );
      return;
    }

    // =========================
    // RANGE VALIDATION
    // =========================
    if (angkatan < minYear || angkatan > maxYear) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Angkatan harus antara $minYear - $maxYear")),
      );
      return;
    }

    if (tahunLulus < minYear || tahunLulus > maxYear) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tahun lulus harus antara $minYear - $maxYear")),
      );
      return;
    }

    // =========================
    // LOGIC VALIDATION
    // =========================
    if (tahunLulus < angkatan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tahun lulus tidak boleh lebih kecil dari angkatan"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await ApiService.updateProfile(
        widget.alumni.nim,
        namaC.text,
        prodiC.text,
        angkatan,
        tahunLulus,
        tempatLahirC.text,
        tanggalLahirC.text,
        alamatC.text,
        selectedImage,
        removeImage,
      );

      if (res['status'] == true) {
        if (mounted) {
          Navigator.pop(context, {
            "nama": namaC.text,
            "prodi": prodiC.text,
            "angkatan": angkatanC.text,
            "tahunLulus": tahunLulusC.text,
            "alamat": alamatC.text,
            "image": res['data']['image'],
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Gagal update")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // =========================
  // INPUT WIDGET
  // =========================
  Widget buildInput(
    String label,
    TextEditingController c,
    IconData icon, {
    bool number = false,
    bool isAddress = false,
    bool isDate = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: c,
        keyboardType: number
            ? TextInputType.number
            : isDate
            ? TextInputType.datetime
            : TextInputType.text,
        inputFormatters: [
          if (number)
            FilteringTextInputFormatter.digitsOnly
          else if (isDate)
            FilteringTextInputFormatter.singleLineFormatter
          else if (isAddress)
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s,.\-/]'))
          else
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
        ],
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF0F2D3F)),
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : (widget.alumni.image != null &&
                                  widget.alumni.image!.isNotEmpty &&
                                  !removeImage
                              ? NetworkImage(
                                  "${ApiService.baseUrl.replaceAll('/api', '')}/storage/${widget.alumni.image}",
                                )
                              : null),
                    child:
                        selectedImage == null &&
                            (widget.alumni.image == null || removeImage)
                        ? const Icon(
                            Icons.camera_alt,
                            color: Color(0xFF0F2D3F),
                            size: 40,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tap untuk ganti foto",
                  style: TextStyle(color: Colors.grey),
                ),
                if (selectedImage != null ||
                    (widget.alumni.image != null && !removeImage))
                  TextButton.icon(
                    onPressed: deleteImage,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      "Hapus Foto",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            buildInput("Nama", namaC, Icons.person),
            buildInput("Prodi", prodiC, Icons.school),
            buildInput(
              "Angkatan",
              angkatanC,
              Icons.calendar_month,
              number: true,
            ),
            buildInput(
              "Tahun Lulus",
              tahunLulusC,
              Icons.workspace_premium,
              number: true,
            ),
            buildInput("Tempat Lahir", tempatLahirC, Icons.place),
            buildDatePicker(),

            buildInput("Alamat", alamatC, Icons.location_on, isAddress: true),
            const SizedBox(height: 20),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2D3F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Simpan Perubahan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
