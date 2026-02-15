import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for exporting analytics data as PDF or CSV
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Export quiz history as CSV
  Future<String?> exportQuizHistoryCSV() async {
    if (_userId == null) return null;

    // Fetch quiz results
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('exam_results')
        .orderBy('date', descending: true)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No quiz history to export');
    }

    // Build CSV content
    final buffer = StringBuffer();
    buffer.writeln('Date,Quiz Title,Score,Total,Percentage,Max Combo');

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp?)?.toDate();
      final dateStr = date != null 
          ? DateFormat('yyyy-MM-dd HH:mm').format(date)
          : 'Unknown';
      final title = data['examTitle'] ?? 'Unknown Quiz';
      final score = data['score'] ?? 0;
      final total = data['total'] ?? 0;
      final percentage = total > 0 ? ((score / total) * 100).toStringAsFixed(1) : '0';
      final combo = data['maxCombo'] ?? 0;

      buffer.writeln('$dateStr,"$title",$score,$total,$percentage%,$combo');
    }

    // Save and share the file
    final filePath = await _saveFile(buffer.toString(), 'quiz_history.csv');
    if (filePath != null) {
      await Share.shareXFiles([XFile(filePath)], text: 'Quiz History Export');
    }
    return filePath;
  }

  /// Export progress report as PDF
  Future<String?> exportProgressPDF({String? studentName}) async {
    if (_userId == null) return null;

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
        .limit(20) // Last 20 quizzes
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
      totalCorrect += (data['score'] as int?) ?? 0;
      totalQuestions += (data['total'] as int?) ?? 0;
    }
    
    double overallAccuracy = totalQuestions > 0 
        ? (totalCorrect / totalQuestions) * 100 
        : 0;

    // Build PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Text(
              'SisuPal Progress Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Student: $name'),
          pw.Text('Generated: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}'),
          pw.Divider(),
          pw.SizedBox(height: 20),

          // Overall Stats
          pw.Header(level: 1, text: 'Overall Performance'),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildStatBox('Total XP', '$xp'),
              _buildStatBox('Streak', '$streak days'),
              _buildStatBox('Quizzes', '$totalQuizzes'),
              _buildStatBox('Accuracy', '${overallAccuracy.toStringAsFixed(1)}%'),
            ],
          ),
          pw.SizedBox(height: 20),

          // Achievements
          pw.Header(level: 1, text: 'Achievements Unlocked'),
          pw.Text('${achievementSnapshot.docs.length} badges earned'),
          pw.SizedBox(height: 20),

          // Recent Quiz History
          pw.Header(level: 1, text: 'Recent Quiz Results'),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: ['Date', 'Quiz', 'Score', 'Result'],
            data: quizSnapshot.docs.map((doc) {
              final data = doc.data();
              final date = (data['date'] as Timestamp?)?.toDate();
              final dateStr = date != null 
                  ? DateFormat('MMM d').format(date)
                  : '-';
              final title = data['examTitle'] ?? '-';
              final score = data['score'] ?? 0;
              final total = data['total'] ?? 0;
              final percentage = total > 0 ? (score / total) * 100 : 0;
              final result = percentage >= 70 ? 'Pass' : 'Needs Work';
              
              return [dateStr, title, '$score/$total', result];
            }).toList(),
          ),
        ],
      ),
    );

    // Save and share PDF
    final bytes = await pdf.save();
    final filePath = await _savePdfFile(bytes, 'progress_report.pdf');
    if (filePath != null) {
      await Share.shareXFiles([XFile(filePath)], text: 'SisuPal Progress Report');
    }
    return filePath;
  }

  pw.Widget _buildStatBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Future<String?> _saveFile(String content, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
      return file.path;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  Future<String?> _savePdfFile(List<int> bytes, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      print('Error saving PDF: $e');
      return null;
    }
  }
}
