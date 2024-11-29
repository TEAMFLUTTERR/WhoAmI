import 'package:flutter/material.dart';
import 'package:who_am_i/screens/exlpain_screen.dart';
import 'deck_creation_screen.dart';
import 'game_start_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Who Am I',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.deepPurple.shade100,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStyledButton(
                context,
                'Deck erstellen',
                Icons.create,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DecksPage()),
                ),
                Colors.green,
              ),
              const SizedBox(height: 20),
              _buildStyledButton(
                context,
                'Spiel starten',
                Icons.play_arrow,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GameStartScreen()),
                ),
                Colors.blue,
              ),
              const SizedBox(height: 20),
              _buildStyledButton(
                context,
                'Wie spielt man?',
                Icons.help_outline,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExplanationScreen()),
                  //Hier müssten dann Werte der letzten Runde rein
                ),
                Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
    Color buttonColor,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
