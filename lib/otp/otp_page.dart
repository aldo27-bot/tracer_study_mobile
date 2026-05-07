import 'package:flutter/material.dart';
import 'package:projectsemester4/resetpassword/resetpassword.dart';
import 'package:projectsemester4/services/api_service.dart';

import '../screens/login_page.dart';

class OtpPage extends StatefulWidget {
  final String email;
  final String type; // register / forgot / login

  const OtpPage({
    Key? key,
    required this.email,
    required this.type,
  }) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final otpController = TextEditingController();

  bool isLoading = false;

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Masukkan OTP"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = await ApiService.verifyOtp(
        widget.email,
        otpController.text.trim(),
        widget.type,
      );

      if (data['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Verifikasi berhasil"),
          ),
        );

        // REGISTER
        if (widget.type == 'register') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginPage(),
            ),
            (route) => false,
          );
        }

        // FORGOT PASSWORD
        else if (widget.type == 'forgot') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ResetPasswordPage(
                    email: widget.email,
                  ),
            ),
          );
        }

        // LOGIN OTP
        else if (widget.type == 'login') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginPage(),
            ),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? "OTP salah",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan"),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    otpController.dispose();
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
            padding: const EdgeInsets.only(
              bottom: 30,
            ),
            child: Column(
              children: [
                // TOP SHAPE
                Stack(
                  children: [
                    Container(
                      height: 220,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F2D3F),
                        borderRadius:
                            BorderRadius.only(
                          bottomLeft:
                              Radius.circular(120),
                          bottomRight:
                              Radius.circular(120),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 35,
                      left: 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration:
                            const BoxDecoration(
                          color: Color(0xFF5D7B93),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 45,
                      right: 20,
                      child: Icon(
                        Icons.verified_user,
                        size: 90,
                        color: Colors.white
                            .withOpacity(0.15),
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
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                // OTP CARD
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Container(
                      padding:
                          const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.08),
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
                              borderRadius:
                                  BorderRadius.circular(
                                      22),
                              color:
                                  const Color(0xFFF5F5F5),
                            ),

                            child: Padding(
                              padding:
                                  const EdgeInsets.all(
                                      12),
                              child: Image.asset(
                                "assets/EnterOTP-pana.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // TITLE
                          const Align(
                            alignment:
                                Alignment.centerLeft,
                            child: Text(
                              "OTP Verification",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(0xFF22313F),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Align(
                            alignment:
                                Alignment.centerLeft,
                            child: Text(
                              "Kode OTP dikirim ke\n${widget.email}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // OTP FIELD
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFF5F5F5),
                              borderRadius:
                                  BorderRadius.circular(
                                      18),
                            ),
                            child: TextField(
                              controller:
                                  otpController,
                              keyboardType:
                                  TextInputType.number,
                              textAlign:
                                  TextAlign.center,
                              style: const TextStyle(
                                letterSpacing: 8,
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                              decoration:
                                  const InputDecoration(
                                hintText:
                                    "Enter OTP",
                                border:
                                    InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : verifyOtp,

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                        0xFF0F2D3F),
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              18),
                                ),
                              ),

                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color:
                                          Colors.white,
                                    )
                                  : const Text(
                                      "Verify OTP",
                                      style:
                                          TextStyle(
                                        fontSize: 16,
                                        color:
                                            Colors.white,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                            ),
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