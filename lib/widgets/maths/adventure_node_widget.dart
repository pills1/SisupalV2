import 'package:flutter/material.dart';
import '../../models/maths/adventure_node_model.dart';
import '../animated_widgets.dart';

/// Game-level circular node widget for the Mathematics Adventure Map.
/// Renders distinct visual styles for LOCKED, AVAILABLE, IN_PROGRESS, and COMPLETED states.
/// Upgraded to larger 100px nodes for better visibility and tappability.
class AdventureNodeWidget extends StatelessWidget {
  final AdventureNodeModel node;
  final VoidCallback onTap;
  final bool alignRight;

  const AdventureNodeWidget({
    super.key,
    required this.node,
    required this.onTap,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (node.state) {
      case LessonNodeState.locked:
        return _buildLockedNode();
      case LessonNodeState.available:
        return _buildAvailableNode();
      case LessonNodeState.inProgress:
        return _buildInProgressNode();
      case LessonNodeState.completed:
        return _buildCompletedNode();
    }
  }

  /// LOCKED: Semi-transparent, grey, dimmed lock icon
  Widget _buildLockedNode() {
    return BouncingButton(
      onPressed: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Location label
            Text(
              '${node.locationEmoji} ${node.locationName}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Circle node — larger 90px
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A2D45),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    color: Colors.white.withOpacity(0.3),
                    size: 28,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${node.lessonNumber}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              node.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.35),
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

  /// AVAILABLE: Bright, pulsing glow, play icon, START badge
  Widget _buildAvailableNode() {
    return BouncingButton(
      onPressed: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Location label
            Text(
              '${node.locationEmoji} ${node.locationName}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Pulsing glowing circle — 100px
            PulsingWidget(
              minScale: 0.96,
              maxScale: 1.04,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [node.themeColor, node.themeColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 4.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: node.themeColor.withOpacity(0.6),
                      blurRadius: 24,
                      spreadRadius: 6,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    Text(
                      '${node.lessonNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              node.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            // START badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: node.themeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'START ▶',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: node.themeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// IN PROGRESS: Blue gradient, continue indicator
  Widget _buildInProgressNode() {
    return BouncingButton(
      onPressed: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Location label
            Text(
              '${node.locationEmoji} ${node.locationName}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Circle with blue gradient — 100px
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF0984E3), Color(0xFF74B9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0984E3).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh_rounded, color: Colors.white, size: 32),
                  Text(
                    '${node.lessonNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              node.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            // CONTINUE badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0984E3), Color(0xFF74B9FF)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0984E3).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'CONTINUE ▶',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// COMPLETED: Gold, checkmark, 3-star display, sparkle feel
  Widget _buildCompletedNode() {
    return BouncingButton(
      onPressed: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Location label
            Text(
              '${node.locationEmoji} ${node.locationName}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Gold circle with checkmark — 100px
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFF39C12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.45),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, color: Colors.white, size: 32),
                  Text(
                    '${node.lessonNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Stars — slightly larger
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < node.stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: index < node.stars
                      ? const Color(0xFFFFD700)
                      : Colors.white.withOpacity(0.35),
                  size: 24,
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              node.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
