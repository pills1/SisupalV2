import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/user_avatar.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Icon(Icons.emoji_events, color: Colors.white, size: 50),
                      const SizedBox(height: 8),
                      const Text(
                        "Leaderboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Top Students",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tab Bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.softShadow,
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorPadding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: "All Time"),
                  Tab(text: "This Week"),
                ],
              ),
            ),
          ),

          // Leaderboard Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardList(currentUser, allTime: true),
                _buildLeaderboardList(currentUser, allTime: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(User? currentUser, {required bool allTime}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .orderBy('xp', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("No students yet!", style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              // Podium for top 3
              if (docs.length >= 3) _buildPodium(docs.take(3).toList(), currentUser),
              
              // Rest of the list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(
                    docs.length > 3 ? docs.length - 3 : 0,
                    (index) {
                      final actualIndex = index + 3;
                      final data = docs[actualIndex].data() as Map<String, dynamic>? ?? {};
                      String name = (data['name'] as String?)?.trim().isNotEmpty == true
                          ? data['name']
                          : (data['studentName'] as String?)?.trim().isNotEmpty == true
                              ? data['studentName']
                              : (data['displayName'] as String?)?.trim().isNotEmpty == true
                                  ? data['displayName']
                                  : "Student ${actualIndex + 1}";
                      int xp = data['xp'] ?? 0;
                      String uid = docs[actualIndex].id;
                      String avatar = AppAvatars.extractAvatarString(data['avatar']);
                      bool isMe = (currentUser?.uid == uid);
                      int level = LevelSystem.getLevel(xp);

                      return SlideInWidget(
                        delay: Duration(milliseconds: 100 * index),
                        child: _buildRankCard(
                          rank: actualIndex + 1,
                          name: name,
                          xp: xp,
                          avatar: avatar,
                          level: level,
                          isMe: isMe,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPodium(List<QueryDocumentSnapshot> topThree, User? currentUser) {
    // Reorder: [1st, 0th, 2nd] for visual podium (2nd place, 1st place, 3rd place)
    final first = topThree[0].data() as Map<String, dynamic>? ?? {};
    final second = topThree.length > 1 ? topThree[1].data() as Map<String, dynamic>? ?? {} : null;
    final third = topThree.length > 2 ? topThree[2].data() as Map<String, dynamic>? ?? {} : null;

    final firstName = (first['name'] as String?)?.trim().isNotEmpty == true
        ? first['name']
        : (first['studentName'] as String?)?.trim().isNotEmpty == true
            ? first['studentName']
            : (first['displayName'] as String?)?.trim().isNotEmpty == true
                ? first['displayName']
                : "Top Student";

    final secondName = second != null
        ? ((second['name'] as String?)?.trim().isNotEmpty == true
            ? second['name']
            : (second['studentName'] as String?)?.trim().isNotEmpty == true
                ? second['studentName']
                : (second['displayName'] as String?)?.trim().isNotEmpty == true
                    ? second['displayName']
                    : "Student 2")
        : "Unknown";

    final thirdName = third != null
        ? ((third['name'] as String?)?.trim().isNotEmpty == true
            ? third['name']
            : (third['studentName'] as String?)?.trim().isNotEmpty == true
                ? third['studentName']
                : (third['displayName'] as String?)?.trim().isNotEmpty == true
                    ? third['displayName']
                    : "Student 3")
        : "Unknown";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (second != null)
            Expanded(
              child: SlideInWidget(
                delay: const Duration(milliseconds: 200),
                child: _buildPodiumItem(
                  rank: 2,
                  name: secondName,
                  xp: second['xp'] ?? 0,
                  avatar: AppAvatars.extractAvatarString(second['avatar']),
                  height: 100,
                  color: AppColors.silver,
                  isMe: currentUser?.uid == topThree[1].id,
                ),
              ),
            ),
          
          // 1st Place (center, tallest)
          Expanded(
            child: SlideInWidget(
              delay: const Duration(milliseconds: 100),
              child: _buildPodiumItem(
                rank: 1,
                name: firstName,
                xp: first['xp'] ?? 0,
                avatar: AppAvatars.extractAvatarString(first['avatar']),
                height: 140,
                color: AppColors.gold,
                isMe: currentUser?.uid == topThree[0].id,
              ),
            ),
          ),
          
          // 3rd Place
          if (third != null)
            Expanded(
              child: SlideInWidget(
                delay: const Duration(milliseconds: 300),
                child: _buildPodiumItem(
                  rank: 3,
                  name: thirdName,
                  xp: third['xp'] ?? 0,
                  avatar: AppAvatars.extractAvatarString(third['avatar']),
                  height: 80,
                  color: AppColors.bronze,
                  isMe: currentUser?.uid == topThree[2].id,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required int rank,
    required String name,
    required int xp,
    required String avatar,
    required double height,
    required Color color,
    required bool isMe,
  }) {
    final level = LevelSystem.getLevel(xp);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for 1st place
        if (rank == 1)
          const PulsingWidget(
            minScale: 0.95,
            maxScale: 1.05,
            child: Text("👑", style: TextStyle(fontSize: 32)),
          ),
        
        // Avatar with border
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: rank == 1 ? 80 : 65,
              height: rank == 1 ? 80 : 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: UserAvatar(
                avatar: avatar,
                size: rank == 1 ? 76 : 60,
              ),
            ),
            // Level badge
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: LevelSystem.getLevelColor(level),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Lv.$level",
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Name
        Text(
          isMe ? "$name (You)" : name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: rank == 1 ? 14 : 12,
            color: isMe ? Colors.blue : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "$xp XP",
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        
        // Podium stand
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              "#$rank",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankCard({
    required int rank,
    required String name,
    required int xp,
    required String avatar,
    required int level,
    required bool isMe,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: Colors.blue, width: 2) : null,
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "#$rank",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Avatar
          Stack(
            children: [
              UserAvatar(
                avatar: avatar,
                size: 44,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: LevelSystem.getLevelColor(level),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "$level",
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? "$name (You)" : name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.blue : Colors.black87,
                  ),
                ),
                Text(
                  LevelSystem.getLevelTitle(level),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          
          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  "$xp XP",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    fontSize: 13,
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