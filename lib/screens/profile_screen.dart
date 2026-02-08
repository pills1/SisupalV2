import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  // --- 1. THE LIST OF AVATARS (No downloads needed!) ---
  final List<String> avatars = [
    'https://cdn-icons-png.flaticon.com/512/4140/4140048.png', // Boy
    'https://cdn-icons-png.flaticon.com/512/4140/4140047.png', // Girl
    'https://cdn-icons-png.flaticon.com/512/616/616408.png',   // Tiger
    'https://cdn-icons-png.flaticon.com/512/616/616450.png',   // Bear
    'https://cdn-icons-png.flaticon.com/512/616/616568.png',   // Lion
    'https://cdn-icons-png.flaticon.com/512/616/616430.png',   // Panda
  ];

  // --- 2. FUNCTION TO UPDATE AVATAR ---
  Future<void> _updateAvatar(String url) async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'avatar': url,
      });
      Navigator.pop(context); // Close the popup
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New Avatar Selected! 🐯")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String name = data['name'] ?? "Student";
          int grade = data['grade'] ?? 5;
          int xp = data['xp'] ?? 0;
          String currentAvatar = data['avatar'] ?? avatars[2]; // Default to Tiger

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),

                // --- 3. THE BIG AVATAR ---
                GestureDetector(
                  onTap: () => _showAvatarPicker(context),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueAccent, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(currentAvatar),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("Grade $grade Student", style: const TextStyle(fontSize: 16, color: Colors.grey)),

                const SizedBox(height: 30),

                // --- 4. STATS CARDS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard("Total XP", "$xp", Colors.amber, Icons.star),
                    _buildStatCard("Streak", "${data['streak'] ?? 0} Days", Colors.deepOrange, Icons.local_fire_department),
                  ],
                ),

                const SizedBox(height: 30),

                // Edit Button
                ElevatedButton.icon(
                  onPressed: () => _showAvatarPicker(context),
                  icon: const Icon(Icons.face),
                  label: const Text("Change My Character"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- 5. THE POPUP PICKER ---
  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 350,
          child: Column(
            children: [
              const Text("Pick Your Character!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _updateAvatar(avatars[index]),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(avatars[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}