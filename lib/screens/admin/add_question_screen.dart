import 'dart:io';
import 'package:flutter/foundation.dart'; // Needed for kIsWeb
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddQuestionScreen extends StatefulWidget {
  final String subject;
  final Map<String, dynamic>? existingData;
  final String? docId;

  const AddQuestionScreen({
    super.key,
    required this.subject,
    this.existingData,
    this.docId
  });

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _questionController;
  late TextEditingController _opt1Controller;
  late TextEditingController _opt2Controller;
  late TextEditingController _opt3Controller;
  late TextEditingController _opt4Controller;
  late int _correctAnswerIndex;

  // Grade Selection
  int _selectedGrade = 5;

  // --- CHANGED: Use XFile for Cross-Platform compatibility ---
  XFile? _selectedImage;          // Replaces 'File? _selectedImage'
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();
  // -----------------------------------------------------------

  bool _isUploading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingData != null;

    _questionController = TextEditingController(text: widget.existingData?['question'] ?? "");
    List<dynamic> opts = widget.existingData?['options'] ?? ["", "", "", ""];
    _opt1Controller = TextEditingController(text: opts[0]);
    _opt2Controller = TextEditingController(text: opts[1]);
    _opt3Controller = TextEditingController(text: opts[2]);
    _opt4Controller = TextEditingController(text: opts[3]);
    _correctAnswerIndex = widget.existingData?['correctIndex'] ?? 0;

    if (_isEditMode) {
      if (widget.existingData!.containsKey('grade')) {
        _selectedGrade = widget.existingData!['grade'];
      }
      if (widget.existingData!.containsKey('imagePath')) {
        _uploadedImageUrl = widget.existingData!['imagePath'];
      }
    }
  }

  // --- 1. Cross-Platform Image Picker ---
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image; // Store as XFile
      });
    }
  }

  // --- 2. Cross-Platform Upload Logic ---
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _uploadedImageUrl;

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('question_images/$fileName.jpg');

      UploadTask uploadTask;

      // FIX: Handle Web vs Mobile Uploads
      if (kIsWeb) {
        // On Web, we must upload raw bytes
        Uint8List fileBytes = await _selectedImage!.readAsBytes();
        uploadTask = ref.putData(fileBytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        // On Mobile, we can upload the File object directly
        uploadTask = ref.putFile(File(_selectedImage!.path));
      }

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUploading = true);

    try {
      // Step A: Upload Image
      String? imageUrl = await _uploadImage();

      // Step B: Determine Collection
      String suffix = _selectedGrade == 5 ? "general" : "grade$_selectedGrade";
      String lessonId = "${widget.subject.toLowerCase()}_$suffix";

      // Step C: Prepare Data
      Map<String, dynamic> questionData = {
        'question': _questionController.text.trim(),
        'options': [
          _opt1Controller.text.trim(),
          _opt2Controller.text.trim(),
          _opt3Controller.text.trim(),
          _opt4Controller.text.trim(),
        ],
        'correctIndex': _correctAnswerIndex,
        'grade': _selectedGrade,
        'imagePath': imageUrl,
      };

      if (_isEditMode) {
        await FirebaseFirestore.instance
            .collection('lessons')
            .doc(lessonId)
            .collection('questions')
            .doc(widget.docId)
            .update(questionData);
      } else {
        questionData['qID'] = DateTime.now().millisecondsSinceEpoch;
        await FirebaseFirestore.instance
            .collection('lessons')
            .doc(lessonId)
            .collection('questions')
            .add(questionData);
      }

      // Ensure Lesson Doc Exists
      await FirebaseFirestore.instance.collection('lessons').doc(lessonId).set({
        'title': "${widget.subject} Grade $_selectedGrade",
        'subject': widget.subject,
        'grade': _selectedGrade,
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Saved Successfully! 📸"), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? "Edit Question" : "Add to ${widget.subject}"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Grade Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal)
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedGrade,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 3, child: Text("For Grade 3 Students")),
                      DropdownMenuItem(value: 4, child: Text("For Grade 4 Students")),
                      DropdownMenuItem(value: 5, child: Text("For Grade 5 (Scholarship)")),
                    ],
                    onChanged: (val) => setState(() => _selectedGrade = val!),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- IMAGE PICKER UI ---
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      // FIX: Display Logic for Web vs Mobile
                      child: kIsWeb
                          ? Image.network(_selectedImage!.path, fit: BoxFit.cover) // Web
                          : Image.file(File(_selectedImage!.path), fit: BoxFit.cover) // Mobile
                  )
                      : _uploadedImageUrl != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_uploadedImageUrl!, fit: BoxFit.cover))
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Tap to add an image (Optional)", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              // Remove Image Button
              if (_selectedImage != null || _uploadedImageUrl != null)
                TextButton.icon(
                  onPressed: () => setState(() { _selectedImage = null; _uploadedImageUrl = null; }),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text("Remove Image", style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 20),
              // ---------------------------

              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: "Question Text", border: OutlineInputBorder()),
                maxLines: 2,
                validator: (val) => val!.isEmpty ? "Enter a question" : null,
              ),
              const SizedBox(height: 20),
              _buildOptionField(_opt1Controller, "Option 1"),
              _buildOptionField(_opt2Controller, "Option 2"),
              _buildOptionField(_opt3Controller, "Option 3"),
              _buildOptionField(_opt4Controller, "Option 4"),

              const SizedBox(height: 20),
              const Text("Select Correct Answer:", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<int>(
                value: _correctAnswerIndex,
                items: List.generate(4, (index) => DropdownMenuItem(value: index, child: Text("Option ${index + 1}"))),
                onChanged: (val) => setState(() => _correctAnswerIndex = val!),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _saveQuestion,
                  icon: const Icon(Icons.save),
                  label: _isUploading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isEditMode ? "Update Question" : "Save Question"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (val) => val!.isEmpty ? "Enter an option" : null,
      ),
    );
  }
}