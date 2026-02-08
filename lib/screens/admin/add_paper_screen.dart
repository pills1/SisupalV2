import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPaperScreen extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final String? docId;

  const AddPaperScreen({super.key, this.existingData, this.docId});

  @override
  State<AddPaperScreen> createState() => _AddPaperScreenState();
}

class _AddPaperScreenState extends State<AddPaperScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController(); // e.g., "2023 Scholarship Exam"
  final TextEditingController _yearController = TextEditingController();  // e.g., "2023"
  final TextEditingController _urlController = TextEditingController();   // PDF Link

  bool _isUploading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingData != null;
    if (_isEditMode) {
      _titleController.text = widget.existingData!['title'];
      _yearController.text = widget.existingData!['year'].toString();
      _urlController.text = widget.existingData!['pdfUrl'];
    }
  }

  Future<void> _savePaper() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUploading = true);

    try {
      Map<String, dynamic> data = {
        'title': _titleController.text.trim(),
        'year': int.parse(_yearController.text.trim()),
        'pdfUrl': _urlController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (_isEditMode) {
        await FirebaseFirestore.instance.collection('papers').doc(widget.docId).update(data);
      } else {
        await FirebaseFirestore.instance.collection('papers').add(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paper Saved! 📄"), backgroundColor: Colors.green));
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
      appBar: AppBar(title: Text(_isEditMode ? "Edit Paper" : "Add Past Paper"), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Paper Title", border: OutlineInputBorder(), hintText: "e.g., 2023 Scholarship Exam"),
                validator: (v) => v!.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Year", border: OutlineInputBorder(), hintText: "e.g., 2023"),
                validator: (v) => v!.isEmpty ? "Enter year" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: "PDF URL", border: OutlineInputBorder(), hintText: "Paste Google Drive/Firebase Link"),
                validator: (v) => v!.isEmpty ? "Enter URL" : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _savePaper,
                  icon: const Icon(Icons.save),
                  label: _isUploading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Paper"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}