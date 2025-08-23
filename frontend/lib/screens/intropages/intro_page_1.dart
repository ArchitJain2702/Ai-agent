import 'package:flutter/material.dart';
import 'package:frontend/screens/intropages/intro_page_2.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  double _dragPosition = 0.0; // slider progress
  double _maxDrag = 0.0; // will calculate later

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.primaryDelta ?? 0;
      if (_dragPosition < 0) _dragPosition = 0;
      if (_dragPosition > _maxDrag) _dragPosition = _maxDrag;
    });
  }

  void _onDragEnd(BuildContext context) {
    if (_dragPosition > _maxDrag * 0.9) {
      // 🔹 Navigate if fully dragged
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NextPage()),
      );
    } else {
      // 🔹 Reset back if not fully dragged
      setState(() {
        _dragPosition = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 Background image
          Image.asset("assets/images/wisnu_bg.png", fit: BoxFit.cover),

          // 🔹 Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // 🔹 Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                const Text(
                  "Welcome to Aurora",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
'Your AI productivity hub. Create notes, discover videos, summarize content, and automate tasks — all in one place.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // 🔹 Slide to start
                LayoutBuilder(
                  builder: (context, constraints) {
                    _maxDrag = constraints.maxWidth - 70; // track - handle size
                    return Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: LinearGradient(
                          colors: [
                            Colors.purpleAccent.withOpacity(0.3),
                            Colors.blueAccent.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Progress fill
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _dragPosition + 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.purpleAccent,
                                  Colors.blueAccent,
                                ],
                              ),
                            ),
                          ),

                          // Center text
                          const Center(
                            child: Text(
                              " Get Started",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),

                          // Draggable handle
                          Positioned(
                            left: _dragPosition,
                            top: 5,
                            child: GestureDetector(
                              onHorizontalDragUpdate: _onDragUpdate,
                              onHorizontalDragEnd: (_) => _onDragEnd(context),
                              child: Container(
                                height: 50,
                                width: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.purpleAccent,
                                      Colors.blueAccent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}