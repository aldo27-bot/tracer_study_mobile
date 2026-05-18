import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

// =============================================
// KONSTANTA WARNA & STYLE
// =============================================
const _kPrimary = Color(0xFF0F2D3F);
const _kAccent = Color(0xFFEC7004);
const _kBgPage = Color(0xFFF4F6F9);

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});
  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  List<Map<String, dynamic>> questions = [];
  Map<Object, dynamic> answers = {};
  bool isLoading = true;
  bool _isSubmitting = false;
  int userId = 0;

  String get draftKey => "draft_answers_$userId";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // =============================================
  // NOTIFIKASI ATAS
  // =============================================
  void _showTopSnackBar(
    String message,
    Color color, {
    IconData icon = Icons.info_outline,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 14,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), entry.remove);
  }

  // =============================================
  // LOAD DATA
  // =============================================
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id') ?? 0;
      final qList = await ApiService.getQuestions(userId);
      if (mounted) {
        setState(() {
          questions = List<Map<String, dynamic>>.from(qList);
          // saved_answer tidak ada di API response — jawaban di-load dari draft
          isLoading = false;
        });
        await loadDraft();
      }
    } catch (e) {
      debugPrint("ERROR LOAD DATA: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // =============================================
  // DRAFT
  // =============================================
  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(draftKey);
  }

  Future<void> simpanSementara() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      draftKey,
      jsonEncode({
        "answers": answers.map((k, v) => MapEntry(k.toString(), v)),
        "saved_at": DateTime.now().toIso8601String(),
      }),
    );
    if (!mounted) return;
    _showTopSnackBar(
      'Jawaban disimpan sementara',
      const Color(0xFF1565C0),
      icon: Icons.save_outlined,
    );
  }

  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(draftKey);
    if (raw == null) return;

    try {
      final data = jsonDecode(raw);
      final savedAnswers = data["answers"] as Map<String, dynamic>;
      final typeById = {
        for (final q in questions)
          q['id'].toString(): q['type']?.toString() ?? '',
      };
      final validIds = questions.map((q) => q['id'].toString()).toSet();

      setState(() {
        answers = {};
        savedAnswers.forEach((key, value) {
          final baseId = key.contains('_') ? key.split('_')[0] : key;
          if (!validIds.contains(baseId)) return;
          final rKey = int.tryParse(key) ?? key;
          final qType = typeById[baseId] ?? '';
          if (qType == 'multiple') {
            answers[rKey] = _parseMultipleValue(value);
          } else if (qType == 'single' || qType == 'scale' || qType == 'text') {
            answers[rKey] = (value is List)
                ? (value.isNotEmpty ? value.first.toString() : null)
                : value?.toString();
          } else {
            // matrix key format: "questionId_detailId"
            answers[rKey] = value;
          }
        });
      });
    } catch (e) {
      debugPrint("ERROR LOAD DRAFT: $e");
    }
  }

  List<dynamic> _parseMultipleValue(dynamic value) {
    if (value == null) return [];
    if (value is List) return List<dynamic>.from(value);
    if (value is String && value.isNotEmpty) {
      try {
        final d = jsonDecode(value);
        if (d is List) return List<dynamic>.from(d);
      } catch (_) {}
    }
    return [];
  }

  // =============================================
  // HELPER
  // =============================================
  String _getAnswerByKode(String kode) {
    final q = questions.firstWhere(
      (q) => q['kode_soal']?.toString() == kode,
      orElse: () => {},
    );
    if (q.isEmpty) return '';
    final val = answers[int.tryParse(q['id'].toString()) ?? 0];
    if (val is List) return val.join(',');
    return val?.toString() ?? '';
  }

  bool _isAnswered(Map<String, dynamic> q) {
    final id = int.tryParse(q['id'].toString()) ?? 0;
    final type = q['type']?.toString() ?? '';
    if (type == 'matrix') {
      final details = q['details'] is List ? q['details'] as List : [];
      if (details.isEmpty) return false;
      return details.every((d) {
        final mapKey = '${id}_${d['id']}';
        return answers.containsKey(mapKey) &&
            answers[mapKey] != null &&
            answers[mapKey].toString().isNotEmpty;
      });
    }
    final val = answers[id];
    if (val == null) return false;
    if (val is List) return val.isNotEmpty;
    return val.toString().isNotEmpty;
  }

  // =============================================
  // CONDITIONAL — logika tampil/sembunyi soal
  // berdasarkan kode soal Kemendikbud
  // =============================================
  bool shouldShow(Map<String, dynamic> q) {
    final kode = q['kode_soal']?.toString() ?? '';
    final status = _getAnswerByKode('f8');

    // ---- Hanya tampil jika status = Bekerja ----
    if ([
      'f502', // bulan dapat pekerjaan pertama
      'f5a1', // provinsi tempat bekerja
      'f5a2', // kota/kabupaten tempat bekerja
      'f1101', // jenis perusahaan
      'f5b', // nama perusahaan
      'f5d', // tingkat tempat kerja
      'f6', // jumlah perusahaan dilamar
      'f7', // yang merespons
      'f7a', // yang wawancara
    ].contains(kode)) {
      return status.contains('Bekerja');
    }

    // ---- f505 (pendapatan) tampil untuk Bekerja DAN Wiraswasta ----
    if (kode == 'f505') {
      return status.contains('Bekerja') || status.contains('Wiraswasta');
    }

    // ---- Hanya tampil jika status = Wiraswasta ----
    if ([
      'f503', // bulan mulai wiraswasta
      'f5c', // posisi/jabatan wiraswasta
    ].contains(kode)) {
      return status.contains('Wiraswasta');
    }

    // ---- Hanya tampil jika status = Melanjutkan Pendidikan ----
    if ([
      'f18a', // sumber biaya studi lanjut
      'f18b', // perguruan tinggi
      'f18c', // program studi
      'f18d', // tanggal masuk
    ].contains(kode)) {
      return status.contains('Melanjutkan Pendidikan');
    }

    // ---- f1101 lainnya (jenis perusahaan lainnya) ----
    if (kode == 'f1102') {
      return _getAnswerByKode('f1101').contains('Lainnya');
    }

    // ---- f1201 lainnya (sumber dana lainnya) ----
    if (kode == 'f1202') {
      return _getAnswerByKode('f1201').contains('Lainnya');
    }

    // ---- f301 kondisional: bulan sebelum/sesudah lulus ----
    if (kode == 'f302') {
      return _getAnswerByKode('f301').contains('sebelum lulus');
    }
    if (kode == 'f303') {
      return _getAnswerByKode('f301').contains('sesudah lulus');
    }

    // ---- f401-f416 lainnya ----
    if (kode == 'f416') {
      return _getAnswerByKode('f401-f416').contains('Lainnya');
    }

    // ---- f1001 lainnya ----
    if (kode == 'f1002') {
      return _getAnswerByKode('f1001').contains('Lainnya');
    }

    // ---- f1601-f1614 lainnya ----
    if (kode == 'f1614') {
      return _getAnswerByKode('f1601-f1614').contains('Lainnya');
    }

    // Semua pertanyaan lain selalu tampil
    return true;
  }

  void _resetConditionalAnswers() {
    // Reset semua jawaban kondisional saat status (f8) berubah
    for (final kode in [
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
    ]) {
      final q = questions.firstWhere(
        (q) => q['kode_soal']?.toString() == kode,
        orElse: () => {},
      );
      if (q.isNotEmpty) {
        answers.remove(int.tryParse(q['id'].toString()) ?? 0);
      }
    }
  }

  // =============================================
  // INPUT DECORATION
  // =============================================
  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _kPrimary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  // =============================================
  // BUILD INPUT PER TIPE
  // =============================================
  Widget buildInput(Map<String, dynamic> q) {
    final id = int.tryParse(q['id'].toString()) ?? 0;
    final type = q['type']?.toString() ?? '';
    final dataType = q['tipe_data']?.toString() ?? 'text';
    final options = q['options'] is List ? q['options'] as List : [];

    // ---- TEXT ----
    if (type == 'text' && dataType == 'text') {
      return TextFormField(
        initialValue: answers[id]?.toString(),
        onChanged: (v) => setState(() => answers[id] = v),
        maxLines: 3,
        decoration: _dec('Tulis jawaban Anda di sini...'),
        style: const TextStyle(fontSize: 14),
      );
    }

    // ---- NUMBER / YEAR ----
    if (type == 'text' && (dataType == 'number' || dataType == 'year')) {
      return TextFormField(
        keyboardType: TextInputType.number,
        initialValue: answers[id]?.toString(),
        onChanged: (v) => setState(() => answers[id] = v),
        decoration: _dec(
          dataType == 'year' ? 'Contoh: 2023' : 'Masukkan angka',
        ),
        style: const TextStyle(fontSize: 14),
      );
    }

    // ---- DATE ----
    if (type == 'text' && dataType == 'date') {
      final hasValue = answers[id] != null && answers[id].toString().isNotEmpty;
      return InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDate: DateTime.now(),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.light(primary: _kPrimary),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            setState(
              () => answers[id] = picked.toIso8601String().split('T')[0],
            );
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasValue ? _kPrimary : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: hasValue ? _kPrimary : Colors.grey.shade400,
              ),
              const SizedBox(width: 10),
              Text(
                hasValue ? answers[id].toString() : 'Pilih tanggal',
                style: TextStyle(
                  fontSize: 14,
                  color: hasValue ? Colors.black87 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ---- SINGLE ----
    if (type == 'single') {
      final currentValue = answers[id];
      final groupValue = (currentValue is List)
          ? (currentValue.isNotEmpty ? currentValue.first.toString() : null)
          : currentValue?.toString();

      return Column(
        children: options.map<Widget>((o) {
          final label = o['label']?.toString() ?? '-';
          final isSelected = groupValue == label;
          return GestureDetector(
            onTap: () => setState(() {
              answers[id] = label;
              // Reset jawaban kondisional saat status berubah
              if (q['kode_soal'] == 'f8') _resetConditionalAnswers();
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? _kPrimary.withOpacity(0.06) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? _kPrimary : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? _kPrimary : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: isSelected ? _kPrimary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? _kPrimary : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    // ---- MULTIPLE ----
    if (type == 'multiple') {
      List selected = _parseMultipleValue(answers[id]);
      return Column(
        children: options.map<Widget>((o) {
          final label = o['label']?.toString() ?? '-';
          final isSelected = selected.contains(label);
          return GestureDetector(
            onTap: () => setState(() {
              if (isSelected) {
                selected.remove(label);
              } else {
                selected.add(label);
              }
              answers[id] = List.from(selected);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? _kPrimary.withOpacity(0.06) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? _kPrimary : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: isSelected ? _kPrimary : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: isSelected ? _kPrimary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 13, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? _kPrimary : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    // ---- SCALE ----
    if (type == 'scale') {
      final scaleLabels = [
        'Sangat\nRendah',
        'Rendah',
        'Sedang',
        'Tinggi',
        'Sangat\nTinggi',
      ];
      final scaleColors = [
        Colors.red.shade300,
        Colors.orange.shade300,
        Colors.amber.shade400,
        Colors.lightGreen.shade400,
        Colors.green.shade500,
      ];
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final val = (i + 1).toString();
              final isSelected = answers[id]?.toString() == val;
              return GestureDetector(
                onTap: () => setState(() => answers[id] = val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? scaleColors[i] : Colors.grey.shade100,
                    border: Border.all(
                      color: isSelected ? scaleColors[i] : Colors.grey.shade300,
                      width: isSelected ? 0 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: scaleColors[i].withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      val,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sangat Rendah',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.shade300,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Sangat Tinggi',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (answers[id] != null) ...[
            const SizedBox(height: 6),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scaleColors[int.parse(answers[id].toString()) - 1]
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  scaleLabels[int.parse(answers[id].toString()) - 1],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scaleColors[int.parse(answers[id].toString()) - 1],
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    }

    // ---- MATRIX ----
    if (type == 'matrix') {
      final details = q['details'] is List ? q['details'] as List : [];
      if (details.isEmpty) return const SizedBox();

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: _kPrimary.withOpacity(0.06),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(flex: 3, child: SizedBox()),
                  ...List.generate(
                    5,
                    (i) => Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _kPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
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
                            color: Colors.red.shade300,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Sangat\nTinggi',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.green.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...details.asMap().entries.map<Widget>((entry) {
              final i = entry.key;
              final detail = entry.value;
              final detailId = detail['id'].toString();
              final label = detail['label']?.toString() ?? '-';
              final mapKey = '${id}_$detailId';
              final isEven = i % 2 == 0;
              return Container(
                color: isEven ? Colors.white : Colors.grey.shade50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ...List.generate(5, (j) {
                      final val = (j + 1).toString();
                      final isSelected = answers[mapKey]?.toString() == val;
                      final dotColor = [
                        Colors.red.shade300,
                        Colors.orange.shade300,
                        Colors.amber.shade400,
                        Colors.lightGreen.shade400,
                        Colors.green.shade500,
                      ][j];
                      return Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => setState(() => answers[mapKey] = val),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? dotColor
                                    : Colors.grey.shade200,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: dotColor.withOpacity(0.4),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
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
        ),
      );
    }

    return const SizedBox();
  }

  // =============================================
  // SUBMIT — sinkron dengan MobileAnswerController
  // =============================================
  Future<void> submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final validIds = questions
          .map((q) => int.tryParse(q['id'].toString()) ?? 0)
          .where((id) => id > 0)
          .toSet();

      List payload = [];

      // ---- Non-matrix answers ----
      answers.forEach((k, v) {
        final keyStr = k.toString();
        if (keyStr.contains('_')) return; // skip matrix keys
        final qId = int.tryParse(keyStr) ?? 0;
        if (qId <= 0 || !validIds.contains(qId)) return;
        if (v == null || (v is String && v.isEmpty) || (v is List && v.isEmpty))
          return;
        payload.add({
          'question_id': qId,
          'value': v is List ? jsonEncode(v) : v.toString(),
        });
      });

      // ---- Matrix answers ----
      // Kumpulkan per question_id, kirim sebagai JSON {"label": "value"}
      // Backend (MobileAnswerController) membaca field 'item' sebagai label
      final Map<int, Map<String, String>> matrixByQuestion = {};

      answers.forEach((k, v) {
        final keyStr = k.toString();
        if (!keyStr.contains('_')) return;
        final parts = keyStr.split('_');
        if (parts.length < 2) return;
        final qId = int.tryParse(parts[0]) ?? 0;
        final detailId = int.tryParse(parts[1]) ?? 0;
        if (qId <= 0 || !validIds.contains(qId) || detailId <= 0) return;
        if (v == null || v.toString().isEmpty) return;

        // Cari label dari detail id
        final q = questions.firstWhere(
          (q) => int.tryParse(q['id'].toString()) == qId,
          orElse: () => {},
        );
        if (q.isEmpty) return;

        final details = q['details'] is List ? q['details'] as List : [];
        final detail = details.firstWhere(
          (d) => d['id'].toString() == detailId.toString(),
          orElse: () => {},
        );
        if (detail.isEmpty) return;

        final label = detail['label']?.toString() ?? '';
        if (label.isEmpty) return;

        matrixByQuestion.putIfAbsent(qId, () => {});
        matrixByQuestion[qId]![label] = v.toString();
      });

      // Kirim setiap matrix question sebagai 1 payload dengan value JSON
      matrixByQuestion.forEach((qId, itemMap) {
        if (itemMap.isEmpty) return;
        payload.add({
          'question_id': qId,
          'value': jsonEncode(
            itemMap,
          ), // {"Etika": "4", "Komunikasi": "3", ...}
        });
      });

      if (payload.isEmpty) {
        _showTopSnackBar(
          'Belum ada jawaban untuk dikirim',
          Colors.orange.shade700,
          icon: Icons.warning_amber_outlined,
        );
        return;
      }

      final res = await ApiService.submitAnswers(userId, payload);
      if (!mounted) return;

      if (res['status'] == true) {
        _showTopSnackBar(
          'Jawaban berhasil dikirim!',
          const Color(0xFF2E7D32),
          icon: Icons.check_circle_outline,
        );
      } else {
        _showTopSnackBar(
          res['message'] ?? 'Gagal mengirim jawaban',
          const Color(0xFFC62828),
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      debugPrint('ERROR SUBMIT: $e');
      if (mounted) {
        _showTopSnackBar(
          'Terjadi kesalahan, coba lagi',
          const Color(0xFFC62828),
          icon: Icons.error_outline,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // =============================================
  // BUILD UI
  // =============================================
  @override
  Widget build(BuildContext context) {
    final visibleQuestions = questions.where((q) => shouldShow(q)).toList();

    int answered = 0;
    for (final q in visibleQuestions) {
      if (_isAnswered(q)) answered++;
    }
    final progress = visibleQuestions.isEmpty
        ? 0.0
        : answered / visibleQuestions.length;

    SharedPreferences.getInstance().then(
      (p) => p.setDouble("progress_$userId", progress),
    );

    Color progressColor;
    if (progress < 0.4) {
      progressColor = Colors.red.shade400;
    } else if (progress < 0.75) {
      progressColor = Colors.orange.shade400;
    } else {
      progressColor = Colors.green.shade500;
    }

    return Scaffold(
      backgroundColor: _kBgPage,
      appBar: AppBar(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Column(
          children: [
            Text(
              'Tracer Study',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Survei Alumni',
              style: TextStyle(fontSize: 11, color: Colors.white60),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : Column(
              children: [
                // ---- PROGRESS HEADER ----
                Container(
                  color: _kPrimary,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}% selesai',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$answered / ${visibleQuestions.length} soal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---- LIST PERTANYAAN ----
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 110),
                    itemCount: visibleQuestions.length,
                    itemBuilder: (ctx, i) {
                      final q = visibleQuestions[i];
                      final hint = q['hint']?.toString() ?? '';
                      final isAns = _isAnswered(q);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(
                              color: isAns
                                  ? Colors.green.shade400
                                  : Colors.grey.shade300,
                              width: 4,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    margin: const EdgeInsets.only(
                                      right: 10,
                                      top: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAns
                                          ? Colors.green.shade400
                                          : _kPrimary.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isAns
                                              ? Colors.white
                                              : _kPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      q['question_text'] ?? '-',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isAns)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                ],
                              ),
                              if (hint.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
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
                              const SizedBox(height: 12),
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

      // ---- BOTTOM BAR ----
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Tombol Simpan
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: simpanSementara,
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text(
                            'Simpan',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              230,
                              3,
                              110,
                              242,
                            ),
                            foregroundColor: _kPrimary,
                            side: const BorderSide(
                              color: _kPrimary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tombol Kirim
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _isSubmitting ? null : submit,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color.fromARGB(255, 7, 3, 43),
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            _isSubmitting ? 'Mengirim...' : 'Kirim Jawaban',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              2,
                              255,
                              40,
                            ),
                            foregroundColor: const Color.fromARGB(
                              255,
                              7,
                              3,
                              43,
                            ),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 7, 3, 43),
                              width: 1.5,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Reset Draft
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: TextButton.icon(
                    onPressed: () async {
                      await clearDraft();
                      setState(() => answers = {});
                      if (!mounted) return;
                      _showTopSnackBar(
                        'Draft berhasil dihapus',
                        Colors.grey.shade700,
                        icon: Icons.delete_outline,
                      );
                    },
                    icon: const Icon(
                      Icons.refresh,
                      size: 14,
                      color: Color.fromARGB(255, 255, 9, 9),
                    ),
                    label: const Text(
                      'Reset Draft',
                      style: TextStyle(
                        color: Color.fromARGB(255, 254, 6, 6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
