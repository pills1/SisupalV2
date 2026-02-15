import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'video_lesson_screen.dart';
import '../widgets/animated_widgets.dart';
import '../services/video_tracking_service.dart';

class VideoListScreen extends StatefulWidget {
  final String category;
  final String title;

  const VideoListScreen({super.key, required this.category, required this.title});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  int? _studentGrade;
  bool _isLoadingGrade = true;
  final VideoTrackingService _trackingService = VideoTrackingService();

  @override
  void initState() {
    super.initState();
    _fetchStudentGrade();
  }

  Future<void> _fetchStudentGrade() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _studentGrade = doc.data()?['grade'] ?? 5;
          _isLoadingGrade = false;
        });
      }
    }
  }

  Color get _categoryColor {
    switch (widget.category) {
      case 'mathematics':
        return const Color(0xFF3498db);
      case 'sinhala':
        return const Color(0xFF9b59b6);
      case 'english':
        return const Color(0xFFe74c3c);
      case 'environment':
        return const Color(0xFF27ae60);
      case 'past_papers':
        return const Color(0xFFf39c12);
      default:
        return const Color(0xFF3498db);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    BouncingButton(
                      onPressed: () => Navigator.pop(context),
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
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            "Grade $_studentGrade",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _categoryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.play_circle, color: _categoryColor, size: 24),
                    ),
                  ],
                ),
              ),

              // Video List
              Expanded(
                child: _isLoadingGrade
                    ? Center(
                        child: CircularProgressIndicator(color: _categoryColor),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('videos')
                            .where('category', isEqualTo: widget.category)
                            .where('targetGrade', isEqualTo: _studentGrade)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(color: _categoryColor),
                            );
                          }

                          var docs = snapshot.data!.docs;

                          if (docs.isEmpty) {
                            return _buildEmptyState();
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              var data = docs[index].data() as Map<String, dynamic>;
                              return SlideInWidget(
                                delay: Duration(milliseconds: index * 100),
                                child: FutureBuilder<bool>(
                                  future: _trackingService.isCompleted(docs[index].id),
                                  builder: (context, watchSnapshot) {
                                    final isWatched = watchSnapshot.data ?? false;
                                    return _VideoCard(
                                      title: data['title'] ?? "Untitled Video",
                                      description: data['description'] ?? "Watch now",
                                      duration: data['duration'] ?? "10:00",
                                      thumbnailUrl: data['thumbnailUrl'],
                                      color: _categoryColor,
                                      isWatched: isWatched,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VideoLessonScreen(
                                              title: data['title'],
                                              videoUrl: data['videoUrl'],
                                              videoId: docs[index].id,
                                              category: widget.category,
                                            ),
                                          ),
                                        ).then((_) => setState(() {})); // Refresh on return
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam_off_outlined,
              size: 60,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No videos yet",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No Grade $_studentGrade videos for\n${widget.title} available",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String description;
  final String duration;
  final String? thumbnailUrl;
  final Color color;
  final VoidCallback onTap;
  final bool isWatched;

  const _VideoCard({
    required this.title,
    required this.description,
    required this.duration,
    this.thumbnailUrl,
    required this.color,
    required this.onTap,
    this.isWatched = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BouncingButton(
        onPressed: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1f2833),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 120,
                height: 90,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  image: thumbnailUrl != null
                      ? DecorationImage(
                          image: NetworkImage(thumbnailUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (thumbnailUrl == null)
                      Icon(Icons.play_circle, color: color, size: 40),
                    // Duration badge
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Play/Watched icon
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isWatched 
                        ? const Color(0xFF11998e).withOpacity(0.2)
                        : color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isWatched ? Icons.check : Icons.play_arrow, 
                    color: isWatched ? const Color(0xFF11998e) : color, 
                    size: 20,
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