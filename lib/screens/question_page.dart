import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  List questions = [];
  Map<int, dynamic> answers = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserAndFetch();
  }

  void loadUserAndFetch() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;

      if (userId == 0) {
        print("USER ID TIDAK ADA");
        return;
      }

      var res = await ApiService.getQuestions(userId);

      print("RESPONSE: $res");

      if (res['data'] == null) {
        print("DATA NULL");
        return;
      }

      List qList = res['data'] is String
          ? jsonDecode(res['data'])
          : res['data'];

      for (var q in qList) {
        int id = int.parse(q['id'].toString());

        if (q['answer'] != null) {
          answers[id] = q['answer'];
        }
      }

      setState(() {
        questions = qList;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR LOAD: $e");
    }
  }

  // ================= INPUT BUILDER =================
  Widget buildInput(q) {
    int id = int.parse(q['id'].toString());
    String type = q['type'];

    if (type == "text") {
      return TextFormField(
        initialValue: answers[id]?.toString() ?? "",
        onChanged: (val) => answers[id] = val,
        decoration: InputDecoration(
          hintText: "Tulis jawaban...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    if (type == "number") {
      return TextFormField(
        keyboardType: TextInputType.number,
        initialValue: answers[id]?.toString() ?? "",
        onChanged: (val) => answers[id] = val,
        decoration: InputDecoration(
          hintText: "Masukkan angka...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    if (type == "radio") {
      List opsi = q['options'] ?? [];

      return Column(
        children: opsi.map<Widget>((o) {
          return RadioListTile(
            value: o,
            groupValue: answers[id],
            onChanged: (val) {
              setState(() {
                answers[id] = val;
              });
            },
            title: Text(o),
          );
        }).toList(),
      );
    }

    if (type == "checkbox") {
  List opsi = q['options'] ?? [];

  List selected = [];

  var rawAnswer = answers[id];

  if (rawAnswer != null) {
    if (rawAnswer is String) {
      try {
        selected = List<String>.from(jsonDecode(rawAnswer));
      } catch (e) {
        selected = [];
      }
    } else if (rawAnswer is List) {
      selected = rawAnswer;
    }
  }

  return Column(
    children: opsi.map<Widget>((o) {
      return CheckboxListTile(
        value: selected.contains(o),
        onChanged: (val) {
          setState(() {
            if (val == true) {
              selected.add(o);
            } else {
              selected.remove(o);
            }
            answers[id] = selected;
          });
        },
        title: Text(o),
      );
    }).toList(),
  );
}

    return SizedBox();
  }

  // ================= SUBMIT =================
  void submit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('user_id') ?? 0;

    if (answers.length < questions.length) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Harap isi semua pertanyaan")));
      return;
    }

    List payload = [];

    answers.forEach((key, value) {
      payload.add({
        "question_id": key,
        "answer": value is List ? jsonEncode(value) : value.toString(),
      });
    });

    print("=== DEBUG KIRIM ===");
    print("USER ID: $userId");
    print("PAYLOAD: $payload");

    try {
      var res = await ApiService.submitAnswers(userId, payload);

      print("RESPONSE: $res");

      if (res['status'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Jawaban berhasil dikirim")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal kirim")));
      }
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ================= UI =================
  @override
Widget build(BuildContext context) {
  double progress = questions.isEmpty ? 0 : answers.length / questions.length;

  final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

  return Scaffold(
    appBar: AppBar(
      title: Text("Form Tracer Study"),
      centerTitle: true,
    ),

    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : SafeArea(
            child: Column(
              children: [
                // ================= PROGRESS =================
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Progress Pengisian"),
                      SizedBox(height: 5),
                      LinearProgressIndicator(value: progress),
                    ],
                  ),
                ),

                // ================= LIST =================
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    itemCount: questions.length,
                    itemBuilder: (context, i) {
                      var q = questions[i];

                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${i + 1}. ${q['question_text']}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              buildInput(q),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

    // ================= BUTTON =================
    bottomNavigationBar: SafeArea(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black12),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: submit,
            child: Text("Kirim Jawaban"),
          ),
        ),
      ),
    ),
  );
}
}