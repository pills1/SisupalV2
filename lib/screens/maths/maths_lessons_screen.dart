import 'package:flutter/material.dart';
import '../../services/progress_service.dart';
import '../../services/sound_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_widgets.dart';
import 'golden_mango_lesson_screen.dart';
import 'number_train_lesson_screen.dart';

/// Concept status enum for visual pathway
enum ConceptStatus {
  completed, // 🟢 Green checkmark, completed
  current,   // 🔵 Bright, glowing, clickable "▶ Continue"
  locked,    // 🔒 Dimmed, lock icon, disabled
}

/// Lesson status enum for category cards
enum LessonStatus {
  completed, // 🏆 All concepts completed
  inProgress,// 🔵 Lesson active
  locked,    // 🔒 Complete previous lesson to unlock
}

class LessonConceptInfo {
  final String id;
  final String title;
  final String subtitle;
  final String icon;

  const LessonConceptInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class LessonCategoryInfo {
  final String id;
  final int lessonNumber;
  final String title;
  final String subtitle;
  final String icon;
  final Color themeColor;
  final List<LessonConceptInfo> concepts;

  const LessonCategoryInfo({
    required this.id,
    required this.lessonNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    required this.concepts,
  });
}

class MathsLessonsScreen extends StatefulWidget {
  final int studentGrade;

  const MathsLessonsScreen({
    super.key,
    required this.studentGrade,
  });

  @override
  State<MathsLessonsScreen> createState() => _MathsLessonsScreenState();
}

class _MathsLessonsScreenState extends State<MathsLessonsScreen> {
  final ProgressService _progressService = ProgressService();
  final SoundService _soundService = SoundService();

  static const List<LessonCategoryInfo> _lessons = [
    // LESSON 1
    LessonCategoryInfo(
      id: 'math_grade5_01',
      lessonNumber: 1,
      title: 'Quest for the Golden Mango 🥭',
      subtitle: 'රන් අඹ ගෙඩිය සොයා ගමන',
      icon: '🥭',
      themeColor: const Color(0xFFFF6B35),
      concepts: [
        LessonConceptInfo(
          id: 'c1_jungle_map',
          title: '1️⃣ අංක කැලෑ සිතියම',
          subtitle: 'ස්ථානීය අගය හැඳින්වීම (9,999 දක්වා)',
          icon: '🗺️',
        ),
        LessonConceptInfo(
          id: 'c2_river_of_beads',
          title: '2️⃣ පබළු ගඟ',
          subtitle: 'ඇබකස් සංකල්පය භාවිතය (ස්ථානීය අගය)',
          icon: '🌊',
        ),
        LessonConceptInfo(
          id: 'c3_giants_gate',
          title: '3️⃣ යෝධයාගේ දොරටුව',
          subtitle: '100,000 දක්වා සංඛ්‍යා සංසන්දනය',
          icon: '⛩️',
        ),
        LessonConceptInfo(
          id: 'c4_crystal_cavern',
          title: '4️⃣ මායා ගුහාවේ පීඨිකා',
          subtitle: 'විස්තරාත්මක සටහන (Expanded Form)',
          icon: '🗿',
        ),
        LessonConceptInfo(
          id: 'c5_golden_chest',
          title: '5️⃣ රන් අඹ අභිමුව',
          subtitle: 'රන් අඹ පූර්ණ පරීක්ෂණය (Mastery)',
          icon: '🏆',
        ),
      ],
    ),

    // LESSON 2
    LessonCategoryInfo(
      id: 'math_grade5_02',
      lessonNumber: 2,
      title: 'The Great Number Train 🚂',
      subtitle: 'සංඛ්‍යා - 2 | සංඛ්‍යා සසඳමු & පටිපාටිගත කරමු',
      icon: '🚂',
      themeColor: Color(0xFF8E44AD),
      concepts: [
        LessonConceptInfo(
          id: 'c1_number_train_intro',
          title: '1️⃣ පළමු නැවතුම – සංඛ්‍යා සසඳමු',
          subtitle: '2, 3, 4 සහ 5 ඉලක්කම් සංඛ්‍යා සසඳමු',
          icon: '🚉',
        ),
        LessonConceptInfo(
          id: 'c2_number_train_ordering',
          title: '2️⃣ දෙවන නැවතුම – සංඛ්‍යා පටිපාටිගත කරමු',
          subtitle: 'ආරෝහණ සහ අවරෝහණ පිළිවෙළ',
          icon: '🚋',
        ),
        LessonConceptInfo(
          id: 'c3_digit_card_train',
          title: '3️⃣ තෙවන නැවතුම – ඉලක්කම් පත්‍ර දුම්රිය',
          subtitle: 'ඉලක්කම් පත්වලින් සංඛ්‍යා හදමු',
          icon: '🃏',
        ),
        LessonConceptInfo(
          id: 'c4_thousands_mountain',
          title: '4️⃣ හතරවන නැවතුම – දහස් කඳුකරය',
          subtitle: '4 සහ 5 ඉලක්කම් සංඛ්‍යා සසඳමු',
          icon: '⛰️',
        ),
        LessonConceptInfo(
          id: 'c5_challenge_train',
          title: '5️⃣ පස්වන නැවතුම – අභියෝග දුම්රිය',
          subtitle: 'සංඛ්‍යා අභියෝග ජයගමු',
          icon: '🌩️',
        ),
        LessonConceptInfo(
          id: 'c6_great_number_train_mastery',
          title: '6️⃣ හයවන නැවතුම – මහා සංඛ්‍යා දුම්රියේ අවසන් ගමන',
          subtitle: 'මහා ගණිත ශූරතාවය',
          icon: '👑',
        ),
      ],
    ),

    // LESSON 3
    LessonCategoryInfo(
      id: 'math_grade5_03_placeholder',
      lessonNumber: 3,
      title: 'Addition & Subtraction 🏰',
      subtitle: 'එකතු කිරීම & අඩුකිරීම',
      icon: '➕',
      themeColor: Color(0xFF27AE60),
      concepts: [
        LessonConceptInfo(
          id: 'c1_addition_intro',
          title: '1️⃣ ස්ථානීය අගයන් අනුව එකතු කිරීම',
          subtitle: 'ඉලක්කම් 5 දක්වා එකතු කරමු',
          icon: '➕',
        ),
        LessonConceptInfo(
          id: 'c2_subtraction_intro',
          title: '2️⃣ සංඛ්‍යා අඩුකිරීමේ අභියෝගය',
          subtitle: 'අඩුකිරීමේ ස්ථානීය නීති',
          icon: '➖',
        ),
        LessonConceptInfo(
          id: 'c3_addition_subtraction_mastery',
          title: '3️⃣ මහා ගණිත ගැටලු විසඳීම',
          subtitle: 'මිශ්‍ර අභියෝග විසඳීම',
          icon: '🎯',
        ),
      ],
    ),
  ];

