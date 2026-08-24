import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';
import 'animated_widgets.dart';

/// ============================================
/// GAMIFICATION WIDGETS - Game-specific UI Components
/// ============================================

/// Circular XP Progress indicator with level display
class XPProgressRing extends StatelessWidget {
  final int currentXP;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final bool showLevel;

  const XPProgressRing({
    super.key,
    required this.currentXP,
    this.size = 80,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.showLevel = true,
  });

  @override
  Widget build(BuildContext context) {
    final level = LevelSystem.getLevel(currentXP);
    final progress = LevelSystem.getProgress(currentXP);
    final levelColor = LevelSystem.getLevelColor(level);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor ?? Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(backgroundColor ?? Colors.grey.shade200),
            ),
          ),
          // Progress arc
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(levelColor),
                  strokeCap: StrokeCap.round,
                ),
              );
            },
          ),
          // Level number
          if (showLevel)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$level",
                  style: TextStyle(
                    fontSize: size * 0.3,
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
                Text(
                  "LVL",
                  style: TextStyle(
                    fontSize: size * 0.12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Level badge with title and icon
class LevelBadge extends StatelessWidget {
  final int xp;
  final bool compact;

  const LevelBadge({
    super.key,
    required this.xp,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final level = LevelSystem.getLevel(xp);
    final title = LevelSystem.getLevelTitle(level);
    final color = LevelSystem.getLevelColor(level);
    final icon = LevelSystem.getLevelIcon(level);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              "Lv.$level",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Level $level",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated streak flame indicator
class StreakFlame extends StatelessWidget {
  final int streak;
  final bool animate;
  final double size;

  const StreakFlame({
    super.key,
    required this.streak,
    this.animate = true,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.3, vertical: size * 0.15),
      decoration: BoxDecoration(
        gradient: streak > 0 ? AppColors.fireGradient : null,
        color: streak <= 0 ? Colors.grey.shade300 : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: streak > 0
            ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: streak > 0 ? Colors.white : Colors.grey,
            size: size * 0.5,
          ),
          const SizedBox(width: 4),
          Text(
            "$streak",
            style: TextStyle(
              color: streak > 0 ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.35,
            ),
          ),
        ],
      ),
    );

    if (animate && streak > 0) {
      return PulsingWidget(
        minScale: 0.98,
        maxScale: 1.02,
        child: child,
      );
    }
    return child;
  }
}

/// Achievement badge display
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  final double size;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.unlocked = false,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? achievement.color.withOpacity(0.15) : Colors.grey.shade200,
              border: Border.all(
                color: unlocked ? achievement.color : Colors.grey.shade300,
                width: 3,
              ),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: achievement.color.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              achievement.icon,
              color: unlocked ? achievement.color : Colors.grey,
              size: size * 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: unlocked ? Colors.black87 : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Daily challenge card
class DailyChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final int xpReward;
  final double progress;
  final VoidCallback? onTap;
  final bool completed;

  const DailyChallengeCard({
    super.key,
    required this.title,
    required this.description,
    required this.xpReward,
    this.progress = 0.0,
    this.onTap,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onPressed: completed ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: completed
              ? AppColors.successGradient
              : const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (completed ? Colors.green : const Color(0xFF6C5CE7))
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
                completed ? Icons.check_circle : Icons.flag_circle,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
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
                              "+$xpReward XP",
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
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                  if (!completed && progress > 0) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 6,
                      ),
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
}

/// Combo counter for quiz streaks
class ComboCounter extends StatelessWidget {
  final int combo;
  final double size;

  const ComboCounter({
    super.key,
    required this.combo,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (combo <= 1) return const SizedBox.shrink();

    Color comboColor;
    String label;
    
    if (combo >= 5) {
      comboColor = Colors.red;
      label = "🔥 ON FIRE!";
    } else if (combo >= 3) {
      comboColor = Colors.orange;
      label = "⚡ COMBO!";
    } else {
      comboColor = Colors.amber;
      label = "✨ Nice!";
    }

    return ScaleInWidget(
      beginScale: 0.5,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [comboColor.withOpacity(0.8), comboColor],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: comboColor.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${combo}x",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// XP earned popup animation
class XPPopup extends StatefulWidget {
  final int xp;
  final VoidCallback? onComplete;

  const XPPopup({
    super.key,
    required this.xp,
    this.onComplete,
  });

  @override
  State<XPPopup> createState() => _XPPopupState();
}

class _XPPopupState extends State<XPPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "+${widget.xp} XP",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Stat card for profile/dashboard
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Gradient? gradient;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null ? color.withOpacity(0.15) : null,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: gradient != null ? Colors.white : color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Subject progress card with ring indicator
class SubjectProgressCard extends StatelessWidget {
  final String subject;
  final IconData icon;
  final Color color;
  final double progress;
  final int lessonsCompleted;
  final int totalLessons;
  final VoidCallback? onTap;

  const SubjectProgressCard({
    super.key,
    required this.subject,
    required this.icon,
    required this.color,
    this.progress = 0.0,
    this.lessonsCompleted = 0,
    this.totalLessons = 10,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Progress ring with icon
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 5,
                        backgroundColor: color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subject,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF2D3436),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "$lessonsCompleted/$totalLessons lessons",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
