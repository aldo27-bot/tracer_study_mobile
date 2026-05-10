import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_page.dart';
import 'screens/question_page.dart';
import 'screens/notification_page.dart';
import 'screens/profile_page.dart';
import 'services/api_service.dart';
import 'services/notif_service.dart';
import 'models/alumni_models.dart';
import 'splash_screen.dart';
import 'package:projectsemester4/lowongan_pekerjaan/jobs_page.dart';

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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
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
  bool isLoading = true;

  AlumniModel? alumni;

  final List<String> _labels = ["Home", "Form", "Jobs", "Profil"];

  @override
  void initState() {
    super.initState();

    getToken();
    getProfile();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      if (notification != null) {
        NotifService.show(
          notification.title ?? '',
          notification.body ?? '',
        );
      }
    });
  }

  // =========================
  // GET TOKEN FCM
  // =========================
  Future<void> getToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      String? token = await messaging.getToken();
      print("FCM TOKEN: $token");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        print("USER BELUM LOGIN");
        return;
      }

      if (token != null) {
        await ApiService.sendFcmToken(userId, token);
      }
    } catch (e) {
      print("FCM ERROR: $e");
    }
  }

  // =========================
  // GET PROFILE (FIXED 100%)
  // =========================
  Future<void> getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 1;

      final data = await ApiService.getProfile(userId);

      if (data['status'] == true) {
        final profile = data['data'];

        setState(() {
          alumni = AlumniModel(
            nim: profile['nim']?.toString() ?? '',
            nama: profile['nama']?.toString() ?? '',
            email: profile['email']?.toString(),
            prodi: profile['prodi']?.toString() ?? '',
            angkatan: profile['angkatan']?.toString() ?? '',
            tempatLahir: profile['tempat_lahir']?.toString() ?? '',
            tanggalLahir: profile['tanggal_lahir']?.toString() ?? '',
            tahunLulus: profile['tahun_lulus']?.toString() ?? '',
            alamat: profile['alamat']?.toString(),
          );

          isLoading = false;
        });
      } else {
        setState(() {
          alumni = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("PROFILE ERROR: $e");

      setState(() {
        alumni = null;
        isLoading = false;
      });
    }
  }

  // =========================
  // NAV ITEM
  // =========================
  Widget buildNavItem(IconData icon, int index, String label) {
    bool isActive = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF0F2D3F)
                  : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive
                    ? const Color.fromARGB(255, 236, 112, 4)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // PAGE HANDLER (SAFE)
  // =========================
  Widget getPage(int index) {
    if (alumni == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const QuestionPage();
      case 2:
        return const JobsPage();
      case 3:
        return ProfilePage(alumni: alumni!);
      default:
        return const HomePage();
    }
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    if (isLoading && alumni == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: getPage(_currentIndex),

      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 5),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                buildNavItem(Icons.home, 0, _labels[0]),
                buildNavItem(Icons.assignment, 1, _labels[1]),
                buildNavItem(Icons.work_outline, 2, _labels[2]),
                buildNavItem(Icons.person, 3, _labels[3]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}