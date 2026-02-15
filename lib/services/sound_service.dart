import 'package:audioplayers/audioplayers.dart';

/// Centralized sound service for all audio effects in the app
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool value) => _soundEnabled = value;

  /// Available sounds in assets/sounds/
  static const String _correctSound = 'correct.mp3';
  static const String _wrongSound = 'wrong.mp3';

  /// Play correct answer sound
  Future<void> playCorrect() async {
    await _play(_correctSound);
  }

  /// Play wrong answer sound  
  Future<void> playWrong() async {
    await _play(_wrongSound);
  }

  /// Play level up celebration sound (uses correct sound as fallback)
  Future<void> playLevelUp() async {
    await _play(_correctSound);
  }

  /// Play achievement unlocked sound (uses correct sound as fallback)
  Future<void> playAchievement() async {
    await _play(_correctSound);
  }

  /// Play combo sound (uses correct sound for feedback)
  Future<void> playCombo(int comboCount) async {
    if (comboCount >= 3) {
      await _play(_correctSound);
    }
  }

  /// Play streak celebration
  Future<void> playStreak() async {
    await _play(_correctSound);
  }

  /// Play button click (uses correct sound tone)
  Future<void> playClick() async {
    // Optional: skip click sounds to avoid too much audio
    // await _play(_correctSound);
  }

  /// Play XP earned sound
  Future<void> playXP() async {
    await _play(_correctSound);
  }

  Future<void> _play(String fileName) async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      // Silently fail if sound file doesn't exist
      print('Sound error: $e');
    }
  }

  /// Stop any currently playing sound
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// Dispose of resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
