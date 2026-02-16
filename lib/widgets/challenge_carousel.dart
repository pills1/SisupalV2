import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../utils/app_theme.dart';
import '../services/daily_challenge_service.dart';
import 'animated_widgets.dart';
import 'gamification_widgets.dart';

/// ============================================
/// DAILY CHALLENGES CAROUSEL
/// ============================================

class DailyChallengesCarousel extends StatefulWidget {
  final List<DailyChallenge> challenges;
  final ValueChanged<DailyChallenge>? onChallengeTap;

  const DailyChallengesCarousel({
    super.key,
    required this.challenges,
    this.onChallengeTap,
  });

  @override
  State<DailyChallengesCarousel> createState() => _DailyChallengesCarouselState();
}

class _DailyChallengesCarouselState extends State<DailyChallengesCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.challenges.isEmpty) {
      return DailyChallengeCard(
        title: "Daily Challenge",
        description: "No challenges available",
        xpReward: 0,
        progress: 0.0,
        onTap: () {},
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Daily Challenges",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${widget.challenges.where((c) => c.completed).length}/${widget.challenges.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontally scrollable challenge cards
        SizedBox(
          height: 145,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.challenges.length,
            itemBuilder: (context, index) {
              final challenge = widget.challenges[index];
              return AnimatedPadding(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: _currentPage == index ? 0 : 8,
                ),
                child: _HorizontalChallengeCard(
                  challenge: challenge,
                  onTap: () => widget.onChallengeTap?.call(challenge),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.challenges.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF6C5CE7)
                    : const Color(0xFF6C5CE7).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Horizontal challenge card for swipeable carousel
class _HorizontalChallengeCard extends StatelessWidget {
  final DailyChallenge challenge;
  final VoidCallback? onTap;

  const _HorizontalChallengeCard({
    required this.challenge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = challenge.completed;
    final List<Color> gradientColors = _getGradientColors(challenge.type, isCompleted);

    return GestureDetector(
      onTap: isCompleted ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                _getChallengeIcon(challenge.type),
                size: 100,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_circle : _getChallengeIcon(challenge.type),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              challenge.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // XP badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              "+${challenge.xpReward}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Progress bar
                  if (!isCompleted) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: challenge.progressPercentage,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${challenge.progress}/${challenge.target}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "Completed! 🎉",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors(ChallengeType type, bool completed) {
    if (completed) return [const Color(0xFF00B894), const Color(0xFF55EFC4)];
    switch (type) {
      case ChallengeType.quizComplete:
        return [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)];
      case ChallengeType.perfectQuiz:
        return [const Color(0xFFFF6B6B), const Color(0xFFFF9FF3)];
      case ChallengeType.combo:
        return [const Color(0xFFFF9F43), const Color(0xFFFECA57)];
      case ChallengeType.lessonComplete:
        return [const Color(0xFF0984E3), const Color(0xFF74B9FF)];
      case ChallengeType.videoWatch:
        return [const Color(0xFFE17055), const Color(0xFFFAB1A0)];
      case ChallengeType.earnXP:
        return [const Color(0xFFD63031), const Color(0xFFFF7675)];
    }
  }

  IconData _getChallengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.quizComplete:
        return Icons.quiz;
      case ChallengeType.perfectQuiz:
        return Icons.verified;
      case ChallengeType.combo:
        return Icons.local_fire_department;
      case ChallengeType.lessonComplete:
        return Icons.school;
      case ChallengeType.videoWatch:
        return Icons.play_circle;
      case ChallengeType.earnXP:
        return Icons.star;
    }
  }
}

/// Compact challenge item for vertical list view
class _CompactChallengeItem extends StatelessWidget {
  final DailyChallenge challenge;
  final VoidCallback? onTap;

  const _CompactChallengeItem({
    required this.challenge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = challenge.completed;
    
    return GestureDetector(
      onTap: isCompleted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? AppColors.successGradient
              : const LinearGradient(
                  colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (isCompleted ? Colors.green : const Color(0xFF00B894))
                  .withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : _getChallengeIcon(challenge.type),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    challenge.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  if (!isCompleted) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: challenge.progressPercentage,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${challenge.progress}/${challenge.target}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // XP Reward
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    "+${challenge.xpReward}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getChallengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.quizComplete:
        return Icons.quiz;
      case ChallengeType.perfectQuiz:
        return Icons.verified;
      case ChallengeType.combo:
        return Icons.local_fire_department;
      case ChallengeType.lessonComplete:
        return Icons.school;
      case ChallengeType.videoWatch:
        return Icons.play_circle;
      case ChallengeType.earnXP:
        return Icons.star;
    }
  }
}

class _ChallengeCarouselItem extends StatelessWidget {
  final DailyChallenge challenge;
  final VoidCallback? onTap;

  const _ChallengeCarouselItem({
    required this.challenge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = challenge.completed;
    
    return BouncingButton(
      onPressed: isCompleted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? AppColors.successGradient
              : const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isCompleted ? Colors.green : const Color(0xFF6C5CE7))
                  .withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : _getChallengeIcon(challenge.type),
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "+${challenge.xpReward} XP",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                  if (!isCompleted) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: challenge.progressPercentage,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${challenge.progress}/${challenge.target}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getChallengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.quizComplete:
        return Icons.quiz;
      case ChallengeType.perfectQuiz:
        return Icons.verified;
      case ChallengeType.combo:
        return Icons.local_fire_department;
      case ChallengeType.lessonComplete:
        return Icons.school;
      case ChallengeType.videoWatch:
        return Icons.play_circle;
      case ChallengeType.earnXP:
        return Icons.star;
    }
  }
}

/// ============================================
/// ACHIEVEMENT UNLOCK OVERLAY
/// ============================================

class AchievementUnlockOverlay extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementUnlockOverlay({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  @override
  State<AchievementUnlockOverlay> createState() => _AchievementUnlockOverlayState();
}

class _AchievementUnlockOverlayState extends State<AchievementUnlockOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shineController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
    
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.linear),
    );
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Start animations
    _scaleController.forward();
    _shineController.repeat();
    _confettiController.play();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shineController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [
                Colors.amber,
                Colors.purple,
                Colors.blue,
                Colors.green,
                Colors.pink,
                Colors.orange,
              ],
            ),
          ),
          // Content
          GestureDetector(
            onTap: widget.onDismiss,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "Achievement Unlocked" text
                ScaleInWidget(
                  beginScale: 0.5,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "ACHIEVEMENT UNLOCKED!",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Badge
                AnimatedBuilder(
                  animation: _scaleController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _shineController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Rotating shine effect
                          Transform.rotate(
                            angle: _rotateAnimation.value,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    Colors.transparent,
                                    widget.achievement.color.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Badge
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  widget.achievement.color.withOpacity(0.8),
                                  widget.achievement.color,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.achievement.color.withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.achievement.icon,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                // Title
                SlideInWidget(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    widget.achievement.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                SlideInWidget(
                  delay: const Duration(milliseconds: 500),
                  child: Text(
                    widget.achievement.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                // Tap to continue
                SlideInWidget(
                  delay: const Duration(milliseconds: 600),
                  child: Text(
                    "Tap to continue",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
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

/// Shows the achievement unlock overlay
void showAchievementUnlock(BuildContext context, Achievement achievement) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Achievement Unlock',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return AchievementUnlockOverlay(
        achievement: achievement,
        onDismiss: () => Navigator.of(context).pop(),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
