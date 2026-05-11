import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  List<Map<String, dynamic>> questions = [];
  Map<int, dynamic> answers = {};
  bool isLoading = true;
  int userId = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ================= LOAD DATA =================
  Future<void> loadData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id') ?? 0;

      // SEKARANG LANGSUNG LIST
      List qList = await ApiService.getQuestions(userId);

      debugPrint("QUESTIONS: $qList");

      if (mounted) {
        setState(() {
          questions = List<Map<String, dynamic>>.from(qList);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ERROR LOAD DATA: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= CONDITIONAL =================
  bool shouldShow(Map<String, dynamic> q) {
    int id = int.tryParse(q['id'].toString()) ?? 0;
    final status = answers[1]?.toString() ?? "";

    if (id == 2) return status.contains("Bekerja");
    if (id == 3) return status.contains("Wiraswasta");

    return true;
  }

  // ================= DECORATION =================
  InputDecoration _dec(String h) => InputDecoration(
    hintText: h,
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );

  // ================= INPUT =================
  Widget buildInput(Map<String, dynamic> q) {
    int id = int.tryParse(q['id'].toString()) ?? 0;
    String type = q['type']?.toString() ?? "";
    String dataType = q['tipe_data']?.toString() ?? "text";

    // SUPER SAFE OPTIONS (ANTI CRASH)
    List options = [];
    if (q['options'] is List) {
      options = q['options'];
    }

    // ================= TEXT =================
    if (type == "text" && dataType == "text") {
      return TextFormField(
        initialValue: answers[id]?.toString(),
        onChanged: (v) => answers[id] = v,
        decoration: _dec("Jawaban..."),
      );
    }

    // ================= NUMBER =================
    if (type == "text" && (dataType == "number" || dataType == "year")) {
      return TextFormField(
        keyboardType: TextInputType.number,
        initialValue: answers[id]?.toString(),
        onChanged: (v) => answers[id] = v,
        decoration: _dec("Masukkan angka"),
      );
    }

    // ================= DATE =================
    if (type == "text" && dataType == "date") {
      return InkWell(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDate: DateTime.now(),
          );

          if (picked != null) {
            setState(() {
              answers[id] = picked.toIso8601String().split("T")[0];
            });
          }
        },
        child: InputDecorator(
          decoration: _dec("Pilih tanggal"),
          child: Text(
            answers[id]?.toString() ?? "Pilih tanggal",
            style: TextStyle(
              color: answers[id] == null ? Colors.grey : Colors.black,
            ),
          ),
        ),
      );
    }

    // ================= SINGLE =================
    if (type == "single") {
      return Column(
        children: options.map<Widget>((o) {
          String label = o['label']?.toString() ?? "-";

          return RadioListTile(
            value: label,
            groupValue: answers[id],
            onChanged: (v) {
              setState(() {
                answers[id] = v;

                if (id == 1) {
                  answers.remove(2);
                  answers.remove(3);
                }
              });
            },
            title: Text(label),
          );
        }).toList(),
      );
    }

    // ================= MULTIPLE =================
    if (type == "multiple") {
      List selected = List.from(answers[id] ?? []);

      return Column(
        children: options.map<Widget>((o) {
          String label = o['label']?.toString() ?? "-";

          return CheckboxListTile(
            value: selected.contains(label),
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  selected.add(label);
                } else {
                  selected.remove(label);
                }
                answers[id] = selected;
              });
            },
            title: Text(label),
          );
        }).toList(),
      );
    }

    return const SizedBox();
  }

  // ================= SUBMIT =================
  Future<void> submit() async {
    try {
      List payload = [];

      answers.forEach((k, v) {
        if (v is List) {
          // multiple choice — kirim sebagai option_ids
          // tapi karena kita simpan label bukan id, kirim sebagai value
          payload.add({
            "question_id": k,
            "option_ids": null,
            "value": jsonEncode(v),
          });
        } else {
          payload.add({
            "question_id": k,
            "option_ids": null,
            "value": v.toString(),
          });
        }
      });

      final res = await ApiService.submitAnswers(userId, payload);

      if (!mounted) return;

      if (res['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Jawaban berhasil dikirim")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Gagal mengirim jawaban")),
        );
      }
    } catch (e) {
      debugPrint("ERROR SUBMIT: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan, coba lagi")),
      );
    }
  }


  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final visibleQuestions = questions.where((q) => shouldShow(q)).toList();

    double progress = visibleQuestions.isEmpty
        ? 0
        : answers.length / visibleQuestions.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Tracer Study"), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Progress ${(progress * 100).toInt()}%"),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: progress),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: visibleQuestions.length,
                    itemBuilder: (c, i) {
                      var q = visibleQuestions[i];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${i + 1}. ${q['question_text'] ?? '-'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),

          child: SizedBox(
            height: 60,
            width: 200,
            
            child: ElevatedButton(
              onPressed: submit,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F2D3F), // warna button
                foregroundColor: const Color.fromARGB(255, 236, 112, 4), // warna teks
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              child: const Text(
                "Kirim Jawaban",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
