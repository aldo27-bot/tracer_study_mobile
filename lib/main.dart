import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/question_page.dart';
import 'screens/notification_page.dart';
import 'screens/profile_page.dart';
import 'package:flutter/services.dart';
import 'models/alumni_models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
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

  final List<Widget> _pages = [
    HomePage(),
    QuestionPage(),
    NotificationPage(),
    ProfilePage(
      alumni: AlumniModel(
        nama: "Agnes Monika",
        nim: "E41212xxx",
        prodi: "TIF Nganjuk",
        jurusan: "Teknologi Informasi",
        angkatan: "2021",
        tempatLahir: "Nganjuk",
        tanggalLahir: "30 Januari 2003",
        tahunLulus: "2025",
        alamat: "", // Biarkan kosong dulu untuk ngetes fitur edit kamu
        email: "e41241123@student.polije.ac.id",
      ),
    ),
  ];

  final List<String> _labels = ["Home", "Form", "Notifikasi", "Profil"];

  Widget buildNavItem(IconData icon, int index, String label) {
    bool isActive = _currentIndex == index;

    return Flexible(
      fit: FlexFit.tight,
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min, // penting anti overflow
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isActive ? Colors.blueAccent : Colors.grey,
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: isActive
                        ? Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 60),
                              child: Text(
                                label,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],

      bottomNavigationBar: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.only(left: 5, right: 5, bottom: 40),
            height: 60,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 230, 230, 230),
              borderRadius: BorderRadius.circular(16),
              border: const Border(
                top: BorderSide(color: Colors.black, width: 1),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildNavItem(Icons.home, 0, _labels[0]),
                buildNavItem(Icons.assignment, 1, _labels[1]),
                buildNavItem(Icons.notification_add, 2, _labels[2]),
                buildNavItem(Icons.person, 3, _labels[3]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
