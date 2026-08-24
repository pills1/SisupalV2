import 'package:flutter/material.dart';
import '../../models/parent/parent_analytics_model.dart';
import '../../utils/app_theme.dart';

class QuickStatsGridWidget extends StatelessWidget {
  final ParentAnalyticsModel analytics;

  const QuickStatsGridWidget({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(
          emoji: '⭐',
          value: '${analytics.xp}',
          label: 'Total XP',
          gradient: AppColors.primaryGradient,
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          emoji: '🔥',
          value: '${analytics.streak}',
          label: 'Day Streak',
          gradient: AppColors.sunsetGradient,
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          emoji: '🏆',
          value: '${analytics.totalBadgesCount}',
          label: 'Badges Earned',
          gradient: AppColors.successGradient,
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          emoji: '📚',
          value: '${analytics.completedLessonsCount}',
          label: 'Lessons Done',
          gradient: const LinearGradient(
            colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String emoji,
    required String value,
    required String label,
    required Gradient gradient,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
