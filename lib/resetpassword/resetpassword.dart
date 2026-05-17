import 'package:flutter/material.dart';
import 'package:projectsemester4/services/api_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passwordController = TextEditingController();

  bool isLoading = false;

  // VALIDASI PASSWORD
  // minimal 8 karakter
  // wajib huruf besar, huruf kecil, dan angka
  bool isValidPassword(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(password);
  }

  Future<void> resetPassword() async {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak boleh kosong")),
      );
      return;
    }

    // VALIDASI PASSWORD
    if (!isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password minimal 8 karakter, wajib huruf besar, kecil, dan angka",
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService.resetPassword(widget.email, password);

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password berhasil diubah")),
        );

        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,

          prefixIcon: Icon(icon, color: Colors.grey),

          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7F7F7),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                // TOP SHAPE
                Stack(
                  children: [
                    Container(
                      height: 220,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F2D3F),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(120),
                          bottomRight: Radius.circular(120),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 35,
                      left: 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5D7B93),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 45,
                      right: 20,
                      child: Icon(
                        Icons.lock_outline,
                        size: 90,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),

                // CARD
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          // IMAGE
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: const Color(0xFFF5F5F5),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(
                                "assets/Reset_password.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // TITLE
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Reset Password",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF22313F),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Masukkan password baru untuk\n${widget.email}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // PASSWORD FIELD
                          buildInputField(
                            controller: passwordController,
                            hint: "Password Baru",
                            icon: Icons.lock_outline,
                          ),

                          const SizedBox(height: 10),

                          // BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : resetPassword,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F2D3F),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),

                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Reset Password",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // BACK
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "kembali ke ",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "halaman sebelumnya",
                                  style: TextStyle(
                                    color: Color(0xFF0F2D3F),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
