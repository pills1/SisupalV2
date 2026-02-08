import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'report_preview_screen.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables
  Map<String, dynamic>? _studentData;
  List<Map<String, dynamic>> _examHistory = [];
  bool _isLoading = false;
  bool _isLinked = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkForLinkedChild();
  }

  Future<void> _checkForLinkedChild() async {
    User? parent = _auth.currentUser;
    if (parent == null) return;

    setState(() => _isLoading = true);

    try {
      DocumentSnapshot parentDoc = await _firestore.collection('users').doc(parent.uid).get();
      if (parentDoc.exists && parentDoc.data() != null) {
        var data = parentDoc.data() as Map<String, dynamic>;
        if (data.containsKey('linkedStudentUid')) {
          await _loadStudentData(data['linkedStudentUid'], isLinked: true);
        }
      }
    } catch (e) {
      print("Error checking link: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _linkChild() async {
    User? parent = _auth.currentUser;
    if (parent == null || _studentData == null) return;
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('users').doc(parent.uid).update({
        'linkedStudentUid': _studentData!['uid'],
      });
      setState(() => _isLinked = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Child Linked!"), backgroundColor: Colors.green));
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unlinkChild() async {
    User? parent = _auth.currentUser;
    if (parent == null) return;
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('users').doc(parent.uid).update({
        'linkedStudentUid': FieldValue.delete(),
      });
      setState(() {
        _studentData = null;
        _examHistory = [];
        _isLinked = false;
        _emailController.clear();
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchStudent() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _studentData = null;
      _examHistory = [];
      _isLinked = false;
    });

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'Student')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = "No student found.";
          _isLoading = false;
        });
        return;
      }
      await _loadStudentData(querySnapshot.docs.first.id, isLinked: false);

    } catch (e) {
      setState(() => _errorMessage = "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStudentData(String uid, {required bool isLinked}) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['uid'] = uid;

      final historySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('exam_results')
          .orderBy('date', descending: true)
          .get();

      final historyList = historySnapshot.docs.map((d) {
        var hData = d.data();
        if (hData['date'] != null) {
          Timestamp t = hData['date'];
          hData['formattedDate'] = DateFormat('MMM d, h:mm a').format(t.toDate());
        } else {
          hData['formattedDate'] = "Unknown";
        }
        return hData;
      }).toList();

      setState(() {
        _studentData = data;
        _examHistory = historyList;
        _isLinked = isLinked;
      });
    } catch (e) {
      print("Error loading: $e");
    }
  }

  // --- NEW: LOGIC TO CALCULATE AVERAGES ---
  Map<String, double> _calculateSubjectAverages() {
    Map<String, List<int>> scores = {}; // Map of Subject -> List of Percentages

    for (var exam in _examHistory) {
      String title = exam['examTitle'] ?? "";
      String subject = "Other";

      // Detect Subject from Title (e.g., "Mathematics Practice")
      if (title.contains("Math")) subject = "Math";
      else if (title.contains("Sinhala")) subject = "Sinhala";
      else if (title.contains("Environment")) subject = "Env";
      else if (title.contains("English")) subject = "English";
      else if (title.contains("Tamil")) subject = "Tamil";

      int score = exam['score'] ?? 0;
      int total = exam['total'] ?? 1;
      int percentage = ((score / total) * 100).round();

      if (!scores.containsKey(subject)) {
        scores[subject] = [];
      }
      scores[subject]!.add(percentage);
    }

    // Calculate Averages
    Map<String, double> averages = {};
    scores.forEach((key, value) {
      double avg = value.reduce((a, b) => a + b) / value.length;
      averages[key] = avg;
    });

    return averages;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate stats whenever UI builds
    final subjectStats = _calculateSubjectAverages();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
          // --- NEW: Profile Button ---
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black), // Use white for ParentDashboard if needed
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          // ---------------------------
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Search Box (Only if not linked)
            if (!_isLinked)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text("Find Your Child", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Student Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(icon: const Icon(Icons.search, color: Colors.indigo), onPressed: _searchStudent),
                        ),
                      ),
                      if (_errorMessage != null)
                        Padding(padding: const EdgeInsets.only(top: 10), child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ),

            if (_isLoading) const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator())),

            // --- STUDENT PROFILE ---
            if (_studentData != null) ...[
              const SizedBox(height: 20),
              // Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.blue, Colors.indigo]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Icon(Icons.face, size: 40, color: Colors.indigo)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_studentData!['name'] ?? "Unknown", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Text("Grade ${_studentData!['grade'] ?? 'N/A'}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                    ),
                    if (_isLinked) IconButton(icon: const Icon(Icons.link_off, color: Colors.white70), onPressed: _unlinkChild),
                  ],
                ),
              ),

              // Link Button (If not linked)
              if (!_isLinked) ...[
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _linkChild,
                  icon: const Icon(Icons.save),
                  label: const Text("Link this Account"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                )
              ],

              // --- REPORT CARD BUTTON ---
              Card(
                  elevation: 4,
                  color: Colors.blueGrey.shade50,
                  margin: const EdgeInsets.only(bottom: 20, top: 20),
                  child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 40),
                      title: const Text("Download Report Card", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Get a PDF summary of progress"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReportPreviewScreen()),
                        );
                      },
                  ),
              ),

              // --- NEW: SUBJECT PERFORMANCE CARDS ---
              if (subjectStats.isNotEmpty) ...[
                const SizedBox(height: 25),
                const Text("Performance Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: subjectStats.entries.map((entry) {
                      return _buildSubjectCard(entry.key, entry.value);
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 25),
              const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),

              // Activity List
              if (_examHistory.isEmpty)
                const Center(child: Text("No exams taken yet.", style: TextStyle(color: Colors.grey)))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _examHistory.length,
                  itemBuilder: (context, index) {
                    var exam = _examHistory[index];
                    int score = exam['score'] ?? 0;
                    int total = exam['total'] ?? 0;
                    double percentage = total == 0 ? 0 : (score / total);

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircularProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey.shade200,
                          color: score >= (total * 0.75) ? Colors.green : (score >= total/2 ? Colors.orange : Colors.red),
                        ),
                        title: Text(exam['examTitle'] ?? "Quiz", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(exam['formattedDate']),
                        trailing: Text("$score / $total", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper to build the colorful subject cards
  Widget _buildSubjectCard(String subject, double percentage) {
    Color color;
    if (percentage >= 80) color = Colors.green;
    else if (percentage >= 50) color = Colors.orange;
    else color = Colors.red;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          Text("${percentage.toInt()}%", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}