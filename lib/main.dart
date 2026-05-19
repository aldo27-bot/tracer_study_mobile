import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:projectsemester4/screens/login_page.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("BACKGROUND NOTIF: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  try {
    print("[MAIN] Initializing Firebase...");

    await Firebase.initializeApp().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print("[MAIN] Firebase init timeout");
        throw Exception("Firebase initialization timeout");
      },
    );

    print("[MAIN] Firebase initialized");

    print("[MAIN] Initializing NotifService...");

    await NotifService.init();

    print("[MAIN] NotifService initialized");

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  } catch (e) {
    print("[MAIN ERROR] $e");
  }

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

  late PageController _pageController;

  void _setStatusBar(int index) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: index == 2
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: index == 2 ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1,
      keepPage: true,
    );

    getToken();
    getProfile();

    // HANDLE KLIK NOTIF LOKAL
    NotifService.onNotificationClick = (payload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (payload == 'job') {
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 450),
            curve: Curves.fastEaseInToSlowEaseOut,
          );
        }
      });
    };

    // =========================
    // klik NOTIFICATION
    // =========================

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      if (notification != null) {
        NotifService.show(
          notification.title ?? '',
          notification.body ?? '',

          // PAYLOAD
          payload: 'job',
        );
      }
    });

    // =========================
    // BACKGROUND NOTIFICATION CLICK
    // =========================

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    // =========================
    // TERMINATED NOTIFICATION CLICK
    // =========================

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationClick(message);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // =========================
  // HANDLE NOTIFICATION CLICK
  // =========================

  void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;

    int targetPage = 0;

    if (data['type'] == 'job') {
      targetPage = 2;
    }

    if (data['type'] == 'profile') {
      targetPage = 3;
    }

    if (data['type'] == 'home') {
      targetPage = 0;
    }

    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 450),
      curve: Curves.fastEaseInToSlowEaseOut,
    );
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
  // FORCE LOGOUT
  // =========================

  Future<void> forceLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // =========================
  // GET PROFILE
  // =========================

  Future<void> getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        await forceLogout();
        return;
      }

      final data = await ApiService.getProfile(userId);

      if (data['status'] == true && data['data'] != null) {
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
        await forceLogout();
      }
    } catch (e) {
      print("PROFILE ERROR: $e");

      await forceLogout();
    }
  }

  // =========================
  // NAVIGATION ITEM
  // =========================

  Widget buildNavItem(IconData icon, int index, String label) {
    bool isActive = _currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 450),
            curve: Curves.fastEaseInToSlowEaseOut,
          );
          _setStatusBar(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isActive ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  icon,
                  color: isActive ? const Color(0xFF0F2D3F) : Colors.grey,
                ),
              ),

              const SizedBox(height: 3),

              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: isActive ? 13 : 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? const Color.fromARGB(255, 236, 112, 4)
                      : Colors.grey,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    if (isLoading && alumni == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),

      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          pageSnapping: true,

          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });

            _setStatusBar(index);
          },

          children: [
            const HomePage(key: PageStorageKey('home')),
            const QuestionPage(key: PageStorageKey('question')),
            const JobsPage(key: PageStorageKey('jobs')),
            ProfilePage(key: const PageStorageKey('profile'), alumni: alumni!),
          ],
        ),

        bottomNavigationBar: SafeArea(
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
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
      ),
    );
  }
}
