import 'package:flutter/material.dart';
import 'package:who_am_i/screens/game_screen.dart';

class GameStartScreen extends StatefulWidget {
  const GameStartScreen({Key? key}) : super(key: key);

  @override
  State<GameStartScreen> createState() => _GameStartScreenState();
}

class _GameStartScreenState extends State<GameStartScreen> {
  final List<String> availableDecks = [
    "Deck 1",
    "Deck 2",
    "Deck 3"
  ]; // Example decks
  String? selectedDeck;
  final List<String> playerNames = [];
  final TextEditingController playerNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiel starten'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Deck Selection Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Deck auswählen',
                border: OutlineInputBorder(),
              ),
              value: selectedDeck,
              onChanged: (value) {
                setState(() {
                  selectedDeck = value;
                });
              },
              items: availableDecks.map((deck) {
                return DropdownMenuItem(
                  value: deck,
                  child: Text(deck),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),

            // Player Name Input
            TextField(
              controller: playerNameController,
              decoration: const InputDecoration(
                labelText: 'Spielername hinzufügen',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    playerNames.add(value);
                    playerNameController.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),

            // Display Player Names
            Expanded(
              child: ListView.builder(
                itemCount: playerNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(playerNames[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          playerNames.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),

            // Start Game Button
            ElevatedButton(
              onPressed: selectedDeck != null && playerNames.isNotEmpty
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            deckImages: _getDeckImages(selectedDeck!),
                            playerNames: playerNames,
                          ),
                        ),
                      );
                    }
                  : null, // Disable button if no deck or players
              child: const Text('Spiel starten'),
            ),
          ],
        ),
      ),
    );
  }

  // Simulate getting deck images for the selected deck
  List<String> _getDeckImages(String deckName) {
    // Replace this with logic to fetch actual images for the selected deck
    return [
      'assets/images/image1.png',
      'assets/images/image2.png',
      'assets/images/image3.png',
      'assets/images/image4.png'
    ];
  }
}
