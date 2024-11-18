import 'package:flutter/material.dart';
import 'package:who_am_i/screens/game_screen.dart';

class GameStartScreen extends StatelessWidget {
  const GameStartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiel starten'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
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
