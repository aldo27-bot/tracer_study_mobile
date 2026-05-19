import 'package:flutter/material.dart';
import 'package:projectsemester4/models/alumni_models.dart';
import 'package:projectsemester4/services/api_service.dart';
import 'package:projectsemester4/screens/edit_profile_page.dart';
import 'package:projectsemester4/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectsemester4/screens/lupa_password.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  final AlumniModel alumni;
  final Function(AlumniModel updated)? onProfileUpdate;

  const ProfilePage({super.key, required this.alumni, this.onProfileUpdate});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AlumniModel alumniData;
  late TextEditingController _alamatController;

  bool isLoading = false;
  String alamatView = "";

  @override
  void initState() {
    super.initState();
    loadProfile();
    alumniData = widget.alumni;
    alamatView = widget.alumni.alamat ?? "";
    _alamatController = TextEditingController(text: alamatView);
  }

  @override
  void dispose() {
    _alamatController.dispose();
    super.dispose();
  }

  // =========================
  // HELPER: FIX IMAGE CACHE + NULL
  // =========================
  String getImageUrl(String? image) {
    if (image == null || image.isEmpty) return "";
    return "${ApiService.baseUrl.replaceAll('/api', '')}/storage/$image?v=${DateTime.now().millisecondsSinceEpoch}";
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
      final data = await ApiService.updateAlamat(widget.alumni.nim, alamatBaru);

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
  // Ambil data terbaru
  // =========================
  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) return;

      final data = await ApiService.getProfile(userId);

      if (data['status'] == true) {
        final user = data['data'];

        setState(() {
          alumniData = AlumniModel(
            nama: user['nama'],
            nim: user['nim'],
            prodi: user['prodi'],
            angkatan: user['angkatan'].toString(),
            tahunLulus: user['tahun_lulus'].toString(),
            alamat: user['alamat'],
            image: user['image'],
            email: user['email'],
            no_hp: user['no_hp'],
            tempatLahir: user['tempat_lahir'],
            tanggalLahir: user['tanggal_lahir'],
          );
        });
      }
    } catch (e) {
      print("ERROR LOAD PROFILE: $e");
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
    final a = alumniData;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "Profile",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                      // =========================
                      // FOTO PROFILE (FIX DELETE + CACHE)
                      // =========================
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: const Color(0xFF0F2D3F),
                        child: ClipOval(
                          child:
                              (alumniData.image != null &&
                                  alumniData.image!.isNotEmpty)
                              ? Image.network(
                                  getImageUrl(alumniData.image),
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 45,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 45,
                                ),
                        ),
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

                      Text(a.nim, style: const TextStyle(color: Colors.grey)),

                      const SizedBox(height: 10),

                      Text(
                        a.prodi,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 20),

                      // =========================
                      // EDIT PROFILE
                      // =========================
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfilePage(alumni: alumniData),
                            ),
                          );

                          if (result != null) {
                            await loadProfile();
                            final updated = AlumniModel(
                              nama: result["nama"],
                              nim: alumniData.nim,
                              prodi: result["prodi"],
                              angkatan: result["angkatan"].toString(),
                              tahunLulus: result["tahunLulus"].toString(),
                              alamat: result["alamat"],

                              // FIX: handle image null (hapus foto)
                              image:
                                  (result["image"] != null &&
                                      result["image"].toString().isNotEmpty)
                                  ? result["image"]
                                  : null,

                              email: alumniData.email,
                              no_hp: alumniData.no_hp,
                              tempatLahir: alumniData.tempatLahir,
                              tanggalLahir: alumniData.tanggalLahir,
                            );

                            setState(() {
                              alumniData = updated;
                              alamatView = result["alamat"];
                            });

                            // force refresh UI (anti cache image)
                            Future.delayed(
                              const Duration(milliseconds: 50),
                              () {
                                if (mounted) setState(() {});
                              },
                            );

                            widget.onProfileUpdate?.call(updated);
                          }
                        },
                        icon: const Icon(Icons.edit, color: Color(0xFFFF8A00)),
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

                      const SizedBox(height: 12),

                      // LUPA PASSWORD
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LupaPasswordPage(email: a.email ?? ""),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.lock_reset,
                            color: Color(0xFF0F2D3F),
                          ),
                          label: const Text(
                            "Lupa Password",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F2D3F),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0F2D3F)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // DATA LIST
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    buildDataMenuItem(Icons.person, "Nama", a.nama),
                    buildDataMenuItem(Icons.badge, "NIM", a.nim),
                    buildDataMenuItem(Icons.school, "Prodi", a.prodi),
                    buildDataMenuItem(
                      Icons.calendar_month,
                      "Angkatan",
                      a.angkatan,
                    ),
                    buildDataMenuItem(
                      Icons.workspace_premium,
                      "Tahun Lulus",
                      a.tahunLulus,
                    ),
                    buildDataMenuItem(
                      Icons.place,
                      "Tempat Lahir",
                      a.tempatLahir ?? "-",
                    ),
                    buildDataMenuItem(
                      Icons.date_range,
                      "Tanggal Lahir",
                      a.tanggalLahir ?? "-",
                    ),
                    buildDataMenuItem(Icons.location_on, "Alamat", alamatView),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // =========================
              // LOGOUT
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();

                      if (!mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      "Logout",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F5F7),
                    ),
                  ),
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
