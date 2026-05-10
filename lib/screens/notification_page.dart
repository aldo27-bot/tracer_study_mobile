import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List notifications = [];
  String? lastSeen;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> saveLastSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_seen_notif',
      DateTime.now().toIso8601String(),
    );
  }

  bool isNewNotification(String createdAt) {
    if (lastSeen == null) return true;

    try {
      DateTime notifTime = DateTime.parse(createdAt);
      DateTime seenTime = DateTime.parse(lastSeen!);

      return notifTime.isAfter(seenTime);
    } catch (e) {
      return false;
    }
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('user_id') ?? 0;

    lastSeen = prefs.getString('last_seen_notif');

    final data = await ApiService.getNotifications(userId);

    setState(() {
      notifications = data;
    });

    // setelah data tampil, update last seen
    saveLastSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Notifikasi"),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("Belum ada notifikasi"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        const Icon(Icons.notifications),

                        if (isNewNotification(item['created_at']))
                          Positioned(
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                "BARU",
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(item['title'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['body'] ?? ''),
                        const SizedBox(height: 4),
                        Text(
                          item['created_at'] ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}