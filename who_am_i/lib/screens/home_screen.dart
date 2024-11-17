import 'package:flutter/material.dart';
import 'deck_creation_screen.dart';
import 'game_start_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Who Am I'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DeckCreationScreen()),
                );
              },
              child: const Text('Deck erstellen'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GameStartScreen()),
                );
              },
              child: const Text('Spiel starten'),
            ),
          ],
        ),
      ),
    );
  }
}
