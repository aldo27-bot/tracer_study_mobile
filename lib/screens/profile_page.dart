import 'package:flutter/material.dart';
import 'package:projectsemester4/models/alumni_models.dart';
import 'package:projectsemester4/services/api_service.dart';
import '../models/alumni_models.dart';

class ProfilePage extends StatefulWidget {
  final AlumniModel alumni;

  const ProfilePage({super.key, required this.alumni});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _alamatController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _alamatController = TextEditingController(
      text: widget.alumni.alamat ?? "",
    );
  }

  @override
  void dispose() {
    _alamatController.dispose();
    super.dispose();
  }

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
      final data = await ApiService.updateAlamat(
        widget.alumni.nim,
        alamatBaru,
      );

      if (data['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alamat berhasil diperbarui")),
        );

        setState(() {
          // update tampilan lokal
          _alamatController.text = alamatBaru;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Gagal update alamat")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),

            const SizedBox(height: 20),

            _buildData("Nama", widget.alumni.nama),
            _buildData("NIM", widget.alumni.nim),
            _buildData("Program Studi", widget.alumni.prodi),
            _buildData("Jurusan", widget.alumni.jurusan),
            _buildData("Angkatan", widget.alumni.angkatan),
            _buildData(
              "TTL",
              "${widget.alumni.tempatLahir}, ${widget.alumni.tanggalLahir}",
            ),
            _buildData("Tahun Lulus", widget.alumni.tahunLulus),

            const Divider(height: 40),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Alamat",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

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
                onPressed: isLoading ? null : updateAlamat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
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

  Widget _buildData(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}