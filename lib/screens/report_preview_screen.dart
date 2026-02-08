import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/report_generator.dart';

class ReportPreviewScreen extends StatefulWidget {
  // --- NEW: Allow passing a specific student ID ---
  final String? preSelectedUserId;
  final String? preSelectedUserName;

  const ReportPreviewScreen({
    super.key,
    this.preSelectedUserId,
    this.preSelectedUserName,
  });

  @override
  State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  String? targetUserId; // The ID of the user we are viewing
  String targetUserName = "Student";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.preSelectedUserId != null && widget.preSelectedUserId!.isNotEmpty) {
      targetUserId = widget.preSelectedUserId;
      targetUserName = widget.preSelectedUserName ?? "Student";
    }
    // PRIORITY 2: If no ID passed, use the currently logged-in user (Self-View)
    else {
      targetUserId = FirebaseAuth.instance.currentUser?.uid;
      targetUserName = FirebaseAuth.instance.currentUser?.displayName ?? "Student";
    }
  }

  // Function to find a student by email (Kept for Parents/Admins to switch manually)
  Future<void> _findStudentByEmail() async {
    TextEditingController emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("View Student Report"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter the student's login email to see their progress:"),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Student Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              setState(() => isLoading = true);

              try {
                String email = emailController.text.trim();
                if (email.isEmpty) return;

                // Query the 'users' collection for this email
                var querySnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: email)
                    .limit(1)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  var userDoc = querySnapshot.docs.first;
                  setState(() {
                    targetUserId = userDoc.id; // Switch to Student's ID
                    targetUserName = userDoc.data()['name'] ?? "Student"; // Update Name
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Found report for $targetUserName!"), backgroundColor: Colors.green),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Student email not found."), backgroundColor: Colors.red),
                    );
                  }
                }
              } catch (e) {
                print("Error finding student: $e");
              } finally {
                setState(() => isLoading = false);
              }
            },
            child: const Text("Find Report"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (targetUserId == null) return const Scaffold(body: Center(child: Text("Please Login")));

    return Scaffold(
      appBar: AppBar(
        title: Text("$targetUserName's Report"),
        backgroundColor: Colors.blueGrey,
        actions: [
          // SEARCH BUTTON (Allows switching students manually)
          IconButton(
            icon: const Icon(Icons.person_search),
            tooltip: "Find Student",
            onPressed: _findStudentByEmail,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchExamData(targetUserId!), // Fetch for the TARGET ID
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_late, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("No exam data found.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _findStudentByEmail,
                    icon: const Icon(Icons.search),
                    label: const Text("Search for Child's Email"),
                  ),
                ],
              ),
            );
          }

          // If data exists, generate PDF
          return PdfPreview(
            build: (format) => ReportGenerator().generateReport(
              targetUserName,
              snapshot.data!,
            ),
            canChangeOrientation: false,
            canDebug: false,
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchExamData(String uid) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('exam_results')
        .orderBy('date', descending: true)
        .limit(20)
        .get();

    return query.docs.map((doc) {
      var data = doc.data();
      if (data['date'] is Timestamp) {
        data['date'] = (data['date'] as Timestamp).toDate();
      }
      return data;
    }).toList();
  }
}