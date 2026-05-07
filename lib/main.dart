import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'screens/home_page.dart';
import 'screens/question_page.dart';
import 'screens/notification_page.dart';
import 'screens/profile_page.dart';
import 'services/api_service.dart';
import 'services/notif_service.dart';
import 'models/alumni_models.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("BACKGROUND NOTIF: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await NotifService.init();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  late AlumniModel alumni;

  final List<Widget> _pages = [];

  final List<String> _labels = ["Home", "Form", "Notifikasi", "Profil"];

  @override
  void initState() {
    super.initState();

    getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      if (notification != null) {
        NotifService.show(
          notification.title ?? '',
          notification.body ?? '',
        );
      }
    });

    // default dummy (biar tidak crash)
    alumni = AlumniModel(
      nim: "0",
      nama: "User",
      prodi: "",
      jurusan: "",
      angkatan: "",
      tempatLahir: "",
      tanggalLahir: "",
      tahunLulus: "",
      alamat: "",
    );

    _pages.addAll([
      const HomePage(),
      const QuestionPage(),
      const NotificationPage(),
      ProfilePage(alumni: alumni),
    ]);
  }

  Future<void> getToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();

      String? token = await messaging.getToken();

      print("FCM TOKEN: $token");

      if (token != null) {
        await ApiService.sendFcmToken(1, token);
      }
    } catch (e) {
      print("FCM ERROR: $e");
    }
  }

  Widget buildNavItem(IconData icon, int index, String label) {
    bool isActive = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.blue : Colors.grey),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          children: [
            buildNavItem(Icons.home, 0, _labels[0]),
            buildNavItem(Icons.assignment, 1, _labels[1]),
            buildNavItem(Icons.notifications, 2, _labels[2]),
            buildNavItem(Icons.person, 3, _labels[3]),
          ],
        ),
      ),
    );
  }
}