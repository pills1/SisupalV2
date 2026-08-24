import 'package:flutter/material.dart';
import '../../models/maths/revision_models.dart';
import '../../data/maths/revision/maths_revision_data.dart';
import '../../services/maths/revision_engine.dart';
import '../../services/sound_service.dart';
import '../../widgets/animated_widgets.dart';
import 'maths_revision_session_screen.dart';

class MathsRevisionScreen extends StatefulWidget {
  final int studentGrade;

  const MathsRevisionScreen({
    super.key,
    required this.studentGrade,
  });

  @override
  State<MathsRevisionScreen> createState() => _MathsRevisionScreenState();
}

class _MathsRevisionScreenState extends State<MathsRevisionScreen> {
  final RevisionEngine _revisionEngine = RevisionEngine();
  final SoundService _soundService = SoundService();

  List<RevisionSkillModel> _skills = [];
  bool _isLoading = true;

  // Question bank lesson filter (all, lesson1, lesson2)
  String _selectedLessonFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadRevisionData();
  }

  Future<void> _loadRevisionData() async {
    setState(() => _isLoading = true);
    try {
      final skills = await _revisionEngine.fetchPersonalizedRevisionSkills();
      if (mounted) {
        setState(() {
          _skills = skills;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading revision skills: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startSkillSession(RevisionSkillModel skill) {
    _soundService.playClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MathsRevisionSessionScreen(
          skill: skill,
          studentGrade: widget.studentGrade,
        ),
      ),
    ).then((_) => _loadRevisionData());
  }

  void _startConceptSession({
    required String conceptId,
    required String conceptTitle,
  }) {
    _soundService.playClick();
    final challenges = MathsRevisionData.getQuestionsByConcept(conceptId);
    if (challenges.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MathsRevisionSessionScreen(
          customChallenges: challenges,
          customTitle: conceptTitle,
          studentGrade: widget.studentGrade,
        ),
      ),
    ).then((_) => _loadRevisionData());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF131326),
        body: SafeArea(
          child: Column(
            children: [
              // Top App Bar
              _buildHeader(context),

              // Tab Bar Switcher
              _buildTabBar(),

              // Tab View
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                        ),
                      )
                    : TabBarView(
                        children: [
                          // Tab 1: Personalized Adaptive Workout
                          _buildPersonalizedTab(),

                          // Tab 2: 40 Official Question Bank Library
                          _buildQuestionBankTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER & TABS ─────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E38),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF6C5CE7).withOpacity(0.3),
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
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'පුනරීක්ෂණ කඳවුර',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text('🔄', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Text(
                  'Revision Zone • 5 ශ්‍රේණිය ගණිතය',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9F43), Color(0xFFFF5252)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔥', style: TextStyle(fontSize: 13)),
                SizedBox(width: 4),
                Text(
                  '40 Qs',
                  style: TextStyle(
                    color: Colors.white,
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

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF1E1E38),
      child: TabBar(
        indicatorColor: const Color(0xFFFFD700),
        indicatorWeight: 3,
        labelColor: const Color(0xFFFFD700),
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        tabs: const [
          Tab(
            icon: Icon(Icons.auto_awesome_rounded, size: 18),
            text: 'මගේ දුර්වලතා (Adaptive)',
          ),
          Tab(
            icon: Icon(Icons.menu_book_rounded, size: 18),
            text: 'ප්‍රශ්න බැංකුව (40 Qs)',
          ),
        ],
      ),
    );
  }

  // ─── TAB 1: PERSONALIZED ADAPTIVE WORKOUT ─────────────────────────────────

  Widget _buildPersonalizedTab() {
    final highPrioritySkills =
        _skills.where((s) => s.priority == RevisionPriority.high).toList();
    final mediumPrioritySkills =
        _skills.where((s) => s.priority == RevisionPriority.medium).toList();
    final masteredSkills =
        _skills.where((s) => s.priority == RevisionPriority.mastered).toList();

    final bool allMastered =
        highPrioritySkills.isEmpty && mediumPrioritySkills.isEmpty;

    return RefreshIndicator(
      onRefresh: _loadRevisionData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(),
            const SizedBox(height: 20),

            if (allMastered) ...[
              _buildMasteryCelebrationCard(),
              const SizedBox(height: 20),
            ],

            if (highPrioritySkills.isNotEmpty) ...[
              const Row(
                children: [
                  Text(
                    '🔥 NEEDS PRACTICE | තව පුහුණුව අවශ්‍යයි',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildPrimarySkillCard(highPrioritySkills.first),
              const SizedBox(height: 20),
            ],

            if (mediumPrioritySkills.isNotEmpty) ...[
              const Row(
                children: [
                  Text(
                    '⭐ KEEP PRACTISING | පුහුණුව පවත්වාගනිමු',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...mediumPrioritySkills.take(3).map((s) => _buildSecondarySkillCard(s)),
              const SizedBox(height: 20),
            ],

            if (masteredSkills.isNotEmpty) ...[
              const Row(
                children: [
                  Text(
                    '🏆 MASTERED SKILLS | හොඳින් ප්‍රගුණ කළ කොටස්',
                    style: TextStyle(
                      color: Color(0xFF2ECC71),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...masteredSkills.map((s) => _buildMasteredTile(s)),
              const SizedBox(height: 20),
            ],

            _buildRevisionProgressSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0984E3), Color(0xFF6C5CE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0984E3).withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          Text('🏕️', style: TextStyle(fontSize: 38)),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ස්ථානීය අගය හා සංඛ්‍යා පුහුණුව',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'නැවත පුහුණු වෙමින් ඔබේ ගණිත කුසලතා වැඩි දියුණු කරගන්න! 🚀',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryCelebrationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E8449), Color(0xFF2ECC71)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.3),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          const Text(
            'ඔබ විශිෂ්ටයි!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'සියලුම ගණිත කොටස් මැනවින් ප්‍රගුණ කර ඇත! ප්‍රශ්න බැංකුවෙන් අලුත් අභියෝග උත්සාහ කරන්න. 🏆',
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimarySkillCard(RevisionSkillModel skill) {
    final accuracyInt = (skill.accuracyPercent * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B3D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF6B35), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎯', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.titleSinhala,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'නිරවද්‍යතාව: $accuracyInt% (${skill.correctAttempts}/${skill.totalAttempts})',
                      style: const TextStyle(
                        color: Color(0xFFFF6B35),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            skill.encouragementMsg,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startSkillSession(skill),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                '⚡ දැන්ම පුහුණු වෙමු (+50 XP)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondarySkillCard(RevisionSkillModel skill) {
    final accuracyInt = (skill.accuracyPercent * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.titleSinhala,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$accuracyInt% Mastery',
                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _startSkillSession(skill),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: const Color(0xFF2C2C54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text(
              'පුහුණුව ➔',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteredTile(RevisionSkillModel skill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              skill.titleSinhala,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const Text(
            'ප්‍රගුණ කර ඇත ✔️',
            style: TextStyle(
              color: Color(0xFF2ECC71),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevisionProgressSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('⚡', style: TextStyle(fontSize: 24)),
              SizedBox(height: 4),
              Text(
                '40 Qs Bank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'සම්පූර්ණ ප්‍රශ්න',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
          Column(
            children: [
              Text('🎯', style: TextStyle(fontSize: 24)),
              SizedBox(height: 4),
              Text(
                '10 Concepts',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ගණිත සංකල්ප',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
          Column(
            children: [
              Text('🏆', style: TextStyle(fontSize: 24)),
              SizedBox(height: 4),
              Text(
                'Grade 5',
                style: TextStyle(
                  color: Color(0xFF2ECC71),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ශිෂ්‍යත්ව මට්ටම',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── TAB 2: 40 OFFICIAL QUESTION BANK LIBRARY ─────────────────────────────

  Widget _buildQuestionBankTab() {
    final conceptDefinitions = [
      // LESSON 1 CONCEPTS
      {
        'lessonId': 'math_grade5_01',
        'lessonTitle': 'පාඩම 1: රන් අඹ ගවේෂණය (Golden Mango)',
        'lessonBadge': '🥭 Lesson 1',
        'lessonBadgeColor': const Color(0xFFFFA502),
        'conceptId': 'c1_jungle_map',
        'title': '1️⃣ 9,999 දක්වා ස්ථානීය අගය හඳුනාගැනීම',
        'subtitle': 'Place value of digits in 4-digit numbers',
        'formats': ['🎯 ස්ථානීය අගය', '📝 වචන අගය'],
        'color': const Color(0xFF2ED573),
      },
      {
        'lessonId': 'math_grade5_01',
        'lessonTitle': 'පාඩම 1: රන් අඹ ගවේෂණය (Golden Mango)',
        'lessonBadge': '🥭 Lesson 1',
        'lessonBadgeColor': const Color(0xFFFFA502),
        'conceptId': 'c2_bead_river',
        'title': '2️⃣ ඇබකසය හා ස්ථානීය අගය නිරූපණය',
        'subtitle': 'Abacus bead counting & column values',
        'formats': ['🔢 ඇබකස පබළු', '✨ කණු අගයන්'],
        'color': const Color(0xFF1E90FF),
      },
      {
        'lessonId': 'math_grade5_01',
        'lessonTitle': 'පාඩම 1: රන් අඹ ගවේෂණය (Golden Mango)',
        'lessonBadge': '🥭 Lesson 1',
        'lessonBadgeColor': const Color(0xFFFFA502),
        'conceptId': 'c3_giants_gate',
        'title': '3️⃣ 10,000 සිට 100,000 දක්වා විශාල සංඛ්‍යා',
        'subtitle': 'Reading & writing large 5-digit numbers',
        'formats': ['📖 සංඛ්‍යා කියවීම', '🔢 100,000 දක්වා'],
        'color': const Color(0xFFFF4757),
      },
      {
        'lessonId': 'math_grade5_01',
        'lessonTitle': 'පාඩම 1: රන් අඹ ගවේෂණය (Golden Mango)',
        'lessonBadge': '🥭 Lesson 1',
        'lessonBadgeColor': const Color(0xFFFFA502),
        'conceptId': 'c4_crystal_cave',
        'title': '4️⃣ දසදහස්ස්ථානය දක්වා ස්ථානීය අගයන්',
        'subtitle': 'Ten-thousands place value & comparisons',
        'formats': ['⚖️ < > = සංසන්දනය', '💎 දසදහස්ස්ථානය'],
        'color': const Color(0xFF9B59B6),
      },
      {
        'lessonId': 'math_grade5_01',
        'lessonTitle': 'පාඩම 1: රන් අඹ ගවේෂණය (Golden Mango)',
        'lessonBadge': '🥭 Lesson 1',
        'lessonBadgeColor': const Color(0xFFFFA502),
        'conceptId': 'c5_unlocking_chest',
        'title': '5️⃣ සංඛ්‍යා විහිදුවා ලිවීම (Expanded Form)',
        'subtitle': 'Expanded form building & missing terms',
        'formats': ['➕ විහිදුවා ලිවීම', '🗝️ පෙට්ටිය විවර කිරීම'],
        'color': const Color(0xFFFFA502),
      },

      // LESSON 2 CONCEPTS
      {
        'lessonId': 'math_grade5_02',
        'lessonTitle': 'පාඩම 2: මහා සංඛ්‍යා දුම්රිය (Number Train)',
        'lessonBadge': '🚂 Lesson 2',
        'lessonBadgeColor': const Color(0xFF00D2D3),
        'conceptId': 'c1_number_train_station',
        'title': '6️⃣ සංඛ්‍යා සසඳමු (<, >, =)',
        'subtitle': 'Comparing 2-digit & 3-digit numbers',
        'formats': ['⚖️ < > = සංසන්දනය', '🚉 සංඛ්‍යා දුම්රියපොළ'],
        'color': const Color(0xFF2ED573),
      },
      {
        'lessonId': 'math_grade5_02',
        'lessonTitle': 'පාඩම 2: මහා සංඛ්‍යා දුම්රිය (Number Train)',
        'lessonBadge': '🚂 Lesson 2',
        'lessonBadgeColor': const Color(0xFF00D2D3),
        'conceptId': 'c2_number_train_ordering',
        'title': '7️⃣ දුම්රිය මැදිරි පේළිගත කිරීම (Ordering)',
        'subtitle': 'Ascending & Descending carriage ordering',
        'formats': ['🚂 මැදිරි පෙළගැස්ම', '⬆️ ආරෝහණ / අවරෝහණ'],
        'color': const Color(0xFF54A0FF),
      },
      {
        'lessonId': 'math_grade5_02',
        'lessonTitle': 'පාඩම 2: මහා සංඛ්‍යා දුම්රිය (Number Train)',
        'lessonBadge': '🚂 Lesson 2',
        'lessonBadgeColor': const Color(0xFF00D2D3),
        'conceptId': 'c3_digit_cards',
        'title': '8️⃣ ඉලක්කම් කාඩ්පත් මඟින් සංඛ්‍යා නිර්මාණය',
        'subtitle': 'Building largest & smallest numbers with cards',
        'formats': ['🃏 0-9 කාඩ්පත්', '🌟 විශාලම / කුඩාම'],
        'color': const Color(0xFFFF9F43),
      },
      {
        'lessonId': 'math_grade5_02',
        'lessonTitle': 'පාඩම 2: මහා සංඛ්‍යා දුම්රිය (Number Train)',
        'lessonBadge': '🚂 Lesson 2',
        'lessonBadgeColor': const Color(0xFF00D2D3),
        'conceptId': 'c4_mountain_tracks',
        'title': '9️⃣ විශාල සංඛ්‍යා කඳු තරණය (Mountain Track)',
        'subtitle': 'Comparing 4-digit & 5-digit real-world numbers',
        'formats': ['🏔️ කඳු තරණය', '⚖️ < > = සංසන්දනය'],
        'color': const Color(0xFFFF6B6B),
      },
      {
        'lessonId': 'math_grade5_02',
        'lessonTitle': 'පාඩම 2: මහා සංඛ්‍යා දුම්රිය (Number Train)',
        'lessonBadge': '🚂 Lesson 2',
        'lessonBadgeColor': const Color(0xFF00D2D3),
        'conceptId': 'c5_championship_flag',
        'title': '🔟 මහා දුම්රිය ශූරතාව (Championship Mastery)',
        'subtitle': 'Mixed mastery challenge across all skills',
        'formats': ['🏆 ශූරතා අභියෝගය', '⭐ මිශ්‍ර අභ්‍යාස'],
        'color': const Color(0xFFFFD700),
      },
    ];

    // Filter concepts
    final filteredConcepts = conceptDefinitions.where((c) {
      if (_selectedLessonFilter == 'lesson1') {
        return c['lessonId'] == 'math_grade5_01';
      } else if (_selectedLessonFilter == 'lesson2') {
        return c['lessonId'] == 'math_grade5_02';
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', '🌟 සියලුම ප්‍රශ්න (40 Qs)'),
                const SizedBox(width: 8),
                _buildFilterChip('lesson1', '🥭 පාඩම 1: රන් අඹ (20 Qs)'),
                const SizedBox(width: 8),
                _buildFilterChip('lesson2', '🚂 පාඩම 2: සංඛ්‍යා දුම්රිය (20 Qs)'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Concept Cards
          ...filteredConcepts.map((c) => _buildConceptChallengeCard(c)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final bool isSelected = _selectedLessonFilter == filterKey;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF2C2C54) : Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFFFD700),
      backgroundColor: const Color(0xFF1E1E38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
        ),
      ),
      onSelected: (_) {
        setState(() => _selectedLessonFilter = filterKey);
      },
    );
  }

  Widget _buildConceptChallengeCard(Map<String, dynamic> concept) {
    final conceptId = concept['conceptId'] as String;
    final title = concept['title'] as String;
    final subtitle = concept['subtitle'] as String;
    final lessonBadge = concept['lessonBadge'] as String;
    final lessonBadgeColor = concept['lessonBadgeColor'] as Color;
    final formats = concept['formats'] as List<String>;
    final accentColor = concept['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 10,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: lessonBadgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: lessonBadgeColor.withOpacity(0.6)),
                ),
                child: Text(
                  lessonBadge,
                  style: TextStyle(
                    color: lessonBadgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '4 ප්‍රශ්න • +50 XP',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 10),

          // Format Badges
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: formats.map((f) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  f,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Play Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startConceptSession(
                conceptId: conceptId,
                conceptTitle: title,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🚀', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  Text(
                    'පුහුණු අභියෝගය ආරම්භ කරමු',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
