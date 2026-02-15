import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================
/// APP THEME - Design System for SisuPal
/// ============================================

class AppColors {
  // Primary Colors
  static const Color primaryDark = Color(0xFF1A1A2E);
  static const Color primaryLight = Color(0xFF16213E);
  static const Color accent = Color(0xFF0F3460);
  
  // Gamification Colors
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color xpPurple = Color(0xFF9B59B6);
  static const Color levelBlue = Color(0xFF3498DB);
  static const Color streakOrange = Color(0xFFE74C3C);
  
  // Subject Colors
  static const Color mathOrange = Color(0xFFFF6B35);
  static const Color sinhalaViolet = Color(0xFF8E44AD);
  static const Color environmentGreen = Color(0xFF27AE60);
  static const Color languageTeal = Color(0xFF16A085);
  
  // Gradient Presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFfa709a), Color(0xFFfee140)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF64b3f4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFf12711), Color(0xFFf5af19)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
}

class AppShadows {
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.from(alpha: 0.08, red: 0, green: 0, blue: 0),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: Color.from(alpha: 0.4, red: color.r, green: color.g, blue: color.b),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
  
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color.from(alpha: 0.05, red: 0, green: 0, blue: 0),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xl = 24.0;
  static const double round = 50.0;
}

/// ============================================
/// LEVEL SYSTEM UTILITIES
/// ============================================

class LevelSystem {
  static const int xpPerLevel = 100;
  
  static int getLevel(int xp) => (xp / xpPerLevel).floor() + 1;
  
  static int getXPForNextLevel(int currentXP) {
    int currentLevel = getLevel(currentXP);
    return currentLevel * xpPerLevel;
  }
  
  static double getProgress(int xp) {
    int currentLevel = getLevel(xp);
    int xpForCurrentLevel = (currentLevel - 1) * xpPerLevel;
    int xpForNextLevel = currentLevel * xpPerLevel;
    return (xp - xpForCurrentLevel) / (xpForNextLevel - xpForCurrentLevel);
  }
  
  static String getLevelTitle(int level) {
    if (level <= 3) return "Beginner";
    if (level <= 6) return "Learner";
    if (level <= 10) return "Scholar";
    if (level <= 15) return "Expert";
    if (level <= 20) return "Master";
    return "Legend";
  }
  
  static Color getLevelColor(int level) {
    if (level <= 3) return Colors.green;
    if (level <= 6) return Colors.blue;
    if (level <= 10) return Colors.purple;
    if (level <= 15) return Colors.orange;
    if (level <= 20) return AppColors.gold;
    return Colors.red;
  }
  
  static IconData getLevelIcon(int level) {
    if (level <= 3) return Icons.eco;
    if (level <= 6) return Icons.school;
    if (level <= 10) return Icons.auto_stories;
    if (level <= 15) return Icons.psychology;
    if (level <= 20) return Icons.star;
    return Icons.emoji_events;
  }
}

/// ============================================
/// BADGE/ACHIEVEMENT DEFINITIONS
/// ============================================

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredValue;
  final String type; // 'streak', 'xp', 'quiz', 'perfect'

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredValue,
    required this.type,
  });
}

class Achievements {
  static const List<Achievement> all = [
    Achievement(
      id: 'first_quiz',
      name: 'First Steps',
      description: 'Complete your first quiz',
      icon: Icons.flag,
      color: Colors.green,
      requiredValue: 1,
      type: 'quiz',
    ),
    Achievement(
      id: 'streak_3',
      name: 'On Fire!',
      description: '3-day login streak',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      requiredValue: 3,
      type: 'streak',
    ),
    Achievement(
      id: 'streak_7',
      name: 'Week Warrior',
      description: '7-day login streak',
      icon: Icons.whatshot,
      color: Colors.deepOrange,
      requiredValue: 7,
      type: 'streak',
    ),
    Achievement(
      id: 'xp_100',
      name: 'Rising Star',
      description: 'Earn 100 XP',
      icon: Icons.star_border,
      color: Colors.amber,
      requiredValue: 100,
      type: 'xp',
    ),
    Achievement(
      id: 'xp_500',
      name: 'Shining Star',
      description: 'Earn 500 XP',
      icon: Icons.star_half,
      color: Colors.amber,
      requiredValue: 500,
      type: 'xp',
    ),
    Achievement(
      id: 'xp_1000',
      name: 'Superstar',
      description: 'Earn 1000 XP',
      icon: Icons.star,
      color: Colors.amber,
      requiredValue: 1000,
      type: 'xp',
    ),
    Achievement(
      id: 'perfect_quiz',
      name: 'Perfect Score',
      description: 'Get 100% on a quiz',
      icon: Icons.verified,
      color: Colors.purple,
      requiredValue: 1,
      type: 'perfect',
    ),
    Achievement(
      id: 'quiz_10',
      name: 'Quiz Champion',
      description: 'Complete 10 quizzes',
      icon: Icons.emoji_events,
      color: Colors.blue,
      requiredValue: 10,
      type: 'quiz',
    ),
  ];
  
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// ============================================
/// APP THEME DATA
/// ============================================

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFFF0F4F8),
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.levelBlue,
        brightness: Brightness.light,
      ),
      
      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 16),
        bodyMedium: GoogleFonts.poppins(fontSize: 14),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        color: Colors.white,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.levelBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.levelBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: AppColors.primaryDark,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.levelBlue,
        brightness: Brightness.dark,
      ),
      
      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        color: const Color(0xFF1f2833),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF16213e),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.levelBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryDark,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
      ),
    );
  }
}
