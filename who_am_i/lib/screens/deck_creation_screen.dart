import 'package:flutter/material.dart';

class DeckCreationScreen extends StatelessWidget {
  const DeckCreationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck erstellen'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                // Hinzufügen von Bildern implementieren
              },
              child: const Text('Bild hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }
}
