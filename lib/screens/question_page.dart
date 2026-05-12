import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  List<Map<String, dynamic>> questions = [];
  Map<Object, dynamic> answers = {};
  bool isLoading = true;
  int userId = 0;
  String get draftKey => "draft_answers_$userId";

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

      List qList = await ApiService.getQuestions(userId);
      debugPrint("QUESTIONS loaded: ${qList.length}");

      if (mounted) {
        setState(() {
          questions = List<Map<String, dynamic>>.from(qList);
          isLoading = false;
        });
        await loadDraft();
      }
    } catch (e) {
      debugPrint("ERROR LOAD DATA: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= Simpan sementara =================
  Future<void> simpanSementara() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> data = {
      "answers": answers.map((key, value) {
        return MapEntry(key.toString(), value);
      }),
      "saved_at": DateTime.now().toIso8601String(),
    };

    await prefs.setString(draftKey, jsonEncode(data));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Jawaban berhasil disimpan sementara"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // ================= Load data yang disimpan =================
  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(draftKey);
    if (raw == null) return;

    final data = jsonDecode(raw);

    final savedAnswers = data["answers"] as Map<String, dynamic>;

    setState(() {
      answers = savedAnswers.map((key, value) {
        return MapEntry(int.tryParse(key) ?? key, value);
      });
    });
  }

  // ================= HELPER: ambil jawaban berdasarkan kode_soal =================
  String _getAnswerByKode(String kode) {
    final q = questions.firstWhere(
      (q) => q['kode_soal']?.toString() == kode,
      orElse: () => {},
    );
    if (q.isEmpty) return '';
    final id = int.tryParse(q['id'].toString()) ?? 0;
    final val = answers[id];
    if (val is List) return val.join(',');
    return val?.toString() ?? '';
  }

  // ================= CONDITIONAL =================
  bool shouldShow(Map<String, dynamic> q) {
    final kode = q['kode_soal']?.toString() ?? '';
    final status = _getAnswerByKode('f8');

    // Hanya tampil jika pilih "Bekerja"
    if ([
      'f502',
      'f505',
      'f5a1',
      'f5a2',
      'f1101',
      'f1102',
      'f5b',
      'f5d',
      'f6',
      'f7',
      'f7a',
    ].contains(kode)) {
      return status.contains('Bekerja');
    }

    // Hanya tampil jika pilih "Wiraswasta"
    if (['f503', 'f5c'].contains(kode)) {
      return status.contains('Wiraswasta');
    }

    // Hanya tampil jika pilih "Melanjutkan Pendidikan"
    if (['f18a', 'f18b', 'f18c', 'f18d'].contains(kode)) {
      return status.contains('Melanjutkan Pendidikan');
    }

    // f302 hanya tampil jika f301 = pilihan "sebelum lulus"
    if (kode == 'f302') {
      return _getAnswerByKode('f301').contains('sebelum lulus');
    }

    // f303 hanya tampil jika f301 = pilihan "sesudah lulus"
    if (kode == 'f303') {
      return _getAnswerByKode('f301').contains('sesudah lulus');
    }

    // f1002 hanya tampil jika f1001 = "Lainnya"
    if (kode == 'f1002') {
      return _getAnswerByKode('f1001').contains('Lainnya');
    }

    // f416 hanya tampil jika f401-f416 memilih "Lainnya"
    if (kode == 'f416') {
      return _getAnswerByKode('f401-f416').contains('Lainnya');
    }

    // f1102 hanya tampil jika f1101 = "Lainnya"
    if (kode == 'f1102') {
      return _getAnswerByKode('f1101').contains('Lainnya');
    }

    // f1202 hanya tampil jika f1201 = "Lainnya"
    if (kode == 'f1202') {
      return _getAnswerByKode('f1201').contains('Lainnya');
    }

    // f1614 hanya tampil jika f1601-f1614 memilih "Lainnya"
    if (kode == 'f1614') {
      return _getAnswerByKode('f1601-f1614').contains('Lainnya');
    }

    return true;
  }

  // ================= DECORATION =================
  InputDecoration _dec(String h) => InputDecoration(
    hintText: h,
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  // ================= INPUT =================
  Widget buildInput(Map<String, dynamic> q) {
    int id = int.tryParse(q['id'].toString()) ?? 0;
    String type = q['type']?.toString() ?? '';
    String dataType = q['tipe_data']?.toString() ?? 'text';

    List options = [];
    if (q['options'] is List) options = q['options'];

    // ================= TEXT =================
    if (type == 'text' && dataType == 'text') {
      return TextFormField(
        initialValue: answers[id]?.toString(),
        onChanged: (v) => answers[id] = v,
        decoration: _dec('Jawaban...'),
      );
    }

    // ================= NUMBER / YEAR =================
    if (type == 'text' && (dataType == 'number' || dataType == 'year')) {
      return TextFormField(
        keyboardType: TextInputType.number,
        initialValue: answers[id]?.toString(),
        onChanged: (v) => answers[id] = v,
        decoration: _dec('Masukkan angka'),
      );
    }

    // ================= DATE =================
    if (type == 'text' && dataType == 'date') {
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
              answers[id] = picked.toIso8601String().split('T')[0];
            });
          }
        },
        child: InputDecorator(
          decoration: _dec('Pilih tanggal'),
          child: Text(
            answers[id]?.toString() ?? 'Pilih tanggal',
            style: TextStyle(
              color: answers[id] == null ? Colors.grey : Colors.black,
            ),
          ),
        ),
      );
    }

    // ================= SINGLE =================
    if (type == 'single') {
      return Column(
        children: options.map<Widget>((o) {
          String label = o['label']?.toString() ?? '-';
          return RadioListTile(
            value: label,
            groupValue: answers[id],
            onChanged: (v) {
              setState(() {
                answers[id] = v;
                // Reset jawaban kondisional saat status berubah
                if (q['kode_soal'] == 'f8') {
                  _resetConditionalAnswers();
                }
              });
            },
            title: Text(label),
            dense: true,
          );
        }).toList(),
      );
    }

    // ================= MULTIPLE =================
    if (type == 'multiple') {
      List selected = List.from(answers[id] ?? []);
      return Column(
        children: options.map<Widget>((o) {
          String label = o['label']?.toString() ?? '-';
          return CheckboxListTile(
            value: selected.contains(label),
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  selected.add(label);
                } else {
                  selected.remove(label);
                }
                answers[id] = List.from(selected);
              });
            },
            title: Text(label),
            dense: true,
          );
        }).toList(),
      );
    }

    // ================= SCALE (1-5) =================
    if (type == 'scale') {
      final scaleLabels = [
        'Sangat\nRendah',
        'Rendah',
        'Sedang',
        'Tinggi',
        'Sangat\nTinggi',
      ];
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (i) {
          final val = (i + 1).toString();
          final isSelected = answers[id]?.toString() == val;
          return GestureDetector(
            onTap: () => setState(() => answers[id] = val),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isSelected
                      ? const Color(0xFF0F2D3F)
                      : Colors.grey.shade200,
                  child: Text(
                    val,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scaleLabels[i],
                  style: const TextStyle(fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      );
    }

    // ================= MATRIX =================
    if (type == 'matrix') {
      List details = [];
      if (q['details'] is List) details = q['details'];
      if (details.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skala
          Row(
            children: [
              const Expanded(flex: 3, child: SizedBox()),
              ...['1', '2', '3', '4', '5'].map(
                (s) => Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(flex: 3, child: SizedBox()),
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sangat\nRendah',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Sangat\nTinggi',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          // Baris per item
          ...details.map<Widget>((detail) {
            final detailId = detail['id'].toString();
            final label = detail['label']?.toString() ?? '-';
            final mapKey = '${id}_$detailId';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(label, style: const TextStyle(fontSize: 12)),
                  ),
                  ...List.generate(5, (i) {
                    final val = (i + 1).toString();
                    final isSelected = answers[mapKey]?.toString() == val;
                    return Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => setState(() => answers[mapKey] = val),
                        child: Center(
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: isSelected
                                ? const Color(0xFF0F2D3F)
                                : Colors.grey.shade200,
                            child: Text(
                              val,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      );
    }

    return const SizedBox();
  }

  // ================= RESET KONDISIONAL =================
  void _resetConditionalAnswers() {
    // Kode soal yang kondisional — hapus jawabannya saat status berubah
    final conditionalKodes = [
      'f502',
      'f503',
      'f505',
      'f5a1',
      'f5a2',
      'f1101',
      'f1102',
      'f5b',
      'f5c',
      'f5d',
      'f18a',
      'f18b',
      'f18c',
      'f18d',
    ];
    for (final kode in conditionalKodes) {
      final q = questions.firstWhere(
        (q) => q['kode_soal']?.toString() == kode,
        orElse: () => {},
      );
      if (q.isNotEmpty) {
        final id = int.tryParse(q['id'].toString()) ?? 0;
        answers.remove(id);
      }
    }
  }

  // ================= SUBMIT =================
  Future<void> submit() async {
    try {
      List payload = [];

      answers.forEach((k, v) {
        // Skip key matrix (format "questionId_detailId")
        if (k.toString().contains('_')) return;

        payload.add({
          'question_id': k,
          'value': v is List ? jsonEncode(v) : v.toString(),
        });
      });

      // Tambahkan jawaban matrix (key format "questionId_detailId")
      answers.forEach((k, v) {
        if (k.toString().contains('_')) {
          final parts = k.toString().split('_');
          payload.add({
            'question_id': int.tryParse(parts[0]) ?? 0,
            'value': v.toString(),
            'detail_id': int.tryParse(parts[1]) ?? 0,
          });
        }
      });

      final res = await ApiService.submitAnswers(userId, payload);

      if (!mounted) return;

      if (res['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jawaban berhasil dikirim'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Gagal mengirim jawaban'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('ERROR SUBMIT: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan, coba lagi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final visibleQuestions = questions.where((q) => shouldShow(q)).toList();

    // Hitung progress hanya dari pertanyaan yang visible dan non-matrix
    int answered = 0;
    for (final q in visibleQuestions) {
      final id = int.tryParse(q['id'].toString()) ?? 0;
      if (answers.containsKey(id) && answers[id] != null) answered++;
    }
    double progress = visibleQuestions.isEmpty
        ? 0
        : answered / visibleQuestions.length;

    // SIMPAN KE SHARED PREFS
    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble("progress_$userId", progress);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Tracer Study'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress ${(progress * 100).toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '$answered / ${visibleQuestions.length} pertanyaan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF0F2D3F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // List pertanyaan
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: visibleQuestions.length,
                    itemBuilder: (c, i) {
                      var q = visibleQuestions[i];
                      final hint = q['hint']?.toString() ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nomor + teks pertanyaan
                              Text(
                                '${i + 1}. ${q['question_text'] ?? '-'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              // Hint / keterangan
                              if (hint.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: Colors.blue.shade600,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          hint,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue.shade700,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
          child: Row(
            children: [
              // Tombol Simpan Sementara
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: simpanSementara,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2D3F),
                      foregroundColor: const Color.fromARGB(255, 236, 112, 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Simpan", textAlign: TextAlign.center),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Tombol Kirim
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2D3F),
                      foregroundColor: const Color.fromARGB(255, 236, 112, 4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Kirim',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
