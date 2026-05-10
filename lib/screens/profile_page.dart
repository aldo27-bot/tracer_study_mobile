import 'package:flutter/material.dart';
import 'package:projectsemester4/models/alumni_models.dart';
import 'package:projectsemester4/services/api_service.dart';
import 'package:projectsemester4/screens/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final AlumniModel alumni;

  const ProfilePage({super.key, required this.alumni});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _alamatController;

  bool isLoading = false;
  String alamatView = "";

  @override
  void initState() {
    super.initState();
    alamatView = widget.alumni.alamat ?? "";

    _alamatController = TextEditingController(text: alamatView);
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

    setState(() => isLoading = true);

    try {
      final data = await ApiService.updateAlamat(
        widget.alumni.nim,
        alamatBaru,
      );

      if (data['status'] == true) {
        setState(() {
          alamatView = alamatBaru;
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alamat berhasil diperbarui")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Gagal update alamat")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget buildDataMenuItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0F2D3F), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.alumni;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "Profile",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: Color(0xFF0F2D3F),
                        child: Icon(Icons.person,
                            color: Colors.white, size: 45),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        a.nama,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        a.nim,
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        a.prodi,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 20),

                      // BUTTON EDIT PROFILE 
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfilePage(alumni: widget.alumni),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              alamatView = result;
                            });
                          }
                        },
                        icon: const Icon(Icons.edit,
                            color: Color(0xFFFF8A00)),
                        label: const Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F2D3F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    buildDataMenuItem(Icons.person, "Nama", a.nama),
                    buildDataMenuItem(Icons.badge, "NIM", a.nim),
                    buildDataMenuItem(Icons.school, "Prodi", a.prodi),
                    buildDataMenuItem(
                        Icons.calendar_month, "Angkatan", a.angkatan),
                    buildDataMenuItem(Icons.workspace_premium,
                        "Tahun Lulus", a.tahunLulus),
                    buildDataMenuItem(
                        Icons.location_on, "Alamat", alamatView),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}