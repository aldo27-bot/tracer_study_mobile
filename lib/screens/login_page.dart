import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projectsemester4/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../otp/otp_page.dart';
import 'lupa_password.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  // =========================
  // SAFE PARSER
  // =========================
  String safeString(dynamic value) {
    return value?.toString() ?? '';
  }

  int safeInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // =========================
  // LOGIN
  // =========================
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email dan password tidak boleh kosong"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      print("LOGIN RESPONSE: $data");

      if (data['status'] == true) {
        final prefs = await SharedPreferences.getInstance();

        final user = data['user'] ?? {};

        await prefs.setBool('isLogin', true);
        await prefs.setString('name', safeString(user['name']));
        await prefs.setInt('user_id', safeInt(user['user_id']));
        await prefs.setString('auth_token', safeString(data['token']));
        await prefs.setString('image', safeString(user['image']));
        await prefs.setString('alamat', safeString(user['alamat']));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainPage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login berhasil"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (data['message'] == "Akun belum verifikasi OTP") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OtpPage(email: emailController.text.trim(), type: 'login'),
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Login gagal")),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server terlalu lama merespon")),
      );
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak bisa terhubung ke server")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  // =========================
  // UI INPUT
  // =========================
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
                // TOP SHAPE (TIDAK DIUBAH)
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
                        Icons.school,
                        size: 90,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),

                // LOGIN CARD (TIDAK DIUBAH)
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
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: const Color(0xFFFFFFFF),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                0,
                              ), 
                              child: Center(
                                child: Image.asset(
                                  "assets/tracerlogo.png",
                                  width: 560, // atur ukuran logo 
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Login",
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
                              "Please Sign in to continue.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          buildInputField(
                            controller: emailController,
                            hint: "Email",
                            icon: Icons.person_outline,
                          ),

                          buildInputField(
                            controller: passwordController,
                            hint: "Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LupaPasswordPage(
                                      email: emailController.text.trim(),
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xFF0F2D3F),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : login,
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
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have account? ",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
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
