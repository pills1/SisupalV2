import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Light Blue-Grey
      appBar: AppBar(
        title: const Text("Top Students"),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Student') // Only Students
            .orderBy('xp', descending: true)     // Highest XP first
            .limit(50)                           // Top 50
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No students yet!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String name = data['name'] ?? "Unknown";
              int xp = data['xp'] ?? 0;
              String uid = docs[index].id;

              // Is this the current user?
              bool isMe = (currentUser?.uid == uid);

              // Determine Rank Color
              Color cardColor = Colors.white;
              Color textColor = Colors.black;
              Widget? trailingIcon;

              if (index == 0) {
                cardColor = const Color(0xFFFFD700); // Gold
                trailingIcon = const Icon(Icons.emoji_events, color: Colors.white, size: 30);
              } else if (index == 1) {
                cardColor = const Color(0xFFC0C0C0); // Silver
                trailingIcon = const Icon(Icons.emoji_events, color: Colors.white70, size: 28);
              } else if (index == 2) {
                cardColor = const Color(0xFFCD7F32); // Bronze
                trailingIcon = const Icon(Icons.emoji_events, color: Colors.brown, size: 26);
              }

              // Highlight "Me" with a blue border if not in top 3
              BorderSide border = isMe
                  ? const BorderSide(color: Colors.blue, width: 3)
                  : BorderSide.none;

              return Card(
                elevation: 3,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: border,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.5),
                    child: data.containsKey('avatar') && data['avatar'] != ""
                        ? Text(data['avatar'], style: const TextStyle(fontSize: 24)) // Show Emoji
                        : Text(
                      "#${index + 1}", // Fallback to Rank Number
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  title: Text(
                    isMe ? "$name (You)" : name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$xp XP",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 10),
                        trailingIcon,
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}