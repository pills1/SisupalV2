import 'package:flutter/material.dart';

/// Representation of a node's state on the Mathematics Adventure Map
enum LessonNodeState {
  locked,
  available,
  inProgress,
  completed,
}

/// Model class representing a single lesson node on the Mathematics Adventure Map
class AdventureNodeModel {
  final String id;
  final String lessonId;
  final int lessonNumber;
  final String title;
  final String subtitle;
  final LessonNodeState state;
  final IconData? icon;
  final int xpReward;
  final int stars;
  final String? description;
  final bool isPlaceholder;

  /// Themed location metadata for game-world map presentation
  final String locationName;
  final String locationEmoji;
  final Color themeColor;

  const AdventureNodeModel({
    required this.id,
    required this.lessonId,
    required this.lessonNumber,
    required this.title,
    required this.subtitle,
    this.state = LessonNodeState.locked,
    this.icon,
    this.xpReward = 50,
    this.stars = 0,
    this.description,
    this.isPlaceholder = false,
    this.locationName = '',
    this.locationEmoji = '📍',
    this.themeColor = const Color(0xFFFF6B35),
  });

  /// Helper to create a copy of the node with modified attributes
  AdventureNodeModel copyWith({
    String? id,
    String? lessonId,
    int? lessonNumber,
    String? title,
    String? subtitle,
    LessonNodeState? state,
    IconData? icon,
    int? xpReward,
    int? stars,
    String? description,
    bool? isPlaceholder,
    String? locationName,
    String? locationEmoji,
    Color? themeColor,
  }) {
    return AdventureNodeModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      state: state ?? this.state,
      icon: icon ?? this.icon,
      xpReward: xpReward ?? this.xpReward,
      stars: stars ?? this.stars,
      description: description ?? this.description,
      isPlaceholder: isPlaceholder ?? this.isPlaceholder,
      locationName: locationName ?? this.locationName,
      locationEmoji: locationEmoji ?? this.locationEmoji,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}
