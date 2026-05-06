import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:projectsemester4/models/alumni_models.dart';
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

  // Fungsi untuk menampilkan Popup Tambah/Edit Alamat
  void _showAlamatPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          // Perbaikan Struktur: BackdropFilter -> child: AlertDialog -> content: SizedBox
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Kelola Alamat",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _alamatController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Masukkan alamat lengkap...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPopupButton("Hapus", Colors.red, () {
                        _alamatController.clear();
                        Navigator.pop(context);
                      }),
                      _buildPopupButton("Edit", Colors.yellow[700]!, () {
                        Navigator.pop(context);
                      }),
                      _buildPopupButton("Tambah", Colors.blueAccent, () {
                        updateAlamat();
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Future<void> updateAlamat() async {
    final alamatBaru = _alamatController.text;
    if (alamatBaru.isEmpty) return;

    setState(() => isLoading = true);
    try {
      final data = await ApiService.updateAlamat(widget.alumni.nim, alamatBaru);
      if (data['status'] != false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alamat berhasil diperbarui")),
        );

        setState(() {
          _alamatController.text = alamatBaru;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blueAccent],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.account_circle,
                          size: 120,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildFieldLabel("Nama"),
                      _buildDataBox(widget.alumni.nama),

                      _buildFieldLabel("NIM"),
                      _buildDataBox(widget.alumni.nim),

                      _buildFieldLabel("Prodi"),
                      _buildDataBox(widget.alumni.prodi),

                      _buildFieldLabel("Jurusan"),
                      _buildDataBox(widget.alumni.jurusan),

                      _buildFieldLabel("Angkatan"),
                      _buildDataBox(widget.alumni.angkatan),

                      _buildFieldLabel("Tempat, Tanggal Lahir"),
                      _buildDataBox(
                        "${widget.alumni.tempatLahir}, ${widget.alumni.tanggalLahir}",
                      ),

                      _buildFieldLabel("Tahun Lulus"),
                      _buildDataBox(widget.alumni.tahunLulus),

                      _buildFieldLabel("Alamat"),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.alumni.alamat ?? "Belum ada alamat",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: _showAlamatPopup,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 5, top: 15),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildDataBox(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(value, style: const TextStyle(fontSize: 15)),
    );
  }
}
