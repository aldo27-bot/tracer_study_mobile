import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static String baseUrl = "http://172.16.115.119:8000/api";

  // ==============================
  // HELPER
  // ==============================
  static void _checkHtmlResponse(String body) {
    if (body.startsWith("<")) {
      throw Exception("Server error (HTML response)");
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    _checkHtmlResponse(response.body);

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      return {
        "status": false,
        "message": data['message'] ?? "Terjadi kesalahan"
      };
    }
  }

  // ==============================
  // CEK ALUMNI
  // ==============================
  static Future<Map<String, dynamic>> cekAlumni(String nim) async {
    try {
      final url = Uri.parse("$baseUrl/cek-alumni?nim=$nim");

      final response =
          await http.get(url).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("Server lama merespon");
    } on SocketException {
      throw Exception("Tidak ada koneksi internet");
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // ==============================
  // REGISTER
  // ==============================
  static Future<Map<String, dynamic>> register(
      String nim, String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/register"),
            headers: {"Accept": "application/json"},
            body: {"nim": nim, "email": email, "password": password},
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("Server terlalu lama merespon");
    } on SocketException {
      throw Exception("Tidak ada koneksi internet");
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // ==============================
  // VERIFY OTP
  // ==============================
  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp, String type) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/verify-otp"),
            headers: {"Accept": "application/json"},
            body: {'email': email, 'otp': otp, 'type': type},
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("OTP timeout (server lama)");
    } on SocketException {
      throw Exception("Tidak ada koneksi internet");
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // ==============================
  // LOGIN
  // ==============================
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/login"),
            headers: {"Accept": "application/json"},
            body: {"email": email, "password": password},
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("Server lambat");
    } on SocketException {
      throw Exception("Tidak ada koneksi internet");
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // ==============================
  // GET QUESTIONS
  // ==============================
  static Future<Map<String, dynamic>> getQuestions(int userId) async {
    try {
      final url = Uri.parse("$baseUrl/questions?user_id=$userId");

      final response = await http
          .get(url, headers: {"Accept": "application/json"})
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("Server lama merespon");
    } on SocketException {
      throw Exception("Tidak ada koneksi internet");
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // ==============================
  // SUBMIT ANSWERS
  // ==============================
  static Future<Map<String, dynamic>> submitAnswers(
      int userId, List answers) async {
    try {
      final url = Uri.parse("$baseUrl/answers");

      final response = await http
          .post(
            url,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "user_id": userId,
              "answers": answers,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("Server lama merespon");
    } on SocketException {
      throw Exception("Tidak ada koneksi internet");
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // ==============================
  // HELPER ALUMNI
  // ==============================
  static Map<String, dynamic>? getAlumni(Map<String, dynamic> data) {
    return data['data'];
  }

  // ==============================
  // Resend otp api
  // ==============================

  static Future<Map<String, dynamic>> resendOtp(String email, String type) async {
  try {
    final response = await http
        .post(
          Uri.parse("$baseUrl/resend-otp"),
          headers: {"Accept": "application/json"},
          body: {
            "email": email,
             "type": type},
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  } catch (e) {
    throw Exception("Error resend OTP: $e");
  }
}

  // ==============================
  // Forgot password
  // ==============================

static Future<Map<String, dynamic>> forgotPassword(String email) async {
  try {
    final response = await http
        .post(
          Uri.parse("$baseUrl/forgot-password"),
          headers: {"Accept": "application/json"},
          body: {
            "email": email,
          },
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  } catch (e) {
    throw Exception("Error forgot password: $e");
  }
}

  // ==============================
  // Reset password
  // ==============================

static Future<Map<String, dynamic>> resetPassword(
    String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/reset-password-otp"),
      headers: {"Accept": "application/json"},
      body: {
        "email": email,
        "password": password,
      },
    );

    return _handleResponse(response);
  } catch (e) {
    throw Exception("Error reset password: $e");
  }
}


}