import 'package:flutter/material.dart';
import 'package:projectsemester4/services/api_service.dart';
import '../otp/otp_page.dart';

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({Key? key, required String email}) : super(key: key);

  @override
  _LupaPasswordPageState createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  final emailController = TextEditingController();
  bool isLoading = false;

  Future<void> kirimOtp() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email tidak boleh kosong")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = await ApiService.forgotPassword(emailController.text.trim());

      if (data['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP telah dikirim ke email")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OtpPage(email: emailController.text.trim(), type: 'forgot'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Gagal mengirim OTP")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lupa Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Masukkan email untuk menerima kode OTP",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : kirimOtp,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Kirim OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
