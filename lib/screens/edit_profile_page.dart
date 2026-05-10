import 'package:flutter/material.dart';
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
  late TextEditingController alamatC;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    namaC = TextEditingController(text: widget.alumni.nama);
    prodiC = TextEditingController(text: widget.alumni.prodi);
    angkatanC = TextEditingController(text: widget.alumni.angkatan.toString());
    tahunLulusC =
        TextEditingController(text: widget.alumni.tahunLulus.toString());
    alamatC = TextEditingController(text: widget.alumni.alamat ?? "");
  }

  @override
  void dispose() {
    namaC.dispose();
    prodiC.dispose();
    angkatanC.dispose();
    tahunLulusC.dispose();
    alamatC.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (namaC.text.isEmpty ||
        prodiC.text.isEmpty ||
        angkatanC.text.isEmpty ||
        tahunLulusC.text.isEmpty ||
        alamatC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua data wajib diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await ApiService.updateProfile(
        widget.alumni.nim,
        namaC.text,
        prodiC.text,
        int.parse(angkatanC.text),
        int.parse(tahunLulusC.text),
        alamatC.text,
      );

      if (res['status'] == true) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Gagal update")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget buildInput(String label, TextEditingController c, IconData icon,
      {bool number = false}) {
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
          )
        ],
      ),
      child: TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
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
        // backgroundColor: const Color(0xFF0F2D3F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildInput("Nama", namaC, Icons.person),
            buildInput("Prodi", prodiC, Icons.school),
            buildInput("Angkatan", angkatanC, Icons.calendar_month,
                number: true),
            buildInput(
                "Tahun Lulus", tahunLulusC, Icons.workspace_premium,
                number: true),
            buildInput("Alamat", alamatC, Icons.location_on),

            const SizedBox(height: 20),

            SizedBox(
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
            )
          ],
        ),
      ),
    );
  }
}