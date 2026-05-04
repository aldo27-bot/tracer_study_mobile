import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projectsemester4/services/api_service.dart';

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({Key? key, required this.email}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final otpController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan OTP")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = await ApiService.verifyOtp(
        widget.email,
        otpController.text.trim(),
      );

      if (data['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verifikasi berhasil")),
        );

        // kembali ke login
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifikasi OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Kode OTP dikirim ke ${widget.email}"),
            const SizedBox(height: 20),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Masukkan OTP",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyOtp,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verifikasi"),
              ),
            )
          ],
        ),
      ),
    );
  }
}