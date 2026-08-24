import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_widgets.dart';
import 'maths/maths_revision_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          "ප්‍රගති සහ විභාග ඉතිහාසය 📜",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('exam_results')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = snapshot.data?.docs ?? [];

          if (results.isEmpty) {
            return _buildEmptyState(context);
          }

          // Calculate summary stats
          int totalSessions = results.length;
          int totalScore = 0;
          int totalPossible = 0;
          int totalXp = 0;

          for (var doc in results) {
            final data = doc.data() as Map<String, dynamic>;
            final s = (data['score'] as num?)?.toInt() ?? 0;
            final t = (data['total'] as num?)?.toInt() ?? 1;
            final xp = (data['xpEarned'] as num?)?.toInt() ?? 0;
            totalScore += s;
            totalPossible += t;
            totalXp += xp;
          }

          final int avgAccuracy = totalPossible > 0
              ? ((totalScore / totalPossible) * 100).round()
              : 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Stats Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "සමස්ත ඉගෙනුම් වාර්තාව",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSummaryStat("සැසි ගණන", "$totalSessions", Icons.history_rounded),
                        Container(width: 1, height: 32, color: Colors.white24),
                        _buildSummaryStat("සාමාන්‍යය", "$avgAccuracy%", Icons.verified_rounded),
                        Container(width: 1, height: 32, color: Colors.white24),
                        _buildSummaryStat("ලැබූ XP", "+$totalXp", Icons.star_rounded),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "මෑතකදී කළ අභ්‍යාස සහ විභාග 📋",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 12),

              // List of records
              ...List.generate(results.length, (index) {
                final data = results[index].data() as Map<String, dynamic>;
                final int score = (data['score'] as num?)?.toInt() ?? 0;
                final int total = (data['total'] as num?)?.toInt() ?? 1;
                final double percentage = (score / total) * 100;
                final String title = data['examTitle'] ?? "පුනරීක්ෂණ සැසිය";
                final String type = data['type'] ?? "exam";
                final isRevision = type == 'revision' || title.contains('පුනරීක්ෂණ');

                DateTime dateTime = DateTime.now();
                if (data['date'] != null && data['date'] is Timestamp) {
                  dateTime = (data['date'] as Timestamp).toDate();
                }
                final formattedDate = DateFormat('yyyy-MM-dd • hh:mm a').format(dateTime);

                return SlideInWidget(
                  delay: Duration(milliseconds: 50 * index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isRevision
                            ? const Color(0xFF6C5CE7).withValues(alpha: 0.15)
                            : Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Progress ring / badge
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: percentage >= 80
                                ? const Color(0xFFECFDF5)
                                : (percentage >= 50
                                    ? const Color(0xFFFFFBEB)
                                    : const Color(0xFFFEF2F2)),
                          ),
                          child: Center(
                            child: Text(
                              "${percentage.toInt()}%",
                              style: TextStyle(
                                color: percentage >= 80
                                    ? const Color(0xFF059669)
                                    : (percentage >= 50
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFFDC2626)),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Title & Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isRevision
                                          ? const Color(0xFF6C5CE7).withValues(alpha: 0.1)
                                          : const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isRevision ? "🔄 පුනරීක්ෂණය" : "📝 විභාගය",
                                      style: TextStyle(
                                        color: isRevision
                                            ? const Color(0xFF6C5CE7)
                                            : const Color(0xFF3B82F6),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Score Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "$score / $total",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const Text(
                                "ලකුණු",
                                style: TextStyle(fontSize: 9, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.history_edu_rounded, size: 48, color: Color(0xFF6C5CE7)),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "තවමත් වාර්තා කිසිවක් නැත",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "ගණිත රාජධානියේ පුනරීක්ෂණ අභ්‍යාස සම්පූර්ණ කළ විට ඔබේ සියලු ප්‍රගති වාර්තා මෙහි දිස්වනු ඇත!",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            BouncingButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MathsRevisionScreen(studentGrade: 5),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "පුනරීක්ෂණ කලාපයට යන්න 🔄",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}