import 'package:flutter/material.dart';
import '../../models/parent/parent_analytics_model.dart';
import '../../widgets/animated_widgets.dart';

class MathsProgressCardWidget extends StatefulWidget {
  final ParentAnalyticsModel analytics;

  const MathsProgressCardWidget({
    super.key,
    required this.analytics,
  });

  @override
  State<MathsProgressCardWidget> createState() => _MathsProgressCardWidgetState();
}

class _MathsProgressCardWidgetState extends State<MathsProgressCardWidget> {
  final Map<String, bool> _expandedLessons = {
    'math_grade5_01': false,
    'math_grade5_02': true, // Expand Lesson 2 by default
  };

  @override
  Widget build(BuildContext context) {
    final lessons = widget.analytics.lessonProgressList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              '📚 MATHEMATICS PROGRESS',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Color(0xFF2D3436),
              ),
            ),
            Spacer(),
            Text(
              '2 Lessons',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...lessons.map((lesson) => _buildLessonCard(context, lesson)),
      ],
    );
  }

  Widget _buildLessonCard(BuildContext context, LessonAnalyticsModel lesson) {
    final isExpanded = _expandedLessons[lesson.lessonId] ?? false;
    final percentInt = (lesson.completionPercent * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: lesson.isCompleted
              ? const Color(0xFF2ECC71).withOpacity(0.5)
              : lesson.themeColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Tile
          BouncingButton(
            onPressed: () {
              setState(() {
                _expandedLessons[lesson.lessonId] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: lesson.themeColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: lesson.themeColor.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        lesson.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${lesson.completedConceptsCount} / ${lesson.totalConceptsCount} concepts completed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Progress Bar
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: lesson.completionPercent,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    lesson.isCompleted
                                        ? const Color(0xFF2ECC71)
                                        : lesson.themeColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$percentInt%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: lesson.isCompleted
                                    ? const Color(0xFF2ECC71)
                                    : lesson.themeColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Expand Icon
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Expandable Concept Pathway List
          if (isExpanded) ...[
            const Divider(height: 1, color: Colors.black12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.grey.shade50,
              child: Column(
                children: lesson.concepts.map((concept) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                concept.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: concept.isLocked ? FontWeight.normal : FontWeight.bold,
                                  color: concept.isLocked ? Colors.grey : const Color(0xFF2D3436),
                                ),
                              ),
                              Text(
                                concept.subtitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: concept.isLocked ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildConceptBadge(concept),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConceptBadge(ConceptAnalyticsModel concept) {
    if (concept.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F8F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2ECC71)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF2ECC71), size: 12),
            SizedBox(width: 4),
            Text(
              'Completed',
              style: TextStyle(
                color: Color(0xFF2ECC71),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (concept.isCurrent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF6C5CE7).withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF6C5CE7)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('▶ ', style: TextStyle(color: Color(0xFF6C5CE7), fontSize: 10)),
            Text(
              'In Progress',
              style: TextStyle(
                color: Color(0xFF6C5CE7),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, color: Colors.grey, size: 11),
            SizedBox(width: 4),
            Text(
              'Locked',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }
}
