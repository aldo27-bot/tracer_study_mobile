import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:projectsemester4/screens/notification_page.dart';
import 'package:projectsemester4/screens/question_page.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "";

  double progress = 0;

  // =========================
  // statistik realtime
  // =========================
  double kerjaPercent = 0;
  double wirausahaPercent = 0;

  int totalAlumni = 0;

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    getName();
    loadStatistik();
    loadProgress();
  }

  // =========================
  // load progress isian tracer study
  // =========================
  Future<void> loadProgress() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    progress = prefs.getDouble("progress") ?? 0;
  });
}

  // =========================
  // ambil nama user
  // =========================
  Future<void> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('name') ?? "";
    });
  }

  // =========================
  // statistik alumni realtime
  // =========================
  Future<void> loadStatistik() async {
    try {
      final res = await ApiService.getStatistikAlumni();

      print("STATISTIK API:");
      print(res);

      if (res['status'] == true) {
        final data = res['data'];

        int total = data['total'];
        int kerja = data['kerja'];
        int wirausaha = data['wirausaha'];

        setState(() {
          totalAlumni = total;

          kerjaPercent = total > 0 ? (kerja / total) * 100 : 0;

          wirausahaPercent = total > 0 ? (wirausaha / total) * 100 : 0;
        });
      }
    } catch (e) {
      print("ERROR STATISTIK:");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =========================
              // HEADER
              // =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const SizedBox(),

                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationPage(),
                      ),
                    ),

                    icon: const Icon(Icons.notifications, color: Colors.orange),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // =========================
              // sapaan
              // =========================
              Text(
                "Halo ${name.isNotEmpty ? name : 'Alumni'}",

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                "Dashboard Tracer Study",

                style: TextStyle(color: Colors.orange),
              ),

              const SizedBox(height: 25),

              // =========================
              // total alumni
              // =========================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: const Color(0xFF0F2D3F),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.groups,
                        color: Colors.orange,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          "Total Alumni",

                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "$totalAlumni Alumni",

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // =========================
              // calendar
              // =========================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(25),

                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),

                padding: const EdgeInsets.all(12),

                child: TableCalendar(
                  focusedDay: focusedDay,

                  firstDay: DateTime(2020),

                  lastDay: DateTime(2030),

                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),

                  onDaySelected: (selected, focused) {
                    setState(() {
                      selectedDay = selected;
                      focusedDay = focused;
                    });
                  },

                  onPageChanged: (focused) {
                    focusedDay = focused;
                  },

                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),

                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Color.fromARGB(255, 236, 112, 4),

                      shape: BoxShape.circle,
                    ),

                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF0F2D3F),

                      shape: BoxShape.circle,
                    ),

                    selectedTextStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // statistik alumni
              // =========================
              const Text(
                "Statistik Alumni",

                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  statCard(
                    "Kerja",
                    "${kerjaPercent.toStringAsFixed(0)}%",
                    Colors.green,
                  ),

                  const SizedBox(width: 10),

                  statCard(
                    "Wirausaha",
                    "${wirausahaPercent.toStringAsFixed(0)}%",
                    Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // card statistik
  // =========================
  Widget statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(15),
        ),

        child: Column(
          children: [
            Text(
              value,

              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 5),

            Text(title),
          ],
        ),
      ),
    );
  }
}
