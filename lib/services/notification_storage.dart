import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notif_model.dart';

class NotificationStorage {
  static const String key = "notifications";

  // ambil semua
  static Future<List<NotifModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data == null) return [];

    final List decoded = jsonDecode(data);

    return decoded.map((e) => NotifModel.fromJson(e)).toList();
  }

  // simpan semua
  static Future<void> saveAll(List<NotifModel> list) async {
    final prefs = await SharedPreferences.getInstance();

    final data = jsonEncode(list.map((e) => e.toJson()).toList());

    await prefs.setString(key, data);
  }

  // tambah 1 notif
  static Future<void> add(NotifModel notif) async {
    final list = await getAll();
    list.insert(0, notif);
    await saveAll(list);
  }

  // hapus semua (opsional)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}