  void _onConceptTap({
    required String lessonId,
    required int conceptIndex,
    required ConceptStatus status,
  }) {
    if (status == ConceptStatus.locked) {
      _soundService.playWrong();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ඊළඟ නැවතුමට යාමට පෙර කලින් නැවතුම සාර්ථකව අවසන් කරන්න! 🔒',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFD63031),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    _soundService.playClick();

    if (lessonId == 'math_grade5_01') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GoldenMangoLessonScreen(
            studentGrade: widget.studentGrade,
            conceptIndex: conceptIndex,
          ),
        ),
      ).then((_) => setState(() {}));
    } else if (lessonId == 'math_grade5_02') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GreatNumberTrainLessonScreen(
            studentGrade: widget.studentGrade,
            conceptIndex: conceptIndex,
          ),
        ),
      ).then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: StreamBuilder<SubjectProgress>(
          stream: _progressService.streamProgress('Mathematics'),
          builder: (context, snapshot) {
            final progress = snapshot.data ?? SubjectProgress(subject: 'Mathematics');
            final completedLessons = progress.completedLessons;
            final completedConcepts = progress.completedConcepts;

            return Column(
              children: [
                _buildHeader(context, completedLessons.length),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = _lessons[index];
                      return _buildLessonCategoryCard(
                        context,
                        lesson: lesson,
                        completedLessons: completedLessons,
                        completedConcepts: completedConcepts,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int completedCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border(
          bottom: BorderSide(
            color: AppColors.mathOrange.withOpacity(0.3),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          BouncingButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Mathematics Lessons',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text('🏰', style: TextStyle(fontSize: 18)),
                  ],
                ),
                Text(
                  'Grade ${widget.studentGrade} • ගණිත පාඩම් මාලාව',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📚 ', style: TextStyle(fontSize: 14)),
                Text(
                  '$completedCount / 3 Completed',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCategoryCard(
    BuildContext context, {
    required LessonCategoryInfo lesson,
    required List<String> completedLessons,
    required List<String> completedConcepts,
  }) {
    // Determine overall lesson status
    final isLesson1 = lesson.id == 'math_grade5_01';
    final isLesson2 = lesson.id == 'math_grade5_02';

    bool isLessonCompleted = completedLessons.contains(lesson.id);

    bool isLessonUnlocked = false;
    if (isLesson1) {
      // Lesson 1 is always unlocked for Grade 5 students
      isLessonUnlocked = true;
    } else if (isLesson2) {
      // Lesson 2 unlocks when Lesson 1 is completed
      isLessonUnlocked = completedLessons.contains('math_grade5_01');
    } else {
      // Subsequent lessons unlock when preceding lesson is completed
      isLessonUnlocked = completedLessons.contains('math_grade5_02');
    }

    LessonStatus lessonStatus = LessonStatus.inProgress;
    if (isLessonCompleted) {
      lessonStatus = LessonStatus.completed;
    } else if (!isLessonUnlocked) {
      lessonStatus = LessonStatus.locked;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLessonCompleted
              ? const Color(0xFFFFD700).withOpacity(0.6)
              : (isLessonUnlocked
                  ? lesson.themeColor.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1)),
          width: isLessonCompleted ? 2.5 : 1.5,
        ),
        boxShadow: isLessonCompleted
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : [AppShadows.cardShadow.first],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isLessonCompleted
                    ? [const Color(0xFF2C3E50), const Color(0xFF1A252F)]
                    : [
                        lesson.themeColor.withOpacity(0.3),
                        const Color(0xFF16213E)
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLessonUnlocked
                        ? lesson.themeColor.withOpacity(0.2)
                        : Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLessonUnlocked ? lesson.themeColor : Colors.white24,
                    ),
                  ),
                  child: Text(
                    isLessonUnlocked ? lesson.icon : '🔒',
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LESSON ${lesson.lessonNumber}',
                        style: TextStyle(
                          color: lesson.themeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lesson.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lesson.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lesson Status Badge
                _buildLessonBadge(lessonStatus),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white10),

          // Concept Pathway Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'CONCEPTS PATHWAY',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'All Concepts Visible',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // List of Concepts with Visual Differentiation
                ...List.generate(lesson.concepts.length, (conceptIdx) {
                  final concept = lesson.concepts[conceptIdx];
                  final status = _resolveConceptStatus(
                    lessonId: lesson.id,
                    conceptIdx: conceptIdx,
                    conceptId: concept.id,
                    completedLessons: completedLessons,
                    completedConcepts: completedConcepts,
                  );

                  final isLast = conceptIdx == lesson.concepts.length - 1;

                  return _buildConceptPathwayTile(
                    context,
                    concept: concept,
                    conceptIndex: conceptIdx,
                    status: status,
                    lessonId: lesson.id,
                    isLast: isLast,
                    themeColor: lesson.themeColor,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonBadge(LessonStatus status) {
    switch (status) {
      case LessonStatus.completed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 8,
              )
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🏆 ', style: TextStyle(fontSize: 14)),
              Text(
                'Completed',
                style: TextStyle(
                  color: Color(0xFFE65100),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      case LessonStatus.inProgress:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA29BFE), width: 1.5),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('⚡ ', style: TextStyle(fontSize: 14)),
              Text(
                'In Progress',
                style: TextStyle(
                  color: Color(0xFFA29BFE),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case LessonStatus.locked:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🔒 ', style: TextStyle(fontSize: 14)),
              Text(
                'Locked',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
    }
  }

  bool _isConceptCompleted(String lessonId, int conceptIdx, String conceptId, List<String> completedConcepts) {
    if (completedConcepts.contains(conceptId)) return true;
    if (lessonId == 'math_grade5_01') {
      if (conceptIdx == 0 &&
          (completedConcepts.contains('c1_jungle_map') ||
              completedConcepts.contains('c1_map_reading') ||
              completedConcepts.contains('c1'))) {
        return true;
      }
      if (conceptIdx == 1 &&
          (completedConcepts.contains('c2_river_of_beads') ||
              completedConcepts.contains('c2_abacus_river') ||
              completedConcepts.contains('c2'))) {
        return true;
      }
      if (conceptIdx == 2 &&
          (completedConcepts.contains('c3_giants_gate') ||
              completedConcepts.contains('c3_place_value_gate') ||
              completedConcepts.contains('c3'))) {
        return true;
      }
      if (conceptIdx == 3 &&
          (completedConcepts.contains('c4_crystal_cavern') ||
              completedConcepts.contains('c4_cave_pedestals') ||
              completedConcepts.contains('c4'))) {
        return true;
      }
      if (conceptIdx == 4 &&
          (completedConcepts.contains('c5_golden_chest') ||
              completedConcepts.contains('c5_golden_mango_chest') ||
              completedConcepts.contains('c5'))) {
        return true;
      }
    }
    if (lessonId == 'math_grade5_02') {
      if (completedConcepts.contains('c${conceptIdx + 1}') ||
          completedConcepts.contains('l2_c${conceptIdx + 1}')) {
        return true;
      }
    }
    return false;
  }

  ConceptStatus _resolveConceptStatus({
    required String lessonId,
    required int conceptIdx,
    required String conceptId,
    required List<String> completedLessons,
    required List<String> completedConcepts,
  }) {
    // If the full lesson is marked completed OR this individual concept is completed
    if (completedLessons.contains(lessonId) || _isConceptCompleted(lessonId, conceptIdx, conceptId, completedConcepts)) {
      return ConceptStatus.completed;
    }

    // Lesson 1: Golden Mango (Unlocked from beginning)
    if (lessonId == 'math_grade5_01') {
      if (conceptIdx == 0) {
        // Concept 1 is the starting point for fresh users
        return ConceptStatus.current;
      } else {
        // Unlocked if previous concept in Lesson 1 has been completed
        final prevConceptId = _lessons[0].concepts[conceptIdx - 1].id;
        if (_isConceptCompleted(lessonId, conceptIdx - 1, prevConceptId, completedConcepts)) {
          return ConceptStatus.current;
        }
        return ConceptStatus.locked;
      }
    }

    // Lesson 2: The Great Number Train
    if (lessonId == 'math_grade5_02') {
      final isLesson1Completed = completedLessons.contains('math_grade5_01') ||
          [0, 1, 2, 3, 4].every((idx) => _isConceptCompleted(
              'math_grade5_01', idx, _lessons[0].concepts[idx].id, completedConcepts));
      if (!isLesson1Completed) {
        return ConceptStatus.locked;
      }
      if (conceptIdx == 0) {
        return ConceptStatus.current;
      } else {
        final prevConceptId = _lessons[1].concepts[conceptIdx - 1].id;
        if (_isConceptCompleted(lessonId, conceptIdx - 1, prevConceptId, completedConcepts)) {
          return ConceptStatus.current;
        }
        return ConceptStatus.locked;
      }
    }

    // Other lessons locked
    return ConceptStatus.locked;
  }

  Widget _buildConceptPathwayTile(
    BuildContext context, {
    required LessonConceptInfo concept,
    required int conceptIndex,
    required ConceptStatus status,
    required String lessonId,
    required bool isLast,
    required Color themeColor,
  }) {
    Color cardBg;
    Color borderColor;
    Widget statusBadge;

    switch (status) {
      case ConceptStatus.completed:
        cardBg = const Color(0xFF1B2A2F);
        borderColor = const Color(0xFF27AE60);
        statusBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF27AE60).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF27AE60)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF27AE60), size: 14),
              SizedBox(width: 4),
              Text(
                'Completed',
                style: TextStyle(
                  color: Color(0xFF27AE60),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
        break;

      case ConceptStatus.current:
        cardBg = const Color(0xFF2A1B3D);
        borderColor = const Color(0xFFFF6B35);
        statusBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.4),
                blurRadius: 8,
              )
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('▶ ', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
        break;

      case ConceptStatus.locked:
        cardBg = Colors.black.withOpacity(0.2);
        borderColor = Colors.white.withOpacity(0.08);
        statusBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, color: Colors.white38, size: 13),
              SizedBox(width: 4),
              Text(
                'Locked',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
        break;
    }

    return Column(
      children: [
        BouncingButton(
          onPressed: () => _onConceptTap(
            lessonId: lessonId,
            conceptIndex: conceptIndex,
            status: status,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: status == ConceptStatus.current ? borderColor : borderColor.withOpacity(0.6),
                width: status == ConceptStatus.current ? 2.0 : 1.0,
              ),
              boxShadow: status == ConceptStatus.current
                  ? [
                      BoxShadow(
                        color: borderColor.withOpacity(0.3),
                        blurRadius: 10,
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Concept Icon
                Text(
                  status == ConceptStatus.locked ? '🔒' : concept.icon,
                  style: TextStyle(
                    fontSize: 22,
                    color: status == ConceptStatus.locked ? Colors.white38 : Colors.white,
                  ),
                ),
                const SizedBox(width: 12),

                // Concept Text Titles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        concept.title,
                        style: TextStyle(
                          color: status == ConceptStatus.locked
                              ? Colors.white38
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        concept.subtitle,
                        style: TextStyle(
                          color: status == ConceptStatus.locked
                              ? Colors.white24
                              : Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Status Badge
                statusBadge,
              ],
            ),
          ),
        ),
        if (!isLast)
          Container(
            height: 12,
            width: 2,
            color: status == ConceptStatus.completed
                ? const Color(0xFF27AE60)
                : Colors.white12,
          ),
      ],
    );
  }
}
