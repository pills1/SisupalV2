import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddVideoScreen extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final String? docId;
  final int? prefilledGrade;
  final String? prefilledSubject;

  const AddVideoScreen({
    super.key, 
    this.existingData, 
    this.docId,
    this.prefilledGrade,
    this.prefilledSubject,
  });

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = "mathematics"; // Default

  // --- NEW: Grade Selection Variable ---
  int _selectedGrade = 5;
  // ------------------------------------

  bool _isUploading = false;
  bool _isEditMode = false;

  final List<Map<String, String>> _categories = [
    {'id': 'mathematics', 'name': 'Mathematics'},
    {'id': 'sinhala', 'name': 'Sinhala'},
    {'id': 'english', 'name': 'English'},
    {'id': 'environment', 'name': 'Environment'},
    {'id': 'tamil', 'name': 'Tamil'},
    {'id': 'past_papers', 'name': 'Past Paper Discussions'},
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingData != null;
    if (_isEditMode) {
      _titleController.text = widget.existingData!['title'];
      _urlController.text = widget.existingData!['videoUrl'];
      _descController.text = widget.existingData!['description'];
      _selectedCategory = widget.existingData!['category'];

      // --- NEW: Load Grade if Editing ---
      if (widget.existingData!.containsKey('targetGrade')) {
        _selectedGrade = widget.existingData!['targetGrade'];
      }
      // ----------------------------------
    } else {
      // Use prefilled values if provided (when adding from grade/subject screen)
      if (widget.prefilledGrade != null) {
        _selectedGrade = widget.prefilledGrade!;
      }
      if (widget.prefilledSubject != null) {
        _selectedCategory = widget.prefilledSubject!;
      }
    }
  }

  Future<void> _saveVideo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUploading = true);

    try {
      Map<String, dynamic> data = {
        'title': _titleController.text.trim(),
        'videoUrl': _urlController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        // --- NEW: Save Grade to Firebase ---
        'targetGrade': _selectedGrade,
        // -----------------------------------
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (_isEditMode) {
        await FirebaseFirestore.instance.collection('videos').doc(widget.docId).update(data);
      } else {
        await FirebaseFirestore.instance.collection('videos').add(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video Saved! 🎬"), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? "Edit Video" : "Add New Video"), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Video Title", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: "YouTube URL", border: OutlineInputBorder(), hintText: "https://youtu.be/..."),
                validator: (v) => v!.isEmpty ? "Enter URL" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c['id'], child: Text(c['name']!))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),

              // Target Grade Dropdown
              DropdownButtonFormField<int>(
                value: 5,
                decoration: const InputDecoration(labelText: "Target Grade", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 5, child: Text("Grade 5 (Scholarship Exam)")),
                ],
                onChanged: (val) => setState(() => _selectedGrade = val ?? 5),
              ),
              const SizedBox(height: 16),
              // ---------------------------

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _saveVideo,
                  icon: const Icon(Icons.save),
                  label: _isUploading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Video"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}