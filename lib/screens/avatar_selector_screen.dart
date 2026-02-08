import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvatarSelectorScreen extends StatefulWidget {
  const AvatarSelectorScreen({super.key});

  @override
  State<AvatarSelectorScreen> createState() => _AvatarSelectorScreenState();
}

class _AvatarSelectorScreenState extends State<AvatarSelectorScreen> {
  // A fun list of avatars to choose from
  final List<String> _avatars = [
    "👦", "u200D👧", "👨‍🚀", "🦸‍♂️", "🦸‍♀️", "🤖",
    "🦁", "🐯", "🐼", "🦊", "🐶", "🐱",
    "🦄", "🐲", "🦖", "👽", "👻", "👾",
    "⚽", "🏀", "🚀", "⭐", "🎨", "🎮"
  ];

  bool _isLoading = false;

  Future<void> _saveAvatar(String avatar) async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'avatar': avatar}); // Save the emoji to Firestore

      if (mounted) {
        Navigator.pop(context); // Go back to profile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avatar Updated!"), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Your Avatar")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // 4 items across
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _avatars.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _saveAvatar(_avatars[index]),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _avatars[index],
                style: const TextStyle(fontSize: 40),
              ),
            ),
          );
        },
      ),
    );
  }
}