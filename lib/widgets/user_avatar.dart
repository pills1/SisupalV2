import 'package:flutter/material.dart';

/// Pre-defined curated avatars for Grade 5 students
class AppAvatars {
  static const List<Map<String, String>> defaultList = [
    // Local High-Res Characters
    {
      'id': 'parrot',
      'value': 'assets/images/maths_parrot_idle.png',
      'label': 'ගිරවා 🦜',
      'type': 'asset',
    },
    {
      'id': 'lion',
      'value': 'assets/images/char_lion_idle.png',
      'label': 'සිංහ රජු 🦁',
      'type': 'asset',
    },
    {
      'id': 'elephant',
      'value': 'assets/images/char_elephant_guide_idle.png',
      'label': 'නැණවත් අලියා 🐘',
      'type': 'asset',
    },
    {
      'id': 'fox',
      'value': 'assets/images/char_fox_trickster_idle.png',
      'label': 'දක්ෂ නරියා 🦊',
      'type': 'asset',
    },

    // Curated Character Emojis & Styles
    {
      'id': 'super_boy',
      'value': '🦸‍♂️',
      'label': 'සුපිරි කොල්ලා 🦸‍♂️',
      'type': 'emoji',
    },
    {
      'id': 'super_girl',
      'value': '🦸‍♀️',
      'label': 'සුපිරි කෙල්ල 🦸‍♀️',
      'type': 'emoji',
    },
    {
      'id': 'scholar_boy',
      'value': '🧑‍🎓',
      'label': 'විද්වත් සිසුවා 🧑‍🎓',
      'type': 'emoji',
    },
    {
      'id': 'scholar_girl',
      'value': '👩‍🎓',
      'label': 'විද්වත් සිසුවිය 👩‍🎓',
      'type': 'emoji',
    },
    {
      'id': 'astronaut',
      'value': '🧑‍🚀',
      'label': 'ගගනගාමියා 🧑‍🚀',
      'type': 'emoji',
    },
    {
      'id': 'prince',
      'value': '🤴',
      'label': 'කුමරු 🤴',
      'type': 'emoji',
    },
    {
      'id': 'princess',
      'value': '👸',
      'label': 'කුමරිය 👸',
      'type': 'emoji',
    },
    {
      'id': 'tiger',
      'value': '🐯',
      'label': 'වීර කොටි පැටියා 🐯',
      'type': 'emoji',
    },
    {
      'id': 'owl',
      'value': '🦉',
      'label': 'නුවණැති බකමූණා 🦉',
      'type': 'emoji',
    },
    {
      'id': 'champion',
      'value': '🏆',
      'label': 'රන් ශූරයා 🏆',
      'type': 'emoji',
    },
    {
      'id': 'star_kid',
      'value': '⭐',
      'label': 'තරු දරුවා ⭐',
      'type': 'emoji',
    },
    {
      'id': 'ninja',
      'value': '🥷',
      'label': 'ගණිත නින්ජා 🥷',
      'type': 'emoji',
    },
  ];

  static String getDefaultAvatar() => 'assets/images/maths_parrot_idle.png';

  /// Safe extractor that handles null, Strings, and Maps without type errors
  static String extractAvatarString(dynamic raw) {
    if (raw == null) return getDefaultAvatar();
    if (raw is String) {
      final trimmed = raw.trim();
      return trimmed.isEmpty ? getDefaultAvatar() : trimmed;
    }
    if (raw is Map) {
      if (raw['value'] != null) return extractAvatarString(raw['value']);
      if (raw['url'] != null) return extractAvatarString(raw['url']);
      if (raw['id'] != null) return extractAvatarString(raw['id']);
      if (raw['avatar'] != null) return extractAvatarString(raw['avatar']);
    }
    final str = raw.toString().trim();
    return str.isEmpty ? getDefaultAvatar() : str;
  }
}

/// Resilient Avatar Widget that renders assets, emojis, and network images perfectly
class UserAvatar extends StatelessWidget {
  final dynamic avatar;
  final double size;
  final Border? border;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    required this.avatar,
    this.size = 50,
    this.border,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final String val = AppAvatars.extractAvatarString(avatar);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        color: backgroundColor ?? const Color(0xFFEEF2FF),
      ),
      child: ClipOval(
        child: _buildAvatarContent(val),
      ),
    );
  }

  Widget _buildAvatarContent(String val) {
    // 1. Local asset image
    if (val.startsWith('assets/')) {
      return Image.asset(
        val,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
      );
    }

    // 2. Network image URL
    if (val.startsWith('http://') || val.startsWith('https://')) {
      return Image.network(
        val,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
      );
    }

    // 3. Emoji or character string
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Text(
          val,
          style: TextStyle(
            fontSize: size * 0.55,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: const Color(0xFFDBEAFE),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: const Color(0xFF2563EB),
          size: size * 0.6,
        ),
      ),
    );
  }
}
