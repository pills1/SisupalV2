import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported languages in the app
enum AppLanguage { english, sinhala, tamil }

/// Localization provider for managing language state
class LocalizationProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  AppLanguage _currentLanguage = AppLanguage.english;
  AppLanguage get currentLanguage => _currentLanguage;

  String get languageCode {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.sinhala:
        return 'si';
      case AppLanguage.tamil:
        return 'ta';
    }
  }

  LocalizationProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langIndex = prefs.getInt(_languageKey) ?? 0;
    _currentLanguage = AppLanguage.values[langIndex];
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = language;
    await prefs.setInt(_languageKey, language.index);
    notifyListeners();
  }

  /// Get translated string by key
  String translate(String key) {
    return AppLocalizations.get(key, _currentLanguage);
  }
}

/// Static localization strings
class AppLocalizations {
  static final Map<String, Map<AppLanguage, String>> _localizedStrings = {
    // Common
    'app_name': {
      AppLanguage.english: 'SisuPal',
      AppLanguage.sinhala: 'සිසුපාල්',
      AppLanguage.tamil: 'சிசுபால்',
    },
    'welcome': {
      AppLanguage.english: 'Welcome!',
      AppLanguage.sinhala: 'ආයුබෝවන්!',
      AppLanguage.tamil: 'வரவேற்பு!',
    },
    'login': {
      AppLanguage.english: 'Login',
      AppLanguage.sinhala: 'පිවිසෙන්න',
      AppLanguage.tamil: 'உள்நுழை',
    },
    'signup': {
      AppLanguage.english: 'Sign Up',
      AppLanguage.sinhala: 'ලියාපදිංචි වන්න',
      AppLanguage.tamil: 'பதிவு செய்',
    },
    'email': {
      AppLanguage.english: 'Email',
      AppLanguage.sinhala: 'විද්‍යුත් තැපෑල',
      AppLanguage.tamil: 'மின்னஞ்சல்',
    },
    'password': {
      AppLanguage.english: 'Password',
      AppLanguage.sinhala: 'මුරපදය',
      AppLanguage.tamil: 'கடவுச்சொல்',
    },
    'logout': {
      AppLanguage.english: 'Logout',
      AppLanguage.sinhala: 'පිටවීම',
      AppLanguage.tamil: 'வெளியேறு',
    },

    // Navigation
    'home': {
      AppLanguage.english: 'Home',
      AppLanguage.sinhala: 'මුල් පිටුව',
      AppLanguage.tamil: 'முகப்பு',
    },
    'profile': {
      AppLanguage.english: 'Profile',
      AppLanguage.sinhala: 'පැතිකඩ',
      AppLanguage.tamil: 'சுயவிவரம்',
    },
    'settings': {
      AppLanguage.english: 'Settings',
      AppLanguage.sinhala: 'සැකසුම්',
      AppLanguage.tamil: 'அமைப்புகள்',
    },
    'language': {
      AppLanguage.english: 'Language',
      AppLanguage.sinhala: 'භාෂාව',
      AppLanguage.tamil: 'மொழி',
    },

    // Dashboard
    'dashboard': {
      AppLanguage.english: 'Dashboard',
      AppLanguage.sinhala: 'උපකරණ පුවරුව',
      AppLanguage.tamil: 'டாஷ்போர்டு',
    },
    'subjects': {
      AppLanguage.english: 'Subjects',
      AppLanguage.sinhala: 'විෂයයන්',
      AppLanguage.tamil: 'பாடங்கள்',
    },
    'videos': {
      AppLanguage.english: 'Videos',
      AppLanguage.sinhala: 'වීඩියෝ',
      AppLanguage.tamil: 'வீடியோக்கள்',
    },
    'quizzes': {
      AppLanguage.english: 'Quizzes',
      AppLanguage.sinhala: 'ප්‍රශ්නාවලි',
      AppLanguage.tamil: 'வினாடி வினா',
    },
    'leaderboard': {
      AppLanguage.english: 'Leaderboard',
      AppLanguage.sinhala: 'ශ්‍රේණිගත කිරීම්',
      AppLanguage.tamil: 'தரவரிசை',
    },

    // Subjects
    'mathematics': {
      AppLanguage.english: 'Mathematics',
      AppLanguage.sinhala: 'ගණිතය',
      AppLanguage.tamil: 'கணிதம்',
    },
    'sinhala': {
      AppLanguage.english: 'Sinhala',
      AppLanguage.sinhala: 'සිංහල',
      AppLanguage.tamil: 'சிங்களம்',
    },
    'tamil': {
      AppLanguage.english: 'Tamil',
      AppLanguage.sinhala: 'දෙමළ',
      AppLanguage.tamil: 'தமிழ்',
    },
    'english': {
      AppLanguage.english: 'English',
      AppLanguage.sinhala: 'ඉංග්‍රීසි',
      AppLanguage.tamil: 'ஆங்கிலம்',
    },
    'environment': {
      AppLanguage.english: 'Environment',
      AppLanguage.sinhala: 'පරිසරය',
      AppLanguage.tamil: 'சூழல்',
    },

    // Quiz
    'quiz_time': {
      AppLanguage.english: 'Quiz Time!',
      AppLanguage.sinhala: 'ප්‍රශ්නාවලි වේලාව!',
      AppLanguage.tamil: 'வினாடி வினா நேரம்!',
    },
    'speed_quiz': {
      AppLanguage.english: 'Speed Quiz!',
      AppLanguage.sinhala: 'වේග ප්‍රශ්නාවලිය!',
      AppLanguage.tamil: 'வேக வினாடி வினா!',
    },
    'question': {
      AppLanguage.english: 'Question',
      AppLanguage.sinhala: 'ප්‍රශ්නය',
      AppLanguage.tamil: 'கேள்வி',
    },
    'next': {
      AppLanguage.english: 'Next',
      AppLanguage.sinhala: 'ඊළඟ',
      AppLanguage.tamil: 'அடுத்து',
    },
    'finish': {
      AppLanguage.english: 'Finish',
      AppLanguage.sinhala: 'අවසන්',
      AppLanguage.tamil: 'முடி',
    },
    'correct': {
      AppLanguage.english: 'Correct!',
      AppLanguage.sinhala: 'නිවැරදි!',
      AppLanguage.tamil: 'சரி!',
    },
    'wrong': {
      AppLanguage.english: 'Wrong!',
      AppLanguage.sinhala: 'වැරදි!',
      AppLanguage.tamil: 'தவறு!',
    },
    'score': {
      AppLanguage.english: 'Score',
      AppLanguage.sinhala: 'ලකුණු',
      AppLanguage.tamil: 'மதிப்பெண்',
    },

    // Gamification
    'xp': {
      AppLanguage.english: 'XP',
      AppLanguage.sinhala: 'අත්දැකීම් ලකුණු',
      AppLanguage.tamil: 'அனுபவ புள்ளிகள்',
    },
    'level': {
      AppLanguage.english: 'Level',
      AppLanguage.sinhala: 'මට්ටම',
      AppLanguage.tamil: 'நிலை',
    },
    'streak': {
      AppLanguage.english: 'Streak',
      AppLanguage.sinhala: 'පටිපාටිය',
      AppLanguage.tamil: 'தொடர்',
    },
    'achievements': {
      AppLanguage.english: 'Achievements',
      AppLanguage.sinhala: 'ජයග්‍රහණ',
      AppLanguage.tamil: 'சாதனைகள்',
    },
    'badges': {
      AppLanguage.english: 'Badges',
      AppLanguage.sinhala: 'ලාංඡන',
      AppLanguage.tamil: 'பதக்கங்கள்',
    },
    'combo': {
      AppLanguage.english: 'Combo',
      AppLanguage.sinhala: 'සංයෝජනය',
      AppLanguage.tamil: 'காம்போ',
    },

    // Profile
    'progress': {
      AppLanguage.english: 'Progress',
      AppLanguage.sinhala: 'ප්‍රගතිය',
      AppLanguage.tamil: 'முன்னேற்றம்',
    },
    'export_data': {
      AppLanguage.english: 'Export Your Data',
      AppLanguage.sinhala: 'ඔබගේ දත්ත අපනයනය කරන්න',
      AppLanguage.tamil: 'உங்கள் தரவை ஏற்றுமதி செய்',
    },
    'pdf_report': {
      AppLanguage.english: 'PDF Report',
      AppLanguage.sinhala: 'PDF වාර්තාව',
      AppLanguage.tamil: 'PDF அறிக்கை',
    },
    'csv_data': {
      AppLanguage.english: 'CSV Data',
      AppLanguage.sinhala: 'CSV දත්ත',
      AppLanguage.tamil: 'CSV தரவு',
    },

    // Messages
    'great_job': {
      AppLanguage.english: 'Great Job!',
      AppLanguage.sinhala: 'නියමයි!',
      AppLanguage.tamil: 'நல்ல வேலை!',
    },
    'keep_going': {
      AppLanguage.english: 'Keep Going!',
      AppLanguage.sinhala: 'ඉදිරියට යන්න!',
      AppLanguage.tamil: 'தொடருங்கள்!',
    },
    'try_again': {
      AppLanguage.english: 'Try Again',
      AppLanguage.sinhala: 'නැවත උත්සාහ කරන්න',
      AppLanguage.tamil: 'மீண்டும் முயற்சி செய்',
    },
    'cancel': {
      AppLanguage.english: 'Cancel',
      AppLanguage.sinhala: 'අවලංගු කරන්න',
      AppLanguage.tamil: 'ரத்து செய்',
    },
    'confirm': {
      AppLanguage.english: 'Confirm',
      AppLanguage.sinhala: 'තහවුරු කරන්න',
      AppLanguage.tamil: 'உறுதிப்படுத்து',
    },
    'save': {
      AppLanguage.english: 'Save',
      AppLanguage.sinhala: 'සුරකින්න',
      AppLanguage.tamil: 'சேமி',
    },
  };

  static String get(String key, AppLanguage language) {
    if (_localizedStrings.containsKey(key)) {
      return _localizedStrings[key]![language] ?? _localizedStrings[key]![AppLanguage.english] ?? key;
    }
    return key;
  }
}

/// Extension for easy translation access
extension TranslateExtension on BuildContext {
  String tr(String key) {
    // This should be used with Provider: context.read<LocalizationProvider>().translate(key)
    // For now, returns English as fallback
    return AppLocalizations.get(key, AppLanguage.english);
  }
}
