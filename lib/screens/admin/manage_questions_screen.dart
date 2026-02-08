import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_question_screen.dart';

class ManageQuestionsScreen extends StatefulWidget {
  final String subject;

  const ManageQuestionsScreen({super.key, required this.subject});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  int _currentGrade = 5; // Default view is Grade 5

  @override
  Widget build(BuildContext context) {
    // Determine which collection to look at based on the dropdown
    String suffix = _currentGrade == 5 ? "general" : "grade$_currentGrade";
    String lessonId = "${widget.subject.toLowerCase()}_$suffix";

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage ${widget.subject}"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // GRADE SELECTOR
          DropdownButton<int>(
            dropdownColor: Colors.teal,
            value: _currentGrade,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            underline: Container(), // Remove underline
            items: const [
              DropdownMenuItem(value: 3, child: Text("Grade 3")),
              DropdownMenuItem(value: 4, child: Text("Grade 4")),
              DropdownMenuItem(value: 5, child: Text("Grade 5")),
            ],
            onChanged: (val) {
              setState(() {
                _currentGrade = val!;
              });
            },
          ),
          const SizedBox(width: 10),

          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddQuestionScreen(subject: widget.subject))
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Banner to show which grade we are editing
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.teal.shade50,
            child: Text(
              "Viewing Questions for Grade $_currentGrade",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.teal.shade900),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lessons')
                  .doc(lessonId)
                  .collection('questions')
                  .orderBy('qID', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.quiz, size: 60, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text("No Grade $_currentGrade questions yet."),
                        const SizedBox(height: 5),
                        const Text("Click + to add one!", style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String qText = data['question'];
                    String docId = docs[index].id;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(qText, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text("Answer: ${data['options'][data['correctIndex']]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddQuestionScreen(
                                        subject: widget.subject,
                                        existingData: data,
                                        docId: docId
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, lessonId, docId),
                            ),
                          ],
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
    );
  }

  void _confirmDelete(BuildContext context, String lessonId, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Question?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('lessons')
                  .doc(lessonId)
                  .collection('questions')
                  .doc(docId)
                  .delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}