import 'package:flutter/material.dart';
import 'package:projectsemester4/models/alumni_models.dart';
import 'package:projectsemester4/services/api_service.dart';

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

  Widget buildDataMenuItem(
    IconData icon,
    String title,
    String value,
  ) {
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
            child: Icon(
              icon,
              color: const Color(0xFF0F2D3F),
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showEditAlamatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 25,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Alamat",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _alamatController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Masukkan alamat lengkap...",
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          await updateAlamat();

                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Simpan Alamat",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF7F7F7),
                      Color(0xFFFFEFE4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
              ),

              // CARD PROFILE
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 42,
                          backgroundColor: Color(0xFF0F2D3F),
                          child: Icon(
                            Icons.person,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          widget.alumni.nama,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          widget.alumni.nim,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          widget.alumni.prodi,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: 170,
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: showEditAlamatSheet,
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              "Edit Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8A00),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // DATA USER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    buildDataMenuItem(
                      Icons.person_outline,
                      "Nama",
                      widget.alumni.nama,
                    ),

                    buildDataMenuItem(
                      Icons.badge_outlined,
                      "NIM",
                      widget.alumni.nim,
                    ),

                    buildDataMenuItem(
                      Icons.school_outlined,
                      "Program Studi",
                      widget.alumni.prodi,
                    ),

                    buildDataMenuItem(
                      Icons.business_outlined,
                      "Jurusan",
                      widget.alumni.jurusan,
                    ),

                    buildDataMenuItem(
                      Icons.calendar_month_outlined,
                      "Angkatan",
                      widget.alumni.angkatan,
                    ),

                    buildDataMenuItem(
                      Icons.workspace_premium_outlined,
                      "Tahun Lulus",
                      widget.alumni.tahunLulus,
                    ),

                    buildDataMenuItem(
                      Icons.location_on_outlined,
                      "Alamat",
                      _alamatController.text,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}