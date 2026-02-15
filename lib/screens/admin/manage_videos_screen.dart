import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_video_screen.dart';
import '../../widgets/animated_widgets.dart';

class ManageVideosScreen extends StatelessWidget {
  final int? grade;
  final String? subject;
  final String? subjectName;

  const ManageVideosScreen({
    super.key,
    this.grade,
    this.subject,
    this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    // Build query based on filters
    // Note: Using multiple where() with orderBy() requires a composite index in Firestore
    // To avoid index requirement, we'll filter and sort client-side when both filters are applied
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('videos');
    
    bool needsClientSideSort = false;
    
    if (grade != null && subject != null) {
      // When both filters are applied, skip orderBy to avoid composite index requirement
      query = query.where('targetGrade', isEqualTo: grade);
      query = query.where('category', isEqualTo: subject);
      needsClientSideSort = true;
    } else if (grade != null) {
      query = query.where('targetGrade', isEqualTo: grade).orderBy('timestamp', descending: true);
    } else if (subject != null) {
      query = query.where('category', isEqualTo: subject).orderBy('timestamp', descending: true);
    } else {
      query = query.orderBy('timestamp', descending: true);
    }

    String title = "Manage Videos 🎬";
    if (subjectName != null && grade != null) {
      title = "Grade $grade - $subjectName";
    } else if (subjectName != null) {
      title = subjectName!;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
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
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Video List
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: query.snapshots(),
                  builder: (context, snapshot) {
                    // Handle errors
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 60, color: Colors.red.withOpacity(0.7)),
                            const SizedBox(height: 16),
                            Text(
                              "Error loading videos",
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                "${snapshot.error}",
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    
                    var docs = snapshot.data!.docs.toList();
                    
                    // Client-side sort if needed (when composite index is not available)
                    if (needsClientSideSort) {
                      docs.sort((a, b) {
                        final aTimestamp = a.data()['timestamp'] as Timestamp?;
                        final bTimestamp = b.data()['timestamp'] as Timestamp?;
                        if (aTimestamp == null && bTimestamp == null) return 0;
                        if (aTimestamp == null) return 1;
                        if (bTimestamp == null) return -1;
                        return bTimestamp.compareTo(aTimestamp); // descending
                      });
                    }

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_library_outlined, size: 80, color: Colors.white.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              "No videos yet",
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tap + to add your first video",
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var data = docs[index].data();
                        String docId = docs[index].id;

                        return SlideInWidget(
                          delay: Duration(milliseconds: 50 * index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1a2a3a),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.play_circle_fill, color: Colors.red, size: 28),
                              ),
                              title: Text(
                                data['title'] ?? 'Untitled',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Grade ${data['targetGrade'] ?? '?'} • ${(data['category'] ?? 'unknown').toString().toUpperCase()}",
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF45aaf2)),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddVideoScreen(existingData: data, docId: docId),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Color(0xFFfc5c65)),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: const Color(0xFF1a2a3a),
                                          title: const Text('Delete Video?', style: TextStyle(color: Colors.white)),
                                          content: Text(
                                            'Are you sure you want to delete "${data['title']}"?',
                                            style: TextStyle(color: Colors.white.withOpacity(0.8)),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await FirebaseFirestore.instance.collection('videos').doc(docId).delete();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Video deleted'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
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
      floatingActionButton: SlideInWidget(
        delay: const Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddVideoScreen(
                  prefilledGrade: grade,
                  prefilledSubject: subject,
                ),
              ),
            );
          },
          backgroundColor: const Color(0xFF667eea),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Video", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
