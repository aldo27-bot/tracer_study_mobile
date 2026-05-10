import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddJobPage extends StatefulWidget {
  const AddJobPage({super.key});

  @override
  State<AddJobPage> createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();

  final posisiC = TextEditingController();
  final perusahaanC = TextEditingController();
  final lokasiC = TextEditingController();
  final gajiC = TextEditingController();
  final deskripsiC = TextEditingController();
  final batasC = TextEditingController();
  final kontakC = TextEditingController();
  final linkC = TextEditingController();

  bool isLoading = false;

  // =========================
  // SIMPAN LOWONGAN
  // =========================
  Future<void> saveJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    bool success = await ApiService.addLowongan(
      posisi: posisiC.text.trim(),
      namaPerusahaan: perusahaanC.text.trim(),
      lokasi: lokasiC.text.trim(),
      gaji: gajiC.text.trim(),
      deskripsi: deskripsiC.text.trim(),
      batasLamaran: batasC.text.trim(),
      kontak: kontakC.text.trim(),
      linkLamaran: linkC.text.trim(),
      dibuatOleh: 1,
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Lowongan berhasil ditambahkan"),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Gagal menambahkan lowongan"),
        ),
      );
    }
  }

  // =========================
  // FORM FIELD
  // =========================
  Widget buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,

        validator: validator,

        decoration: InputDecoration(
          labelText: label,
          hintText: hint,

          filled: true,
          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEC7004), width: 2),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  // =========================
  // PILIH TANGGAL
  // =========================
  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime.now(),

      lastDate: DateTime(2100),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFEC7004)),
          ),

          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

      setState(() {
        batasC.text = formattedDate;
      });
    }
  }

  // =========================
  // DISPOSE
  // =========================
  @override
  void dispose() {
    posisiC.dispose();
    perusahaanC.dispose();
    lokasiC.dispose();
    gajiC.dispose();
    deskripsiC.dispose();
    batasC.dispose();
    kontakC.dispose();
    linkC.dispose();

    super.dispose();
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,

        title: const Text(
          "Tambah Lowongan",
          style: TextStyle(
            color: Color(0xFF0F2D3F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Isi informasi lowongan pekerjaan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F2D3F),
                ),
              ),

              const SizedBox(height: 24),

              // POSISI
              buildField(
                label: "Posisi",
                controller: posisiC,
                hint: "Contoh: Flutter Developer",

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Posisi wajib diisi";
                  }

                  return null;
                },
              ),

              // PERUSAHAAN
              buildField(
                label: "Nama Perusahaan",
                controller: perusahaanC,
                hint: "Contoh: PT Maju Jaya",

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nama perusahaan wajib diisi";
                  }

                  return null;
                },
              ),

              // LOKASI
              buildField(
                label: "Lokasi",
                controller: lokasiC,
                hint: "Contoh: Surabaya",

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Lokasi wajib diisi";
                  }

                  return null;
                },
              ),

              // GAJI
              buildField(
                label: "Gaji",
                controller: gajiC,
                hint: "Contoh: Rp 5.000.000",

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Gaji wajib diisi";
                  }

                  return null;
                },
              ),

              // DESKRIPSI
              buildField(
                label: "Deskripsi",
                controller: deskripsiC,
                maxLines: 5,
                hint: "Masukkan deskripsi pekerjaan",

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Deskripsi wajib diisi";
                  }

                  if (value.length < 10) {
                    return "Deskripsi terlalu pendek";
                  }

                  return null;
                },
              ),

              // BATAS LAMARAN
              Padding(
                padding: const EdgeInsets.only(bottom: 18),

                child: TextFormField(
                  controller: batasC,
                  readOnly: true,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Batas lamaran wajib diisi";
                    }

                    return null;
                  },

                  onTap: pickDate,

                  decoration: InputDecoration(
                    labelText: "Batas Lamaran",
                    hintText: "Pilih tanggal",

                    suffixIcon: const Icon(
                      Icons.calendar_month,
                      color: Color(0xFFEC7004),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFEC7004),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // KONTAK
              buildField(
                label: "Kontak",
                controller: kontakC,
                keyboardType: TextInputType.phone,
                hint: "Contoh: 08123456789",

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Kontak wajib diisi";
                  }

                  if (value.length < 10) {
                    return "Nomor kontak tidak valid";
                  }

                  return null;
                },
              ),

              // LINK LAMARAN
              buildField(
                label: "Link Lamaran (Opsional)",
                controller: linkC,
                keyboardType: TextInputType.url,
                hint: "https://linkedin.com/...",

                validator: (value) {
                  // kosong diperbolehkan
                  if (value == null || value.isEmpty) {
                    return null;
                  }

                  // kalau diisi harus valid
                  if (!value.startsWith("http")) {
                    return "Link harus diawali http/https";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 10),

              /// BUTTON
              SafeArea(
                top: false,

                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),

                  child: SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2D3F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      onPressed: isLoading ? null : saveJob,

                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,

                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Simpan Lowongan",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
