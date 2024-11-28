import 'package:flutter/material.dart';
import 'package:who_am_i/screens/game_screen.dart';
import 'package:who_am_i/model/player.dart';
import 'package:hive/hive.dart';

class GameStartScreen extends StatefulWidget {
  const GameStartScreen({Key? key}) : super(key: key);

  @override
  _GameStartScreenState createState() => _GameStartScreenState();
}

class _GameStartScreenState extends State<GameStartScreen> {
  int _playerCount = 2;
  int _gameTimeMinutes = 5;
  List<TextEditingController> _playerNameControllers = [];
  late Box decksBox;
  List<Map<String, dynamic>> _availableDecks = [];
  String? _selectedDeck;

  @override
  void initState() {
    super.initState();
    _initializePlayerControllers();
    _loadDecks();
  }

  void _loadDecks() {
    decksBox = Hive.box('decks');
    setState(() {
      _availableDecks = decksBox.values
          .map((dynamic value) => {
                'name': value['name'],
                'imagePaths': value['imagePaths'] ?? []
              })
          .toList();
    });
  }

  void _initializePlayerControllers() {
    _playerNameControllers = List.generate(_playerCount,
        (index) => TextEditingController(text: 'Spieler ${index + 1}'));
  }

  @override
  void dispose() {
    for (var controller in _playerNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Spiel konfigurieren',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Deck Auswahl
                Text(
                  'Deck auswählen',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                _availableDecks.isEmpty
                    ? Center(
                        child: Text(
                          'Keine Decks vorhanden. Bitte erstellen Sie erst Decks.',
                          style: TextStyle(color: Colors.deepPurple.shade700),
                        ),
                      )
                    : Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedDeck,
                            hint: Text('Deck auswählen'),
                            items: _availableDecks
                                .map((deck) => DropdownMenuItem<String>(
                                      value: deck['name'],
                                      child: Text(deck['name']),
                                    ))
                                .toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedDeck = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                const SizedBox(height: 20),

                // Spieleranzahl einstellen
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Spieleranzahl: $_playerCount',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Slider(
                          value: _playerCount.toDouble(),
                          min: 2,
                          max: 8,
                          divisions: 6,
                          activeColor: Colors.deepPurple,
                          onChanged: (double value) {
                            setState(() {
                              _playerCount = value.round();
                              _initializePlayerControllers();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Spielzeit einstellen
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Spielzeit: $_gameTimeMinutes Minuten',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Slider(
                          value: _gameTimeMinutes.toDouble(),
                          min: 1,
                          max: 15,
                          divisions: 14,
                          activeColor: Colors.deepPurple,
                          onChanged: (double value) {
                            setState(() {
                              _gameTimeMinutes = value.round();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Spielernamen Eingabefelder
                Text(
                  'Spielernamen',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  _playerCount,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _playerNameControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Name von Spieler ${index + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Spiel starten Button
                ElevatedButton(
                  onPressed: () {
                    if (_selectedDeck == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Bitte wählen Sie ein Deck aus.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Holen des ausgewählten Decks und seiner Bildpfade
                    var selectedDeckData = _availableDecks.firstWhere(
                      (deck) => deck['name'] == _selectedDeck,
                    );

                    // Create list of Player objects with names and initial score of 0
                    List<Player> players = _playerNameControllers
                        .map((controller) => Player(
                              name: controller.text.trim(),
                              score: 0,
                            ))
                        .toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(
                          players: players,
                          deckImages: selectedDeckData['imagePaths'],
                          gameTimeMinutes: _gameTimeMinutes,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _selectedDeck != null ? Colors.blue : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow),
                      SizedBox(width: 10),
                      Text(
                        'Spiel starten',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}