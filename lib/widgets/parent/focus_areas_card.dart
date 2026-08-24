import 'package:flutter/material.dart';
import '../../models/parent/parent_analytics_model.dart';

class FocusAreasCardWidget extends StatelessWidget {
  final List<SkillMetric> focusAreas;
  final RecommendationModel? recommendation;
  final Function(String lessonId, String conceptId) onPracticeTap;

  const FocusAreasCardWidget({
    super.key,
    required this.focusAreas,
    this.recommendation,
    required this.onPracticeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              '🎯 FOCUS AREAS & RECOMMENDATIONS',
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

        if (focusAreas.isEmpty)
          _buildEmptyFocusCard()
        else
          ...focusAreas.map((skill) => _buildFocusItemCard(context, skill)),
      ],
    );
  }

  Widget _buildEmptyFocusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.5), width: 1.5),
      ),
      child: const Row(
        children: [
          Icon(Icons.stars_rounded, color: Color(0xFF2ECC71), size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Great Job! No Critical Weaknesses',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E8449),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your learner is performing strongly across all completed math activities. Keep encouraging consistent practice!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF27AE60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusItemCard(BuildContext context, SkillMetric skill) {
    final accuracyInt = (skill.accuracyPercent * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFE74C3C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.titleSinhala,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    Text(
                      skill.titleEnglish,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE74C3C)),
                ),
                child: Text(
                  'Accuracy: $accuracyInt%',
                  style: const TextStyle(
                    color: Color(0xFFE74C3C),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'ඔබේ දරුවාට ${skill.titleSinhala} අභ්‍යාස සඳහා නැවත උත්සාහ කිරීමට උපකාර අවශ්‍ය වේ.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 12),

          // Suggested concept recommendation box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Text('📌 ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    'Suggested Practice: ${skill.suggestedPracticeConceptTitle}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => onPracticeTap(skill.suggestedLessonId, skill.suggestedConceptId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'View Concept',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
