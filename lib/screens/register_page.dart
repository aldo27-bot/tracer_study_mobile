import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projectsemester4/services/api_service.dart';

import '../otp/otp_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nimController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final no_hpController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  // VALIDASI EMAIL
  bool isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@gmail\.com$").hasMatch(email);
  }

  // REGISTER FUNCTION
  Future<void> register() async {
    if (isLoading) return;

    final nim = nimController.text.trim();
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final no_hp = no_hpController.text.trim();
    final password = passwordController.text.trim();

<<<<<<< HEAD
    if (nim.isEmpty ||
        email.isEmpty ||
        username.isEmpty ||
        no_hp.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field wajib diisi"),
        ),
      );
=======
    if (nim.isEmpty || email.isEmpty || no_hp.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
>>>>>>> e94cdbb (update otp dan reset password)
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email harus menggunakan Format @gmail.com"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
<<<<<<< HEAD
      final data = await ApiService.register(
        nim,
        email,
        username,
        no_hp,
        password,
      );
=======
      final data = await ApiService.register(nim, email, no_hp, password);
>>>>>>> e94cdbb (update otp dan reset password)

      if (!mounted) return;

      if (data['status'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("OTP berhasil dikirim")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(email: email, type: 'register'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Register gagal"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Server lama merespon")));
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada koneksi internet")),
      );
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

  @override
  void dispose() {
    nimController.dispose();
    emailController.dispose();
    usernameController.dispose();
    no_hpController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscurePassword : false,
        enabled: !isLoading,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,

          prefixIcon: Icon(icon, color: Colors.grey),

          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                )
              : null,

          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
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
                        Icons.app_registration,
                        size: 90,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),

                    // BACK BUTTON
                    Positioned(
                      top: 20,
                      left: 10,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                // REGISTER CARD
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
                                "assets/Signup-amico.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // TITLE
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF22313F),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Create your alumni account.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // NIM
                          buildInputField(
                            controller: nimController,
                            hint: "NIM",
                            icon: Icons.badge_outlined,
                          ),

                          // EMAIL
                          buildInputField(
                            controller: emailController,
                            hint: "Email",
                            icon: Icons.email_outlined,
                          ),

                          // USERNAME
                          buildInputField(
                            controller:
                                usernameController,
                            hint: "Username",
                            icon: Icons.person_outlined,
                          ),

                          // NOMOR HANDPHONE
                          buildInputField(
                            controller: no_hpController,
                            hint: "Nomor Handphone",
                            icon: Icons.phone_outlined,
                          ),

                          // PASSWORD
                          buildInputField(
                            controller: passwordController,
                            hint: "Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),

                          const SizedBox(height: 12),

                          // REGISTER BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : register,

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
                                      "Register",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // LOGIN
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have account? ",
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
                                  "Sign In",
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
