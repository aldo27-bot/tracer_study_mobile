import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // static String baseUrl = "http://172.16.106.213:8000/api";
  static String baseUrl = "http://192.168.1.8:8000/api";

  // CEK ALUMNI
  static Future cekAlumni(String nim) async {
    try {
      var url = Uri.parse("$baseUrl/cek-alumni?nim=$nim");

      var response = await http.get(url).timeout(Duration(seconds: 10));

      print("CEK ALUMNI STATUS: ${response.statusCode}");
      print("CEK ALUMNI BODY: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Gagal cek alumni");
      }
    } catch (e) {
      print("ERROR CEK ALUMNI: $e");
      throw Exception("Koneksi gagal");
    }
  }

  // REGISTER
  static Future register(String nim, String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/register"),
            headers: {"Accept": "application/json"},
            body: {"nim": nim, "email": email, "password": password},
          )
          .timeout(Duration(seconds: 10));

      print("REGISTER STATUS: ${response.statusCode}");
      print("REGISTER BODY: ${response.body}");

      final data = jsonDecode(response.body);

      return data;
    } catch (e) {
      print("ERROR REGISTER: $e");
      throw Exception("Koneksi gagal");
    }
  }

  // VERIFY OTP

  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/verify-otp'),
          body: {'email': email, 'otp': otp},
        )
        .timeout(const Duration(seconds: 10));

    return jsonDecode(response.body);
  }

  // LOGIN
  static Future login(String email, String password) async {
    try {
      var url = Uri.parse("$baseUrl/login");

      var response = await http
          .post(
            url,
            headers: {"Accept": "application/json"},
            body: {"email": email, "password": password},
          )
          .timeout(Duration(seconds: 10));

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      final data = jsonDecode(response.body);

      return data;
    } catch (e) {
      print("ERROR LOGIN: $e");
      throw Exception("Koneksi gagal");
    }
  }

  //helper untuk ambil data alumni dari response cek-alumni
  static Map<String, dynamic>? getAlumni(Map<String, dynamic> data) {
    return data['alumni'];
  }

  // GET QUESTIONS
  static Future<Map<String, dynamic>> getQuestions(int userId) async {
    try {
      final url = Uri.parse("$baseUrl/questions?user_id=$userId");

      final response = await http
          .get(url, headers: {"Accept": "application/json"})
          .timeout(Duration(seconds: 10));

      print("QUESTION STATUS: ${response.statusCode}");
      print("QUESTION BODY: ${response.body}");

      if (response.body.startsWith("<")) {
        throw Exception("Server mengembalikan HTML");
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal ambil soal");
      }
    } catch (e) {
      print("ERROR QUESTION: $e");
      throw Exception("Koneksi gagal");
    }
  }

  // SUBMIT JAWABAN
  static Future<Map<String, dynamic>> submitAnswers(
    int userId,
    List answers,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/answers");

      final response = await http
          .post(
            url,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"user_id": userId, "answers": answers}),
          )
          .timeout(Duration(seconds: 10));

      print("SUBMIT STATUS: ${response.statusCode}");
      print("SUBMIT BODY: ${response.body}");

      if (response.body.startsWith("<")) {
        throw Exception("Server error (HTML)");
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Submit gagal");
      }
    } catch (e) {
      print("ERROR SUBMIT: $e");
      throw Exception("Koneksi gagal");
    }
  }
}
