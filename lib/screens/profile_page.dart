import 'package:flutter/material.dart';
import 'package:projectsemester4/models/alumni_models.dart';
// Import ApiService kamu (sesuaikan path foldernya jika berbeda)
import 'package:projectsemester4/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  final AlumniModel alumni;

  const ProfilePage({Key? key, required this.alumni}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _alamatController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _alamatController = TextEditingController(text: widget.alumni.alamat ?? "");
  }

  @override
  void dispose() {
    _alamatController.dispose();
    super.dispose();
  }

  // FUNGSI UPDATE ALAMAT YANG SUDAH DIPERBAIKI
  Future<void> updateAlamat() async {
    final alamatBaru = _alamatController.text;

    if (alamatBaru.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alamat tidak boleh kosong")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // MEMANGGIL FUNGSI DARI API_SERVICE
      final data = await ApiService.updateAlamat(widget.alumni.nim, alamatBaru);

      if (data['status'] != false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alamat berhasil diperbarui")),
        );

        setState(() {
          _alamatController.text = alamatBaru;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Gagal update alamat")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ), // Menampilkan error dari ApiService
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            _buildDataAlumni("Nama", widget.alumni.nama),
            _buildDataAlumni("NIM", widget.alumni.nim),
            _buildDataAlumni("Program Studi", widget.alumni.prodi),
            _buildDataAlumni("Jurusan", widget.alumni.jurusan),
            _buildDataAlumni("Angkatan", widget.alumni.angkatan),
            _buildDataAlumni(
              "TTL",
              "${widget.alumni.tempatLahir}, ${widget.alumni.tanggalLahir}",
            ),
            _buildDataAlumni("Tahun Lulus", widget.alumni.tahunLulus),

            const Divider(height: 40),

            const Text("Alamat", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            TextField(
              controller: _alamatController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Masukkan alamat lengkap...",
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: isLoading ? null : updateAlamat,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Simpan Alamat",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataAlumni(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
