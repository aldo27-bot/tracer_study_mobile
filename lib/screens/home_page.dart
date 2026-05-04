import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "";

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
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.grid_view_rounded),
                  IconButton(
                    onPressed: () => logout(context),
                    icon: Icon(Icons.logout),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // GREETING
              Text(
                "Hi ${name.isNotEmpty ? name : 'Alumni'}",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              // SEARCH
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: "Cari",
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // WELCOME CARD
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Selamat datang!\nCek informasi terbaru seputar kampusmu di sini.",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),

                    // image assets
                    Image.asset("assets/work.png", height: 70),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ongoing Projects",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text("view all", style: TextStyle(color: Colors.grey)),
                ],
              ),

              SizedBox(height: 15),

              // GRID PROJECT
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    buildCard("Mobile App", "May 28, 2022", true),
                    buildCard("Dashboard", "May 28, 2022", false),
                    buildCard("Banner", "May 30, 2022", false),
                    buildCard("UI/UX", "May 30, 2022", false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(String title, String date, bool isMain) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isMain ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: TextStyle(
              color: isMain ? Colors.white70 : Colors.grey,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isMain ? Colors.white : Colors.black,
            ),
          ),
          Spacer(),
          LinearProgressIndicator(
            value: 0.5,
            backgroundColor: isMain ? Colors.white24 : Colors.grey.shade300,
            color: isMain ? Colors.white : Colors.blue,
          ),
        ],
      ),
    );
  }
}
