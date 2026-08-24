import 'package:flutter/material.dart';

/// ============================================
/// GOLDEN MANGO STORY MODELS
/// Data-driven models for the interactive story engine
/// ============================================

/// Characters in the Quest for the Golden Mango
enum StoryCharacter {
  leo,
  ella,
  felix,
}

/// Animation type for character entrance/presentation
enum StoryAnimation {
  slideFromLeft,
  slideFromRight,
  popIn,
  fadeIn,
}

/// Extension providing character metadata
extension StoryCharacterData on StoryCharacter {
  String get displayName {
    switch (this) {
      case StoryCharacter.leo:
        return 'ලියෝ';
      case StoryCharacter.ella:
        return 'එළි';
      case StoryCharacter.felix:
        return 'ෆීලික්ස්';
    }
  }

  String get displayNameSi {
    switch (this) {
      case StoryCharacter.leo:
        return 'ලියෝ';
      case StoryCharacter.ella:
        return 'එළි';
      case StoryCharacter.felix:
        return 'ෆීලික්ස්';
    }
  }

  String get emoji {
    switch (this) {
      case StoryCharacter.leo:
        return '🦁';
      case StoryCharacter.ella:
        return '🐘';
      case StoryCharacter.felix:
        return '🦊';
    }
  }

  String get assetPath {
    switch (this) {
      case StoryCharacter.leo:
        return 'assets/images/char_lion_idle.png';
      case StoryCharacter.ella:
        return 'assets/images/char_elephant_guide_idle.png';
      case StoryCharacter.felix:
        return 'assets/images/char_fox_trickster_idle.png';
    }
  }

  Color get themeColor {
    switch (this) {
      case StoryCharacter.leo:
        return const Color(0xFFFF8F00); // Amber
      case StoryCharacter.ella:
        return const Color(0xFF6C5CE7); // Purple
      case StoryCharacter.felix:
        return const Color(0xFFE17055); // Coral-red
    }
  }

  Color get bubbleColor {
    switch (this) {
      case StoryCharacter.leo:
        return const Color(0xFFFFF3E0); // Light amber
      case StoryCharacter.ella:
        return const Color(0xFFF3E5F5); // Light purple
      case StoryCharacter.felix:
        return const Color(0xFFFBE9E7); // Light coral
    }
  }

  StoryAnimation get defaultAnimation {
    switch (this) {
      case StoryCharacter.leo:
        return StoryAnimation.slideFromLeft;
      case StoryCharacter.ella:
        return StoryAnimation.slideFromRight;
      case StoryCharacter.felix:
        return StoryAnimation.popIn;
    }
  }
}

/// A single dialogue beat in the story
class StoryBeat {
  final StoryCharacter speaker;
  final String text;
  final StoryAnimation? animation;
  final bool isFinal; // true = last beat before exercise placeholder

  const StoryBeat({
    required this.speaker,
    required this.text,
    this.animation,
    this.isFinal = false,
  });

  /// Resolved animation: uses override or character default
  StoryAnimation get resolvedAnimation =>
      animation ?? speaker.defaultAnimation;
}

/// A single concept (chapter) in the Golden Mango adventure
class GoldenMangoConcept {
  final String id;
  final String title;
  final String learningObjective;
  final String learningObjectiveSi;
  final String backgroundAsset;
  final List<StoryBeat> beats;
  final String rewardText;

  const GoldenMangoConcept({
    required this.id,
    required this.title,
    required this.learningObjective,
    required this.learningObjectiveSi,
    required this.backgroundAsset,
    required this.beats,
    required this.rewardText,
  });
}
