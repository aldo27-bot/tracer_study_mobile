import 'dart:convert';
import 'dart:async';
// import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lowongan_model.dart';

class ApiService {
  // static String baseUrl = "http://172.16.103.150:8000/api";
  static String baseUrl = "http://172.16.106.242:8000/api";

  // ==============================
  // HELPER
  // ==============================
  static void _checkHtmlResponse(String body) {
    final trimmed = body.trimLeft();
    if (trimmed.startsWith("<")) {
      throw Exception("Server mengembalikan HTML (error backend)");
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
        "message": data['message'] ?? "Terjadi kesalahan",
      };
    }
  }

  // ==============================
  // CEK ALUMNI
  // ==============================
  static Future<Map<String, dynamic>> cekAlumni(String nim) async {
    final url = Uri.parse("$baseUrl/cek-alumni?nim=$nim");

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  // ==============================
  // REGISTER
  // ==============================
  static Future<Map<String, dynamic>> register(
    String nim,
    String email,
    String username,
    String no_hp,
    String password,
  ) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/register"),
          headers: {"Accept": "application/json"},
          body: {
            "nim": nim,
            "email": email,
            "username": username,
            "no_hp": no_hp,
            "password": password},
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  // ==============================
  // VERIFY OTP (FIXED)
  // ==============================
  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
    String type,
  ) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/verify-otp"),
          headers: {"Accept": "application/json"},
          body: {"email": email, "otp": otp, "type": type},
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  // ==============================
  // LOGIN
  // ==============================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/login"),
          headers: {"Accept": "application/json"},
          body: {"email": email, "password": password},
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  // ==============================
  // FORGOT PASSWORD (FIX)
  // ==============================
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/forgot-password"),
          headers: {"Accept": "application/json"},
          body: {"email": email},
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  // ==============================
  // RESET PASSWORD (FIX ROUTE MATCH BACKEND)
  // ==============================
  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String password,
  ) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/reset-password-otp"),
          headers: {"Accept": "application/json"},
          body: {"email": email, "password": password},
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  // ==============================
  // RESEND OTP (FIXED)
  // ==============================
  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/resend-otp"),
          headers: {"Accept": "application/json"},
          body: {"email": email},
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  // ==============================
  // QUESTIONS
  // ==============================
  static Future<List> getQuestions(int userId) async {
    final url = Uri.parse("$baseUrl/questions?user_id=$userId");

    final response = await http
        .get(url, headers: {"Accept": "application/json"})
        .timeout(const Duration(seconds: 10));

    final res = _handleResponse(response);

    var data = res['data'];

    // NORMALISASI DATA
    if (data is String) {
      data = jsonDecode(data);
    }

    if (data is List) {
      return data;
    }

    return [];
  }

  // ==============================
  // SUBMIT ANSWERS
  // ==============================
  static Future<Map<String, dynamic>> submitAnswers(
    int userId,
    List answers,
    ) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.post(
        Uri.parse("$baseUrl/answers"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // ← token dikirim di sini
        },
        body: jsonEncode({"answers": answers}),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    }

  // ==============================
  // UPDATE ALAMAT
  // ==============================
  static Future<Map<String, dynamic>> updateAlamat(
    String nim,
    String alamat,
  ) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/update-alamat"),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"nim": nim, "alamat": alamat}),
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  // ==============================
  // HELPER ALUMNI
  // ==============================
  static Map<String, dynamic>? getAlumni(Map<String, dynamic> data) {
    return data['data'];
  }

  // ==============================
  // Kirim fcm token
  // ==============================
  static Future<void> sendFcmToken(int userId, String token) async {
    await http.post(
      Uri.parse("$baseUrl/save-fcm-token"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"user_id": userId, "token": token}),
    );
  }

  // ==============================
  // profile
  // ==============================
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile?user_id=$userId'),
      headers: {"Accept": "application/json"},
    );

    return _handleResponse(response);
  }
  // ==============================
  //edit rofile
  // ==============================

  static Future updateProfile(
    String nim,
    String nama,
    String prodi,
    int angkatan,
    int tahunLulus,
    String alamat,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update-profile"),
      body: {
        "nim": nim,
        "nama": nama,
        "prodi": prodi,
        "angkatan": angkatan.toString(),
        "tahun_lulus": tahunLulus.toString(),
        "alamat": alamat,
      },
    );

    return json.decode(response.body);
  }

  // ==============================
  //get lowongan
  // ==============================
  static Future<List<LowonganModel>> getLowongan() async {
    final response = await http.get(Uri.parse("$baseUrl/lowongan"));

    final data = jsonDecode(response.body);

    if (data['status'] == true) {
      return (data['data'] as List)
          .map((item) => LowonganModel.fromJson(item))
          .toList();
    }

    return [];
  }

  // ==============================
  //add lowongan
  // ==============================
  static Future<bool> addLowongan({
    required String posisi,
    required String namaPerusahaan,
    required String lokasi,
    required String gaji,
    required String deskripsi,
    required String batasLamaran,
    required String kontak,
    required String linkLamaran,
    required int dibuatOleh,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/lowongan"),

        headers: {"Accept": "application/json"},

        body: {
          "posisi": posisi,
          "nama_perusahaan": namaPerusahaan,
          "lokasi": lokasi,
          "gaji": gaji,
          "deskripsi": deskripsi,
          "batas_lamaran": batasLamaran,
          "kontak": kontak,
          "link_lamaran": linkLamaran,
          "dibuat_oleh": dibuatOleh.toString(),
        },
      );

      print(response.body);

      final data = jsonDecode(response.body);

      return data['status'] == true;
    } catch (e) {
      print("ERROR ADD LOWONGAN: $e");

      return false;
    }
  }

  // ==============================
  //statistik alumni
  // ==============================
  static Future<Map<String, dynamic>> getStatistikAlumni() async {
    final response = await http.get(
      Uri.parse("$baseUrl/statistik-alumni"),
      headers: {"Accept": "application/json"},
    );

    return _handleResponse(response);
  }


  // ==============================
  //get notification_page
  // ==============================
  static Future<List> getNotifications(int userId) async {
  final response = await http.get(
    Uri.parse("$baseUrl/notifications/$userId"),
    headers: {"Accept": "application/json"},
  );

  return jsonDecode(response.body);
}
}