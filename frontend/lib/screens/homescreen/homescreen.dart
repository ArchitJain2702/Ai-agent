import 'package:flutter/material.dart';
import 'package:frontend/screens/notesgenerator/notes_chatscreen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Premium Button + Profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B0B40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.star, color: Colors.white, size: 18),
                    label: const Text(
                      "Try Premium",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(
                      "assets/profile.png",
                    ), // Replace with your profile asset
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Greeting
              const Text(
                "Hi ",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Give any command naturally, from\n"
                "generating discription to creating notes",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 30),

              // Background Gradient Image
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF000000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white54,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Feature Cards (2x2 grid)
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: const [
                    _FeatureCard(title: "Generating Discription"),
                    _FeatureCard(title: "Writing Note"),
                  ],
                ),
              ),

              // Bottom Voice Button
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A0DAD), Color(0xFF000000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.mic, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Tap here to start work with Syncra",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Feature Card Widget
class _FeatureCard extends StatelessWidget {
  final String title;
  const _FeatureCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NotesChatScreen(),
    ),
  );
},

      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
