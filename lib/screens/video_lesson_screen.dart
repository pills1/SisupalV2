import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';
import '../services/video_tracking_service.dart';

class VideoLessonScreen extends StatefulWidget {
  final String title;
  final String videoUrl;
  final String? videoId;
  final String? category;

  const VideoLessonScreen({
    super.key,
    required this.title,
    required this.videoUrl,
    this.videoId,
    this.category,
  });

  @override
  State<VideoLessonScreen> createState() => _VideoLessonScreenState();
}

class _VideoLessonScreenState extends State<VideoLessonScreen> {
  late YoutubePlayerController _controller;
  final VideoTrackingService _trackingService = VideoTrackingService();
  Timer? _watchTimer;
  int _watchedSeconds = 0;
  bool _isPlaying = false;
  bool _hasStartedTracking = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? "",
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    // Listen to player state changes
    _controller.addListener(_onPlayerStateChange);
  }

  void _onPlayerStateChange() {
    if (!mounted) return;

    final state = _controller.value.playerState;
    
    // Track when video starts playing
    if (state == PlayerState.playing && !_hasStartedTracking) {
      _startTracking();
    }

    // Handle play/pause for timer
    if (state == PlayerState.playing && !_isPlaying) {
      setState(() => _isPlaying = true);
      _startWatchTimer();
    } else if (state != PlayerState.playing && _isPlaying) {
      setState(() => _isPlaying = false);
      _stopWatchTimer();
    }

    // Track completion
    if (state == PlayerState.ended) {
      _trackCompletion();
    }
  }

  void _startTracking() {
    _hasStartedTracking = true;
    final trackingId = widget.videoId ?? widget.videoUrl;
    _trackingService.startWatching(
      trackingId,
      videoTitle: widget.title,
      category: widget.category,
    );
  }

  void _startWatchTimer() {
    _watchTimer?.cancel();
    _watchTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _watchedSeconds += 10;
      // Update duration every 10 seconds
      final trackingId = widget.videoId ?? widget.videoUrl;
      _trackingService.updateWatchDuration(trackingId, _watchedSeconds);
    });
  }

  void _stopWatchTimer() {
    _watchTimer?.cancel();
    // Save current duration when pausing
    if (_hasStartedTracking) {
      final trackingId = widget.videoId ?? widget.videoUrl;
      _trackingService.updateWatchDuration(trackingId, _watchedSeconds);
    }
  }

  void _trackCompletion() {
    final trackingId = widget.videoId ?? widget.videoUrl;
    _trackingService.markCompleted(trackingId);
  }

  @override
  void dispose() {
    _watchTimer?.cancel();
    // Final duration update on dispose
    if (_hasStartedTracking) {
      final trackingId = widget.videoId ?? widget.videoUrl;
      _trackingService.updateWatchDuration(trackingId, _watchedSeconds);
    }
    _controller.removeListener(_onPlayerStateChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0f23), Color(0xFF1a1a2e)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Now Playing 🎬",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Watch time indicator
                    if (_watchedSeconds > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF11998e).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time, color: Color(0xFF11998e), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "${(_watchedSeconds ~/ 60)}m",
                              style: const TextStyle(
                                color: Color(0xFF11998e),
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

              // Video Player
              Expanded(
                child: Center(
                  child: YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: const Color(0xFF4facfe),
                    progressColors: const ProgressBarColors(
                      playedColor: Color(0xFF4facfe),
                      handleColor: Color(0xFF4facfe),
                      backgroundColor: Colors.white24,
                      bufferedColor: Colors.white38,
                    ),
                  ),
                ),
              ),

              // Bottom info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4facfe).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isPlaying ? Icons.play_arrow : Icons.pause,
                          color: const Color(0xFF4facfe),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isPlaying ? "Video is playing" : "Video is paused",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Your progress is being saved automatically",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_hasStartedTracking)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF11998e).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF11998e),
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
