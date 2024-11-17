import 'package:flutter/material.dart';

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
            const Text('Wähle ein Deck und füge Spielernamen hinzu!'),
            ElevatedButton(
              onPressed: () {
                // Logik zum Starten des Spiels
              },
              child: const Text('Deck auswählen'),
            ),
          ],
        ),
      ),
    );
  }
}
