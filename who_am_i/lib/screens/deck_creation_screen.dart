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
            const Text('Hier kannst du ein neues Deck erstellen!'),
            ElevatedButton(
              onPressed: () {
                // Logik zum Hinzufügen von Bildern
              },
              child: const Text('Bild hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }
}
