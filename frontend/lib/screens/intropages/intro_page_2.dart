import 'package:flutter/material.dart';
import 'package:frontend/screens/signin_signup/signup_1.dart';

class NextPage extends StatelessWidget {
  const NextPage({super.key});

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

                // 🔹 Title
                const Text(
                  "Unfold Something New",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // 🔹 Subtitle / Tagline (2–3 lines)
                const Text(
                  "Notes, summaries, recommendations, and more.\n"
                  "Explore an AI experience built just for you.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // 🔹 Custom Sign Up button (neon glow + gradient border)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Stack(
                    children: [
                      // Outer glow
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF2D9C).withOpacity(0.45),
                                blurRadius: 40,
                                spreadRadius: -6,
                                offset: const Offset(0, 18),
                              ),
                              BoxShadow(
                                color: const Color(0xFF7C3AED).withOpacity(0.50),
                                blurRadius: 16,
                                spreadRadius: -10,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Gradient border ring
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF7C3AED), // purple
                                Color(0xFFFF2D9C),// magenta
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Stack(
                                children: [
                                  // Inner fill gradient
                                  Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFF1A0728),
                                          Color(0xFF0B0312),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Subtle crisp edge
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.18),
                                        width: 1,
                                      ),
                                    ),
                                  ),

                                  // Top highlight
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withOpacity(0.20),
                                            Colors.white.withOpacity(0.03),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.35, 0.80],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Tap ripple + text
                                  Material(
                                    type: MaterialType.transparency,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        // TODO: Navigate to SignUp Page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SignupEmailPage(),
                                          ),
                                        );
                                      },
                                      child: const Center(
                                        child: Text(
                                          "Sign Up",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Sign In button (Glassmorphism style)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      shadowColor: Colors.black.withOpacity(0.3),
                      elevation: 4,
                    ),
                    onPressed: () {
                      // Navigate to SignIn Page
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
