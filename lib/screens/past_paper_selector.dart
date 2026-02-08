import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class PastPaperSelector extends StatelessWidget {
  const PastPaperSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Past Papers"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 1. Listen to the 'papers' collection
        stream: FirebaseFirestore.instance
            .collection('papers')
            .orderBy('year', descending: true) // Newest papers first
            .snapshots(),
        builder: (context, snapshot) {
          // 2. Loading State
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          // 3. Empty State
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No past papers added yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // 4. List of Papers
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;

              // Safe Data Extraction
              String title = data['title'] ?? "Unknown Paper";
              String year = (data['year'] ?? "2023").toString();
              String url = data['pdfUrl'] ?? "";

              // Generate a pretty color based on year (Simple logic)
              Color cardColor;
              if (index % 3 == 0) cardColor = Colors.orange;
              else if (index % 3 == 1) cardColor = Colors.blue;
              else cardColor = Colors.green;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: cardColor.withOpacity(0.2),
                    child: Text(
                      year,
                      style: TextStyle(color: cardColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: const Text("Tap to view paper"),
                  trailing: const Icon(Icons.open_in_new, color: Colors.grey),

                  // 5. Open the PDF Link
                  onTap: () async {
                    if (url.isNotEmpty) {
                      final Uri uri = Uri.parse(url);
                      try {
                        // This opens the PDF in the Browser or Google Drive App
                        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Could not launch PDF URL")),
                            );
                          }
                        }
                      } catch (e) {
                        print("Error opening URL: $e");
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error: No PDF Link found for this paper")),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}