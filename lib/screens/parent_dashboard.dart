import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/parent/parent_analytics_model.dart';
import '../models/parent/parent_notification_model.dart';
import '../services/parent_analytics_service.dart';
import '../widgets/parent/parent_header.dart';
import '../widgets/parent/child_summary_hero_card.dart';
import '../widgets/parent/quick_stats_grid.dart';
import '../widgets/parent/maths_progress_card.dart';
import '../widgets/parent/focus_areas_card.dart';
import '../widgets/parent/learning_strengths_card.dart';
import '../widgets/parent/learning_trend_chart.dart';
import '../widgets/parent/learning_insight_card.dart';
import '../widgets/parent/parent_notifications_modal.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'report_preview_screen.dart';
import 'maths/golden_mango_lesson_screen.dart';
import 'maths/number_train_lesson_screen.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final ParentAnalyticsService _analyticsService = ParentAnalyticsService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ParentAnalyticsModel? _analytics;
  List<ParentNotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final analytics = await _analyticsService.fetchParentAnalytics();
      if (mounted) {
        setState(() {
          _analytics = analytics;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading Parent Dashboard analytics: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to load progress data. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _onPracticeNavigate(String lessonId, String conceptId) {
    int conceptIdx = 0;
    if (conceptId == 'c2_number_train_ordering') conceptIdx = 1;
    if (conceptId == 'c3_digit_card_train') conceptIdx = 2;
    if (conceptId == 'c4_thousands_mountain') conceptIdx = 3;

    if (lessonId == 'math_grade5_01') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GoldenMangoLessonScreen(
            studentGrade: _analytics?.grade ?? 5,
            conceptIndex: conceptIdx,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GreatNumberTrainLessonScreen(
            studentGrade: _analytics?.grade ?? 5,
            conceptIndex: conceptIdx,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Parent Dashboard 2.0 🛡️'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ParentNotificationModel>>(
        stream: _analyticsService.streamNotifications(),
        builder: (context, notifSnapshot) {
          _notifications = notifSnapshot.data ?? [];

          if (_isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing learner progress & telemetry...',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_errorMessage != null || _analytics == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage ?? 'An error occurred loading analytics.',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDashboardData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final analytics = _analytics!;

          return RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // SECTION 1: Parent Header
                  ParentHeaderWidget(
                    studentName: analytics.studentName,
                    notifications: _notifications,
                    onNotificationTap: () {
                      ParentNotificationsModal.show(
                        context,
                        notifications: _notifications,
                        onMarkRead: (id) => _analyticsService.markNotificationRead(id),
                      );
                    },
                    onSettingsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // SECTION 2: Hero Summary Card
                        ChildSummaryHeroCard(analytics: analytics),
                        const SizedBox(height: 20),

                        // SECTION 3: Quick Statistics Grid
                        QuickStatsGridWidget(analytics: analytics),
                        const SizedBox(height: 24),

                        // SECTION 4: Weekly Learning Insight
                        LearningInsightCardWidget(weeklyInsight: analytics.weeklyInsight),
                        const SizedBox(height: 24),

                        // SECTION 5: Mathematics Progress & Concept Pathways
                        MathsProgressCardWidget(analytics: analytics),
                        const SizedBox(height: 24),

                        // SECTION 6: Focus Areas (Needs Practice)
                        FocusAreasCardWidget(
                          focusAreas: analytics.focusAreas,
                          recommendation: analytics.recommendedNextStep,
                          onPracticeTap: _onPracticeNavigate,
                        ),
                        const SizedBox(height: 24),

                        // SECTION 7: Learning Strengths (Mastered Skills)
                        LearningStrengthsCardWidget(strengths: analytics.strengths),
                        const SizedBox(height: 24),

                        // SECTION 8: Learning Trend Timeline
                        LearningTrendChartWidget(trendData: analytics.trendData),
                        const SizedBox(height: 24),

                        // SECTION 9: PDF Report Export Card
                        _buildPdfReportCard(context, analytics),
                        const SizedBox(height: 24),

                        // SECTION 10: Recent Activity Feed
                        _buildRecentActivitySection(analytics),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// PDF Report Export Launcher Card
  Widget _buildPdfReportCard(BuildContext context, ParentAnalyticsModel analytics) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: const Color(0xFFF0F3F8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 32),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download Official PDF Report',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Generate formal Sri Lankan Grade 5 progress summary report for printing.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportPreviewScreen(
                      preSelectedUserId: analytics.studentUid,
                      preSelectedUserName: analytics.studentName,
                      analytics: analytics,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Export PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  /// Recent Activity Feed List
  Widget _buildRecentActivitySection(ParentAnalyticsModel analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              '🕒 RECENT ACTIVITY HISTORY',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Color(0xFF2D3436),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (analytics.recentActivities.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text(
                'No recent exam or quiz attempts recorded yet.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          )
        else
          ...analytics.recentActivities.map((act) {
            final percInt = (act.percentage * 100).toInt();
            Color statusColor = const Color(0xFF2ECC71);
            if (act.percentage < 0.50) {
              statusColor = const Color(0xFFE74C3C);
            } else if (act.percentage < 0.75) {
              statusColor = const Color(0xFFF39C12);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: act.percentage,
                      backgroundColor: Colors.grey.shade200,
                      color: statusColor,
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        Text(
                          '${act.lessonName} • Score: ${act.score} / ${act.total}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$percInt%',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}