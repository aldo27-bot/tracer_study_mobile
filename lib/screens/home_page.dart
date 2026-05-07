import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "";
  double progress = 0.65;

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    getName();
  }

  Future<void> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "";
    });
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
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
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(), // biar kiri kosong tetap seimbang

                  IconButton(
                    onPressed: () => logout(context),
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),

              const SizedBox(height: 0),

              Text(
                "Halo ${name.isNotEmpty ? name : 'Alumni'}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                "Dashboard Tracer Study",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // PROGRESS CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2D3F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tracer Study Progress",
                          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Lengkapi Data Kamu",
                          style: TextStyle(
                            color:  const Color.fromARGB(255, 236, 112, 4),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${(progress * 100).toInt()}% selesai",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 70,
                          width: 70,
                          child: CircularProgressIndicator(
                            value: progress,
                            color:  const Color.fromARGB(255, 236, 112, 4),
                            backgroundColor: Colors.white24,
                            strokeWidth: 6,
                          ),
                        ),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CALENDAR
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
                      color:  const Color.fromARGB(255, 236, 112, 4),
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

              const Text(
                "Statistik Alumni",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  statCard("Kerja", "75%", Colors.green),
                  const SizedBox(width: 10),
                  statCard("Kuliah", "15%", Colors.orange),
                  const SizedBox(width: 10),
                  statCard("Wirausaha", "10%", Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
