import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

/// Service for exporting analytics and progress data as PDF
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Export progress report as PDF (Works seamlessly on Web, Android, iOS, Windows)
  Future<bool> exportProgressPDF({String? studentName}) async {
    if (_userId == null) return false;

    // Fetch user data
    final userDoc = await _firestore.collection('users').doc(_userId).get();
    final userData = userDoc.data() ?? {};
    final name = studentName ?? userData['name'] ?? 'Student';
    final xp = userData['xp'] ?? 0;
    final streak = userData['streak'] ?? 0;

    // Fetch quiz results
    final quizSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('exam_results')
        .orderBy('date', descending: true)
        .limit(20)
        .get();

    // Fetch achievements
    final achievementSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('achievements')
        .get();

    // Calculate statistics
    int totalQuizzes = quizSnapshot.docs.length;
    int totalCorrect = 0;
    int totalQuestions = 0;

    for (var doc in quizSnapshot.docs) {
      final data = doc.data();
      final num scoreVal = data['score'] is num ? data['score'] : 0;
      final num totalVal = data['total'] is num ? data['total'] : 0;
      totalCorrect += scoreVal.toInt();
      totalQuestions += totalVal.toInt();
    }

    double overallAccuracy = totalQuestions > 0
        ? (totalCorrect / totalQuestions) * 100
        : 0;

    // Build PDF Document
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'SisuPal Progress Report',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Text(
                  DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  style: const pw.TextStyle(color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Student: ${_cleanText(name)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.Text('Generated: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}'),
          pw.Divider(),
          pw.SizedBox(height: 14),

          // Overall Performance Stats
          pw.Header(level: 1, text: 'Overall Performance'),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildStatBox('Total XP', '$xp'),
              _buildStatBox('Streak', '$streak Days'),
              _buildStatBox('Quizzes', '$totalQuizzes'),
              _buildStatBox('Accuracy', '${overallAccuracy.toStringAsFixed(1)}%'),
            ],
          ),
          pw.SizedBox(height: 16),

          // Achievements
          pw.Header(level: 1, text: 'Achievements'),
          pw.Text('${achievementSnapshot.docs.length} badges earned across learning activities'),
          pw.SizedBox(height: 16),

          // Recent Quiz History Table
          pw.Header(level: 1, text: 'Recent Activity & Quiz Results'),
          if (quizSnapshot.docs.isEmpty)
            pw.Text('No quiz attempts recorded yet.')
          else
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
              ),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              headers: ['Date', 'Topic / Quiz', 'Score', 'Result'],
              data: quizSnapshot.docs.map((doc) {
                final data = doc.data();
                final date = (data['date'] as Timestamp?)?.toDate();
                final dateStr = date != null
                    ? DateFormat('MMM d, yyyy').format(date)
                    : '-';
                final title = _cleanText(data['examTitle'] ?? 'Mathematics Activity');
                final num score = data['score'] is num ? data['score'] : 0;
                final num total = data['total'] is num ? data['total'] : 0;
                final percentage = total > 0 ? (score / total) * 100 : 0;
                final result = percentage >= 70 ? 'Pass' : 'Needs Practice';

                return [dateStr, title, '$score/$total', result];
              }).toList(),
            ),

          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.Center(
            child: pw.Text(
              'SisuPal Learning Platform - Keep Up The Great Work!',
              style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
            ),
          ),
        ],
      ),
    );

    // Save & share or layout PDF cross-platform
    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'SisuPal_Progress_Report.pdf',
    );
    return true;
  }

  static String _cleanText(dynamic raw) {
    if (raw == null) return '';
    String text = raw.toString();
    // Remove emojis
    text = text.replaceAll(
      RegExp(r'[\u{1F300}-\u{1F9FF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}|\u{1F600}-\u{1F64F}|\u{1F680}-\u{1F6FF}]', unicode: true),
      '',
    );
    // Map Sinhala titles to clean English names for standard PDF fonts
    if (text.contains('පුනරීක්ෂණ') || text.contains('පුනරීක්ෂණය')) {
      text = 'Mathematics Revision Session';
    } else if (text.contains('ගණක රාමුව')) {
      text = 'Abacus Challenge';
    } else if (text.contains('දිය ගෙම්බාගේ')) {
      text = 'Lily Pad Leap (Patterns)';
    } else if (text.contains('ඉලක්කයට')) {
      text = 'Number Archery (Rounding)';
    } else if (text.contains('ඉලක්කම් සකස්')) {
      text = 'Digit Builder Challenge';
    } else if (text.contains('ස්ථානීය අගය')) {
      text = 'Place Value Explorer';
    } else if (text.contains('විහිදුවා')) {
      text = 'Expanded Form Builder';
    } else if (text.contains('ඉක්මන් සංඛ්‍යා')) {
      text = 'Rapid Number Challenge';
    } else if (text.contains(RegExp(r'[\u0D80-\u0DFF]'))) {
      text = 'Grade 5 Mathematics Activity';
    }
    return text.trim();
  }

  pw.Widget _buildStatBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
          ),
          pw.SizedBox(height: 2),
          pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ],
      ),
    );
  }
}
